enum AssistantResponseType {
  text,
  amount,
  percentage,
  category,
  transactionList,
  comparison,
  actionButton,
}

class AssistantResponse {
  final String message;
  final bool isUser;
  final bool isError;
  final DateTime timestamp;
  
  // Structured data fields for rich UI
  final AssistantResponseType type;
  final double? amount;
  final double? percentage;
  final String? category;
  final List<dynamic>? transactions; // Should be List<Transaction> but dynamic for simplicity across layers
  final double? comparisonAmount;
  final String? actionLabel;
  final String? actionRoute;

  AssistantResponse({
    required this.message,
    this.isUser = false,
    this.isError = false,
    this.type = AssistantResponseType.text,
    this.amount,
    this.percentage,
    this.category,
    this.transactions,
    this.comparisonAmount,
    this.actionLabel,
    this.actionRoute,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
