import 'package:drift/drift.dart';
import 'package:mealora/database/tables/food_servings_table.dart';
import 'package:mealora/database/tables/user_record_columns.dart';

/// Nilai gizi untuk SATU takaran saji (bukan per 100 g) — relasi 1:1 dengan
/// `FoodServings` (spec food-catalog). Seluruh zat gizi dapat kosong untuk
/// membedakan belum diketahui dari nol (Design D9, change 007); `energyKcal`,
/// `proteinG`, `carbohydrateG`, dan `fatG` selalu terisi untuk makanan
/// bawaan (task 1.6/2.3.5 — makanan tanpa nilai dasar lengkap tidak masuk
/// katalog), sementara `fiberG`/`sugarG`/`sodiumMg` opsional sesuai sumber.
@DataClassName('NutritionValueRow')
class NutritionValues extends Table with UserRecordColumns {
  TextColumn get servingId => text()
      .references(FoodServings, #id, onDelete: KeyAction.cascade)
      .unique()();

  RealColumn get energyKcal => real().nullable()();
  RealColumn get proteinG => real().nullable()();
  RealColumn get carbohydrateG => real().nullable()();
  RealColumn get fatG => real().nullable()();
  RealColumn get fiberG => real().nullable()();
  RealColumn get sugarG => real().nullable()();
  RealColumn get sodiumMg => real().nullable()();
}
