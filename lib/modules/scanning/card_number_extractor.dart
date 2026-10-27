// AUTHOR: L. I. Jefthas
// DATE: October 2026
// VERSION: 0.0.1

import '../validation/card_number_rules.dart';

/// Finds a valid card number inside text recognised from a card photo.
class CardNumberExtractor {
  CardNumberExtractor._();

  /// A run of 13 to 19 digits, optionally separated by single spaces or dashes.
  static final RegExp _digitRun = RegExp(r'\d(?:[ -]?\d){12,18}');

  /// Returns the first digit run that passes the length and Luhn checks, or null.
  static String? numberFrom(String recognizedText) {
    for (final match in _digitRun.allMatches(recognizedText)) {
      final digits = CardNumberRules.digitsOnly(match.group(0)!);
      if (_isUsableNumber(digits)) {
        return digits;
      }
    }
    return null;
  }

  static bool _isUsableNumber(String digits) {
    return CardNumberRules.hasValidLength(digits) && CardNumberRules.passesLuhn(digits);
  }
}
