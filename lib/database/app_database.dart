import 'package:drift/drift.dart';
import 'package:mealora/database/connection/mealora_connection.dart';
import 'package:mealora/database/migrations/user_record_triggers.dart';
import 'package:mealora/database/tables/harness_records.dart';
import 'package:mealora/database/tables/ui_preferences.dart';

part 'app_database.g.dart';

/// Versi skema penyimpanan lokal.
///
/// Setiap perubahan struktur menaikkan angka ini dan menambah langkah di
/// [AppDatabase.migration] beserta kasus uji di `test/database/`. Penurunan
/// versi (downgrade) tidak didukung.
const int kSchemaVersion = 1;

@DriftDatabase(
  tables: <Type>[HarnessRecords, HarnessRecordNotes, UiPreferences],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase([QueryExecutor? executor])
    : super(executor ?? openMealoraConnection());

  @override
  int get schemaVersion => kSchemaVersion;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await createUserRecordTriggers(this);
    },
    onUpgrade: (m, from, to) async {
      if (from > to) {
        throw StateError(
          'Penurunan versi skema tidak didukung (dari $from ke $to).',
        );
      }
      // Versi 1 adalah titik awal; belum ada langkah migrasi.
    },
    beforeOpen: (details) async {
      // Kunci asing diaktifkan pada setiap pembukaan koneksi: PRAGMA ini
      // tidak bertahan antar koneksi di SQLite.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
