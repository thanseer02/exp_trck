import '../models/assistant_query.dart';
import '../models/assistant_intent.dart';

class AssistantParser {
  AssistantQuery parse(String text) {
    final lowerText = text.toLowerCase();

    // Very basic offline keyword matching for architecture demonstration
    if (lowerText.contains('balance')) {
      return AssistantQuery(
        rawText: text,
        intent: AssistantIntent.queryBalance,
      );
    } else if (lowerText.contains('expense') || lowerText.contains('spent')) {
      if (lowerText.contains('total')) {
        return AssistantQuery(
          rawText: text,
          intent: AssistantIntent.queryTotalExpense,
        );
      }
      return AssistantQuery(
        rawText: text,
        intent: AssistantIntent.queryCategoryExpense,
        parameters: {'category': 'General'},
      );
    } else if (lowerText.contains('income') || lowerText.contains('earned')) {
      return AssistantQuery(
        rawText: text,
        intent: AssistantIntent.queryTotalIncome,
      );
    } else if (lowerText.contains('recent') || lowerText.contains('last')) {
      return AssistantQuery(
        rawText: text,
        intent: AssistantIntent.queryRecentTransactions,
      );
    } else if (lowerText.contains('hello') || lowerText.contains('hi')) {
      return AssistantQuery(rawText: text, intent: AssistantIntent.greeting);
    } else if (lowerText.contains('help')) {
      return AssistantQuery(rawText: text, intent: AssistantIntent.help);
    }

    return AssistantQuery(rawText: text, intent: AssistantIntent.unknown);
  }
}
