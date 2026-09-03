import 'package:flutter/material.dart';
import 'app_colors.dart';

class AppStyles {
  // Headings
  static const TextStyle heading1 = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimaryDark,
    letterSpacing: -1.0,
  );

  static const TextStyle heading2 = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimaryDark,
    letterSpacing: -0.5,
  );

  static const TextStyle heading3 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimaryDark,
  );

  static const TextStyle sectionTitle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimaryDark,
  );

  static const TextStyle sectionHeader = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.5,
    color: AppColors.textTertiaryDark,
  );

  // Body text
  static const TextStyle bodyPrimary = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimaryDark,
  );

  static const TextStyle bodySecondary = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondaryDark,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 11,
    color: AppColors.textTertiaryDark,
  );

  // Labels and small highlights
  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.bold,
    color: AppColors.textSecondaryDark,
  );

  // Dialog and App Bar
  static const TextStyle appBarTitle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimaryDark,
  );

  // Specific transaction amounts
  static const TextStyle amountIncome = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.income,
  );

  static const TextStyle amountExpense = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimaryDark,
  );
  
  static const TextStyle amountIncomeLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.income,
  );
  
  static const TextStyle amountExpenseLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimaryDark,
  );
  
  // Destructive text
  static const TextStyle destructive = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.bold,
    color: Color(0xFFF87171),
  );
}
