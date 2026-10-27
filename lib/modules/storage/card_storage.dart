// AUTHOR: L. I. Jefthas
// DATE: October 2026
// VERSION: 0.0.1

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/captured_card.dart';

/// Persists validated cards in local storage as JSON.
class CardStorage {
  CardStorage(this._preferences);

  static const String _cardsKey = 'captured_cards';

  final SharedPreferences _preferences;

  Future<List<CapturedCard>> loadAll() async {
    final raw = _preferences.getStringList(_cardsKey) ?? const <String>[];
    return raw
        .map((entry) => CapturedCard.fromJson(jsonDecode(entry) as Map<String, dynamic>))
        .toList();
  }

  /// Saves [card] unless a card with the same fingerprint is already stored.
  /// Returns false when the card was a duplicate.
  Future<bool> appendIfNew(CapturedCard card) async {
    final cards = await loadAll();
    if (cards.any((stored) => stored.fingerprint == card.fingerprint)) {
      return false;
    }
    cards.add(card);
    await _writeAll(cards);
    return true;
  }

  Future<void> _writeAll(List<CapturedCard> cards) {
    final encoded = cards.map((card) => jsonEncode(card.toJson())).toList();
    return _preferences.setStringList(_cardsKey, encoded);
  }
}
