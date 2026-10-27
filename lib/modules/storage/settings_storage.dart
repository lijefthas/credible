// AUTHOR: L. I. Jefthas
// DATE: October 2026
// VERSION: 0.0.1

import 'package:shared_preferences/shared_preferences.dart';

/// Stores app-level switches such as "View Previous".
class SettingsStorage {
  SettingsStorage(this._preferences);

  static const String _viewPreviousKey = 'view_previous';
  static const String _bannedCountriesKey = 'banned_countries';

  final SharedPreferences _preferences;

  bool get viewPreviousEnabled => _preferences.getBool(_viewPreviousKey) ?? false;

  Future<void> setViewPreviousEnabled(bool enabled) {
    return _preferences.setBool(_viewPreviousKey, enabled);
  }

  /// Null until a banned list has been saved, so the bundled defaults apply.
  List<String>? get bannedCountries => _preferences.getStringList(_bannedCountriesKey);

  Future<void> setBannedCountries(List<String> countries) {
    return _preferences.setStringList(_bannedCountriesKey, countries);
  }
}
