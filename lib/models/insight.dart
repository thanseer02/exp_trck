import 'package:flutter/material.dart';

enum InsightType {
  largestExpense,
  topCategory,
  monthlyComparison,
  dailyAverage,
  savings,
  info
}

class Insight {
  final InsightType type;
  final String title;
  final String description;
  final double? amount;
  final double? percentage;
  final String? category;
  final int priority; // Lower number means higher priority

  const Insight({
    required this.type,
    required this.title,
    required this.description,
    this.amount,
    this.percentage,
    this.category,
    this.priority = 5,
  });

  IconData get icon {
    switch (type) {
      case InsightType.largestExpense:
        return Icons.shopping_bag_outlined;
      case InsightType.topCategory:
        return Icons.pie_chart_outline;
      case InsightType.monthlyComparison:
        return Icons.trending_up; // Or trending_down depending on context, handled in UI
      case InsightType.dailyAverage:
        return Icons.calendar_today;
      case InsightType.savings:
        return Icons.savings_outlined;
      case InsightType.info:
      default:
        return Icons.lightbulb_outline;
    }
  }
}
