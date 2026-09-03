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
      return await _db
          .into(_db.transactions)
          .insert(
            db.TransactionsCompanion.insert(
              type: tx.type.name,
              amount: tx.amount,
              categoryId: tx.categoryId,
              note: Value(tx.note),
              date: tx.date,
              createdAt: Value(tx.createdAt ?? DateTime.now()),
              updatedAt: Value(tx.updatedAt ?? DateTime.now()),
            ),
          );
    } catch (e) {
      throw Exception('Failed to add transaction: $e');
    }
  }

  Future<bool> updateTransaction(domain.Transaction tx) async {
    if (tx.id == null) return false;
    try {
      return await _db
          .update(_db.transactions)
          .replace(
            db.TransactionsCompanion(
              id: Value(tx.id!),
              type: Value(tx.type.name),
              amount: Value(tx.amount),
              categoryId: Value(tx.categoryId),
              note: Value(tx.note),
              date: Value(tx.date),
              updatedAt: Value(DateTime.now()),
            ),
          );
    } catch (e) {
      throw Exception('Failed to update transaction: $e');
    }
  }

  Future<void> deleteTransaction(int id) async {
    try {
      await (_db.delete(_db.transactions)..where((t) => t.id.equals(id))).go();
    } catch (e) {
      throw Exception('Failed to delete transaction: $e');
    }
  }

  Future<void> deleteAllTransactions() async {
    try {
      await _db.delete(_db.transactions).go();
    } catch (e) {
      throw Exception('Failed to delete all transactions: $e');
    }
  }

  Future<void> wipeData() async {
    try {
      await _db.wipeData();
    } catch (e) {
      throw Exception('Failed to wipe data: $e');
    }
  }

  Future<List<domain.Transaction>> getAllTransactions() async {
    try {
      final results =
          await (_db.select(_db.transactions)..orderBy([
                (t) =>
                    OrderingTerm(expression: t.date, mode: OrderingMode.desc),
              ]))
              .get();
      return results.map(_mapTransaction).toList();
    } catch (e) {
      throw Exception('Failed to load transactions: $e');
    }
  }

  Future<List<domain.Transaction>> getTransactionsForPeriod(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final results =
          await (_db.select(_db.transactions)
                ..where((t) => t.date.isBetweenValues(start, end))
                ..orderBy([
                  (t) =>
                      OrderingTerm(expression: t.date, mode: OrderingMode.desc),
                ]))
              .get();
      return results.map(_mapTransaction).toList();
    } catch (e) {
      throw Exception('Failed to load transactions for period: $e');
    }
  }

  Future<List<domain.Transaction>> getRecentTransactions({
    int limit = 5,
  }) async {
    try {
      final results =
          await (_db.select(_db.transactions)
                ..orderBy([
                  (t) =>
                      OrderingTerm(expression: t.date, mode: OrderingMode.desc),
                ])
                ..limit(limit))
              .get();
      return results.map(_mapTransaction).toList();
    } catch (e) {
      throw Exception('Failed to load recent transactions: $e');
    }
  }

  Future<domain.Transaction?> getTransactionById(int id) async {
    try {
      final result = await (_db.select(
        _db.transactions,
      )..where((t) => t.id.equals(id))).getSingleOrNull();
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
      final result = await query
          .map((row) => row.read(amountExp))
          .getSingleOrNull();
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
        ..where(
          _db.transactions.type.equals('income') &
              _db.transactions.date.isBetweenValues(start, end),
        );
      final result = await query
          .map((row) => row.read(amountExp))
          .getSingleOrNull();
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
      final result = await query
          .map((row) => row.read(countExp))
          .getSingleOrNull();
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
      final result = await query
          .map((row) => row.read(countExp))
          .getSingleOrNull();
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
      final result = await query
          .map((row) => row.read(amountExp))
          .getSingleOrNull();
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
        ..where(
          _db.transactions.type.equals('expense') &
              _db.transactions.date.isBetweenValues(start, end),
        );
      final result = await query
          .map((row) => row.read(amountExp))
          .getSingleOrNull();
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

  // --- Period Analytics Methods ---

  // --- Assistant Analytics Methods ---

Future<Map<String, dynamic>?> getAssistantTopSpendingCategory({DateTime? start, DateTime? end}) async {
    try {
      final amountExp = _db.transactions.amount.sum();
      
      var query = _db.select(_db.transactions).join([
        innerJoin(_db.categories, _db.categories.id.equalsExp(_db.transactions.categoryId))
      ])
        ..addColumns([amountExp])
        ..where(_db.transactions.type.equals('expense'))
        ..groupBy([_db.categories.id])
        ..orderBy([OrderingTerm(expression: amountExp, mode: OrderingMode.desc)])
        ..limit(1);
        
      if (start != null && end != null) {
        query.where(_db.transactions.date.isBetweenValues(start, end));
      }
      
      final row = await query.getSingleOrNull();
      if (row == null) return null;
      
      final dbCategory = row.readTable(_db.categories);
      final amount = row.read(amountExp);
      
      final category = domain.Category(
        id: dbCategory.id,
        name: dbCategory.name,
        icon: dbCategory.icon,
        type: TransactionTypeExtension.fromString(dbCategory.type),
        isDefault: dbCategory.isDefault,
        createdAt: dbCategory.createdAt,
      );
      
      // Get total expenses to calculate percentage
      var totalQuery = _db.selectOnly(_db.transactions)
        ..addColumns([amountExp])
        ..where(_db.transactions.type.equals('expense'));
      if (start != null && end != null) {
        totalQuery.where(_db.transactions.date.isBetweenValues(start, end));
      }
      final totalRow = await totalQuery.getSingleOrNull();
      final total = totalRow?.read(amountExp) ?? 0.0;
      
      return {
        'name': category.name,
        'category': category,
        'amount': amount,
        'total': total
      };
    } catch (e) {
      throw Exception('Failed to get top spending category: $e');
    }
  }


  Future<double> getCategoryExpense(String categoryName, {DateTime? start, DateTime? end}) async {
    try {
      final amountExp = _db.transactions.amount.sum();
      
      var query = _db.selectOnly(_db.transactions)
        ..join([
          innerJoin(_db.categories, _db.categories.id.equalsExp(_db.transactions.categoryId))
        ])
        ..addColumns([amountExp])
        ..where(_db.transactions.type.equals('expense') & _db.categories.name.lower().equals(categoryName.toLowerCase()));
        
      if (start != null && end != null) {
        query.where(_db.transactions.date.isBetweenValues(start, end));
      }
      
      final result = await query.map((row) => row.read(amountExp)).getSingleOrNull();
      return result ?? 0.0;
    } catch (e) {
      throw Exception('Failed to get category expense: $e');
    }
  }

  
Future<Map<String, dynamic>?> getLargestExpenseTransaction({DateTime? start, DateTime? end}) async {
    try {
      var query = _db.select(_db.transactions).join([
        leftOuterJoin(_db.categories, _db.categories.id.equalsExp(_db.transactions.categoryId)),
      ])
        ..where(_db.transactions.type.equals('expense'))
        ..orderBy([OrderingTerm(expression: _db.transactions.amount, mode: OrderingMode.desc)])
        ..limit(1);
        
      if (start != null && end != null) {
        query.where(_db.transactions.date.isBetweenValues(start, end));
      }
      
      final row = await query.getSingleOrNull();
      if (row == null) return null;
      
      final dbTransaction = row.readTable(_db.transactions);
      final dbCategory = row.readTableOrNull(_db.categories);

      final tx = domain.Transaction(
        id: dbTransaction.id,
        amount: dbTransaction.amount,
        date: dbTransaction.date,
        type: TransactionTypeExtension.fromString(dbTransaction.type),
        categoryId: dbTransaction.categoryId,
        note: dbTransaction.note,
        createdAt: dbTransaction.createdAt,
      );
      
      return {
        'transaction': tx,
        'categoryName': dbCategory?.name ?? 'General',
      };
    } catch (e) {
      throw Exception('Failed to get largest expense transaction: $e');
    }
  }


  Future<double> getLargestExpense({DateTime? start, DateTime? end}) async {
    try {
      final maxExp = _db.transactions.amount.max();
      var query = _db.selectOnly(_db.transactions)
        ..addColumns([maxExp])
        ..where(_db.transactions.type.equals('expense'));
        
      if (start != null && end != null) {
        query.where(_db.transactions.date.isBetweenValues(start, end));
      }
      
      final result = await query.map((row) => row.read(maxExp)).getSingleOrNull();
      return result ?? 0.0;
    } catch (e) {
      throw Exception('Failed to get largest expense: $e');
    }
  }

  Future<double> getAverageExpense({DateTime? start, DateTime? end}) async {
    try {
      final avgExp = _db.transactions.amount.avg();
      var query = _db.selectOnly(_db.transactions)
        ..addColumns([avgExp])
        ..where(_db.transactions.type.equals('expense'));
        
      if (start != null && end != null) {
        query.where(_db.transactions.date.isBetweenValues(start, end));
      }
      
      final result = await query.map((row) => row.read(avgExp)).getSingleOrNull();
      return result ?? 0.0;
    } catch (e) {
      throw Exception('Failed to get average expense: $e');
    }
  }

  Future<int> getAssistantTransactionCount({DateTime? start, DateTime? end}) async {
    try {
      final countExp = _db.transactions.id.count();
      var query = _db.selectOnly(_db.transactions)..addColumns([countExp]);
      if (start != null && end != null) {
        query.where(_db.transactions.date.isBetweenValues(start, end));
      }
      final result = await query.map((row) => row.read(countExp)).getSingleOrNull();
      return result ?? 0;
    } catch (e) {
      throw Exception('Failed to get transaction count: $e');
    }
  }

  Future<Map<String, dynamic>?> getMostExpensiveDay({DateTime? start, DateTime? end}) async {
    try {
      var query = _db.select(_db.transactions)..where((t) => t.type.equals('expense'));
      if (start != null && end != null) {
        query.where((t) => t.date.isBetweenValues(start, end));
      }
      final results = await query.get();
      if (results.isEmpty) return null;
      
      final Map<String, double> dailyTotals = {};
      for (var tx in results) {
        final dateKey = '${tx.date.year}-${tx.date.month.toString().padLeft(2, '0')}-${tx.date.day.toString().padLeft(2, '0')}';
        dailyTotals[dateKey] = (dailyTotals[dateKey] ?? 0.0) + tx.amount;
      }
      
      String maxDay = '';
      double maxAmount = 0;
      dailyTotals.forEach((key, value) {
        if (value > maxAmount) {
          maxAmount = value;
          maxDay = key;
        }
      });
      
      if (maxAmount == 0) return null;
      
      final parts = maxDay.split('-');
      final parsedDate = DateTime(int.parse(parts[0]), int.parse(parts[1]), int.parse(parts[2]));
      
      return {
        'date': parsedDate,
        'amount': maxAmount,
      };
    } catch (e) {
      throw Exception('Failed to get most expensive day: $e');
    }
  }

  Future<Map<String, dynamic>?> getCategoryChangeMost(DateTime currentStart, DateTime currentEnd, DateTime lastStart, DateTime lastEnd, {required bool isIncrease}) async {
    try {
      final currentQuery = _db.selectOnly(_db.transactions)
        ..addColumns([_db.transactions.categoryId, _db.transactions.amount.sum()])
        ..where(_db.transactions.type.equals('expense'))
        ..where(_db.transactions.date.isBetweenValues(currentStart, currentEnd))
        ..groupBy([_db.transactions.categoryId]);
        
      final lastQuery = _db.selectOnly(_db.transactions)
        ..addColumns([_db.transactions.categoryId, _db.transactions.amount.sum()])
        ..where(_db.transactions.type.equals('expense'))
        ..where(_db.transactions.date.isBetweenValues(lastStart, lastEnd))
        ..groupBy([_db.transactions.categoryId]);

      final currentResults = await currentQuery.get();
      final lastResults = await lastQuery.get();
      
      final Map<int, double> currentTotals = {};
      for (var row in currentResults) {
         currentTotals[row.read(_db.transactions.categoryId)!] = row.read(_db.transactions.amount.sum()) ?? 0.0;
      }
      
      final Map<int, double> lastTotals = {};
      for (var row in lastResults) {
         lastTotals[row.read(_db.transactions.categoryId)!] = row.read(_db.transactions.amount.sum()) ?? 0.0;
      }
      
      int? targetCategoryId;
      double maxDifference = 0;
      
      final allCategoryIds = {...currentTotals.keys, ...lastTotals.keys};
      
      for (var catId in allCategoryIds) {
        final current = currentTotals[catId] ?? 0.0;
        final last = lastTotals[catId] ?? 0.0;
        
        final diff = current - last;
        
        if (isIncrease && diff > maxDifference) {
          maxDifference = diff;
          targetCategoryId = catId;
        } else if (!isIncrease && diff < -maxDifference) {
          maxDifference = -diff;
          targetCategoryId = catId;
        }
      }
      
      if (targetCategoryId == null || maxDifference == 0) return null;
      
      final categoryQuery = _db.select(_db.categories)..where((c) => c.id.equals(targetCategoryId!));
      final category = await categoryQuery.getSingleOrNull();
      
      if (category == null) return null;
      
      return {
        'name': category.name,
        'difference': maxDifference,
        'current': currentTotals[targetCategoryId] ?? 0.0,
        'last': lastTotals[targetCategoryId] ?? 0.0,
      };
    } catch (e) {
      throw Exception('Failed to get category change: $e');
    }
  }


  Future<double> getIncomeForPeriod(DateTime start, DateTime end) async {
    try {
      final amountExp = _db.transactions.amount.sum();
      final query = _db.selectOnly(_db.transactions)
        ..addColumns([amountExp])
        ..where(
          _db.transactions.type.equals('income') &
              _db.transactions.date.isBetweenValues(start, end),
        );
      final result = await query
          .map((row) => row.read(amountExp))
          .getSingleOrNull();
      return result ?? 0.0;
    } catch (e) {
      throw Exception('Failed to calculate income for period: $e');
    }
  }

  Future<double> getExpensesForPeriod(DateTime start, DateTime end) async {
    try {
      final amountExp = _db.transactions.amount.sum();
      final query = _db.selectOnly(_db.transactions)
        ..addColumns([amountExp])
        ..where(
          _db.transactions.type.equals('expense') &
              _db.transactions.date.isBetweenValues(start, end),
        );
      final result = await query
          .map((row) => row.read(amountExp))
          .getSingleOrNull();
      return result ?? 0.0;
    } catch (e) {
      throw Exception('Failed to calculate expenses for period: $e');
    }
  }

  Future<MonthlySummary> getSummaryForPeriod(
    DateTime start,
    DateTime end,
  ) async {
    try {
      final income = await getIncomeForPeriod(start, end);
      final expense = await getExpensesForPeriod(start, end);

      return MonthlySummary(
        month: start,
        totalIncome: income,
        totalExpense: expense,
        balance: income - expense,
      );
    } catch (e) {
      throw Exception('Failed to calculate summary for period: $e');
    }
  }

  Future<List<CategorySpending>> getTopExpensesForPeriod(
    DateTime start,
    DateTime end, {
    int limit = 5,
  }) async {
    try {
      final amountExp = _db.transactions.amount.sum();
      final query = _db.selectOnly(_db.transactions)
        ..join([
          innerJoin(
            _db.categories,
            _db.categories.id.equalsExp(_db.transactions.categoryId),
          ),
        ])
        ..addColumns([
          _db.categories.id,
          _db.categories.name,
          _db.categories.icon,
          _db.categories.type,
          _db.categories.isDefault,
          _db.categories.createdAt,
          amountExp,
        ])
        ..where(
          _db.transactions.type.equals('expense') &
              _db.transactions.date.isBetweenValues(start, end),
        )
        ..groupBy([_db.categories.id])
        ..orderBy([
          OrderingTerm(expression: amountExp, mode: OrderingMode.desc),
        ])
        ..limit(limit);

      final results = await query.get();
      return results.map((row) {
        final category = domain.Category(
          id: row.read(_db.categories.id),
          name: row.read(_db.categories.name)!,
          icon: row.read(_db.categories.icon)!,
          type: TransactionTypeExtension.fromString(
            row.read(_db.categories.type)!,
          ),
          isDefault: row.read(_db.categories.isDefault)!,
          createdAt: row.read(_db.categories.createdAt),
        );

        return CategorySpending(
          category: category,
          totalAmount: row.read(amountExp) ?? 0.0,
        );
      }).toList();
    } catch (e) {
      throw Exception('Failed to get top expenses for period: $e');
    }
  }

  Future<int> getTransactionCountForPeriod(DateTime start, DateTime end) async {
    try {
      final countExp = _db.transactions.id.count();
      final query = _db.selectOnly(_db.transactions)
        ..addColumns([countExp])
        ..where(_db.transactions.date.isBetweenValues(start, end));
      final result = await query
          .map((row) => row.read(countExp))
          .getSingleOrNull();
      return result ?? 0;
    } catch (e) {
      throw Exception('Failed to calculate transaction count for period: $e');
    }
  }

  Future<List<CategorySpending>> getExpensesByCategory() async {
    try {
      final amountExp = _db.transactions.amount.sum();
      final query = _db.selectOnly(_db.transactions)
        ..join([
          innerJoin(
            _db.categories,
            _db.categories.id.equalsExp(_db.transactions.categoryId),
          ),
        ])
        ..addColumns([
          _db.categories.id,
          _db.categories.name,
          _db.categories.icon,
          _db.categories.type,
          _db.categories.isDefault,
          _db.categories.createdAt,
          amountExp,
        ])
        ..where(_db.transactions.type.equals('expense'))
        ..groupBy([_db.categories.id]);

      final results = await query.get();
      return results.map((row) {
        final category = domain.Category(
          id: row.read(_db.categories.id),
          name: row.read(_db.categories.name)!,
          icon: row.read(_db.categories.icon)!,
          type: TransactionTypeExtension.fromString(
            row.read(_db.categories.type)!,
          ),
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

  Future<List<CategorySpending>> getTopExpenses(
    DateTime month, {
    int limit = 3,
  }) async {
    try {
      final start = DateTime(month.year, month.month, 1);
      final end = DateTime(month.year, month.month + 1, 0, 23, 59, 59);

      final amountExp = _db.transactions.amount.sum();
      final query = _db.selectOnly(_db.transactions)
        ..join([
          innerJoin(
            _db.categories,
            _db.categories.id.equalsExp(_db.transactions.categoryId),
          ),
        ])
        ..addColumns([
          _db.categories.id,
          _db.categories.name,
          _db.categories.icon,
          _db.categories.type,
          _db.categories.isDefault,
          _db.categories.createdAt,
          amountExp,
        ])
        ..where(
          _db.transactions.type.equals('expense') &
              _db.transactions.date.isBetweenValues(start, end),
        )
        ..groupBy([_db.categories.id])
        ..orderBy([
          OrderingTerm(expression: amountExp, mode: OrderingMode.desc),
        ])
        ..limit(limit);

      final results = await query.get();
      return results.map((row) {
        final category = domain.Category(
          id: row.read(_db.categories.id),
          name: row.read(_db.categories.name)!,
          icon: row.read(_db.categories.icon)!,
          type: TransactionTypeExtension.fromString(
            row.read(_db.categories.type)!,
          ),
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
          percentages[spending.category.id!] =
              (spending.totalAmount / totalExpense) * 100;
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
