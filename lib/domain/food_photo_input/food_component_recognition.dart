import 'package:mealora/domain/image_ai_access/reading_confidence.dart';

/// Perkiraan jumlah satu komponen, beserta keyakinan model (spec
/// food-photo-input, "Ketidakpastian dinyatakan per komponen") — `value`
/// dan `unit` SHALL `null` ketika [confidence] adalah
/// [ReadingConfidence.unread] (pola yang sama dengan `ExtractedNumber`,
/// domain/image_ai_access, change 010): tidak ada tebakan, tidak ada nol.
final class RecognizedQuantity {
  const RecognizedQuantity({required this.confidence, this.value, this.unit})
    : assert(
        confidence != ReadingConfidence.unread || value == null,
        'ReadingConfidence.unread SHALL TIDAK membawa value — kesalahan '
        'pemetaan klien provider, bukan jalur pengguna.',
      );

  final double? value;
  final String? unit;
  final ReadingConfidence confidence;
}

/// Metode masak yang diusulkan untuk sebuah komponen, bila relevan (spec,
/// "Metode masak belum pasti") — `null` ketika [confidence] adalah
/// [ReadingConfidence.unread] (tidak terlihat atau tidak relevan untuk
/// komponen ini, mis. buah segar).
final class RecognizedCookingMethod {
  const RecognizedCookingMethod({required this.confidence, this.value})
    : assert(
        confidence != ReadingConfidence.unread || value == null,
        'ReadingConfidence.unread SHALL TIDAK membawa value.',
      );

  final String? value;
  final ReadingConfidence confidence;
}

/// Satu komponen makanan yang diusulkan dari foto (Design D1, change 011)
/// — HANYA apa yang ada di piring dan kira-kira seberapa banyak. SATU PUN
/// bidangnya adalah nilai gizi: itu datang dari padanan katalog, tidak
/// pernah dari sini (spec, "Nilai gizi berasal dari catatan makanan yang
/// dapat ditelusuri").
final class RecognizedComponent {
  const RecognizedComponent({
    required this.foodNameGuess,
    required this.quantity,
    required this.cookingMethod,
  });

  /// Tebakan nama makanan dari model — dipakai sebagai kueri awal pemadanan
  /// katalog (`FoodComponentMatcher`), BUKAN disimpan sebagai nama catatan
  /// tersendiri.
  final String foodNameGuess;

  final RecognizedQuantity quantity;
  final RecognizedCookingMethod cookingMethod;
}

/// Hasil satu panggilan pengenalan komponen — mengusulkan nol atau lebih
/// komponen (spec, "Beberapa komponen dalam satu foto").
final class FoodPhotoRecognition {
  const FoodPhotoRecognition({required this.components});

  final List<RecognizedComponent> components;
}
