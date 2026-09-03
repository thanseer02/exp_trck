import '../models/assistant_response.dart';
import '../models/assistant_intent.dart';

class AssistantResponseGenerator {
  AssistantResponse generateResponse(AssistantIntent intent, dynamic data) {
    String message = '';

    switch (intent) {
      case AssistantIntent.queryBalance:
        final balance = data as double;
        message =
            'Your current net balance is \$${balance.toStringAsFixed(2)}.';
        break;
      case AssistantIntent.queryTotalExpense:
        final expense = data as double;
        message =
            'You have spent a total of \$${expense.toStringAsFixed(2)} recently.';
        break;
      case AssistantIntent.queryTotalIncome:
        final income = data as double;
        message =
            'You have earned a total of \$${income.toStringAsFixed(2)} recently.';
        break;
      case AssistantIntent.queryRecentTransactions:
        // Expecting data to be a List of transactions or a formatted string for now
        message = 'Here are your recent transactions:\\n$data';
        break;
      case AssistantIntent.greeting:
        message =
            'Hello! I am your Money Assistant. How can I help you track your finances today?';
        break;
      case AssistantIntent.help:
        message =
            'You can ask me things like:\\n- What is my balance?\\n- How much have I spent?\\n- Show me my recent transactions.';
        break;
      case AssistantIntent.queryCategoryExpense:
        message =
            'Category specific queries are not fully supported yet, but you spent some money there.';
        break;
      case AssistantIntent.unknown:
        message =
            'I am not sure how to answer that yet. Try asking about your balance or recent expenses.';
        break;
    }

    return AssistantResponse(message: message);
  }
}
