class AppCategory {
  final int? id;
  final String name;
  final String icon;
  final String type; // 'income' or 'expense'
  final bool isDefault;
  final DateTime? createdAt;

  AppCategory({
    this.id,
    required this.name,
    required this.icon,
    required this.type,
    this.isDefault = false,
    this.createdAt,
  });
}
