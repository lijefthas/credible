// AUTHOR: L. I. Jefthas
// DATE: October 2026
// VERSION: 0.0.1

import 'package:flutter/material.dart';

import '../config/banned_country_list.dart';
import '../data/country_catalog.dart';
import '../session/card_session.dart';
import '../theme/app_typography.dart';
import 'country_picker_screen.dart';

/// Edits the banned list. Changes only reach storage when the user taps save.
class BannedCountriesScreen extends StatefulWidget {
  const BannedCountriesScreen({super.key, required this.session});

  final CardSession session;

  @override
  State<BannedCountriesScreen> createState() => _BannedCountriesScreenState();
}

class _BannedCountriesScreenState extends State<BannedCountriesScreen> {
  late List<String> _banned = List.of(widget.session.bannedCountries);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Banned countries'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            tooltip: 'Save',
            onPressed: _save,
          ),
        ],
      ),
      body: _banned.isEmpty
          ? const Center(child: Text('No banned countries'))
          : ListView(children: [for (final country in _banned) _bannedTile(country)]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addCountry,
        icon: const Icon(Icons.add),
        label: const Text('Add country'),
      ),
    );
  }

  Widget _bannedTile(String country) {
    return ListTile(
      title: Text(country, style: AppTypography.body),
      trailing: IconButton(
        icon: const Icon(Icons.remove_circle_outline),
        tooltip: 'Remove',
        onPressed: () => setState(() => _banned.remove(country)),
      ),
    );
  }

  Future<void> _addCountry() async {
    final available = countryCatalog.where((country) => !_banned.contains(country)).toList();
    final picked = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => CountryPickerScreen(
          title: 'Add banned country',
          countries: available,
          bannedCountries: BannedCountryList(const []),
        ),
      ),
    );
    if (!mounted || picked == null) return;
    setState(() => _banned = [..._banned, picked]..sort());
  }

  Future<void> _save() async {
    await widget.session.setBannedCountries(_banned);
    if (!mounted) return;
    Navigator.of(context).pop();
  }
}
