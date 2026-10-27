// AUTHOR: L. I. Jefthas
// DATE: October 2026

import 'package:flutter/material.dart';

import '../models/captured_card.dart';
import '../theme/app_typography.dart';

/// One captured card: type and masked number, with the issuing country beneath.
class CapturedCardTile extends StatelessWidget {
  const CapturedCardTile({super.key, required this.card});

  final CapturedCard card;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.credit_card),
        title: Text(
          '${card.cardType.label}  ${card.maskedNumber}',
          style: AppTypography.body,
        ),
        subtitle: Text(card.issuingCountry, style: AppTypography.hint),
      ),
    );
  }
}
