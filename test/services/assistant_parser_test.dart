import 'package:flutter_test/flutter_test.dart';
import 'package:expense_tracker/services/assistant_parser.dart';
import 'package:expense_tracker/models/assistant_intent.dart';

void main() {
  late AssistantParser parser;

  setUp(() {
    parser = AssistantParser();
  });

  group('Expense intents', () {
    test('resolves totalExpense', () {
      final inputs = [
        "How much did I spend?",
        "What are my expenses?",
        "How much money did I spend?",
        "How much have I spent?",
        "What did I spend?",
      ];
      for (final input in inputs) {
        final query = parser.parse(input);
        expect(query.intent, AssistantIntent.totalExpense, reason: 'Failed on: \$input');
      }
    });

    test('resolves monthlyExpense', () {
      final inputs = [
        "How much did I spend this month?",
        "What are my expenses for January?",
      ];
      for (final input in inputs) {
        final query = parser.parse(input);
        expect(query.intent, AssistantIntent.monthlyExpense, reason: 'Failed on: \$input');
      }
    });

    test('resolves dailyExpense', () {
      final inputs = [
        "How much did I spend today?",
        "What are my expenses from yesterday?",
      ];
      for (final input in inputs) {
        final query = parser.parse(input);
        expect(query.intent, AssistantIntent.dailyExpense, reason: 'Failed on: \$input');
      }
    });
  });

  group('Balance intents', () {
    test('resolves balance', () {
      final inputs = [
        "What's my balance?",
        "How much money do I have?",
        "What is left?",
        "How much do I have?",
      ];
      for (final input in inputs) {
        final query = parser.parse(input);
        expect(query.intent, AssistantIntent.balance, reason: 'Failed on: \$input');
      }
    });
  });

  group('Top category intents', () {
    test('resolves topSpendingCategory', () {
      final inputs = [
        "Where did I spend the most?",
        "What am I spending most on?",
        "Which category costs me the most?",
        "Where does my money go?",
      ];
      for (final input in inputs) {
        final query = parser.parse(input);
        expect(query.intent, AssistantIntent.topSpendingCategory, reason: 'Failed on: \$input');
      }
    });
  });

  group('Category specific intents', () {
    test('resolves categoryExpense and extracts category', () {
      final cases = {
        "How much did I spend on food?": "food",
        "What did I spend on transport?": "transport",
        "How much went to shopping?": "shopping",
      };
      
      cases.forEach((input, expectedCategory) {
        final query = parser.parse(input);
        expect(query.intent, AssistantIntent.categoryExpense, reason: 'Failed intent on: \$input');
        expect(query.category, expectedCategory, reason: 'Failed category extraction on: \$input');
      });
    });
  });

  group('Time extraction', () {
    test('extracts dates correctly', () {
      final qToday = parser.parse("how much did I spend today?");
      expect(qToday.startDate, isNotNull);
      expect(qToday.endDate, isNotNull);
      
      final qThisMonth = parser.parse("how much did I spend this month?");
      expect(qThisMonth.startDate, isNotNull);
      expect(qThisMonth.endDate, isNotNull);
      
      final qLastMonth = parser.parse("how much did I spend last month?");
      expect(qLastMonth.startDate, isNotNull);
      expect(qLastMonth.endDate, isNotNull);
    });
    
    test('extracts months correctly', () {
      final query = parser.parse("what did I spend in february");
      expect(query.month, 2);
      expect(query.intent, AssistantIntent.monthlyExpense);
    });
  });

  group('Other intents', () {
    test('resolves totalIncome', () {
      final query = parser.parse("How much did I earn?");
      expect(query.intent, AssistantIntent.totalIncome);
    });

    test('resolves monthlyComparison', () {
      final query = parser.parse("Did I spend more than last month?");
      expect(query.intent, AssistantIntent.monthlyComparison);
    });

    test('returns unknown for ambiguous queries', () {
      final query = parser.parse("What color is the sky?");
      expect(query.intent, AssistantIntent.unknown);
    });
  });
}
