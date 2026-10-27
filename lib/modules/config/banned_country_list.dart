// AUTHOR: L. I. Jefthas
// DATE: October 2026
// VERSION: 0.0.1

import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

/// Countries whose issued cards are rejected. Loaded from an editable JSON asset.
class BannedCountryList {
  BannedCountryList(List<String> countries)
      : countries = List.unmodifiable(countries),
        _normalized = countries.map(_normalize).toSet();

  static const String assetPath = 'assets/config/banned_countries.json';

  /// Country names exactly as they were given.
  final List<String> countries;
  final Set<String> _normalized;

  static Future<BannedCountryList> loadFromAsset() async {
    final raw = await rootBundle.loadString(assetPath);
    final json = jsonDecode(raw) as Map<String, dynamic>;
    final countries = (json['banned_countries'] as List).cast<String>();
    return BannedCountryList(countries);
  }

  bool contains(String country) => _normalized.contains(_normalize(country));

  static String _normalize(String country) => country.trim().toLowerCase();
}
