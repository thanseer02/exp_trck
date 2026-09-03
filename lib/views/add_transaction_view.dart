import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/transaction.dart';
import '../models/transaction_type.dart';
import '../models/category.dart';
import '../repositories/category_repository.dart';
import '../viewmodels/transaction_viewmodel.dart';

class AddTransactionView extends StatefulWidget {
  const AddTransactionView({super.key});

  @override
  State<AddTransactionView> createState() => _AddTransactionViewState();
}

class _AddTransactionViewState extends State<AddTransactionView> {
  final _formKey = GlobalKey<FormState>();
  
  TransactionType _selectedType = TransactionType.expense;
  double? _amount;
  Category? _selectedCategory;
  DateTime _selectedDate = DateTime.now();
  String? _note;
  
  List<Category> _categories = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    try {
      final repository = context.read<CategoryRepository>();
      final allCategories = await repository.getCategories();
      
      if (mounted) {
        setState(() {
          _categories = allCategories.where((c) => c.type == _selectedType).toList();
          if (_categories.isNotEmpty) {
            _selectedCategory = _categories.first;
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load categories.')),
        );
      }
    }
  }

  void _onTypeChanged(TransactionType type) {
    setState(() {
      _selectedType = type;
      _isLoading = true;
    });
    _loadCategories();
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

    final transaction = Transaction(
      type: _selectedType,
      amount: _amount!,
      categoryId: _selectedCategory!.id!,
      date: _selectedDate,
      note: _note,
    );

    try {
      await context.read<TransactionViewModel>().addTransaction(transaction);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Transaction added successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error adding transaction: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Transaction'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
                      decoration: const InputDecoration(
                        labelText: 'Amount',
                        prefixText: '\$ ',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                        return null;
                      },
                      onSaved: (value) {
                        _amount = double.parse(value!);
                      },
                    ),
                    const SizedBox(height: 16),
                    FormField<Category>(
                      validator: (value) => _selectedCategory == null ? 'Please select a category' : null,
                      builder: (FormFieldState<Category> state) {
                        return InputDecorator(
                          decoration: InputDecoration(
                            labelText: 'Category',
                            border: const OutlineInputBorder(),
                            errorText: state.errorText,
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<Category>(
                              value: _selectedCategory,
                              isDense: true,
                              items: _categories.map((Category category) {
                                return DropdownMenuItem<Category>(
                                  value: category,
                                  child: Text(category.name),
                                );
                              }).toList(),
                              onChanged: (Category? newValue) {
                                setState(() {
                                  _selectedCategory = newValue;
                                });
                                state.didChange(newValue);
                              },
                            ),
                          ),
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
                      decoration: const InputDecoration(
                        labelText: 'Note (Optional)',
                        border: OutlineInputBorder(),
                      ),
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
    );
  }
}
