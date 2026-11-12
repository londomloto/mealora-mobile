import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/data/local/drift_diary_repository.dart';
import 'package:mealora/data/local/drift_food_repository.dart';
import 'package:mealora/data/local/drift_program_repository.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/database/migrations/migration_verification.dart';
import 'package:mealora/domain/food/meal_time.dart';

import 'test_database.dart';

/// Migrasi versi 9 → 10 (change 015, task 1.3).
///
/// Berkas versi 9 dibangun dari basis data terkini dengan membuang kelima
/// kolom baru lewat `ALTER TABLE ... DROP COLUMN` dan mengembalikan
/// `user_version` ke 9 — hasilnya skema versi 9 yang sebenarnya, berisi
/// catatan makan sungguhan, tanpa perlu salinan kode tabel versi 9.
void main() {
  late Directory workspace;
  const profileId = 'profile-1';
  const today = LocalDate(2026, 11, 8);

  setUp(() {
    workspace = Directory.systemTemp.createTempSync('mealora_migration_v10');
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

  Future<List<Map<String, Object?>>> itemRows(AppDatabase db) async =>
      (await db
              .customSelect('SELECT * FROM meal_entry_items ORDER BY id')
              .get())
          .map((r) => r.data)
          .toList();

  test('basis data versi 9 berisi catatan makan bermigrasi ke versi 10: '
      'data lama utuh, kolom baru bernilai bawaan', () async {
    final file = File('${workspace.path}/mealora.sqlite');

    final v9 = createTestDatabase(executor: NativeDatabase(file));
    await v9
        .into(v9.profiles)
        .insert(
          ProfilesCompanion.insert(
            id: profileId,
            createdAt: testInstant,
            updatedAt: testInstant,
          ),
        );
    final food = (await DriftFoodRepository(
      v9,
      ids: createTestIds(),
      clock: createTestClock(),
    ).findById('food-tkpi-1215'))!;
    await diaryRepo(v9).addEntry(
      profileId: profileId,
      date: today,
      mealTime: MealTime.lunch,
      food: food,
      serving: food.defaultServing,
      quantity: 1.5,
    );
    for (final statement in <String>[
      'ALTER TABLE foods DROP COLUMN form',
      'ALTER TABLE foods DROP COLUMN is_active',
      'ALTER TABLE food_servings DROP COLUMN provenance_tier',
      'ALTER TABLE food_servings DROP COLUMN provenance_ref',
      'ALTER TABLE food_servings DROP COLUMN provenance_note',
      'PRAGMA user_version = 9',
    ]) {
      await v9.customStatement(statement);
    }
    final itemsBefore = await itemRows(v9);
    final foodCountBefore =
        (await v9.customSelect('SELECT COUNT(*) AS c FROM foods').getSingle())
                .data['c']!
            as int;
    final totalBefore = await diaryRepo(v9).dailyTotal(profileId, today);
    await v9.close();

    final v10 = createTestDatabase(executor: NativeDatabase(file));
    addTearDown(v10.close);

    final check = await verifyMigration(
      v10,
      expectedSchemaVersion: kSchemaVersion,
    );
    expect(kSchemaVersion, greaterThanOrEqualTo(10));
    expect(check.isHealthy, isTrue, reason: check.toString());

    expect(await itemRows(v10), itemsBefore);
    final totalAfter = await diaryRepo(v10).dailyTotal(profileId, today);
    expect(
      totalAfter.nutrition.energy!.kcal,
      totalBefore.nutrition.energy!.kcal,
    );

    final foods = await v10.select(v10.foods).get();
    expect(foods, hasLength(foodCountBefore));
    expect(foods.every((f) => f.isActive), isTrue);

    final servings = await v10.select(v10.foodServings).get();
    expect(servings.every((s) => s.provenanceRef == null), isTrue);
    expect(servings.every((s) => s.provenanceNote == null), isTrue);
  });
}
