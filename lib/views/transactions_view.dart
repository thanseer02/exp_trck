import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/transaction_viewmodel.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../models/transaction.dart';
import '../models/transaction_type.dart';
import 'add_edit_transaction_view.dart';
import 'package:intl/intl.dart';

class TransactionsView extends StatefulWidget {
  const TransactionsView({super.key});

  @override
  State<TransactionsView> createState() => _TransactionsViewState();
}

class _TransactionsViewState extends State<TransactionsView> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final vm = context.read<TransactionViewModel>();
    _searchController.text = vm.searchQuery;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      vm.loadTransactions();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showSortOptions(BuildContext context, TransactionViewModel vm) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: TransactionSortOption.values.map((sort) {
            String label;
            switch (sort) {
              case TransactionSortOption.newest: label = 'Newest First'; break;
              case TransactionSortOption.oldest: label = 'Oldest First'; break;
              case TransactionSortOption.highestAmount: label = 'Highest Amount'; break;
              case TransactionSortOption.lowestAmount: label = 'Lowest Amount'; break;
            }
            return ListTile(
              title: Text(label),
              trailing: vm.currentSort == sort ? const Icon(Icons.check) : null,
              onTap: () {
                vm.setSortOption(sort);
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Future<void> _pickDateFilter(BuildContext context, TransactionViewModel vm) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: vm.filterDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      vm.setFilterDate(picked);
    }
  }

  Map<String, List<Transaction>> _groupTransactions(List<Transaction> transactions) {
    final Map<String, List<Transaction>> groups = {};
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));

    for (final tx in transactions) {
      final txDate = DateTime(tx.date.year, tx.date.month, tx.date.day);
      String key;
      if (txDate == today) {
        key = 'Today';
      } else if (txDate == yesterday) {
        key = 'Yesterday';
      } else {
        key = DateFormat.yMMMd().format(txDate);
      }

      if (!groups.containsKey(key)) {
        groups[key] = [];
      }
      groups[key]!.add(tx);
    }
    return groups;
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TransactionViewModel>();
    final filteredTx = vm.filteredTransactions;
    final groupedTx = _groupTransactions(filteredTx);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            onPressed: () => _showSortOptions(context, vm),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search notes...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          vm.setSearchQuery('');
                        },
                      )
                    : null,
              ),
              onChanged: (val) => vm.setSearchQuery(val),
            ),
          ),
          
          // Filters
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: vm.filterType == null,
                  onSelected: (_) => vm.setFilterType(null),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Income'),
                  selected: vm.filterType == TransactionType.income,
                  onSelected: (_) => vm.setFilterType(TransactionType.income),
                ),
                const SizedBox(width: 8),
                FilterChip(
                  label: const Text('Expense'),
                  selected: vm.filterType == TransactionType.expense,
                  onSelected: (_) => vm.setFilterType(TransactionType.expense),
                ),
                const SizedBox(width: 8),
                ActionChip(
                  label: Text(vm.filterDate != null ? DateFormat.yMMMd().format(vm.filterDate!) : 'Date'),
                  avatar: const Icon(Icons.calendar_today, size: 16),
                  onPressed: () => _pickDateFilter(context, vm),
                ),
                if (vm.filterDate != null || vm.filterType != null || _searchController.text.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  ActionChip(
                    label: const Text('Clear All'),
                    avatar: const Icon(Icons.clear, size: 16),
                    onPressed: () {
                      _searchController.clear();
                      vm.clearFilters();
                    },
                  ),
                ]
              ],
            ),
          ),
          const Divider(),

          // Transactions List
          Expanded(
            child: vm.isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredTx.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_long, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 16),
                            const Text('No transactions found.', style: TextStyle(fontSize: 18, color: Colors.grey)),
                            const SizedBox(height: 8),
                            const Text('Tap + to add your first transaction.', style: TextStyle(color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: groupedTx.length,
                        itemBuilder: (context, index) {
                          final key = groupedTx.keys.elementAt(index);
                          final transactions = groupedTx[key]!;
                          
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
                                child: Text(
                                  key,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey),
                                ),
                              ),
                              ...transactions.map((tx) {
                                final isIncome = tx.type == TransactionType.income;
                                return ListTile(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => AddEditTransactionView(transaction: tx),
                                      ),
                                    );
                                  },
                                  leading: CircleAvatar(
                                    backgroundColor: isIncome ? Colors.green.shade100 : Colors.red.shade100,
                                    child: Icon(
                                      isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                                      color: isIncome ? Colors.green : Colors.red,
                                    ),
                                  ),
                                  title: Text(tx.note != null && tx.note!.isNotEmpty ? tx.note! : tx.type.name.toUpperCase()),
                                  subtitle: Text(tx.date.toLocal().toString().split(' ')[0]),
                                  trailing: Text(
                                    '${isIncome ? '+' : '-'}${context.read<SettingsViewModel>().currencySymbol}${tx.amount.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isIncome ? Colors.green : Colors.red,
                                      fontSize: 16,
                                    ),
                                  ),
                                );
                              }),
                            ],
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
