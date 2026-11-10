import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/errors/result.dart';
import 'package:mealora/data/local/drift_diary_repository.dart';
import 'package:mealora/data/local/drift_food_repository.dart';
import 'package:mealora/data/local/drift_program_repository.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/domain/diary/meal_entry.dart';
import 'package:mealora/domain/food/meal_time.dart';

import 'test_database.dart';

/// Uji integrasi alur penuh (task 9.5) dan ketahanan data lintas
/// pembukaan-ulang basis data (task 9.6) — seluruhnya luring, SQLite asli
/// (bukan tiruan), mengikuti pola `migration_test.dart`.
void main() {
  late Directory workspace;
  const profileId = 'profile-1';
  const today = LocalDate(2026, 11, 8);

  setUp(() {
    workspace = Directory.systemTemp.createTempSync('mealora_food_diary');
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

  File databaseFile() => File('${workspace.path}/mealora.sqlite');

  test('cari makanan → pilih takaran dan jumlah → simpan → ruang Hari ini '
      'menyesuaikan → sunting → pindahkan → hapus → total kembali seperti '
      'semula (task 9.5)', () async {
    final db = createTestDatabase(executor: NativeDatabase(databaseFile()));
    addTearDown(db.close);
    final foodRepository = DriftFoodRepository(
      db,
      ids: createTestIds(),
      clock: createTestClock(),
    );
    final programRepository = DriftProgramRepository(
      db,
      clock: createTestClock(),
      ids: createTestIds(),
    );
    final diaryRepository = DriftDiaryRepository(
      db,
      clock: createTestClock(),
      ids: createTestIds(),
      programRepository: programRepository,
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

    final baseline = await diaryRepository.dailyTotal(profileId, today);
    expect(baseline.hasAnyEntries, isFalse);

    // Cari makanan (pencarian luring sepenuhnya di atas SQLite lokal).
    final results = await foodRepository.search('nasi putih');
    expect(results, isNotEmpty);
    final food = results.first;

    // Pilih takaran dan jumlah, lalu simpan.
    final added = await diaryRepository.addEntry(
      profileId: profileId,
      date: today,
      mealTime: MealTime.lunch,
      food: food,
      serving: food.defaultServing,
      quantity: 2,
    );
    expect(added, isA<Ok<MealEntry>>());
    final entry = (added as Ok<MealEntry>).value;

    // Ruang Hari ini menyesuaikan.
    final afterAdd = await diaryRepository.dailyTotal(profileId, today);
    expect(afterAdd.hasAnyEntries, isTrue);
    expect(afterAdd.nutrition.energy, isNotNull);

    // Sunting jumlah.
    final edited = await diaryRepository.updateEntry(
      entryId: entry.id,
      serving: food.defaultServing,
      quantity: 3,
      mealTime: MealTime.lunch,
    );
    expect(edited, isA<Ok<MealEntry>>());

    // Pindahkan ke waktu makan lain.
    final moved = await diaryRepository.updateEntry(
      entryId: entry.id,
      serving: food.defaultServing,
      quantity: 3,
      mealTime: MealTime.dinner,
    );
    expect((moved as Ok<MealEntry>).value.mealTime, MealTime.dinner);
    final afterMove = await diaryRepository.dailyTotal(profileId, today);
    expect(
      afterMove.nutrition.energy!.kcal,
      afterAdd.nutrition.energy!.kcal * 1.5,
    );

    // Hapus.
    await diaryRepository.deleteEntry(entry.id);
    final afterDelete = await diaryRepository.dailyTotal(profileId, today);
    expect(afterDelete.hasAnyEntries, isFalse);
    expect(afterDelete.nutrition.energy, baseline.nutrition.energy);
  });

  test('seluruh catatan dan total bertahan setelah penyimpanan ditutup dan '
      'dibuka kembali (task 9.6)', () async {
    final file = databaseFile();

    final first = createTestDatabase(executor: NativeDatabase(file));
    final firstFoodRepo = DriftFoodRepository(
      first,
      ids: createTestIds(),
      clock: createTestClock(),
    );
    final firstDiaryRepo = DriftDiaryRepository(
      first,
      clock: createTestClock(),
      ids: createTestIds(),
      programRepository: DriftProgramRepository(
        first,
        clock: createTestClock(),
        ids: createTestIds(),
      ),
    );
    await first
        .into(first.profiles)
        .insert(
          ProfilesCompanion.insert(
            id: profileId,
            createdAt: testInstant,
            updatedAt: testInstant,
          ),
        );
    final food = (await firstFoodRepo.findById('food-telur-rebus'))!;
    await firstDiaryRepo.addEntry(
      profileId: profileId,
      date: today,
      mealTime: MealTime.breakfast,
      food: food,
      serving: food.defaultServing,
      quantity: 2,
    );
    final totalBeforeClose = await firstDiaryRepo.dailyTotal(profileId, today);
    await first.close();

    final second = createTestDatabase(executor: NativeDatabase(file));
    addTearDown(second.close);
    final secondDiaryRepo = DriftDiaryRepository(
      second,
      clock: createTestClock(),
      ids: createTestIds(),
      programRepository: DriftProgramRepository(
        second,
        clock: createTestClock(),
        ids: createTestIds(),
      ),
    );

    final entries = await secondDiaryRepo.entriesForDate(profileId, today);
    expect(entries, hasLength(1));
    expect(entries.single.quantity, 2);

    final totalAfterReopen = await secondDiaryRepo.dailyTotal(profileId, today);
    expect(
      totalAfterReopen.nutrition.energy!.kcal,
      totalBeforeClose.nutrition.energy!.kcal,
    );
  });
}
