// AUTHOR: L. I. Jefthas
// DATE: October 2026

import '../config/banned_country_list.dart';
import '../models/card_draft.dart';
import '../models/card_type.dart';
import 'card_number_rules.dart';
import 'card_type_detector.dart';

/// The form fields a check can fail on.
enum CardField { number, cardType, cvv, country }

/// The first failed check: which field it belongs to and the message to show.
class CardCheckFailure {
  const CardCheckFailure(this.field, this.message);

  final CardField field;
  final String message;
}

/// Checks a [CardDraft] and returns the first problem found, or null when it is valid.
class CardValidator {
  const CardValidator(this._bannedCountries);

  final BannedCountryList _bannedCountries;

  String? validationError(CardDraft draft) => failureFor(draft)?.message;

  CardCheckFailure? failureFor(CardDraft draft) {
    final digits = CardNumberRules.digitsOnly(draft.number);
    return _failure(CardField.number, numberError(digits)) ??
        _failure(CardField.cardType, typeError(digits, draft.cardType)) ??
        _failure(CardField.cvv, cvvError(draft.cvv, draft.cardType)) ??
        _failure(CardField.country, countryError(draft.issuingCountry));
  }

  /// Fields the user has left empty. Each of these also fails [failureFor].
  Set<CardField> missingFields(CardDraft draft) {
    return {
      if (CardNumberRules.digitsOnly(draft.number).isEmpty) CardField.number,
      if (draft.cardType == CardType.unknown) CardField.cardType,
      if (draft.cvv.isEmpty) CardField.cvv,
      if (draft.issuingCountry == null || draft.issuingCountry!.trim().isEmpty) CardField.country,
    };
  }

  CardCheckFailure? _failure(CardField field, String? message) {
    return message == null ? null : CardCheckFailure(field, message);
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
