// AUTHOR: L. I. Jefthas
// DATE: October 2026
// VERSION: 0.0.1

import 'package:shared_preferences/shared_preferences.dart';

import '../config/banned_country_list.dart';
import '../scanning/card_scanner.dart';
import '../session/card_session.dart';
import '../storage/card_storage.dart';
import '../storage/settings_storage.dart';
import '../validation/card_validator.dart';

/// Everything the screens need, built once at startup.
class AppServices {
  AppServices({
    required this.session,
    required this.validator,
    required this.scanner,
  });

  final CardSession session;
  final CardValidator validator;
  final CardScanner scanner;

  static Future<AppServices> create() async {
    final preferences = await SharedPreferences.getInstance();
    final bannedCountries = await BannedCountryList.loadFromAsset();
    final session = CardSession(
      cardStorage: CardStorage(preferences),
      settingsStorage: SettingsStorage(preferences),
    );
    await session.initialize();
    return AppServices(
      session: session,
      validator: CardValidator(bannedCountries),
      scanner: CardScanner(),
    );
  }
}
