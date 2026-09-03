import 'package:flutter/material.dart';
import '../models/insight.dart';
import '../services/insight_engine.dart';

class InsightViewModel extends ChangeNotifier {
  final InsightEngine _engine;
  List<Insight> _currentInsights = [];
  bool _isLoading = false;

  InsightViewModel(this._engine) {
    loadInsights();
  }

  List<Insight> get currentInsights => _currentInsights;
  bool get isLoading => _isLoading;

  Future<void> loadInsights() async {
    _isLoading = true;
    notifyListeners();

    try {
      final insights = await _engine.generateInsights();
      // Only keep top 2 insights so as not to overwhelm the dashboard
      _currentInsights = insights.length > 2 ? insights.take(2).toList() : insights;
    } catch (e) {
      debugPrint('Error loading insights: $e');
      _currentInsights = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
