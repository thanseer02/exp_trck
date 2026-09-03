import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:intl/intl.dart';

class SettingsViewModel extends ChangeNotifier {
  final SharedPreferences _prefs;
  
  static const String _currencyKey = 'currency_symbol';
  static const String _themeModeKey = 'theme_mode';

  String _currencySymbol = '₹';
  ThemeMode _themeMode = ThemeMode.system;

  SettingsViewModel(this._prefs) {
    _loadSettings();
  }

  String get currencySymbol => _currencySymbol;
  ThemeMode get themeMode => _themeMode;
  
  String formatAmount(double amount) {
    final format = NumberFormat.currency(
      locale: 'en_IN',
      symbol: _currencySymbol,
      decimalDigits: amount.truncateToDouble() == amount ? 0 : 2,
    );
    return format.format(amount);
  }

  void _loadSettings() {
    _currencySymbol = _prefs.getString(_currencyKey) ?? '₹';
    
    final themeIndex = _prefs.getInt(_themeModeKey);
    if (themeIndex != null && themeIndex >= 0 && themeIndex < ThemeMode.values.length) {
      _themeMode = ThemeMode.values[themeIndex];
    } else {
      _themeMode = ThemeMode.system;
    }
    
    notifyListeners();
  }

  Future<void> setCurrencySymbol(String symbol) async {
    _currencySymbol = symbol;
    await _prefs.setString(_currencyKey, symbol);
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setInt(_themeModeKey, mode.index);
    notifyListeners();
  }
}
