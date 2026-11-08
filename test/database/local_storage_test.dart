import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/core/errors/failure.dart';
import 'package:mealora/core/errors/result.dart';
import 'package:mealora/data/local/harness_record_dao.dart';
import 'package:mealora/data/local/ui_preference_dao.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/database/migrations/migration_verification.dart';
import 'package:mealora/database/tables/user_record_columns.dart';

import 'test_database.dart';

void main() {
  late AppDatabase db;
  late HarnessRecordDao dao;

  setUp(() {
    db = createTestDatabase();
    dao = HarnessRecordDao(db, clock: createTestClock(), ids: createTestIds());
  });

  tearDown(() => db.close());

  group('konvensi record milik pengguna', () {
    test('record baru memakai pengenal aplikasi, bukan nomor urut', () async {
      final created = await dao.create(label: 'Harness', amount: 1.5);

      expect(created.isOk, isTrue);
      expect(created.valueOrNull, 'test-0001');
      expect(int.tryParse(created.valueOrNull!), isNull);
    });

    test('record baru berstatus lokal dengan revisi awal', () async {
      await dao.create(label: 'Harness', amount: 1.5);

      final record = (await dao.listActive()).single;
      expect(record.syncStatus, kSyncStatusLocal);
      expect(record.revision, 1);
      expect(record.deletedAt, isNull);
    });

    test('pembaruan menaikkan revisi dan waktu pembaruan, '
        'tanpa mengubah waktu pembuatan maupun pengenal', () async {
      final id = (await dao.create(label: 'Harness', amount: 1.5)).valueOrNull!;
      final before = (await dao.listActive()).single;

      final result = await dao.updateLabel(id, 'Harness diperbarui');
      expect(result.isOk, isTrue);

      final after = (await dao.listActive()).single;
      expect(after.id, before.id);
      expect(after.createdAt, before.createdAt);
      expect(after.revision, before.revision + 1);
      expect(after.label, 'Harness diperbarui');
    });

    test('penghapusan lunak menyembunyikan record dari pembacaan biasa '
        'tetapi barisnya tetap ada', () async {
      final id = (await dao.create(label: 'Harness', amount: 1.5)).valueOrNull!;

      expect(await dao.softDelete(id), isA<Ok<void>>());

      expect(await dao.listActive(), isEmpty);
      expect(await dao.findActive(id), isNull);

      final deleted = await dao.listDeleted();
      expect(deleted, hasLength(1));
      expect(deleted.single.deletedAt, isNotNull);
    });

    test('record terhapus tidak ikut dalam perhitungan', () async {
      final keep = await dao.create(
        label: 'Tetap',
        amount: 1,
        nutrientValue: 10,
      );
      final drop = await dao.create(
        label: 'Dihapus',
        amount: 1,
        nutrientValue: 90,
      );
      expect(keep.isOk, isTrue);

      await dao.softDelete(drop.valueOrNull!);

      expect(await dao.knownNutrientTotal(), 10);
    });

    test('tanggal lokal dan zona waktu dicatat saat penulisan', () async {
      await dao.create(label: 'Harness', amount: 1);

      final record = (await dao.listActive()).single;
      // 2026-11-08T02:30Z di Asia/Jakarta adalah 09:30 tanggal 8 November.
      expect(record.localDate, '2026-11-08');
      expect(record.timeZoneId, 'Asia/Jakarta');
    });
  });

  group('integritas nilai', () {
    test('nilai gizi negatif ditolak dan tidak ada data tersimpan', () async {
      final result = await dao.create(
        label: 'Harness',
        amount: 1,
        nutrientValue: -1,
      );

      expect(result, isA<Err<String>>());
      expect(result.failureOrNull?.code, FailureCode.valueOutOfRange);
      expect(await dao.listActive(), isEmpty);
    });

    test('jumlah nol atau negatif ditolak', () async {
      expect(
        (await dao.create(label: 'Harness', amount: 0)).failureOrNull?.code,
        FailureCode.valueOutOfRange,
      );
      expect(
        (await dao.create(label: 'Harness', amount: -2)).failureOrNull?.code,
        FailureCode.valueOutOfRange,
      );
      expect(await dao.listActive(), isEmpty);
    });

    test('nilai bukan angka ditolak', () async {
      final result = await dao.create(label: 'Harness', amount: double.nan);

      expect(result.failureOrNull?.code, FailureCode.invalidValue);
      expect(await dao.listActive(), isEmpty);
    });

    test('nilai belum diketahui disimpan sebagai tidak diketahui, '
        'bukan nol', () async {
      await dao.create(label: 'Tidak diketahui', amount: 1);
      await dao.create(label: 'Nol terukur', amount: 1, nutrientValue: 0);

      final records = await dao.listActive();
      expect(records.map((r) => r.nutrientValue), <double?>[null, 0]);
      expect(await dao.knownNutrientTotal(), 0);
    });

    test(
      'batasan nilai juga ditegakkan basis data, bukan hanya kode',
      () async {
        await expectLater(
          db
              .into(db.harnessRecords)
              .insert(
                HarnessRecordsCompanion.insert(
                  id: 'manual-1',
                  createdAt: testInstant,
                  updatedAt: testInstant,
                  label: 'Lewat jalur belakang',
                  amount: -5,
                  localDate: '2026-11-08',
                  timeZoneId: 'Asia/Jakarta',
                ),
              ),
          throwsA(isA<Exception>()),
        );
      },
    );
  });

  group('keutuhan penulisan', () {
    test(
      'kegagalan di tengah penulisan ganda tidak menyisakan apa pun',
      () async {
        final result = await dao.create(
          label: 'Harness',
          amount: 1,
          notes: <String>['catatan sah', '   '],
        );

        expect(result.isErr, isTrue);
        expect(await dao.listActive(), isEmpty);
        expect(await db.select(db.harnessRecordNotes).get(), isEmpty);
      },
    );

    test('penulisan ganda yang berhasil menyimpan seluruhnya', () async {
      final result = await dao.create(
        label: 'Harness',
        amount: 1,
        notes: <String>['satu', 'dua'],
      );

      expect(result.isOk, isTrue);
      expect(await dao.listActive(), hasLength(1));
      expect(await db.select(db.harnessRecordNotes).get(), hasLength(2));
    });

    test('kunci asing aktif: catatan yatim ditolak', () async {
      await expectLater(
        db
            .into(db.harnessRecordNotes)
            .insert(
              HarnessRecordNotesCompanion.insert(
                id: 'note-yatim',
                createdAt: testInstant,
                updatedAt: testInstant,
                recordId: 'tidak-ada',
                note: 'menunjuk ke record yang tidak ada',
              ),
            ),
        throwsA(isA<Exception>()),
      );
    });

    test('pragma kunci asing menyala pada koneksi yang dibuka', () async {
      final check = await verifyMigration(db, expectedSchemaVersion: 1);

      expect(check.foreignKeysEnabled, isTrue);
      expect(check.foreignKeyViolations, 0);
      expect(check.schemaVersion, kSchemaVersion);
      expect(check.isHealthy, isTrue);
    });
  });

  group('ketahanan data', () {
    test('data bertahan ketika basis data dibuka ulang', () async {
      final file = await _temporaryDatabaseFile();
      addTearDown(() async {
        if (file.existsSync()) {
          file.deleteSync();
        }
      });

      final first = createTestDatabase(executor: NativeDatabase(file));
      final firstDao = HarnessRecordDao(
        first,
        clock: createTestClock(),
        ids: createTestIds(),
      );
      await firstDao.create(label: 'Bertahan', amount: 2);
      await first.close();

      final second = createTestDatabase(executor: NativeDatabase(file));
      final secondDao = HarnessRecordDao(
        second,
        clock: createTestClock(),
        ids: createTestIds(),
      );
      final records = await secondDao.listActive();
      await second.close();

      expect(records, hasLength(1));
      expect(records.single.label, 'Bertahan');
    });
  });

  group('preferensi antarmuka', () {
    test('ruang terpilih tersimpan dan terbaca kembali', () async {
      final prefs = UiPreferenceDao(db, clock: createTestClock());

      expect(await prefs.read(UiPreferenceKeys.selectedDestination), isNull);

      await prefs.write(UiPreferenceKeys.selectedDestination, 'history');
      expect(await prefs.read(UiPreferenceKeys.selectedDestination), 'history');

      await prefs.write(UiPreferenceKeys.selectedDestination, 'profile');
      expect(await prefs.read(UiPreferenceKeys.selectedDestination), 'profile');
    });
  });
}

Future<File> _temporaryDatabaseFile() async {
  final directory = Directory.systemTemp.createTempSync('mealora_db_test');
  return File('${directory.path}/mealora.sqlite');
}
