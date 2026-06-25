import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_colors.dart';

/// Helper to apply Cairo font for Arabic text throughout the app.
class ArabicTextStyle {
  ArabicTextStyle._();

  static TextStyle display({
    double fontSize = 36,
    FontWeight fontWeight = FontWeight.w700,
    Color color = AppColors.textPrimary,
  }) =>
      GoogleFonts.cairo(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );

  static TextStyle heading({
    double fontSize = 22,
    FontWeight fontWeight = FontWeight.w700,
    Color color = AppColors.textPrimary,
  }) =>
      GoogleFonts.cairo(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );

  static TextStyle body({
    double fontSize = 15,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.textPrimary,
  }) =>
      GoogleFonts.cairo(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );

  static TextStyle label({
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.w600,
    Color color = AppColors.textSecondary,
  }) =>
      GoogleFonts.cairo(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );

  static TextStyle caption({
    double fontSize = 11,
    FontWeight fontWeight = FontWeight.w400,
    Color color = AppColors.textDisabled,
  }) =>
      GoogleFonts.cairo(
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
      );
}
