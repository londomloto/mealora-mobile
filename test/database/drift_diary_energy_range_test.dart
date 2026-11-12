import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/data/local/drift_diary_repository.dart';
import 'package:mealora/data/local/drift_food_repository.dart';
import 'package:mealora/data/local/drift_program_repository.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/domain/diary/energy_trend.dart';
import 'package:mealora/domain/food/food.dart';
import 'package:mealora/domain/food/food_category.dart';
import 'package:mealora/domain/food/food_repository.dart';
import 'package:mealora/domain/food/meal_time.dart';
import 'package:mealora/domain/food/nutrition_profile.dart';
import 'package:mealora/domain/shared/units.dart';

import 'test_database.dart';

/// Pembacaan energi per rentang dan tanggal catatan pertama (change 018,
/// tasks 1.2/1.4) di atas SQLite nyata.
void main() {
  late AppDatabase db;
  late DriftFoodRepository foodRepository;
  late DriftDiaryRepository repository;
  const profileId = 'profile-1';

  setUp(() async {
    db = createTestDatabase();
    foodRepository = DriftFoodRepository(
      db,
      ids: createTestIds(),
      clock: createTestClock(),
    );
    repository = DriftDiaryRepository(
      db,
      clock: createTestClock(),
      ids: createTestIds(),
      programRepository: DriftProgramRepository(
        db,
        clock: createTestClock(),
        ids: createTestIds(),
      ),
    );
    await db
        .into(db.profiles)
        .insert(
          ProfilesCompanion.insert(
            id: profileId,
            createdAt: testInstant,
            updatedAt: testInstant,
          ),
        );
  });

  tearDown(() => db.close());

  Future<Food> food(String name, double? kcal) => foodRepository.createUserFood(
    name: name,
    category: FoodCategory.other,
    serving: ServingSizeInput(
      label: '1 porsi',
      amount: 1,
      unit: 'porsi',
      nutrition: NutritionProfile(
        energy: kcal == null
            ? null
            : Energy.kcalValue(kcal, field: 'energy').valueOrNull,
        proteinG: 1,
        carbohydrateG: 1,
        fatG: 1,
      ),
    ),
  );

  Future<void> log(LocalDate date, Food f, {MealTime time = MealTime.lunch}) =>
      repository.addEntry(
        profileId: profileId,
        date: date,
        mealTime: time,
        food: f,
        serving: f.defaultServing,
        quantity: 1,
      );

  test(
    'menjumlahkan energi per tanggal dan melewatkan tanggal kosong',
    () async {
      final nasi = await food('Nasi', 400);
      final ayam = await food('Ayam', 250);
      await log(const LocalDate(2026, 11, 2), nasi, time: MealTime.breakfast);
      await log(const LocalDate(2026, 11, 2), ayam);
      await log(const LocalDate(2026, 11, 4), nasi);
      await log(const LocalDate(2026, 11, 9), nasi);

      final result = await repository.dailyEnergyInRange(
        profileId,
        from: const LocalDate(2026, 11, 1),
        to: const LocalDate(2026, 11, 5),
      );

      expect(
        result.keys,
        unorderedEquals(<String>['2026-11-02', '2026-11-04']),
      );
      expect(result['2026-11-02']!.kcal, 650);
      expect(result['2026-11-04']!.kcal, 400);
    },
  );

  test(
    'satu catatan tanpa energi membuat tanggal itu tidak diketahui',
    () async {
      final nasi = await food('Nasi', 400);
      final misteri = await food('Kue misteri', null);
      await log(const LocalDate(2026, 11, 3), nasi);
      await log(const LocalDate(2026, 11, 3), misteri, time: MealTime.snack);

      final result = await repository.dailyEnergyInRange(
        profileId,
        from: const LocalDate(2026, 11, 3),
        to: const LocalDate(2026, 11, 3),
      );

      expect(result['2026-11-03'], isNotNull);
      expect(result['2026-11-03']!.kcal, isNull);
    },
  );

  test('tanggal catatan pertama, null bila belum ada catatan', () async {
    expect(await repository.firstEntryDate(profileId), isNull);
    final nasi = await food('Nasi', 400);
    await log(const LocalDate(2026, 11, 5), nasi);
    await log(const LocalDate(2026, 10, 28), nasi);

    expect(
      await repository.firstEntryDate(profileId),
      const LocalDate(2026, 10, 28),
    );
  });

  test('rentang 365 hari dibaca dalam satu kueri', () async {
    final nasi = await food('Nasi', 400);
    final days = datesBetween(
      const LocalDate(2025, 11, 9),
      const LocalDate(2026, 11, 8),
    ).toList();
    for (final day in days) {
      await log(day, nasi);
    }

    final watch = Stopwatch()..start();
    final result = await repository.dailyEnergyInRange(
      profileId,
      from: days.first,
      to: days.last,
    );
    watch.stop();

    expect(result, hasLength(365));
    expect(watch.elapsed, lessThan(const Duration(seconds: 2)));
  });
}
