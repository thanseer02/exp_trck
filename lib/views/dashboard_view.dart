import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/transaction_viewmodel.dart';
import '../models/transaction_type.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../theme/app_colors.dart';
import '../viewmodels/category_viewmodel.dart';
import '../models/category.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TransactionViewModel>().loadDashboardData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.select<TransactionViewModel, bool>((vm) => vm.isLoading);

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<TransactionViewModel>().loadDashboardData(),
          color: AppColors.primary,
          child: CustomScrollView(
            slivers: [
              const SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _HeaderSection(),
                      SizedBox(height: 32),
                      _MainBalanceCard(),
                      SizedBox(height: 32),
                      _ThisMonthInsight(),
                      SizedBox(height: 32),
                      _WhereMoneyGoesSection(),
                      SizedBox(height: 32),
                      _RecentActivitySection(),
                      SizedBox(height: 80), // Padding for potential FAB/Navigation
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GOOD MORNING',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Your financial overview',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class _MainBalanceCard extends StatelessWidget {
  const _MainBalanceCard();

  @override
  Widget build(BuildContext context) {
    return Consumer2<TransactionViewModel, SettingsViewModel>(
      builder: (context, vm, settings, child) {
        final totalIncome = vm.monthlySummary?.totalIncome ?? 0.0;
        final totalExpense = vm.monthlySummary?.totalExpense ?? 0.0;
        
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AVAILABLE BALANCE',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.8),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                settings.formatAmount(vm.balance),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -1.0,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _SummaryMini(
                    label: 'Income',
                    amount: settings.formatAmount(totalIncome),
                    icon: Icons.arrow_downward_rounded,
                    color: AppColors.incomeBg,
                  ),
                  _SummaryMini(
                    label: 'Spent',
                    amount: settings.formatAmount(totalExpense),
                    icon: Icons.arrow_upward_rounded,
                    color: AppColors.expenseBg,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SummaryMini extends StatelessWidget {
  final String label;
  final String amount;
  final IconData icon;
  final Color color;

  const _SummaryMini({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 16),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.8),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              amount,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ThisMonthInsight extends StatelessWidget {
  const _ThisMonthInsight();

  @override
  Widget build(BuildContext context) {
    return Selector2<TransactionViewModel, SettingsViewModel, (double, double)>(
      selector: (_, vm, settings) => (
        vm.monthlySummary?.totalExpense ?? 0.0,
        0.0 // Placeholder for last month's comparison logic
      ),
      builder: (context, data, child) {
        final currentSpent = data.$1;
        final settings = context.read<SettingsViewModel>();
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'THIS MONTH',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: AppColors.textTertiary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${settings.formatAmount(currentSpent)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 4.0),
                  child: Text(
                    'spent',
                    style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _WhereMoneyGoesSection extends StatelessWidget {
  const _WhereMoneyGoesSection();

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
      default: return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'WHERE YOUR MONEY GOES',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: AppColors.textTertiary,
          ),
        ),
        const SizedBox(height: 16),
        Consumer<TransactionViewModel>(
          builder: (context, vm, child) {
            if (vm.topSpending.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text('No expenses recorded this month.', style: TextStyle(color: AppColors.textTertiary)),
              );
            }
            
            final totalExpense = vm.monthlySummary?.totalExpense ?? 1.0;
            
            return Column(
              children: vm.topSpending.take(3).map((spending) {
                final percent = totalExpense > 0 ? spending.totalAmount / totalExpense : 0.0;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(_getIconData(spending.category.icon), color: AppColors.textSecondary, size: 20),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              spending.category.name,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                          ),
                          Text(
                            context.read<SettingsViewModel>().formatAmount(spending.totalAmount),
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percent,
                          backgroundColor: AppColors.border,
                          valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryLight),
                          minHeight: 6,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}

class _RecentActivitySection extends StatelessWidget {
  const _RecentActivitySection();

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
      default: return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'RECENT ACTIVITY',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Consumer2<TransactionViewModel, CategoryViewModel>(
          builder: (context, vm, categoryVm, child) {
            if (vm.recentTransactions.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text('No recent transactions.', style: TextStyle(color: AppColors.textTertiary)),
              );
            }
            return Column(
              children: vm.recentTransactions.take(5).map((tx) {
                final isIncome = tx.type == TransactionType.income;
                final categories = isIncome ? categoryVm.incomeCategories : categoryVm.expenseCategories;
                final category = categories.firstWhere(
                  (c) => c.id == tx.categoryId,
                  orElse: () => Category(id: -1, name: 'Unknown', icon: 'category', type: tx.type),
                );
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16.0),
                  child: Row(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: isIncome ? AppColors.incomeBg : AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: isIncome ? null : Border.all(color: AppColors.border),
                        ),
                        child: Icon(
                          _getIconData(category.icon), 
                          color: isIncome ? AppColors.income : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              category.name,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
                            ),
                            if (tx.note != null && tx.note!.isNotEmpty)
                              Padding(
                                padding: const EdgeInsets.only(top: 2.0),
                                child: Text(
                                  tx.note!,
                                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                          ],
                        ),
                      ),
                      Text(
                        '${isIncome ? '+' : '-'}${context.read<SettingsViewModel>().formatAmount(tx.amount)}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: isIncome ? AppColors.income : AppColors.textPrimary,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }
}
