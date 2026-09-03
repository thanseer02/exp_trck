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

      case AssistantIntent.transactionCount:
        final count = (data as int?) ?? 0;
        message = 'You made $count transactions for this period.';
        return AssistantResponse(message: message);

      case AssistantIntent.mostExpensiveDay:
        if (data == null) {
          return AssistantResponse(message: "You haven't spent anything recently.");
        }
        final date = data['date'] as DateTime;
        final amt = data['amount'] as double;
        final dateStr = DateFormat('MMMM d, yyyy').format(date);
        message = 'Your most expensive day was $dateStr, when you spent ${_currencyFormat.format(amt)}.';
        return AssistantResponse(message: message, type: AssistantResponseType.amount, amount: amt);

      case AssistantIntent.categoryIncreaseMost:
        if (data == null) {
          return AssistantResponse(message: "I couldn't find any category that increased significantly.");
        }
        final name = data['name'] as String;
        final diff = data['difference'] as double;
        message = 'Your spending on $name increased the most by ${_currencyFormat.format(diff)} compared to the previous period.';
        return AssistantResponse(message: message, type: AssistantResponseType.category, categoryName: name, amount: diff);

      case AssistantIntent.categoryDecreaseMost:
        if (data == null) {
          return AssistantResponse(message: "I couldn't find any category that decreased significantly.");
        }
        final dName = data['name'] as String;
        final dDiff = data['difference'] as double;
        message = 'Your spending on $dName decreased the most by ${_currencyFormat.format(dDiff)} compared to the previous period.';
        return AssistantResponse(message: message, type: AssistantResponseType.category, categoryName: dName, amount: dDiff);

      case AssistantIntent.savings:
        final sData = data as Map<String, dynamic>;
        final savings = sData['savings'] as double;
        if (savings > 0) {
          message = 'You saved ${_currencyFormat.format(savings)} for this period.';
        } else if (savings < 0) {
          message = 'You spent ${_currencyFormat.format(savings.abs())} more than you earned for this period.';
        } else {
          message = 'You broke even exactly for this period.';
        }
        return AssistantResponse(message: message, type: AssistantResponseType.amount, amount: savings);

      case AssistantIntent.spendPercentage:
        final spData = data as Map<String, dynamic>;
        final perc = spData['percentage'] as double;
        final inc = spData['income'] as double;
        if (inc == 0) {
          return AssistantResponse(message: "You didn't have any income for this period.");
        }
        message = 'You spent ${perc.toStringAsFixed(1)}% of your income for this period.';
        return AssistantResponse(message: message);

      case AssistantIntent.addTransaction:
        final cat = query.category ?? 'General';
        final amt = query.amount ?? 0.0;
        final date = query.startDate ?? DateTime.now();
        final dateStr = DateFormat('MMMM d, yyyy').format(date);
        
        final payload = 'ADD:$amt:$cat:${date.toIso8601String()}';
        
        message = 'I can add this transaction:\\n\\nCategory: $cat\\nAmount: ${_currencyFormat.format(amt)}\\nDate: $dateStr\\n\\nWould you like to add it?';
        return AssistantResponse(
          message: message,
          type: AssistantResponseType.confirmation,
          confirmPayload: payload,
          cancelPayload: 'cancel',
        );

      case AssistantIntent.deleteTransaction:
        if (data == null) {
          return AssistantResponse(message: "I couldn't find a transaction to delete.");
        }
        final tx = data as Transaction;
        final dateStr = DateFormat('MMMM d, yyyy').format(tx.date);
        final payload = 'DELETE:${tx.id}';
        
        message = 'I can delete this transaction:\\n\\nAmount: ${_currencyFormat.format(tx.amount)}\\nDate: $dateStr\\n\\nWould you like to delete it?';
        return AssistantResponse(
          message: message,
          type: AssistantResponseType.confirmation,
          confirmPayload: payload,
          cancelPayload: 'cancel',
        );
        
      case AssistantIntent.confirmAction:
        return AssistantResponse(message: 'Action confirmed and executed successfully.');
        
      case AssistantIntent.cancelAction:
        return AssistantResponse(message: 'Action cancelled.');

      case AssistantIntent.help:
        message = 'Here are some things you can ask me:';
        final helpGroups = {
          'Spending': [
            'How much did I spend this month?',
            'Where did I spend most?',
            'How much did I spend on Food?'
          ],
          'Income': [
            'How much did I earn?',
            'How much income did I receive this month?'
          ],
          'Comparison': [
            'Did I spend more than last month?',
            'Which category increased?'
          ],
          'Transactions': [
            'What was my biggest expense?',
            'Show my recent expenses.'
          ],
          'Insights': [
            'Give me a spending summary.',
            'How am I doing this month?'
          ],
        };
        return AssistantResponse(
          message: message,
          type: AssistantResponseType.help,
          helpGroups: helpGroups,
        );

      case AssistantIntent.unknown:
      default:
        message = 'I am not sure how to answer that yet. Try asking about your balance or recent expenses.';
        return AssistantResponse(message: message);
    }
  }
}
