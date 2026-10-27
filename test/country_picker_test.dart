// AUTHOR: L. I. Jefthas
// DATE: October 2026

import 'package:credible/modules/config/banned_country_list.dart';
import 'package:credible/modules/screens/country_picker_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('banned countries under the red line cannot be picked', (tester) async {
    String? picked;
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => TextButton(
          onPressed: () async {
            picked = await Navigator.of(context).push<String>(MaterialPageRoute(
              builder: (_) => CountryPickerScreen(
                title: 'Issuing country',
                countries: const ['Canada', 'Chile'],
                bannedCountries: BannedCountryList(const ['Chile']),
              ),
            ));
          },
          child: const Text('open'),
        ),
      ),
    ));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Chile'));
    await tester.pumpAndSettle();
    expect(find.byType(CountryPickerScreen), findsOneWidget);
    expect(picked, isNull);

    await tester.tap(find.text('Canada'));
    await tester.pumpAndSettle();
    expect(picked, 'Canada');
  });
}
