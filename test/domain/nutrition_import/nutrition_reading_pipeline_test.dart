import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/domain/image_ai_access/label_service_failure.dart';
import 'package:mealora/domain/nutrition_import/nutrition_import.dart';
import 'package:mealora/domain/nutrition_import/nutrition_reading.dart';

const NutritionReading _reading = NutritionReading(
  sourceKind: NutritionSourceKind.general,
  basis: NutritionBasis.unread,
  energyKcal: NutrientReading.read(200),
  proteinGrams: NutrientReading.unread,
  carbohydrateGrams: NutrientReading.unread,
  fatGrams: NutrientReading.unread,
);

const NutritionReading _empty = NutritionReading(
  sourceKind: NutritionSourceKind.unknown,
  basis: NutritionBasis.unread,
  energyKcal: NutrientReading.unread,
  proteinGrams: NutrientReading.unread,
  carbohydrateGrams: NutrientReading.unread,
  fatGrams: NutrientReading.unread,
);

final class _FakeImage implements NutritionImageReader {
  _FakeImage(this.outcome);
  final NutritionReadOutcome outcome;
  int calls = 0;

  @override
  Future<NutritionReadOutcome> readImage(Uint8List imageBytes) async {
    calls++;
    return outcome;
  }
}

final class _FakeText implements NutritionTextReader {
  _FakeText(this.outcome);
  final NutritionReadOutcome outcome;
  final List<String> sent = <String>[];

  @override
  Future<NutritionReadOutcome> readText(String text) async {
    sent.add(text);
    return outcome;
  }
}

void main() {
  final bytes = Uint8List.fromList(<int>[1, 2, 3]);
  const unavailable = NutritionReadUnavailable(
    LabelServiceFailureReason.quotaExceeded,
  );
  const ocrText = 'Energi Total 150 kkal\nProtein 3 g\nLemak total 5 g';
  const vision = NutritionReadSuccess(_reading, ReadingTier.vision);
  const textOk = NutritionReadSuccess(_reading, ReadingTier.text);

  NutritionReadingPipeline pipeline(
    _FakeImage image,
    _FakeText text, {
    Future<String> Function(Uint8List)? ocr,
  }) => NutritionReadingPipeline(
    imageReader: image,
    textReader: text,
    recognizeText: ocr ?? (_) async => ocrText,
  );

  group('NutritionReadingPipeline (design D3, revisi uji HP #5)', () {
    test(
      'analisis tulisan: hanya teks OCR dikirim, foto tidak diunggah',
      () async {
        final image = _FakeImage(vision);
        final text = _FakeText(textOk);
        final out = await pipeline(image, text).readImage(bytes);

        expect(image.calls, 0);
        expect(text.sent.single, ocrText);
        expect((out as NutritionReadSuccess).tier, ReadingTier.text);
      },
    );

    test('layanan teks tidak tersedia → dibaca di perangkat', () async {
      final image = _FakeImage(vision);
      final out = await pipeline(
        image,
        _FakeText(unavailable),
      ).readImage(bytes);

      final success = out as NutritionReadSuccess;
      expect(success.tier, ReadingTier.offline);
      expect(success.reading.energyKcal.proposed, 150);
      expect(image.calls, 0, reason: 'tidak ada unggah otomatis');
    });

    test('teks terbaca tanpa angka gizi → NoText, tanpa unggah', () async {
      final image = _FakeImage(vision);
      final out = await pipeline(
        image,
        _FakeText(const NutritionReadSuccess(_empty, ReadingTier.text)),
      ).readImage(bytes);

      expect(out, isA<NutritionReadNoText>());
      expect(image.calls, 0);
    });

    test('tidak ada tulisan terbaca → NoText, tanpa unggah', () async {
      final image = _FakeImage(vision);
      final text = _FakeText(textOk);
      final out = await pipeline(
        image,
        text,
        ocr: (_) async => '   ',
      ).readImage(bytes);

      expect(out, isA<NutritionReadNoText>());
      expect(image.calls, 0);
      expect(text.sent, isEmpty);
    });

    test('readImage tidak pernah mengirim foto ke vision', () async {
      final image = _FakeImage(vision);
      final out = await pipeline(image, _FakeText(textOk)).readImage(bytes);

      expect(image.calls, 0);
      expect((out as NutritionReadSuccess).tier, ReadingTier.text);
    });

    test('analyzePhoto mengirim foto ke vision', () async {
      final image = _FakeImage(vision);
      final out = await pipeline(image, _FakeText(textOk)).analyzePhoto(bytes);

      expect(image.calls, 1);
      expect((out as NutritionReadSuccess).tier, ReadingTier.vision);
    });

    test('teks OCR panjang dipotong ke 4000 karakter', () async {
      final text = _FakeText(textOk);
      await pipeline(
        _FakeImage(unavailable),
        text,
        ocr: (_) async => 'a' * 5000,
      ).readImage(bytes);

      expect(text.sent.single.length, maxNutritionTextChars);
    });
  });
}
