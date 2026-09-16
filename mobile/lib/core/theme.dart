import 'package:flutter/material.dart';

class AppColors {
  static const Color forestDark = Color(0xFF0F1914);
  static const Color forestCard = Color(0xFF16261E);
  static const Color forestAccent = Color(0xFF10B981);
  static const Color forestGlow = Color(0xFF064E3B);
  static const Color pineTeal = Color(0xFF14B8A6);

  static const Color textPrimary = Color(0xFFF8FAFC);
  static const Color textSecondary = Color(0xFF94A3B8);
  static const Color textMuted = Color(0xFF64748B);

  static const Color borderSubtle = Color(0xFF2D5A43);
  static const Color borderActive = Color(0xFF52C489);

  // Pressure Status Colors
  static const Color statusLow = Color(0xFF10B981);
  static const Color statusModerate = Color(0xFFF59E0B);
  static const Color statusHigh = Color(0xFFF97316);
  static const Color statusCritical = Color(0xFFEF4444);
}

class AppTheme {
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.forestDark,
      primaryColor: AppColors.forestAccent,
      fontFamily: 'Inter',
      colorScheme: const ColorScheme.dark(
        primary: AppColors.forestAccent,
        secondary: AppColors.pineTeal,
        surface: AppColors.forestCard,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.forestDark,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
      ),
      cardTheme: CardThemeData(
        color: AppColors.forestCard,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.borderSubtle, width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.forestAccent,
          foregroundColor: Colors.white,
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
