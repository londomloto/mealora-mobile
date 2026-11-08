import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/core/errors/failure.dart';
import 'package:mealora/core/errors/result.dart';
import 'package:mealora/data/local/harness_record_dao.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/database/migrations/migration_verification.dart';
import 'package:mealora/database/migrations/program_catalog_verification.dart';
import 'package:mealora/database/storage_bootstrap.dart';

import 'legacy_v1_database.dart' as legacy;
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
