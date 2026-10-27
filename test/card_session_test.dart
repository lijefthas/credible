// AUTHOR: L. I. Jefthas
// DATE: October 2026
// VERSION: 0.0.1

import 'package:credible/modules/models/captured_card.dart';
import 'package:credible/modules/models/card_type.dart';
import 'package:credible/modules/session/card_session.dart';
import 'package:credible/modules/storage/card_storage.dart';
import 'package:credible/modules/storage/settings_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

CapturedCard _visaCard() {
  return CapturedCard.fromDigits(
    digits: '4111111111111111',
    cardType: CardType.visa,
    issuingCountry: 'Canada',
  );
}

Future<CardSession> _sessionWith(SharedPreferences preferences) async {
  final session = CardSession(
    cardStorage: CardStorage(preferences),
    settingsStorage: SettingsStorage(preferences),
  );
  await session.initialize(defaultBannedCountries: const ['Iran']);
  return session;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('uses the default banned countries until a list is saved', () async {
    final session = await _sessionWith(await SharedPreferences.getInstance());
    expect(session.bannedCountries, ['Iran']);
  });

  test('saves the banned list and restores it at startup', () async {
    final preferences = await SharedPreferences.getInstance();
    final session = await _sessionWith(preferences);

    await session.setBannedCountries(['Chile', 'Australia']);
    expect(session.bannedCountries, ['Australia', 'Chile']);

    final restored = await _sessionWith(preferences);
    expect(restored.bannedCountries, ['Australia', 'Chile']);
    expect(restored.bannedCountryList.contains('chile'), isTrue);
  });

  test('captures a card once and reports the repeat as a duplicate', () async {
    final session = await _sessionWith(await SharedPreferences.getInstance());

    expect(await session.capture(_visaCard()), CaptureOutcome.captured);
    expect(await session.capture(_visaCard()), CaptureOutcome.duplicate);
    expect(session.visibleCards, hasLength(1));
  });

  test('hides previous cards until "View Previous" is enabled', () async {
    final preferences = await SharedPreferences.getInstance();
    await CardStorage(preferences).appendIfNew(_visaCard());

    final session = await _sessionWith(preferences);
    expect(session.visibleCards, isEmpty);

    await session.setViewPrevious(true);
    expect(session.visibleCards, hasLength(1));
  });

  test('restores the View Previous setting and stored cards at startup', () async {
    final preferences = await SharedPreferences.getInstance();
    await SettingsStorage(preferences).setViewPreviousEnabled(true);
    await CardStorage(preferences).appendIfNew(_visaCard());

    final session = await _sessionWith(preferences);
    expect(session.viewPreviousEnabled, isTrue);
    expect(session.visibleCards, hasLength(1));
  });

  test('rejects a card already stored in an earlier session', () async {
    final preferences = await SharedPreferences.getInstance();
    await CardStorage(preferences).appendIfNew(_visaCard());

    final session = await _sessionWith(preferences);
    expect(await session.capture(_visaCard()), CaptureOutcome.duplicate);
  });
}
