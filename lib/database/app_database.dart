import 'package:drift/drift.dart';
import 'package:mealora/database/connection/mealora_connection.dart';
import 'package:mealora/database/migrations/program_indexes.dart';
import 'package:mealora/database/migrations/program_invariant_trigger.dart';
import 'package:mealora/database/migrations/user_record_triggers.dart';
import 'package:mealora/database/seeds/program_catalog_seed.dart';
import 'package:mealora/database/tables/harness_records.dart';
import 'package:mealora/database/tables/profiles_table.dart';
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
const int kSchemaVersion = 3;

@DriftDatabase(
  tables: <Type>[
    HarnessRecords,
    HarnessRecordNotes,
    UiPreferences,
    Programs,
    UserPrograms,
    ProgramProgress,
    ProgramEvents,
    Profiles,
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
        //
        // `userPrograms` di sini sudah memakai definisi Dart terkini —
        // yaitu sudah menyertakan foreign key ke `profiles` (change 005).
        // SQLite mengizinkan `CREATE TABLE` merujuk tabel yang belum ada;
        // tabel `profiles` dibuat di blok `from < 3` tepat setelah ini,
        // sebelum `beforeOpen` mengaktifkan penegakan kunci asing.
        await m.createTable(programs);
        await m.createTable(userPrograms);
        await m.createTable(programProgress);
        await m.createTable(programEvents);
        await createUserRecordTriggers(this);
        await createProgramIndexes(this);
        await createProgramInvariantTrigger(this);
        await seedProgramCatalog(this);
      }
      if (from < 3) {
        // Versi 2 → 3 (change 005): tabel profil, lalu rujukan profil pada
        // `user_programs` dilengkapi menjadi foreign key sungguhan (Design
        // D8). Migrasi ini TIDAK membuat profil otomatis dan TIDAK
        // mengaktifkan program apa pun.
        await m.createTable(profiles);

        if (from == 2) {
          // Catatan migrasi (task 2.7, design.md Open Questions): tabel
          // `profiles` baru dan selalu kosong pada titik ini — tidak ada
          // profil yang pernah ada sebelum change ini. Akibatnya, SETIAP
          // baris `user_programs` dari versi 2 ke bawah adalah baris
          // "yatim" di bawah foreign key sungguhan: `profile_id`-nya tidak
          // pernah menunjuk ke profil nyata, karena profil belum pernah
          // ada untuk ditunjuk.
          //
          // Keputusan yang diambil: baris yatim tersebut DIHAPUS beserta
          // peristiwa dan potret kemajuannya, bukan migrasi yang ditolak.
          // Ini hanya mungkin terjadi pada perangkat uji internal (belum
          // ada rilis publik), dan ini pula perilaku yang dituntut spesifik
          // program-onboarding — "Pengguna dari versi sebelumnya": tidak
          // ada program aktif setelah migrasi, pengguna diajak memilih
          // program dari awal. Bila baris ini dibiarkan, `PRAGMA
          // foreign_key_check` setelah migrasi akan melaporkannya sebagai
          // pelanggaran.
          await customStatement('''
DELETE FROM program_progress
WHERE user_program_id IN (
  SELECT id FROM user_programs
  WHERE profile_id NOT IN (SELECT id FROM profiles)
);
''');
          await customStatement('''
DELETE FROM program_events
WHERE user_program_id IN (
  SELECT id FROM user_programs
  WHERE profile_id NOT IN (SELECT id FROM profiles)
);
''');
          await customStatement('''
DELETE FROM user_programs
WHERE profile_id NOT IN (SELECT id FROM profiles);
''');

          // Membangun ulang `user_programs` dengan definisi Dart terkini
          // (foreign key sungguhan ke `profiles`) — proses ini menghapus
          // indeks dan trigger milik tabel lama, jadi keduanya dibuat ulang
          // sesudahnya (idiom `IF NOT EXISTS`/`insertOnConflictUpdate` di
          // setiap fungsi ini membuatnya aman dipanggil berkali-kali).
          await m.alterTable(TableMigration(userPrograms));
          await createUserRecordTriggers(this);
          await createProgramIndexes(this);
          await createProgramInvariantTrigger(this);
        }
      }
    },
    beforeOpen: (details) async {
      // Kunci asing diaktifkan pada setiap pembukaan koneksi: PRAGMA ini
      // tidak bertahan antar koneksi di SQLite.
      await customStatement('PRAGMA foreign_keys = ON');
    },
  );
}
