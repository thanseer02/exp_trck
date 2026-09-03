class AssistantResponse {
  final String message;
  final bool isUser;
  final bool isError;
  final DateTime timestamp;

  AssistantResponse({
    required this.message,
    this.isUser = false,
    this.isError = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
