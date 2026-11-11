import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/domain/image_ai_access/label_extraction.dart';
import 'package:mealora/domain/image_ai_access/reading_confidence.dart';
import 'package:mealora/domain/packaged_food/serving_basis.dart';

void main() {
  group('ExtractedBasisKind', () {
    test('perServing dan perHundredGrams punya padanan ServingBasis', () {
      expect(
        ExtractedBasisKind.perServing.asServingBasis,
        ServingBasis.perServing,
      );
      expect(
        ExtractedBasisKind.perHundredGrams.asServingBasis,
        ServingBasis.perHundredGrams,
      );
    });

    test(
      'unread tidak punya padanan — SHALL diminta ke pengguna (Design D6)',
      () {
        expect(ExtractedBasisKind.unread.asServingBasis, isNull);
      },
    );
  });

  group('ExtractedNumber', () {
    test('unread SHALL TIDAK membawa value (spec, nilai tidak terbaca tetap '
        'belum diketahui)', () {
      expect(
        () => ExtractedNumber(confidence: ReadingConfidence.unread, value: 10),
        throwsA(isA<AssertionError>()),
      );
    });

    test('genuinelyAbsent adalah unread tanpa value — titik awal yang sah '
        'untuk "memang tidak tercantum" (task 7.7)', () {
      const absent = ExtractedNumber.genuinelyAbsent;
      expect(absent.confidence, ReadingConfidence.unread);
      expect(absent.value, isNull);
    });

    test('needsCheck boleh membawa value (tebakan model yang masih harus '
        'diperiksa)', () {
      const number = ExtractedNumber(
        confidence: ReadingConfidence.needsCheck,
        value: 12.5,
        unit: 'g',
      );
      expect(number.value, 12.5);
    });
  });

  group('ReadingConfidence.needsUserAttention', () {
    test(
      'confident tidak menahan perhatian; needsCheck dan unread menahan',
      () {
        expect(ReadingConfidence.confident.needsUserAttention, isFalse);
        expect(ReadingConfidence.needsCheck.needsUserAttention, isTrue);
        expect(ReadingConfidence.unread.needsUserAttention, isTrue);
      },
    );
  });
}
