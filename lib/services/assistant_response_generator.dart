import '../models/assistant_response.dart';
import '../models/assistant_intent.dart';

class AssistantResponseGenerator {
  AssistantResponse generateResponse(AssistantIntent intent, dynamic data) {
    String message = '';
    
    switch (intent) {
      case AssistantIntent.balance:
        final balance = data as double;
        message = 'Your current net balance is \$${balance.toStringAsFixed(2)}.';
        break;
      case AssistantIntent.totalExpense:
        final expense = data as double;
        message = 'You have spent a total of \$${expense.toStringAsFixed(2)} recently.';
        break;
      case AssistantIntent.totalIncome:
        final income = data as double;
        message = 'You have earned a total of \$${income.toStringAsFixed(2)} recently.';
        break;
      case AssistantIntent.recentTransactions:
        message = 'Here are your recent transactions:\\n$data';
        break;
      case AssistantIntent.help:
        message = 'You can ask me things like:\\n- What is my balance?\\n- How much have I spent?\\n- Show me my recent transactions.';
        break;
      case AssistantIntent.categoryExpense:
      case AssistantIntent.monthlyIncome:
      case AssistantIntent.monthlyExpense:
      case AssistantIntent.topSpendingCategory:
      case AssistantIntent.largestExpense:
      case AssistantIntent.averageExpense:
      case AssistantIntent.dailyExpense:
      case AssistantIntent.monthlyComparison:
      case AssistantIntent.categoryComparison:
      case AssistantIntent.spendingInsight:
        message = 'This query type is recognized but the data generation is not fully implemented yet.';
        break;
      case AssistantIntent.unknown:
        message = 'I am not sure how to answer that yet. Try asking about your balance or recent expenses.';
        break;
    }
    
    return AssistantResponse(message: message);
  }
}
