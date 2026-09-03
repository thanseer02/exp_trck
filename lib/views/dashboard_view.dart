import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
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
        body: Center(child: CircularProgressIndicator(color: AppColors.income)),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<TransactionViewModel>().loadDashboardData(),
          color: AppColors.income,
          backgroundColor: AppColors.surfaceContainerHighDark,
          child: CustomScrollView(
            slivers: [
              const _FlowLedgerHeader(),
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 24.0),
                sliver: SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _GreetingSection(),
                      const SizedBox(height: 32),
                      _HeroBalanceCard(
                        isHidden: _isBalanceHidden,
                        onToggle: () => setState(() => _isBalanceHidden = !_isBalanceHidden),
                      ),
                      const SizedBox(height: 24),
                      const _DualMicroCards(),
                      const SizedBox(height: 32),
                      const _QuickActionHub(),
                      const SizedBox(height: 32),
                      const _WeeklyCadenceMock(),
                      const SizedBox(height: 32),
                      const _RecentActivitySection(),
                      const SizedBox(height: 32),
                      const _FinancialTipBanner(),
                      const SizedBox(height: 80), // Bottom nav padding
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

class _FlowLedgerHeader extends StatelessWidget {
  const _FlowLedgerHeader();

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: AppColors.backgroundDark.withValues(alpha: 0.85),
      pinned: true,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppColors.income,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.account_balance_wallet, color: AppColors.backgroundDark, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'VAULT',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  color: AppColors.textSecondaryDark,
                ),
              ),
              const Text(
                'Overview',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimaryDark,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_none, color: AppColors.textSecondaryDark),
          onPressed: () {},
        ),
        Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.surfaceContainerHighDark,
            child: Icon(Icons.person, size: 20, color: AppColors.textPrimaryDark),
          ),
        ),
      ],
    );
  }
}

class _GreetingSection extends StatelessWidget {
  const _GreetingSection();

  @override
  Widget build(BuildContext context) {
    final today = DateFormat('MMMM d, yyyy').format(DateTime.now());
    
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              today.toUpperCase(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: AppColors.textSecondaryDark,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Good morning, User',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimaryDark,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.incomeBg,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: AppColors.income,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'Live Sync',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.income,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroBalanceCard extends StatelessWidget {
  final bool isHidden;
  final VoidCallback onToggle;

  const _HeroBalanceCard({required this.isHidden, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return Consumer2<TransactionViewModel, SettingsViewModel>(
      builder: (context, vm, settings, child) {
        final balanceAmount = settings.formatAmount(vm.balance);
        final netFlow = (vm.monthlySummary?.totalIncome ?? 0.0) - (vm.monthlySummary?.totalExpense ?? 0.0);
        final netFlowStr = '${netFlow >= 0 ? '+' : ''}${settings.formatAmount(netFlow)}';
        
        return Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Decorative blurs
              Positioned(
                right: -20,
                bottom: -20,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: AppColors.incomeBg.withValues(alpha: 0.4),
                    shape: BoxShape.circle,
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),
              Positioned(
                left: -30,
                top: -30,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHighDark.withValues(alpha: 0.6),
                    shape: BoxShape.circle,
                  ),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(color: Colors.transparent),
                  ),
                ),
              ),
              
              // Content
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Total Net Balance',
                              style: TextStyle(
                                color: AppColors.textSecondaryDark,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: onToggle,
                              child: Icon(
                                isHidden ? Icons.visibility_off : Icons.visibility,
                                color: AppColors.textSecondaryDark,
                                size: 18,
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
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(height: 32),
                    
                    // Net Monthly Flow Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowDark,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: AppColors.incomeBg,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.sync_alt, size: 14, color: AppColors.income),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Net Monthly Flow',
                                style: TextStyle(
                                  color: AppColors.textPrimaryDark,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            isHidden ? '••••' : netFlowStr,
                            style: TextStyle(
                              color: netFlow >= 0 ? AppColors.income : AppColors.expense,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _DualMicroCards extends StatelessWidget {
  const _DualMicroCards();

  @override
  Widget build(BuildContext context) {
    return Consumer2<TransactionViewModel, SettingsViewModel>(
      builder: (context, vm, settings, child) {
        final incomeAmount = vm.monthlySummary?.totalIncome ?? 0.0;
        final expenseAmount = vm.monthlySummary?.totalExpense ?? 0.0;

        return Row(
          children: [
            Expanded(
              child: _MicroCard(
                title: 'Total Income',
                amount: settings.formatAmount(incomeAmount),
                icon: Icons.arrow_downward,
                color: AppColors.income,
                bgColor: AppColors.incomeBg,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _MicroCard(
                title: 'Total Expenses',
                amount: settings.formatAmount(expenseAmount),
                icon: Icons.arrow_upward,
                color: AppColors.expense,
                bgColor: AppColors.expenseBg,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _MicroCard extends StatelessWidget {
  final String title;
  final String amount;
  final IconData icon;
  final Color color;
  final Color bgColor;

  const _MicroCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: bgColor.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12),
          ),
          const SizedBox(height: 4),
          Text(
            amount,
            style: const TextStyle(
              color: AppColors.textPrimaryDark,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionHub extends StatelessWidget {
  const _QuickActionHub();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'QUICK ACTIONS',
          style: TextStyle(
            color: AppColors.textSecondaryDark,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ActionBtn(icon: Icons.add_circle, label: 'Income', color: AppColors.income, bg: AppColors.incomeBg),
            _ActionBtn(icon: Icons.remove_circle, label: 'Expense', color: AppColors.expense, bg: AppColors.expenseBg),
            _ActionBtn(icon: Icons.swap_horiz, label: 'Transfer', color: AppColors.textPrimaryDark, bg: AppColors.surfaceContainerHighDark),
            _ActionBtn(icon: Icons.document_scanner, label: 'Scan Bill', color: AppColors.textPrimaryDark, bg: AppColors.surfaceContainerLowDark),
          ],
        ),
      ],
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Color bg;

  const _ActionBtn({required this.icon, required this.label, required this.color, required this.bg});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: bg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: AppColors.textPrimaryDark, fontSize: 12, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _WeeklyCadenceMock extends StatelessWidget {
  const _WeeklyCadenceMock();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Weekly Cadence', style: TextStyle(color: AppColors.textPrimaryDark, fontSize: 18, fontWeight: FontWeight.bold)),
                  Text('Inflow vs. Outflow rhythm', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
                ],
              ),
              Row(
                children: [
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.income, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text('In', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
                  const SizedBox(width: 12),
                  Container(width: 8, height: 8, decoration: const BoxDecoration(color: AppColors.expense, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text('Out', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Mock bars
          SizedBox(
            height: 100,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _CadenceBar(day: 'Mon', inH: 50, outH: 30),
                _CadenceBar(day: 'Tue', inH: 35, outH: 45),
                _CadenceBar(day: 'Wed', inH: 80, outH: 20),
                _CadenceBar(day: 'Thu', inH: 90, outH: 40, isBold: true),
                _CadenceBar(day: 'Fri', inH: 25, outH: 15, isDim: true),
                _CadenceBar(day: 'Sat', inH: 20, outH: 30, isDim: true),
                _CadenceBar(day: 'Sun', inH: 15, outH: 20, isDim: true),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CadenceBar extends StatelessWidget {
  final String day;
  final double inH;
  final double outH;
  final bool isBold;
  final bool isDim;

  const _CadenceBar({required this.day, required this.inH, required this.outH, this.isBold = false, this.isDim = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(width: 10, height: inH, decoration: BoxDecoration(color: isDim ? AppColors.income.withValues(alpha: 0.4) : AppColors.income, borderRadius: const BorderRadius.vertical(top: Radius.circular(4)))),
            const SizedBox(width: 2),
            Container(width: 10, height: outH, decoration: BoxDecoration(color: isDim ? AppColors.expense.withValues(alpha: 0.4) : AppColors.expense, borderRadius: const BorderRadius.vertical(top: Radius.circular(4)))),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          day,
          style: TextStyle(
            color: isBold ? AppColors.textPrimaryDark : AppColors.textSecondaryDark,
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
            const Text(
              'Recent Activity',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimaryDark),
            ),
            Text(
              'View All >',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.income),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Consumer2<TransactionViewModel, CategoryViewModel>(
          builder: (context, vm, categoryVm, child) {
            if (vm.recentTransactions.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                decoration: BoxDecoration(color: AppColors.surfaceDark, borderRadius: BorderRadius.circular(16)),
                child: Center(
                  child: Text('No recent transactions.', style: TextStyle(color: AppColors.textSecondaryDark)),
                ),
              );
            }
            
            return Container(
              decoration: BoxDecoration(
                color: AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                children: vm.recentTransactions.take(4).map((tx) {
                  final isIncome = tx.type == TransactionType.income;
                  final categories = isIncome ? categoryVm.incomeCategories : categoryVm.expenseCategories;
                  final category = categories.firstWhere(
                    (c) => c.id == tx.categoryId,
                    orElse: () => Category(id: -1, name: 'Unknown', icon: 'category', type: tx.type),
                  );
                  
                  return Container(
                    padding: const EdgeInsets.all(16.0),
                    decoration: const BoxDecoration(
                      border: Border(bottom: BorderSide(color: AppColors.surfaceContainerLowDark)),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: isIncome ? AppColors.incomeBg : AppColors.expenseBg,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            _getIconData(category.icon), 
                            color: isIncome ? AppColors.income : AppColors.expense,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                           crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                tx.note != null && tx.note!.isNotEmpty ? tx.note! : category.name,
                                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.textPrimaryDark),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '${category.name} • ${DateFormat('MMM d').format(tx.date.toLocal())}',
                                style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 13),
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
                                fontWeight: FontWeight.bold,
                                color: isIncome ? AppColors.income : AppColors.textPrimaryDark,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerLowDark,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text('Cleared', style: TextStyle(fontSize: 10, color: AppColors.textSecondaryDark)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _FinancialTipBanner extends StatelessWidget {
  const _FinancialTipBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowDark,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceDark,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lightbulb, color: AppColors.income, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Spending Pace Tip', style: TextStyle(color: AppColors.textPrimaryDark, fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(
                  'You\'re tracking 18% below your target discretionary budget this cycle. Keep this pace!',
                  style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
