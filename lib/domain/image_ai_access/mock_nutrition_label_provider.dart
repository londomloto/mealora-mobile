import 'dart:typed_data' show Uint8List;

import 'package:mealora/domain/image_ai_access/nutrition_label_provider.dart';

/// Implementasi tiruan [NutritionLabelProvider] (task 3.1) — dipakai pada
/// pengujian tanpa jaringan, dan pada pengembangan layar sebelum penyedia
/// sungguhan dipilih lewat evaluasi (workorder.md, "paket 5 sampai 14 ...
/// dapat dibangun dan diuji dengan penyedia tiruan").
///
/// Mengembalikan [outcome] yang sama pada SETIAP panggilan — pengujian yang
/// perlu mensimulasikan urutan berbeda (mis. gagal lalu berhasil) memakai
/// [MockNutritionLabelProvider.sequence].
final class MockNutritionLabelProvider implements NutritionLabelProvider {
  MockNutritionLabelProvider(this.outcome) : _sequence = null;

  MockNutritionLabelProvider.sequence(List<LabelExtractionOutcome> outcomes)
    : outcome = outcomes.last,
      _sequence = List<LabelExtractionOutcome>.of(outcomes);

  final LabelExtractionOutcome outcome;
  final List<LabelExtractionOutcome>? _sequence;
  int _callCount = 0;

  /// Salinan setiap `imageBytes` yang diterima — dipakai pengujian untuk
  /// memastikan gambar yang benar-benar dikirim (task 3.8 memakai pola
  /// serupa di sisi jaringan: mengamati permintaan, bukan menebak isinya).
  final List<Uint8List> capturedImages = <Uint8List>[];

  int get callCount => _callCount;

  @override
  Future<LabelExtractionOutcome> extractLabel(Uint8List imageBytes) async {
    capturedImages.add(imageBytes);
    final sequence = _sequence;
    if (sequence == null) {
      _callCount++;
      return outcome;
    }
    final index = _callCount < sequence.length
        ? _callCount
        : sequence.length - 1;
    _callCount++;
    return sequence[index];
  }
}
