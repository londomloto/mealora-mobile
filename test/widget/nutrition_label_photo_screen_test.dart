import 'dart:typed_data' show Uint8List;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/core/clock/fixed_clock.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/data/local/ui_preference_dao.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/domain/image_ai_access/image_ai_settings.dart';
import 'package:mealora/domain/image_ai_access/label_extraction.dart';
import 'package:mealora/domain/image_ai_access/label_service_failure.dart';
import 'package:mealora/domain/image_ai_access/mock_nutrition_label_provider.dart';
import 'package:mealora/domain/image_ai_access/nutrition_label_provider.dart';
import 'package:mealora/domain/image_ai_access/reading_confidence.dart';
import 'package:mealora/features/diary/nutrition_label_photo_screen.dart';
import 'package:mealora/features/diary/nutrition_label_review_screen.dart';
import 'package:mealora/features/diary/packaged_food_manual_fill_screen.dart';

import 'harness.dart';

LabelExtraction _fixtureExtraction() => const LabelExtraction(
  basis: ExtractedBasis(
    kind: ExtractedBasisKind.perServing,
    confidence: ReadingConfidence.confident,
  ),
  servingSize: ExtractedNumber(
    confidence: ReadingConfidence.confident,
    value: 30,
  ),
  servingsPerPackage: ExtractedNumber(
    confidence: ReadingConfidence.confident,
    value: 2,
  ),
  energyKcal: ExtractedNumber(
    confidence: ReadingConfidence.confident,
    value: 150,
  ),
  protein: ExtractedNumber(confidence: ReadingConfidence.confident, value: 2),
  carbohydrate: ExtractedNumber(
    confidence: ReadingConfidence.confident,
    value: 18,
  ),
  fat: ExtractedNumber(confidence: ReadingConfidence.confident, value: 7),
);

/// `23 · Foto label kemasan` (task 6.1-6.5) dan task 4.6 (kegagalan layanan
/// dengan penyedia tiruan).
///
/// Pratinjau kamera sungguhan (`CameraController`) tidak dapat ditiru di
/// lingkungan uji — sama seperti `BarcodeScanScreen` (change 009) yang juga
/// tidak punya uji widget untuk jalur kamera sungguhan. `debugSkipCameraInit`
/// melewati inisialisasi itu langsung ke keadaan siap, dan `debugCapture`
/// menggantikan `_controller.takePicture()`, sehingga logika di SEKITAR
/// kamera (gerbang persetujuan, pengiriman, kegagalan, jalur manual) tetap
/// teruji penuh.
void main() {
  late AppDatabase database;

  setUp(() {
    database = createWidgetTestDatabase();
  });

  tearDown(() => database.close());

  /// PNG 1×1 transparan yang sah — layar tinjau (24) mendekode bita ini
  /// lewat `Image.memory`, jadi perlu gambar yang benar-benar valid.
  final tinyValidPng = Uint8List.fromList(<int>[
    0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
    0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, //
    0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, //
    0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, //
    0x89, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x44, 0x41, //
    0x54, 0x78, 0x9C, 0x62, 0x00, 0x01, 0x00, 0x00, //
    0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, //
    0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, //
    0x42, 0x60, 0x82, //
  ]);

  Future<Uint8List> fakeCapture() async => tinyValidPng;

  Widget buildScreen({
    required NutritionLabelProvider provider,
    Future<Uint8List> Function()? capture,
  }) {
    return wrapForTest(
      NutritionLabelPhotoScreen(
        barcode: '8991234567890',
        debugSkipCameraInit: true,
        debugCapture: capture ?? fakeCapture,
      ),
      database: database,
      overrides: <Override>[
        nutritionLabelProviderProvider.overrideWithValue(provider),
      ],
    );
  }

  Future<void> setConsentPreference(ImageUploadConsentPreference value) {
    return UiPreferenceDao(
      database,
      clock: FixedClock(
        instantUtc: DateTime.utc(2026, 11, 8),
        timeZoneId: 'Asia/Jakarta',
        utcOffset: const Duration(hours: 7),
      ),
    ).write(UiPreferenceKeys.imageUploadConsent, value.stableCode);
  }

  testWidgets(
    'tautan isi manual membuka pengisian manual tanpa memotret (task 6.3/6.4)',
    (tester) async {
      var captureCalled = false;
      await tester.pumpWidget(
        buildScreen(
          provider: MockNutritionLabelProvider(
            LabelExtractionRead(_fixtureExtraction()),
          ),
          capture: () async {
            captureCalled = true;
            return fakeCapture();
          },
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Isi label secara manual tanpa unggah'));
      await tester.pumpAndSettle();

      expect(captureCalled, isFalse);
      expect(find.byType(PackagedFoodManualFillScreen), findsOneWidget);
    },
  );

  testWidgets(
    'askEachTime (bawaan): tombol ekstrak nonaktif sampai kotak persetujuan '
    'dicentang, lalu memanggil provider dan pindah ke layar tinjau',
    (tester) async {
      final provider = MockNutritionLabelProvider(
        LabelExtractionRead(_fixtureExtraction()),
      );
      await tester.pumpWidget(buildScreen(provider: provider));
      await tester.pumpAndSettle();

      expect(find.text('Izinkan unggah foto label ini'), findsOneWidget);
      var extractButton = tester.widget<FilledButton>(
        find.ancestor(
          of: find.text('Ekstrak untuk ditinjau'),
          matching: find.byType(FilledButton),
        ),
      );
      expect(extractButton.onPressed, isNull);

      await tester.ensureVisible(find.byType(Checkbox));
      await tester.tap(find.byType(Checkbox));
      await tester.pumpAndSettle();

      extractButton = tester.widget<FilledButton>(
        find.ancestor(
          of: find.text('Ekstrak untuk ditinjau'),
          matching: find.byType(FilledButton),
        ),
      );
      expect(extractButton.onPressed, isNotNull);

      await tester.ensureVisible(find.text('Ekstrak untuk ditinjau'));
      await tester.tap(find.text('Ekstrak untuk ditinjau'));
      await tester.pumpAndSettle();

      expect(provider.callCount, 1);
      expect(find.byType(NutritionLabelReviewScreen), findsOneWidget);
    },
  );

  testWidgets(
    'alwaysAllow menyembunyikan kotak persetujuan dan tombol langsung aktif',
    (tester) async {
      await setConsentPreference(ImageUploadConsentPreference.alwaysAllow);

      await tester.pumpWidget(
        buildScreen(
          provider: MockNutritionLabelProvider(
            LabelExtractionRead(_fixtureExtraction()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Izinkan unggah foto label ini'), findsNothing);
      await tester.ensureVisible(find.text('Ekstrak untuk ditinjau'));
      await tester.tap(find.text('Ekstrak untuk ditinjau'));
      await tester.pumpAndSettle();

      expect(find.byType(NutritionLabelReviewScreen), findsOneWidget);
    },
  );

  for (final reason in LabelServiceFailureReason.values) {
    testWidgets(
      'kegagalan layanan ($reason) menampilkan bahasa awam, jalur manual '
      'tetap ada, dan foto tidak hilang (task 4.1/4.2/4.3/4.4/4.6)',
      (tester) async {
        await setConsentPreference(ImageUploadConsentPreference.alwaysAllow);
        final provider = MockNutritionLabelProvider(
          LabelExtractionServiceUnavailable(reason),
        );
        await tester.pumpWidget(buildScreen(provider: provider));
        await tester.pumpAndSettle();

        await tester.ensureVisible(find.text('Ekstrak untuk ditinjau'));
        await tester.tap(find.text('Ekstrak untuk ditinjau'));
        await tester.pumpAndSettle();

        expect(
          find.text('Pembacaan otomatis belum bisa dilakukan'),
          findsOneWidget,
        );
        expect(
          find.textContaining(
            'Foto dan nilai yang sudah kamu isi tetap tersimpan.',
          ),
          findsOneWidget,
        );
        expect(
          find.text('Isi label secara manual tanpa unggah'),
          findsOneWidget,
          reason: 'jalur manual tetap tersedia, bukan jalan buntu',
        );
        expect(find.text('Coba lagi dengan foto ini'), findsOneWidget);

        await tester.ensureVisible(find.text('Coba lagi dengan foto ini'));
        await tester.tap(find.text('Coba lagi dengan foto ini'));
        await tester.pumpAndSettle();

        expect(
          provider.callCount,
          2,
          reason: 'foto yang sama dikirim ulang tanpa memotret ulang',
        );
      },
    );
  }

  testWidgets(
    'konfirmasi berhasil setelah kegagalan membuktikan foto yang sama '
    'dipakai ulang, bukan diganti',
    (tester) async {
      await setConsentPreference(ImageUploadConsentPreference.alwaysAllow);
      final provider =
          MockNutritionLabelProvider.sequence(<LabelExtractionOutcome>[
            const LabelExtractionServiceUnavailable(
              LabelServiceFailureReason.timeout,
            ),
            LabelExtractionRead(_fixtureExtraction()),
          ]);
      await tester.pumpWidget(buildScreen(provider: provider));
      await tester.pumpAndSettle();

      await tester.ensureVisible(find.text('Ekstrak untuk ditinjau'));
      await tester.tap(find.text('Ekstrak untuk ditinjau'));
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.text('Coba lagi dengan foto ini'));
      await tester.tap(find.text('Coba lagi dengan foto ini'));
      await tester.pumpAndSettle();

      expect(provider.capturedImages, hasLength(2));
      expect(
        provider.capturedImages[0],
        provider.capturedImages[1],
        reason: 'bita foto yang dikirim ulang identik dengan yang pertama',
      );
      expect(find.byType(NutritionLabelReviewScreen), findsOneWidget);
    },
  );
}
