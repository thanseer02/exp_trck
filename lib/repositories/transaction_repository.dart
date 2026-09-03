import 'package:drift/drift.dart';
import '../database/app_database.dart' as db;
import '../models/transaction.dart';
import '../models/category.dart';
import '../models/transaction_type.dart';
import '../models/category_spending.dart';

class TransactionRepository {
  final db.AppDatabase _db;

  TransactionRepository(this._db);

  Transaction _mapTransaction(db.Transaction t) {
    return Transaction(
      id: t.id,
      type: TransactionTypeExtension.fromString(t.type),
      amount: t.amount,
      categoryId: t.categoryId,
      note: t.note,
      date: t.date,
      createdAt: t.createdAt,
      updatedAt: t.updatedAt,
    );
  }

  Category _mapCategory(db.Category c) {
    return Category(
      id: c.id,
      name: c.name,
      icon: c.icon,
      type: TransactionTypeExtension.fromString(c.type),
      isDefault: c.isDefault,
      createdAt: c.createdAt,
    );
  }

  Future<int> addTransaction(Transaction tx) {
    return _db.into(_db.transactions).insert(
      db.TransactionsCompanion.insert(
        type: tx.type.name,
        amount: tx.amount,
        categoryId: tx.categoryId,
        note: Value(tx.note),
        date: tx.date,
        createdAt: Value(tx.createdAt ?? DateTime.now()),
        updatedAt: Value(tx.updatedAt ?? DateTime.now()),
      )
    );
  }

  Future<bool> updateTransaction(Transaction tx) {
    if (tx.id == null) return Future.value(false);
    return _db.update(_db.transactions).replace(
      db.TransactionsCompanion(
        id: Value(tx.id!),
        type: Value(tx.type.name),
        amount: Value(tx.amount),
        categoryId: Value(tx.categoryId),
        note: Value(tx.note),
        date: Value(tx.date),
        updatedAt: Value(DateTime.now()),
      )
    );
  }

  Future<int> deleteTransaction(int id) {
    return (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();
  }

  Future<List<Transaction>> getTransactions() async {
    final results = await (_db.select(_db.transactions)
      ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]))
      .get();
    return results.map(_mapTransaction).toList();
  }

  Future<Transaction?> getTransactionById(int id) async {
    final result = await (_db.select(_db.transactions)..where((t) => t.id.equals(id))).getSingleOrNull();
    if (result == null) return null;
    return _mapTransaction(result);
  }

  Future<List<Transaction>> getTransactionsByDate(DateTime start, DateTime end) async {
    final results = await (_db.select(_db.transactions)
      ..where((t) => t.date.isBetweenValues(start, end))
      ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]))
      .get();
    return results.map(_mapTransaction).toList();
  }

  Future<List<Transaction>> getTransactionsByCategory(int categoryId) async {
    final results = await (_db.select(_db.transactions)
      ..where((t) => t.categoryId.equals(categoryId))
      ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]))
      .get();
    return results.map(_mapTransaction).toList();
  }

  Future<double> getTotalIncome() async {
    final amountExp = _db.transactions.amount.sum();
    final query = _db.selectOnly(_db.transactions)
      ..addColumns([amountExp])
      ..where(_db.transactions.type.equals('income'));
    final result = await query.map((row) => row.read(amountExp)).getSingleOrNull();
    return result ?? 0.0;
  }

  Future<double> getTotalExpenses() async {
    final amountExp = _db.transactions.amount.sum();
    final query = _db.selectOnly(_db.transactions)
      ..addColumns([amountExp])
      ..where(_db.transactions.type.equals('expense'));
    final result = await query.map((row) => row.read(amountExp)).getSingleOrNull();
    return result ?? 0.0;
  }

  Future<double> getBalance() async {
    final income = await getTotalIncome();
    final expense = await getTotalExpenses();
    return income - expense;
  }

  Future<List<CategorySpending>> getExpensesByCategory() async {
    final amountExp = _db.transactions.amount.sum();
    final query = _db.selectOnly(_db.transactions)
      ..join([
        innerJoin(_db.categories, _db.categories.id.equalsExp(_db.transactions.categoryId))
      ])
      ..addColumns([_db.categories.id, _db.categories.name, _db.categories.icon, _db.categories.type, _db.categories.isDefault, _db.categories.createdAt, amountExp])
      ..where(_db.transactions.type.equals('expense'))
      ..groupBy([_db.categories.id]);
    
    final results = await query.get();
    return results.map((row) {
      final category = Category(
        id: row.read(_db.categories.id),
        name: row.read(_db.categories.name)!,
        icon: row.read(_db.categories.icon)!,
        type: TransactionTypeExtension.fromString(row.read(_db.categories.type)!),
        isDefault: row.read(_db.categories.isDefault)!,
        createdAt: row.read(_db.categories.createdAt),
      );
      
      return CategorySpending(
        category: category,
        totalAmount: row.read(amountExp) ?? 0.0,
      );
    }).toList();
  }

  Future<CategorySpending?> getTopSpendingCategory() async {
    final expenses = await getExpensesByCategory();
    if (expenses.isEmpty) return null;
    
    expenses.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
    return expenses.first;
  }
}
