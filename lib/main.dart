import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'viewmodels/transaction_viewmodel.dart';
import 'viewmodels/category_viewmodel.dart';
import 'viewmodels/settings_viewmodel.dart';
import 'viewmodels/assistant_viewmodel.dart';
import 'services/assistant_parser.dart';
import 'services/assistant_response_generator.dart';
import 'routes/app_routes.dart';
import 'database/app_database.dart';
import 'repositories/transaction_repository.dart';
import 'repositories/category_repository.dart';
import 'theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final appDb = AppDatabase();
  final prefs = await SharedPreferences.getInstance();

  runApp(
    MultiProvider(
      providers: [
        Provider<AppDatabase>.value(value: appDb),
        Provider<CategoryRepository>(
          create: (context) => CategoryRepository(context.read<AppDatabase>()),
        ),
        Provider<TransactionRepository>(
          create: (context) =>
              TransactionRepository(context.read<AppDatabase>()),
        ),
        ChangeNotifierProvider(create: (context) => SettingsViewModel(prefs)),
        ChangeNotifierProvider(
          create: (context) =>
              TransactionViewModel(context.read<TransactionRepository>()),
        ),
        ChangeNotifierProvider(
          create: (context) => CategoryViewModel(
            context.read<CategoryRepository>(),
            context.read<TransactionRepository>(),
          )..loadCategories(),
        ),
        Provider<AssistantParser>(create: (_) => AssistantParser()),
        Provider<AssistantResponseGenerator>(
          create: (_) => AssistantResponseGenerator(),
        ),
        ChangeNotifierProvider(
          create: (context) => AssistantViewModel(
            context.read<TransactionRepository>(),
            context.read<AssistantParser>(),
            context.read<AssistantResponseGenerator>(),
          ),
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
    return Consumer<SettingsViewModel>(
      builder: (context, settingsVM, child) {
        return MaterialApp(
          title: 'Vault',
          themeMode: ThemeMode.dark,
          theme: AppTheme.darkTheme,
          darkTheme: AppTheme.darkTheme,
          initialRoute: AppRoutes.dashboard,
          onGenerateRoute: AppRoutes.generateRoute,
        );
      },
    );
  }
}
