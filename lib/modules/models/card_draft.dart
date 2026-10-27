// AUTHOR: L. I. Jefthas
// DATE: October 2026

import 'card_type.dart';

/// Raw values typed or scanned into the form, before validation.
class CardDraft {
  const CardDraft({
    required this.number,
    required this.cardType,
    required this.cvv,
    required this.issuingCountry,
  });

  final String number;
  final CardType cardType;
  final String cvv;
  final String? issuingCountry;
}
