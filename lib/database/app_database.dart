import 'package:drift/drift.dart';
import 'package:mealora/database/connection/mealora_connection.dart';
import 'package:mealora/database/migrations/program_indexes.dart';
import 'package:mealora/database/migrations/program_invariant_trigger.dart';
import 'package:mealora/database/migrations/user_record_triggers.dart';
import 'package:mealora/database/seeds/program_catalog_seed.dart';
import 'package:mealora/database/tables/harness_records.dart';
import 'package:mealora/database/tables/program_events_table.dart';
import 'package:mealora/database/tables/program_progress_table.dart';
import 'package:mealora/database/tables/programs_table.dart';
import 'package:mealora/database/tables/ui_preferences.dart';
import 'package:mealora/database/tables/user_programs_table.dart';

part 'app_database.g.dart';

/// Versi skema penyimpanan lokal.
///
/// Setiap perubahan struktur menaikkan angka ini dan menambah langkah di
/// [AppDatabase.migration] beserta kasus uji di `test/database/`. Penurunan
/// versi (downgrade) tidak didukung.
const int kSchemaVersion = 2;

@DriftDatabase(
  tables: <Type>[
    HarnessRecords,
    HarnessRecordNotes,
    UiPreferences,
    Programs,
    UserPrograms,
    ProgramProgress,
    ProgramEvents,
  ],
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
      await createProgramIndexes(this);
      await createProgramInvariantTrigger(this);
      await seedProgramCatalog(this);
    },
    onUpgrade: (m, from, to) async {
      if (from > to) {
        throw StateError(
          'Penurunan versi skema tidak didukung (dari $from ke $to).',
        );
      }
      if (from < 2) {
        // Versi 1 → 2 (change 004): empat tabel program, indeks, dan
        // trigger invarian, lalu seed katalog. Tidak menyentuh data versi 1
        // dan tidak mendaftarkan profil mana pun ke program (Design D8).
        await m.createTable(programs);
        await m.createTable(userPrograms);
        await m.createTable(programProgress);
        await m.createTable(programEvents);
        await createUserRecordTriggers(this);
        await createProgramIndexes(this);
        await createProgramInvariantTrigger(this);
        await seedProgramCatalog(this);
      }
    },
    beforeOpen: (details) async {
      // Kunci asing diaktifkan pada setiap pembukaan koneksi: PRAGMA ini
      // tidak bertahan antar koneksi di SQLite.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
