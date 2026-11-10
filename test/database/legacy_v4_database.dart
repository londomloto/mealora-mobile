import 'package:drift/drift.dart';
import 'package:mealora/database/tables/food_servings_table.dart';
import 'package:mealora/database/tables/foods_table.dart';
import 'package:mealora/database/tables/harness_records.dart';
import 'package:mealora/database/tables/meal_entries_table.dart';
import 'package:mealora/database/tables/meal_entry_items_table.dart';
import 'package:mealora/database/tables/nutrition_values_table.dart';
import 'package:mealora/database/tables/profiles_table.dart';
import 'package:mealora/database/tables/program_events_table.dart';
import 'package:mealora/database/tables/program_progress_table.dart';
import 'package:mealora/database/tables/programs_table.dart';
import 'package:mealora/database/tables/ui_preferences.dart';
import 'package:mealora/database/tables/user_programs_table.dart';

part 'legacy_v4_database.g.dart';

/// Skema versi 4 dibekukan (change 007) — dipakai khusus fixture migrasi
/// versi 4 ke 5 (change 008, task 1.5/1.6).
///
/// Berbeda dari `LegacyV3Database`: change 008 hanya MENAMBAH satu tabel
/// baru (catatan berat) dan tidak mengubah bentuk satu pun tabel yang
/// sudah ada sejak change 007 — jadi fixture ini memakai ulang kelas tabel
/// `AppDatabase` apa adanya, bukan menyalin/membekukannya kembali.
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
    Foods,
    FoodServings,
    NutritionValues,
    MealEntries,
    MealEntryItems,
  ],
)
class LegacyV4Database extends _$LegacyV4Database {
  LegacyV4Database(super.executor);

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
  );
}
