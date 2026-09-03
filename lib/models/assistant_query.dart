import 'assistant_intent.dart';

class AssistantQuery {
  final AssistantIntent intent;
  final String? category;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? month;
  final int? year;
  final double? amount;
  final String originalQuestion;

  const AssistantQuery({
    required this.intent,
    required this.originalQuestion,
    this.category,
    this.startDate,
    this.endDate,
    this.month,
    this.year,
    this.amount,
  });
}
