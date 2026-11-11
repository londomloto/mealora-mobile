import 'dart:typed_data' show Uint8List;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/domain/image_ai_access/label_extraction.dart';
import 'package:mealora/domain/image_ai_access/mock_nutrition_label_provider.dart';
import 'package:mealora/domain/image_ai_access/nutrition_label_provider.dart';
import 'package:mealora/domain/image_ai_access/reading_confidence.dart';
import 'package:mealora/features/diary/nutrition_label_photo_screen.dart';
import 'package:mealora/features/diary/nutrition_label_review_screen.dart';
import 'package:mealora/features/profile/privacy_settings_screen.dart';

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

/// Skala teks besar untuk layar baru change 010 (task 9.3) — pratinjau
/// kamera sungguhan `NutritionLabelPhotoScreen` diverifikasi terpisah di
/// perangkat Android (task 9.6); di sini `debugSkipCameraInit` melewati
/// kamera agar struktur layar tetap teruji pada skala besar.
void main() {
  late AppDatabase database;

  setUp(() {
    database = createWidgetTestDatabase();
  });

  tearDown(() => database.close());

  testWidgets('NutritionLabelPhotoScreen tetap terbaca pada skala 2x', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapForTest(
        NutritionLabelPhotoScreen(
          barcode: '8991234567890',
          debugSkipCameraInit: true,
          debugCapture: () async => Uint8List.fromList(_tinyValidPng),
        ),
        database: database,
        textScale: 2,
        overrides: <Override>[
          nutritionLabelProviderProvider.overrideWithValue(
            MockNutritionLabelProvider(
              const LabelExtractionRead(
                LabelExtraction(
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
                  protein: ExtractedNumber(
                    confidence: ReadingConfidence.confident,
                    value: 2,
                  ),
                  carbohydrate: ExtractedNumber(
                    confidence: ReadingConfidence.confident,
                    value: 18,
                  ),
                  fat: ExtractedNumber(
                    confidence: ReadingConfidence.confident,
                    value: 7,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      find.byIcon(Icons.arrow_back),
      findsOneWidget,
      reason:
          'layar yang dibuka lewat push SHALL selalu punya jalan '
          'kembali yang terlihat, bukan hanya gestur OS/browser',
    );
  });

  testWidgets('NutritionLabelReviewScreen tetap terbaca pada skala 2x', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapForTest(
        NutritionLabelReviewScreen(
          photoBytes: Uint8List.fromList(_tinyValidPng),
          extraction: const LabelExtraction(
            basis: ExtractedBasis(
              kind: ExtractedBasisKind.unread,
              confidence: ReadingConfidence.unread,
            ),
            servingSize: ExtractedNumber(confidence: ReadingConfidence.unread),
            servingsPerPackage: ExtractedNumber(
              confidence: ReadingConfidence.unread,
            ),
            energyKcal: ExtractedNumber(
              confidence: ReadingConfidence.needsCheck,
              value: 150,
            ),
            protein: ExtractedNumber(confidence: ReadingConfidence.unread),
            carbohydrate: ExtractedNumber(
              confidence: ReadingConfidence.confident,
              value: 18,
            ),
            fat: ExtractedNumber(confidence: ReadingConfidence.unread),
          ),
          barcode: '8991234567890',
        ),
        database: database,
        textScale: 2,
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      find.byIcon(Icons.arrow_back),
      findsOneWidget,
      reason:
          'layar yang dibuka lewat push SHALL selalu punya jalan '
          'kembali yang terlihat, bukan hanya gestur OS/browser',
    );
  });

  testWidgets('PrivacySettingsScreen tetap terbaca pada skala 2x', (
    tester,
  ) async {
    await tester.pumpWidget(
      wrapForTest(
        const PrivacySettingsScreen(),
        database: database,
        textScale: 2,
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
