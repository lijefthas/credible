// AUTHOR: L. I. Jefthas
// DATE: October 2026
// VERSION: 0.0.1

import 'package:flutter/material.dart';

import '../config/banned_country_list.dart';
import '../data/country_filter.dart';
import '../theme/app_typography.dart';

/// Searchable country list. Pops with the country the user taps.
class CountryPickerScreen extends StatefulWidget {
  const CountryPickerScreen({
    super.key,
    required this.title,
    required this.countries,
    required this.bannedCountries,
  });

  final String title;
  final List<String> countries;
  final BannedCountryList bannedCountries;

  @override
  State<CountryPickerScreen> createState() => _CountryPickerScreenState();
}

class _CountryPickerScreenState extends State<CountryPickerScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final sections = filterCountries(
      countries: widget.countries,
      banned: widget.bannedCountries,
      query: _query,
    );
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              onChanged: (value) => setState(() => _query = value),
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: 'Search countries',
              ),
            ),
          ),
          Expanded(child: _countryList(sections)),
        ],
      ),
    );
  }

  Widget _countryList(CountrySections sections) {
    if (sections.isEmpty) {
      return const Center(child: Text('No countries match your search'));
    }
    return ListView(
      children: [
        for (final country in sections.open) _countryTile(country),
        if (sections.needsDivider) const Divider(color: Colors.red, thickness: 2),
        for (final country in sections.banned) _countryTile(country),
      ],
    );
  }

  Widget _countryTile(String country) {
    return ListTile(
      title: Text(country, style: AppTypography.body),
      onTap: () => Navigator.of(context).pop(country),
    );
  }
}
