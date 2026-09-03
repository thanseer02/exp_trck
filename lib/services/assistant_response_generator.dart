import 'package:intl/intl.dart';
import '../models/assistant_response.dart';
import '../models/assistant_intent.dart';

class AssistantResponseGenerator {
  final NumberFormat _currencyFormat = NumberFormat.currency(symbol: '₹', decimalDigits: 0);

  AssistantResponse generateResponse(AssistantIntent intent, dynamic data) {
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
        String period = intent == AssistantIntent.monthlyExpense ? 'this month' : (intent == AssistantIntent.dailyExpense ? 'today' : 'recently');
        message = 'You spent ${_currencyFormat.format(expense)} $period.';
        type = AssistantResponseType.amount;
        return AssistantResponse(message: message, type: type, amount: expense);

      case AssistantIntent.totalIncome:
      case AssistantIntent.monthlyIncome:
        final income = (data as double?) ?? 0.0;
        String period = intent == AssistantIntent.monthlyIncome ? 'this month' : 'recently';
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
        
        message = '$categoryName is your biggest expense this month. You spent ${_currencyFormat.format(amount)}, which is ${percentage.toStringAsFixed(0)}% of your total spending.';
        return AssistantResponse(
          message: message, 
          type: AssistantResponseType.category, 
          amount: amount, 
          category: categoryName, 
          percentage: percentage
        );

      case AssistantIntent.categoryExpense:
        if (data == null) {
          return AssistantResponse(message: "I couldn't find spending for that category.");
        }
        final categoryName = data['name'] as String;
        final amount = data['amount'] as double;
        message = 'You spent ${_currencyFormat.format(amount)} on $categoryName this month.';
        return AssistantResponse(
          message: message, 
          type: AssistantResponseType.category, 
          amount: amount, 
          category: categoryName
        );

      case AssistantIntent.largestExpense:
        if (data == null || (data['amount'] as double) == 0) {
          return AssistantResponse(message: "You don't have any recorded expenses.");
        }
        final amount = data['amount'] as double;
        final categoryName = (data['category'] as String?) ?? 'General';
        message = 'Your biggest expense was ${_currencyFormat.format(amount)} on $categoryName.';
        return AssistantResponse(
          message: message, 
          type: AssistantResponseType.amount, 
          amount: amount,
          category: categoryName
        );

      case AssistantIntent.averageExpense:
        final amount = (data as double?) ?? 0.0;
        message = 'Your average expense is ${_currencyFormat.format(amount)}.';
        return AssistantResponse(message: message, type: AssistantResponseType.amount, amount: amount);

      case AssistantIntent.recentTransactions:
        if (data == null || (data as List).isEmpty) {
          return AssistantResponse(message: 'No recent transactions found.');
        }
        // Fallback text rendering if UI doesn't handle transactionList type
        message = 'Here are your recent transactions:';
        return AssistantResponse(
          message: message, 
          type: AssistantResponseType.transactionList,
          transactions: data as List<dynamic>
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
          comparisonAmount: diff
        );

      case AssistantIntent.help:
        message = 'I can help you track your finances! Try asking:\\n- What is my balance?\\n- Where did I spend the most?\\n- Did I spend more than last month?';
        return AssistantResponse(
          message: message,
          type: AssistantResponseType.actionButton,
          actionLabel: 'View Dashboard',
          actionRoute: '/dashboard'
        );

      case AssistantIntent.unknown:
      default:
        message = 'I am not sure how to answer that yet. Try asking about your balance or recent expenses.';
        return AssistantResponse(message: message);
    }
  }
}
