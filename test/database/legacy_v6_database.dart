import 'package:drift/drift.dart';
import 'package:mealora/database/tables/food_servings_table.dart';
import 'package:mealora/database/tables/foods_table.dart';
import 'package:mealora/database/tables/harness_records.dart';
import 'package:mealora/database/tables/meal_entries_table.dart';
import 'package:mealora/database/tables/meal_entry_items_table.dart';
import 'package:mealora/database/tables/nutrition_values_table.dart';
import 'package:mealora/database/tables/packaged_food_properties_table.dart'
    show kServingBasisValues;
import 'package:mealora/database/tables/profiles_table.dart';
import 'package:mealora/database/tables/program_events_table.dart';
import 'package:mealora/database/tables/program_progress_table.dart';
import 'package:mealora/database/tables/programs_table.dart';
import 'package:mealora/database/tables/ui_preferences.dart';
import 'package:mealora/database/tables/user_programs_table.dart';
import 'package:mealora/database/tables/user_record_columns.dart';
import 'package:mealora/database/tables/weight_records_table.dart';

part 'legacy_v6_database.g.dart';

/// `source_type` yang sah pada versi 6 (change 009) — SEBELUM change 010
/// menambah `label_extraction`. Dibekukan terpisah dari
/// `kPackagedFoodSourceTypeValues` di kode aplikasi, yang sudah memuat
/// nilai baru itu.
const List<String> _kPackagedFoodSourceTypeValuesV6 = <String>[
  'openfoodfacts',
  'user_manual',
];

/// `packaged_food_properties` dibekukan persis seperti bentuknya di versi 6
/// (change 009): TANPA `source_image_path`, dan CHECK `source_type` HANYA
/// mengizinkan `openfoodfacts`/`user_manual`.
///
/// Kelas `PackagedFoodProperties` yang dipakai `AppDatabase` sudah memuat
/// kolom dan CHECK terkini (change 010) — merujuknya di sini akan diam-diam
/// membuat fixture v6 ini punya bentuk v7, membatalkan maksud fixture
/// (pola yang sama dengan `UserProgramsV2` di `legacy_v2_database.dart`).
@DataClassName('PackagedFoodPropertiesV6Row')
class PackagedFoodPropertiesV6 extends Table with UserRecordColumns {
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
      .check(sourceType.isIn(_kPackagedFoodSourceTypeValuesV6))();

  TextColumn get sourceRef => text().withLength(min: 1, max: 64).nullable()();

  TextColumn get sourceVersion =>
      text().withLength(min: 1, max: 32).nullable()();

  DateTimeColumn get verifiedAt => dateTime()();

  BoolColumn get userCorrected =>
      boolean().withDefault(const Constant(false))();
}

/// Skema versi 6 dibekukan (change 009) — dipakai khusus fixture migrasi
/// versi 6 ke 7 (change 010, task 5.4).
///
/// Semua tabel lain tidak berubah bentuk sejak versi 6, jadi dipakai ulang
/// apa adanya dari `AppDatabase` (sama seperti `LegacyV5Database`); hanya
/// `packaged_food_properties` yang punya salinan beku tersendiri di atas.
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
    PackagedFoodPropertiesV6,
  ],
)
class LegacyV6Database extends _$LegacyV6Database {
  LegacyV6Database(super.executor);

  @override
  int get schemaVersion => 6;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
  );
}
