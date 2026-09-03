import 'package:flutter/material.dart';
import '../models/category.dart';
import '../models/transaction_type.dart';
import '../repositories/category_repository.dart';
import '../repositories/transaction_repository.dart';

class CategoryViewModel extends ChangeNotifier {
  final CategoryRepository _categoryRepository;
  final TransactionRepository _transactionRepository;

  CategoryViewModel(this._categoryRepository, this._transactionRepository);

  List<Category> _expenseCategories = [];
  List<Category> _incomeCategories = [];
  bool _isLoading = false;

  List<Category> get expenseCategories => _expenseCategories;
  List<Category> get incomeCategories => _incomeCategories;
  bool get isLoading => _isLoading;

  Future<void> loadCategories() async {
    _isLoading = true;
    notifyListeners();

    final allCategories = await _categoryRepository.getCategories();
    _expenseCategories = allCategories
        .where((c) => c.type == TransactionType.expense)
        .toList();
    _incomeCategories = allCategories
        .where((c) => c.type == TransactionType.income)
        .toList();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCategory(Category category) async {
    await _categoryRepository.addCategory(category);
    await loadCategories();
  }

  Future<void> updateCategory(Category category) async {
    await _categoryRepository.updateCategory(category);
    await loadCategories();
  }

  /// Returns true if successfully deleted, false if blocked due to existing transactions.
  Future<bool> deleteCategory(int id) async {
    final inUse = await _transactionRepository.hasTransactionsForCategory(id);
    if (inUse) {
      return false;
    }

    await _categoryRepository.deleteCategory(id);
    await loadCategories();
    return true;
  }
}
