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
      switch (query.intent) {
        case AssistantIntent.balance:
          data = await _repository.getBalance();
          break;
        case AssistantIntent.totalExpense:
          data = await _repository.getTotalExpenses();
          break;
        case AssistantIntent.totalIncome:
          data = await _repository.getTotalIncome();
          break;
        case AssistantIntent.recentTransactions:
          final recent = await _repository.getRecentTransactions(limit: 3);
          if (recent.isEmpty) {
            data = 'No recent transactions.';
          } else {
            data = recent.map((t) => '- \${t.amount} for \${t.category?.name ?? "General"}').join('\\n');
          }
          break;
        default:
          data = null; // No database query needed for placeholders
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
