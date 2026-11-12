import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/data/local/drift_diary_repository.dart';
import 'package:mealora/data/local/drift_food_repository.dart';
import 'package:mealora/data/local/drift_program_repository.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/database/migrations/migration_verification.dart';
import 'package:mealora/domain/food/food_category.dart';
import 'package:mealora/domain/food/food_repository.dart';
import 'package:mealora/domain/food/meal_time.dart';
import 'package:mealora/domain/food/nutrition_profile.dart';
import 'package:mealora/domain/shared/units.dart';

import 'test_database.dart';

/// Migrasi versi 10 → 11 (change 016, task 1.5).
///
/// Berkas versi 10 dibangun dari basis data terkini dengan membuang tabel
/// dan kolom change 016 lalu mengembalikan `user_version` ke 10 (pola
/// `migration_v10_test.dart`).
void main() {
  late Directory workspace;
  const profileId = 'profile-1';
  const today = LocalDate(2026, 11, 12);

  setUp(() {
    workspace = Directory.systemTemp.createTempSync('mealora_migration_v11');
  });

  tearDown(() {
    try {
      if (workspace.existsSync()) {
        workspace.deleteSync(recursive: true);
      }
    } on FileSystemException {
      // Pada Windows berkas kadang masih dipegang proses saat uji selesai.
    }
  });

  DriftDiaryRepository diaryRepo(AppDatabase db) => DriftDiaryRepository(
    db,
    clock: createTestClock(),
    ids: createTestIds(),
    programRepository: DriftProgramRepository(
      db,
      clock: createTestClock(),
      ids: createTestIds(),
    ),
  );

  Future<List<Map<String, Object?>>> rows(AppDatabase db, String sql) async =>
      (await db.customSelect(sql).get()).map((r) => r.data).toList();

  test('makanan buatan pengguna lama utuh dan bertanda manual, '
      'catatan makan tidak berubah', () async {
    final file = File('${workspace.path}/mealora.sqlite');

    final v10 = createTestDatabase(executor: NativeDatabase(file));
    await v10
        .into(v10.profiles)
        .insert(
          ProfilesCompanion.insert(
            id: profileId,
            createdAt: testInstant,
            updatedAt: testInstant,
          ),
        );
    final foods = DriftFoodRepository(
      v10,
      ids: createTestIds(),
      clock: createTestClock(),
    );
    final custom = await foods.createUserFood(
      name: 'Tumis buncis rumahan',
      category: FoodCategory.sideDish,
      serving: ServingSizeInput(
        label: '1 porsi',
        amount: 1,
        unit: 'porsi',
        nutrition: NutritionProfile(
          energy: Energy.kcalValue(185, field: 'e').valueOrNull,
          proteinG: 7,
        ),
      ),
    );
    await diaryRepo(v10).addEntry(
      profileId: profileId,
      date: today,
      mealTime: MealTime.dinner,
      food: custom,
      serving: custom.defaultServing,
      quantity: 1,
    );
    for (final statement in <String>[
      'DROP TABLE recipe_ingredients',
      'ALTER TABLE foods DROP COLUMN nutrition_origin',
      'ALTER TABLE foods DROP COLUMN recipe_yield_servings',
      'ALTER TABLE foods DROP COLUMN recipe_yield_grams',
      'PRAGMA user_version = 10',
    ]) {
      await v10.customStatement(statement);
    }
    const itemsSql = 'SELECT * FROM meal_entry_items ORDER BY id';
    const customSql =
        'SELECT id, name, revision FROM foods WHERE is_user_created = 1';
    final itemsBefore = await rows(v10, itemsSql);
    final customBefore = await rows(v10, customSql);
    await v10.close();

    final v11 = createTestDatabase(executor: NativeDatabase(file));
    addTearDown(v11.close);

    final check = await verifyMigration(
      v11,
      expectedSchemaVersion: kSchemaVersion,
    );
    expect(kSchemaVersion, 11);
    expect(check.isHealthy, isTrue, reason: check.toString());

    expect(await rows(v11, itemsSql), itemsBefore);
    expect(await rows(v11, customSql), customBefore);

    final migrated = await v11.select(v11.foods).get();
    for (final f in migrated) {
      expect(
        f.nutritionOrigin,
        f.isUserCreated ? 'manual' : isNull,
        reason: f.name,
      );
      expect(f.recipeYieldServings, isNull);
      expect(f.recipeYieldGrams, isNull);
    }
    expect(await rows(v11, 'SELECT * FROM recipe_ingredients'), isEmpty);
  });

  test('CHECK recipe_ingredients menolak gram dan kelipatan sekaligus, '
      'serta bahan tanpa food maupun nama', () async {
    final db = createTestDatabase();
    addTearDown(db.close);
    final food =
        await DriftFoodRepository(
          db,
          ids: createTestIds(),
          clock: createTestClock(),
        ).createUserFood(
          name: 'Resep',
          category: FoodCategory.other,
          serving: const ServingSizeInput(
            label: '1 porsi',
            amount: 1,
            unit: 'porsi',
            nutrition: NutritionProfile.unknown,
          ),
        );

    Future<void> insert(String values) => db.customStatement(
      'INSERT INTO recipe_ingredients (id, created_at, updated_at, '
      'recipe_food_id, ingredient_food_id, ingredient_serving_id, '
      'free_text_name, grams, serving_multiple, position) VALUES ($values)',
    );

    await insert("'ok', 0, 0, '${food.id}', NULL, NULL, 'garam', 5, NULL, 0");
    for (final bad in <String>[
      "'b1', 0, 0, '${food.id}', NULL, NULL, 'garam', 5, 1, 1",
      "'b2', 0, 0, '${food.id}', NULL, NULL, NULL, 5, NULL, 1",
      "'b3', 0, 0, '${food.id}', NULL, NULL, 'garam', 0, NULL, 1",
    ]) {
      await expectLater(insert(bad), throwsA(anything), reason: bad);
    }
  });
}
