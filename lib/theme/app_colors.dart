import 'package:flutter/material.dart';

class AppColors {
  // Primary (mostly for the app bar dot or specific accents)
  static const Color primary = Color(0xFF10B981); // Bright FlowLedger Green
  static const Color primaryLight = Color(0xFF34D399);
  static const Color primaryDark = Color(0xFF047857);

  // Backgrounds & Surfaces (Light Theme - Kept for compatibility)
  static const Color background = Color(0xFFFFFFFF); // Pure White
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceContainer = Color(0xFFF9FAFB);
  static const Color surfaceContainerHigh = Color(0xFFF3F4F6);

  // Dark Theme Surfaces (FlowLedger Dark Minimalist)
  static const Color backgroundDark = Color(0xFF121212); // Deep charcoal black
  static const Color surfaceDark = Color(0xFF1E1E1E); // Elevated slightly
  static const Color surfaceContainerLowDark = Color(
    0xFF262626,
  ); // Slightly higher
  static const Color surfaceContainerHighDark = Color(
    0xFF333333,
  ); // Even higher

  // Semantics
  static const Color income = Color(
    0xFF10B981,
  ); // Bright green (FlowLedger +12.4%, +$3,200.00)
  static const Color incomeBg = Color(0xFF064E3B); // Dark green container
  static const Color expense = Color(
    0xFFF3F4F6,
  ); // Expenses are white/light gray in the dark design
  static const Color expenseBg = Color(0xFF262626);

  // Text (Light)
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);

  // Dark Theme Text
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFF9CA3AF);
  static const Color textTertiaryDark = Color(0xFF6B7280);

  // Borders & Dividers
  static const Color border = Color(0xFFF3F4F6);
  static const Color borderDark = Color(0xFF333333); // Subtle dark border
}
