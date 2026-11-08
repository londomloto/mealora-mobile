import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/data/local/drift_program_repository.dart';
import 'package:mealora/data/local/program_progress_snapshot.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/database/seeds/program_catalog_seed.dart';
import 'package:mealora/domain/program/program_code.dart';

import 'test_database.dart';

/// Pembangunan ulang potret kemajuan (tasks 6.1–6.9, change 004).
///
/// Sumber data sungguhan (buku harian, berat badan) belum ada — tabelnya
/// baru dibuat change 007/008 (design.md Non-Goals). Uji di sini memanggil
/// `rebuildProgressForDate` dengan nilai yang sudah dihitung, membuktikan
/// mekanisme penyisipan-atau-perbarui dan perlakuan "belum diketahui"
/// bekerja — bukan membuktikan perhitungan kemajuan itu sendiri, yang
/// datang bersama change buku harian.
void main() {
  late AppDatabase db;
  late DriftProgramRepository repository;
  late String userProgramId;

  setUp(() async {
    db = createTestDatabase();
    repository = DriftProgramRepository(
      db,
      clock: createTestClock(),
      ids: createTestIds(),
    );
    userProgramId = 'up-1';
    await db
        .into(db.userPrograms)
        .insert(
          UserProgramsCompanion.insert(
            id: userProgramId,
            createdAt: testInstant,
            updatedAt: testInstant,
            profileId: 'profile-1',
            programId: kProgramCatalogIds[ProgramCode.maintenance]!,
            status: 'active',
            inputSnapshotJson: '{}',
            calculatorVersion: 'v1',
            policyVersion: 'v1',
          ),
        );
  });

  tearDown(() => db.close());

  ProgramProgressInput input({
    double? consumedEnergyKcal,
    double? energyAdherenceRatio,
    int loggedMealsCount = 2,
    bool diaryComplete = false,
    int activeDayNumber = 1,
  }) => ProgramProgressInput(
    recordedAt: testInstant,
    consumedEnergyKcal: consumedEnergyKcal,
    energyAdherenceRatio: energyAdherenceRatio,
    loggedMealsCount: loggedMealsCount,
    diaryComplete: diaryComplete,
    activeDayNumber: activeDayNumber,
    calculationVersion: 'v1',
  );

  test(
    'pembangunan ulang tiga kali menghasilkan satu baris dengan nilai yang sama (6.5)',
    () async {
      const date = LocalDate(2026, 11, 8);
      for (var i = 0; i < 3; i++) {
        await repository.rebuildProgressForDate(
          userProgramId: userProgramId,
          localDate: date,
          input: input(consumedEnergyKcal: 1800, loggedMealsCount: 2),
        );
      }

      final rows = await db.select(db.programProgress).get();
      expect(rows, hasLength(1));
      expect(rows.single.consumedEnergyKcal, 1800);
      expect(rows.single.loggedMealsCount, 2);
    },
  );

  test('menyunting catatan sumber lalu membangun ulang mencerminkan nilai '
      'terbaru tanpa menggandakan (6.6)', () async {
    const date = LocalDate(2026, 11, 8);
    await repository.rebuildProgressForDate(
      userProgramId: userProgramId,
      localDate: date,
      input: input(consumedEnergyKcal: 1800, loggedMealsCount: 2),
    );
    // Pengguna menyunting catatan makanan — dipicu ulang dengan nilai baru.
    await repository.rebuildProgressForDate(
      userProgramId: userProgramId,
      localDate: date,
      input: input(consumedEnergyKcal: 2100, loggedMealsCount: 3),
    );

    final rows = await db.select(db.programProgress).get();
    expect(rows, hasLength(1));
    expect(rows.single.consumedEnergyKcal, 2100);
    expect(rows.single.loggedMealsCount, 3);
  });

  test('pembangunan ulang penuh seluruh rentang menghasilkan nilai yang sama '
      'dengan potret tersimpan (6.7)', () async {
    final dates = [
      const LocalDate(2026, 11, 1),
      const LocalDate(2026, 11, 2),
      const LocalDate(2026, 11, 3),
    ];
    for (var i = 0; i < dates.length; i++) {
      await repository.rebuildProgressForDate(
        userProgramId: userProgramId,
        localDate: dates[i],
        input: input(consumedEnergyKcal: 1800.0 + i, activeDayNumber: i + 1),
      );
    }
    final before = await repository.listProgress(userProgramId);

    // Bangun ulang seluruh rentang lagi dengan nilai yang identik.
    for (var i = 0; i < dates.length; i++) {
      await repository.rebuildProgressForDate(
        userProgramId: userProgramId,
        localDate: dates[i],
        input: input(consumedEnergyKcal: 1800.0 + i, activeDayNumber: i + 1),
      );
    }
    final after = await repository.listProgress(userProgramId);

    expect(after, hasLength(before.length));
    for (var i = 0; i < before.length; i++) {
      expect(after[i].consumedEnergyKcal, before[i].consumedEnergyKcal);
      expect(after[i].recordedLocalDate, before[i].recordedLocalDate);
      expect(after[i].activeDayNumber, before[i].activeDayNumber);
    }
  });

  test('nilai belum diketahui disimpan kosong, bukan nol; pencacah tetap '
      'terisi (6.3)', () async {
    const date = LocalDate(2026, 11, 8);
    await repository.rebuildProgressForDate(
      userProgramId: userProgramId,
      localDate: date,
      input: input(
        consumedEnergyKcal: null,
        energyAdherenceRatio: null,
        loggedMealsCount: 0,
      ),
    );

    final rows = await db.select(db.programProgress).get();
    expect(rows.single.consumedEnergyKcal, isNull);
    expect(rows.single.energyAdherenceRatio, isNull);
    expect(rows.single.weightKg, isNull);
    expect(rows.single.loggedMealsCount, 0);
  });

  test(
    'hari dalam rentang jeda: pemanggil dapat menahan nomor hari aktif '
    'dan mengecualikan dari kesesuaian target, catatan tetap tersimpan (6.2)',
    () async {
      const day1 = LocalDate(2026, 11, 1);
      const pausedDay = LocalDate(2026, 11, 2);

      await repository.rebuildProgressForDate(
        userProgramId: userProgramId,
        localDate: day1,
        input: input(
          consumedEnergyKcal: 1800,
          energyAdherenceRatio: 0.9,
          activeDayNumber: 1,
        ),
      );
      // Hari jeda: pemanggil (logika di luar change ini) menahan nomor hari
      // aktif tetap 1 dan tidak mengisi rasio kesesuaian, tetapi catatan
      // makanan pada hari itu tetap dikirim dan tersimpan.
      await repository.rebuildProgressForDate(
        userProgramId: userProgramId,
        localDate: pausedDay,
        input: input(
          consumedEnergyKcal: 1200,
          energyAdherenceRatio: null,
          activeDayNumber: 1,
        ),
      );

      final rows = await repository.listProgress(userProgramId);
      expect(rows, hasLength(2));
      final paused = rows.firstWhere((r) => r.recordedLocalDate == pausedDay);
      expect(paused.activeDayNumber, 1);
      expect(paused.energyAdherenceRatio, isNull);
      expect(paused.consumedEnergyKcal, 1200);
    },
  );

  test(
    'tanggal lokal yang tersimpan dipakai apa adanya, tidak dihitung ulang (6.4)',
    () async {
      const date = LocalDate(2026, 11, 8);
      await repository.rebuildProgressForDate(
        userProgramId: userProgramId,
        localDate: date,
        input: input(),
      );

      final rows = await db.select(db.programProgress).get();
      expect(rows.single.recordedLocalDate, '2026-11-08');

      final reopened = DriftProgramRepository(
        db,
        clock: createTestClock(),
        ids: createTestIds(),
      );
      final listed = await reopened.listProgress(userProgramId);
      expect(listed.single.recordedLocalDate.iso, '2026-11-08');
    },
  );
}
