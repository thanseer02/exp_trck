import 'dart:io';
import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [Categories, Transactions])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (Migrator m) async {
        await m.createAll();
        
        // Pre-populate default categories
        final defaultCategories = [
          // Expense Categories
          CategoriesCompanion.insert(name: 'Food', icon: 'restaurant', type: 'expense', isDefault: const Value(true)),
          CategoriesCompanion.insert(name: 'Transport', icon: 'directions_car', type: 'expense', isDefault: const Value(true)),
          CategoriesCompanion.insert(name: 'Shopping', icon: 'shopping_cart', type: 'expense', isDefault: const Value(true)),
          CategoriesCompanion.insert(name: 'Bills', icon: 'receipt', type: 'expense', isDefault: const Value(true)),
          CategoriesCompanion.insert(name: 'Rent', icon: 'home', type: 'expense', isDefault: const Value(true)),
          CategoriesCompanion.insert(name: 'Entertainment', icon: 'movie', type: 'expense', isDefault: const Value(true)),
          CategoriesCompanion.insert(name: 'Health', icon: 'local_hospital', type: 'expense', isDefault: const Value(true)),
          CategoriesCompanion.insert(name: 'Education', icon: 'school', type: 'expense', isDefault: const Value(true)),
          CategoriesCompanion.insert(name: 'Travel', icon: 'flight', type: 'expense', isDefault: const Value(true)),
          CategoriesCompanion.insert(name: 'Groceries', icon: 'local_grocery_store', type: 'expense', isDefault: const Value(true)),
          CategoriesCompanion.insert(name: 'Subscriptions', icon: 'subscriptions', type: 'expense', isDefault: const Value(true)),
          CategoriesCompanion.insert(name: 'Other', icon: 'category', type: 'expense', isDefault: const Value(true)),
          
          // Income Categories
          CategoriesCompanion.insert(name: 'Salary', icon: 'attach_money', type: 'income', isDefault: const Value(true)),
          CategoriesCompanion.insert(name: 'Freelance', icon: 'work', type: 'income', isDefault: const Value(true)),
          CategoriesCompanion.insert(name: 'Business', icon: 'business', type: 'income', isDefault: const Value(true)),
          CategoriesCompanion.insert(name: 'Gift', icon: 'card_giftcard', type: 'income', isDefault: const Value(true)),
          CategoriesCompanion.insert(name: 'Other', icon: 'category', type: 'income', isDefault: const Value(true)),
        ];

        for (final category in defaultCategories) {
          await into(categories).insert(category);
        }
      },
    );
  }

  Future<void> wipeData() async {
    await delete(transactions).go();
    await delete(categories).go();
    
    final defaultCategories = [
      // Expense Categories
      CategoriesCompanion.insert(name: 'Food', icon: 'restaurant', type: 'expense', isDefault: const Value(true)),
      CategoriesCompanion.insert(name: 'Transport', icon: 'directions_car', type: 'expense', isDefault: const Value(true)),
      CategoriesCompanion.insert(name: 'Shopping', icon: 'shopping_cart', type: 'expense', isDefault: const Value(true)),
      CategoriesCompanion.insert(name: 'Bills', icon: 'receipt', type: 'expense', isDefault: const Value(true)),
      CategoriesCompanion.insert(name: 'Rent', icon: 'home', type: 'expense', isDefault: const Value(true)),
      CategoriesCompanion.insert(name: 'Entertainment', icon: 'movie', type: 'expense', isDefault: const Value(true)),
      CategoriesCompanion.insert(name: 'Health', icon: 'local_hospital', type: 'expense', isDefault: const Value(true)),
      CategoriesCompanion.insert(name: 'Education', icon: 'school', type: 'expense', isDefault: const Value(true)),
      CategoriesCompanion.insert(name: 'Travel', icon: 'flight', type: 'expense', isDefault: const Value(true)),
      CategoriesCompanion.insert(name: 'Groceries', icon: 'local_grocery_store', type: 'expense', isDefault: const Value(true)),
      CategoriesCompanion.insert(name: 'Subscriptions', icon: 'subscriptions', type: 'expense', isDefault: const Value(true)),
      CategoriesCompanion.insert(name: 'Other', icon: 'category', type: 'expense', isDefault: const Value(true)),
      
      // Income Categories
      CategoriesCompanion.insert(name: 'Salary', icon: 'attach_money', type: 'income', isDefault: const Value(true)),
      CategoriesCompanion.insert(name: 'Freelance', icon: 'work', type: 'income', isDefault: const Value(true)),
      CategoriesCompanion.insert(name: 'Business', icon: 'business', type: 'income', isDefault: const Value(true)),
      CategoriesCompanion.insert(name: 'Gift', icon: 'card_giftcard', type: 'income', isDefault: const Value(true)),
      CategoriesCompanion.insert(name: 'Other', icon: 'category', type: 'income', isDefault: const Value(true)),
    ];

    for (final category in defaultCategories) {
      await into(categories).insert(category);
    }
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
