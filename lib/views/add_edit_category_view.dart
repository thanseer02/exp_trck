import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../models/transaction_type.dart';
import '../viewmodels/category_viewmodel.dart';

class AddEditCategoryView extends StatefulWidget {
  final Category? category;
  const AddEditCategoryView({super.key, this.category});

  @override
  State<AddEditCategoryView> createState() => _AddEditCategoryViewState();
}

class _AddEditCategoryViewState extends State<AddEditCategoryView> {
  final _formKey = GlobalKey<FormState>();

  late TransactionType _selectedType;
  String? _name;
  late String _selectedIcon;

  final List<String> _availableIcons = [
    'category',
    'restaurant',
    'directions_car',
    'shopping_cart',
    'receipt',
    'home',
    'movie',
    'local_hospital',
    'school',
    'flight',
    'local_grocery_store',
    'subscriptions',
    'attach_money',
    'work',
    'business',
    'card_giftcard',
  ];

  @override
  void initState() {
    super.initState();
    final cat = widget.category;
    if (cat != null) {
      _selectedType = cat.type;
      _name = cat.name;
      _selectedIcon = cat.icon;
    } else {
      _selectedType = TransactionType.expense;
      _selectedIcon = 'category';
    }
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'restaurant':
        return Icons.restaurant;
      case 'directions_car':
        return Icons.directions_car;
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'receipt':
        return Icons.receipt;
      case 'home':
        return Icons.home;
      case 'movie':
        return Icons.movie;
      case 'local_hospital':
        return Icons.local_hospital;
      case 'school':
        return Icons.school;
      case 'flight':
        return Icons.flight;
      case 'local_grocery_store':
        return Icons.local_grocery_store;
      case 'subscriptions':
        return Icons.subscriptions;
      case 'attach_money':
        return Icons.attach_money;
      case 'work':
        return Icons.work;
      case 'business':
        return Icons.business;
      case 'card_giftcard':
        return Icons.card_giftcard;
      case 'category':
      default:
        return Icons.category;
    }
  }

  Future<void> _deleteCategory() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Category'),
        content: const Text('Are you sure you want to delete this category?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted && widget.category?.id != null) {
      try {
        final success = await context.read<CategoryViewModel>().deleteCategory(
          widget.category!.id!,
        );
        if (mounted) {
          if (success) {
            Navigator.pop(context);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Category deleted successfully!')),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Cannot delete category in use by existing transactions.',
                ),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting category: $e')),
          );
        }
      }
    }
  }

  Future<void> _saveCategory() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    _formKey.currentState!.save();

    final isEdit = widget.category != null;
    final category = Category(
      id: isEdit ? widget.category!.id : null,
      name: _name!,
      icon: _selectedIcon,
      type: _selectedType,
      isDefault: isEdit ? widget.category!.isDefault : false,
      createdAt: isEdit ? widget.category!.createdAt : DateTime.now(),
    );

    try {
      if (isEdit) {
        await context.read<CategoryViewModel>().updateCategory(category);
      } else {
        await context.read<CategoryViewModel>().addCategory(category);
      }

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(isEdit ? 'Category updated!' : 'Category added!'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error saving category: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.category != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Category' : 'Add Category'),
        actions: [
          if (isEdit && !widget.category!.isDefault)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteCategory,
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              if (!isEdit) ...[
                SegmentedButton<TransactionType>(
                  segments: const [
                    ButtonSegment(
                      value: TransactionType.expense,
                      label: Text('Expense'),
                    ),
                    ButtonSegment(
                      value: TransactionType.income,
                      label: Text('Income'),
                    ),
                  ],
                  selected: {_selectedType},
                  onSelectionChanged: (Set<TransactionType> selection) {
                    setState(() {
                      _selectedType = selection.first;
                    });
                  },
                ),
                const SizedBox(height: 24),
              ],
              TextFormField(
                initialValue: _name,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a name';
                  }
                  return null;
                },
                onSaved: (value) => _name = value!.trim(),
              ),
              const SizedBox(height: 24),
              const Text(
                'Select Icon',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4,
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                ),
                itemCount: _availableIcons.length,
                itemBuilder: (context, index) {
                  final iconName = _availableIcons[index];
                  final isSelected = iconName == _selectedIcon;
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedIcon = iconName;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.deepPurple.withValues(alpha: 0.2)
                            : Colors.grey.shade100,
                        border: Border.all(
                          color: isSelected
                              ? Colors.deepPurple
                              : Colors.transparent,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        _getIconData(iconName),
                        color: isSelected
                            ? Colors.deepPurple
                            : Colors.grey.shade600,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: _saveCategory,
                child: const Text(
                  'Save Category',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
