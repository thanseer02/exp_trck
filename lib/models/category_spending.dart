import 'category.dart';

class CategorySpending {
  final Category category;
  final double totalAmount;

  const CategorySpending({required this.category, required this.totalAmount});

  CategorySpending copyWith({Category? category, double? totalAmount}) {
    return CategorySpending(
      category: category ?? this.category,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is CategorySpending &&
        other.category == category &&
        other.totalAmount == totalAmount;
  }

  @override
  int get hashCode => category.hashCode ^ totalAmount.hashCode;
}
