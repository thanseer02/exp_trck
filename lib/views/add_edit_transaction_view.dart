import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../models/transaction_type.dart';
import '../models/category.dart';
import '../viewmodels/category_viewmodel.dart';
import '../viewmodels/transaction_viewmodel.dart';

class AddEditTransactionView extends StatefulWidget {
  final Transaction? transaction;
  const AddEditTransactionView({super.key, this.transaction});

  @override
  State<AddEditTransactionView> createState() => _AddEditTransactionViewState();
}

class _AddEditTransactionViewState extends State<AddEditTransactionView> {
  final _formKey = GlobalKey<FormState>();
  
  late TransactionType _selectedType;
  double? _amount;
  Category? _selectedCategory;
  late DateTime _selectedDate;
  String? _note;
  
  @override
  void initState() {
    super.initState();
    final tx = widget.transaction;
    if (tx != null) {
      _selectedType = tx.type;
      _amount = tx.amount;
      _selectedDate = tx.date;
      _note = tx.note;
    } else {
      _selectedType = TransactionType.expense;
      _selectedDate = DateTime.now();
    }
  }

  void _onTypeChanged(TransactionType type) {
    setState(() {
      _selectedType = type;
      _selectedCategory = null;
    });
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'restaurant': return Icons.restaurant;
      case 'directions_car': return Icons.directions_car;
      case 'shopping_cart': return Icons.shopping_cart;
      case 'receipt': return Icons.receipt;
      case 'home': return Icons.home;
      case 'movie': return Icons.movie;
      case 'local_hospital': return Icons.local_hospital;
      case 'school': return Icons.school;
      case 'flight': return Icons.flight;
      case 'local_grocery_store': return Icons.local_grocery_store;
      case 'subscriptions': return Icons.subscriptions;
      case 'attach_money': return Icons.attach_money;
      case 'work': return Icons.work;
      case 'business': return Icons.business;
      case 'card_giftcard': return Icons.card_giftcard;
      case 'category': 
      default: return Icons.category;
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _deleteTransaction() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Transaction'),
        content: const Text('Are you sure you want to delete this transaction?'),
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

    if (confirm == true && mounted && widget.transaction?.id != null) {
      try {
        await context.read<TransactionViewModel>().deleteTransaction(widget.transaction!.id!);
        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Transaction deleted successfully!')),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting transaction: $e')),
          );
        }
      }
    }
  }

  Future<void> _saveTransaction() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    
    if (_selectedCategory == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a category')),
      );
      return;
    }

    _formKey.currentState!.save();

    final isEdit = widget.transaction != null;
    final transaction = Transaction(
      id: isEdit ? widget.transaction!.id : null,
      type: _selectedType,
      amount: _amount!,
      categoryId: _selectedCategory!.id!,
      date: _selectedDate,
      note: _note,
      createdAt: isEdit ? widget.transaction!.createdAt : null,
    );

    try {
      if (isEdit) {
        await context.read<TransactionViewModel>().updateTransaction(transaction);
      } else {
        await context.read<TransactionViewModel>().addTransaction(transaction);
      }
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(isEdit ? 'Transaction updated!' : 'Transaction added!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving transaction: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final catVM = context.watch<CategoryViewModel>();
    final isEdit = widget.transaction != null;
    
    List<Category> categories = _selectedType == TransactionType.expense 
        ? catVM.expenseCategories 
        : catVM.incomeCategories;
        
    if (!catVM.isLoading && categories.isNotEmpty) {
      if (_selectedCategory == null) {
        if (isEdit) {
          try {
            _selectedCategory = categories.firstWhere((c) => c.id == widget.transaction!.categoryId);
          } catch (_) {
            _selectedCategory = categories.first;
          }
        } else {
          _selectedCategory = categories.first;
        }
      } else if (!categories.any((c) => c.id == _selectedCategory!.id)) {
        _selectedCategory = categories.first;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Transaction' : 'Add Transaction'),
        actions: [
          if (isEdit)
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _deleteTransaction,
            ),
        ],
      ),
      body: catVM.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 600),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView(
                  children: [
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
                        _onTypeChanged(selection.first);
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _amount?.toString(),
                      decoration: InputDecoration(
                        labelText: 'Amount',
                        prefixText: '${context.read<SettingsViewModel>().currencySymbol} ',
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      autofocus: true,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter an amount';
                        }
                        final amount = double.tryParse(value);
                        if (amount == null) {
                          return 'Please enter a valid number';
                        }
                        if (amount <= 0) {
                          return 'Amount must be greater than 0';
                        }
                        if (amount > 1000000000) {
                          return 'Amount is too large';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _amount = double.parse(value!);
                      },
                    ),
                    const SizedBox(height: 16),
                    const SizedBox(height: 16),
                    const Text('Category', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    FormField<Category>(
                      validator: (value) => _selectedCategory == null ? 'Please select a category' : null,
                      builder: (FormFieldState<Category> state) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 8.0,
                              runSpacing: 8.0,
                              children: categories.map((Category category) {
                                final isSelected = _selectedCategory?.id == category.id;
                                return ChoiceChip(
                                  label: Text(category.name),
                                  avatar: Icon(_getIconData(category.icon), size: 18, color: isSelected ? Colors.white : Colors.deepPurple),
                                  selected: isSelected,
                                  selectedColor: Colors.deepPurple,
                                  labelStyle: TextStyle(color: isSelected ? Colors.white : Colors.black87),
                                  onSelected: (bool selected) {
                                    setState(() {
                                      _selectedCategory = category;
                                    });
                                    state.didChange(category);
                                  },
                                );
                              }).toList(),
                            ),
                            if (state.hasError)
                              Padding(
                                padding: const EdgeInsets.only(top: 8.0, left: 12.0),
                                child: Text(state.errorText!, style: const TextStyle(color: Colors.red, fontSize: 12)),
                              ),
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    ListTile(
                      shape: RoundedRectangleBorder(
                        side: const BorderSide(color: Colors.grey, width: 1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      title: Text('Date: ${_selectedDate.toLocal().toString().split(' ')[0]}'),
                      trailing: const Icon(Icons.calendar_today),
                      onTap: () => _selectDate(context),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: _note,
                      decoration: const InputDecoration(
                        labelText: 'Note (Optional)',
                        border: OutlineInputBorder(),
                      ),
                      textInputAction: TextInputAction.done,
                      onFieldSubmitted: (_) => _saveTransaction(),
                      onSaved: (value) {
                        _note = value;
                      },
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _saveTransaction,
                      child: const Text('Save', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
               ),
              ),
             ),
            ),
          ),
    );
  }
}
