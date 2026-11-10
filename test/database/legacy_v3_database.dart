import 'package:drift/drift.dart';
import 'package:mealora/database/tables/harness_records.dart';
import 'package:mealora/database/tables/profiles_table.dart';
import 'package:mealora/database/tables/program_events_table.dart';
import 'package:mealora/database/tables/program_progress_table.dart';
import 'package:mealora/database/tables/programs_table.dart';
import 'package:mealora/database/tables/ui_preferences.dart';
import 'package:mealora/database/tables/user_programs_table.dart';

part 'legacy_v3_database.g.dart';

/// Skema versi 3 dibekukan (change 005) — dipakai khusus fixture migrasi
/// versi 3 ke 4 (change 007, task 2.9/2.10).
///
/// Berbeda dari `LegacyV2Database`: change 007 hanya MENAMBAH lima tabel
/// baru (makanan, takaran saji, nilai gizi, catatan makan, butir catatan)
/// dan tidak mengubah bentuk satu pun tabel yang sudah ada sejak change 005
/// — jadi fixture ini memakai ulang kelas tabel `AppDatabase` apa adanya,
/// bukan menyalin/membekukannya kembali.
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
class LegacyV3Database extends _$LegacyV3Database {
  LegacyV3Database(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
  );
}
