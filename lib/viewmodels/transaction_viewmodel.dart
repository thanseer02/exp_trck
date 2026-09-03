import 'package:flutter/material.dart';
import '../models/transaction.dart';
import '../repositories/transaction_repository.dart';

class TransactionViewModel extends ChangeNotifier {
  final TransactionRepository _repository = TransactionRepository();

  List<AppTransaction> _transactions = [];
  List<AppTransaction> get transactions => _transactions;

  Future<void> loadTransactions() async {
    _transactions = await _repository.getTransactions();
    notifyListeners();
  }

  Future<void> addTransaction(AppTransaction transaction) async {
    await _repository.insertTransaction(transaction);
    await loadTransactions();
  }
}
