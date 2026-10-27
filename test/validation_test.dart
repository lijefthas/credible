// AUTHOR: L. I. Jefthas
// DATE: October 2026
// VERSION: 0.0.1

import 'package:credible/modules/config/banned_country_list.dart';
import 'package:credible/modules/models/card_draft.dart';
import 'package:credible/modules/models/card_type.dart';
import 'package:credible/modules/scanning/card_number_extractor.dart';
import 'package:credible/modules/validation/card_number_rules.dart';
import 'package:credible/modules/validation/card_type_detector.dart';
import 'package:credible/modules/validation/card_validator.dart';
import 'package:flutter_test/flutter_test.dart';

const _sampleNumbers = {
  CardType.visa: '4111111111111111',
  CardType.mastercard: '5555555555554444',
  CardType.amex: '378282246310005',
  CardType.discover: '6011111111111117',
  CardType.dinersClub: '30569309025904',
  CardType.jcb: '3530111333300000',
  CardType.maestro: '6759649826438453',
  CardType.unionPay: '6200000000000005',
};

void main() {
  group('CardTypeDetector', () {
    test('detects each supported network from its sample number', () {
      for (final entry in _sampleNumbers.entries) {
        expect(CardTypeDetector.typeOf(entry.value), entry.key);
      }
    });

    test('returns unknown for an unrecognised prefix', () {
      expect(CardTypeDetector.typeOf('9999999999999999'), CardType.unknown);
    });
  });

  group('CardNumberRules', () {
    test('passes Luhn for a valid number and fails for an altered one', () {
      expect(CardNumberRules.passesLuhn('4111111111111111'), isTrue);
      expect(CardNumberRules.passesLuhn('4111111111111112'), isFalse);
    });

    test('masks all but the last four digits', () {
      expect(CardNumberRules.maskedNumberOf('4111111111111111'), '•••• 1111');
    });
  });

  group('CardNumberExtractor', () {
    test('finds the first Luhn-valid number in recognised text', () {
      const text = 'BANK NAME\n4111 1111 1111 1111\nVALID THRU 12/30';
      expect(CardNumberExtractor.numberFrom(text), '4111111111111111');
    });

    test('returns null when no valid number is present', () {
      expect(CardNumberExtractor.numberFrom('no digits 123 here'), isNull);
    });
  });

  group('CardValidator', () {
    final validator = CardValidator(BannedCountryList(['Iran']));

    CardDraft draft({
      String number = '4111111111111111',
      CardType type = CardType.visa,
      String cvv = '123',
      String? country = 'Canada',
    }) {
      return CardDraft(number: number, cardType: type, cvv: cvv, issuingCountry: country);
    }

    test('accepts a valid draft', () {
      expect(validator.validationError(draft()), isNull);
    });

    test('rejects a number that fails Luhn', () {
      expect(validator.validationError(draft(number: '4111111111111112')), isNotNull);
    });

    test('rejects a selected type that does not match the number', () {
      expect(validator.validationError(draft(type: CardType.amex)), isNotNull);
    });

    test('requires the CVV length for the card type', () {
      expect(validator.validationError(draft(type: CardType.amex, cvv: '123')), isNotNull);
      expect(validator.validationError(draft(number: '378282246310005', type: CardType.amex, cvv: '1234')), isNull);
    });

    test('rejects banned countries regardless of case and spacing', () {
      expect(validator.validationError(draft(country: '  iran ')), isNotNull);
    });

    test('rejects a missing issuing country', () {
      expect(validator.validationError(draft(country: null)), isNotNull);
    });
  });
}
