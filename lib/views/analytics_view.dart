import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/transaction_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';

class AnalyticsView extends StatefulWidget {
  const AnalyticsView({super.key});

  @override
  State<AnalyticsView> createState() => _AnalyticsViewState();
}

class _AnalyticsViewState extends State<AnalyticsView> {
  int _selectedSegment = 1; // 0=Week, 1=Month, 2=Year

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TransactionViewModel>().loadAnalyticsData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TransactionViewModel>();
    final settings = context.watch<SettingsViewModel>();
    final isLoading = vm.isLoading;

    if (isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.backgroundDark,
        body: Center(child: CircularProgressIndicator(color: AppColors.income)),
      );
    }

    final totalExpense = vm.analyticsMonthlySummary?.totalExpense ?? 0.0;
    final totalIncome = vm.analyticsMonthlySummary?.totalIncome ?? 0.0;
    final budget = totalIncome > 0 ? totalIncome : (totalExpense > 0 ? totalExpense : 0.0);
    final spentPercentage = budget > 0 ? (totalExpense / budget).clamp(0.0, 1.0) : 0.0;
    final spentPercentText = '${(spentPercentage * 100).toInt()}%';
    final remaining = budget > totalExpense ? budget - totalExpense : 0.0;
    
    final now = DateTime.now();
    final daysInMonth = DateTime(now.year, now.month + 1, 0).day;
    final daysLeft = daysInMonth - now.day;

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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Analytics',
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimaryDark),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Overview & activity',
                        style: AppStyles.bodySecondary,
                      ),
                    ],
                  ),
                  _SegmentedControl(
                    selectedIndex: _selectedSegment,
                    onChanged: (idx) => setState(() => _selectedSegment = idx),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              
              // Hero Spend Card
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
                        Text(
                          'SPENT THIS MONTH',
                          style: AppStyles.sectionHeader,
                        ),
                        Text(
                          spentPercentText,
                          style: const TextStyle(color: AppColors.income, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
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
                          'of ${settings.formatAmount(budget)}',
                          style: TextStyle(color: AppColors.textTertiaryDark, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    // Progress Bar
                    Container(
                      height: 6,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHighDark,
                        borderRadius: BorderRadius.circular(3),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: spentPercentage,
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.income,
                            borderRadius: BorderRadius.circular(3),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${settings.formatAmount(remaining)} remaining',
                          style: AppStyles.caption,
                        ),
                        Text(
                          '$daysLeft days left',
                          style: AppStyles.caption,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Spending by Category
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Spending by Category', style: AppStyles.sectionTitle),
                  Text('Details', style: AppStyles.bodySecondary),
                ],
              ),
              const SizedBox(height: 24),
              
              if (vm.analyticsTopExpenses.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 32.0),
                  child: Center(
                    child: Text('No spending data for this period.', style: AppStyles.bodySecondary),
                  ),
                )
              else ...[
                Builder(
                  builder: (context) {
                    final categoryColors = const [AppColors.income, Colors.blue, Colors.purpleAccent, Color(0xFFF87171), Colors.orangeAccent];
                    return Column(
                      children: [
                        // Segmented Progress Bar
                        Row(
                          children: vm.analyticsTopExpenses.map((item) {
                            final index = vm.analyticsTopExpenses.indexOf(item);
                            final flex = totalExpense > 0 ? (item.totalAmount / totalExpense * 100).toInt() : 0;
                            if (flex <= 0) return const SizedBox.shrink();
                            return Expanded(
                              flex: flex,
                              child: _ProgressSegment(
                                color: categoryColors[index % categoryColors.length],
                                isFirst: index == 0,
                                isLast: index == vm.analyticsTopExpenses.length - 1,
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 24),
                        
                        // Category List
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceDark,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.borderDark),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Column(
                            children: vm.analyticsTopExpenses.map((item) {
                              final index = vm.analyticsTopExpenses.indexOf(item);
                              final percentage = totalExpense > 0 
                                  ? (item.totalAmount / totalExpense * 100).toInt() 
                                  : 0;
                              return _CategoryRow(
                                color: categoryColors[index % categoryColors.length],
                                name: item.category.name,
                                amount: settings.formatAmount(item.totalAmount),
                                percentage: '$percentage%',
                                isLast: index == vm.analyticsTopExpenses.length - 1,
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    );
                  }
                ),
              ],
              
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

class _SegmentedControl extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onChanged;

  const _SegmentedControl({required this.selectedIndex, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _Segment(title: 'Week', isSelected: selectedIndex == 0, onTap: () => onChanged(0)),
          _Segment(title: 'Month', isSelected: selectedIndex == 1, onTap: () => onChanged(1)),
          _Segment(title: 'Year', isSelected: selectedIndex == 2, onTap: () => onChanged(2)),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _Segment({required this.title, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.textPrimaryDark : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.backgroundDark : AppColors.textSecondaryDark,
            fontSize: 10,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _ProgressSegment extends StatelessWidget {
  final Color color;
  final bool isFirst;
  final bool isLast;

  const _ProgressSegment({required this.color, this.isFirst = false, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 6,
      margin: EdgeInsets.only(right: isLast ? 0 : 2),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.horizontal(
          left: isFirst ? const Radius.circular(3) : Radius.zero,
          right: isLast ? const Radius.circular(3) : Radius.zero,
        ),
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  final Color color;
  final String name;
  final String amount;
  final String percentage;
  final bool isLast;

  const _CategoryRow({
    required this.color,
    required this.name,
    required this.amount,
    required this.percentage,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    name,
                    style: AppStyles.bodyPrimary,
                  ),
                ),
                Text(
                  amount,
                  style: const TextStyle(color: AppColors.textPrimaryDark, fontSize: 13, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  width: 32,
                  child: Text(
                    percentage,
                    textAlign: TextAlign.right,
                    style: AppStyles.caption,
                  ),
                ),
              ],
            ),
          ),
          if (!isLast) const Divider(height: 1, color: AppColors.surfaceContainerLowDark),
        ],
      ),
    );
  }
}
