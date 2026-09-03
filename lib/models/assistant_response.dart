import '../models/transaction.dart';
import '../models/category.dart';

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
  final String? categoryName;
  final Category? category;
  final List<Transaction>? transactions;
  final Transaction? transaction;
  final double? comparisonAmount;
  final double? lastAmount;
  final String? actionLabel;
  final String? actionRoute;
  final Map<String, dynamic>? actionArguments;

  AssistantResponse({
    required this.message,
    this.isUser = false,
    this.isError = false,
    this.type = AssistantResponseType.text,
    this.amount,
    this.percentage,
    this.categoryName,
    this.category,
    this.transactions,
    this.transaction,
    this.comparisonAmount,
    this.lastAmount,
    this.actionLabel,
    this.actionRoute,
    this.actionArguments,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}
