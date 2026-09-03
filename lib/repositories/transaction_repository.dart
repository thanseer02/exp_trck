import 'package:drift/drift.dart';
import '../database/app_database.dart' as db;
import '../models/transaction.dart' as domain;
import '../models/category.dart' as domain;
import '../models/transaction_type.dart';
import '../models/category_spending.dart';
import '../models/monthly_summary.dart';

class TransactionRepository {
  final db.AppDatabase _db;

  TransactionRepository(this._db);

  domain.Transaction _mapTransaction(db.Transaction t) {
    return domain.Transaction(
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

  // --- Transactions ---

  Future<int> addTransaction(domain.Transaction tx) async {
    try {
      return await _db.into(_db.transactions).insert(
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
    } catch (e) {
      throw Exception('Failed to add transaction: $e');
    }
  }

  Future<bool> updateTransaction(domain.Transaction tx) async {
    if (tx.id == null) return false;
    try {
      return await _db.update(_db.transactions).replace(
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
    } catch (e) {
      throw Exception('Failed to update transaction: $e');
    }
  }

  Future<int> deleteTransaction(int id) async {
    try {
      return await (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();
    } catch (e) {
      throw Exception('Failed to delete transaction: $e');
    }
  }

  Future<List<domain.Transaction>> getAllTransactions() async {
    try {
      final results = await (_db.select(_db.transactions)
        ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)]))
        .get();
      return results.map(_mapTransaction).toList();
    } catch (e) {
      throw Exception('Failed to load transactions: $e');
    }
  }

  Future<List<domain.Transaction>> getRecentTransactions({int limit = 5}) async {
    try {
      final results = await (_db.select(_db.transactions)
        ..orderBy([(t) => OrderingTerm(expression: t.date, mode: OrderingMode.desc)])
        ..limit(limit))
        .get();
      return results.map(_mapTransaction).toList();
    } catch (e) {
      throw Exception('Failed to load recent transactions: $e');
    }
  }

  Future<domain.Transaction?> getTransactionById(int id) async {
    try {
      final result = await (_db.select(_db.transactions)..where((t) => t.id.equals(id))).getSingleOrNull();
      if (result == null) return null;
      return _mapTransaction(result);
    } catch (e) {
      throw Exception('Failed to load transaction: $e');
    }
  }

  // --- Income ---

  Future<double> getTotalIncome() async {
    try {
      final amountExp = _db.transactions.amount.sum();
      final query = _db.selectOnly(_db.transactions)
        ..addColumns([amountExp])
        ..where(_db.transactions.type.equals('income'));
      final result = await query.map((row) => row.read(amountExp)).getSingleOrNull();
      return result ?? 0.0;
    } catch (e) {
      throw Exception('Failed to calculate total income: $e');
    }
  }

  Future<double> getMonthlyIncome(DateTime month) async {
    try {
      final start = DateTime(month.year, month.month, 1);
      final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
      
      final amountExp = _db.transactions.amount.sum();
      final query = _db.selectOnly(_db.transactions)
        ..addColumns([amountExp])
        ..where(_db.transactions.type.equals('income') & _db.transactions.date.isBetweenValues(start, end));
      final result = await query.map((row) => row.read(amountExp)).getSingleOrNull();
      return result ?? 0.0;
    } catch (e) {
      throw Exception('Failed to calculate monthly income: $e');
    }
  }

  Future<int> getTransactionCount(DateTime month) async {
    try {
      final start = DateTime(month.year, month.month, 1);
      final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
      
      final countExp = _db.transactions.id.count();
      final query = _db.selectOnly(_db.transactions)
        ..addColumns([countExp])
        ..where(_db.transactions.date.isBetweenValues(start, end));
      final result = await query.map((row) => row.read(countExp)).getSingleOrNull();
      return result ?? 0;
    } catch (e) {
      throw Exception('Failed to calculate transaction count: $e');
    }
  }

  Future<bool> hasTransactionsForCategory(int categoryId) async {
    try {
      final countExp = _db.transactions.id.count();
      final query = _db.selectOnly(_db.transactions)
        ..addColumns([countExp])
        ..where(_db.transactions.categoryId.equals(categoryId));
      final result = await query.map((row) => row.read(countExp)).getSingleOrNull();
      return (result ?? 0) > 0;
    } catch (e) {
      throw Exception('Failed to check category usage: $e');
    }
  }

  // --- Expenses ---

  Future<double> getTotalExpenses() async {
    try {
      final amountExp = _db.transactions.amount.sum();
      final query = _db.selectOnly(_db.transactions)
        ..addColumns([amountExp])
        ..where(_db.transactions.type.equals('expense'));
      final result = await query.map((row) => row.read(amountExp)).getSingleOrNull();
      return result ?? 0.0;
    } catch (e) {
      throw Exception('Failed to calculate total expenses: $e');
    }
  }

  Future<double> getMonthlyExpenses(DateTime month) async {
    try {
      final start = DateTime(month.year, month.month, 1);
      final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
      
      final amountExp = _db.transactions.amount.sum();
      final query = _db.selectOnly(_db.transactions)
        ..addColumns([amountExp])
        ..where(_db.transactions.type.equals('expense') & _db.transactions.date.isBetweenValues(start, end));
      final result = await query.map((row) => row.read(amountExp)).getSingleOrNull();
      return result ?? 0.0;
    } catch (e) {
      throw Exception('Failed to calculate monthly expenses: $e');
    }
  }

  // --- Balance ---

  Future<double> getBalance() async {
    try {
      final income = await getTotalIncome();
      final expense = await getTotalExpenses();
      return income - expense;
    } catch (e) {
      throw Exception('Failed to calculate balance: $e');
    }
  }

  // --- Analytics ---

  Future<List<CategorySpending>> getExpensesByCategory() async {
    try {
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
        final category = domain.Category(
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
    } catch (e) {
      throw Exception('Failed to load category expenses: $e');
    }
  }

  Future<List<CategorySpending>> getTopExpenses(DateTime month, {int limit = 3}) async {
    try {
      final start = DateTime(month.year, month.month, 1);
      final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);
      
      final amountExp = _db.transactions.amount.sum();
      final query = _db.selectOnly(_db.transactions)
        ..join([
          innerJoin(_db.categories, _db.categories.id.equalsExp(_db.transactions.categoryId))
        ])
        ..addColumns([_db.categories.id, _db.categories.name, _db.categories.icon, _db.categories.type, _db.categories.isDefault, _db.categories.createdAt, amountExp])
        ..where(_db.transactions.type.equals('expense') & _db.transactions.date.isBetweenValues(start, end))
        ..groupBy([_db.categories.id])
        ..orderBy([OrderingTerm(expression: amountExp, mode: OrderingMode.desc)])
        ..limit(limit);
      
      final results = await query.get();
      return results.map((row) {
        final category = domain.Category(
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
    } catch (e) {
      throw Exception('Failed to calculate top expenses: $e');
    }
  }

  Future<CategorySpending?> getTopSpendingCategory() async {
    try {
      final expenses = await getExpensesByCategory();
      if (expenses.isEmpty) return null;
      
      expenses.sort((a, b) => b.totalAmount.compareTo(a.totalAmount));
      return expenses.first;
    } catch (e) {
      throw Exception('Failed to calculate top spending category: $e');
    }
  }

  Future<Map<int, double>> getCategoryPercentage() async {
    try {
      final totalExpense = await getTotalExpenses();
      if (totalExpense == 0) return {};

      final expenses = await getExpensesByCategory();
      final Map<int, double> percentages = {};
      
      for (final spending in expenses) {
        if (spending.category.id != null) {
          percentages[spending.category.id!] = (spending.totalAmount / totalExpense) * 100;
        }
      }
      return percentages;
    } catch (e) {
      throw Exception('Failed to calculate category percentages: $e');
    }
  }

  Future<MonthlySummary> getMonthlySummary(DateTime month) async {
    try {
      final income = await getMonthlyIncome(month);
      final expense = await getMonthlyExpenses(month);
      final balance = income - expense;
      
      return MonthlySummary(
        totalIncome: income,
        totalExpense: expense,
        balance: balance,
        month: month,
      );
    } catch (e) {
      throw Exception('Failed to calculate monthly summary: $e');
    }
  }
}
