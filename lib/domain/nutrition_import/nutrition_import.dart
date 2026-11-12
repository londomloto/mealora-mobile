import 'dart:typed_data' show Uint8List;

import 'package:mealora/domain/image_ai_access/label_service_failure.dart';
import 'package:mealora/domain/image_ai_access/label_text_parser.dart';
import 'package:mealora/domain/nutrition_import/nutrition_reading.dart';

/// Batas karakter teks yang dibaca (spec "Teks tempel dibatasi").
const int maxNutritionTextChars = 4000;

sealed class NutritionReadOutcome {
  const NutritionReadOutcome();
}

final class NutritionReadSuccess extends NutritionReadOutcome {
  const NutritionReadSuccess(this.reading, this.tier);

  final NutritionReading reading;
  final ReadingTier tier;
}

/// Layanan tidak tersedia (offline, timeout, kuota, ditolak/error).
final class NutritionReadUnavailable extends NutritionReadOutcome {
  const NutritionReadUnavailable(this.reason);

  final LabelServiceFailureReason reason;
}

/// Tidak ada tulisan yang terbaca pada gambar.
final class NutritionReadNoText extends NutritionReadOutcome {
  const NutritionReadNoText();
}

/// Klien proksi `/parse-nutrition-text` (hanya teks).
abstract interface class NutritionTextReader {
  Future<NutritionReadOutcome> readText(String text);
}

/// Klien proksi `/read-nutrition-image`.
abstract interface class NutritionImageReader {
  Future<NutritionReadOutcome> readImage(Uint8List imageBytes);
}

/// Pengenalan tulisan di perangkat (ML Kit). Mengembalikan teks mentah,
/// atau melempar bila kanal platform gagal.
typedef OnDeviceTextRecognizer = Future<String> Function(Uint8List imageBytes);

/// Pembacaan foto (design D3, direvisi setelah uji HP — temuan #3/#5):
/// - [readImage]: analisis tulisan — OCR di perangkat, hanya teks dibaca AI;
///   bila layanan teks tidak tersedia, teks OCR dibaca di perangkat
///   ([LabelTextParser]). Foto TIDAK pernah diunggah di jalur ini, apa pun
///   preferensi privasi unggah.
/// - [analyzePhoto]: foto dikirim ke AI vision. Hanya dipanggil saat
///   pengguna menekan "Analisis foto dengan AI".
final class NutritionReadingPipeline {
  NutritionReadingPipeline({
    required this.imageReader,
    required this.textReader,
    required this.recognizeText,
    this.parser = const LabelTextParser(),
  });

  final NutritionImageReader imageReader;
  final NutritionTextReader textReader;
  final OnDeviceTextRecognizer recognizeText;
  final LabelTextParser parser;

  Future<NutritionReadOutcome> readImage(Uint8List imageBytes) async {
    var recognized = '';
    try {
      recognized = (await recognizeText(imageBytes)).trim();
    } on Object {
      recognized = '';
    }

    if (recognized.isNotEmpty) {
      final text = recognized.length > maxNutritionTextChars
          ? recognized.substring(0, maxNutritionTextChars)
          : recognized;
      final online = await textReader.readText(text);
      if (online is NutritionReadSuccess && online.reading.hasAnyNutrient) {
        return online;
      }
      if (online is NutritionReadUnavailable) {
        final offline = NutritionReading.fromOfflineExtraction(
          parser.parse(recognized),
          recognized,
        );
        return offline.hasAnyNutrient
            ? NutritionReadSuccess(offline, ReadingTier.offline)
            : const NutritionReadNoText();
      }
    }

    return const NutritionReadNoText();
  }

  /// AI vision atas foto — dipanggil hanya atas tindakan pengguna.
  Future<NutritionReadOutcome> analyzePhoto(Uint8List imageBytes) =>
      imageReader.readImage(imageBytes);
}

/// Nilai hasil tinjau yang mengisi form Buat makanan (spec "Tujuan hasil
/// mengikuti konteks dan jenis sumber"). `null` = biarkan/kosongkan field.
final class NutritionImportResult {
  const NutritionImportResult({
    required this.values,
    this.foodName,
    this.servingLabel,
  });

  factory NutritionImportResult.fromReading(
    NutritionReading reading,
    String Function(double) formatNumber,
  ) => NutritionImportResult(
    foodName: reading.foodName,
    servingLabel: reading.basis.servingLabel(formatNumber),
    values: <ImportNutrient, double?>{
      for (final n in ImportNutrient.values) n: reading.nutrient(n).proposed,
    },
  );

  final String? foodName;
  final String? servingLabel;

  /// Nilai per nutrien; `null` berarti belum diketahui (field dikosongkan).
  final Map<ImportNutrient, double?> values;
}

/// Isi form yang dihasilkan dari [NutritionImportResult] (design D5): nama
/// hanya bila kolom nama masih kosong, sajian hanya bila basis terbaca,
/// nutrien selalu ditimpa (nilai `null` mengosongkan field).
final class FormPrefill {
  const FormPrefill({required this.nutrients, this.name, this.servingLabel});

  factory FormPrefill.from(
    NutritionImportResult result, {
    required String currentName,
    required String Function(double) formatNumber,
  }) {
    final name = result.foodName?.trim();
    return FormPrefill(
      name: currentName.trim().isEmpty && name != null && name.isNotEmpty
          ? _capitalize(name)
          : null,
      servingLabel: result.servingLabel,
      nutrients: <ImportNutrient, String>{
        for (final n in ImportNutrient.values)
          n: switch (result.values[n]) {
            final double v => formatNumber(v),
            null => '',
          },
      },
    );
  }

  final String? name;
  final String? servingLabel;
  final Map<ImportNutrient, String> nutrients;
}

String _capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
