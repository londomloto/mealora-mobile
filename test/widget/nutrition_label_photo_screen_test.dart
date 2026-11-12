import 'dart:typed_data' show Uint8List;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/domain/image_ai_access/label_service_failure.dart';
import 'package:mealora/domain/nutrition_import/nutrition_import.dart';
import 'package:mealora/domain/nutrition_import/nutrition_reading.dart';
import 'package:mealora/features/diary/custom_food_screen.dart';
import 'package:mealora/features/diary/nutrition_import_review_screen.dart';
import 'package:mealora/features/diary/nutrition_label_photo_screen.dart';
import 'package:mealora/features/diary/nutrition_label_review_screen.dart';
import 'package:mealora/features/diary/packaged_food_manual_fill_screen.dart';

import 'harness.dart';

NutritionReading _reading(NutritionSourceKind kind) => NutritionReading(
  sourceKind: kind,
  basis: const NutritionBasis(
    kind: NutritionBasisKind.perHundredGrams,
    amount: 100,
    unit: 'g',
  ),
  energyKcal: const NutrientReading.range(214, 252),
  proteinGrams: const NutrientReading.read(25),
  carbohydrateGrams: const NutrientReading.read(0),
  fatGrams: const NutrientReading.read(15),
);

const NutritionReading _empty = NutritionReading(
  sourceKind: NutritionSourceKind.general,
  basis: NutritionBasis.unread,
  energyKcal: NutrientReading.unread,
  proteinGrams: NutrientReading.unread,
  carbohydrateGrams: NutrientReading.unread,
  fatGrams: NutrientReading.unread,
);

final class _FakeImage implements NutritionImageReader {
  _FakeImage(this.outcome);
  NutritionReadOutcome outcome;
  final List<Uint8List> sent = <Uint8List>[];

  @override
  Future<NutritionReadOutcome> readImage(Uint8List imageBytes) async {
    sent.add(imageBytes);
    return outcome;
  }
}

final class _FakeText implements NutritionTextReader {
  _FakeText(this.outcome);
  NutritionReadOutcome outcome;
  final List<String> sent = <String>[];

  @override
  Future<NutritionReadOutcome> readText(String text) async {
    sent.add(text);
    return outcome;
  }
}

const _unavailable = NutritionReadUnavailable(
  LabelServiceFailureReason.quotaExceeded,
);

/// `88 · Foto info gizi` (change 020, design D3/D4; menggantikan uji layar
/// `23` change 010). Kamera sungguhan dilewati lewat `debugSkipCameraInit`
/// dan `debugCapture`; pembacaan bertingkat memakai pembaca tiruan.
void main() {
  late AppDatabase database;

  setUp(() {
    database = createWidgetTestDatabase();
  });

  tearDown(() => database.close());

  final photo = Uint8List.fromList(<int>[
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

  Widget buildScreen({
    required _FakeImage image,
    required _FakeText text,
    String ocr = 'Energi 150 kkal',
    String? barcode,
    Future<Uint8List> Function()? capture,
    Future<Uint8List?> Function()? gallery,
  }) {
    return wrapForTest(
      NutritionLabelPhotoScreen(
        barcode: barcode,
        debugSkipCameraInit: true,
        debugCapture: capture ?? () async => photo,
        debugPickGallery: gallery,
      ),
      database: database,
      overrides: <Override>[
        nutritionReadingPipelineProvider.overrideWithValue(
          NutritionReadingPipeline(
            imageReader: image,
            textReader: text,
            recognizeText: (_) async => ocr,
          ),
        ),
      ],
    );
  }


  Future<void> tapRead(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Baca info gizi'));
    await tester.tap(find.text('Baca info gizi'));
    await tester.pumpAndSettle();
  }

  testWidgets('tautan isi manual membuka pengisian manual tanpa memotret', (
    tester,
  ) async {
    var captured = false;
    await tester.pumpWidget(
      buildScreen(
        image: _FakeImage(_unavailable),
        text: _FakeText(_unavailable),
        capture: () async {
          captured = true;
          return photo;
        },
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Isi secara manual'));
    await tester.pumpAndSettle();

    expect(captured, isFalse);
    expect(find.byType(PackagedFoodManualFillScreen), findsOneWidget);
  });

  testWidgets('tanpa kotak izin: foto tidak diunggah, teks OCR dibaca AI '
      '(temuan uji HP #5)', (tester) async {
    final image = _FakeImage(
      NutritionReadSuccess(
        _reading(NutritionSourceKind.general),
        ReadingTier.vision,
      ),
    );
    final text = _FakeText(
      NutritionReadSuccess(
        _reading(NutritionSourceKind.general),
        ReadingTier.text,
      ),
    );
    await tester.pumpWidget(buildScreen(image: image, text: text));
    await tester.pumpAndSettle();

    expect(find.byType(Checkbox), findsNothing);
    expect(find.text('Tulisan dibaca di HP'), findsOneWidget);
    await tapRead(tester);

    expect(image.sent, isEmpty, reason: 'foto tidak diunggah otomatis');
    expect(text.sent, hasLength(1));
    expect(find.byType(NutritionImportReviewScreen), findsOneWidget);
  });

  testWidgets(
    'tidak ada info → "Analisis foto dengan AI" mengunggah foto yang sama',
    (tester) async {
      final image = _FakeImage(
        NutritionReadSuccess(
          _reading(NutritionSourceKind.general),
          ReadingTier.vision,
        ),
      );
      await tester.pumpWidget(
        buildScreen(
          image: image,
          text: _FakeText(const NutritionReadSuccess(_empty, ReadingTier.text)),
        ),
      );
      await tester.pumpAndSettle();
      await tapRead(tester);

      expect(find.text('Tidak ada info gizi terbaca'), findsOneWidget);
      expect(image.sent, isEmpty);

      await tester.ensureVisible(find.text('Analisis foto dengan AI'));
      await tester.tap(find.text('Analisis foto dengan AI'));
      await tester.pumpAndSettle();

      expect(image.sent.single, photo);
      expect(find.byType(NutritionImportReviewScreen), findsOneWidget);
    },
  );

  testWidgets(
    'tinjau hasil foto: tautan analisis foto mengganti nilai dengan hasil AI',
    (tester) async {
      const visionReading = NutritionReading(
        sourceKind: NutritionSourceKind.general,
        basis: NutritionBasis.unread,
        energyKcal: NutrientReading.read(321),
        proteinGrams: NutrientReading.unread,
        carbohydrateGrams: NutrientReading.unread,
        fatGrams: NutrientReading.unread,
      );
      final image = _FakeImage(
        const NutritionReadSuccess(visionReading, ReadingTier.vision),
      );
      await tester.pumpWidget(
        buildScreen(
          image: image,
          text: _FakeText(
            NutritionReadSuccess(
              _reading(NutritionSourceKind.general),
              ReadingTier.text,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tapRead(tester);

      expect(find.text('233'), findsOneWidget);
      final link = find.byKey(const ValueKey('nutrition-review-analyze'));
      await tester.ensureVisible(link);
      await tester.tap(link);
      await tester.pumpAndSettle();

      expect(image.sent, hasLength(1));
      expect(find.text('321'), findsOneWidget);
    },
  );

  testWidgets('label kemasan dari menu scan masuk ke tinjau label (alur 010)', (
    tester,
  ) async {
    final image = _FakeImage(_unavailable);
    await tester.pumpWidget(
      buildScreen(
        image: image,
        text: _FakeText(
          NutritionReadSuccess(
            _reading(NutritionSourceKind.packageLabel),
            ReadingTier.text,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Izinkan unggah foto untuk dibaca AI'), findsNothing);
    await tapRead(tester);

    expect(find.byType(NutritionLabelReviewScreen), findsOneWidget);
    expect(image.sent, isEmpty);
  });

  testWidgets(
    'dibuka dari "Barcode tidak ditemukan" selalu jalur produk kemasan',
    (tester) async {
      await tester.pumpWidget(
        buildScreen(
          barcode: '8991234567890',
          image: _FakeImage(_unavailable),
          text: _FakeText(
            NutritionReadSuccess(
              _reading(NutritionSourceKind.general),
              ReadingTier.text,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tapRead(tester);

      expect(find.byType(NutritionLabelReviewScreen), findsOneWidget);
    },
  );

  testWidgets(
    'info gizi umum dari menu scan → tinjau → form Buat makanan terisi',
    (tester) async {
      await tester.pumpWidget(
        buildScreen(
          image: _FakeImage(_unavailable),
          text: _FakeText(
            NutritionReadSuccess(
              _reading(NutritionSourceKind.general),
              ReadingTier.text,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tapRead(tester);

      await tester.ensureVisible(find.text('Pakai di Buat makanan'));
      await tester.tap(find.text('Pakai di Buat makanan'));
      await tester.pumpAndSettle();

      expect(find.byType(CustomFoodScreen), findsOneWidget);
      expect(find.text('233'), findsOneWidget);
      expect(find.text('100 g'), findsOneWidget);
    },
  );

  testWidgets('jenis sumber ragu → pengguna memilih', (tester) async {
    await tester.pumpWidget(
      buildScreen(
        image: _FakeImage(_unavailable),
        text: _FakeText(
          NutritionReadSuccess(
            _reading(NutritionSourceKind.unknown),
            ReadingTier.text,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tapRead(tester);

    expect(find.text('Simpan sebagai apa?'), findsOneWidget);
    await tester.tap(find.text('Produk kemasan'));
    await tester.pumpAndSettle();

    expect(find.byType(NutritionLabelReviewScreen), findsOneWidget);
  });

  testWidgets('semua layanan gagal → dibaca offline dan ditandai', (
    tester,
  ) async {
    await tester.pumpWidget(
      buildScreen(
        image: _FakeImage(_unavailable),
        text: _FakeText(_unavailable),
        ocr: 'Kalori 250 kkal\nProtein 20 g',
      ),
    );
    await tester.pumpAndSettle();
    await tapRead(tester);

    if (find.text('Simpan sebagai apa?').evaluate().isNotEmpty) {
      await tester.tap(find.text('Makanan buatan sendiri'));
      await tester.pumpAndSettle();
    }
    expect(find.byType(NutritionImportReviewScreen), findsOneWidget);
    expect(find.text('PERIKSA HASIL BACA · OFFLINE'), findsOneWidget);
  });

  testWidgets('tidak ada angka gizi → pesan, bisa foto ulang', (tester) async {
    await tester.pumpWidget(
      buildScreen(
        image: _FakeImage(_unavailable),
        text: _FakeText(const NutritionReadSuccess(_empty, ReadingTier.text)),
      ),
    );
    await tester.pumpAndSettle();
    await tapRead(tester);

    expect(find.text('Tidak ada info gizi terbaca'), findsOneWidget);
    expect(find.text('Isi secara manual'), findsWidgets);
    await tester.tap(find.text('Foto ulang'));
    await tester.pumpAndSettle();
    expect(find.text('Baca info gizi'), findsOneWidget);
  });

  testWidgets('ikon galeri memakai alur yang sama', (tester) async {
    final text = _FakeText(
      NutritionReadSuccess(
        _reading(NutritionSourceKind.general),
        ReadingTier.text,
      ),
    );
    await tester.pumpWidget(
      buildScreen(
        image: _FakeImage(_unavailable),
        text: text,
        gallery: () async => photo,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const ValueKey('label-photo-gallery')));
    await tester.pumpAndSettle();

    expect(text.sent, hasLength(1));
    expect(find.byType(NutritionImportReviewScreen), findsOneWidget);
  });
}
