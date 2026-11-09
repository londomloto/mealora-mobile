import 'package:drift/drift.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/database/seeds/program_catalog_seed.dart';
import 'package:mealora/domain/program/program_code.dart';

import 'test_database.dart';

/// Penegakan "satu program berjalan per profil" di tingkat basis data
/// (Design D3, tasks 2.3/2.4/2.6/2.7) — diuji dengan penulisan langsung ke
/// tabel, melewati domain sepenuhnya.
void main() {
  late AppDatabase db;

  setUp(() async {
    db = createTestDatabase();
    // Foreign key sungguhan ke `profiles` (Design D8, change 005): setiap
    // `profileId` dipakai di baris uji ini harus menunjuk ke profil yang
    // benar-benar ada.
    for (final id in <String>['profile-1', 'profile-2']) {
      await db
          .into(db.profiles)
          .insert(
            ProfilesCompanion.insert(
              id: id,
              createdAt: testInstant,
              updatedAt: testInstant,
            ),
          );
    }
  });
  tearDown(() => db.close());

  UserProgramsCompanion row({
    required String id,
    required String profileId,
    required String status,
  }) => UserProgramsCompanion.insert(
    id: id,
    createdAt: testInstant,
    updatedAt: testInstant,
    profileId: profileId,
    programId: kProgramCatalogIds[ProgramCode.weightLoss]!,
    status: status,
    inputSnapshotJson: '{}',
    calculatorVersion: 'v1',
    policyVersion: 'v1',
  );

  test(
    'indeks unik parsial menolak dua baris active hidup untuk satu profil',
    () async {
      await db
          .into(db.userPrograms)
          .insert(row(id: 'up-1', profileId: 'profile-1', status: 'active'));

      await expectLater(
        db
            .into(db.userPrograms)
            .insert(row(id: 'up-2', profileId: 'profile-1', status: 'active')),
        throwsA(isA<Exception>()),
      );
    },
  );

  test(
    'indeks unik parsial menolak dua baris paused hidup untuk satu profil',
    () async {
      await db
          .into(db.userPrograms)
          .insert(row(id: 'up-1', profileId: 'profile-1', status: 'paused'));

      await expectLater(
        db
            .into(db.userPrograms)
            .insert(row(id: 'up-2', profileId: 'profile-1', status: 'paused')),
        throwsA(isA<Exception>()),
      );
    },
  );

  test('trigger menolak satu profil punya baris active DAN paused sekaligus '
      '(celah yang tidak tertangkap kedua indeks parsial) — INSERT', () async {
    await db
        .into(db.userPrograms)
        .insert(row(id: 'up-1', profileId: 'profile-1', status: 'active'));

    await expectLater(
      db
          .into(db.userPrograms)
          .insert(row(id: 'up-2', profileId: 'profile-1', status: 'paused')),
      throwsA(isA<Exception>()),
    );
  });

  test('trigger menolak perpindahan UPDATE yang menghasilkan dua program '
      'berjalan sekaligus', () async {
    await db
        .into(db.userPrograms)
        .insert(row(id: 'up-1', profileId: 'profile-1', status: 'active'));
    await db
        .into(db.userPrograms)
        .insert(row(id: 'up-2', profileId: 'profile-1', status: 'draft'));

    await expectLater(
      (db.update(db.userPrograms)..where((t) => t.id.equals('up-2'))).write(
        const UserProgramsCompanion(status: Value<String>('paused')),
      ),
      throwsA(isA<Exception>()),
    );
  });

  test('draf dan riwayat (status akhir) tidak melanggar invarian', () async {
    await db
        .into(db.userPrograms)
        .insert(row(id: 'up-1', profileId: 'profile-1', status: 'active'));
    await db
        .into(db.userPrograms)
        .insert(row(id: 'up-2', profileId: 'profile-1', status: 'draft'));
    await db
        .into(db.userPrograms)
        .insert(row(id: 'up-3', profileId: 'profile-1', status: 'completed'));
    await db
        .into(db.userPrograms)
        .insert(row(id: 'up-4', profileId: 'profile-1', status: 'changed'));
    await db
        .into(db.userPrograms)
        .insert(row(id: 'up-5', profileId: 'profile-1', status: 'cancelled'));

    final rows = await db.select(db.userPrograms).get();
    expect(rows, hasLength(5));
  });

  test(
    'profil berbeda masing-masing boleh punya satu program aktif sendiri',
    () async {
      await db
          .into(db.userPrograms)
          .insert(row(id: 'up-1', profileId: 'profile-1', status: 'active'));
      await db
          .into(db.userPrograms)
          .insert(row(id: 'up-2', profileId: 'profile-2', status: 'active'));

      final rows = await db.select(db.userPrograms).get();
      expect(rows, hasLength(2));
    },
  );

  test('indeks unik hidup potret kemajuan menolak dua baris untuk tanggal '
      'yang sama', () async {
    await db
        .into(db.userPrograms)
        .insert(row(id: 'up-1', profileId: 'profile-1', status: 'active'));

    ProgramProgressCompanion progress(String id) =>
        ProgramProgressCompanion.insert(
          id: id,
          createdAt: testInstant,
          updatedAt: testInstant,
          userProgramId: 'up-1',
          recordedLocalDate: '2026-11-08',
          recordedAt: testInstant,
          activeDayNumber: 1,
          calculationVersion: 'v1',
        );

    await db.into(db.programProgress).insert(progress('pp-1'));

    await expectLater(
      db.into(db.programProgress).insert(progress('pp-2')),
      throwsA(isA<Exception>()),
    );
  });

  group('keadaan akhir tidak dapat berpindah lagi (task 5.4)', () {
    for (final terminal in <String>['completed', 'changed', 'cancelled']) {
      test(
        'basis data menolak perpindahan keluar dari $terminal, bukan hanya domain',
        () async {
          await db
              .into(db.userPrograms)
              .insert(
                row(id: 'up-1', profileId: 'profile-1', status: terminal),
              );

          await expectLater(
            (db.update(db.userPrograms)..where((t) => t.id.equals('up-1')))
                .write(const UserProgramsCompanion(status: Value('draft'))),
            throwsA(isA<Exception>()),
          );
        },
      );
    }

    test(
      'memperbarui kolom lain pada baris keadaan akhir tanpa mengubah status tetap diizinkan',
      () async {
        await db
            .into(db.userPrograms)
            .insert(
              row(id: 'up-1', profileId: 'profile-1', status: 'completed'),
            );

        await (db.update(db.userPrograms)..where((t) => t.id.equals('up-1')))
            .write(const UserProgramsCompanion(completionReason: Value('x')));

        final reloaded = await (db.select(
          db.userPrograms,
        )..where((t) => t.id.equals('up-1'))).getSingle();
        expect(reloaded.completionReason, 'x');
      },
    );
  });
}
