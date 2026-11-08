import 'package:drift/drift.dart';
import 'package:mealora/database/tables/harness_records.dart';
import 'package:mealora/database/tables/ui_preferences.dart';

part 'legacy_v1_database.g.dart';

/// Skema versi 1 dibekukan — persis seperti sebelum change 004 menambah
/// tabel program (hanya `harness_records`, `harness_record_notes`, dan
/// `ui_preferences`).
///
/// Dipakai khusus untuk fixture migrasi (task 8.2): membuat berkas SQLite
/// sungguhan pada versi 1, lalu dibuka kembali dengan `AppDatabase` (versi
/// 2) sehingga jalur `onUpgrade` benar-benar teruji — bukan sekadar
/// `onCreate` langsung pada versi terkini.
///
/// Memicu sendiri konvensi record milik pengguna untuk kedua tabel harness
/// — tidak memakai `createUserRecordTriggers` bersama, karena daftar tabel
/// di sana sudah diperluas change 004 dengan tabel yang tidak ada di
/// skema beku ini.
@DriftDatabase(
  tables: <Type>[HarnessRecords, HarnessRecordNotes, UiPreferences],
)
class LegacyV1Database extends _$LegacyV1Database {
  LegacyV1Database(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      for (final table in <String>['harness_records', 'harness_record_notes']) {
        await customStatement('''
CREATE TRIGGER IF NOT EXISTS ${table}_revision_touch
AFTER UPDATE ON $table
FOR EACH ROW
WHEN NEW.revision = OLD.revision
BEGIN
  UPDATE $table
     SET revision = OLD.revision + 1,
         created_at = OLD.created_at
   WHERE id = OLD.id;
END;
''');
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
