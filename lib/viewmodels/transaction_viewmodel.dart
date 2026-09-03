import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../models/monthly_summary.dart';
import '../models/category_spending.dart';
import '../repositories/transaction_repository.dart';

class TransactionViewModel extends ChangeNotifier {
  final TransactionRepository _repository;

  TransactionViewModel(this._repository);

  List<Transaction> _transactions = [];
  List<Transaction> _recentTransactions = [];
  List<CategorySpending> _topSpending = [];
  MonthlySummary? _monthlySummary;
  double _balance = 0.0;
  bool _isLoading = false;

  List<Transaction> get transactions => _transactions;
  List<Transaction> get recentTransactions => _recentTransactions;
  List<CategorySpending> get topSpending => _topSpending;
  MonthlySummary? get monthlySummary => _monthlySummary;
  double get balance => _balance;
  bool get isLoading => _isLoading;

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
}
