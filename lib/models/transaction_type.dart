enum TransactionType { income, expense }

extension TransactionTypeExtension on TransactionType {
  String get name {
    switch (this) {
      case TransactionType.income:
        return 'income';
      case TransactionType.expense:
        return 'expense';
    }
  }

  static TransactionType fromString(String type) {
    if (type == 'income') {
      return TransactionType.income;
    }
    return TransactionType.expense;
  }
}
