import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/data/local/drift_photo_draft_repository.dart';
import 'package:mealora/data/local/drift_profile_repository.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/domain/food/meal_time.dart';
import 'package:mealora/domain/food_photo_input/photo_draft.dart';
import 'package:mealora/domain/nutrition/activity_level.dart';
import 'package:mealora/domain/nutrition/biological_input.dart';
import 'package:mealora/domain/profile/user_profile.dart';
import 'package:mealora/domain/shared/units.dart';
import 'package:mealora/features/diary/food_photo_review_screen.dart';
import 'package:mealora/features/today/today_screen.dart';

import 'harness.dart';

/// `01 · Hari ini` memulihkan draf foto makanan setelah aplikasi ditutup
/// paksa di tengah peninjauan lalu dibuka kembali (spec food-photo-input,
/// change 011, task 3.4). Draf disimpan oleh `DriftPhotoDraftRepository`
/// SEBELUM `TodayScreen` dipompa di sini, sama seperti keadaan nyata: tidak
/// ada state navigasi di memori yang bertahan, satu-satunya yang bertahan
/// adalah baris di basis data — titik pemulihannya adalah ruang utama,
/// bukan layar yang sedang terbuka saat aplikasi ditutup.
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

  Future<void> pumpToday(WidgetTester tester) async {
    await tester.pumpWidget(
      wrapForTest(
        const TodayScreen(),
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
  }

  testWidgets(
    'draf yang tersimpan sebelum aplikasi ditutup tampil sebagai tawaran '
    'melanjutkan, dan ketukan membuka peninjauan dengan komponen yang sudah '
    'diisi',
    (tester) async {
      final repository = DriftPhotoDraftRepository(
        database,
        clock: createWidgetTestClock(),
      );
      await repository.save(
        PhotoDraft(
          id: 'draft-1',
          profileId: profileId,
          localDate: createWidgetTestClock().today(),
          mealTime: MealTime.lunch,
          sourceImagePath: null,
          createdAt: createWidgetTestClock().nowUtc(),
          components: const <PhotoDraftComponent>[
            PhotoDraftComponent(
              localId: 'component-1',
              foodNameGuess: 'Nasi putih',
              matchedFoodId: 'food-tkpi-921',
              matchedFoodName: 'Nasi putih',
              quantity: 1,
              portionNeedsCheck: true,
              cookingMethodNeedsCheck: false,
            ),
          ],
        ),
      );

      await pumpToday(tester);

      expect(find.text('Draf foto makanan menunggu'), findsOneWidget);

      await tester.tap(find.text('Draf foto makanan menunggu'));
      await tester.pumpAndSettle();

      expect(find.byType(FoodPhotoReviewScreen), findsOneWidget);
      expect(find.text('Nasi putih'), findsOneWidget);
    },
  );

  testWidgets('tanpa draf tersimpan, tawaran melanjutkan tidak tampil', (
    tester,
  ) async {
    await pumpToday(tester);

    expect(find.text('Draf foto makanan menunggu'), findsNothing);
  });
}
