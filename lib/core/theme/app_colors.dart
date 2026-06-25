import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Brand
  static const Color primary = Color(0xFF00D4AA);
  static const Color primaryDark = Color(0xFF00A884);
  static const Color primaryLight = Color(0xFF33DEBB);
  static const Color accent = Color(0xFF00B4D8);

  // Background
  static const Color background = Color(0xFF060A0F);
  static const Color surface = Color(0xFF0D1420);
  static const Color surfaceVariant = Color(0xFF141E2E);
  static const Color card = Color(0xFF111827);
  static const Color cardBorder = Color(0xFF1E2D42);

  // Status
  static const Color safe = Color(0xFF00D4AA);
  static const Color warning = Color(0xFFFFB020);
  static const Color danger = Color(0xFFFF4757);
  static const Color info = Color(0xFF00B4D8);

  // Text
  static const Color textPrimary = Color(0xFFE8F4FD);
  static const Color textSecondary = Color(0xFF8DA3BC);
  static const Color textDisabled = Color(0xFF4A6080);
  static const Color textOnPrimary = Color(0xFF060A0F);

  // Chart colors
  static const Color chartLine1 = Color(0xFF00D4AA);
  static const Color chartLine2 = Color(0xFF00B4D8);
  static const Color chartLine3 = Color(0xFFFFB020);
  static const Color chartLine4 = Color(0xFFFF4757);

  // Gradient stops
  static const List<Color> primaryGradient = [
    Color(0xFF00D4AA),
    Color(0xFF00B4D8),
  ];

  static const List<Color> backgroundGradient = [
    Color(0xFF060A0F),
    Color(0xFF0D1420),
  ];

  static const List<Color> dangerGradient = [
    Color(0xFFFF4757),
    Color(0xFFFF6B81),
  ];
}
