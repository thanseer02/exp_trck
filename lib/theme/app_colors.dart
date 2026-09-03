import 'package:flutter/material.dart';

class AppColors {
  // Primary - Emerald / Deep Green
  static const Color primary = Color(0xFF0F766E); // Teal 700
  static const Color primaryLight = Color(0xFF14B8A6); // Teal 500
  static const Color primaryDark = Color(0xFF115E59); // Teal 800

  // Backgrounds & Surfaces (Light - Unused but kept for structure)
  static const Color background = Color(0xFFF8FAFC); 
  static const Color surface = Colors.white;

  // Dark Theme Surfaces (FlowLedger)
  static const Color backgroundDark = Color(0xFF0B1221); // Deepest dark
  static const Color surfaceDark = Color(0xFF131B2E); // Surface container lowest
  static const Color surfaceContainerLowDark = Color(0xFF1A243D); 
  static const Color surfaceContainerHighDark = Color(0xFF213145);

  // Semantics
  static const Color income = Color(0xFF4EDEA3); // Bright secondary green
  static const Color incomeBg = Color(0xFF00714D); // Secondary container dark
  static const Color expense = Color(0xFFFFA2A6); // Error text
  static const Color expenseBg = Color(0xFF93000A); // Error container dark

  // Text
  static const Color textPrimary = Color(0xFF0F172A); 
  static const Color textSecondary = Color(0xFF64748B); 
  static const Color textTertiary = Color(0xFF94A3B8); 

  // Dark Theme Text
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFBEC6E0); // Outline variant
  static const Color textTertiaryDark = Color(0xFF76777D);

  // Borders & Dividers
  static const Color border = Color(0xFFE2E8F0); 
  static const Color borderDark = Color(0xFF2A374F); 
}
