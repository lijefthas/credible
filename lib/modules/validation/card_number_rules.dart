// AUTHOR: L. I. Jefthas
// DATE: October 2026
// VERSION: 0.0.1

import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Rules for card numbers: digit cleanup, length, Luhn checksum, masking, fingerprint.
class CardNumberRules {
  CardNumberRules._();

  static const int minLength = 13;
  static const int maxLength = 19;

  /// Strips spaces and dashes, keeping only the digits.
  static String digitsOnly(String input) => input.replaceAll(RegExp(r'\D'), '');

  static bool hasValidLength(String digits) =>
      digits.length >= minLength && digits.length <= maxLength;

  static bool passesLuhn(String digits) {
    var sum = 0;
    var doubleNext = false;
    for (var i = digits.length - 1; i >= 0; i--) {
      final digit = int.parse(digits[i]);
      sum += doubleNext ? _doubledDigitValue(digit) : digit;
      doubleNext = !doubleNext;
    }
    return sum % 10 == 0;
  }

  static int _doubledDigitValue(int digit) {
    final doubled = digit * 2;
    return doubled > 9 ? doubled - 9 : doubled;
  }

  /// Shows only the last four digits, e.g. "•••• 4242".
  static String maskedNumberOf(String digits) =>
      '•••• ${digits.substring(digits.length - 4)}';

  /// SHA-256 of the digits, so duplicates can be detected without keeping the number.
  static String fingerprintOf(String digits) =>
      sha256.convert(utf8.encode(digits)).toString();
}
