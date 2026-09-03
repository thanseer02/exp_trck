import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/transaction_viewmodel.dart';
import '../models/transaction_type.dart';
import '../viewmodels/settings_viewmodel.dart';

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
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () => context.read<TransactionViewModel>().loadDashboardData(),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: const [
                  _BalanceSection(),
                  SizedBox(height: 24),
                  _IncomeExpenseCards(),
                  SizedBox(height: 32),
                  _TopSpendingSection(),
                  SizedBox(height: 32),
                  _RecentTransactionsSection(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BalanceSection extends StatelessWidget {
  const _BalanceSection();

  @override
  Widget build(BuildContext context) {
    return Selector<TransactionViewModel, double>(
      selector: (_, vm) => vm.balance,
      builder: (context, balance, child) {
        return Center(
          child: Column(
            children: [
              const Text('Total Balance', style: TextStyle(fontSize: 16, color: Colors.grey)),
              const SizedBox(height: 8),
              Selector<SettingsViewModel, String>(
                selector: (_, settings) => settings.formatAmount(balance),
                builder: (context, formattedBalance, child) {
                  return Text(
                    formattedBalance,
                    style: const TextStyle(fontSize: 42, fontWeight: FontWeight.bold, letterSpacing: -1.0),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _IncomeExpenseCards extends StatelessWidget {
  const _IncomeExpenseCards();

  @override
  Widget build(BuildContext context) {
    return Selector<TransactionViewModel, (double, double)>(
      selector: (_, vm) => (
        vm.monthlySummary?.totalIncome ?? 0.0,
        vm.monthlySummary?.totalExpense ?? 0.0
      ),
      builder: (context, data, child) {
        final totalIncome = data.$1;
        final totalExpense = data.$2;
        final formatAmount = context.read<SettingsViewModel>().formatAmount;

        return Row(
          children: [
            Expanded(
              child: Card(
                color: Colors.green.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.arrow_downward, color: Colors.green, size: 16),
                          SizedBox(width: 4),
                          Text('Income', style: TextStyle(color: Colors.green)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formatAmount(totalIncome),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Card(
                color: Colors.red.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.arrow_upward, color: Colors.red, size: 16),
                          SizedBox(width: 4),
                          Text('Expenses', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        formatAmount(totalExpense),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _TopSpendingSection extends StatelessWidget {
  const _TopSpendingSection();

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
        const Text(
          'Top Spending (This Month)',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Consumer<TransactionViewModel>(
          builder: (context, vm, child) {
            if (vm.topSpending.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.pie_chart_outline, size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 8),
                      const Text('No expenses recorded this month.', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              );
            }
            return Column(
              children: vm.topSpending.map((spending) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(_getIconData(spending.category.icon), color: Colors.grey.shade700),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(spending.category.name, style: const TextStyle(fontSize: 16)),
                      ),
                      Text(
                        context.read<SettingsViewModel>().formatAmount(spending.totalAmount),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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

class _RecentTransactionsSection extends StatelessWidget {
  const _RecentTransactionsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Transactions',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        Consumer<TransactionViewModel>(
          builder: (context, vm, child) {
            if (vm.recentTransactions.isEmpty) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 32.0),
                child: Center(
                  child: Column(
                    children: [
                      Icon(Icons.receipt_long, size: 48, color: Colors.grey.shade300),
                      const SizedBox(height: 8),
                      const Text('No recent transactions.', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                ),
              );
            }
            return Column(
              children: vm.recentTransactions.map((tx) {
                final isIncome = tx.type == TransactionType.income;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8.0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isIncome ? Colors.green.shade100 : Colors.red.shade100,
                      child: Icon(
                        isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                        color: isIncome ? Colors.green : Colors.red,
                      ),
                    ),
                    title: Text(tx.note != null && tx.note!.isNotEmpty ? tx.note! : tx.type.name.toUpperCase()),
                    subtitle: Text(tx.date.toLocal().toString().split(' ')[0]),
                    trailing: Text(
                      '${isIncome ? '+' : '-'}${context.read<SettingsViewModel>().formatAmount(tx.amount)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isIncome ? Colors.green : Colors.red,
                        fontSize: 16,
                      ),
                    ),
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
