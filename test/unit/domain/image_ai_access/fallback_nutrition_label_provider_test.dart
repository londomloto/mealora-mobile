import 'dart:typed_data' show Uint8List;

import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/domain/image_ai_access/fallback_nutrition_label_provider.dart';
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
  final bytes = Uint8List.fromList(<int>[1, 2, 3]);

  test(
    'cloud berhasil -> OCR SHALL TIDAK pernah dipanggil (task 4.7/4.8)',
    () async {
      final cloud = MockNutritionLabelProvider(
        LabelExtractionRead(_fixtureExtraction()),
      );
      final ocr = MockNutritionLabelProvider(
        const LabelExtractionServiceUnavailable(
          LabelServiceFailureReason.refused,
        ),
      );
      final composite = FallbackNutritionLabelProvider(
        primary: cloud,
        fallback: ocr,
      );

      final outcome = await composite.extractLabel(bytes);

      expect(outcome, isA<LabelExtractionRead>());
      expect(cloud.callCount, 1);
      expect(
        ocr.callCount,
        0,
        reason:
            'OCR tidak boleh dicoba kalau cloud sudah berhasil — setiap '
            'panggilan OCR yang tak perlu kehilangan maksud fallback-nya',
      );
    },
  );

  for (final reason in LabelServiceFailureReason.values) {
    test(
      'cloud gagal ($reason) -> OCR dicoba dan hasilnya dipakai (spec '
      'image-ai-access, "Kegagalan layanan cloud dicoba lewat OCR lokal")',
      () async {
        final cloud = MockNutritionLabelProvider(
          LabelExtractionServiceUnavailable(reason),
        );
        final ocr = MockNutritionLabelProvider(
          LabelExtractionRead(_fixtureExtraction()),
        );
        final composite = FallbackNutritionLabelProvider(
          primary: cloud,
          fallback: ocr,
        );

        final outcome = await composite.extractLabel(bytes);

        expect(outcome, isA<LabelExtractionRead>());
        expect(cloud.callCount, 1);
        expect(ocr.callCount, 1);
      },
    );
  }

  test('cloud gagal DAN OCR juga gagal -> ServiceUnavailable diteruskan apa '
      'adanya, bermuara ke jalur manual (task 4.9)', () async {
    final cloud = MockNutritionLabelProvider(
      const LabelExtractionServiceUnavailable(
        LabelServiceFailureReason.offline,
      ),
    );
    final ocr = MockNutritionLabelProvider(
      const LabelExtractionServiceUnavailable(
        LabelServiceFailureReason.refused,
      ),
    );
    final composite = FallbackNutritionLabelProvider(
      primary: cloud,
      fallback: ocr,
    );

    final outcome = await composite.extractLabel(bytes);

    expect(outcome, isA<LabelExtractionServiceUnavailable>());
    expect(
      (outcome as LabelExtractionServiceUnavailable).reason,
      LabelServiceFailureReason.refused,
      reason:
          'alasan kegagalan TERAKHIR (OCR) yang dipakai layar, sesuai '
          'kegagalannya sendiri — bukan alasan kegagalan cloud yang sudah '
          'lewat',
    );
  });

  test(
    'gambar yang sama diteruskan apa adanya ke OCR saat fallback terjadi',
    () async {
      final cloud = MockNutritionLabelProvider(
        const LabelExtractionServiceUnavailable(
          LabelServiceFailureReason.quotaExceeded,
        ),
      );
      final ocr = MockNutritionLabelProvider(
        LabelExtractionRead(_fixtureExtraction()),
      );
      final composite = FallbackNutritionLabelProvider(
        primary: cloud,
        fallback: ocr,
      );

      await composite.extractLabel(bytes);

      expect(cloud.capturedImages.single, bytes);
      expect(
        ocr.capturedImages.single,
        bytes,
        reason: 'draf foto yang sama tidak hilang/diubah saat jatuh ke OCR',
      );
    },
  );
}
