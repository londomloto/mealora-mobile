import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/data/local/drift_photo_draft_repository.dart';
import 'package:mealora/data/local/drift_profile_repository.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/domain/food/meal_time.dart';
import 'package:mealora/domain/food_photo_input/photo_draft.dart';
import 'package:mealora/domain/image_ai_access/image_ai_settings.dart';
import 'package:mealora/domain/nutrition/activity_level.dart';
import 'package:mealora/domain/nutrition/biological_input.dart';
import 'package:mealora/domain/profile/user_profile.dart';
import 'package:mealora/domain/shared/units.dart';
import 'package:mealora/features/diary/food_photo_review_screen.dart';
import 'package:mealora/features/diary/food_photo_saved_screen.dart';
import 'package:mealora/features/share/daily_summary_share_card.dart';
import 'package:mealora/features/share/meal_share_card.dart';
import 'package:mealora/features/share/share_preview_screen.dart';
import 'package:mealora/features/share/share_service.dart';
import 'package:mealora/features/today/today_screen.dart';

import 'harness.dart';

/// Change 014 — berbagi ringkasan harian dan makanan dari jalur foto
/// (task 2.3 dan 3.5).
void main() {
  late AppDatabase database;
  const profileId = 'test-profile';

  setUp(() async {
    database = createWidgetTestDatabase();
    await DriftProfileRepository(
      database,
      clock: createWidgetTestClock(),
    ).upsert(
      UserProfile(
        id: profileId,
        birthDate: const LocalDate(1997, 5, 20),
        height: Length.cmValue(165, field: 'height').valueOrNull,
        currentWeight: Mass.kgValue(68, field: 'weight').valueOrNull,
        biologicalInput: BiologicalInput.female,
        activityLevel: ActivityLevel.moderatelyActive,
        isOnboardingComplete: true,
      ),
    );
  });

  tearDown(() => database.close());

  group('kartu ringkasan harian (task 2.3)', () {
    const data = DailySummaryShareData(
      date: LocalDate(2026, 11, 11),
      consumedKcal: 1650,
      targetKcal: 2000,
      proteinG: 98,
      carbohydrateG: 196,
      fatG: 54,
    );

    testWidgets('memuat energi/target, persentase bulat, makro, dan '
        'watermark — tanpa berat badan maupun program', (tester) async {
      await tester.pumpWidget(
        wrapForTest(const Center(child: DailySummaryShareCard(data: data))),
      );
      await tester.pumpAndSettle();

      expect(find.text('1.650'), findsOneWidget);
      expect(find.text('dari 2.000 kkal'), findsOneWidget);
      expect(find.text('83% dari target'), findsOneWidget);
      expect(
        find.text('Protein 98 g · Karbo 196 g · Lemak 54 g'),
        findsOneWidget,
      );
      expect(find.text('RABU, 11 NOVEMBER 2026'), findsOneWidget);
      expect(find.byKey(const ValueKey<String>('share-watermark')), findsOne);
      expect(find.text('Mealora'), findsOneWidget);

      final allText = tester
          .widgetList<Text>(find.byType(Text))
          .map((t) => t.data ?? '')
          .join(' | ');
      expect(allText, isNot(contains('kg')));
      expect(allText, isNot(contains('Turun Berat')));
      expect(allText, isNot(contains('Program')));
    });

    test('persentase dibulatkan dan boleh melebihi 100%', () {
      const over = DailySummaryShareData(
        date: LocalDate(2026, 11, 11),
        consumedKcal: 2350,
        targetKcal: 2000,
        proteinG: null,
        carbohydrateG: null,
        fatG: null,
      );
      expect(data.percentOfTarget, 83);
      expect(over.percentOfTarget, 118);
    });

    testWidgets('tanpa catatan hari ini tombol Bagikan nonaktif dan '
        'menjelaskan alasannya', (tester) async {
      await useDesignViewport(tester);
      await tester.pumpWidget(
        wrapForTest(
          const Scaffold(body: TodayScreen()),
          database: database,
          overrides: <Override>[
            profileRepositoryAppOverride,
            programRepositoryAppOverride,
            foodRepositoryAppOverride,
            diaryRepositoryAppOverride,
            photoDraftRepositoryAppOverride,
          ],
        ),
      );
      await tester.pumpAndSettle();

      final button = find.byKey(const ValueKey<String>('today-share-summary'));
      expect(button, findsOneWidget);
      expect(
        tester.getSemantics(button),
        isSemantics(isButton: true, hasEnabledState: true, isEnabled: false),
      );

      await tester.tap(button);
      await tester.pump();

      expect(
        find.text('Catat makanan dulu untuk membagikan ringkasan.'),
        findsOneWidget,
      );
      expect(find.byType(SharePreviewScreen), findsNothing);
    });
  });

  group('layar "Tersimpan" jalur foto (task 3.5)', () {
    late Directory tempDir;

    setUp(() {
      tempDir = Directory.systemTemp.createTempSync('mealora-share-test');
    });

    tearDown(() {
      try {
        tempDir.deleteSync(recursive: true);
      } on FileSystemException {
        // Windows: berkas bisa masih dikunci pemuat gambar.
      }
    });

    Future<String> savePhotoDraft(String photoPath) async {
      await DriftPhotoDraftRepository(
        database,
        clock: createWidgetTestClock(),
      ).save(
        PhotoDraft(
          id: 'draft-1',
          profileId: profileId,
          localDate: createWidgetTestClock().today(),
          mealTime: MealTime.lunch,
          sourceImagePath: photoPath,
          createdAt: createWidgetTestClock().nowUtc(),
          components: const <PhotoDraftComponent>[
            PhotoDraftComponent(
              localId: 'component-1',
              foodNameGuess: 'Nasi putih',
              matchedFoodId: 'food-tkpi-921',
              matchedFoodName: 'Nasi putih',
              quantity: 1,
              portionNeedsCheck: false,
              cookingMethodNeedsCheck: false,
            ),
          ],
        ),
      );
      return photoPath;
    }

    Future<_RecordingShareService> pumpReviewAndConfirm(
      WidgetTester tester, {
      required ImageRetentionPreference retention,
      required String photoPath,
    }) async {
      final share = _RecordingShareService();
      final draft = (await DriftPhotoDraftRepository(
        database,
        clock: createWidgetTestClock(),
      ).current(profileId))!;
      await useDesignViewport(tester);
      await tester.pumpWidget(
        wrapForTest(
          Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (_) => FoodPhotoReviewScreen(draft: draft),
                    ),
                  ),
                  child: const Text('beranda'),
                ),
              ),
            ),
          ),
          database: database,
          overrides: <Override>[
            profileRepositoryAppOverride,
            programRepositoryAppOverride,
            foodRepositoryAppOverride,
            diaryRepositoryAppOverride,
            photoDraftRepositoryAppOverride,
            imageRetentionPreferenceProvider.overrideWith(
              () => _FixedRetention(retention),
            ),
            shareCardServiceProvider.overrideWithValue(share),
          ],
        ),
      );
      await tester.tap(find.text('beranda'));
      await tester.pumpAndSettle();

      tester
          .widget<MealoraPrimaryButton>(find.byType(MealoraPrimaryButton))
          .onPressed!();
      await tester.pumpAndSettle();
      return share;
    }

    Future<void> settleIo(WidgetTester tester) async {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 50)),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('konfirmasi foto membuka "Tersimpan"; Bagikan menampilkan '
        'pratinjau kartu makanan lalu lembar berbagi', (tester) async {
      final photo = File('${tempDir.path}/draft.jpg')
        ..writeAsBytesSync(<int>[0]);
      await savePhotoDraft(photo.path);
      final share = await pumpReviewAndConfirm(
        tester,
        retention: ImageRetentionPreference.deleteAfterLogging,
        photoPath: photo.path,
      );

      expect(find.byType(FoodPhotoSavedScreen), findsOneWidget);
      expect(find.text('Tersimpan!'), findsOneWidget);
      expect((await database.select(database.mealEntries).get()).length, 1);
      // Draf DB dibuang segera; foto ditahan selama layar terbuka.
      expect(
        await DriftPhotoDraftRepository(
          database,
          clock: createWidgetTestClock(),
        ).current(profileId),
        isNull,
      );
      expect(photo.existsSync(), isTrue);

      await tester.tap(find.text('Bagikan'));
      await tester.pumpAndSettle();

      expect(find.byType(SharePreviewScreen), findsOneWidget);
      final card = tester.widget<MealShareCard>(
        find.descendant(
          of: find.byType(SharePreviewScreen),
          matching: find.byType(MealShareCard),
        ),
      );
      expect(card.data.items.single.name, isNotEmpty);
      expect(card.data.items.single.portion, contains('×'));
      expect(card.data.items.single.kcal, isNotNull);
      expect(card.data.photoPath, photo.path);
      expect(
        find.descendant(
          of: find.byType(SharePreviewScreen),
          matching: find.byKey(const ValueKey<String>('share-watermark')),
        ),
        findsOneWidget,
      );

      await tester.tap(
        find.descendant(
          of: find.byType(SharePreviewScreen),
          matching: find.byType(MealoraPrimaryButton),
        ),
      );
      await tester.pumpAndSettle();
      expect(share.calls, 1);
    });

    testWidgets('Selesai kembali ke halaman awal; retensi "hapus setelah '
        'dicatat" menghapus foto, catatan tetap ada', (tester) async {
      final photo = File('${tempDir.path}/draft.jpg')
        ..writeAsBytesSync(<int>[0]);
      await savePhotoDraft(photo.path);
      await pumpReviewAndConfirm(
        tester,
        retention: ImageRetentionPreference.deleteAfterLogging,
        photoPath: photo.path,
      );

      await tester.tap(find.text('Selesai'));
      await settleIo(tester);

      expect(find.byType(FoodPhotoSavedScreen), findsNothing);
      expect(find.text('beranda'), findsOneWidget);
      expect(photo.existsSync(), isFalse);
      expect((await database.select(database.mealEntries).get()).length, 1);
    });

    testWidgets('retensi "simpan di perangkat" mempertahankan foto', (
      tester,
    ) async {
      final photo = File('${tempDir.path}/draft.jpg')
        ..writeAsBytesSync(<int>[0]);
      await savePhotoDraft(photo.path);
      await pumpReviewAndConfirm(
        tester,
        retention: ImageRetentionPreference.keepOnDevice,
        photoPath: photo.path,
      );

      await tester.tap(find.text('Selesai'));
      await settleIo(tester);

      expect(find.text('beranda'), findsOneWidget);
      expect(photo.existsSync(), isTrue);
    });
  });
}

class _FixedRetention extends ImageRetentionSetting {
  _FixedRetention(this.value);

  final ImageRetentionPreference value;

  @override
  Future<ImageRetentionPreference> build() async => value;
}

class _RecordingShareService extends ShareCardService {
  _RecordingShareService()
    : super(gateway: const SystemShareSheetGateway(), nextId: () => 'x');

  int calls = 0;

  @override
  Future<void> share(RenderRepaintBoundary boundary) async => calls++;
}
