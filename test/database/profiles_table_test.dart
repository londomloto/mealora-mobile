import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/database/app_database.dart';

import 'test_database.dart';

/// Tabel profil (assessment §11, Design D8, change 005): kolom milik
/// pengguna, batas nilai `biological_input`/`activity_level`, dan foreign
/// key sungguhan dari `user_programs.profile_id`.
void main() {
  late AppDatabase db;

  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  ProfilesCompanion profile({
    required String id,
    String? biologicalInput,
    String? activityLevel,
  }) => ProfilesCompanion.insert(
    id: id,
    createdAt: testInstant,
    updatedAt: testInstant,
    biologicalInput: Value<String?>(biologicalInput),
    activityLevel: Value<String?>(activityLevel),
  );

  test('profiles memuat seluruh kolom UserRecordColumns', () async {
    final rows = await db.customSelect('PRAGMA table_info(profiles)').get();
    final columns = rows.map((r) => r.data['name'] as String).toSet();
    expect(
      columns,
      containsAll(<String>[
        'id',
        'created_at',
        'updated_at',
        'deleted_at',
        'sync_status',
        'revision',
      ]),
    );
  });

  test(
    'seluruh bidang domain boleh kosong kecuali onboarding_complete',
    () async {
      await db.into(db.profiles).insert(profile(id: 'p-1'));
      final row = await (db.select(
        db.profiles,
      )..where((t) => t.id.equals('p-1'))).getSingle();

      expect(row.nickname, isNull);
      expect(row.birthDate, isNull);
      expect(row.heightCm, isNull);
      expect(row.currentWeightKg, isNull);
      expect(row.biologicalInput, isNull);
      expect(row.activityLevel, isNull);
      expect(row.onboardingComplete, isFalse);
    },
  );

  test('biological_input menolak nilai di luar enum domain', () async {
    await expectLater(
      db
          .into(db.profiles)
          .insert(profile(id: 'p-2', biologicalInput: 'not_a_value')),
      throwsA(isA<Exception>()),
    );
  });

  test('activity_level menolak nilai di luar enum domain', () async {
    await expectLater(
      db
          .into(db.profiles)
          .insert(profile(id: 'p-3', activityLevel: 'not_a_value')),
      throwsA(isA<Exception>()),
    );
  });

  test(
    'biological_input dan activity_level menerima seluruh nilai domain',
    () async {
      await db
          .into(db.profiles)
          .insert(
            profile(
              id: 'p-4',
              biologicalInput: 'male',
              activityLevel: 'sedentary',
            ),
          );
      await db
          .into(db.profiles)
          .insert(
            profile(
              id: 'p-5',
              biologicalInput: 'female',
              activityLevel: 'moderatelyActive',
            ),
          );

      final rows = await db.select(db.profiles).get();
      expect(rows, hasLength(2));
    },
  );

  test('user_programs.profile_id adalah foreign key sungguhan — baris tanpa '
      'profil ditolak', () async {
    await expectLater(
      db
          .into(db.userPrograms)
          .insert(
            UserProgramsCompanion.insert(
              id: 'up-orphan',
              createdAt: testInstant,
              updatedAt: testInstant,
              profileId: 'tidak-ada',
              programId: 'program-weight-loss',
              status: 'draft',
              inputSnapshotJson: '{}',
              calculatorVersion: 'v1',
              policyVersion: 'v1',
            ),
          ),
      throwsA(isA<Exception>()),
    );
  });

  test(
    'menghapus profil yang masih dirujuk user_programs ditolak (onDelete: restrict)',
    () async {
      await db.into(db.profiles).insert(profile(id: 'p-6'));
      await db
          .into(db.userPrograms)
          .insert(
            UserProgramsCompanion.insert(
              id: 'up-1',
              createdAt: testInstant,
              updatedAt: testInstant,
              profileId: 'p-6',
              programId: 'program-weight-loss',
              status: 'draft',
              inputSnapshotJson: '{}',
              calculatorVersion: 'v1',
              policyVersion: 'v1',
            ),
          );

      await expectLater(
        (db.delete(db.profiles)..where((t) => t.id.equals('p-6'))).go(),
        throwsA(isA<Exception>()),
      );
    },
  );
}
