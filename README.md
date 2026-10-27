# Credible

Verify Credit Cards. Flutter app for admins to submit card details for validation. Valid cards are saved to local storage. Duplicate cards are rejected.

## Features

- Enter card number, card type, CVV, and issuing country
- Card type is inferred from the number (Visa, Mastercard, Amex, Discover, Diners, JCB, UnionPay, Maestro)
- Scan a card with the camera to fill in the number
- Reject cards issued in banned countries (list is configurable)
- Show cards captured this session; "View Previous" also loads cards stored earlier

## Layout

```
lib/
  main.dart               Single entry point
  modules/
    app/                  App shell and service wiring
    theme/                Typography, button style, theme
    models/               Card type, draft, captured card
    validation/           Luhn, type detection, form validator
    config/               Banned country list loader
    data/                 Country catalog
    storage/              Local storage for cards and settings
    session/              In-session list and duplicate check
    scanning/             Camera capture and card number extraction
    screens/              Form and captured cards screens
    widgets/              Reusable widgets
assets/config/banned_countries.json   Banned countries (editable)
```

## Configuration

The banned country list can be changed in the app: tap the gear icon on the form screen to open Banned countries. Once a list is saved there, it is used instead of the default.

The default list is `assets/config/banned_countries.json`. Add country names exactly as they appear in `lib/modules/data/country_catalog.dart`. Matching ignores case and extra spaces. Rebuild the app after editing the file.

## Styling

- Fonts and text styles: `lib/modules/theme/app_typography.dart`
- Button size and shape: `lib/modules/theme/app_button_style.dart`

## Packages

| Package | Why |
| --- | --- |
| shared_preferences | Local storage for captured cards and the "View Previous" setting |
| crypto | SHA-256 fingerprint for duplicate detection |
| image_picker | Camera capture for scanning |
| google_mlkit_text_recognition | On-device text recognition for the card number |

## Notes

- The CVV is checked but never stored.
- Stored cards keep only the masked number (last four digits), type, and country.
- Duplicates are detected with a SHA-256 fingerprint of the full number.

## Tests

```
flutter test
```
