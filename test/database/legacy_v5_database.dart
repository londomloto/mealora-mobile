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
import 'package:mealora/database/tables/weight_records_table.dart';

part 'legacy_v5_database.g.dart';

/// Skema versi 5 dibekukan (change 008) — dipakai khusus fixture migrasi
/// versi 5 ke 6 (change 009, task 2.5/2.6).
///
/// Berbeda dari `LegacyV4Database`: change 009 hanya MENAMBAH satu tabel
/// baru (sifat produk kemasan) dan tidak mengubah bentuk satu pun tabel
/// yang sudah ada sejak change 008 — jadi fixture ini memakai ulang kelas
/// tabel `AppDatabase` apa adanya, bukan menyalin/membekukannya kembali.
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
    WeightRecords,
  ],
)
class LegacyV5Database extends _$LegacyV5Database {
  LegacyV5Database(super.executor);

  @override
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
  );
}
