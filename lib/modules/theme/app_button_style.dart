// AUTHOR: L. I. Jefthas
// DATE: October 2026

import 'package:flutter/material.dart';

import 'app_typography.dart';

/// Shared button look: one height, one corner radius, one label style.
class AppButtonStyle {
  AppButtonStyle._();

  static const double height = 52;
  static const double cornerRadius = 12;

  /// Main action colour: the app's seed blue.
  static const Color primaryColor = Color(0xFF1565C0);

  /// Secondary action colour: a blue-grey that is clearly different from [primaryColor].
  static const Color secondaryColor = Color(0xFF546E7A);

  static final ButtonStyle filled = ElevatedButton.styleFrom(
    minimumSize: const Size.fromHeight(height),
    textStyle: AppTypography.button,
    shape: _roundedShape,
  );

  static final ButtonStyle primary = ElevatedButton.styleFrom(
    minimumSize: const Size.fromHeight(height),
    backgroundColor: primaryColor,
    foregroundColor: Colors.white,
    textStyle: AppTypography.button,
    shape: _roundedShape,
  );

  static final ButtonStyle secondary = ElevatedButton.styleFrom(
    minimumSize: const Size.fromHeight(height),
    backgroundColor: secondaryColor,
    foregroundColor: Colors.white,
    textStyle: AppTypography.button,
    shape: _roundedShape,
  );

  static final ButtonStyle outlined = OutlinedButton.styleFrom(
    minimumSize: const Size.fromHeight(height),
    textStyle: AppTypography.button,
    shape: _roundedShape,
  );

  static final RoundedRectangleBorder _roundedShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(cornerRadius),
  );
}
