// AUTHOR: L. I. Jefthas
// DATE: October 2026
// VERSION: 0.0.1

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/app_services.dart';
import '../data/country_catalog.dart';
import '../models/captured_card.dart';
import '../models/card_draft.dart';
import '../models/card_type.dart';
import '../session/card_session.dart';
import '../theme/app_typography.dart';
import '../validation/card_number_rules.dart';
import '../validation/card_type_detector.dart';
import '../validation/card_validator.dart';
import 'banned_countries_screen.dart';
import 'captured_cards_screen.dart';
import 'country_picker_screen.dart';

/// Form for entering or scanning a card, validating it, and saving it.
class CardFormScreen extends StatefulWidget {
  const CardFormScreen({super.key, required this.services});

  final AppServices services;

  @override
  State<CardFormScreen> createState() => _CardFormScreenState();
}

class _CardFormScreenState extends State<CardFormScreen> {
  final _numberController = TextEditingController();
  final _cvvController = TextEditingController();
  final _countryController = TextEditingController();
  CardType? _cardType;
  String? _country;
  String? _errorMessage;

  @override
  void dispose() {
    _numberController.dispose();
    _cvvController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Capture card'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            tooltip: 'Banned countries',
            onPressed: _openBannedCountries,
          ),
          IconButton(
            icon: const Icon(Icons.list_alt),
            tooltip: 'Captured cards',
            onPressed: _openCapturedCards,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _numberField(),
            const SizedBox(height: 16),
            _typeDropdown(),
            const SizedBox(height: 16),
            _cvvField(),
            const SizedBox(height: 16),
            _countryField(),
            const SizedBox(height: 16),
            _errorLabel(),
            _actionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _numberField() {
    return TextField(
      controller: _numberController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9 \-]'))],
      style: AppTypography.body,
      decoration: const InputDecoration(
        labelText: 'Card number',
        hintText: '4111 1111 1111 1111',
      ),
      onChanged: _onNumberChanged,
    );
  }

  Widget _typeDropdown() {
    return DropdownButtonFormField<CardType>(
      // ignore: deprecated_member_use - initialValue cannot follow detected type changes
      value: _cardType,
      isExpanded: true,
      decoration: const InputDecoration(
        labelText: 'Card type',
        hintText: 'Detected from the number',
      ),
      items: [
        for (final type in CardType.selectable)
          DropdownMenuItem(
            value: type,
            child: Text(type.label, style: AppTypography.body),
          ),
      ],
      onChanged: (type) => setState(() => _cardType = type),
    );
  }

  Widget _cvvField() {
    return TextField(
      controller: _cvvController,
      keyboardType: TextInputType.number,
      obscureText: true,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(4),
      ],
      style: AppTypography.body,
      decoration: const InputDecoration(
        labelText: 'CVV',
        hintText: '3 or 4 digits on the card',
      ),
    );
  }

  Widget _countryField() {
    return TextField(
      controller: _countryController,
      readOnly: true,
      showCursor: false,
      onTap: _pickCountry,
      style: AppTypography.body,
      decoration: const InputDecoration(
        labelText: 'Issuing country',
        hintText: 'Select a country',
        suffixIcon: Icon(Icons.arrow_drop_down),
      ),
    );
  }

  Future<void> _pickCountry() async {
    final picked = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => CountryPickerScreen(
          title: 'Issuing country',
          countries: countryCatalog,
          bannedCountries: widget.services.session.bannedCountryList,
        ),
      ),
    );
    if (!mounted || picked == null) return;
    setState(() => _country = picked);
    _countryController.text = picked;
  }

  Widget _errorLabel() {
    if (_errorMessage == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(_errorMessage!, style: AppTypography.error),
    );
  }

  Widget _actionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: _scanCard,
          icon: const Icon(Icons.camera_alt_outlined),
          label: const Text('Scan card'),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _submitCard,
          child: const Text('Validate and save'),
        ),
      ],
    );
  }

  void _onNumberChanged(String value) {
    final detected = CardTypeDetector.typeOf(CardNumberRules.digitsOnly(value));
    if (detected != CardType.unknown) {
      setState(() => _cardType = detected);
    }
  }

  Future<void> _scanCard() async {
    final String? number;
    try {
      number = await widget.services.scanner.scanCardNumber();
    } on Exception catch (error) {
      _showMessage('Scan failed: $error');
      return;
    }
    if (!mounted) return;
    if (number == null) {
      _showMessage('No valid card number was found in the photo.');
      return;
    }
    _numberController.text = number;
    _onNumberChanged(number);
  }

  Future<void> _submitCard() async {
    final draft = _currentDraft();
    final validator = CardValidator(widget.services.session.bannedCountryList);
    final error = validator.validationError(draft);
    if (error != null) {
      setState(() => _errorMessage = error);
      return;
    }
    final card = CapturedCard.fromDigits(
      digits: CardNumberRules.digitsOnly(draft.number),
      cardType: draft.cardType,
      issuingCountry: draft.issuingCountry!,
    );
    final outcome = await widget.services.session.capture(card);
    if (!mounted) return;
    if (outcome == CaptureOutcome.duplicate) {
      setState(() => _errorMessage = 'This card has already been captured.');
      return;
    }
    _resetForm();
    _showMessage('Card saved.');
  }

  CardDraft _currentDraft() {
    return CardDraft(
      number: _numberController.text,
      cardType: _cardType ?? CardType.unknown,
      cvv: _cvvController.text,
      issuingCountry: _country,
    );
  }

  void _resetForm() {
    setState(() {
      _numberController.clear();
      _cvvController.clear();
      _countryController.clear();
      _cardType = null;
      _country = null;
      _errorMessage = null;
    });
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text, style: AppTypography.body)),
    );
  }

  void _openBannedCountries() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BannedCountriesScreen(session: widget.services.session),
      ),
    );
  }

  void _openCapturedCards() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CapturedCardsScreen(session: widget.services.session),
      ),
    );
  }
}
