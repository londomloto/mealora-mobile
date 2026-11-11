import 'package:drift/drift.dart';
import 'package:mealora/database/tables/food_servings_table.dart';
import 'package:mealora/database/tables/foods_table.dart';
import 'package:mealora/database/tables/harness_records.dart';
import 'package:mealora/database/tables/meal_entries_table.dart';
import 'package:mealora/database/tables/meal_entry_items_table.dart';
import 'package:mealora/database/tables/nutrition_values_table.dart';
import 'package:mealora/database/tables/packaged_food_properties_table.dart'
    show kPackagedFoodSourceTypeValues, kServingBasisValues;
import 'package:mealora/database/tables/profiles_table.dart';
import 'package:mealora/database/tables/program_events_table.dart';
import 'package:mealora/database/tables/program_progress_table.dart';
import 'package:mealora/database/tables/programs_table.dart';
import 'package:mealora/database/tables/ui_preferences.dart';
import 'package:mealora/database/tables/user_programs_table.dart';
import 'package:mealora/database/tables/user_record_columns.dart';
import 'package:mealora/database/tables/weight_records_table.dart';

part 'legacy_v7_database.g.dart';

/// `packaged_food_properties` dibekukan persis seperti bentuknya di versi 7
/// (change 010, migrasi 6→7): `barcode` MASIH wajib terisi — belum
/// longgar seperti definisi Dart terkini (change 010, migrasi 7→8).
///
/// `source_type` di versi 7 sudah memuat `label_extraction` dan kolom
/// `source_image_path` sudah ada, jadi keduanya dipakai ulang dari konstanta
/// hidup (`kPackagedFoodSourceTypeValues`/`kServingBasisValues`) — yang
/// belum berubah sejak versi 7. Hanya `barcode` yang dibekukan terpisah.
@DataClassName('PackagedFoodPropertiesV7Row')
class PackagedFoodPropertiesV7 extends Table with UserRecordColumns {
  @override
  String get tableName => 'packaged_food_properties';

  TextColumn get foodId =>
      text().references(Foods, #id, onDelete: KeyAction.cascade).unique()();

  TextColumn get barcode => text().withLength(min: 8, max: 14)();

  TextColumn get packageSize => text().withLength(min: 1, max: 40).nullable()();

  RealColumn get unitsPerPackage => real()
      // ignore: recursive_getters
      .check(unitsPerPackage.isBiggerThanValue(0))
      .nullable()();

  TextColumn get servingBasis => text()
      .withLength(min: 1, max: 16)
      // ignore: recursive_getters
      .check(servingBasis.isIn(kServingBasisValues))();

  TextColumn get sourceType => text()
      .withLength(min: 1, max: 32)
      // ignore: recursive_getters
      .check(sourceType.isIn(kPackagedFoodSourceTypeValues))();

  TextColumn get sourceRef => text().withLength(min: 1, max: 64).nullable()();

  TextColumn get sourceVersion =>
      text().withLength(min: 1, max: 32).nullable()();

  DateTimeColumn get verifiedAt => dateTime()();

  BoolColumn get userCorrected =>
      boolean().withDefault(const Constant(false))();

  TextColumn get sourceImagePath =>
      text().withLength(min: 1, max: 512).nullable()();
}

/// Skema versi 7 dibekukan (change 010, migrasi 6→7) — dipakai khusus
/// fixture migrasi versi 7 ke 8 (change 010, barcode opsional).
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
    PackagedFoodPropertiesV7,
  ],
)
class LegacyV7Database extends _$LegacyV7Database {
  LegacyV7Database(super.executor);

  @override
  int get schemaVersion => 7;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
  );
}
