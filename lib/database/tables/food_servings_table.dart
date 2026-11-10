import 'package:drift/drift.dart';
import 'package:mealora/database/tables/foods_table.dart';
import 'package:mealora/database/tables/user_record_columns.dart';

/// Takaran saji sebuah makanan (spec food-catalog, "Takaran saji yang
/// bermakna"): label sehari-hari, jumlah, satuan, dan padanan gram bila
/// diketahui. Setiap makanan SHALL punya sekurang-kurangnya satu takaran,
/// dengan tepat satu ditandai [isDefault].
@DataClassName('FoodServingRow')
class FoodServings extends Table with UserRecordColumns {
  TextColumn get foodId =>
      text().references(Foods, #id, onDelete: KeyAction.restrict)();

  /// Label lengkap sehari-hari (mis. "150 g · 1 mangkuk").
  TextColumn get label => text().withLength(min: 1, max: 80)();

  RealColumn get amount => real()();
  TextColumn get unit => text().withLength(min: 1, max: 24)();
  RealColumn get gramEquivalent => real().nullable()();

  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();
}
