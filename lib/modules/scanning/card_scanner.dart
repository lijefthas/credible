// AUTHOR: L. I. Jefthas
// DATE: October 2026
// VERSION: 0.0.1

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import 'card_number_extractor.dart';

/// Takes a photo of a card and returns the card number read from it.
class CardScanner {
  CardScanner()
      : _picker = ImagePicker(),
        _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  final ImagePicker _picker;
  final TextRecognizer _recognizer;

  /// Returns the card number found in the photo, or null if the user cancelled or nothing was read.
  Future<String?> scanCardNumber() async {
    final photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo == null) {
      return null;
    }
    final recognized = await _recognizer.processImage(InputImage.fromFilePath(photo.path));
    return CardNumberExtractor.numberFrom(recognized.text);
  }

  Future<void> dispose() => _recognizer.close();
}
