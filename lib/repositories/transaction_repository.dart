import 'package:drift/drift.dart';
import '../database/app_database.dart';
import '../models/transaction.dart';


class TransactionRepository {
  final AppDatabase _db;

  TransactionRepository(this._db);

  Future<int> addTransaction(AppTransaction tx) {
    return _db.into(_db.transactions).insert(
      TransactionsCompanion.insert(
        type: tx.type,
        amount: tx.amount,
        categoryId: tx.categoryId,
        note: Value(tx.note),
        date: tx.date,
        createdAt: Value(tx.createdAt ?? DateTime.now()),
        updatedAt: Value(tx.updatedAt ?? DateTime.now()),
      )
    );
  }

  Future<bool> updateTransaction(AppTransaction tx) {
    if (tx.id == null) return Future.value(false);
    return _db.update(_db.transactions).replace(
      TransactionsCompanion(
        id: Value(tx.id!),
        type: Value(tx.type),
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

  Future<List<Transaction>> getTransactions() {
    return (_db.select(_db.transactions)
      ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]))
      .get();
  }

  Future<Transaction?> getTransactionById(int id) {
    return (_db.select(_db.transactions)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Future<List<Transaction>> getTransactionsByDate(DateTime start, DateTime end) {
    return (_db.select(_db.transactions)
      ..where((t) => t.date.isBetweenValues(start, end))
      ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]))
      .get();
  }

  Future<List<Transaction>> getTransactionsByCategory(int categoryId) {
    return (_db.select(_db.transactions)
      ..where((t) => t.categoryId.equals(categoryId))
      ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]))
      .get();
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

  Future<List<Map<String, dynamic>>> getExpensesByCategory() async {
    final amountExp = _db.transactions.amount.sum();
    final query = _db.selectOnly(_db.transactions)
      ..join([
        innerJoin(_db.categories, _db.categories.id.equalsExp(_db.transactions.categoryId))
      ])
      ..addColumns([_db.categories.id, _db.categories.name, amountExp])
      ..where(_db.transactions.type.equals('expense'))
      ..groupBy([_db.categories.id]);
    
    final results = await query.get();
    return results.map((row) {
      return {
        'categoryId': row.read(_db.categories.id),
        'categoryName': row.read(_db.categories.name),
        'totalAmount': row.read(amountExp) ?? 0.0,
      };
    }).toList();
  }

  Future<Map<String, dynamic>?> getTopSpendingCategory() async {
    final expenses = await getExpensesByCategory();
    if (expenses.isEmpty) return null;
    
    expenses.sort((a, b) => (b['totalAmount'] as double).compareTo(a['totalAmount'] as double));
    return expenses.first;
  }
}
