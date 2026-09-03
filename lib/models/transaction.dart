class AppTransaction {
  final int? id;
  final String type; // 'income' or 'expense'
  final double amount;
  final int categoryId;
  final String? note;
  final DateTime date;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  AppTransaction({
    this.id,
    required this.type,
    required this.amount,
    required this.categoryId,
    this.note,
    required this.date,
    this.createdAt,
    this.updatedAt,
  });
}
