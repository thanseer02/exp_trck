import 'package:intl/intl.dart';
import 'package:flutter/foundation.dart';
import '../models/insight.dart';
import '../repositories/transaction_repository.dart';

class InsightEngine {
  final TransactionRepository _repository;
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

  InsightEngine(this._repository);

  Future<List<Insight>> generateInsights() async {
    final List<Insight> insights = [];
    final now = DateTime.now();
    final thisMonthStart = DateTime(now.year, now.month, 1);
    final thisMonthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    try {
      final totalExpenses = await _repository.getTotalExpenses();
      if (totalExpenses == 0) {
        return insights; // No insights if no expenses exist
      }

      // 1. Top Spending Category Insight
      final topCategoryData = await _repository.getAssistantTopSpendingCategory(start: thisMonthStart, end: thisMonthEnd);
      if (topCategoryData != null) {
        final amount = topCategoryData['amount'] as double;
        final name = topCategoryData['name'] as String;
        final total = topCategoryData['total'] as double;
        if (amount > 0 && total > 0) {
          final percentage = (amount / total) * 100;
          insights.add(
            Insight(
              type: InsightType.topCategory,
              title: 'Top Category',
              description: '$name is your biggest expense this month.',
              amount: amount,
              percentage: percentage,
              category: name,
              priority: 1,
            )
          );
        }
      }

      // 2. Monthly Comparison Insight
      final lastMonthStart = DateTime(now.year, now.month - 1, 1);
      final lastMonthEnd = DateTime(now.year, now.month, 0, 23, 59, 59);
      
      final currentMonthExpenses = await _repository.getExpensesForPeriod(thisMonthStart, thisMonthEnd);
      final lastMonthExpenses = await _repository.getExpensesForPeriod(lastMonthStart, lastMonthEnd);
      
      if (lastMonthExpenses > 0) {
        final diff = currentMonthExpenses - lastMonthExpenses;
        final percentage = (diff.abs() / lastMonthExpenses) * 100;
        
        if (diff > 0) {
          insights.add(
            Insight(
              type: InsightType.monthlyComparison,
              title: 'Spending Increased',
              description: 'You spent ${percentage.toStringAsFixed(0)}% more this month than last month.',
              amount: diff,
              percentage: percentage,
              priority: currentMonthExpenses > 0 ? 2 : 10,
            )
          );
        } else if (diff < 0) {
          insights.add(
            Insight(
              type: InsightType.savings,
              title: 'Great Job!',
              description: 'Your spending decreased by ${_currencyFormat.format(diff.abs())} compared to last month.',
              amount: diff.abs(),
              percentage: percentage,
              priority: 2,
            )
          );
        }
      }

      // 3. Largest Expense Insight
      final largestExpenseData = await _repository.getLargestExpenseTransaction(start: thisMonthStart, end: thisMonthEnd);
      if (largestExpenseData != null) {
        final transaction = largestExpenseData['transaction'];
        final amount = transaction.amount;
        if (amount > 0 && currentMonthExpenses > 0 && (amount / currentMonthExpenses) > 0.1) {
          insights.add(
            Insight(
              type: InsightType.largestExpense,
              title: 'Largest Transaction',
              description: 'Your largest transaction this month was ${_currencyFormat.format(amount)}.',
              amount: amount,
              priority: 3,
            )
          );
        }
      }

      // 4. Daily Average Insight
      final daysInMonth = now.day; // Up to current day
      if (daysInMonth > 1 && currentMonthExpenses > 0) {
        final dailyAverage = currentMonthExpenses / daysInMonth;
        insights.add(
          Insight(
            type: InsightType.dailyAverage,
            title: 'Daily Average',
            description: 'Your average daily spending is ${_currencyFormat.format(dailyAverage)}.',
            amount: dailyAverage,
            priority: 4,
          )
        );
      }

      // Sort by priority
      insights.sort((a, b) => a.priority.compareTo(b.priority));
      
      return insights;
    } catch (e) {
      debugPrint('Error generating insights: $e');
      return insights;
    }
  }
}
