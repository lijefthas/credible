// AUTHOR: L. I. Jefthas
// DATE: October 2026
// VERSION: 0.0.1

import '../config/banned_country_list.dart';

/// Matching countries split into the open list and the banned list (shown under the red line).
class CountrySections {
  const CountrySections({required this.open, required this.banned});

  final List<String> open;
  final List<String> banned;

  bool get isEmpty => open.isEmpty && banned.isEmpty;

  bool get needsDivider => open.isNotEmpty && banned.isNotEmpty;
}

/// Keeps the countries whose name contains [query] (ignoring case) and splits out banned ones.
CountrySections filterCountries({
  required List<String> countries,
  required BannedCountryList banned,
  required String query,
}) {
  final needle = query.trim().toLowerCase();
  final matching = countries.where((country) => country.toLowerCase().contains(needle));
  return CountrySections(
    open: matching.where((country) => !banned.contains(country)).toList(),
    banned: matching.where(banned.contains).toList(),
  );
}
