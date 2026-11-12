import 'dart:io' show Directory, File;
import 'dart:typed_data' show Uint8List;

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:mealora/domain/image_ai_access/label_extraction.dart';
import 'package:mealora/domain/image_ai_access/label_service_failure.dart';
import 'package:mealora/domain/image_ai_access/label_text_parser.dart';
import 'package:mealora/domain/image_ai_access/nutrition_label_provider.dart';

/// Pembaca teks yang dapat diganti — pembungkus tipis di atas
/// `TextRecognizer.processImage` (google_mlkit_text_recognition) yang
/// sesungguhnya memerlukan kanal platform dan tidak dapat dijalankan pada
/// pengujian unit tanpa perangkat. Implementasi tiruan dipasang lewat
/// konstruktor [OcrNutritionLabelProvider.new] pada pengujian (task 3.12).
typedef TextRecognitionReader = Future<String> Function(Uint8List imageBytes);

/// Implementasi [NutritionLabelProvider] kedua yang membaca label di
/// perangkat lewat pengenalan teks ML Kit, TANPA mengunggah gambar maupun
/// memanggil proksi inferensi (Design D11, change 010) — dipakai
/// `FallbackNutritionLabelProvider` (lib/domain/image_ai_access) sebagai
/// langkah antara ketika penyedia cloud gagal.
///
/// Pemetaan teks ke [LabelExtraction] didelegasikan ke [LabelTextParser]
/// (lib/domain/image_ai_access) yang diuji terpisah dari plugin ini (task
/// 3.12); kelas ini sendiri hanya bertanggung jawab memanggil pengenalan
/// teks dan menerjemahkan kegagalannya — gambar kosong/buram tanpa teks
/// yang bisa dibaca SHALL dilaporkan lewat
/// [LabelExtractionServiceUnavailable], BUKAN [LabelExtraction] kosong
/// (spec image-ai-access, "OCR lokal tidak menemukan teks yang berguna").
final class OcrNutritionLabelProvider implements NutritionLabelProvider {
  OcrNutritionLabelProvider({
    TextRecognitionReader? recognizeText,
    this.parser = const LabelTextParser(),
  }) : _recognizeText = recognizeText ?? recognizeWithMlKit;

  final TextRecognitionReader _recognizeText;
  final LabelTextParser parser;

  @override
  Future<LabelExtractionOutcome> extractLabel(Uint8List imageBytes) async {
    final String text;
    try {
      text = await _recognizeText(imageBytes);
    } on Object {
      // Kanal platform gagal (mis. komponen pengenalan teks belum siap di
      // perangkat) — dilaporkan sebagai keadaan yang dirancang, bukan
      // pengecualian mentah ke pemanggil, persis pola `VisionProxyLabelProvider`
      // (lib/data/remote, change 010).
      return const LabelExtractionServiceUnavailable(
        LabelServiceFailureReason.refused,
      );
    }
    if (text.trim().isEmpty) {
      return const LabelExtractionServiceUnavailable(
        LabelServiceFailureReason.refused,
      );
    }
    return LabelExtractionRead(parser.parse(text));
  }

  static Future<String> recognizeWithMlKit(Uint8List imageBytes) async {
    final tempDir = Directory.systemTemp.createTempSync('mealora_ocr_');
    try {
      final tempFile = File('${tempDir.path}/label.jpg');
      await tempFile.writeAsBytes(imageBytes);
      final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
      try {
        final input = InputImage.fromFilePath(tempFile.path);
        final result = await recognizer.processImage(input);
        if (kDebugMode) {
          // Teks mentah ML Kit, sebelum LabelTextParser — dipakai
          // mendiagnosis keluhan "nilai sering kosong" tanpa menebak
          // bagaimana ML Kit sesungguhnya memisahkan baris tabel di
          // perangkat; tidak pernah tercetak pada build rilis.
          debugPrint('OCR lokal — teks mentah:\n${result.text}');
        }
        return result.text;
      } finally {
        await recognizer.close();
      }
    } finally {
      await tempDir.delete(recursive: true);
    }
  }
}
