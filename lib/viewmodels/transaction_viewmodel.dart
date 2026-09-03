import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/transaction_type.dart';
import '../models/category.dart';
import '../models/monthly_summary.dart';
import '../models/category_spending.dart';
import '../repositories/transaction_repository.dart';

enum TransactionSortOption {
  newest,
  oldest,
  highestAmount,
  lowestAmount,
}

class TransactionViewModel extends ChangeNotifier {
  final TransactionRepository _repository;

  TransactionViewModel(this._repository);

  List<Transaction> _transactions = [];
  List<Transaction> _recentTransactions = [];
  List<CategorySpending> _topSpending = [];
  MonthlySummary? _monthlySummary;
  double _balance = 0.0;
  bool _isLoading = false;

  // Filtering & Sorting State
  TransactionType? _filterType;
  Category? _filterCategory;
  DateTime? _filterDate;
  String _searchQuery = '';
  TransactionSortOption _currentSort = TransactionSortOption.newest;
  Timer? _searchDebouncer;

  List<Transaction> get transactions => _transactions;
  Map<String, List<Transaction>> get groupedTransactions {
    if (_cachedGroupedTransactions == null) {
      _cachedGroupedTransactions = _groupTransactions(filteredTransactions);
    }
    return _cachedGroupedTransactions!;
  }
  Map<String, List<Transaction>>? _cachedGroupedTransactions;

  List<Transaction> get recentTransactions => _recentTransactions;
  List<CategorySpending> get topSpending => _topSpending;
  MonthlySummary? get monthlySummary => _monthlySummary;
  double get balance => _balance;
  bool get isLoading => _isLoading;

  TransactionType? get filterType => _filterType;
  Category? get filterCategory => _filterCategory;
  DateTime? get filterDate => _filterDate;
  String get searchQuery => _searchQuery;
  TransactionSortOption get currentSort => _currentSort;

  // Analytics State
  DateTime _analyticsMonth = DateTime.now();
  MonthlySummary? _analyticsMonthlySummary;
  List<CategorySpending> _analyticsTopExpenses = [];
  int _analyticsTransactionCount = 0;
  List<String> _monthlyInsights = [];
  
  DateTime get analyticsMonth => _analyticsMonth;
  MonthlySummary? get analyticsMonthlySummary => _analyticsMonthlySummary;
  List<CategorySpending> get analyticsTopExpenses => _analyticsTopExpenses;
  int get analyticsTransactionCount => _analyticsTransactionCount;
  List<String> get monthlyInsights => _monthlyInsights;

  Future<void> loadTransactions({bool notify = true}) async {
    if (notify) {
      _isLoading = true;
      notifyListeners();
    }
    
    _transactions = await _repository.getAllTransactions();
    _cachedGroupedTransactions = null;
    
    if (notify) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDashboardData({bool notify = true}) async {
    if (notify) {
      _isLoading = true;
      notifyListeners();
    }

    final now = DateTime.now();
    _balance = await _repository.getBalance();
    _monthlySummary = await _repository.getMonthlySummary(now);
    _recentTransactions = await _repository.getRecentTransactions(limit: 5);
    _topSpending = await _repository.getTopExpenses(now, limit: 3);

    if (notify) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAnalyticsData({bool notify = true}) async {
    if (notify) {
      _isLoading = true;
      notifyListeners();
    }

    _analyticsMonthlySummary = await _repository.getMonthlySummary(_analyticsMonth);
    _analyticsTopExpenses = await _repository.getTopExpenses(_analyticsMonth, limit: 100);
    _analyticsTransactionCount = await _repository.getTransactionCount(_analyticsMonth);

    // Load previous month data
    final prevMonth = DateTime(_analyticsMonth.year, _analyticsMonth.month - 1);
    final prevSummary = await _repository.getMonthlySummary(prevMonth);
    final prevTopExpenses = await _repository.getTopExpenses(prevMonth, limit: 100);
    
    _generateInsights(prevSummary, prevTopExpenses);

    if (notify) {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshAll() async {
    _isLoading = true;
    notifyListeners();
    
    await Future.wait([
      loadTransactions(notify: false),
      loadDashboardData(notify: false),
      loadAnalyticsData(notify: false),
    ]);

    _isLoading = false;
    notifyListeners();
  }

  void _generateInsights(MonthlySummary prevSummary, List<CategorySpending> prevTopExpenses) {
    _monthlyInsights = [];
    final current = _analyticsMonthlySummary;
    if (current == null) return;

    // Data Safeguard
    if (prevSummary.totalExpense == 0 && prevSummary.totalIncome == 0) {
      return; // Not enough data for meaningful comparison
    }

    // Total Expenses Insight
    if (current.totalExpense > prevSummary.totalExpense) {
      final diff = current.totalExpense - prevSummary.totalExpense;
      _monthlyInsights.add('You spent \$${diff.toStringAsFixed(2)} more this month.');
    } else if (current.totalExpense < prevSummary.totalExpense) {
      if (prevSummary.totalExpense > 0) {
        final percent = ((prevSummary.totalExpense - current.totalExpense) / prevSummary.totalExpense * 100).toInt();
        _monthlyInsights.add('Your total expenses decreased by $percent%.');
      }
    }

    // Total Income Insight
    if (current.totalIncome > prevSummary.totalIncome && prevSummary.totalIncome > 0) {
      final percent = ((current.totalIncome - prevSummary.totalIncome) / prevSummary.totalIncome * 100).toInt();
      _monthlyInsights.add('Your income increased by $percent% this month!');
    }

    // Category Insights (Top 2 categories from current month)
    int categoryInsightsAdded = 0;
    for (var currentSpending in _analyticsTopExpenses) {
      if (categoryInsightsAdded >= 2) break;
      
      try {
        final prevSpending = prevTopExpenses.firstWhere((s) => s.category.id == currentSpending.category.id);
        
        final diff = currentSpending.totalAmount - prevSpending.totalAmount;
        if (diff.abs() > 50) { // Only show significant changes
          final catName = currentSpending.category.name;
          if (diff > 0) {
            _monthlyInsights.add('$catName spending increased by \$${diff.toStringAsFixed(0)}.');
          } else {
            _monthlyInsights.add('$catName spending decreased by \$${diff.abs().toStringAsFixed(0)}.');
          }
          categoryInsightsAdded++;
        }
      } catch (_) {
        // Category didn't exist or wasn't spent on last month
      }
    }
  }

  void setAnalyticsMonth(DateTime month) {
    _analyticsMonth = month;
    loadAnalyticsData();
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _repository.addTransaction(transaction);
    await refreshAll();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await _repository.updateTransaction(transaction);
    await refreshAll();
  }

  Future<void> deleteTransaction(int id) async {
    await _repository.deleteTransaction(id);
    await refreshAll();
  }

  // --- Filtering & Sorting ---

  void setFilterType(TransactionType? type) {
    _filterType = type;
    _cachedGroupedTransactions = null;
    notifyListeners();
  }

  void setFilterCategory(Category? category) {
    _filterCategory = category;
    _cachedGroupedTransactions = null;
    notifyListeners();
  }

  void setFilterDate(DateTime? date) {
    _filterDate = date;
    _cachedGroupedTransactions = null;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    if (_searchDebouncer?.isActive ?? false) _searchDebouncer!.cancel();
    _searchDebouncer = Timer(const Duration(milliseconds: 300), () {
      _searchQuery = query.toLowerCase();
      _cachedGroupedTransactions = null;
      notifyListeners();
    });
  }

  void setSortOption(TransactionSortOption sort) {
    _currentSort = sort;
    _cachedGroupedTransactions = null;
    notifyListeners();
  }

  void clearFilters() {
    _filterType = null;
    _filterCategory = null;
    _filterDate = null;
    _searchQuery = '';
    _currentSort = TransactionSortOption.newest;
    _cachedGroupedTransactions = null;
    notifyListeners();
  }

  List<Transaction> get filteredTransactions {
    List<Transaction> result = List.from(_transactions);

    // Apply Type Filter
    if (_filterType != null) {
      result = result.where((t) => t.type == _filterType).toList();
    }

    // Apply Category Filter
    if (_filterCategory != null) {
      result = result.where((t) => t.categoryId == _filterCategory!.id).toList();
    }

    // Apply Date Filter
    if (_filterDate != null) {
      result = result.where((t) => 
        t.date.year == _filterDate!.year &&
        t.date.month == _filterDate!.month &&
        t.date.day == _filterDate!.day
      ).toList();
    }

    // Apply Search
    if (_searchQuery.isNotEmpty) {
      result = result.where((t) {
        final note = t.note?.toLowerCase() ?? '';
        return note.contains(_searchQuery);
      }).toList();
    }

    // Apply Sorting
    switch (_currentSort) {
      case TransactionSortOption.newest:
        result.sort((a, b) => b.date.compareTo(a.date));
        break;
      case TransactionSortOption.oldest:
        result.sort((a, b) => a.date.compareTo(b.date));
        break;
      case TransactionSortOption.highestAmount:
        result.sort((a, b) => b.amount.compareTo(a.amount));
        break;
      case TransactionSortOption.lowestAmount:
        result.sort((a, b) => a.amount.compareTo(b.amount));
        break;
    }

    return result;
  }

  Map<String, List<Transaction>> _groupTransactions(List<Transaction> transactions) {
    final Map<String, List<Transaction>> groups = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final tx in transactions) {
      final txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);
      String key;
      if (txDate == today) {
        key = 'Today';
      } else if (txDate == yesterday) {
        key = 'Yesterday';
      } else {
        key = DateFormat.yMMMd().format(txDate);
      }

      if (!groups.containsKey(key)) {
        groups[key] = [];
      }
        groups[key]!.add(tx);
    }
    return groups;
  }
}
