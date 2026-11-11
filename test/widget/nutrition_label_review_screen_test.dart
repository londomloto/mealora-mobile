import 'dart:typed_data' show Uint8List;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/domain/image_ai_access/label_extraction.dart';
import 'package:mealora/domain/image_ai_access/reading_confidence.dart';
import 'package:mealora/features/diary/nutrition_label_review_screen.dart';
import 'package:mealora/features/diary/packaged_food_review_screen.dart';

import 'harness.dart';

const _tinyValidPng = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, //
  0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52, //
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, //
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, //
  0x89, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x44, 0x41, //
  0x54, 0x78, 0x9C, 0x62, 0x00, 0x01, 0x00, 0x00, //
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, //
  0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, //
  0x42, 0x60, 0x82, //
];

/// `24 · Tinjau ekstraksi label` (task 7.1-7.9).
void main() {
  late AppDatabase database;

  setUp(() {
    database = createWidgetTestDatabase();
  });

  tearDown(() => database.close());

  Widget buildScreen(LabelExtraction extraction) {
    return wrapForTest(
      NutritionLabelReviewScreen(
        photoBytes: Uint8List.fromList(_tinyValidPng),
        extraction: extraction,
        barcode: '8991234567890',
      ),
      database: database,
    );
  }

  Future<void> tapConfirm(WidgetTester tester) async {
    await tester.ensureVisible(find.text('Konfirmasi nilai'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Konfirmasi nilai'));
  }

  FilledButton confirmButtonOf(WidgetTester tester) =>
      tester.widget<FilledButton>(
        find.ancestor(
          of: find.text('Konfirmasi nilai'),
          matching: find.byType(FilledButton),
        ),
      );

  const fullyConfidentExtraction = LabelExtraction(
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

  testWidgets('foto asli tampil berdampingan dengan nilai, tanpa '
      'perpindahan layar (task 7.1)', (tester) async {
    await tester.pumpWidget(buildScreen(fullyConfidentExtraction));
    await tester.pumpAndSettle();

    expect(find.byType(Image), findsOneWidget);
    expect(find.text('150,0'), findsOneWidget); // energi
    expect(find.text('2,0'), findsWidgets); // protein & servings per package
  });

  testWidgets(
    'konfirmasi tertahan ketika basis tidak terbaca, menyebutkan basis '
    'sebagai yang menahan (task 7.2/7.6)',
    (tester) async {
      final extraction = LabelExtraction(
        basis: const ExtractedBasis(
          kind: ExtractedBasisKind.unread,
          confidence: ReadingConfidence.unread,
        ),
        servingSize: fullyConfidentExtraction.servingSize,
        servingsPerPackage: fullyConfidentExtraction.servingsPerPackage,
        energyKcal: fullyConfidentExtraction.energyKcal,
        protein: fullyConfidentExtraction.protein,
        carbohydrate: fullyConfidentExtraction.carbohydrate,
        fat: fullyConfidentExtraction.fat,
      );
      await tester.pumpWidget(buildScreen(extraction));
      await tester.pumpAndSettle();

      expect(
        find.text(
          'Basis tidak terbaca dari foto — pilih sendiri sebelum lanjut.',
        ),
        findsOneWidget,
      );
      expect(confirmButtonOf(tester).onPressed, isNull);

      await tester.ensureVisible(find.text('Tidak terbaca').first);
      await tester.tap(find.text('Tidak terbaca').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Per sajian'));
      await tester.pumpAndSettle();

      expect(confirmButtonOf(tester).onPressed, isNotNull);
    },
  );

  testWidgets('nilai lemak tidak terbaca menahan konfirmasi sampai diisi atau '
      'ditandai tidak tercantum (task 7.5/7.6/7.7)', (tester) async {
    final extraction = LabelExtraction(
      basis: fullyConfidentExtraction.basis,
      servingSize: fullyConfidentExtraction.servingSize,
      servingsPerPackage: fullyConfidentExtraction.servingsPerPackage,
      energyKcal: fullyConfidentExtraction.energyKcal,
      protein: fullyConfidentExtraction.protein,
      carbohydrate: fullyConfidentExtraction.carbohydrate,
      fat: const ExtractedNumber(confidence: ReadingConfidence.unread),
    );
    await tester.pumpWidget(buildScreen(extraction));
    await tester.pumpAndSettle();

    expect(find.textContaining('Lemak'), findsWidgets);
    expect(confirmButtonOf(tester).onPressed, isNull);

    await tester.ensureVisible(find.byIcon(Icons.block_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.byIcon(Icons.block_outlined));
    await tester.pumpAndSettle();

    expect(confirmButtonOf(tester).onPressed, isNotNull);
    expect(
      find.text('Ditandai tidak tercantum di kemasan'),
      findsOneWidget,
      reason: 'penanda SHALL berupa teks, bukan hanya warna ikon (task 9.2)',
    );
  });

  testWidgets(
    'menyatakan hubungan sajian dan kemasan ketika keduanya diketahui '
    '(task 7.3)',
    (tester) async {
      await tester.pumpWidget(buildScreen(fullyConfidentExtraction));
      await tester.pumpAndSettle();

      expect(find.textContaining('1 kemasan = 2'), findsOneWidget);
    },
  );

  testWidgets(
    'menutup layar tanpa konfirmasi menampilkan dialog, dan "lanjutkan '
    'meninjau" tidak menutup layar (task 7.9)',
    (tester) async {
      await tester.pumpWidget(buildScreen(fullyConfidentExtraction));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.text('Batalkan peninjauan ini?'), findsOneWidget);
      await tester.tap(find.text('Lanjutkan meninjau'));
      await tester.pumpAndSettle();

      expect(find.byType(NutritionLabelReviewScreen), findsOneWidget);
    },
  );

  testWidgets(
    'mengonfirmasi "ya, batalkan" menutup layar tanpa membuat catatan '
    '(task 7.9)',
    (tester) async {
      await tester.pumpWidget(buildScreen(fullyConfidentExtraction));
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Ya, batalkan'));
      await tester.pumpAndSettle();

      expect(find.byType(NutritionLabelReviewScreen), findsNothing);
      expect(find.byType(PackagedFoodReviewScreen), findsNothing);
    },
  );

  testWidgets(
    'mengisi nama lalu konfirmasi berpindah ke layar tinjau produk kemasan '
    '(task 8.5/8.6 — memakai ulang jalur change 009)',
    (tester) async {
      await tester.pumpWidget(buildScreen(fullyConfidentExtraction));
      await tester.pumpAndSettle();

      await tester.enterText(
        find.widgetWithText(TextField, 'mis. Keripik Singkong Renyah'),
        'Keripik Singkong Renyah',
      );
      await tester.pumpAndSettle();
      await tapConfirm(tester);
      await tester.pumpAndSettle();

      expect(find.byType(PackagedFoodReviewScreen), findsOneWidget);
    },
  );
}
