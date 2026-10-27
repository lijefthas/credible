// AUTHOR: L. I. Jefthas
// DATE: October 2026

import '../models/card_type.dart';

/// Infers the card network from the leading digits (IIN/BIN ranges).
class CardTypeDetector {
  CardTypeDetector._();

  /// Ordered from most to least specific, so overlapping prefixes resolve correctly.
  static final List<(CardType, RegExp)> _prefixRules = [
    (CardType.amex, RegExp(r'^3[47]')),
    (CardType.dinersClub, RegExp(r'^3(0[0-5]|[689])')),
    (CardType.jcb, RegExp(r'^35(2[89]|[3-8])')),
    (CardType.maestro, RegExp(r'^(5018|5020|5038|5893|6304|6759|676[1-3])')),
    (CardType.visa, RegExp(r'^4')),
    (CardType.mastercard, RegExp(r'^(5[1-5]|22[2-9]|2[3-6]|27[01]|2720)')),
    (CardType.discover, RegExp(r'^(6011|65|64[4-9]|622[1-9])')),
    (CardType.unionPay, RegExp(r'^62')),
  ];

  static CardType typeOf(String digits) {
    for (final (type, prefix) in _prefixRules) {
      if (prefix.hasMatch(digits)) {
        return type;
      }
    }
    return CardType.unknown;
  }
}
