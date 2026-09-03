import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'viewmodels/transaction_viewmodel.dart';
import 'viewmodels/category_viewmodel.dart';
import 'views/main_navigation_view.dart';
import 'database/app_database.dart';
import 'repositories/transaction_repository.dart';
import 'repositories/category_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final appDb = AppDatabase();

  runApp(
    MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: appDb),
        Provider<CategoryRepository>(
          create: (context) => CategoryRepository(context.read<AppDatabase>()),
        ),
        Provider<TransactionRepository>(
          create: (context) => TransactionRepository(context.read<AppDatabase>()),
        ),
        ChangeNotifierProvider(
          create: (context) => TransactionViewModel(context.read<TransactionRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) => CategoryViewModel(
            context.read<CategoryRepository>(),
            context.read<TransactionRepository>(),
          )..loadCategories(),
        ),
      ],
      child: const ExpenseTrackerApp(),
    ),
  );
}

class ExpenseTrackerApp extends StatelessWidget {
  const ExpenseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MainNavigationView(),
    );
  }
}
