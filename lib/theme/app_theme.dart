import 'package:flutter/material.dart';

class AppTheme {
  static const Color background = Color(0xFF080A0D);
  static const Color surface = Color(0xCC171B22);
  static const Color surfaceStrong = Color(0xFF202630);
  static const Color border = Color(0x29FFFFFF);
  static const Color textPrimary = Color(0xFFF7F9FC);
  static const Color textSecondary = Color(0xFF9EA7B5);
  static const Color accent = Color(0xFF71E4FF);
  static const Color lowRisk = Color(0xFF38D996);
  static const Color suspicious = Color(0xFFFFB84D);
  static const Color highRisk = Color(0xFFFF5C6C);

  static ThemeData get darkTheme {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: background,
      colorScheme: ColorScheme.fromSeed(
        seedColor: accent,
        brightness: Brightness.dark,
        surface: surface,
      ),
      textTheme: base.textTheme.apply(
        fontFamily: 'SF Pro Display',
        bodyColor: textPrimary,
        displayColor: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        foregroundColor: textPrimary,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: surfaceStrong,
        contentTextStyle: const TextStyle(color: textPrimary),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0x99171B22),
        hintStyle: const TextStyle(color: textSecondary),
        contentPadding: const EdgeInsets.all(18),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(24),
          borderSide: const BorderSide(color: accent, width: 1.4),
        ),
      ),
    );
  }

  static Color riskColor(String riskLabel) {
    switch (riskLabel) {
      case 'HIGH RISK':
        return highRisk;
      case 'SUSPICIOUS':
        return suspicious;
      default:
        return lowRisk;
    }
  }
}
