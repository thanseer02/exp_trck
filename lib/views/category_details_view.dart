import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/category.dart';
import '../models/transaction_type.dart';
import '../viewmodels/transaction_viewmodel.dart';
import 'add_edit_transaction_view.dart';
import 'package:intl/intl.dart';

class CategoryDetailsView extends StatelessWidget {
  final Category category;
  final DateTime month;

  const CategoryDetailsView({
    super.key,
    required this.category,
    required this.month,
  });

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

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<TransactionViewModel>();
    
    // Filter transactions by category and month
    final categoryTransactions = vm.transactions.where((tx) {
      return tx.categoryId == category.id &&
             tx.date.year == month.year &&
             tx.date.month == month.month;
    }).toList();
    
    // Sort newest first
    categoryTransactions.sort((a, b) => b.date.compareTo(a.date));

    // Calculate stats
    final totalSpent = categoryTransactions.fold(0.0, (sum, tx) => sum + tx.amount);
    final txCount = categoryTransactions.length;
    final avgTx = txCount > 0 ? totalSpent / txCount : 0.0;
    
    final isIncome = category.type == TransactionType.income;
    final color = isIncome ? Colors.green : Colors.red;

    return Scaffold(
      appBar: AppBar(
        title: Text(category.name),
      ),
      body: Column(
        children: [
          // Header Stats
          Container(
            padding: const EdgeInsets.all(24.0),
            color: color.withValues(alpha: 0.05),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: color.withValues(alpha: 0.1),
                  child: Icon(_getIconData(category.icon), color: color, size: 32),
                ),
                const SizedBox(height: 16),
                Text(
                  DateFormat.yMMMM().format(month),
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Text(
                  '\$${totalSpent.toStringAsFixed(2)}',
                  style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: color),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildStatCol('Transactions', '$txCount'),
                    Container(height: 30, width: 1, color: Colors.grey.shade300),
                    _buildStatCol('Avg Transaction', '\$${avgTx.toStringAsFixed(2)}'),
                  ],
                ),
              ],
            ),
          ),
          
          // Transactions List
          Expanded(
            child: categoryTransactions.isEmpty
                ? const Center(child: Text('No transactions found.'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16.0),
                    itemCount: categoryTransactions.length,
                    itemBuilder: (context, index) {
                      final tx = categoryTransactions[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8.0),
                        child: ListTile(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AddEditTransactionView(transaction: tx),
                              ),
                            );
                          },
                          leading: CircleAvatar(
                            backgroundColor: color.withValues(alpha: 0.1),
                            child: Icon(
                              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                              color: color,
                            ),
                          ),
                          title: Text(tx.note != null && tx.note!.isNotEmpty ? tx.note! : category.name),
                          subtitle: Text(DateFormat.yMMMd().format(tx.date.toLocal())),
                          trailing: Text(
                            '${isIncome ? '+' : '-'}\$${tx.amount.toStringAsFixed(2)}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: color,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCol(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
