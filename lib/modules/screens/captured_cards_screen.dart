// AUTHOR: L. I. Jefthas
// DATE: October 2026
// VERSION: 0.0.1

import 'package:flutter/material.dart';

import '../session/card_session.dart';
import '../theme/app_typography.dart';
import '../widgets/captured_card_tile.dart';

/// Lists captured cards and hosts the "View Previous" switch.
class CapturedCardsScreen extends StatelessWidget {
  const CapturedCardsScreen({super.key, required this.session});

  final CardSession session;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Captured cards')),
      body: ListenableBuilder(
        listenable: session,
        builder: (context, _) => Column(
          children: [
            _viewPreviousSwitch(),
            const Divider(height: 1),
            Expanded(child: _cardList()),
          ],
        ),
      ),
    );
  }

  Widget _viewPreviousSwitch() {
    return SwitchListTile(
      title: const Text('View Previous', style: AppTypography.body),
      subtitle: const Text(
        'Also show cards stored from earlier sessions',
        style: AppTypography.hint,
      ),
      value: session.viewPreviousEnabled,
      onChanged: (enabled) => session.setViewPrevious(enabled),
    );
  }

  Widget _cardList() {
    final cards = session.visibleCards;
    if (cards.isEmpty) {
      return const Center(
        child: Text('No cards captured yet.', style: AppTypography.hint),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: cards.length,
      itemBuilder: (context, index) => CapturedCardTile(card: cards[index]),
    );
  }
}
