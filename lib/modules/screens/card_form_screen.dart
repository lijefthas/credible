// AUTHOR: L. I. Jefthas
// DATE: October 2026

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app/app_services.dart';
import '../data/country_catalog.dart';
import '../models/captured_card.dart';
import '../models/card_draft.dart';
import '../models/card_type.dart';
import '../session/card_session.dart';
import '../theme/app_button_style.dart';
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
  static const Color _successGreen = Color(0xFF2E7D32);

  final _numberController = TextEditingController();
  final _cvvController = TextEditingController();
  final _countryController = TextEditingController();
  CardType? _cardType;
  String? _country;
  CardCheckFailure? _failure;
  Set<CardField> _missing = {};

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
      bottomNavigationBar: _bottomBar(),
    );
  }

  Widget _numberField() {
    return TextField(
      controller: _numberController,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[0-9 \-]'))],
      style: AppTypography.body,
      decoration: _decoration(CardField.number, label: 'Card number', hint: '4111 1111 1111 1111'),
      onChanged: _onNumberChanged,
    );
  }

  Widget _typeDropdown() {
    return DropdownButtonFormField<CardType>(
      // ignore: deprecated_member_use - initialValue cannot follow detected type changes
      value: _cardType,
      isExpanded: true,
      decoration: _decoration(CardField.cardType, label: 'Card type', hint: 'Detected from the number'),
      items: [
        for (final type in CardType.selectable)
          DropdownMenuItem(
            value: type,
            child: Text(type.label, style: AppTypography.body),
          ),
      ],
      onChanged: _onTypeChanged,
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
      decoration: _decoration(CardField.cvv, label: 'CVV', hint: '3 or 4 digits on the card'),
      onChanged: (_) => _clearMark(CardField.cvv),
    );
  }

  Widget _countryField() {
    return TextField(
      controller: _countryController,
      readOnly: true,
      showCursor: false,
      onTap: _pickCountry,
      style: AppTypography.body,
      decoration: _decoration(
        CardField.country,
        label: 'Issuing country',
        hint: 'Select a country',
        suffixIcon: const Icon(Icons.arrow_drop_down),
      ),
    );
  }

  /// Builds a field's decoration: a red outline when its check failed, and a red "!" beside the label when it is empty.
  InputDecoration _decoration(
    CardField field, {
    required String label,
    String? hint,
    Widget? suffixIcon,
  }) {
    final border = _isFailing(field)
        ? OutlineInputBorder(borderSide: BorderSide(color: _errorRed, width: 2))
        : null;
    return InputDecoration(
      label: _fieldLabel(field, label),
      hintText: hint,
      suffixIcon: suffixIcon,
      border: border,
      enabledBorder: border,
      focusedBorder: border,
    );
  }

  Widget _fieldLabel(CardField field, String text) {
    if (!_missing.contains(field)) {
      return Text(text);
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(text),
        const SizedBox(width: 4),
        Icon(Icons.priority_high, size: 16, color: _errorRed),
      ],
    );
  }

  Color get _errorRed => Theme.of(context).colorScheme.error;

  bool _isFailing(CardField field) => _failure?.field == field;

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
    _clearMark(CardField.country);
  }

  Widget _errorLabel() {
    final failure = _failure;
    if (failure == null) {
      return const SizedBox.shrink();
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(failure.message, style: AppTypography.error),
    );
  }

  Widget _actionButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ElevatedButton.icon(
          onPressed: _scanCard,
          style: AppButtonStyle.secondary,
          icon: const Icon(Icons.camera_alt_outlined),
          label: const Text('Scan card'),
        ),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: _submitCard,
          style: AppButtonStyle.primary,
          child: const Text('Validate and save'),
        ),
      ],
    );
  }

  Widget _bottomBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton.icon(
          onPressed: _resetForm,
          style: AppButtonStyle.secondary,
          icon: const Icon(Icons.clear),
          label: const Text('Clear form'),
        ),
      ),
    );
  }

  void _onNumberChanged(String value) {
    _clearMark(CardField.number);
    final detected = CardTypeDetector.typeOf(CardNumberRules.digitsOnly(value));
    if (detected != CardType.unknown) {
      setState(() => _cardType = detected);
      _clearMark(CardField.cardType);
    }
  }

  void _onTypeChanged(CardType? type) {
    setState(() => _cardType = type);
    _clearMark(CardField.cardType);
  }

  /// Removes a field's red outline and "!" once the user edits it.
  void _clearMark(CardField field) {
    if (!_missing.contains(field) && !_isFailing(field)) return;
    setState(() {
      _missing = {..._missing}..remove(field);
      if (_isFailing(field)) _failure = null;
    });
  }

  Future<void> _scanCard() async {
    final String? number;
    try {
      number = await widget.services.scanner.scanCardNumber();
    } on Exception catch (error) {
      _showSnackBar('Scan failed: $error', success: false);
      return;
    }
    if (!mounted) return;
    if (number == null) {
      _showSnackBar('No valid card number was found in the photo.', success: false);
      return;
    }
    _numberController.text = number;
    _onNumberChanged(number);
  }

  Future<void> _submitCard() async {
    final draft = _currentDraft();
    final validator = CardValidator(widget.services.session.bannedCountryList);
    final failure = validator.failureFor(draft);
    if (failure != null) {
      _showFailure(failure, validator.missingFields(draft));
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
      _showFailure(const CardCheckFailure(CardField.number, 'This card has already been captured.'), {});
      return;
    }
    _resetForm();
    _showSnackBar('Card saved.', success: true);
  }

  void _showFailure(CardCheckFailure failure, Set<CardField> missing) {
    setState(() {
      _failure = failure;
      _missing = missing;
    });
    _showSnackBar(failure.message, success: false);
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
      _failure = null;
      _missing = {};
    });
  }

  void _showSnackBar(String text, {required bool success}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: success ? _successGreen : _errorRed,
        content: Text(text, style: AppTypography.body.copyWith(color: Colors.white)),
      ),
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
