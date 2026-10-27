// AUTHOR: L. I. Jefthas
// DATE: October 2026
// VERSION: 0.0.1

import 'package:flutter/foundation.dart';

import '../config/banned_country_list.dart';
import '../models/captured_card.dart';
import '../storage/card_storage.dart';
import '../storage/settings_storage.dart';

enum CaptureOutcome { captured, duplicate }

/// Holds the cards shown in the list and enforces "no card is captured twice".
class CardSession extends ChangeNotifier {
  CardSession({
    required CardStorage cardStorage,
    required SettingsStorage settingsStorage,
  })  : _cardStorage = cardStorage,
        _settingsStorage = settingsStorage;

  final CardStorage _cardStorage;
  final SettingsStorage _settingsStorage;
  final List<CapturedCard> _sessionCards = [];
  List<CapturedCard> _previousCards = [];
  bool _viewPrevious = false;
  List<String> _bannedCountries = const [];

  bool get viewPreviousEnabled => _viewPrevious;

  /// Banned countries, sorted by name.
  List<String> get bannedCountries => List.unmodifiable(_bannedCountries);

  BannedCountryList get bannedCountryList => BannedCountryList(_bannedCountries);

  /// Cards to show: previously stored ones (when "View Previous" is on) followed by this session's.
  List<CapturedCard> get visibleCards => [
        if (_viewPrevious) ..._previousCards,
        ..._sessionCards,
      ];

  /// Reads saved settings. Uses [defaultBannedCountries] until a banned list is saved.
  Future<void> initialize({required List<String> defaultBannedCountries}) async {
    _bannedCountries = _sorted(_settingsStorage.bannedCountries ?? defaultBannedCountries);
    _viewPrevious = _settingsStorage.viewPreviousEnabled;
    if (_viewPrevious) {
      await _reloadPreviousCards();
    }
  }

  /// Saves [countries] as the banned list and notifies listeners.
  Future<void> setBannedCountries(List<String> countries) async {
    _bannedCountries = _sorted(countries);
    await _settingsStorage.setBannedCountries(_bannedCountries);
    notifyListeners();
  }

  static List<String> _sorted(Iterable<String> countries) => countries.toList()..sort();

  Future<void> setViewPrevious(bool enabled) async {
    _viewPrevious = enabled;
    await _settingsStorage.setViewPreviousEnabled(enabled);
    if (enabled) {
      await _reloadPreviousCards();
    }
    notifyListeners();
  }

  Future<CaptureOutcome> capture(CapturedCard card) async {
    if (_containsFingerprint(card.fingerprint)) {
      return CaptureOutcome.duplicate;
    }
    final isNew = await _cardStorage.appendIfNew(card);
    if (!isNew) {
      return CaptureOutcome.duplicate;
    }
    _sessionCards.add(card);
    notifyListeners();
    return CaptureOutcome.captured;
  }

  bool _containsFingerprint(String fingerprint) {
    return [..._sessionCards, ..._previousCards]
        .any((card) => card.fingerprint == fingerprint);
  }

  /// Loads stored cards, leaving out any already captured in this session.
  Future<void> _reloadPreviousCards() async {
    final stored = await _cardStorage.loadAll();
    final sessionFingerprints = _sessionCards.map((card) => card.fingerprint).toSet();
    _previousCards = stored
        .where((card) => !sessionFingerprints.contains(card.fingerprint))
        .toList();
  }
}
