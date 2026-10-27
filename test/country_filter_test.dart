// AUTHOR: L. I. Jefthas
// DATE: October 2026

import 'package:credible/modules/config/banned_country_list.dart';
import 'package:credible/modules/data/country_filter.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final countries = ['Australia', 'Canada', 'Chile', 'Kenya', 'Thailand'];
  final banned = BannedCountryList(['Chile', 'Australia']);

  test('puts banned countries after the open ones, keeping catalog order', () {
    final sections = filterCountries(countries: countries, banned: banned, query: '');

    expect(sections.open, ['Canada', 'Kenya', 'Thailand']);
    expect(sections.banned, ['Australia', 'Chile']);
    expect(sections.needsDivider, isTrue);
  });

  test('matches the query ignoring case and surrounding spaces', () {
    final sections = filterCountries(countries: countries, banned: banned, query: '  CH ');

    expect(sections.open, isEmpty);
    expect(sections.banned, ['Chile']);
  });

  test('reports empty when nothing matches', () {
    final sections = filterCountries(countries: countries, banned: banned, query: 'zzz');

    expect(sections.isEmpty, isTrue);
  });

  test('needs no divider when only one section has matches', () {
    final sections = filterCountries(countries: countries, banned: banned, query: 'Kenya');

    expect(sections.open, ['Kenya']);
    expect(sections.banned, isEmpty);
    expect(sections.needsDivider, isFalse);
  });
}
