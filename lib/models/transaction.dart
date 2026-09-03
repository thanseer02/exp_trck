import 'transaction_type.dart';

class Transaction {
  final int? id;
  final TransactionType type;
  final double amount;
  final int categoryId;
  final String? note;
  final DateTime date;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Transaction({
    this.id,
    required this.type,
    required this.amount,
    required this.categoryId,
    this.note,
    required this.date,
    this.createdAt,
    this.updatedAt,
  });

  Transaction copyWith({
    int? id,
    TransactionType? type,
    double? amount,
    int? categoryId,
    String? note,
    DateTime? date,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Transaction &&
        other.id == id &&
        other.type == type &&
        other.amount == amount &&
        other.categoryId == categoryId &&
        other.note == note &&
        other.date == date &&
        other.createdAt == createdAt &&
        other.updatedAt == updatedAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        type.hashCode ^
        amount.hashCode ^
        categoryId.hashCode ^
        note.hashCode ^
        date.hashCode ^
        createdAt.hashCode ^
        updatedAt.hashCode;
  }
}
