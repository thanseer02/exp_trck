import 'package:flutter/material.dart';
import '../models/assistant_response.dart';
import '../models/assistant_intent.dart';
import '../services/assistant_parser.dart';
import '../services/assistant_response_generator.dart';
import '../repositories/transaction_repository.dart';

class AssistantViewModel extends ChangeNotifier {
  final TransactionRepository _repository;
  final AssistantParser _parser;
  final AssistantResponseGenerator _generator;

  final List<AssistantResponse> _chatHistory = [];
  List<String> _currentSuggestions = [];
  bool _isProcessing = false;
  bool _hasTransactions = true;

  AssistantViewModel(this._repository, this._parser, this._generator) {
    _initAssistant();
  }

  List<AssistantResponse> get chatHistory => _chatHistory;
  List<String> get currentSuggestions => _currentSuggestions;
  bool get isProcessing => _isProcessing;
  bool get hasTransactions => _hasTransactions;

  Future<void> _initAssistant() async {
    _isProcessing = true;
    notifyListeners();

    try {
      final total = await _repository.getTotalExpenses();
      final income = await _repository.getTotalIncome();
      _hasTransactions = (total > 0 || income > 0);
      
      if (!_hasTransactions) {
        _chatHistory.add(AssistantResponse(
          message: 'Add your first transaction to start using Money Assistant.',
        ));
        _currentSuggestions = [];
      } else {
        _chatHistory.add(AssistantResponse(
          message: 'Hi there! I am your offline Money Assistant. How can I help you today?',
        ));
        _currentSuggestions = [
          "Where did I spend most?",
          "How much did I spend this month?",
          "What was my biggest expense?",
          "Did I spend more than last month?",
        ];
      }
    } catch (e) {
      _chatHistory.add(AssistantResponse(
        message: 'Hi there! I am your offline Money Assistant. How can I help you today?',
      ));
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  Future<void> processUserMessage(String message) async {
    if (message.trim().isEmpty) return;

    // 1. Add user message to history
    _chatHistory.add(AssistantResponse(message: message, isUser: true));
    _currentSuggestions = []; // Clear suggestions while processing
    _isProcessing = true;
    notifyListeners();

    // 2. Parse the message
    final query = _parser.parse(message);
    
    // Simulate slight processing delay for realism
    await Future.delayed(const Duration(milliseconds: 600));

    dynamic data;
    
    // 3. Query Repository based on Intent
    try {
      final now = DateTime.now();
      DateTime? start = query.startDate;
      DateTime? end = query.endDate;
      
      // Default to this month if month is specifically queried but not full date range
      if (start == null && end == null && query.month != null) {
        final targetYear = query.year ?? now.year;
        start = DateTime(targetYear, query.month!, 1);
        end = DateTime(targetYear, query.month! + 1, 0, 23, 59, 59);
      }
      
      switch (query.intent) {
        case AssistantIntent.balance:
          data = await _repository.getBalance();
          break;
        case AssistantIntent.totalExpense:
          if (start != null && end != null) {
             data = await _repository.getExpensesForPeriod(start, end);
          } else {
             data = await _repository.getTotalExpenses();
          }
          break;
        case AssistantIntent.monthlyExpense:
          start ??= DateTime(now.year, now.month, 1);
          end ??= DateTime(now.year, now.month + 1, 0, 23, 59, 59);
          data = await _repository.getExpensesForPeriod(start, end);
          break;
        case AssistantIntent.dailyExpense:
          start ??= DateTime(now.year, now.month, now.day);
          end ??= DateTime(now.year, now.month, now.day, 23, 59, 59);
          data = await _repository.getExpensesForPeriod(start, end);
          break;
        case AssistantIntent.totalIncome:
          if (start != null && end != null) {
             data = await _repository.getIncomeForPeriod(start, end);
          } else {
             data = await _repository.getTotalIncome();
          }
          break;
        case AssistantIntent.monthlyIncome:
          start ??= DateTime(now.year, now.month, 1);
          end ??= DateTime(now.year, now.month + 1, 0, 23, 59, 59);
          data = await _repository.getIncomeForPeriod(start, end);
          break;
        case AssistantIntent.recentTransactions:
          data = await _repository.getRecentTransactions(limit: 5);
          break;
        case AssistantIntent.categoryExpense:
          if (query.category != null) {
            final amt = await _repository.getCategoryExpense(query.category!, start: start, end: end);
            data = {'name': query.category, 'amount': amt};
          }
          break;
        case AssistantIntent.topSpendingCategory:
          start ??= DateTime(now.year, now.month, 1);
          end ??= DateTime(now.year, now.month + 1, 0, 23, 59, 59);
          data = await _repository.getAssistantTopSpendingCategory(start: start, end: end);
          break;
        case AssistantIntent.largestExpense:
          data = await _repository.getLargestExpenseTransaction(start: start, end: end);
          break;
        case AssistantIntent.averageExpense:
          data = await _repository.getAverageExpense(start: start, end: end);
          break;
        case AssistantIntent.monthlyComparison:
          final thisMonthStart = DateTime(now.year, now.month, 1);
          final thisMonthEnd = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
          final lastMonthStart = DateTime(now.year, now.month - 1, 1);
          final lastMonthEnd = DateTime(now.year, now.month, 0, 23, 59, 59);
          
          final currentExp = await _repository.getExpensesForPeriod(thisMonthStart, thisMonthEnd);
          final lastExp = await _repository.getExpensesForPeriod(lastMonthStart, lastMonthEnd);
          data = {'current': currentExp, 'last': lastExp};
          break;
        case AssistantIntent.transactionCount:
          data = await _repository.getAssistantTransactionCount(start: start, end: end);
          break;
        case AssistantIntent.mostExpensiveDay:
          data = await _repository.getMostExpensiveDay(start: start, end: end);
          break;
        case AssistantIntent.categoryIncreaseMost:
        case AssistantIntent.categoryDecreaseMost:
          final currentStart = start ?? DateTime(now.year, now.month, 1);
          final currentEnd = end ?? DateTime(now.year, now.month + 1, 0, 23, 59, 59);
          final lastStart = DateTime(currentStart.year, currentStart.month - 1, 1);
          final lastEnd = DateTime(currentStart.year, currentStart.month, 0, 23, 59, 59);
          final isIncrease = query.intent == AssistantIntent.categoryIncreaseMost;
          data = await _repository.getCategoryChangeMost(currentStart, currentEnd, lastStart, lastEnd, isIncrease: isIncrease);
          break;
        case AssistantIntent.savings:
          final pStart = start ?? DateTime(now.year, now.month, 1);
          final pEnd = end ?? DateTime(now.year, now.month + 1, 0, 23, 59, 59);
          final inc = await _repository.getIncomeForPeriod(pStart, pEnd);
          final exp = await _repository.getExpensesForPeriod(pStart, pEnd);
          data = {'income': inc, 'expense': exp, 'savings': inc - exp};
          break;
        case AssistantIntent.spendPercentage:
          final pStart2 = start ?? DateTime(now.year, now.month, 1);
          final pEnd2 = end ?? DateTime(now.year, now.month + 1, 0, 23, 59, 59);
          final inc2 = await _repository.getIncomeForPeriod(pStart2, pEnd2);
          final exp2 = await _repository.getExpensesForPeriod(pStart2, pEnd2);
          final percentage = inc2 > 0 ? (exp2 / inc2) * 100 : 0.0;
          data = {'percentage': percentage, 'income': inc2, 'expense': exp2};
          break;
        default:
          data = null; 
          break;
      }

      // 4. Generate Response
      final response = _generator.generateResponse(query, data);
      _chatHistory.add(response);
      _generateFollowUpSuggestions(query.intent, data);
      
    } catch (e) {
      _chatHistory.add(AssistantResponse(
        message: 'Sorry, I ran into an issue retrieving that information.',
        isError: true,
      ));
      _generateFollowUpSuggestions(AssistantIntent.unknown, null);
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }

  void _generateFollowUpSuggestions(AssistantIntent intent, dynamic data) {
    if (!_hasTransactions) {
      _currentSuggestions = [];
      return;
    }

    switch (intent) {
      case AssistantIntent.topSpendingCategory:
        if (data != null && data['name'] != null) {
          final cat = data['name'];
          _currentSuggestions = [
            "How much on $cat?",
            "Compare $cat with last month",
            "Show $cat transactions",
          ];
        } else {
          _currentSuggestions = ["What's my balance?", "Did I spend more than last month?"];
        }
        break;
      case AssistantIntent.balance:
      case AssistantIntent.totalExpense:
      case AssistantIntent.monthlyExpense:
        _currentSuggestions = [
          "Where did I spend most?",
          "What was my biggest expense?",
          "Show recent transactions",
        ];
        break;
      case AssistantIntent.categoryExpense:
        if (data != null && data['name'] != null) {
           final cat = data['name'];
           _currentSuggestions = [
             "Compare $cat with last month",
             "Show $cat transactions",
           ];
        } else {
           _currentSuggestions = ["Where did I spend most?"];
        }
        break;
      case AssistantIntent.largestExpense:
        _currentSuggestions = [
          "Where did I spend most?",
          "What's my average expense?",
        ];
        break;
      default:
        _currentSuggestions = [
          "Where did I spend most?",
          "How much did I spend this month?",
          "What's my balance?",
        ];
        break;
    }
  }
}
