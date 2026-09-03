import 'package:expense_tracker/services/assistant_parser.dart';
import 'package:expense_tracker/services/assistant_response_generator.dart';
import 'package:expense_tracker/models/assistant_query.dart';

void main() {
  final parser = AssistantParser();
  
  final questions = [
    "What is my balance?",
    "How much did I earn?",
    "How much did I spend?",
    "How much did I spend this month?",
    "How much did I spend last month?",
    "Where did I spend most?",
    "How much did I spend on Food?",
    "How much did I spend on Food this month?",
    "What was my biggest expense?",
    "What did I spend today?",
    "What did I spend yesterday?",
    "How much did I spend this week?",
    "Did I spend more than last month?",
    "Which category increased the most?",
    "Which category decreased the most?",
    "What is my average daily spending?",
    "How many transactions did I make?",
    "What can you do?",
    "Tell me a joke",
    "How much"
  ];

  for (final q in questions) {
    final query = parser.parse(q);
    print('Q: $q');
    print('Intent: ${query.intent}');
    print('DateRange: ${query.startDate} to ${query.endDate}');
    print('Category: ${query.category}');
    print('----------------');
  }
}
