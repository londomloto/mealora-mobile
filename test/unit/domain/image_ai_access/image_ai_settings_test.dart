import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/domain/image_ai_access/image_ai_settings.dart';

void main() {
  group('ImageUploadConsentPreference', () {
    test('bawaan adalah askEachTime (spec, tanya setiap kali)', () {
      expect(
        ImageUploadConsentPreference.defaultValue,
        ImageUploadConsentPreference.askEachTime,
      );
    });

    test('stableCode bolak-balik untuk setiap nilai', () {
      for (final value in ImageUploadConsentPreference.values) {
        expect(
          ImageUploadConsentPreference.fromStableCode(value.stableCode),
          value,
        );
      }
    });

    test('kode tidak dikenal jatuh ke bawaan, bukan melempar', () {
      expect(
        ImageUploadConsentPreference.fromStableCode('garbage'),
        ImageUploadConsentPreference.defaultValue,
      );
    });
  });

  group('ImageRetentionPreference', () {
    test('bawaan adalah deleteAfterLogging (rancangan 35)', () {
      expect(
        ImageRetentionPreference.defaultValue,
        ImageRetentionPreference.deleteAfterLogging,
      );
    });

    test('stableCode bolak-balik untuk setiap nilai', () {
      for (final value in ImageRetentionPreference.values) {
        expect(
          ImageRetentionPreference.fromStableCode(value.stableCode),
          value,
        );
      }
    });
  });
}
