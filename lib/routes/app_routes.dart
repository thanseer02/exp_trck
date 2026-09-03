import 'package:flutter/material.dart';

import '../views/dashboard_view.dart';
import '../views/transactions_view.dart';
import '../views/analytics_view.dart';
import '../views/budgets_view.dart';
import '../views/settings_view.dart';
import '../views/add_edit_transaction_view.dart';
import '../views/transfer_view.dart';
import '../views/manage_categories_view.dart';
import '../views/add_edit_category_view.dart';
import '../views/category_details_view.dart';

import '../models/transaction.dart';
import '../models/category.dart';
import '../models/transaction_type.dart';

class AppRoutes {
  static const String dashboard = '/';
  static const String transactions = '/transactions';
  static const String analytics = '/analytics';
  static const String budgets = '/budgets';
  static const String settings = '/settings';
  static const String addEditTransaction = '/add-edit-transaction';
  static const String transfer = '/transfer';
  static const String manageCategories = '/manage-categories';
  static const String addEditCategory = '/add-edit-category';
  static const String categoryDetails = '/category-details';

  static Route<dynamic> generateRoute(RouteSettings routeSettings) {
    switch (routeSettings.name) {
      case dashboard:
        return MaterialPageRoute(builder: (_) => const DashboardView());
      case transactions:
        return MaterialPageRoute(builder: (_) => const TransactionsView());
      case analytics:
        return MaterialPageRoute(builder: (_) => const AnalyticsView());
      case budgets:
        return MaterialPageRoute(builder: (_) => const BudgetsView());
      case settings:
        return MaterialPageRoute(builder: (_) => const SettingsView());
      case transfer:
        return MaterialPageRoute(builder: (_) => const TransferView());
      case manageCategories:
        return MaterialPageRoute(builder: (_) => const ManageCategoriesView());
      case addEditTransaction:
        final args = routeSettings.arguments as Map<String, dynamic>?;
        final transaction = args?['transaction'] as Transaction?;
        final initialType = args?['initialType'] as TransactionType?;
        return MaterialPageRoute(
          builder: (_) => AddEditTransactionView(
            transaction: transaction,
            initialType: initialType,
          ),
        );
      case addEditCategory:
        final args = routeSettings.arguments as Map<String, dynamic>?;
        final category = args?['category'] as Category?;
        return MaterialPageRoute(
          builder: (_) => AddEditCategoryView(category: category),
        );
      case categoryDetails:
        final args = routeSettings.arguments as Map<String, dynamic>;
        final category = args['category'] as Category;
        final month = args['month'] as DateTime;
        return MaterialPageRoute(
          builder: (_) => CategoryDetailsView(category: category, month: month),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${routeSettings.name}'),
            ),
          ),
        );
    }
  }
}
