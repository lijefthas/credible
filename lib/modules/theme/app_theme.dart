// AUTHOR: L. I. Jefthas
// DATE: October 2026
// VERSION: 0.0.1

import 'package:flutter/material.dart';

import 'app_button_style.dart';
import 'app_typography.dart';

/// Builds the app-wide theme from [AppTypography] and [AppButtonStyle].
class AppTheme {
  AppTheme._();

  static ThemeData light() {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: const Color(0xFF1565C0),
      textTheme: const TextTheme(
        titleLarge: AppTypography.title,
        bodyLarge: AppTypography.body,
        bodyMedium: AppTypography.body,
        bodySmall: AppTypography.hint,
        labelLarge: AppTypography.button,
      ),
      appBarTheme: const AppBarTheme(titleTextStyle: AppTypography.title),
      inputDecorationTheme: const InputDecorationTheme(
        border: OutlineInputBorder(),
        labelStyle: AppTypography.body,
        hintStyle: AppTypography.hint,
        errorStyle: AppTypography.error,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(style: AppButtonStyle.filled),
      outlinedButtonTheme: OutlinedButtonThemeData(style: AppButtonStyle.outlined),
    );
  }
}
