import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import '../viewmodels/transaction_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';

class BudgetsView extends StatefulWidget {
  const BudgetsView({super.key});

  @override
  State<BudgetsView> createState() => _BudgetsViewState();
}

class _BudgetsViewState extends State<BudgetsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TransactionViewModel>().loadDashboardData();
        context.read<TransactionViewModel>().loadAnalyticsData();
      }
    });
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'restaurant': return Icons.restaurant;
      case 'directions_car': return Icons.directions_car;
      case 'shopping_cart': return Icons.shopping_cart;
      case 'receipt': return Icons.receipt;
      case 'home': return Icons.home;
      case 'movie': return Icons.movie;
      case 'local_hospital': return Icons.local_hospital;
      case 'school': return Icons.school;
      case 'flight': return Icons.flight;
      case 'local_grocery_store': return Icons.local_grocery_store;
      case 'subscriptions': return Icons.subscriptions;
      case 'attach_money': return Icons.attach_money;
      case 'work': return Icons.work;
      case 'business': return Icons.business;
      case 'card_giftcard': return Icons.card_giftcard;
      case 'category': 
      default: return Icons.category_outlined;
    }
  }

  Color _getCategoryColor(int index) {
    const colors = [
      Colors.blue,
      Color(0xFFF87171),
      Colors.purpleAccent,
      Colors.orange,
      Colors.teal,
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimaryDark, size: 22),
          onPressed: () => Navigator.pop(context),
        ),

      ),
      body: Consumer2<TransactionViewModel, SettingsViewModel>(
        builder: (context, vm, settings, child) {
          final isLoading = vm.isLoading;
          if (isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final totalExpense = vm.monthlySummary?.totalExpense ?? 0.0;
          final totalIncome = vm.monthlySummary?.totalIncome ?? 0.0;
          final totalBalance = vm.balance;

          // Assuming a global budget limit of $3,000 for demonstration, unless income exists
          final globalBudget = totalIncome > 0 ? totalIncome * 0.8 : 3000.0;
          final spentRatio = (totalExpense / globalBudget).clamp(0.0, 1.0);
          final remaining = (globalBudget - totalExpense).clamp(0.0, double.infinity);
          
          final isOverBudget = totalExpense > globalBudget;

          final categoryBudgets = vm.topSpending;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  const Text(
                    'Budgets & Targets',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimaryDark),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Keep your spending in check',
                    style: AppStyles.bodySecondary,
                  ),
                  const SizedBox(height: 32),
                  
                  // Overall Discretionary Budget
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'MONTHLY DISCRETIONARY',
                              style: AppStyles.sectionHeader,
                            ),
                            const Icon(Icons.more_horiz, color: AppColors.textSecondaryDark, size: 20),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: [
                            Text(
                              settings.formatAmount(totalExpense),
                              style: AppStyles.heading1,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'spent of ${settings.formatAmount(globalBudget)}',
                              style: const TextStyle(color: AppColors.textTertiaryDark, fontSize: 12),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        // Progress Bar
                        Container(
                          height: 8,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHighDark,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: spentRatio,
                            child: Container(
                              decoration: BoxDecoration(
                                color: isOverBudget ? const Color(0xFFF87171) : AppColors.income,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              isOverBudget ? 'Over budget' : 'On track',
                              style: TextStyle(
                                color: isOverBudget ? const Color(0xFFF87171) : AppColors.income,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              '${settings.formatAmount(remaining)} left',
                              style: AppStyles.caption,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // By Category Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Category Budgets', style: AppStyles.sectionTitle),
                      const Text('Edit', style: AppStyles.bodySecondary),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  if (categoryBudgets.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Text('No spending data to generate category budgets.', style: AppStyles.bodySecondary),
                      ),
                    )
                  else
                    // Category Budgets List dynamically from Top Expenses
                    ...List.generate(categoryBudgets.length, (index) {
                      final item = categoryBudgets[index];
                      // Assigning a realistic mock budget based on the spending to demonstrate UI
                      final categoryLimit = item.totalAmount * 1.25 + 50.0;
                      final percent = (item.totalAmount / categoryLimit).clamp(0.0, 1.0);
                      final isCatOverBudget = item.totalAmount > categoryLimit;
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: _BudgetCategoryRow(
                          icon: _getIconData(item.category.icon),
                          name: item.category.name,
                          spent: settings.formatAmount(item.totalAmount),
                          total: settings.formatAmount(categoryLimit),
                          percent: percent,
                          color: _getCategoryColor(index),
                          isOverBudget: isCatOverBudget,
                        ),
                      );
                    }),
                  
                  const SizedBox(height: 24),
                  
                  // Savings Goals Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Savings Goals', style: AppStyles.sectionTitle),
                      const Text('Add', style: AppStyles.bodySecondary),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Savings Goal Card mapped to global balance
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.borderDark),
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: const BoxDecoration(
                                color: AppColors.surfaceContainerLowDark,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.shield_outlined, color: AppColors.income, size: 20),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Emergency Reserve', style: TextStyle(color: AppColors.textPrimaryDark, fontSize: 14, fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 4),
                                  Text('${settings.formatAmount(totalBalance)} of ${settings.formatAmount(10000.0)}', style: AppStyles.bodySecondary),
                                ],
                              ),
                            ),
                            Text('${((totalBalance / 10000.0).clamp(0.0, 1.0) * 100).toInt()}%', style: const TextStyle(color: AppColors.textPrimaryDark, fontSize: 16, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Container(
                          height: 6,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHighDark,
                            borderRadius: BorderRadius.circular(3),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: (totalBalance / 10000.0).clamp(0.0, 1.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.income,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton(
                            onPressed: () {},
                            style: OutlinedButton.styleFrom(
                              side: const BorderSide(color: AppColors.borderDark),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            child: const Text('Add Funds', style: AppStyles.bodyPrimary),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 64),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _BudgetCategoryRow extends StatelessWidget {
  final IconData icon;
  final String name;
  final String spent;
  final String total;
  final double percent;
  final Color color;
  final bool isOverBudget;

  const _BudgetCategoryRow({
    required this.icon,
    required this.name,
    required this.spent,
    required this.total,
    required this.percent,
    required this.color,
    this.isOverBudget = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: const BoxDecoration(
            color: AppColors.surfaceDark,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 18),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(name, style: AppStyles.bodyPrimary),
                  Text(
                    '$spent / $total',
                    style: TextStyle(
                      color: isOverBudget ? const Color(0xFFF87171) : AppColors.textPrimaryDark,
                      fontSize: 12,
                      fontWeight: isOverBudget ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                height: 4,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHighDark,
                  borderRadius: BorderRadius.circular(2),
                ),
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: percent,
                  child: Container(
                    decoration: BoxDecoration(
                      color: isOverBudget ? const Color(0xFFF87171) : color,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
