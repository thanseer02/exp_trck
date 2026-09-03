import 'package:flutter/material.dart';
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

  List<Transaction> get transactions => _transactions;
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

  Future<void> loadTransactions() async {
    _isLoading = true;
    notifyListeners();
    
    _transactions = await _repository.getAllTransactions();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> loadDashboardData() async {
    _isLoading = true;
    notifyListeners();

    final now = DateTime.now();
    _balance = await _repository.getBalance();
    _monthlySummary = await _repository.getMonthlySummary(now);
    _recentTransactions = await _repository.getRecentTransactions(limit: 5);
    _topSpending = await _repository.getTopExpenses(now, limit: 3);

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addTransaction(Transaction transaction) async {
    await _repository.addTransaction(transaction);
    await loadTransactions();
    await loadDashboardData();
  }

  Future<void> updateTransaction(Transaction transaction) async {
    await _repository.updateTransaction(transaction);
    await loadTransactions();
    await loadDashboardData();
  }

  Future<void> deleteTransaction(int id) async {
    await _repository.deleteTransaction(id);
    await loadTransactions();
    await loadDashboardData();
  }

  // --- Filtering & Sorting ---

  void setFilterType(TransactionType? type) {
    _filterType = type;
    notifyListeners();
  }

  void setFilterCategory(Category? category) {
    _filterCategory = category;
    notifyListeners();
  }

  void setFilterDate(DateTime? date) {
    _filterDate = date;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query.toLowerCase();
    notifyListeners();
  }

  void setSortOption(TransactionSortOption sort) {
    _currentSort = sort;
    notifyListeners();
  }

  void clearFilters() {
    _filterType = null;
    _filterCategory = null;
    _filterDate = null;
    _searchQuery = '';
    _currentSort = TransactionSortOption.newest;
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
}
