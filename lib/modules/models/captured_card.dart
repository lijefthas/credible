// AUTHOR: L. I. Jefthas
// DATE: October 2026

import '../validation/card_number_rules.dart';
import 'card_type.dart';

/// A validated card as kept for display and storage. Holds no CVV and no full number.
class CapturedCard {
  const CapturedCard({
    required this.fingerprint,
    required this.maskedNumber,
    required this.cardType,
    required this.issuingCountry,
  });

  /// Builds a captured card from a validated digit string.
  factory CapturedCard.fromDigits({
    required String digits,
    required CardType cardType,
    required String issuingCountry,
  }) {
    return CapturedCard(
      fingerprint: CardNumberRules.fingerprintOf(digits),
      maskedNumber: CardNumberRules.maskedNumberOf(digits),
      cardType: cardType,
      issuingCountry: issuingCountry,
    );
  }

  factory CapturedCard.fromJson(Map<String, dynamic> json) {
    return CapturedCard(
      fingerprint: json['fingerprint'] as String,
      maskedNumber: json['maskedNumber'] as String,
      cardType: CardType.values.byName(json['cardType'] as String),
      issuingCountry: json['issuingCountry'] as String,
    );
  }

  /// SHA-256 of the full number, used to detect duplicates without storing the number.
  final String fingerprint;
  final String maskedNumber;
  final CardType cardType;
  final String issuingCountry;

  Map<String, dynamic> toJson() => {
        'fingerprint': fingerprint,
        'maskedNumber': maskedNumber,
        'cardType': cardType.name,
        'issuingCountry': issuingCountry,
      };
}
