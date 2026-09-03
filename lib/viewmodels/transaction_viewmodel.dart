import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../repositories/transaction_repository.dart';
import '../database/app_database.dart'; // To get Drift Transaction

class TransactionViewModel extends ChangeNotifier {
  final TransactionRepository _repository;

  TransactionViewModel(this._repository);

  List<Transaction> _transactions = [];
  List<Transaction> get transactions => _transactions;

  Future<void> loadTransactions() async {
    _transactions = await _repository.getTransactions();
    notifyListeners();
  }

  Future<void> addTransaction(AppTransaction transaction) async {
    await _repository.addTransaction(transaction);
    await loadTransactions();
  }
}
