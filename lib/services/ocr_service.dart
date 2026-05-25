import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrService {
  final TextRecognizer _recognizer = TextRecognizer(script: TextRecognitionScript.latin);

  Future<String> extractText(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final recognizedText = await _recognizer.processImage(inputImage);
    return recognizedText.text.trim();
  }

  Future<void> dispose() async {
    await _recognizer.close();
  }
}
