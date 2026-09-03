import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/transaction_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';
import 'package:intl/intl.dart';
import 'category_details_view.dart';

class AnalyticsView extends StatefulWidget {
  const AnalyticsView({super.key});

  @override
  State<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TransactionViewModel>().loadAnalyticsData();
      }
    });
  }

  void _previousMonth(TransactionViewModel vm) {
    final current = vm.analyticsMonth;
    vm.setAnalyticsMonth(DateTime(current.year, current.month - 1));
  }

  void _nextMonth(TransactionViewModel vm) {
    final current = vm.analyticsMonth;
    vm.setAnalyticsMonth(DateTime(current.year, current.month + 1));
  }

  void _selectMonth(TransactionViewModel vm) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: vm.analyticsMonth,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      initialDatePickerMode: DatePickerMode.year,
    );
    if (picked != null) {
      vm.setAnalyticsMonth(DateTime(picked.year, picked.month));
    }
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
      default: return Icons.category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TransactionViewModel>();
    final summary = vm.analyticsMonthlySummary;
    final topExpenses = vm.analyticsTopExpenses;
    
    final totalExpense = summary?.totalExpense ?? 0.0;
    final averageExpense = vm.analyticsTransactionCount > 0 
        ? totalExpense / vm.analyticsTransactionCount 
        : 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spending Analytics'),
      ),
      body: SafeArea(
        child: vm.isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: () => vm.loadAnalyticsData(),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: ListView(
                      padding: const EdgeInsets.all(16.0),
                      children: [
                  // Month Selector
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: () => _previousMonth(vm),
                      ),
                      TextButton(
                        onPressed: () => _selectMonth(vm),
                        child: Text(
                          DateFormat.yMMMM().format(vm.analyticsMonth),
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: () => _nextMonth(vm),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  
                  // Total Spending Header
                  const Center(child: Text('Total Spending', style: TextStyle(fontSize: 16, color: Colors.grey))),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      context.read<SettingsViewModel>().formatAmount(totalExpense),
                      style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.red),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Grid Metrics
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 2,
                    children: [
                      _buildMetricCard('Total Income', context.read<SettingsViewModel>().formatAmount(summary?.totalIncome ?? 0), Colors.green),
                      _buildMetricCard('Balance', context.read<SettingsViewModel>().formatAmount(summary?.balance ?? 0), Colors.deepPurple),
                      _buildMetricCard('Transactions', '${vm.analyticsTransactionCount}', Colors.blue),
                      _buildMetricCard('Avg Expense', context.read<SettingsViewModel>().formatAmount(averageExpense), Colors.orange),
                    ],
                  ),
                  const SizedBox(height: 32),

                  if (totalExpense <= 0 || topExpenses.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 48.0),
                      child: Center(
                        child: Text('No spending data for this month.', style: TextStyle(color: Colors.grey, fontSize: 16)),
                      ),
                    )
                  else ...[
                    if (vm.monthlyInsights.isNotEmpty) ...[
                      const Text('Monthly Insights', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 16),
                      ...vm.monthlyInsights.map((insight) {
                        final isPositive = insight.contains('decreased') || insight.contains('increased by') && insight.contains('income');
                        final color = isPositive ? Colors.green : Colors.orange;
                        final icon = isPositive ? Icons.trending_down : Icons.trending_up;
                        
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: color.withValues(alpha: 0.1),
                              child: Icon(icon, color: color, size: 20),
                            ),
                            title: Text(insight.replaceAll('\$', context.read<SettingsViewModel>().currencySymbol), style: const TextStyle(fontSize: 14)),
                          ),
                        );
                      }),
                      const SizedBox(height: 32),
                    ],

                    // Biggest Expense Category Card
                    const Text('Biggest Expense', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    Card(
                      color: Colors.red.shade50,
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => CategoryDetailsView(
                                category: topExpenses.first.category,
                                month: vm.analyticsMonth,
                              ),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                          children: [
                            CircleAvatar(
                              radius: 24,
                              backgroundColor: Colors.red.shade100,
                              child: Icon(_getIconData(topExpenses.first.category.icon), color: Colors.red, size: 28),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    topExpenses.first.category.name,
                                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${((topExpenses.first.totalAmount / totalExpense) * 100).toStringAsFixed(1)}% of total spending',
                                    style: TextStyle(color: Colors.red.shade900),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              context.read<SettingsViewModel>().formatAmount(topExpenses.first.totalAmount),
                              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                    // Spending By Category Chart
                    const Text('Spending By Category', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 16),
                    ...topExpenses.map((spending) {
                      final percentage = (spending.totalAmount / totalExpense) * 100;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 24.0),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => CategoryDetailsView(
                                  category: spending.category,
                                  month: vm.analyticsMonth,
                                ),
                              ),
                            );
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Icon(_getIconData(spending.category.icon), size: 16, color: Colors.grey),
                                    const SizedBox(width: 8),
                                    Text(spending.category.name, style: const TextStyle(fontSize: 16)),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(context.read<SettingsViewModel>().formatAmount(spending.totalAmount), style: const TextStyle(fontWeight: FontWeight.bold)),
                                    const SizedBox(width: 8),
                                    Text('${percentage.toStringAsFixed(1)}%', style: const TextStyle(color: Colors.grey)),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Stack(
                              children: [
                                Container(
                                  height: 8,
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                FractionallySizedBox(
                                  widthFactor: percentage / 100.0,
                                  child: Container(
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: Colors.deepPurple,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  ]
                ],
              ),
             ),
            ),
           ),
         ),
    );
  }

  Widget _buildMetricCard(String title, String value, Color color) {
    return Card(
      elevation: 0,
      color: color.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: BorderSide(color: color.withValues(alpha: 0.2))),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: TextStyle(color: color.withValues(alpha: 0.8), fontSize: 12, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
