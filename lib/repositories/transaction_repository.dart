import '../database/app_database.dart';
import '../models/transaction.dart';

class TransactionRepository {
  final AppDatabase _appDatabase = AppDatabase.instance;

  Future<int> insertTransaction(AppTransaction transaction) async {
    final db = await _appDatabase.database;
    return await db.insert('transactions', transaction.toMap());
  }

  Future<List<AppTransaction>> getTransactions() async {
    final db = await _appDatabase.database;
    final maps = await db.query('transactions');
    return maps.map((map) => AppTransaction.fromMap(map)).toList();
  }
}
