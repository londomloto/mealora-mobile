import 'dart:typed_data' show Uint8List;

import 'package:mealora/domain/food_photo_input/food_component_recognition_provider.dart';

/// Implementasi tiruan [FoodComponentRecognitionProvider] (task 2.2) —
/// dipakai pada pengujian tanpa jaringan, dan pada pengembangan layar
/// sebelum penyedia sungguhan dipilih lewat evaluasi (pola yang sama dengan
/// `MockNutritionLabelProvider`, change 010).
///
/// Mengembalikan [outcome] yang sama pada SETIAP panggilan — pengujian yang
/// perlu mensimulasikan urutan berbeda memakai
/// [MockFoodComponentRecognitionProvider.sequence].
final class MockFoodComponentRecognitionProvider
    implements FoodComponentRecognitionProvider {
  MockFoodComponentRecognitionProvider(this.outcome) : _sequence = null;

  MockFoodComponentRecognitionProvider.sequence(
    List<FoodComponentRecognitionOutcome> outcomes,
  ) : outcome = outcomes.last,
      _sequence = List<FoodComponentRecognitionOutcome>.of(outcomes);

  final FoodComponentRecognitionOutcome outcome;
  final List<FoodComponentRecognitionOutcome>? _sequence;
  int _callCount = 0;

  /// Salinan setiap `imageBytes` yang diterima — dipakai pengujian untuk
  /// memastikan gambar yang benar-benar dikirim.
  final List<Uint8List> capturedImages = <Uint8List>[];

  int get callCount => _callCount;

  @override
  Future<FoodComponentRecognitionOutcome> recognizeComponents(
    Uint8List imageBytes,
  ) async {
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
