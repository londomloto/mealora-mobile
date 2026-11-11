import 'dart:typed_data' show Uint8List;

import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/domain/image_ai_access/label_extraction.dart';
import 'package:mealora/domain/image_ai_access/label_service_failure.dart';
import 'package:mealora/domain/image_ai_access/mock_nutrition_label_provider.dart';
import 'package:mealora/domain/image_ai_access/nutrition_label_provider.dart';
import 'package:mealora/domain/image_ai_access/reading_confidence.dart';

LabelExtraction _fixtureExtraction() => const LabelExtraction(
  basis: ExtractedBasis(
    kind: ExtractedBasisKind.perServing,
    confidence: ReadingConfidence.confident,
  ),
  servingSize: ExtractedNumber(
    confidence: ReadingConfidence.confident,
    value: 30,
    unit: 'g',
  ),
  servingsPerPackage: ExtractedNumber(
    confidence: ReadingConfidence.confident,
    value: 2,
  ),
  energyKcal: ExtractedNumber(
    confidence: ReadingConfidence.confident,
    value: 150,
    unit: 'kkal',
  ),
  protein: ExtractedNumber(confidence: ReadingConfidence.confident, value: 2),
  carbohydrate: ExtractedNumber(
    confidence: ReadingConfidence.confident,
    value: 18,
  ),
  fat: ExtractedNumber.genuinelyAbsent,
);

void main() {
  test('mengembalikan outcome tetap pada setiap panggilan', () async {
    final provider = MockNutritionLabelProvider(
      LabelExtractionRead(_fixtureExtraction()),
    );

    final first = await provider.extractLabel(Uint8List.fromList(<int>[1]));
    final second = await provider.extractLabel(Uint8List.fromList(<int>[2]));

    expect(first, isA<LabelExtractionRead>());
    expect(second, isA<LabelExtractionRead>());
    expect(provider.callCount, 2);
  });

  test('merekam setiap bita gambar yang diterima (pola task 3.8)', () async {
    final provider = MockNutritionLabelProvider(
      const LabelExtractionServiceUnavailable(
        LabelServiceFailureReason.offline,
      ),
    );
    final bytes = Uint8List.fromList(<int>[9, 9, 9]);

    await provider.extractLabel(bytes);

    expect(provider.capturedImages, hasLength(1));
    expect(provider.capturedImages.single, bytes);
  });

  test('sequence mengembalikan outcome berurutan, lalu bertahan di yang '
      'terakhir', () async {
    final provider =
        MockNutritionLabelProvider.sequence(<LabelExtractionOutcome>[
          const LabelExtractionServiceUnavailable(
            LabelServiceFailureReason.timeout,
          ),
          LabelExtractionRead(_fixtureExtraction()),
        ]);
    final bytes = Uint8List.fromList(<int>[1]);

    final first = await provider.extractLabel(bytes);
    final second = await provider.extractLabel(bytes);
    final third = await provider.extractLabel(bytes);

    expect(first, isA<LabelExtractionServiceUnavailable>());
    expect(second, isA<LabelExtractionRead>());
    expect(
      third,
      isA<LabelExtractionRead>(),
      reason: 'bertahan di outcome terakhir setelah sequence habis',
    );
  });
}
