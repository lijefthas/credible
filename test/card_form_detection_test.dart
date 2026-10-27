// AUTHOR: L. I. Jefthas
// DATE: October 2026

import 'package:credible/modules/app/app_services.dart';
import 'package:credible/modules/scanning/card_scanner.dart';
import 'package:credible/modules/screens/card_form_screen.dart';
import 'package:credible/modules/session/card_session.dart';
import 'package:credible/modules/storage/card_storage.dart';
import 'package:credible/modules/storage/settings_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _pumpForm(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();
  final session = CardSession(
    cardStorage: CardStorage(preferences),
    settingsStorage: SettingsStorage(preferences),
  );
  await session.initialize(defaultBannedCountries: const []);
  final services = AppServices(session: session, scanner: CardScanner());
  await tester.pumpWidget(MaterialApp(home: CardFormScreen(services: services)));
}

void main() {
  const number = '4111111111111111';

  testWidgets('detects the card type from a pasted number', (tester) async {
    await _pumpForm(tester);
    await tester.enterText(find.byType(TextField).first, number);
    await tester.pump();

    expect(find.text('Visa'), findsOneWidget);
  });

  testWidgets('detects the card type while typing one digit at a time', (tester) async {
    await _pumpForm(tester);
    for (var i = 1; i <= number.length; i++) {
      await tester.enterText(find.byType(TextField).first, number.substring(0, i));
      await tester.pump();
    }

    expect(find.text('Visa'), findsOneWidget);
  });

  testWidgets('detects the card type after a failed submit', (tester) async {
    await _pumpForm(tester);
    await tester.tap(find.text('Validate and save'));
    await tester.pump();
    await tester.enterText(find.byType(TextField).first, number);
    await tester.pump();

    expect(find.text('Visa'), findsOneWidget);
  });
}
