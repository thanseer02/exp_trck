import 'dart:core';
import 'package:flutter/foundation.dart';

import '../models/assistant_query.dart';
import '../models/assistant_intent.dart';

class AssistantParser {
  AssistantQuery parse(String text) {
    // Normalize: lowercase, whitespace, punctuation
    String normalized = text.toLowerCase().trim();
    normalized = normalized.replaceAll(RegExp(r'[^\w\s]'), '');
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ');

    final intent = determineIntent(normalized);
    final category = extractCategory(normalized, intent);
    final month = extractMonth(normalized);
    final year = extractYear(normalized);
    final amount = extractAmount(normalized);
    
    // Extract start/end dates based on time keywords
    DateTime? startDate;
    DateTime? endDate;
    final now = DateTime.now();

    if (normalized.contains('today')) {
      startDate = DateTime(now.year, now.month, now.day);
      endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
    } else if (normalized.contains('yesterday')) {
      final yesterday = now.subtract(const Duration(days: 1));
      startDate = DateTime(yesterday.year, yesterday.month, yesterday.day);
      endDate = DateTime(yesterday.year, yesterday.month, yesterday.day, 23, 59, 59);
    } else if (normalized.contains('this week')) {
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
      startDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
      endDate = startDate.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
    } else if (normalized.contains('last week')) {
      final startOfLastWeek = now.subtract(Duration(days: now.weekday - 1 + 7));
      startDate = DateTime(startOfLastWeek.year, startOfLastWeek.month, startOfLastWeek.day);
      endDate = startDate.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59));
    } else if (normalized.contains('this month')) {
      startDate = DateTime(now.year, now.month, 1);
      endDate = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    } else if (normalized.contains('last month')) {
      startDate = DateTime(now.year, now.month - 1, 1);
      endDate = DateTime(now.year, now.month, 0, 23, 59, 59);
    } else if (normalized.contains('this year')) {
      startDate = DateTime(now.year, 1, 1);
      endDate = DateTime(now.year, 12, 31, 23, 59, 59);
    } else if (normalized.contains('last year')) {
      startDate = DateTime(now.year - 1, 1, 1);
      endDate = DateTime(now.year - 1, 12, 31, 23, 59, 59);
    } else if (month != null) {
      final int targetYear = year ?? now.year;
      startDate = DateTime(targetYear, month, 1);
      endDate = DateTime(targetYear, month + 1, 0, 23, 59, 59);
    } else if (year != null) {
      startDate = DateTime(year, 1, 1);
      endDate = DateTime(year, 12, 31, 23, 59, 59);
    }
    
    return AssistantQuery(
      intent: intent,
      originalQuestion: text,
      category: category,
      month: month,
      year: year,
      startDate: startDate,
      endDate: endDate,
      amount: amount,
    );
  }

  @visibleForTesting
  AssistantIntent determineIntent(String text) {
    if (_matches(text, [
      r'\bbalance\b',
      r'how much money do i have',
      r'what is left',
      r'how much do i have',
    ])) {
      return AssistantIntent.balance;
    }
    
    if (_matches(text, [
      r'spend the most',
      r'spending most on',
      r'category costs me the most',
      r'where does my money go',
      r'spend most',
    ])) {
      return AssistantIntent.topSpendingCategory;
    }
    
    if (_matches(text, [
      r'biggest expense',
      r'largest expense',
      r'highest expense'
    ])) {
      return AssistantIntent.largestExpense;
    }
    
    if (_matches(text, [
      r'average expense',
      r'average spend',
    ])) {
      return AssistantIntent.averageExpense;
    }
    
    if (_matches(text, [
      r'more than last month',
      r'compare.*last month',
      r'spend.*more.*last month'
    ])) {
      return AssistantIntent.monthlyComparison;
    }
    
    if (_matches(text, [
      r'\bearn',
      r'\bincome\b',
      r'\bmake\b',
      r'made'
    ])) {
      if (_matches(text, [r'this month', r'last month', r'january', r'february', r'march', r'april', r'may', r'june', r'july', r'august', r'september', r'october', r'november', r'december'])) {
        return AssistantIntent.monthlyIncome;
      }
      return AssistantIntent.totalIncome;
    }
    
    if (_matches(text, [
      r'spend on \w+',
      r'spent on \w+',
      r'went to \w+'
    ])) {
      return AssistantIntent.categoryExpense;
    }
    
    if (_matches(text, [
      r'\bspend\b',
      r'\bspent\b',
      r'\bexpenses?\b',
      r'cost',
    ])) {
      if (text.contains('today') || text.contains('yesterday')) {
        return AssistantIntent.dailyExpense;
      }
      if (_matches(text, [r'this month', r'last month', r'january', r'february', r'march', r'april', r'may', r'june', r'july', r'august', r'september', r'october', r'november', r'december'])) {
        return AssistantIntent.monthlyExpense;
      }
      return AssistantIntent.totalExpense;
    }
    
    if (_matches(text, [
      r'recent',
      r'last transactions?',
      r'history'
    ])) {
      return AssistantIntent.recentTransactions;
    }
    
    if (_matches(text, [
      r'how many transactions',
      r'number of transactions',
    ])) {
      return AssistantIntent.transactionCount;
    }
    
    if (_matches(text, [
      r'category increased',
      r'increased the most',
    ])) {
      return AssistantIntent.categoryIncreaseMost;
    }
    
    if (_matches(text, [
      r'category decreased',
      r'decreased the most',
    ])) {
      return AssistantIntent.categoryDecreaseMost;
    }
    
    if (_matches(text, [
      r'save',
      r'savings',
    ])) {
      return AssistantIntent.savings;
    }
    
    if (_matches(text, [
      r'percentage',
      r'percent',
    ])) {
      return AssistantIntent.spendPercentage;
    }
    
    if (_matches(text, [
      r'most expensive day',
      r'highest spending day',
    ])) {
      return AssistantIntent.mostExpensiveDay;
    }
    
    if (_matches(text, [r'^hello', r'^hi\b'])) {
      return AssistantIntent.help;
    }
    
    if (_matches(text, [r'^help', r'what can you do', r'what can i ask'])) {
      return AssistantIntent.help;
    }
    
    if (_matches(text, [r'^cancel\b', r'^abort\b'])) {
      return AssistantIntent.cancelAction;
    }
    
    if (text.startsWith('confirmaction')) {
      return AssistantIntent.confirmAction;
    }
    
    if (_matches(text, [r'add .* expense', r'add .* transaction'])) {
      return AssistantIntent.addTransaction;
    }
    
    if (_matches(text, [r'delete .* transaction', r'remove .* transaction'])) {
      return AssistantIntent.deleteTransaction;
    }
    
    return AssistantIntent.unknown;
  }

  bool _matches(String text, List<String> patterns) {
    for (final pattern in patterns) {
      if (RegExp(pattern).hasMatch(text)) {
        return true;
      }
    }
    return false;
  }

  @visibleForTesting
  String? extractCategory(String text, AssistantIntent intent) {
    if (intent == AssistantIntent.addTransaction) {
       final RegExp regExp4 = RegExp(r'add .*? (\w+) expense');
       final match4 = regExp4.firstMatch(text);
       if (match4 != null) return match4.group(1);
    }
  
    if (intent != AssistantIntent.categoryExpense && intent != AssistantIntent.addTransaction) return null;
    
    final RegExp regExp1 = RegExp(r'spend on (\w+)');
    final match1 = regExp1.firstMatch(text);
    if (match1 != null) return match1.group(1);
    
    final RegExp regExp2 = RegExp(r'spent on (\w+)');
    final match2 = regExp2.firstMatch(text);
    if (match2 != null) return match2.group(1);
    
    final RegExp regExp3 = RegExp(r'went to (\w+)');
    final match3 = regExp3.firstMatch(text);
    if (match3 != null) return match3.group(1);
    
    return null;
  }
  
  @visibleForTesting
  double? extractAmount(String text) {
    final RegExp regExp = RegExp(r'(?:₹|rs\.?|rupees?)?\s*(\d+(?:,\d+)*(?:\.\d+)?)');
    final match = regExp.firstMatch(text);
    if (match != null && match.groupCount >= 1) {
      final str = match.group(1)!.replaceAll(',', '');
      return double.tryParse(str);
    }
    return null;
  }

  @visibleForTesting
  int? extractMonth(String text) {
    const months = {
      'january': 1, 'february': 2, 'march': 3, 'april': 4,
      'may': 5, 'june': 6, 'july': 7, 'august': 8,
      'september': 9, 'october': 10, 'november': 11, 'december': 12,
      'jan': 1, 'feb': 2, 'mar': 3, 'apr': 4,
      'jun': 6, 'jul': 7, 'aug': 8,
      'sep': 9, 'oct': 10, 'nov': 11, 'dec': 12
    };
    
    for (final entry in months.entries) {
      if (RegExp(r'\b' + entry.key + r'\b').hasMatch(text)) {
        return entry.value;
      }
    }
    return null;
  }
  
  @visibleForTesting
  int? extractYear(String text) {
    final RegExp regExp = RegExp(r'\b(20\d{2})\b');
    final match = regExp.firstMatch(text);
    if (match != null && match.groupCount >= 1) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }
}
