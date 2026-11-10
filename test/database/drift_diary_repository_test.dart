import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/errors/result.dart';
import 'package:mealora/data/local/drift_diary_repository.dart';
import 'package:mealora/data/local/drift_food_repository.dart';
import 'package:mealora/data/local/drift_program_repository.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/domain/diary/meal_entry.dart';
import 'package:mealora/domain/food/food_category.dart';
import 'package:mealora/domain/food/food_repository.dart';
import 'package:mealora/domain/food/meal_time.dart';
import 'package:mealora/domain/food/nutrition_profile.dart';
import 'package:mealora/domain/nutrition/activity_level.dart';
import 'package:mealora/domain/nutrition/biological_input.dart';
import 'package:mealora/domain/program/commands/activate_program_command.dart';
import 'package:mealora/domain/program/commands/activation_result.dart';
import 'package:mealora/domain/program/nutrition_policy.dart';
import 'package:mealora/domain/program/program_code.dart';
import 'package:mealora/domain/program/program_engine.dart';
import 'package:mealora/domain/program/program_proposal_inputs.dart';
import 'package:mealora/domain/shared/units.dart';

import 'test_database.dart';

/// `DriftDiaryRepository` (change 007) di atas SQLite nyata: potret nilai
/// gizi dibekukan, penulisan utuh, agregasi yang jujur tentang nilai belum
/// diketahui (Design D9), dan penyambungan ke potret kemajuan program
/// (Design D8).
void main() {
  late AppDatabase db;
  late DriftFoodRepository foodRepository;
  late DriftProgramRepository programRepository;
  late DriftDiaryRepository repository;
  const profileId = 'profile-1';
  const today = LocalDate(2026, 11, 8);

  setUp(() async {
    db = createTestDatabase();
    foodRepository = DriftFoodRepository(
      db,
      ids: createTestIds(),
      clock: createTestClock(),
    );
    programRepository = DriftProgramRepository(
      db,
      clock: createTestClock(),
      ids: createTestIds(),
    );
    repository = DriftDiaryRepository(
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
  });

  tearDown(() => db.close());

  Future<void> activeMaintenanceProgram() async {
    final engine = ProgramEngine(
      NutritionPolicy.np100(status: PolicyApprovalStatus.approved),
    );
    final inputs = ProgramProposalInputs(
      ageYears: 29,
      biologicalInput: BiologicalInput.female,
      height: Length.cmValue(165, field: 'h').valueOrNull!,
      currentWeight: Mass.kgValue(68.4, field: 'w').valueOrNull!,
      activity: ActivityLevel.moderatelyActive,
    );
    final command = ActivateProgramCommand(
      repository: programRepository,
      clock: createTestClock(),
      idGenerator: createTestIds(),
      engine: engine,
    );
    final result = await command.execute(
      profileId: profileId,
      program: ProgramCode.maintenance,
      previewInputs: inputs,
      currentInputs: inputs,
      userConfirmed: true,
      programRequiresTargetWeight: false,
      programRequiresHabitFocus: false,
    );
    expect(result, isA<ActivationSucceeded>());
  }

  group('potret nilai gizi dibekukan (Design D1, task 4.2)', () {
    test('pembaruan nilai gizi katalog tidak mengubah catatan yang sudah '
        'dicatat', () async {
      final food = await foodRepository.createUserFood(
        name: 'Tempe goreng rumahan',
        category: FoodCategory.other,
        serving: const ServingSizeInput(
          label: '2 potong',
          amount: 2,
          unit: 'potong',
          nutrition: NutritionProfile(
            energy: null,
            proteinG: 10,
            carbohydrateG: 6,
            fatG: 8,
          ),
        ),
      );
      final loaded = (await foodRepository.findById(food.id))!;
      final serving = loaded.defaultServing;

      final addResult = await repository.addEntry(
        profileId: profileId,
        date: today,
        mealTime: MealTime.lunch,
        food: loaded,
        serving: serving,
        quantity: 1,
      );
      expect(addResult, isA<Ok<MealEntry>>());
      final entryId = (addResult as Ok<MealEntry>).value.id;

      // Katalog diperbarui SETELAH dicatat — nilai jauh berbeda.
      await foodRepository.updateUserFood(
        food.id,
        name: loaded.name,
        serving: const ServingSizeInput(
          label: '2 potong (direvisi)',
          amount: 2,
          unit: 'potong',
          nutrition: NutritionProfile(
            energy: null,
            proteinG: 999,
            carbohydrateG: 999,
            fatG: 999,
          ),
        ),
      );

      final entries = await repository.entriesForDate(profileId, today);
      final stillFrozen = entries.firstWhere((e) => e.id == entryId);
      expect(stillFrozen.nutritionPerServing.proteinG, 10);
      expect(stillFrozen.nutritionPerServing.fatG, 8);
      expect(stillFrozen.foodNameSnapshot, 'Tempe goreng rumahan');
    });
  });

  group('penulisan catatan bersifat utuh (task 4.1/4.8)', () {
    test('kegagalan di tengah transaksi tidak meninggalkan catatan atau '
        'butir sebagian', () async {
      await expectLater(
        db.transaction(() async {
          await db
              .into(db.mealEntries)
              .insert(
                MealEntriesCompanion.insert(
                  id: 'entry-interrupted',
                  createdAt: testInstant,
                  updatedAt: testInstant,
                  profileId: profileId,
                  localDate: today.iso,
                  mealTime: MealTime.breakfast.stableCode,
                ),
              );
          throw const _SimulatedFailure();
        }),
        throwsA(isA<_SimulatedFailure>()),
      );

      expect(await repository.entriesForDate(profileId, today), isEmpty);
      final rows = await db.select(db.mealEntries).get();
      expect(rows, isEmpty);
    });
  });

  group('penolakan jumlah tidak sah (task 4.6)', () {
    test('jumlah nol ditolak dan tidak membuat catatan', () async {
      final food = (await foodRepository.findById('food-nasi-putih'))!;

      final result = await repository.addEntry(
        profileId: profileId,
        date: today,
        mealTime: MealTime.breakfast,
        food: food,
        serving: food.defaultServing,
        quantity: 0,
      );

      expect(result, isA<Err<MealEntry>>());
      expect(await repository.entriesForDate(profileId, today), isEmpty);
    });

    test('jumlah negatif ditolak dan tidak membuat catatan', () async {
      final food = (await foodRepository.findById('food-nasi-putih'))!;

      final result = await repository.addEntry(
        profileId: profileId,
        date: today,
        mealTime: MealTime.breakfast,
        food: food,
        serving: food.defaultServing,
        quantity: -1,
      );

      expect(result, isA<Err<MealEntry>>());
      expect(await repository.entriesForDate(profileId, today), isEmpty);
    });
  });

  group('agregasi harian (Design D9, task 5.2)', () {
    test(
      'nilai belum diketahui tidak pernah menjadi nol di agregasi',
      () async {
        final knownFood = (await foodRepository.findById('food-nasi-putih'))!;
        final unknownFatFood = await foodRepository.createUserFood(
          name: 'Makanan tanpa data lemak',
          category: FoodCategory.other,
          serving: ServingSizeInput(
            label: '1 porsi',
            amount: 1,
            unit: 'porsi',
            nutrition: NutritionProfile(
              energy: Energy.kcalValue(120, field: 'energy').valueOrNull,
              fatG: null,
              proteinG: 5,
            ),
          ),
        );

        await repository.addEntry(
          profileId: profileId,
          date: today,
          mealTime: MealTime.breakfast,
          food: knownFood,
          serving: knownFood.defaultServing,
          quantity: 1,
        );
        await repository.addEntry(
          profileId: profileId,
          date: today,
          mealTime: MealTime.lunch,
          food: unknownFatFood,
          serving: unknownFatFood.defaultServing,
          quantity: 1,
        );

        final total = await repository.dailyTotal(profileId, today);
        expect(total.hasAnyEntries, isTrue);
        expect(
          total.nutrition.energy,
          isNotNull,
          reason: 'kedua makanan punya energi diketahui',
        );
        expect(
          total.nutrition.fatG,
          isNull,
          reason:
              'satu makanan tidak tahu lemaknya, jadi total lemak hari itu '
              'SHALL belum diketahui, bukan hanya milik makanan pertama',
        );
      },
    );

    test('hari tanpa catatan memberi seluruhnya belum diketahui', () async {
      final total = await repository.dailyTotal(profileId, today);
      expect(total.hasAnyEntries, isFalse);
      expect(total.nutrition.isFullyUnknown, isTrue);
    });
  });

  group('menyunting, memindahkan, menghapus (task 4.3/4.4/4.5)', () {
    test(
      'memindahkan catatan antar waktu makan tidak mengubah total harian',
      () async {
        final food = (await foodRepository.findById('food-nasi-putih'))!;
        final added = await repository.addEntry(
          profileId: profileId,
          date: today,
          mealTime: MealTime.snack,
          food: food,
          serving: food.defaultServing,
          quantity: 1,
        );
        final entry = (added as Ok<MealEntry>).value;
        final totalBefore = await repository.dailyTotal(profileId, today);

        final moved = await repository.updateEntry(
          entryId: entry.id,
          serving: food.defaultServing,
          quantity: 1,
          mealTime: MealTime.dinner,
        );
        expect((moved as Ok<MealEntry>).value.mealTime, MealTime.dinner);

        final totalAfter = await repository.dailyTotal(profileId, today);
        expect(
          totalAfter.nutrition.energy?.kcal,
          totalBefore.nutrition.energy?.kcal,
        );
      },
    );

    test('menyunting satu catatan tidak mengubah catatan lain dari makanan '
        'yang sama di hari berbeda', () async {
      final food = (await foodRepository.findById('food-nasi-putih'))!;
      const other = LocalDate(2026, 11, 7);

      final todayEntry =
          ((await repository.addEntry(
                    profileId: profileId,
                    date: today,
                    mealTime: MealTime.lunch,
                    food: food,
                    serving: food.defaultServing,
                    quantity: 1,
                  ))
                  as Ok<MealEntry>)
              .value;
      await repository.addEntry(
        profileId: profileId,
        date: other,
        mealTime: MealTime.lunch,
        food: food,
        serving: food.defaultServing,
        quantity: 1,
      );

      await repository.updateEntry(
        entryId: todayEntry.id,
        serving: food.defaultServing,
        quantity: 3,
        mealTime: MealTime.lunch,
      );

      final otherDayEntries = await repository.entriesForDate(profileId, other);
      expect(otherDayEntries.single.quantity, 1);
    });

    test('menghapus catatan mengurangi total harian sesuai nilainya', () async {
      final food = (await foodRepository.findById('food-nasi-putih'))!;
      final added =
          ((await repository.addEntry(
                    profileId: profileId,
                    date: today,
                    mealTime: MealTime.breakfast,
                    food: food,
                    serving: food.defaultServing,
                    quantity: 1,
                  ))
                  as Ok<MealEntry>)
              .value;

      await repository.deleteEntry(added.id);

      final entries = await repository.entriesForDate(profileId, today);
      expect(entries, isEmpty);
      final total = await repository.dailyTotal(profileId, today);
      expect(total.hasAnyEntries, isFalse);
    });
  });

  group('penyambungan potret kemajuan program (Design D8, task 5.3/5.4)', () {
    test('tanpa program berjalan, pencatatan tetap berhasil tanpa memicu '
        'potret kemajuan apa pun', () async {
      final food = (await foodRepository.findById('food-nasi-putih'))!;
      final result = await repository.addEntry(
        profileId: profileId,
        date: today,
        mealTime: MealTime.breakfast,
        food: food,
        serving: food.defaultServing,
        quantity: 1,
      );
      expect(result, isA<Ok<MealEntry>>());

      final progressRows = await db.select(db.programProgress).get();
      expect(progressRows, isEmpty);
    });

    test('penambahan, penyuntingan, dan pemindahan catatan memicu pembangunan '
        'ulang potret kemajuan tanpa menggandakan baris', () async {
      await activeMaintenanceProgram();
      final program = (await programRepository.findRunning(profileId))!;
      final food = (await foodRepository.findById('food-nasi-putih'))!;

      final added =
          ((await repository.addEntry(
                    profileId: profileId,
                    date: today,
                    mealTime: MealTime.breakfast,
                    food: food,
                    serving: food.defaultServing,
                    quantity: 1,
                  ))
                  as Ok<MealEntry>)
              .value;

      var progress = await programRepository.listProgress(program.id);
      expect(progress, hasLength(1));
      expect(progress.single.loggedMealsCount, 1);
      expect(progress.single.consumedEnergyKcal, isNotNull);

      await repository.updateEntry(
        entryId: added.id,
        serving: food.defaultServing,
        quantity: 2,
        mealTime: MealTime.lunch,
      );

      progress = await programRepository.listProgress(program.id);
      expect(
        progress,
        hasLength(1),
        reason: 'satu tanggal SHALL tetap satu baris potret (idempoten)',
      );
      expect(progress.single.loggedMealsCount, 1);

      await repository.deleteEntry(added.id);
      progress = await programRepository.listProgress(program.id);
      expect(progress.single.loggedMealsCount, 0);
      expect(progress.single.consumedEnergyKcal, isNull);
    });
  });
}

class _SimulatedFailure implements Exception {
  const _SimulatedFailure();
}
