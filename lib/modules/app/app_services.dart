// AUTHOR: L. I. Jefthas
// DATE: October 2026

import 'package:shared_preferences/shared_preferences.dart';

import '../config/banned_country_list.dart';
import '../scanning/card_scanner.dart';
import '../session/card_session.dart';
import '../storage/card_storage.dart';
import '../storage/settings_storage.dart';

/// Everything the screens need, built once at startup.
class AppServices {
  AppServices({
    required this.session,
    required this.scanner,
  });

  final CardSession session;
  final CardScanner scanner;

  static Future<AppServices> create() async {
    final preferences = await SharedPreferences.getInstance();
    final defaults = await BannedCountryList.loadFromAsset();
    final session = CardSession(
      cardStorage: CardStorage(preferences),
      settingsStorage: SettingsStorage(preferences),
    );
    await session.initialize(defaultBannedCountries: defaults.countries);
    return AppServices(
      session: session,
      scanner: CardScanner(),
    );
  }
}
