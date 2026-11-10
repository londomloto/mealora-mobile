import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/errors/failure.dart';
import 'package:mealora/core/errors/result.dart';
import 'package:mealora/data/local/drift_diary_repository.dart';
import 'package:mealora/data/local/drift_food_repository.dart';
import 'package:mealora/data/local/drift_profile_repository.dart';
import 'package:mealora/data/local/drift_program_repository.dart';
import 'package:mealora/data/local/drift_weight_repository.dart';
import 'package:mealora/data/local/program_progress_snapshot.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/domain/food/food_category.dart';
import 'package:mealora/domain/food/food_repository.dart';
import 'package:mealora/domain/food/meal_time.dart';
import 'package:mealora/domain/food/nutrition_profile.dart';
import 'package:mealora/domain/nutrition/activity_level.dart';
import 'package:mealora/domain/nutrition/biological_input.dart';
import 'package:mealora/domain/profile/user_profile.dart';
import 'package:mealora/domain/program/commands/activate_program_command.dart';
import 'package:mealora/domain/program/commands/activation_result.dart';
import 'package:mealora/domain/program/nutrition_policy.dart';
import 'package:mealora/domain/program/program_code.dart';
import 'package:mealora/domain/program/program_engine.dart';
import 'package:mealora/domain/program/program_proposal_inputs.dart';
import 'package:mealora/domain/shared/units.dart';
import 'package:mealora/domain/weight/weight_record.dart';

import 'test_database.dart';

/// `DriftWeightRepository` (change 008, task 2.6): berat terbaru tetap
/// benar setelah penyuntingan dan setelah penghapusan catatan terakhir,
/// dan penolakan bernilai jenis untuk berat di luar rentang masuk akal
/// serta tanggal di masa depan.
void main() {
  late AppDatabase db;
  late DriftProgramRepository programRepository;
  late DriftDiaryRepository diaryRepository;
  late DriftFoodRepository foodRepository;
  late DriftWeightRepository repository;
  const profileId = 'profile-1';

  setUp(() async {
    db = createTestDatabase();
    await DriftProfileRepository(
      db,
      clock: createTestClock(),
    ).upsert(const UserProfile(id: profileId));
    programRepository = DriftProgramRepository(
      db,
      clock: createTestClock(),
      ids: createTestIds(),
    );
    foodRepository = DriftFoodRepository(
      db,
      ids: createTestIds(),
      clock: createTestClock(),
    );
    diaryRepository = DriftDiaryRepository(
      db,
      clock: createTestClock(),
      ids: createTestIds(),
      programRepository: programRepository,
    );
    repository = DriftWeightRepository(
      db,
      clock: createTestClock(),
      diaryRepository: diaryRepository,
      ids: createTestIds(),
    );
  });

  tearDown(() => db.close());

  test('latest() mengembalikan null sebelum ada catatan', () async {
    expect(await repository.latest(profileId), isNull);
  });

  test('addRecord() menyimpan catatan dan terbaca kembali', () async {
    final result = await repository.addRecord(
      profileId: profileId,
      date: const LocalDate(2026, 11, 6),
      weightKg: 68.4,
      note: 'setelah bangun pagi',
    );

    expect(result, isA<Ok<WeightRecord>>());
    final record = result.valueOrNull!;
    expect(record.weightKg, 68.4);
    expect(record.localDate, const LocalDate(2026, 11, 6));
    expect(record.note, 'setelah bangun pagi');

    final latest = await repository.latest(profileId);
    expect(latest?.id, record.id);
  });

  test('latest() mengembalikan catatan untuk tanggal lokal terbaru, bukan '
      'urutan penambahan', () async {
    await repository.addRecord(
      profileId: profileId,
      date: const LocalDate(2026, 10, 30),
      weightKg: 70,
    );
    final newer = await repository.addRecord(
      profileId: profileId,
      date: const LocalDate(2026, 11, 6),
      weightKg: 68.4,
    );

    final latest = await repository.latest(profileId);
    expect(latest?.id, newer.valueOrNull!.id);
    expect(latest?.weightKg, 68.4);
  });

  test(
    'menyunting catatan terbaru mengubah apa yang dikembalikan latest()',
    () async {
      final added = await repository.addRecord(
        profileId: profileId,
        date: const LocalDate(2026, 11, 6),
        weightKg: 68.4,
      );

      await repository.updateRecord(
        recordId: added.valueOrNull!.id,
        date: const LocalDate(2026, 11, 6),
        weightKg: 67.9,
        note: 'koreksi salah ketik',
      );

      final latest = await repository.latest(profileId);
      expect(latest?.weightKg, 67.9);
      expect(latest?.note, 'koreksi salah ketik');
    },
  );

  test('menghapus catatan terakhir membuat latest() jatuh ke catatan '
      'sebelumnya', () async {
    await repository.addRecord(
      profileId: profileId,
      date: const LocalDate(2026, 10, 30),
      weightKg: 70,
    );
    final newest = await repository.addRecord(
      profileId: profileId,
      date: const LocalDate(2026, 11, 6),
      weightKg: 68.4,
    );

    await repository.deleteRecord(newest.valueOrNull!.id);

    final latest = await repository.latest(profileId);
    expect(latest?.weightKg, 70);
  });

  test('catatan terhapus tidak muncul pada recordsInRange()', () async {
    final added = await repository.addRecord(
      profileId: profileId,
      date: const LocalDate(2026, 11, 6),
      weightKg: 68.4,
    );
    await repository.deleteRecord(added.valueOrNull!.id);

    final records = await repository.recordsInRange(
      profileId,
      from: const LocalDate(2026, 10, 1),
      to: const LocalDate(2026, 11, 30),
    );
    expect(records, isEmpty);
  });

  test('recordsInRange() mengurutkan dari yang terlama', () async {
    await repository.addRecord(
      profileId: profileId,
      date: const LocalDate(2026, 11, 6),
      weightKg: 68.4,
    );
    await repository.addRecord(
      profileId: profileId,
      date: const LocalDate(2026, 10, 30),
      weightKg: 70,
    );

    final records = await repository.recordsInRange(
      profileId,
      from: const LocalDate(2026, 10, 1),
      to: const LocalDate(2026, 11, 30),
    );
    expect(records.map((r) => r.localDate.iso), ['2026-10-30', '2026-11-06']);
  });

  group('validasi nilai bertipe', () {
    test(
      'menolak berat di luar rentang masuk akal tanpa menulis apa pun',
      () async {
        final result = await repository.addRecord(
          profileId: profileId,
          date: const LocalDate(2026, 11, 6),
          weightKg: 500,
        );

        expect(result, isA<Err<WeightRecord>>());
        expect(result.failureOrNull?.code, FailureCode.valueOutOfRange);
        expect(await repository.latest(profileId), isNull);
      },
    );

    test(
      'menolak tanggal catatan di masa depan tanpa menulis apa pun',
      () async {
        final result = await repository.addRecord(
          profileId: profileId,
          date: const LocalDate(2026, 11, 9),
          weightKg: 68.4,
        );

        expect(result, isA<Err<WeightRecord>>());
        expect(result.failureOrNull?.code, FailureCode.invalidValue);
        expect(await repository.latest(profileId), isNull);
      },
    );

    test(
      'updateRecord() juga menolak berat di luar rentang masuk akal',
      () async {
        final added = await repository.addRecord(
          profileId: profileId,
          date: const LocalDate(2026, 11, 6),
          weightKg: 68.4,
        );

        final result = await repository.updateRecord(
          recordId: added.valueOrNull!.id,
          date: const LocalDate(2026, 11, 6),
          weightKg: 2,
        );

        expect(result, isA<Err<WeightRecord>>());
        expect((await repository.latest(profileId))?.weightKg, 68.4);
      },
    );
  });

  group(
    'pembangunan ulang potret kemajuan bersama buku harian (task 3.1/3.5)',
    () {
      const date = LocalDate(2026, 11, 6);

      Future<String> activeMaintenanceProgram() async {
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
        final program = await programRepository.findRunning(profileId);
        return program!.id;
      }

      /// Mencatat satu makan sungguhan (lewat katalog + buku harian),
      /// bukan menulis langsung ke tabel potret — supaya pembangunan
      /// ulang berikutnya benar-benar membaca dari sumber kebenaran, sama
      /// seperti alur nyata (Design D5 change 004: potret adalah turunan).
      Future<void> logOneMeal(LocalDate onDate) async {
        final food = await foodRepository.createUserFood(
          name: 'Nasi uduk',
          category: FoodCategory.other,
          serving: const ServingSizeInput(
            label: '1 porsi',
            amount: 1,
            unit: 'porsi',
            nutrition: NutritionProfile(
              energy: Energy.zero,
              proteinG: 20,
              carbohydrateG: 40,
              fatG: 10,
            ),
          ),
        );
        final loaded = (await foodRepository.findById(food.id))!;
        final addResult = await diaryRepository.addEntry(
          profileId: profileId,
          date: onDate,
          mealTime: MealTime.breakfast,
          food: loaded,
          serving: loaded.defaultServing,
          quantity: 1,
        );
        expect(addResult, isA<Ok<Object>>());
      }

      Future<ProgramProgressSnapshot> progressFor(
        String userProgramId,
        LocalDate forDate,
      ) async {
        final rows = await programRepository.listProgress(userProgramId);
        return rows.firstWhere((row) => row.recordedLocalDate == forDate);
      }

      test('mencatat berat pada tanggal yang sudah punya catatan makan '
          'tidak menghapus nilai buku harian itu', () async {
        final userProgramId = await activeMaintenanceProgram();
        await logOneMeal(date);
        final beforeWeight = await progressFor(userProgramId, date);
        expect(beforeWeight.loggedMealsCount, 1);
        expect(beforeWeight.proteinG, 20);

        await repository.addRecord(
          profileId: profileId,
          date: date,
          weightKg: 68.4,
        );

        final snapshot = await progressFor(userProgramId, date);
        expect(snapshot.weightKg, 68.4);
        expect(
          snapshot.loggedMealsCount,
          1,
          reason:
              'catatan berat tidak boleh menimpa nilai buku harian '
              'yang sudah ada untuk tanggal yang sama',
        );
        expect(snapshot.proteinG, 20);
      });

      test('mencatat makan pada tanggal yang sudah punya catatan berat '
          'tidak menghapus nilai berat itu', () async {
        final userProgramId = await activeMaintenanceProgram();
        await repository.addRecord(
          profileId: profileId,
          date: date,
          weightKg: 68.4,
        );
        expect((await progressFor(userProgramId, date)).weightKg, 68.4);

        await logOneMeal(date);

        final snapshot = await progressFor(userProgramId, date);
        expect(
          snapshot.weightKg,
          68.4,
          reason:
              'catatan makan tidak boleh menimpa nilai berat yang sudah '
              'ada untuk tanggal yang sama',
        );
        expect(snapshot.loggedMealsCount, 1);
      });

      test('menghapus satu-satunya catatan berat pada sebuah tanggal '
          'mengosongkan weightKg pada potret tanggal itu tanpa mengubah '
          'nilai lain', () async {
        final userProgramId = await activeMaintenanceProgram();
        final added = await repository.addRecord(
          profileId: profileId,
          date: date,
          weightKg: 68.4,
        );
        expect((await progressFor(userProgramId, date)).weightKg, 68.4);

        await repository.deleteRecord(added.valueOrNull!.id);

        final snapshot = await progressFor(userProgramId, date);
        expect(snapshot.weightKg, isNull);
        expect(snapshot.activeDayNumber, 1);
      });

      test('menyunting tanggal catatan berat membangun ulang potret tanggal '
          'lama maupun tanggal baru', () async {
        final userProgramId = await activeMaintenanceProgram();
        final added = await repository.addRecord(
          profileId: profileId,
          date: date,
          weightKg: 68.4,
        );

        const newDate = LocalDate(2026, 11, 7);
        await repository.updateRecord(
          recordId: added.valueOrNull!.id,
          date: newDate,
          weightKg: 68.1,
        );

        expect((await progressFor(userProgramId, date)).weightKg, isNull);
        expect((await progressFor(userProgramId, newDate)).weightKg, 68.1);
      });
    },
  );
}
