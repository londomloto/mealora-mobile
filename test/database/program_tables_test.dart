import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/database/app_database.dart';

import 'test_database.dart';

/// Konvensi metadata record milik pengguna (task 1.7, change 004).
///
/// `user_programs` dan `program_progress` memakai `UserRecordColumns`
/// penuh; `program_events` memakai `AppendOnlyRecordColumns` (tanpa
/// `updated_at`/`deleted_at`) karena bersifat tambah-saja (Design, change
/// 004, komentar `program_events_table.dart`).
void main() {
  late AppDatabase db;

  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  Future<Set<String>> columnsOf(String table) async {
    final rows = await db.customSelect('PRAGMA table_info($table)').get();
    return rows.map((r) => r.data['name'] as String).toSet();
  }

  group('tabel milik pengguna memakai mixin metadata siap-sinkron', () {
    test('user_programs memuat seluruh kolom UserRecordColumns', () async {
      final columns = await columnsOf('user_programs');
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

    test('program_progress memuat seluruh kolom UserRecordColumns', () async {
      final columns = await columnsOf('program_progress');
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
      'program_events bersifat tambah-saja: tanpa updated_at/deleted_at',
      () async {
        final columns = await columnsOf('program_events');
        expect(
          columns,
          containsAll(<String>['id', 'created_at', 'sync_status', 'revision']),
        );
        expect(columns, isNot(contains('updated_at')));
        expect(columns, isNot(contains('deleted_at')));
      },
    );
  });

  group('tabel katalog bukan tabel milik pengguna', () {
    test('programs tidak memakai kolom milik pengguna', () async {
      final columns = await columnsOf('programs');
      expect(columns, isNot(contains('deleted_at')));
      expect(columns, isNot(contains('sync_status')));
      expect(columns, isNot(contains('revision')));
    });
  });

  group('potret kemajuan: belum diketahui berbeda dari nol', () {
    test(
      'seluruh kolom nilai bersifat nullable, kolom pencacah tidak',
      () async {
        final rows = await db
            .customSelect('PRAGMA table_info(program_progress)')
            .get();
        final nullable = <String>{
          'weight_kg',
          'weight_change_kg',
          'target_progress_ratio',
          'consumed_energy_kcal',
          'energy_adherence_ratio',
          'protein_g',
          'carbohydrate_g',
          'fat_g',
        };
        final notNullable = <String>{'logged_meals_count', 'active_day_number'};

        for (final row in rows) {
          final name = row.data['name'] as String;
          final notNull = (row.data['notnull'] as int) == 1;
          if (nullable.contains(name)) {
            expect(notNull, isFalse, reason: '$name harus nullable');
          }
          if (notNullable.contains(name)) {
            expect(notNull, isTrue, reason: '$name harus NOT NULL');
          }
        }
      },
    );
  });
}
