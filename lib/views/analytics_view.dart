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
    // Mock budget for UI demonstration based on the design
    const mockBudget = 5000.0;
    final spentPercentage = (totalExpense / mockBudget).clamp(0.0, 1.0);
    final spentPercentText = '${(spentPercentage * 100).toInt()}%';
    final remaining = mockBudget - totalExpense;

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
                          'of ${settings.formatAmount(mockBudget)}',
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
                          '11 days left', // Mock data for days left
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
              
              // Segmented Progress Bar (Mocked for visual based on the design)
              Row(
                children: [
                  Expanded(flex: 38, child: _ProgressSegment(color: AppColors.income, isFirst: true)),
                  Expanded(flex: 20, child: _ProgressSegment(color: Colors.blue)),
                  Expanded(flex: 14, child: _ProgressSegment(color: Colors.purpleAccent)),
                  Expanded(flex: 8, child: _ProgressSegment(color: AppColors.textTertiaryDark)),
                  Expanded(flex: 20, child: _ProgressSegment(color: const Color(0xFFF87171), isLast: true)),
                ],
              ),
              const SizedBox(height: 24),
              
              // Mocked Category List to perfectly match the design
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderDark),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    _CategoryRow(color: AppColors.income, name: 'Housing & Utilities', amount: '\$1,450.00', percentage: '38%'),
                    _CategoryRow(color: Colors.blue, name: 'Food & Dining', amount: '\$780.20', percentage: '20%'),
                    _CategoryRow(color: Colors.purpleAccent, name: 'Shopping & Tech', amount: '\$540.00', percentage: '14%'),
                    _CategoryRow(color: AppColors.textTertiaryDark, name: 'Transportation', amount: '\$320.30', percentage: '8%'),
                    _CategoryRow(color: const Color(0xFFF87171), name: 'Entertainment & Other', amount: '\$730.00', percentage: '20%', isLast: true),
                  ],
                ),
              ),
              
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
