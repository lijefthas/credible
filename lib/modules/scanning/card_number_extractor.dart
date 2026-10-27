// AUTHOR: L. I. Jefthas
// DATE: October 2026

import '../models/card_type.dart';
import '../validation/card_number_rules.dart';
import '../validation/card_type_detector.dart';

/// Finds a valid card number inside text recognised from a card photo.
class CardNumberExtractor {
  CardNumberExtractor._();

  /// Each run of consecutive digits in the recognised text.
  static final RegExp _digitGroup = RegExp(r'\d+');

  /// Returns the first usable number formed by consecutive digit groups, or null.
  static String? numberFrom(String recognizedText) {
    final groups = _digitGroup.allMatches(recognizedText).map((match) => match.group(0)!).toList();
    for (var start = 0; start < groups.length; start++) {
      final number = _numberStartingAt(groups, start);
      if (number != null) return number;
    }
    return null;
  }

  /// Joins groups from [start] onwards, shortest first, and returns the first usable join.
  static String? _numberStartingAt(List<String> groups, int start) {
    final digits = StringBuffer();
    for (var end = start; end < groups.length; end++) {
      digits.write(groups[end]);
      final candidate = digits.toString();
      if (candidate.length > CardNumberRules.maxLength) return null;
      if (_isUsableNumber(candidate)) return candidate;
    }
    return null;
  }

  static bool _isUsableNumber(String digits) {
    return CardNumberRules.hasValidLength(digits) &&
        CardNumberRules.passesLuhn(digits) &&
        CardTypeDetector.typeOf(digits) != CardType.unknown;
  }
}
