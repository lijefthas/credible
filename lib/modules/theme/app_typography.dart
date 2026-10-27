// AUTHOR: L. I. Jefthas
// DATE: October 2026

import 'package:flutter/material.dart';

/// Single source for the app's font family and text styles (title, body, hint, button, error).
class AppTypography {
  AppTypography._();

  /// Null uses the platform default font. Set a bundled font family name here to change it app-wide.
  static const String? fontFamily = null;

  static const TextStyle title = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: Color(0xFF1A1A1A),
  );

  static const TextStyle body = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    height: 1.4,
  );

  static const TextStyle hint = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Color(0xFF757575),
  );

  static const TextStyle button = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle error = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: Color(0xFFB00020),
  );
}
