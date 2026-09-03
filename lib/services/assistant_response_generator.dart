import 'package:intl/intl.dart';
import '../models/assistant_response.dart';
import '../models/assistant_intent.dart';
import '../models/category.dart';
import '../models/transaction.dart';
import '../routes/app_routes.dart';

import '../models/assistant_query.dart';

class AssistantResponseGenerator {
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

  AssistantResponse generateResponse(AssistantQuery query, dynamic data) {
    final intent = query.intent;
    String message = '';
    AssistantResponseType type = AssistantResponseType.text;
    
    switch (intent) {
      case AssistantIntent.balance:
        final balance = (data as double?) ?? 0.0;
        message = 'Your current balance is ${_currencyFormat.format(balance)}.';
        type = AssistantResponseType.amount;
        return AssistantResponse(message: message, type: type, amount: balance);

      case AssistantIntent.totalExpense:
      case AssistantIntent.monthlyExpense:
      case AssistantIntent.dailyExpense:
        final expense = (data as double?) ?? 0.0;
        String period = intent == AssistantIntent.monthlyExpense ? 'for this period' : (intent == AssistantIntent.dailyExpense ? 'today' : 'recently');
        message = 'You spent ${_currencyFormat.format(expense)} $period.';
        type = AssistantResponseType.amount;
        return AssistantResponse(message: message, type: type, amount: expense);

      case AssistantIntent.totalIncome:
      case AssistantIntent.monthlyIncome:
        final income = (data as double?) ?? 0.0;
        String period = intent == AssistantIntent.monthlyIncome ? 'for this period' : 'recently';
        message = 'You earned ${_currencyFormat.format(income)} $period.';
        type = AssistantResponseType.amount;
        return AssistantResponse(message: message, type: type, amount: income);

      case AssistantIntent.topSpendingCategory:
        if (data == null) {
          return AssistantResponse(message: "You haven't spent anything recently.");
        }
        final categoryName = data['name'] as String;
        final amount = data['amount'] as double;
        final total = data['total'] as double;
        final percentage = total > 0 ? (amount / total * 100) : 0.0;
        final category = data['category'] as Category?;
        
        message = '$categoryName is your biggest expense for this period. You spent ${_currencyFormat.format(amount)}, which is ${percentage.toStringAsFixed(0)}% of your total spending.';
        
        return AssistantResponse(
          message: message, 
          type: AssistantResponseType.category, 
          amount: amount, 
          categoryName: categoryName, 
          percentage: percentage,
          category: category,
          actionLabel: 'View $categoryName',
          actionRoute: category != null ? AppRoutes.categoryDetails : null,
          actionArguments: category != null ? {
            'category': category,
            'month': DateTime(DateTime.now().year, DateTime.now().month, 1),
          } : null,
        );

      case AssistantIntent.categoryExpense:
        if (data == null) {
          return AssistantResponse(message: "I couldn't find spending for that category.");
        }
        final catName = data['name'] as String;
        final catAmount = data['amount'] as double;
        message = 'You spent ${_currencyFormat.format(catAmount)} on $catName for this period.';
        return AssistantResponse(
          message: message, 
          type: AssistantResponseType.category, 
          amount: catAmount, 
          categoryName: catName
        );

      case AssistantIntent.largestExpense:
        if (data == null) {
          return AssistantResponse(message: "You don't have any recorded expenses.");
        }
        final mapData = data as Map<String, dynamic>;
        final transaction = mapData['transaction'] as Transaction;
        final categoryName = mapData['categoryName'] as String;
        final amount = transaction.amount;
        
        message = 'Your biggest expense was ${_currencyFormat.format(amount)} on $categoryName.';
        return AssistantResponse(
          message: message, 
          type: AssistantResponseType.amount, 
          amount: amount,
          categoryName: categoryName,
          transaction: transaction,
          actionLabel: 'View Transaction',
          actionRoute: AppRoutes.addEditTransaction,
          actionArguments: {
            'transaction': transaction,
          },
        );

      case AssistantIntent.averageExpense:
        final amount = (data as double?) ?? 0.0;
        message = 'Your average expense is ${_currencyFormat.format(amount)}.';
        return AssistantResponse(message: message, type: AssistantResponseType.amount, amount: amount);

      case AssistantIntent.recentTransactions:
        if (data == null || (data as List).isEmpty) {
          return AssistantResponse(message: 'No recent transactions found.');
        }
        message = 'Here are your recent transactions:';
        return AssistantResponse(
          message: message, 
          type: AssistantResponseType.transactionList,
          transactions: (data as List).cast<Transaction>(),
        );

      case AssistantIntent.monthlyComparison:
        if (data == null) {
          return AssistantResponse(message: "I don't have enough data to compare.");
        }
        final currentMonth = data['current'] as double;
        final lastMonth = data['last'] as double;
        final diff = currentMonth - lastMonth;
        
        if (diff > 0) {
          message = 'Yes. You spent ${_currencyFormat.format(diff)} more than last month.';
        } else if (diff < 0) {
          message = 'No. You spent ${_currencyFormat.format(diff.abs())} less than last month.';
        } else {
          message = 'You spent exactly the same as last month.';
        }
        return AssistantResponse(
          message: message, 
          type: AssistantResponseType.comparison, 
          amount: currentMonth,
          lastAmount: lastMonth,
          comparisonAmount: diff
        );

      case AssistantIntent.help:
        message = 'I can help you track your finances! Try asking:\\n- What is my balance?\\n- Where did I spend the most?\\n- Did I spend more than last month?';
        return AssistantResponse(
          message: message,
          type: AssistantResponseType.actionButton,
          actionLabel: 'View Dashboard',
          actionRoute: AppRoutes.dashboard
        );

      case AssistantIntent.unknown:
      default:
        message = 'I am not sure how to answer that yet. Try asking about your balance or recent expenses.';
        return AssistantResponse(message: message);
    }
  }
}
