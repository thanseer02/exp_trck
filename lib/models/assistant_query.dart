import 'assistant_intent.dart';

class AssistantQuery {
  final String rawText;
  final AssistantIntent intent;
  final Map<String, dynamic> parameters;

  const AssistantQuery({
    required this.rawText,
    required this.intent,
    this.parameters = const {},
  });
}
