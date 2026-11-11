import 'dart:typed_data' show Uint8List;

import 'package:mealora/domain/image_ai_access/label_extraction.dart';
import 'package:mealora/domain/image_ai_access/label_service_failure.dart';

/// Hasil satu panggilan [NutritionLabelProvider.extractLabel] — sealed
/// supaya pemanggil SHALL menangani kedua keadaan secara eksplisit, tidak
/// bisa diam-diam memperlakukan kegagalan sebagai sukses kosong (spec
/// image-ai-access, "Kegagalan layanan selalu bermuara ke jalur manual").
sealed class LabelExtractionOutcome {
  const LabelExtractionOutcome();
}

final class LabelExtractionRead extends LabelExtractionOutcome {
  const LabelExtractionRead(this.extraction);

  final LabelExtraction extraction;
}

final class LabelExtractionServiceUnavailable extends LabelExtractionOutcome {
  const LabelExtractionServiceUnavailable(this.reason);

  final LabelServiceFailureReason reason;
}

/// Antarmuka penyedia model pembacaan label yang dapat diganti (Design D2,
/// D8, change 010) — satu-satunya titik yang disentuh saat penyedia
/// berganti; layar, aturan peninjauan, dan jalur manual SHALL TIDAK
/// berubah (spec, "Penyedia diganti").
///
/// Implementasi SHALL TIDAK melempar pengecualian ke pemanggil untuk
/// kegagalan layanan — luring, waktu tunggu lewat, kuota habis, atau
/// penyedia menolak SEMUANYA dilaporkan lewat
/// [LabelExtractionServiceUnavailable], persis pola `ProductDataSourceClient`
/// (domain/packaged_food, change 009): pemanggil memperlakukan kegagalan
/// sebagai keadaan yang dirancang, bukan sebagai `catch` darurat.
abstract interface class NutritionLabelProvider {
  Future<LabelExtractionOutcome> extractLabel(Uint8List imageBytes);
}
