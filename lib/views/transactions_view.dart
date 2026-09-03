import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../viewmodels/transaction_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../viewmodels/category_viewmodel.dart';
import '../models/transaction.dart';
import '../models/transaction_type.dart';
import '../models/category.dart';
import '../theme/app_colors.dart';
import '../theme/app_styles.dart';
import '../routes/app_routes.dart';

class TransactionsView extends StatefulWidget {
  const TransactionsView({super.key});

  @override
  State<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<TransactionsView> {
  /// Initializes the state by scheduling a callback to load
  /// transactions and categories after the first frame is rendered.
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TransactionViewModel>().loadTransactions();
        context.read<CategoryViewModel>().loadCategories();
      }
    });
  }

  /// Builds the main screen of the transactions view, containing an app bar,
  /// a floating action button to add a transaction, and the transaction list.
  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TransactionViewModel>();
    final isLoading = vm.isLoading;

    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.backgroundDark,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: AppColors.textPrimaryDark,
            size: 22,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Ledger', style: AppStyles.appBarTitle),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary, // Green FlowLedger action
        onPressed: () async {
          final result = await Navigator.pushNamed(
            context,
            AppRoutes.addEditTransaction,
          );
          if (result == true && mounted) {
            context.read<TransactionViewModel>().loadTransactions();
          }
        },
        child: const Icon(Icons.add, color: AppColors.backgroundDark),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.income),
              )
            : RefreshIndicator(
                onRefresh: () => vm.loadTransactions(),
                color: AppColors.income,
                backgroundColor: AppColors.surfaceDark,
                child: Column(
                  children: [
                    _FilterChipsSection(vm: vm),
                    Expanded(
                      child: vm.transactions.isEmpty
                          ? _buildEmptyState()
                          : _buildTransactionList(vm),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  /// Builds the widget to display when there are no transactions available.
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.receipt_long,
            size: 64,
            color: AppColors.surfaceContainerHighDark,
          ),
          const SizedBox(height: 16),
          Text('No transactions found.', style: AppStyles.bodySecondary),
        ],
      ),
    );
  }

  /// Builds a grouped list of transactions, sorted by date in descending order.
  Widget _buildTransactionList(TransactionViewModel vm) {
    // Group transactions by date
    final groupedTransactions = <String, List<Transaction>>{};

    for (var tx in vm.transactions) {
      final dateKey = DateFormat('yyyy-MM-dd').format(tx.date.toLocal());
      if (!groupedTransactions.containsKey(dateKey)) {
        groupedTransactions[dateKey] = [];
      }
      groupedTransactions[dateKey]!.add(tx);
    }

    final sortedKeys = groupedTransactions.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      itemCount: sortedKeys.length,
      itemBuilder: (context, index) {
        final dateKey = sortedKeys[index];
        final transactionsForDate = groupedTransactions[dateKey]!;
        final date = DateTime.parse(dateKey);

        final now = DateTime.now();
        final isToday =
            date.year == now.year &&
            date.month == now.month &&
            date.day == now.day;
        final isYesterday =
            date.year == now.year &&
            date.month == now.month &&
            date.day == now.day - 1;

        String displayDate = DateFormat('MMMM d, yyyy').format(date);
        if (isToday)
          displayDate = 'TODAY';
        else if (isYesterday)
          displayDate = 'YESTERDAY';
        else
          displayDate = displayDate.toUpperCase();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Text(displayDate, style: AppStyles.sectionHeader),
            ),
            ...transactionsForDate
                .map((tx) => _TransactionTile(tx: tx, vm: vm))
                .toList(),
          ],
        );
      },
    );
  }
}

class _FilterChipsSection extends StatelessWidget {
  final TransactionViewModel vm;

  const _FilterChipsSection({required this.vm});

  /// Builds a horizontal scrollable row of filter chips.
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          _buildFilterChip('All', null, vm),
          const SizedBox(width: 8),
          _buildFilterChip('Income', TransactionType.income, vm),
          const SizedBox(width: 8),
          _buildFilterChip('Expense', TransactionType.expense, vm),
        ],
      ),
    );
  }

  /// Builds a single filter chip for a specific transaction type.
  Widget _buildFilterChip(
    String label,
    TransactionType? type,
    TransactionViewModel vm,
  ) {
    final isSelected = vm.filterType == type;
    return GestureDetector(
      onTap: () {
        vm.setFilterType(type);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.textPrimaryDark : AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? AppColors.textPrimaryDark
                : AppColors.borderDark,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected
                ? AppColors.backgroundDark
                : AppColors.textSecondaryDark,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  final Transaction tx;
  final TransactionViewModel vm;

  const _TransactionTile({required this.tx, required this.vm});

  /// Maps a string icon name to the corresponding [IconData] object.
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
        return Icons.category_outlined;
    }
  }

  /// Builds a single transaction list tile with swipe-to-delete functionality
  /// and tap-to-edit behavior.
  @override
  Widget build(BuildContext context) {
    final isIncome = tx.type == TransactionType.income;
    final categoryVm = context.read<CategoryViewModel>();
    final categories = isIncome
        ? categoryVm.incomeCategories
        : categoryVm.expenseCategories;
    final category = categories.firstWhere(
      (c) => c.id == tx.categoryId,
      orElse: () =>
          Category(id: -1, name: 'Unknown', icon: 'category', type: tx.type),
    );

    return Dismissible(
      key: Key(tx.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        color: const Color(0xFFF87171),
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24.0),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: AppColors.surfaceDark,
            title: const Text(
              'Delete Transaction',
              style: AppStyles.bodyPrimary,
            ),
            content: const Text(
              'Are you sure you want to delete this transaction?',
              style: AppStyles.bodySecondary,
            ),
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
      },
      onDismissed: (direction) {
        vm.deleteTransaction(tx.id!);
      },
      child: InkWell(
        onTap: () async {
          final result = await Navigator.pushNamed(
            context,
            AppRoutes.addEditTransaction,
            arguments: {'transaction': tx},
          );
          if (result == true) {
            vm.loadTransactions();
          }
        },
        child: Padding(
          padding: const EdgeInsets.only(bottom: 24.0, left: 24.0, right: 24.0),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.surfaceContainerLowDark,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _getIconData(category.icon),
                  color: AppColors.textSecondaryDark,
                  size: 18,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tx.note != null && tx.note!.isNotEmpty
                          ? tx.note!
                          : category.name,
                      style: AppStyles.bodyPrimary,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${category.name} • ${DateFormat('h:mm a').format(tx.date.toLocal())}',
                      style: AppStyles.caption,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${isIncome ? '+' : '-'}${context.read<SettingsViewModel>().formatAmount(tx.amount)}',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isIncome
                          ? AppColors.income
                          : const Color(0xFFF87171),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isIncome ? 'CLEARED' : 'CARD',
                    style: const TextStyle(
                      fontSize: 8,
                      color: AppColors.textTertiaryDark,
                      letterSpacing: 1.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
