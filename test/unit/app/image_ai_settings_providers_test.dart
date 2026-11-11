import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/domain/image_ai_access/image_ai_settings.dart';

import '../../widget/harness.dart';

/// Pengaturan persetujuan unggah dan retensi foto (change 010, task 3.5/3.6)
/// — bawaan sesuai Design D3/D9, dan tersimpan persisten lewat
/// `UiPreferenceDao` yang sama dengan `selectedDestinationProvider`.
void main() {
  ProviderContainer buildContainer() {
    final database = createWidgetTestDatabase();
    addTearDown(database.close);
    final container = ProviderContainer(
      overrides: <Override>[
        appDatabaseProvider.overrideWithValue(database),
        clockProvider.overrideWithValue(createWidgetTestClock()),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('ImageUploadConsentSetting', () {
    test('bawaan askEachTime sebelum pernah ditulis (Design D3)', () async {
      final container = buildContainer();
      final value = await container.read(
        imageUploadConsentPreferenceProvider.future,
      );
      expect(value, ImageUploadConsentPreference.askEachTime);
    });

    test('tersimpan dan terbaca ulang lewat UiPreferenceDao', () async {
      final container = buildContainer();
      await container.read(imageUploadConsentPreferenceProvider.future);

      await container
          .read(imageUploadConsentPreferenceProvider.notifier)
          .set(ImageUploadConsentPreference.alwaysAllow);

      expect(
        container.read(imageUploadConsentPreferenceProvider).value,
        ImageUploadConsentPreference.alwaysAllow,
      );
    });
  });

  group('ImageRetentionSetting', () {
    test(
      'bawaan deleteAfterLogging sebelum pernah ditulis (rancangan 35)',
      () async {
        final container = buildContainer();
        final value = await container.read(
          imageRetentionPreferenceProvider.future,
        );
        expect(value, ImageRetentionPreference.deleteAfterLogging);
      },
    );

    test('tersimpan dan terbaca ulang lewat UiPreferenceDao', () async {
      final container = buildContainer();
      await container.read(imageRetentionPreferenceProvider.future);

      await container
          .read(imageRetentionPreferenceProvider.notifier)
          .set(ImageRetentionPreference.keepOnDevice);

      expect(
        container.read(imageRetentionPreferenceProvider).value,
        ImageRetentionPreference.keepOnDevice,
      );
    });
  });
}
