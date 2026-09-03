class MonthlySummary {
  final double totalIncome;
  final double totalExpense;
  final double balance;
  final DateTime month;

  const MonthlySummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
    required this.month,
  });

  MonthlySummary copyWith({
    double? totalIncome,
    double? totalExpense,
    double? balance,
    DateTime? month,
  }) {
    return MonthlySummary(
      totalIncome: totalIncome ?? this.totalIncome,
      totalExpense: totalExpense ?? this.totalExpense,
      balance: balance ?? this.balance,
      month: month ?? this.month,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is MonthlySummary &&
      other.totalIncome == totalIncome &&
      other.totalExpense == totalExpense &&
      other.balance == balance &&
      other.month == month;
  }

  @override
  int get hashCode {
    return totalIncome.hashCode ^
      totalExpense.hashCode ^
      balance.hashCode ^
      month.hashCode;
  }
}
