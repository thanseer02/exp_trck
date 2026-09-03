import 'package:drift/drift.dart';
import '../database/app_database.dart' as db;
import '../models/category.dart';
import '../models/transaction_type.dart';

class CategoryRepository {
  final db.AppDatabase _db;

  CategoryRepository(this._db);

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

  Future<List<Category>> getCategories() async {
    try {
      final results = await _db.select(_db.categories).get();
      return results.map(_mapCategory).toList();
    } catch (e) {
      throw Exception('Failed to load categories: $e');
    }
  }

  Future<int> addCategory(Category category) async {
    try {
      return await _db.into(_db.categories).insert(
        db.CategoriesCompanion.insert(
          name: category.name,
          icon: category.icon,
          type: category.type.name,
          isDefault: Value(category.isDefault),
          createdAt: Value(category.createdAt ?? DateTime.now()),
        )
      );
    } catch (e) {
      throw Exception('Failed to add category: $e');
    }
  }

  Future<bool> updateCategory(Category category) async {
    if (category.id == null) return false;
    try {
      return await _db.update(_db.categories).replace(
        db.CategoriesCompanion(
          id: Value(category.id!),
          name: Value(category.name),
          icon: Value(category.icon),
          type: Value(category.type.name),
          isDefault: Value(category.isDefault),
        )
      );
    } catch (e) {
      throw Exception('Failed to update category: $e');
    }
  }

  Future<int> deleteCategory(int id) async {
    try {
      return await (_db.delete(_db.categories)..where((c) => c.id.equals(id))).go();
    } catch (e) {
      throw Exception('Failed to delete category: $e');
    }
  }
}
