import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/transaction_viewmodel.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({super.key});

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<TransactionViewModel>().loadTransactions();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<TransactionViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: viewModel.transactions.isEmpty
          ? const Center(child: Text('No transactions yet.'))
          : ListView.builder(
              itemCount: viewModel.transactions.length,
              itemBuilder: (context, index) {
                final transaction = viewModel.transactions[index];
                return ListTile(
                  title: Text(transaction.note ?? transaction.type),
                  subtitle: Text(transaction.date.toString()),
                  trailing: Text('\$${transaction.amount.toStringAsFixed(2)}'),
                );
              },
            ),
    );
  }
}
