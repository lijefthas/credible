// AUTHOR: L. I. Jefthas
// DATE: October 2026
// VERSION: 0.0.1

import 'package:shared_preferences/shared_preferences.dart';

/// Stores app-level switches such as "View Previous".
class SettingsStorage {
  SettingsStorage(this._preferences);

  static const String _viewPreviousKey = 'view_previous';

  final SharedPreferences _preferences;

  bool get viewPreviousEnabled => _preferences.getBool(_viewPreviousKey) ?? false;

  Future<void> setViewPreviousEnabled(bool enabled) {
    return _preferences.setBool(_viewPreviousKey, enabled);
  }
}
