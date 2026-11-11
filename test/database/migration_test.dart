import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/core/errors/failure.dart';
import 'package:mealora/core/errors/result.dart';
import 'package:mealora/data/local/harness_record_dao.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/database/migrations/food_catalog_verification.dart';
import 'package:mealora/database/migrations/migration_verification.dart';
import 'package:mealora/database/migrations/program_catalog_verification.dart';
import 'package:mealora/database/storage_bootstrap.dart';

import 'legacy_v1_database.dart' as legacy;
import 'legacy_v2_database.dart' as legacy2;
import 'legacy_v3_database.dart' as legacy3;
import 'legacy_v4_database.dart' as legacy4;
import 'legacy_v5_database.dart' as legacy5;
import 'legacy_v6_database.dart' as legacy6;
import 'legacy_v7_database.dart' as legacy7;
import 'test_database.dart';

/// Harness migrasi, termasuk migrasi versi 1 → 2 (change 004, tasks
/// 8.1–8.6): empat tabel program, indeks, trigger, dan seed katalog,
/// diuji terhadap berkas SQLite yang sungguh-sungguh dibuat pada versi 1
/// lebih dulu (`LegacyV1Database`), bukan basis data yang langsung dibuat
/// pada versi terkini.
void main() {
  late Directory workspace;

  setUp(() {
    workspace = Directory.systemTemp.createTempSync('mealora_migration');
  });

  tearDown(() {
    try {
      if (workspace.existsSync()) {
        workspace.deleteSync(recursive: true);
      }
    } on FileSystemException {
      // Pada Windows berkas kadang masih dipegang proses saat uji selesai;
      // direktori sementara dibersihkan sistem.
    }
  });

  File databaseFile([String name = 'mealora.sqlite']) =>
      File('${workspace.path}/$name');

  group('fixture: basis data kosong', () {
    test(
      'pembuatan langsung pada versi terkini menghasilkan skema sehat',
      () async {
        final db = createTestDatabase(executor: NativeDatabase(databaseFile()));
        addTearDown(db.close);

        final check = await verifyMigration(
          db,
          expectedSchemaVersion: kSchemaVersion,
        );

        expect(check.schemaVersion, kSchemaVersion);
        expect(check.foreignKeyViolations, 0);
        expect(check.foreignKeysEnabled, isTrue);
        expect(check.isHealthy, isTrue);
      },
    );

    test('bootstrap penyimpanan mengembalikan basis data siap pakai', () async {
      final result = await openLocalStorage(
        databaseFactory: () =>
            createTestDatabase(executor: NativeDatabase(databaseFile())),
      );

      expect(result, isA<Ok<AppDatabase>>());
      await result.valueOrNull?.close();
    });
  });

  group('fixture: basis data berisi data harness', () {
    test('membuka ulang tidak menjalankan ulang pembuatan skema '
        'dan tidak menyentuh data', () async {
      final file = databaseFile();

      final first = createTestDatabase(executor: NativeDatabase(file));
      final firstDao = HarnessRecordDao(
        first,
        clock: createTestClock(),
        ids: createTestIds(),
      );
      await firstDao.create(label: 'Sebelum migrasi', amount: 3);
      await first.close();

      final second = createTestDatabase(executor: NativeDatabase(file));
      addTearDown(second.close);
      final secondDao = HarnessRecordDao(
        second,
        clock: createTestClock(),
        ids: createTestIds(),
      );

      final records = await secondDao.listActive();
      expect(records, hasLength(1));
      expect(records.single.label, 'Sebelum migrasi');

      final check = await verifyMigration(
        second,
        expectedSchemaVersion: kSchemaVersion,
      );
      expect(check.isHealthy, isTrue);
    });
  });

  group('fixture: migrasi terputus', () {
    test('perubahan yang terputus di tengah tidak merusak data '
        'dan percobaan berikutnya berhasil', () async {
      final file = databaseFile();

      final first = createTestDatabase(executor: NativeDatabase(file));
      final firstDao = HarnessRecordDao(
        first,
        clock: createTestClock(),
        ids: createTestIds(),
      );
      await firstDao.create(label: 'Harus selamat', amount: 1);
      await first.close();

      // Simulasi migrasi yang terhenti sebelum selesai: perubahan struktur
      // dimulai di dalam transaksi, lalu prosesnya berhenti tanpa commit.
      final interrupted = createTestDatabase(executor: NativeDatabase(file));
      await expectLater(
        interrupted.transaction(() async {
          await interrupted.customStatement(
            'CREATE TABLE migration_wip (id TEXT NOT NULL)',
          );
          throw const _SimulatedInterruption();
        }),
        throwsA(isA<_SimulatedInterruption>()),
      );
      await interrupted.close();

      // Percobaan berikutnya berjalan dari keadaan yang konsisten.
      final retry = createTestDatabase(executor: NativeDatabase(file));
      addTearDown(retry.close);
      final retryDao = HarnessRecordDao(
        retry,
        clock: createTestClock(),
        ids: createTestIds(),
      );

      final records = await retryDao.listActive();
      expect(records, hasLength(1));
      expect(records.single.label, 'Harus selamat');

      final leftovers = await retry
          .customSelect(
            'SELECT name FROM sqlite_master '
            "WHERE type = 'table' AND name = 'migration_wip'",
          )
          .get();
      expect(leftovers, isEmpty);

      final check = await verifyMigration(
        retry,
        expectedSchemaVersion: kSchemaVersion,
      );
      expect(check.isHealthy, isTrue);
    });
  });

  group('fixture: migrasi versi 1 ke 2 (change 004)', () {
    test('basis data versi 1 berisi data harness bermigrasi ke versi 2 dengan '
        'sehat, katalog terseed, dan tidak ada program yang aktif', () async {
      final file = databaseFile();

      final v1 = legacy.LegacyV1Database(NativeDatabase(file));
      await _insertLegacyHarnessRecord(
        v1,
        id: 'legacy-1',
        label: 'Sebelum migrasi ke v2',
        amount: 5,
      );
      await v1.close();

      final upgraded = createTestDatabase(executor: NativeDatabase(file));
      addTearDown(upgraded.close);

      final check = await verifyMigration(
        upgraded,
        expectedSchemaVersion: kSchemaVersion,
      );
      expect(check.isHealthy, isTrue);
      expect(await verifyProgramCatalog(upgraded), isTrue);

      final upgradedDao = HarnessRecordDao(
        upgraded,
        clock: createTestClock(),
        ids: createTestIds(),
      );
      final records = await upgradedDao.listActive();
      expect(records, hasLength(1));
      expect(records.single.label, 'Sebelum migrasi ke v2');

      final userPrograms = await upgraded.select(upgraded.userPrograms).get();
      expect(
        userPrograms,
        isEmpty,
        reason: 'tidak ada profil yang didaftarkan otomatis (Design D8)',
      );
    });

    test('migrasi versi 1 ke 2 yang terputus di tengah tidak merusak data dan '
        'percobaan berikutnya berhasil', () async {
      final file = databaseFile();

      final v1 = legacy.LegacyV1Database(NativeDatabase(file));
      await _insertLegacyHarnessRecord(
        v1,
        id: 'legacy-2',
        label: 'Harus selamat lintas migrasi',
        amount: 1,
      );
      await v1.close();

      // Simulasi migrasi v1→v2 yang terhenti: tabel program mulai dibuat
      // di dalam transaksi, lalu prosesnya berhenti sebelum selesai.
      final interrupted = legacy.LegacyV1Database(NativeDatabase(file));
      await expectLater(
        interrupted.transaction(() async {
          await interrupted.customStatement(
            'CREATE TABLE programs_wip (id TEXT NOT NULL)',
          );
          throw const _SimulatedInterruption();
        }),
        throwsA(isA<_SimulatedInterruption>()),
      );
      await interrupted.close();

      final retry = createTestDatabase(executor: NativeDatabase(file));
      addTearDown(retry.close);

      final retryDao = HarnessRecordDao(
        retry,
        clock: createTestClock(),
        ids: createTestIds(),
      );
      final records = await retryDao.listActive();
      expect(records, hasLength(1));
      expect(records.single.label, 'Harus selamat lintas migrasi');

      final leftovers = await retry
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table' "
            "AND name = 'programs_wip'",
          )
          .get();
      expect(leftovers, isEmpty);

      final check = await verifyMigration(
        retry,
        expectedSchemaVersion: kSchemaVersion,
      );
      expect(check.isHealthy, isTrue);
      expect(await verifyProgramCatalog(retry), isTrue);
    });
  });

  group('fixture: migrasi versi 2 ke 3 (change 005)', () {
    test('basis data versi 2 berisi data program bermigrasi ke versi 3 dengan '
        'sehat, dan data tak terkait (harness, katalog) tetap ada', () async {
      final file = databaseFile();

      final v2 = legacy2.LegacyV2Database(NativeDatabase(file));
      await _insertLegacyV2ProgramRow(v2, profileId: 'orphan-profile-1');
      await _insertLegacyHarnessRecordV2(
        v2,
        id: 'legacy-v2-harness',
        label: 'Sebelum migrasi ke v3',
        amount: 2,
      );
      await v2.customStatement('PRAGMA user_version = 2');
      await v2.close();

      final upgraded = createTestDatabase(executor: NativeDatabase(file));
      addTearDown(upgraded.close);

      final check = await verifyMigration(
        upgraded,
        expectedSchemaVersion: kSchemaVersion,
      );
      expect(check.isHealthy, isTrue);

      final harnessDao = HarnessRecordDao(
        upgraded,
        clock: createTestClock(),
        ids: createTestIds(),
      );
      final records = await harnessDao.listActive();
      expect(records, hasLength(1));
      expect(records.single.label, 'Sebelum migrasi ke v3');

      final catalogRows = await upgraded.select(upgraded.programs).get();
      expect(
        catalogRows,
        isNotEmpty,
        reason:
            'baris katalog program (bukan user_programs) tidak '
            'tersentuh migrasi',
      );
    });

    test('basis data versi 2 berisi program tanpa profil: baris yatim '
        'dihapus, tidak ada profil yang dibuat otomatis, dan pemeriksaan '
        'foreign key bersih (task 2.7, design.md Open Questions)', () async {
      final file = databaseFile();

      final v2 = legacy2.LegacyV2Database(NativeDatabase(file));
      await _insertLegacyV2ProgramRow(v2, profileId: 'orphan-profile-2');
      await v2.customStatement('PRAGMA user_version = 2');
      await v2.close();

      final upgraded = createTestDatabase(executor: NativeDatabase(file));
      addTearDown(upgraded.close);

      final check = await verifyMigration(
        upgraded,
        expectedSchemaVersion: kSchemaVersion,
      );
      expect(check.isHealthy, isTrue);
      expect(check.foreignKeyViolations, 0);

      final profileRows = await upgraded.select(upgraded.profiles).get();
      expect(
        profileRows,
        isEmpty,
        reason: 'migrasi tidak pernah membuat profil otomatis (Design D8)',
      );

      final userProgramRows = await upgraded
          .select(upgraded.userPrograms)
          .get();
      expect(
        userProgramRows,
        isEmpty,
        reason: 'baris program yatim (tanpa profil) dihapus saat migrasi',
      );

      final eventRows = await upgraded.select(upgraded.programEvents).get();
      final progressRows = await upgraded
          .select(upgraded.programProgress)
          .get();
      expect(eventRows, isEmpty);
      expect(progressRows, isEmpty);
    });

    test('migrasi versi 2 ke 3 yang terputus di tengah tidak merusak data dan '
        'percobaan berikutnya berhasil', () async {
      final file = databaseFile();

      final v2 = legacy2.LegacyV2Database(NativeDatabase(file));
      await _insertLegacyV2ProgramRow(v2, profileId: 'orphan-profile-3');
      await v2.customStatement('PRAGMA user_version = 2');
      await v2.close();

      // Simulasi migrasi v2→v3 yang terhenti: tabel profil mulai dibuat
      // di dalam transaksi, lalu prosesnya berhenti sebelum selesai.
      final interrupted = legacy2.LegacyV2Database(NativeDatabase(file));
      await expectLater(
        interrupted.transaction(() async {
          await interrupted.customStatement(
            'CREATE TABLE profiles_wip (id TEXT NOT NULL)',
          );
          throw const _SimulatedInterruption();
        }),
        throwsA(isA<_SimulatedInterruption>()),
      );
      await interrupted.close();

      final retry = createTestDatabase(executor: NativeDatabase(file));
      addTearDown(retry.close);

      final check = await verifyMigration(
        retry,
        expectedSchemaVersion: kSchemaVersion,
      );
      expect(check.isHealthy, isTrue);

      final leftovers = await retry
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table' "
            "AND name = 'profiles_wip'",
          )
          .get();
      expect(leftovers, isEmpty);
    });
  });

  group('fixture: migrasi versi 3 ke 4 (change 007)', () {
    test('basis data versi 3 berisi profil dan data harness bermigrasi ke '
        'versi 4 dengan sehat, katalog makanan terseed, dan data lama '
        'tidak tersentuh', () async {
      final file = databaseFile();

      final v3 = legacy3.LegacyV3Database(NativeDatabase(file));
      await _insertLegacyV3Profile(v3, id: 'profile-v3');
      await _insertLegacyHarnessRecordV3(
        v3,
        id: 'legacy-v3-harness',
        label: 'Sebelum migrasi ke v4',
        amount: 4,
      );
      await v3.customStatement('PRAGMA user_version = 3');
      await v3.close();

      final upgraded = createTestDatabase(executor: NativeDatabase(file));
      addTearDown(upgraded.close);

      final check = await verifyMigration(
        upgraded,
        expectedSchemaVersion: kSchemaVersion,
      );
      expect(check.isHealthy, isTrue);

      final catalogCheck = await verifyFoodCatalog(upgraded);
      expect(catalogCheck.isHealthy, isTrue, reason: catalogCheck.toString());
      expect(catalogCheck.builtInFoodCount, greaterThan(0));

      final harnessDao = HarnessRecordDao(
        upgraded,
        clock: createTestClock(),
        ids: createTestIds(),
      );
      final records = await harnessDao.listActive();
      expect(records, hasLength(1));
      expect(records.single.label, 'Sebelum migrasi ke v4');

      final profiles = await upgraded.select(upgraded.profiles).get();
      expect(profiles, hasLength(1));
      expect(profiles.single.id, 'profile-v3');
    });

    test('migrasi versi 3 ke 4 yang terputus di tengah tidak merusak data dan '
        'percobaan berikutnya berhasil', () async {
      final file = databaseFile();

      final v3 = legacy3.LegacyV3Database(NativeDatabase(file));
      await _insertLegacyHarnessRecordV3(
        v3,
        id: 'legacy-v3-harness-2',
        label: 'Harus selamat lintas migrasi v4',
        amount: 1,
      );
      await v3.customStatement('PRAGMA user_version = 3');
      await v3.close();

      // Simulasi migrasi v3→v4 yang terhenti: tabel makanan mulai dibuat
      // di dalam transaksi, lalu prosesnya berhenti sebelum selesai.
      final interrupted = legacy3.LegacyV3Database(NativeDatabase(file));
      await expectLater(
        interrupted.transaction(() async {
          await interrupted.customStatement(
            'CREATE TABLE foods_wip (id TEXT NOT NULL)',
          );
          throw const _SimulatedInterruption();
        }),
        throwsA(isA<_SimulatedInterruption>()),
      );
      await interrupted.close();

      final retry = createTestDatabase(executor: NativeDatabase(file));
      addTearDown(retry.close);

      final check = await verifyMigration(
        retry,
        expectedSchemaVersion: kSchemaVersion,
      );
      expect(check.isHealthy, isTrue);
      expect((await verifyFoodCatalog(retry)).isHealthy, isTrue);

      final retryDao = HarnessRecordDao(
        retry,
        clock: createTestClock(),
        ids: createTestIds(),
      );
      final records = await retryDao.listActive();
      expect(records, hasLength(1));
      expect(records.single.label, 'Harus selamat lintas migrasi v4');

      final leftovers = await retry
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table' "
            "AND name = 'foods_wip'",
          )
          .get();
      expect(leftovers, isEmpty);
    });

    test(
      'menjalankan ulang migrasi/seed (buka ulang) tetap idempoten',
      () async {
        final file = databaseFile();

        final v3 = legacy3.LegacyV3Database(NativeDatabase(file));
        await v3.customStatement('PRAGMA user_version = 3');
        await v3.close();

        final first = createTestDatabase(executor: NativeDatabase(file));
        final foodsFirst = await first.select(first.foods).get();
        await first.close();

        final second = createTestDatabase(executor: NativeDatabase(file));
        addTearDown(second.close);
        final foodsSecond = await second.select(second.foods).get();

        expect(
          foodsSecond.map((f) => f.id).toSet(),
          foodsFirst.map((f) => f.id).toSet(),
        );
      },
    );
  });

  group('fixture: migrasi versi 4 ke 5 (change 008)', () {
    test('basis data versi 4 berisi profil, makanan, dan program bermigrasi '
        'ke versi 5 dengan sehat, dan data lama tidak tersentuh', () async {
      final file = databaseFile();

      final v4 = legacy4.LegacyV4Database(NativeDatabase(file));
      await _insertLegacyV4Profile(v4, id: 'profile-v4');
      await _insertLegacyHarnessRecordV4(
        v4,
        id: 'legacy-v4-harness',
        label: 'Sebelum migrasi ke v5',
        amount: 4,
      );
      await v4.customStatement('PRAGMA user_version = 4');
      await v4.close();

      final upgraded = createTestDatabase(executor: NativeDatabase(file));
      addTearDown(upgraded.close);

      final check = await verifyMigration(
        upgraded,
        expectedSchemaVersion: kSchemaVersion,
      );
      expect(check.isHealthy, isTrue);

      final weightRows = await upgraded.select(upgraded.weightRecords).get();
      expect(
        weightRows,
        isEmpty,
        reason: 'tabel catatan berat baru dan kosong pada migrasi',
      );

      final catalogCheck = await verifyFoodCatalog(upgraded);
      expect(catalogCheck.isHealthy, isTrue, reason: catalogCheck.toString());

      final harnessDao = HarnessRecordDao(
        upgraded,
        clock: createTestClock(),
        ids: createTestIds(),
      );
      final records = await harnessDao.listActive();
      expect(records, hasLength(1));
      expect(records.single.label, 'Sebelum migrasi ke v5');

      final profiles = await upgraded.select(upgraded.profiles).get();
      expect(profiles, hasLength(1));
      expect(profiles.single.id, 'profile-v4');
    });

    test('migrasi versi 4 ke 5 yang terputus di tengah tidak merusak data dan '
        'percobaan berikutnya berhasil', () async {
      final file = databaseFile();

      final v4 = legacy4.LegacyV4Database(NativeDatabase(file));
      await _insertLegacyHarnessRecordV4(
        v4,
        id: 'legacy-v4-harness-2',
        label: 'Harus selamat lintas migrasi v5',
        amount: 1,
      );
      await v4.customStatement('PRAGMA user_version = 4');
      await v4.close();

      // Simulasi migrasi v4→v5 yang terhenti: tabel catatan berat mulai
      // dibuat di dalam transaksi, lalu prosesnya berhenti sebelum selesai.
      final interrupted = legacy4.LegacyV4Database(NativeDatabase(file));
      await expectLater(
        interrupted.transaction(() async {
          await interrupted.customStatement(
            'CREATE TABLE weight_records_wip (id TEXT NOT NULL)',
          );
          throw const _SimulatedInterruption();
        }),
        throwsA(isA<_SimulatedInterruption>()),
      );
      await interrupted.close();

      final retry = createTestDatabase(executor: NativeDatabase(file));
      addTearDown(retry.close);

      final check = await verifyMigration(
        retry,
        expectedSchemaVersion: kSchemaVersion,
      );
      expect(check.isHealthy, isTrue);

      final retryDao = HarnessRecordDao(
        retry,
        clock: createTestClock(),
        ids: createTestIds(),
      );
      final records = await retryDao.listActive();
      expect(records, hasLength(1));
      expect(records.single.label, 'Harus selamat lintas migrasi v5');

      final leftovers = await retry
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table' "
            "AND name = 'weight_records_wip'",
          )
          .get();
      expect(leftovers, isEmpty);
    });
  });

  group('fixture: migrasi versi 5 ke 6 (change 009)', () {
    test('basis data versi 5 berisi profil, makanan, catatan, dan berat '
        'bermigrasi ke versi 6 dengan sehat, tabel sifat produk kemasan '
        'baru dan kosong, dan data lama tidak tersentuh', () async {
      final file = databaseFile();

      final v5 = legacy5.LegacyV5Database(NativeDatabase(file));
      await _insertLegacyV5Profile(v5, id: 'profile-v5');
      final foodId = await _insertLegacyV5UserFood(
        v5,
        id: 'legacy-v5-food',
        profileId: 'profile-v5',
      );
      await _insertLegacyHarnessRecordV5(
        v5,
        id: 'legacy-v5-harness',
        label: 'Sebelum migrasi ke v6',
        amount: 4,
      );
      await v5.customStatement('PRAGMA user_version = 5');
      await v5.close();

      final upgraded = createTestDatabase(executor: NativeDatabase(file));
      addTearDown(upgraded.close);

      final check = await verifyMigration(
        upgraded,
        expectedSchemaVersion: kSchemaVersion,
      );
      expect(check.isHealthy, isTrue);

      final packagedRows = await upgraded
          .select(upgraded.packagedFoodProperties)
          .get();
      expect(
        packagedRows,
        isEmpty,
        reason: 'tabel sifat produk kemasan baru dan kosong pada migrasi',
      );

      final foods = await upgraded.select(upgraded.foods).get();
      expect(foods.map((f) => f.id), contains(foodId));

      final entries = await upgraded.select(upgraded.mealEntries).get();
      expect(entries, hasLength(1));
      final entryItems = await upgraded.select(upgraded.mealEntryItems).get();
      expect(entryItems, hasLength(1));
      expect(entryItems.single.foodId, foodId);

      final harnessDao = HarnessRecordDao(
        upgraded,
        clock: createTestClock(),
        ids: createTestIds(),
      );
      final records = await harnessDao.listActive();
      expect(records, hasLength(1));
      expect(records.single.label, 'Sebelum migrasi ke v6');

      final profiles = await upgraded.select(upgraded.profiles).get();
      expect(profiles, hasLength(1));
      expect(profiles.single.id, 'profile-v5');
    });

    test('migrasi versi 5 ke 6 yang terputus di tengah tidak merusak data '
        'dan percobaan berikutnya berhasil', () async {
      final file = databaseFile();

      final v5 = legacy5.LegacyV5Database(NativeDatabase(file));
      await _insertLegacyHarnessRecordV5(
        v5,
        id: 'legacy-v5-harness-2',
        label: 'Harus selamat lintas migrasi v6',
        amount: 1,
      );
      await v5.customStatement('PRAGMA user_version = 5');
      await v5.close();

      // Simulasi migrasi v5→v6 yang terhenti: tabel sifat produk kemasan
      // mulai dibuat di dalam transaksi, lalu prosesnya berhenti sebelum
      // selesai.
      final interrupted = legacy5.LegacyV5Database(NativeDatabase(file));
      await expectLater(
        interrupted.transaction(() async {
          await interrupted.customStatement(
            'CREATE TABLE packaged_food_properties_wip (id TEXT NOT NULL)',
          );
          throw const _SimulatedInterruption();
        }),
        throwsA(isA<_SimulatedInterruption>()),
      );
      await interrupted.close();

      final retry = createTestDatabase(executor: NativeDatabase(file));
      addTearDown(retry.close);

      final check = await verifyMigration(
        retry,
        expectedSchemaVersion: kSchemaVersion,
      );
      expect(check.isHealthy, isTrue);

      final retryDao = HarnessRecordDao(
        retry,
        clock: createTestClock(),
        ids: createTestIds(),
      );
      final records = await retryDao.listActive();
      expect(records, hasLength(1));
      expect(records.single.label, 'Harus selamat lintas migrasi v6');

      final leftovers = await retry
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table' "
            "AND name = 'packaged_food_properties_wip'",
          )
          .get();
      expect(leftovers, isEmpty);
    });
  });

  group('fixture: migrasi versi 6 ke 7 (change 010)', () {
    test('basis data versi 6 berisi produk kemasan sumber daring bermigrasi '
        'ke versi 7 dengan sehat, nilai lama tidak berubah, dan sourceType '
        'label_extraction baru dapat dipakai setelahnya', () async {
      final file = databaseFile();

      final v6 = legacy6.LegacyV6Database(NativeDatabase(file));
      final foodId = await _insertLegacyV6Food(v6, id: 'legacy-v6-food');
      await _insertLegacyV6PackagedFoodProperties(
        v6,
        id: 'legacy-v6-packaged',
        foodId: foodId,
        barcode: '8991234567890',
      );
      await _insertLegacyHarnessRecordV6(
        v6,
        id: 'legacy-v6-harness',
        label: 'Sebelum migrasi ke v7',
        amount: 4,
      );
      await v6.customStatement('PRAGMA user_version = 6');
      await v6.close();

      final upgraded = createTestDatabase(executor: NativeDatabase(file));
      addTearDown(upgraded.close);

      final check = await verifyMigration(
        upgraded,
        expectedSchemaVersion: kSchemaVersion,
      );
      expect(check.isHealthy, isTrue);
      expect(check.foreignKeyViolations, 0);

      final packagedRows = await upgraded
          .select(upgraded.packagedFoodProperties)
          .get();
      expect(packagedRows, hasLength(1));
      final preserved = packagedRows.single;
      expect(preserved.barcode, '8991234567890');
      expect(
        preserved.sourceType,
        'openfoodfacts',
        reason:
            'data versi 6 tidak tersentuh migrasi (design.md Migration '
            'Plan item 3)',
      );
      expect(
        preserved.sourceImagePath,
        isNull,
        reason: 'kolom baru, baris versi 6 tidak pernah mengisinya',
      );

      // CHECK constraint SHALL benar-benar melonggar, bukan hanya kolom
      // baru ditambahkan — dibuktikan dengan menyisipkan baris bernilai
      // sumber baru setelah migrasi.
      final secondFoodId = await _insertUpgradedFood(
        upgraded,
        id: 'post-migration-food',
      );
      await upgraded
          .into(upgraded.packagedFoodProperties)
          .insert(
            PackagedFoodPropertiesCompanion.insert(
              id: 'post-migration-packaged',
              createdAt: testInstant,
              updatedAt: testInstant,
              foodId: secondFoodId,
              barcode: const Value<String?>('8990000000001'),
              servingBasis: 'per_serving',
              sourceType: 'label_extraction',
              verifiedAt: testInstant,
              sourceImagePath: const Value<String?>(
                '/data/user/0/app/files/label-photos/x.jpg',
              ),
            ),
          );
      final afterInsert = await (upgraded.select(
        upgraded.packagedFoodProperties,
      )..where((t) => t.id.equals('post-migration-packaged'))).getSingle();
      expect(afterInsert.sourceType, 'label_extraction');
      expect(afterInsert.sourceImagePath, isNotNull);

      final harnessDao = HarnessRecordDao(
        upgraded,
        clock: createTestClock(),
        ids: createTestIds(),
      );
      final records = await harnessDao.listActive();
      expect(records, hasLength(1));
      expect(records.single.label, 'Sebelum migrasi ke v7');
    });

    test('migrasi versi 6 ke 7 yang terputus di tengah tidak merusak data '
        'dan percobaan berikutnya berhasil', () async {
      final file = databaseFile();

      final v6 = legacy6.LegacyV6Database(NativeDatabase(file));
      final foodId = await _insertLegacyV6Food(v6, id: 'legacy-v6-food-2');
      await _insertLegacyV6PackagedFoodProperties(
        v6,
        id: 'legacy-v6-packaged-2',
        foodId: foodId,
        barcode: '8991234567891',
      );
      await v6.customStatement('PRAGMA user_version = 6');
      await v6.close();

      // Simulasi migrasi v6→v7 yang terhenti: `TableMigration` pada Drift
      // bekerja lewat tabel sementara `_packaged_food_properties_new_X` —
      // simulasikan interupsi di tengah proses serupa itu.
      final interrupted = legacy6.LegacyV6Database(NativeDatabase(file));
      await expectLater(
        interrupted.transaction(() async {
          await interrupted.customStatement(
            'CREATE TABLE packaged_food_properties_migration_wip '
            '(id TEXT NOT NULL)',
          );
          throw const _SimulatedInterruption();
        }),
        throwsA(isA<_SimulatedInterruption>()),
      );
      await interrupted.close();

      final retry = createTestDatabase(executor: NativeDatabase(file));
      addTearDown(retry.close);

      final check = await verifyMigration(
        retry,
        expectedSchemaVersion: kSchemaVersion,
      );
      expect(check.isHealthy, isTrue);
      expect(check.foreignKeyViolations, 0);

      final packagedRows = await retry
          .select(retry.packagedFoodProperties)
          .get();
      expect(packagedRows, hasLength(1));
      expect(packagedRows.single.barcode, '8991234567891');

      final leftovers = await retry
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table' "
            "AND name = 'packaged_food_properties_migration_wip'",
          )
          .get();
      expect(leftovers, isEmpty);
    });
  });

  group('fixture: migrasi versi 7 ke 8 (change 010, barcode opsional)', () {
    test('basis data versi 7 berisi produk kemasan berbarcode bermigrasi ke '
        'versi 8 dengan sehat, barcode lama tetap ada, dan barcode kosong '
        'baru dapat dipakai setelahnya', () async {
      final file = databaseFile();

      final v7 = legacy7.LegacyV7Database(NativeDatabase(file));
      final foodId = await _insertLegacyV7Food(v7, id: 'legacy-v7-food');
      await _insertLegacyV7PackagedFoodProperties(
        v7,
        id: 'legacy-v7-packaged',
        foodId: foodId,
        barcode: '8991234567892',
      );
      await v7.customStatement('PRAGMA user_version = 7');
      await v7.close();

      final upgraded = createTestDatabase(executor: NativeDatabase(file));
      addTearDown(upgraded.close);

      final check = await verifyMigration(
        upgraded,
        expectedSchemaVersion: kSchemaVersion,
      );
      expect(check.isHealthy, isTrue);
      expect(check.foreignKeyViolations, 0);

      final preserved = await (upgraded.select(
        upgraded.packagedFoodProperties,
      )..where((t) => t.id.equals('legacy-v7-packaged'))).getSingle();
      expect(
        preserved.barcode,
        '8991234567892',
        reason: 'data versi 7 tidak tersentuh migrasi',
      );

      // NOT NULL SHALL benar-benar longgar — dibuktikan dengan menyisipkan
      // baris tanpa barcode sama sekali setelah migrasi (task yang
      // mendasari fitur "Foto Info Gizi tanpa pindai barcode").
      final secondFoodId = await _insertUpgradedFood(
        upgraded,
        id: 'post-migration-food-v8',
      );
      await upgraded
          .into(upgraded.packagedFoodProperties)
          .insert(
            PackagedFoodPropertiesCompanion.insert(
              id: 'post-migration-packaged-v8',
              createdAt: testInstant,
              updatedAt: testInstant,
              foodId: secondFoodId,
              servingBasis: 'per_serving',
              sourceType: 'label_extraction',
              verifiedAt: testInstant,
            ),
          );
      final withoutBarcode = await (upgraded.select(
        upgraded.packagedFoodProperties,
      )..where((t) => t.id.equals('post-migration-packaged-v8'))).getSingle();
      expect(withoutBarcode.barcode, isNull);

      // Dua baris tanpa barcode boleh bersisian — SQLite memperlakukan
      // setiap NULL sebagai berbeda pada indeks unik.
      final thirdFoodId = await _insertUpgradedFood(
        upgraded,
        id: 'post-migration-food-v8-b',
      );
      await upgraded
          .into(upgraded.packagedFoodProperties)
          .insert(
            PackagedFoodPropertiesCompanion.insert(
              id: 'post-migration-packaged-v8-b',
              createdAt: testInstant,
              updatedAt: testInstant,
              foodId: thirdFoodId,
              servingBasis: 'per_serving',
              sourceType: 'label_extraction',
              verifiedAt: testInstant,
            ),
          );
      final allRows = await upgraded
          .select(upgraded.packagedFoodProperties)
          .get();
      expect(
        allRows.where((r) => r.barcode == null),
        hasLength(2),
        reason: 'dua produk tanpa barcode tidak saling bentrok',
      );
    });

    test('migrasi versi 7 ke 8 yang terputus di tengah tidak merusak data '
        'dan percobaan berikutnya berhasil', () async {
      final file = databaseFile();

      final v7 = legacy7.LegacyV7Database(NativeDatabase(file));
      final foodId = await _insertLegacyV7Food(v7, id: 'legacy-v7-food-2');
      await _insertLegacyV7PackagedFoodProperties(
        v7,
        id: 'legacy-v7-packaged-2',
        foodId: foodId,
        barcode: '8991234567893',
      );
      await v7.customStatement('PRAGMA user_version = 7');
      await v7.close();

      final interrupted = legacy7.LegacyV7Database(NativeDatabase(file));
      await expectLater(
        interrupted.transaction(() async {
          await interrupted.customStatement(
            'CREATE TABLE packaged_food_properties_migration_wip_v8 '
            '(id TEXT NOT NULL)',
          );
          throw const _SimulatedInterruption();
        }),
        throwsA(isA<_SimulatedInterruption>()),
      );
      await interrupted.close();

      final retry = createTestDatabase(executor: NativeDatabase(file));
      addTearDown(retry.close);

      final check = await verifyMigration(
        retry,
        expectedSchemaVersion: kSchemaVersion,
      );
      expect(check.isHealthy, isTrue);
      expect(check.foreignKeyViolations, 0);

      final packagedRows = await retry
          .select(retry.packagedFoodProperties)
          .get();
      expect(packagedRows, hasLength(1));
      expect(packagedRows.single.barcode, '8991234567893');

      final leftovers = await retry
          .customSelect(
            "SELECT name FROM sqlite_master WHERE type = 'table' "
            "AND name = 'packaged_food_properties_migration_wip_v8'",
          )
          .get();
      expect(leftovers, isEmpty);
    });
  });

  group('kegagalan inisialisasi penyimpanan', () {
    test('dilaporkan sebagai kegagalan bertipe, bukan exception', () async {
      final result = await openLocalStorage(
        databaseFactory: () => throw const FileSystemException('disk penuh'),
      );

      expect(result, isA<Err<AppDatabase>>());
      expect(result.failureOrNull?.code, FailureCode.storageUnavailable);
    });

    test(
      'versi skema yang tidak sesuai dilaporkan sebagai kegagalan migrasi',
      () async {
        final result = await openLocalStorage(
          databaseFactory: () => _WrongVersionDatabase(
            NativeDatabase(databaseFile('wrong.sqlite')),
          ),
        );

        expect(result.failureOrNull?.code, FailureCode.storageMigrationFailed);
      },
    );
  });

  group('penurunan versi', () {
    test('tidak didukung dan ditolak dengan jelas', () async {
      final file = databaseFile('downgrade.sqlite');

      final future = createTestDatabase(executor: NativeDatabase(file));
      addTearDown(future.close);
      await future.customStatement('PRAGMA user_version = 99');
      await future.close();

      final reopened = createTestDatabase(executor: NativeDatabase(file));
      addTearDown(() async {
        try {
          await reopened.close();
        } on Object {
          // Basis data memang gagal dibuka pada uji ini.
        }
      });
      await expectLater(
        reopened.customSelect('SELECT 1').get(),
        throwsA(isA<StateError>()),
      );
    });
  });
}

class _SimulatedInterruption implements Exception {
  const _SimulatedInterruption();
}

/// Menyisipkan satu record harness langsung lewat tabel `LegacyV1Database`
/// — `HarnessRecordDao` terikat ke tipe `AppDatabase` dan tidak dapat
/// dipakai pada skema beku ini.
Future<void> _insertLegacyHarnessRecord(
  legacy.LegacyV1Database db, {
  required String id,
  required String label,
  required double amount,
}) {
  return db
      .into(db.harnessRecords)
      .insert(
        legacy.HarnessRecordsCompanion.insert(
          id: id,
          createdAt: testInstant,
          updatedAt: testInstant,
          label: label,
          amount: amount,
          localDate: '2026-11-08',
          timeZoneId: 'Asia/Jakarta',
        ),
      );
}

/// Menyisipkan satu baris harness langsung lewat `LegacyV2Database` —
/// `HarnessRecordDao` terikat ke tipe `AppDatabase`.
Future<void> _insertLegacyHarnessRecordV2(
  legacy2.LegacyV2Database db, {
  required String id,
  required String label,
  required double amount,
}) {
  return db
      .into(db.harnessRecords)
      .insert(
        legacy2.HarnessRecordsCompanion.insert(
          id: id,
          createdAt: testInstant,
          updatedAt: testInstant,
          label: label,
          amount: amount,
          localDate: '2026-11-08',
          timeZoneId: 'Asia/Jakarta',
        ),
      );
}

/// Menyisipkan satu baris harness langsung lewat `LegacyV3Database`.
Future<void> _insertLegacyHarnessRecordV3(
  legacy3.LegacyV3Database db, {
  required String id,
  required String label,
  required double amount,
}) {
  return db
      .into(db.harnessRecords)
      .insert(
        legacy3.HarnessRecordsCompanion.insert(
          id: id,
          createdAt: testInstant,
          updatedAt: testInstant,
          label: label,
          amount: amount,
          localDate: '2026-11-08',
          timeZoneId: 'Asia/Jakarta',
        ),
      );
}

/// Menyisipkan satu profil langsung lewat `LegacyV3Database` (task 2.10 —
/// migrasi versi 3 ke 4 SHALL mempertahankan seluruh data versi 3).
Future<void> _insertLegacyV3Profile(
  legacy3.LegacyV3Database db, {
  required String id,
}) {
  return db
      .into(db.profiles)
      .insert(
        legacy3.ProfilesCompanion.insert(
          id: id,
          createdAt: testInstant,
          updatedAt: testInstant,
          onboardingComplete: const Value<bool>(true),
        ),
      );
}

/// Menyisipkan satu baris katalog, satu `user_programs`, satu
/// `program_events`, dan satu `program_progress` pada basis data v2 beku —
/// `profileId` sengaja tidak menunjuk ke profil mana pun, karena tabel
/// `profiles` belum ada pada versi 2 (fixture task 2.6/2.7).
Future<void> _insertLegacyV2ProgramRow(
  legacy2.LegacyV2Database db, {
  required String profileId,
}) async {
  const programId = 'program-weight-loss';
  await db
      .into(db.programs)
      .insertOnConflictUpdate(
        legacy2.ProgramsCompanion.insert(
          id: programId,
          code: 'weight_loss',
          name: 'Turun Berat',
          description: 'Program turun berat.',
          requiresWeightTarget: true,
          sortOrder: 0,
          definitionVersion: 1,
          createdAt: testInstant,
          updatedAt: testInstant,
        ),
      );

  const userProgramId = 'legacy-v2-user-program';
  await db
      .into(db.userProgramsV2)
      .insert(
        legacy2.UserProgramsV2Companion.insert(
          id: userProgramId,
          createdAt: testInstant,
          updatedAt: testInstant,
          profileId: profileId,
          programId: programId,
          status: 'active',
          startedAt: Value<DateTime?>(testInstant),
          inputSnapshotJson: '{}',
          calculatorVersion: 'msj-1.0.0',
          policyVersion: 'np-1.0.0',
        ),
      );

  await db
      .into(db.programEventsV2)
      .insert(
        legacy2.ProgramEventsV2Companion.insert(
          id: 'legacy-v2-event',
          createdAt: testInstant,
          userProgramId: userProgramId,
          eventType: 'activated',
          occurredAt: testInstant,
          toStatus: const Value<String?>('active'),
        ),
      );

  await db
      .into(db.programProgressV2)
      .insert(
        legacy2.ProgramProgressV2Companion.insert(
          id: 'legacy-v2-progress',
          createdAt: testInstant,
          updatedAt: testInstant,
          userProgramId: userProgramId,
          recordedLocalDate: '2026-11-08',
          recordedAt: testInstant,
          activeDayNumber: 1,
          calculationVersion: 'msj-1.0.0',
        ),
      );
}

/// Menyisipkan satu baris harness langsung lewat `LegacyV4Database`.
Future<void> _insertLegacyHarnessRecordV4(
  legacy4.LegacyV4Database db, {
  required String id,
  required String label,
  required double amount,
}) {
  return db
      .into(db.harnessRecords)
      .insert(
        legacy4.HarnessRecordsCompanion.insert(
          id: id,
          createdAt: testInstant,
          updatedAt: testInstant,
          label: label,
          amount: amount,
          localDate: '2026-11-08',
          timeZoneId: 'Asia/Jakarta',
        ),
      );
}

/// Menyisipkan satu profil langsung lewat `LegacyV4Database` (task 1.6 —
/// migrasi versi 4 ke 5 SHALL mempertahankan seluruh data versi 4).
Future<void> _insertLegacyV4Profile(
  legacy4.LegacyV4Database db, {
  required String id,
}) {
  return db
      .into(db.profiles)
      .insert(
        legacy4.ProfilesCompanion.insert(
          id: id,
          createdAt: testInstant,
          updatedAt: testInstant,
          onboardingComplete: const Value<bool>(true),
        ),
      );
}

/// Menyisipkan satu baris harness langsung lewat `LegacyV5Database`.
Future<void> _insertLegacyHarnessRecordV5(
  legacy5.LegacyV5Database db, {
  required String id,
  required String label,
  required double amount,
}) {
  return db
      .into(db.harnessRecords)
      .insert(
        legacy5.HarnessRecordsCompanion.insert(
          id: id,
          createdAt: testInstant,
          updatedAt: testInstant,
          label: label,
          amount: amount,
          localDate: '2026-11-08',
          timeZoneId: 'Asia/Jakarta',
        ),
      );
}

/// Menyisipkan satu profil langsung lewat `LegacyV5Database` (task 2.6 —
/// migrasi versi 5 ke 6 SHALL mempertahankan seluruh data versi 5).
Future<void> _insertLegacyV5Profile(
  legacy5.LegacyV5Database db, {
  required String id,
}) {
  return db
      .into(db.profiles)
      .insert(
        legacy5.ProfilesCompanion.insert(
          id: id,
          createdAt: testInstant,
          updatedAt: testInstant,
          onboardingComplete: const Value<bool>(true),
        ),
      );
}

/// Menyisipkan satu makanan buatan pengguna lengkap dengan takaran, nilai
/// gizi, dan satu catatan buku harian langsung lewat `LegacyV5Database` —
/// fixture migrasi versi 5 ke 6 (task 2.5/2.6, change 009). Mengembalikan
/// `foodId` untuk diperiksa setelah migrasi.
Future<String> _insertLegacyV5UserFood(
  legacy5.LegacyV5Database db, {
  required String id,
  required String profileId,
}) async {
  const servingId = 'legacy-v5-serving';
  await db
      .into(db.foods)
      .insert(
        legacy5.FoodsCompanion.insert(
          id: id,
          createdAt: testInstant,
          updatedAt: testInstant,
          name: 'Makanan sebelum migrasi v6',
          category: 'other',
          isUserCreated: const Value<bool>(true),
        ),
      );
  await db
      .into(db.foodServings)
      .insert(
        legacy5.FoodServingsCompanion.insert(
          id: servingId,
          createdAt: testInstant,
          updatedAt: testInstant,
          foodId: id,
          label: '1 porsi',
          amount: 1,
          unit: 'porsi',
          isDefault: const Value<bool>(true),
        ),
      );
  await db
      .into(db.nutritionValues)
      .insert(
        legacy5.NutritionValuesCompanion.insert(
          id: 'legacy-v5-nutrition',
          createdAt: testInstant,
          updatedAt: testInstant,
          servingId: servingId,
          energyKcal: const Value<double?>(120),
        ),
      );
  const entryId = 'legacy-v5-entry';
  await db
      .into(db.mealEntries)
      .insert(
        legacy5.MealEntriesCompanion.insert(
          id: entryId,
          createdAt: testInstant,
          updatedAt: testInstant,
          profileId: profileId,
          localDate: '2026-11-08',
          mealTime: 'breakfast',
        ),
      );
  await db
      .into(db.mealEntryItems)
      .insert(
        legacy5.MealEntryItemsCompanion.insert(
          id: 'legacy-v5-entry-item',
          createdAt: testInstant,
          updatedAt: testInstant,
          mealEntryId: entryId,
          foodId: id,
          servingId: servingId,
          quantity: 1,
          foodNameSnapshot: 'Makanan sebelum migrasi v6',
          servingLabelSnapshot: '1 porsi',
          energyKcalSnapshot: const Value<double?>(120),
        ),
      );
  return id;
}

/// Menyisipkan satu baris harness langsung lewat `LegacyV6Database`.
Future<void> _insertLegacyHarnessRecordV6(
  legacy6.LegacyV6Database db, {
  required String id,
  required String label,
  required double amount,
}) {
  return db
      .into(db.harnessRecords)
      .insert(
        legacy6.HarnessRecordsCompanion.insert(
          id: id,
          createdAt: testInstant,
          updatedAt: testInstant,
          label: label,
          amount: amount,
          localDate: '2026-11-08',
          timeZoneId: 'Asia/Jakarta',
        ),
      );
}

/// Menyisipkan satu makanan minimal langsung lewat `LegacyV6Database` —
/// hanya untuk memenuhi foreign key `packaged_food_properties.food_id`
/// (fixture migrasi versi 6 ke 7, task 5.4); rantai takaran/nilai gizi
/// lengkap sudah diuji oleh fixture versi 5 ke 6. Mengembalikan `foodId`.
Future<String> _insertLegacyV6Food(
  legacy6.LegacyV6Database db, {
  required String id,
}) async {
  await db
      .into(db.foods)
      .insert(
        legacy6.FoodsCompanion.insert(
          id: id,
          createdAt: testInstant,
          updatedAt: testInstant,
          name: 'Produk sebelum migrasi ke v7',
          category: 'other',
          isUserCreated: const Value<bool>(true),
        ),
      );
  return id;
}

/// Menyisipkan satu baris `packaged_food_properties` BENTUK VERSI 6 (tanpa
/// `source_image_path`, `source_type` terbatas pada `openfoodfacts`/
/// `user_manual`) langsung lewat `LegacyV6Database` — fixture migrasi versi
/// 6 ke 7 (task 5.4, change 010).
Future<void> _insertLegacyV6PackagedFoodProperties(
  legacy6.LegacyV6Database db, {
  required String id,
  required String foodId,
  required String barcode,
}) {
  return db
      .into(db.packagedFoodPropertiesV6)
      .insert(
        legacy6.PackagedFoodPropertiesV6Companion.insert(
          id: id,
          createdAt: testInstant,
          updatedAt: testInstant,
          foodId: foodId,
          barcode: barcode,
          servingBasis: 'per_serving',
          sourceType: 'openfoodfacts',
          verifiedAt: testInstant,
        ),
      );
}

/// Menyisipkan satu makanan minimal langsung lewat `LegacyV7Database` —
/// fixture migrasi versi 7 ke 8 (change 010, barcode opsional).
Future<String> _insertLegacyV7Food(
  legacy7.LegacyV7Database db, {
  required String id,
}) async {
  await db
      .into(db.foods)
      .insert(
        legacy7.FoodsCompanion.insert(
          id: id,
          createdAt: testInstant,
          updatedAt: testInstant,
          name: 'Produk sebelum migrasi ke v8',
          category: 'other',
          isUserCreated: const Value<bool>(true),
        ),
      );
  return id;
}

/// Menyisipkan satu baris `packaged_food_properties` BENTUK VERSI 7
/// (barcode MASIH wajib) langsung lewat `LegacyV7Database` — fixture
/// migrasi versi 7 ke 8 (change 010, barcode opsional).
Future<void> _insertLegacyV7PackagedFoodProperties(
  legacy7.LegacyV7Database db, {
  required String id,
  required String foodId,
  required String barcode,
}) {
  return db
      .into(db.packagedFoodPropertiesV7)
      .insert(
        legacy7.PackagedFoodPropertiesV7Companion.insert(
          id: id,
          createdAt: testInstant,
          updatedAt: testInstant,
          foodId: foodId,
          barcode: barcode,
          servingBasis: 'per_serving',
          sourceType: 'label_extraction',
          verifiedAt: testInstant,
        ),
      );
}

/// Menyisipkan satu makanan minimal langsung lewat `AppDatabase` terkini —
/// dipakai fixture migrasi versi 6 ke 7 untuk membuktikan CHECK
/// `source_type` benar-benar melonggar setelah migrasi (bukan hanya kolom
/// baru ditambahkan), dengan baris baru yang foreign key-nya sah.
Future<String> _insertUpgradedFood(AppDatabase db, {required String id}) async {
  await db
      .into(db.foods)
      .insert(
        FoodsCompanion.insert(
          id: id,
          createdAt: testInstant,
          updatedAt: testInstant,
          name: 'Produk hasil ekstraksi label',
          category: 'other',
          isUserCreated: const Value<bool>(true),
        ),
      );
  return id;
}

/// Basis data dengan versi skema yang sengaja berbeda, untuk menguji
/// pemeriksaan pasca-migrasi.
class _WrongVersionDatabase extends AppDatabase {
  _WrongVersionDatabase(super.executor);

  @override
  int get schemaVersion => kSchemaVersion + 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await customStatement('PRAGMA user_version = $kSchemaVersion');
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
