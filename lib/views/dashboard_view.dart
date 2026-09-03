import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/transaction_viewmodel.dart';
import '../models/transaction_type.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../theme/app_colors.dart';
import '../viewmodels/category_viewmodel.dart';
import '../models/category.dart';
import 'analytics_view.dart';
import 'transactions_view.dart';
import 'budgets_view.dart';
import 'add_edit_transaction_view.dart';
import 'transfer_view.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  bool _isBalanceHidden = false;

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
        backgroundColor: AppColors.backgroundDark,
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<TransactionViewModel>().loadDashboardData(),
          color: AppColors.primary,
          backgroundColor: AppColors.surfaceDark,
          child: CustomScrollView(
            slivers: [
              const _FlowLedgerDarkHeader(),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _GreetingSection(),
                      const SizedBox(height: 32),
                      _MinimalBalanceSection(
                        isHidden: _isBalanceHidden,
                        onToggle: () => setState(() => _isBalanceHidden = !_isBalanceHidden),
                      ),
                      const SizedBox(height: 40),
                      const _QuickActionHub(),
                      const SizedBox(height: 48),
                      const _WeeklyCadenceSection(),
                      const SizedBox(height: 40),
                      const _RecentActivitySection(),
                      const SizedBox(height: 48),
                      const _ExploreSections(),
                      const SizedBox(height: 32),
                      const _FinancialTipBanner(),
                      const SizedBox(height: 40),
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

class _FlowLedgerDarkHeader extends StatelessWidget {
  const _FlowLedgerDarkHeader();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.backgroundDark.withValues(alpha: 0.95),
      pinned: true,
      elevation: 0,
      title: Row(
        children: [
          const Text(
            'FlowLedger',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimaryDark,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(
              color: AppColors.income,
              shape: BoxShape.circle,
            ),
          )
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.notifications_none, color: AppColors.textSecondaryDark, size: 22),
          onPressed: () {},
        ),
        const SizedBox(width: 8),
      ],
    );
  }
}

class _GreetingSection extends StatelessWidget {
  const _GreetingSection();

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('MMMM d, yyyy').format(DateTime.now());
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          today.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.5,
            color: AppColors.textTertiaryDark,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Good morning, Alex',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimaryDark,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class _MinimalBalanceSection extends StatelessWidget {
  final bool isHidden;
  final VoidCallback onToggle;

  const _MinimalBalanceSection({required this.isHidden, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Consumer2<TransactionViewModel, SettingsViewModel>(
      builder: (context, vm, settings, child) {
        final balanceAmount = settings.formatAmount(vm.balance);
        final totalIncome = vm.monthlySummary?.totalIncome ?? 0.0;
        final totalExpense = vm.monthlySummary?.totalExpense ?? 0.0;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text(
                      'Total Net Balance',
                      style: TextStyle(
                        color: AppColors.textSecondaryDark,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: onToggle,
                      child: Icon(
                        isHidden ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                        color: AppColors.textSecondaryDark,
                        size: 16,
                      ),
                    ),
                  ],
                ),
                const Row(
                  children: [
                    Text(
                      '+12.4%',
                      style: TextStyle(
                        color: AppColors.income,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      ' this month',
                      style: TextStyle(
                        color: AppColors.textTertiaryDark,
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              isHidden ? '••••••••' : balanceAmount,
              style: const TextStyle(
                color: AppColors.textPrimaryDark,
                fontSize: 42,
                fontWeight: FontWeight.w600,
                letterSpacing: -2.0,
              ),
            ),
            const SizedBox(height: 24),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Row(
                children: [
                  Text(
                    'Income ',
                    style: TextStyle(color: AppColors.textTertiaryDark, fontSize: 12),
                  ),
                  Text(
                    settings.formatAmount(totalIncome),
                    style: const TextStyle(color: AppColors.textPrimaryDark, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 20),
                  Text(
                    'Expenses ',
                    style: TextStyle(color: AppColors.textTertiaryDark, fontSize: 12),
                  ),
                  Text(
                    settings.formatAmount(totalExpense),
                    style: const TextStyle(color: AppColors.textPrimaryDark, fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(width: 20),
                  const Text(
                    'Net ',
                    style: TextStyle(color: AppColors.textTertiaryDark, fontSize: 12),
                  ),
                  const Icon(Icons.arrow_forward_rounded, color: AppColors.income, size: 14),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _QuickActionHub extends StatelessWidget {
  const _QuickActionHub();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _ActionBtn(
          icon: Icons.add, 
          label: 'Income', 
          iconColor: AppColors.income,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditTransactionView(initialType: TransactionType.income)));
          },
        ),
        _ActionBtn(
          icon: Icons.remove, 
          label: 'Expense', 
          iconColor: const Color(0xFFEF4444),
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditTransactionView(initialType: TransactionType.expense)));
          },
        ),
        _ActionBtn(
          icon: Icons.swap_horiz, 
          label: 'Transfer', 
          iconColor: AppColors.textPrimaryDark,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const TransferView()));
          },
        ),
        _ActionBtn(
          icon: Icons.filter_center_focus, 
          label: 'Scan', 
          iconColor: AppColors.textPrimaryDark,
          onTap: () {},
        ),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color iconColor;
  final VoidCallback? onTap;

  const _ActionBtn({required this.icon, required this.label, required this.iconColor, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.backgroundDark, // Uses the deep background
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.surfaceContainerLowDark, width: 1.5),
            ),
            child: Center(
              child: Icon(icon, color: iconColor, size: 24),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(color: AppColors.textPrimaryDark, fontSize: 11, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}

class _WeeklyCadenceSection extends StatelessWidget {
  const _WeeklyCadenceSection();

  @override
  Widget build(BuildContext context) {
    return Consumer<TransactionViewModel>(
      builder: (context, vm, child) {
        // Calculate last 7 days of inflow/outflow
        final now = DateTime.now();
        final Map<int, double> dailyInflow = {};
        final Map<int, double> dailyOutflow = {};
        
        // Initialize last 7 days
        for (int i = 6; i >= 0; i--) {
          final date = now.subtract(Duration(days: i));
          dailyInflow[date.weekday] = 0.0;
          dailyOutflow[date.weekday] = 0.0;
        }

        // Aggregate data
        for (final tx in vm.transactions) {
          final date = tx.date.toLocal();
          final diff = now.difference(date).inDays;
          
          if (diff >= 0 && diff < 7) {
            if (tx.type == TransactionType.income) {
              dailyInflow[date.weekday] = (dailyInflow[date.weekday] ?? 0) + tx.amount;
            } else {
              dailyOutflow[date.weekday] = (dailyOutflow[date.weekday] ?? 0) + tx.amount;
            }
          }
        }

        // Find max value to scale the bars properly (preventing overflow)
        double maxVal = 1.0;
        for (int i = 6; i >= 0; i--) {
          final date = now.subtract(Duration(days: i));
          if ((dailyInflow[date.weekday] ?? 0) > maxVal) maxVal = dailyInflow[date.weekday]!;
          if ((dailyOutflow[date.weekday] ?? 0) > maxVal) maxVal = dailyOutflow[date.weekday]!;
        }

        const double maxBarHeight = 60.0; // Fixed maximum height for the bars to fit in 100px SizedBox

        final List<Widget> bars = [];
        final weekdays = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
        
        for (int i = 6; i >= 0; i--) {
          final date = now.subtract(Duration(days: i));
          final inVal = dailyInflow[date.weekday] ?? 0;
          final outVal = dailyOutflow[date.weekday] ?? 0;
          
          final inH = (inVal / maxVal) * maxBarHeight;
          final outH = (outVal / maxVal) * maxBarHeight;
          
          final isToday = i == 0;
          
          bars.add(_CadenceBar(day: weekdays[date.weekday - 1], inH: inH, outH: outH, isBold: isToday));
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Weekly Cadence', style: TextStyle(color: AppColors.textPrimaryDark, fontSize: 13, fontWeight: FontWeight.w600)),
                Row(
                  children: [
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.income, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    const Text('Inflow', style: TextStyle(color: AppColors.textTertiaryDark, fontSize: 11)),
                    const SizedBox(width: 12),
                    Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.surfaceContainerHighDark, shape: BoxShape.circle)),
                    const SizedBox(width: 6),
                    const Text('Outflow', style: TextStyle(color: AppColors.textTertiaryDark, fontSize: 11)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Real Data Dual Bars
            SizedBox(
              height: maxBarHeight + 30, // Safely bounds the maximum height
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: bars,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _CadenceBar extends StatelessWidget {
  final String day;
  final double inH;
  final double outH;
  final bool isBold;

  const _CadenceBar({required this.day, required this.inH, required this.outH, this.isBold = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(width: 6, height: inH > 0 ? inH : 2, decoration: BoxDecoration(color: AppColors.income, borderRadius: BorderRadius.circular(3))),
            const SizedBox(width: 2),
            Container(width: 6, height: outH > 0 ? outH : 2, decoration: BoxDecoration(color: AppColors.surfaceContainerHighDark, borderRadius: BorderRadius.circular(3))),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          day,
          style: TextStyle(
            color: isBold ? AppColors.textPrimaryDark : AppColors.textTertiaryDark,
            fontSize: 11,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
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
      default: return Icons.category_outlined;
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
            const Text(
              'Recent Activity',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimaryDark),
            ),
            const Text(
              'View all',
              style: TextStyle(fontSize: 11, color: AppColors.textSecondaryDark),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Consumer2<TransactionViewModel, CategoryViewModel>(
          builder: (context, vm, categoryVm, child) {
            if (vm.recentTransactions.isEmpty) {
              return Center(
                child: Text('No recent transactions.', style: TextStyle(color: AppColors.textSecondaryDark)),
              );
            }
            
            return Column(
              children: vm.recentTransactions.take(4).map((tx) {
                final isIncome = tx.type == TransactionType.income;
                final categories = isIncome ? categoryVm.incomeCategories : categoryVm.expenseCategories;
                final category = categories.firstWhere(
                  (c) => c.id == tx.categoryId,
                  orElse: () => Category(id: -1, name: 'Unknown', icon: 'category', type: tx.type),
                );
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: const BoxDecoration(
                          color: AppColors.surfaceContainerLowDark,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          _getIconData(category.icon), 
                          color: AppColors.textSecondaryDark,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              tx.note != null && tx.note!.isNotEmpty ? tx.note! : category.name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14, color: AppColors.textPrimaryDark),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${category.name} • ${DateFormat('MMM d').format(tx.date.toLocal())}',
                              style: const TextStyle(color: AppColors.textTertiaryDark, fontSize: 11),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${isIncome ? '+' : '-'}${context.read<SettingsViewModel>().formatAmount(tx.amount)}',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: isIncome ? AppColors.income : const Color(0xFFF87171), // Soft red/pink for expenses in this dark design, or keep it white. The mockup shows soft red.
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            isIncome ? 'CLEARED' : 'CARD',
                            style: TextStyle(fontSize: 8, color: AppColors.textTertiaryDark, letterSpacing: 1.0, fontWeight: FontWeight.bold),
                          ),
                        ],
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

class _ExploreSections extends StatelessWidget {
  const _ExploreSections();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Explore & Sections',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textPrimaryDark),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _SectionCard(
                icon: Icons.pie_chart,
                title: 'Analytics',
                subtitle: 'Cashflow &\nTrends',
                iconColor: AppColors.income,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const AnalyticsView()));
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SectionCard(
                icon: Icons.track_changes,
                title: 'Budgets',
                subtitle: 'Targets &\nLimits',
                iconColor: AppColors.textPrimaryDark,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const BudgetsView()));
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _SectionCard(
                icon: Icons.receipt_long,
                title: 'Ledger',
                subtitle: 'All\nTransactions',
                iconColor: AppColors.textPrimaryDark,
                onTap: () {
                  Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionsView()));
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final VoidCallback onTap;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderDark, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 20),
            const SizedBox(height: 24),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textPrimaryDark,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: AppColors.textTertiaryDark,
                fontSize: 10,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class _FinancialTipBanner extends StatelessWidget {
  const _FinancialTipBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderDark, width: 1),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: AppColors.textTertiaryDark, size: 16),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Tracking 18% below discretionary target. On pace to reach your \$20K reserve goal 3 weeks ahead of schedule.',
              style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 11, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
