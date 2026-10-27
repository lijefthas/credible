// AUTHOR: L. I. Jefthas
// DATE: October 2026
// VERSION: 0.0.1

import 'package:flutter/material.dart';

import 'app_typography.dart';

/// Shared button look: one height, one corner radius, one label style.
class AppButtonStyle {
  AppButtonStyle._();

  static const double height = 52;
  static const double cornerRadius = 12;

  static final ButtonStyle filled = ElevatedButton.styleFrom(
    minimumSize: const Size.fromHeight(height),
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
