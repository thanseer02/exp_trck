import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../models/transaction.dart';
import '../models/transaction_type.dart';
import '../viewmodels/transaction_viewmodel.dart';
import '../viewmodels/category_viewmodel.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';

class AddEditTransactionView extends StatefulWidget {
  final Transaction? transaction;
  final TransactionType? initialType;

  const AddEditTransactionView({super.key, this.transaction, this.initialType});

  @override
  State<AddEditTransactionView> createState() => _AddEditTransactionViewState();
}

class _AddEditTransactionViewState extends State<AddEditTransactionView> {
  late TransactionType _selectedType;
  String _amountStr = '0';
  int? _selectedCategoryId;
  DateTime _selectedDate = DateTime.now();
  String _note = '';

  @override
  void initState() {
    super.initState();
    _selectedType = widget.initialType ?? TransactionType.expense;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<CategoryViewModel>().loadCategories();
      }
    });

    if (widget.transaction != null) {
      _selectedType = widget.transaction!.type;
      _amountStr = widget.transaction!.amount.toString().replaceAll(RegExp(r'\.0$'), ''); // Remove .0 if whole number
      _selectedCategoryId = widget.transaction!.categoryId;
      _selectedDate = widget.transaction!.date.toLocal();
      _note = widget.transaction!.note ?? '';
    }
  }

  void _onNumpadPressed(String val) {
    setState(() {
      if (val == 'C') {
        _amountStr = '0';
      } else if (val == '⌫') {
        if (_amountStr.length > 1) {
          _amountStr = _amountStr.substring(0, _amountStr.length - 1);
        } else {
          _amountStr = '0';
        }
      } else if (val == '.') {
        if (!_amountStr.contains('.')) {
          _amountStr += '.';
        }
      } else {
        if (_amountStr == '0') {
          _amountStr = val;
        } else {
          // Limit decimals to 2 places
          if (_amountStr.contains('.')) {
            final parts = _amountStr.split('.');
            if (parts.length > 1 && parts[1].length >= 2) return;
          }
          _amountStr += val;
        }
      }
    });
  }

  void _saveTransaction() async {
    final amount = double.tryParse(_amountStr) ?? 0.0;
    if (amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid amount')),
      );
      return;
    }
    
    // Auto-select first category if none selected
    if (_selectedCategoryId == null) {
      final categoryVm = context.read<CategoryViewModel>();
      final categories = _selectedType == TransactionType.income 
          ? categoryVm.incomeCategories 
          : categoryVm.expenseCategories;
          
      if (categories.isNotEmpty) {
        _selectedCategoryId = categories.first.id;
      } else {
         ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please create a category first')),
        );
        return;
      }
    }

    final newTransaction = Transaction(
      id: widget.transaction?.id,
      amount: amount,
      date: _selectedDate.toUtc(),
      note: _note.isNotEmpty ? _note : null,
      categoryId: _selectedCategoryId!,
      type: _selectedType,
    );

    final vm = context.read<TransactionViewModel>();
    
    if (widget.transaction == null) {
      await vm.addTransaction(newTransaction);
    } else {
      await vm.updateTransaction(newTransaction);
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimaryDark, size: 22),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(widget.transaction == null ? 'New Entry' : 'Edit Entry', style: AppStyles.appBarTitle),
        actions: [
          if (widget.transaction != null)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Color(0xFFF87171)),
              onPressed: () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    backgroundColor: AppColors.surfaceDark,
                    title: const Text('Delete Transaction', style: AppStyles.bodyPrimary),
                    content: const Text('Are you sure you want to delete this transaction?', style: AppStyles.bodySecondary),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, false),
                        child: const Text('Cancel', style: AppStyles.bodySecondary),
                      ),
                      TextButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        child: const Text('Delete', style: AppStyles.destructive),
                      ),
                    ],
                  ),
                );
                
                if (confirm == true && mounted) {
                  final vm = context.read<TransactionViewModel>();
                  await vm.deleteTransaction(widget.transaction!.id!);
                  if (mounted) Navigator.pop(context, true);
                }
              },
            )
          else
            TextButton(
              onPressed: () => _onNumpadPressed('C'),
              child: const Text('Clear', style: AppStyles.bodySecondary),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                child: Column(
                  children: [
                    // Type Toggle
                    Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerLowDark,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _TypeToggleBtn(
                            title: 'Expense',
                            isSelected: _selectedType == TransactionType.expense,
                            color: const Color(0xFFF87171),
                            onTap: () => setState(() => _selectedType = TransactionType.expense),
                          ),
                          _TypeToggleBtn(
                            title: 'Income',
                            isSelected: _selectedType == TransactionType.income,
                            color: AppColors.income,
                            onTap: () => setState(() => _selectedType = TransactionType.income),
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Amount Input
                    Text(
                      '\$$_amountStr',
                      style: const TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimaryDark,
                        letterSpacing: -2.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.borderDark),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.credit_card, color: AppColors.textSecondaryDark, size: 14),
                          SizedBox(width: 8),
                          Text('Chase Sapphire...', style: AppStyles.bodySecondary),
                          SizedBox(width: 4),
                          Icon(Icons.keyboard_arrow_down, color: AppColors.textSecondaryDark, size: 14),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 48),
                    
                    // Categories Grid
                    Consumer<CategoryViewModel>(
                      builder: (context, categoryVm, child) {
                        final categories = _selectedType == TransactionType.income
                            ? categoryVm.incomeCategories
                            : categoryVm.expenseCategories;
                            
                        if (categories.isEmpty) {
                          return const Center(child: Text('No categories found', style: AppStyles.bodySecondary));
                        }
                        
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            childAspectRatio: 0.85,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: categories.take(8).length,
                          itemBuilder: (context, index) {
                            final category = categories[index];
                            final isSelected = _selectedCategoryId == category.id;
                            
                            return GestureDetector(
                              onTap: () => setState(() => _selectedCategoryId = category.id),
                              child: Column(
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      color: isSelected ? AppColors.incomeBg : AppColors.surfaceDark,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(
                                        color: isSelected ? AppColors.income : AppColors.borderDark,
                                        width: isSelected ? 1.5 : 1.0,
                                      ),
                                    ),
                                    child: Icon(
                                      _getIconData(category.icon),
                                      color: isSelected ? AppColors.income : AppColors.textSecondaryDark,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    category.name,
                                    style: TextStyle(
                                      color: isSelected ? AppColors.textPrimaryDark : AppColors.textTertiaryDark,
                                      fontSize: 10,
                                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Detail Rows
                    _DetailRow(
                      icon: Icons.calendar_today,
                      label: DateFormat('MMMM d, h:mm a').format(_selectedDate),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2101),
                        );
                        if (date != null && mounted) {
                          final time = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.fromDateTime(_selectedDate),
                          );
                          if (time != null && mounted) {
                            setState(() {
                              _selectedDate = DateTime(date.year, date.month, date.day, time.hour, time.minute);
                            });
                          }
                        }
                      },
                    ),
                    _DetailRow(
                      icon: Icons.receipt_long,
                      label: _note.isEmpty ? 'Add note or receipt...' : _note,
                      valueColor: _note.isEmpty ? AppColors.textTertiaryDark : AppColors.textPrimaryDark,
                      onTap: () async {
                        final textController = TextEditingController(text: _note);
                        await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: AppColors.surfaceDark,
                            title: const Text('Add Note', style: AppStyles.bodyPrimary),
                            content: TextField(
                              controller: textController,
                              style: AppStyles.bodyPrimary,
                              decoration: const InputDecoration(
                                hintText: 'Enter note here...',
                                hintStyle: AppStyles.caption,
                              ),
                              autofocus: true,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () {
                                  setState(() => _note = textController.text);
                                  Navigator.pop(context);
                                },
                                child: const Text('Save'),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            
            // Custom Numpad & Save Button area
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              color: AppColors.backgroundDark,
              child: Column(
                children: [
                  _Numpad(onPressed: _onNumpadPressed),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      onPressed: _saveTransaction,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.backgroundDark,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        widget.transaction == null ? 'Save Transaction' : 'Update Transaction',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
      default: return Icons.category_outlined;
    }
  }
}

class _TypeToggleBtn extends StatelessWidget {
  final String title;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const _TypeToggleBtn({required this.title, required this.isSelected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isSelected ? AppColors.backgroundDark : AppColors.textSecondaryDark,
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? valueColor;
  final VoidCallback onTap;

  const _DetailRow({required this.icon, required this.label, this.valueColor, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondaryDark, size: 20),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: valueColor ?? AppColors.textPrimaryDark,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textTertiaryDark, size: 20),
          ],
        ),
      ),
    );
  }
}

class _Numpad extends StatelessWidget {
  final ValueChanged<String> onPressed;

  const _Numpad({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _NumpadRow(keys: const ['1', '2', '3'], onPressed: onPressed),
        const SizedBox(height: 12),
        _NumpadRow(keys: const ['4', '5', '6'], onPressed: onPressed),
        const SizedBox(height: 12),
        _NumpadRow(keys: const ['7', '8', '9'], onPressed: onPressed),
        const SizedBox(height: 12),
        _NumpadRow(keys: const ['.', '0', '⌫'], onPressed: onPressed),
      ],
    );
  }
}

class _NumpadRow extends StatelessWidget {
  final List<String> keys;
  final ValueChanged<String> onPressed;

  const _NumpadRow({required this.keys, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: keys.map((k) {
        return Expanded(
          child: InkWell(
            onTap: () => onPressed(k),
            borderRadius: BorderRadius.circular(32),
            child: Container(
              height: 56,
              alignment: Alignment.center,
              child: Text(
                k,
                style: const TextStyle(
                  color: AppColors.textPrimaryDark,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
