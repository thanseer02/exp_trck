import '../models/assistant_query.dart';
import '../models/assistant_intent.dart';

class AssistantParser {
  AssistantQuery parse(String text) {
    final lowerText = text.toLowerCase().trim();
    
    final intent = determineIntent(lowerText);
    final category = extractCategory(lowerText, intent);
    final month = extractMonth(lowerText);
    final year = extractYear(lowerText);
    
    return AssistantQuery(
      intent: intent,
      originalQuestion: text,
      category: category,
      month: month,
      year: year,
    );
  }

  AssistantIntent determineIntent(String text) {
    if (text.contains('balance')) {
      return AssistantIntent.balance;
    }
    
    if (text.contains('spend the most') || text.contains('spent the most') || text.contains('where do i spend most')) {
      return AssistantIntent.topSpendingCategory;
    }
    
    if (text.contains('biggest expense') || text.contains('largest expense')) {
      return AssistantIntent.largestExpense;
    }
    
    if (text.contains('average expense') || text.contains('average spend')) {
      return AssistantIntent.averageExpense;
    }
    
    if (text.contains('more than last month') || text.contains('compare to last month') || (text.contains('spend') && text.contains('last month') && text.contains('more'))) {
      return AssistantIntent.monthlyComparison;
    }
    
    if (text.contains('earn') || text.contains('income') || text.contains('make')) {
      if (text.contains('this month') || (text.contains('in ') && extractMonth(text) != null)) {
        return AssistantIntent.monthlyIncome;
      }
      return AssistantIntent.totalIncome;
    }
    
    if (text.contains('spend') || text.contains('spent') || text.contains('expense')) {
      if (text.contains('today')) {
        return AssistantIntent.dailyExpense;
      }
      
      if (text.contains('on ')) {
        return AssistantIntent.categoryExpense;
      }
      
      if (text.contains('this month') || (text.contains('in ') && extractMonth(text) != null)) {
        return AssistantIntent.monthlyExpense;
      }
      
      return AssistantIntent.totalExpense;
    }
    
    if (text.contains('recent') || text.contains('last transactions') || text.contains('history')) {
      return AssistantIntent.recentTransactions;
    }
    
    if (text.contains('hello') || text.contains('hi')) {
      return AssistantIntent.help;
    }
    
    if (text.contains('help')) {
      return AssistantIntent.help;
    }
    
    return AssistantIntent.unknown;
  }

  String? extractCategory(String text, AssistantIntent intent) {
    if (intent != AssistantIntent.categoryExpense) return null;
    
    // Look for "on [category]"
    final RegExp regExp = RegExp(r'on\s+([a-zA-Z0-9_]+)\b');
    final match = regExp.firstMatch(text);
    if (match != null && match.groupCount >= 1) {
      return match.group(1);
    }
    return null;
  }

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
      if (text.contains(entry.key)) {
        return entry.value;
      }
    }
    return null;
  }
  
  int? extractYear(String text) {
    final RegExp regExp = RegExp(r'\b(20\d{2})\b');
    final match = regExp.firstMatch(text);
    if (match != null && match.groupCount >= 1) {
      return int.tryParse(match.group(1)!);
    }
    return null;
  }
}
