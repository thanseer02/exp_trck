import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class BudgetsView extends StatelessWidget {
  const BudgetsView({super.key});

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
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none, color: AppColors.textSecondaryDark, size: 22),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
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
              Text(
                'Keep your spending in check',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondaryDark),
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
                        Text(
                          'MONTHLY DISCRETIONARY',
                          style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.5),
                        ),
                        const Icon(Icons.more_horiz, color: AppColors.textSecondaryDark, size: 20),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        const Text(
                          '\$1,420.50',
                          style: TextStyle(color: AppColors.textPrimaryDark, fontSize: 32, fontWeight: FontWeight.bold, letterSpacing: -1.0),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'left of \$3,000.00',
                          style: TextStyle(color: AppColors.textTertiaryDark, fontSize: 12),
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
                        widthFactor: 0.52, // 52% spent
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.income,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'On track',
                          style: TextStyle(color: AppColors.income, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          '11 days left',
                          style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 11),
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
                  const Text('Category Budgets', style: TextStyle(color: AppColors.textPrimaryDark, fontSize: 16, fontWeight: FontWeight.w600)),
                  Text('Edit', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 24),
              
              // Category Budgets List
              _BudgetCategoryRow(
                icon: Icons.restaurant,
                name: 'Food & Dining',
                spent: '\$780.20',
                total: '\$1,000.00',
                percent: 0.78,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              _BudgetCategoryRow(
                icon: Icons.shopping_cart,
                name: 'Shopping & Tech',
                spent: '\$540.00',
                total: '\$400.00',
                percent: 1.0, // Over budget
                isOverBudget: true,
                color: const Color(0xFFF87171),
              ),
              const SizedBox(height: 24),
              _BudgetCategoryRow(
                icon: Icons.movie,
                name: 'Entertainment',
                spent: '\$120.00',
                total: '\$300.00',
                percent: 0.4,
                color: Colors.purpleAccent,
              ),
              
              const SizedBox(height: 48),
              
              // Savings Goals Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Savings Goals', style: TextStyle(color: AppColors.textPrimaryDark, fontSize: 16, fontWeight: FontWeight.w600)),
                  Text('Add', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
                ],
              ),
              const SizedBox(height: 24),
              
              // Savings Goal Card
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
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Emergency Reserve', style: TextStyle(color: AppColors.textPrimaryDark, fontSize: 14, fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text('\$14,500.00 of \$20,000.00', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
                            ],
                          ),
                        ),
                        const Text('72%', style: TextStyle(color: AppColors.textPrimaryDark, fontSize: 16, fontWeight: FontWeight.bold)),
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
                        widthFactor: 0.72,
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
                        child: const Text('Add Funds', style: TextStyle(color: AppColors.textPrimaryDark)),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 64),
            ],
          ),
        ),
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
                  Text(name, style: const TextStyle(color: AppColors.textPrimaryDark, fontSize: 13, fontWeight: FontWeight.w600)),
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
