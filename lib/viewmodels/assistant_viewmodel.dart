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
  bool _isProcessing = false;

  AssistantViewModel(this._repository, this._parser, this._generator) {
    // Add initial greeting
    _chatHistory.add(AssistantResponse(
      message: 'Hi there! I am your offline Money Assistant. How can I help you today?',
    ));
  }

  List<AssistantResponse> get chatHistory => _chatHistory;
  bool get isProcessing => _isProcessing;

  Future<void> processUserMessage(String message) async {
    if (message.trim().isEmpty) return;

    // 1. Add user message to history
    _chatHistory.add(AssistantResponse(message: message, isUser: true));
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
          final amt = await _repository.getLargestExpense(start: start, end: end);
          data = {'amount': amt, 'category': 'General'}; // We don't fetch the name in the basic query, but good enough for now
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
        default:
          data = null; 
          break;
      }

      // 4. Generate Response
      final response = _generator.generateResponse(query.intent, data);
      _chatHistory.add(response);
      
    } catch (e) {
      _chatHistory.add(AssistantResponse(
        message: 'Sorry, I ran into an issue retrieving that information.',
        isError: true,
      ));
    } finally {
      _isProcessing = false;
      notifyListeners();
    }
  }
}
