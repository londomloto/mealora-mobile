import 'dart:typed_data' show Uint8List;

import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/data/ocr/ocr_nutrition_label_provider.dart';
import 'package:mealora/domain/image_ai_access/label_service_failure.dart';
import 'package:mealora/domain/image_ai_access/nutrition_label_provider.dart';

void main() {
  group('pengenalan teks berhasil', () {
    test(
      'teks yang berguna -> LabelExtractionRead lewat LabelTextParser',
      () async {
        final provider = OcrNutritionLabelProvider(
          recognizeText: (_) async => 'Energi Total 150 kkal\nProtein 2 g\n',
        );

        final outcome = await provider.extractLabel(Uint8List.fromList([1]));

        expect(outcome, isA<LabelExtractionRead>());
        final extraction = (outcome as LabelExtractionRead).extraction;
        expect(extraction.energyKcal.value, 150);
        expect(extraction.protein.value, 2);
      },
    );
  });

  group('pengenalan teks tidak berguna', () {
    test('teks kosong -> ServiceUnavailable(refused), bukan LabelExtraction '
        'kosong yang ditampilkan seolah-olah dibaca', () async {
      final provider = OcrNutritionLabelProvider(
        recognizeText: (_) async => '   \n  ',
      );

      final outcome = await provider.extractLabel(Uint8List.fromList([1]));

      expect(outcome, isA<LabelExtractionServiceUnavailable>());
      expect(
        (outcome as LabelExtractionServiceUnavailable).reason,
        LabelServiceFailureReason.refused,
      );
    });

    test('kanal platform melempar pengecualian -> ServiceUnavailable(refused), '
        'tidak pernah pengecualian mentah ke pemanggil', () async {
      final provider = OcrNutritionLabelProvider(
        recognizeText: (_) async => throw StateError('kanal platform gagal'),
      );

      final outcome = await provider.extractLabel(Uint8List.fromList([1]));

      expect(outcome, isA<LabelExtractionServiceUnavailable>());
      expect(
        (outcome as LabelExtractionServiceUnavailable).reason,
        LabelServiceFailureReason.refused,
      );
    });
  });
}
