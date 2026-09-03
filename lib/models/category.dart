import 'transaction_type.dart';

class Category {
  final int? id;
  final String name;
  final String icon;
  final TransactionType type;
  final bool isDefault;
  final DateTime? createdAt;

  const Category({
    this.id,
    required this.name,
    required this.icon,
    required this.type,
    this.isDefault = false,
    this.createdAt,
  });

  Category copyWith({
    int? id,
    String? name,
    String? icon,
    TransactionType? type,
    bool? isDefault,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      name: name ?? this.name,
      icon: icon ?? this.icon,
      type: type ?? this.type,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Category &&
      other.id == id &&
      other.name == name &&
      other.icon == icon &&
      other.type == type &&
      other.isDefault == isDefault &&
      other.createdAt == createdAt;
  }

  @override
  int get hashCode {
    return id.hashCode ^
      name.hashCode ^
      icon.hashCode ^
      type.hashCode ^
      isDefault.hashCode ^
      createdAt.hashCode;
  }
}
