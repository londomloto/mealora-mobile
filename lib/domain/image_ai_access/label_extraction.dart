import 'package:mealora/domain/image_ai_access/reading_confidence.dart';
import 'package:mealora/domain/packaged_food/serving_basis.dart';

/// Basis nilai gizi pada label SEBELUM dipastikan pengguna — berbeda dari
/// `ServingBasis` (domain/packaged_food, change 009): basis itu SHALL
/// selalu diketahui pada rekaman tersimpan, sedangkan hasil pembacaan model
/// boleh [unread] (spec, "Basis tidak terbaca" — sistem meminta pengguna
/// menetapkannya, tidak pernah menebak; Design D6, change 010).
enum ExtractedBasisKind {
  perServing,
  perHundredGrams,
  unread;

  /// `null` untuk [unread] — tidak ada padanan sampai pengguna menetapkan
  /// sendiri (task 7.2).
  ServingBasis? get asServingBasis => switch (this) {
    ExtractedBasisKind.perServing => ServingBasis.perServing,
    ExtractedBasisKind.perHundredGrams => ServingBasis.perHundredGrams,
    ExtractedBasisKind.unread => null,
  };
}

/// Basis label hasil bacaan model, beserta keyakinannya (spec
/// nutrition-label-extraction, "Basis label dibaca dan ditegaskan").
final class ExtractedBasis {
  const ExtractedBasis({required this.kind, required this.confidence});

  final ExtractedBasisKind kind;
  final ReadingConfidence confidence;
}

/// Satu nilai numerik hasil bacaan model — `value` dan `unit` SHALL `null`
/// ketika [confidence] adalah [ReadingConfidence.unread] (spec, "Nilai yang
/// tidak terbaca tetap belum diketahui"): tidak ada nol, tidak ada
/// tebakan. Boleh `null` juga pada [ReadingConfidence.needsCheck] bila
/// model sendiri tidak mengembalikan angka tebakan untuk nilai yang
/// diragukannya.
final class ExtractedNumber {
  const ExtractedNumber({required this.confidence, this.value, this.unit})
    : assert(
        confidence != ReadingConfidence.unread || value == null,
        'ReadingConfidence.unread SHALL TIDAK membawa value — pelanggaran '
        'ini adalah kesalahan pemetaan klien provider, bukan jalur '
        'pengguna (spec, "Nilai yang tidak terbaca tetap belum diketahui").',
      );

  /// Satu-satunya titik awal yang sah untuk nilai yang memang tidak
  /// tercantum pada kemasan (task 7.7) — dipakai controller layar
  /// peninjauan saat pengguna menyatakan demikian, BUKAN hasil model.
  static const ExtractedNumber genuinelyAbsent = ExtractedNumber(
    confidence: ReadingConfidence.unread,
  );

  final double? value;
  final String? unit;
  final ReadingConfidence confidence;
}

/// Hasil satu pembacaan panel Informasi Nilai Gizi (spec
/// nutrition-label-extraction) — SATU PUN bidangnya BELUM menjadi data
/// terverifikasi (Requirement "Hasil model tidak pernah menjadi data
/// terverifikasi", image-ai-access); itu terjadi hanya setelah pengguna
/// mengonfirmasi layar peninjauan (`24`).
///
/// `servingSize`/`servingsPerPackage` hanya relevan ketika [basis] bernilai
/// [ExtractedBasisKind.perServing] — layar peninjauan menyembunyikannya
/// untuk basis lain, sama seperti `PackagedFood.unitsPerPackage` (domain
/// packaged_food, change 009).
final class LabelExtraction {
  const LabelExtraction({
    required this.basis,
    required this.servingSize,
    required this.servingsPerPackage,
    required this.energyKcal,
    required this.protein,
    required this.carbohydrate,
    required this.fat,
  });

  final ExtractedBasis basis;
  final ExtractedNumber servingSize;
  final ExtractedNumber servingsPerPackage;
  final ExtractedNumber energyKcal;
  final ExtractedNumber protein;
  final ExtractedNumber carbohydrate;
  final ExtractedNumber fat;
}
