import 'package:drift/drift.dart';

/// Nama tabel milik pengguna yang mendapat pemicu konvensi record.
const List<String> kUserRecordTables = <String>[
  'harness_records',
  'harness_record_notes',
];

/// Membuat pemicu yang menegakkan konvensi record milik pengguna di tingkat
/// basis data, bukan hanya di kode:
///
/// - `revision` bertambah satu pada setiap perubahan baris;
/// - `created_at` tidak dapat diubah setelah record dibuat.
///
/// `updated_at` tetap diisi kode lewat `Clock` yang disuntikkan, supaya
/// perilaku berwaktu dapat diuji secara deterministik.
Future<void> createUserRecordTriggers(DatabaseConnectionUser db) async {
  for (final table in kUserRecordTables) {
    await db.customStatement('''
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
}
