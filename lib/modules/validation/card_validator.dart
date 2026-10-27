// AUTHOR: L. I. Jefthas
// DATE: October 2026
// VERSION: 0.0.1

import '../config/banned_country_list.dart';
import '../models/card_draft.dart';
import '../models/card_type.dart';
import 'card_number_rules.dart';
import 'card_type_detector.dart';

/// Checks a [CardDraft] and returns the first problem found, or null when it is valid.
class CardValidator {
  const CardValidator(this._bannedCountries);

  final BannedCountryList _bannedCountries;

  String? validationError(CardDraft draft) {
    final digits = CardNumberRules.digitsOnly(draft.number);
    return numberError(digits) ??
        typeError(digits, draft.cardType) ??
        cvvError(draft.cvv, draft.cardType) ??
        countryError(draft.issuingCountry);
  }

  String? numberError(String digits) {
    if (!CardNumberRules.hasValidLength(digits)) {
      return 'Card number must be ${CardNumberRules.minLength} to '
          '${CardNumberRules.maxLength} digits';
    }
    if (!CardNumberRules.passesLuhn(digits)) {
      return 'Card number is not valid';
    }
    return null;
  }

  String? typeError(String digits, CardType selected) {
    final detected = CardTypeDetector.typeOf(digits);
    if (detected == CardType.unknown) {
      return 'Card type is not supported';
    }
    if (detected != selected) {
      return 'Card type does not match the card number';
    }
    return null;
  }

  String? cvvError(String cvv, CardType type) {
    final isValidCvv = RegExp(r'^\d+$').hasMatch(cvv) && cvv.length == type.cvvLength;
    return isValidCvv ? null : 'CVV must be ${type.cvvLength} digits';
  }

  String? countryError(String? country) {
    if (country == null || country.trim().isEmpty) {
      return 'Select an issuing country';
    }
    if (_bannedCountries.contains(country)) {
      return 'Cards issued in $country are not accepted';
    }
    return null;
  }
}
