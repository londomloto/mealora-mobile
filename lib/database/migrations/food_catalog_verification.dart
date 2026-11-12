import 'package:mealora/database/app_database.dart';

/// Hasil pemeriksaan katalog makanan pasca-migrasi (task 2.10, change 007).
final class FoodCatalogCheck {
  const FoodCatalogCheck({
    required this.builtInFoodCount,
    required this.builtInFoodsWithoutProvenance,
    required this.foodsWithoutDefaultServing,
    required this.servingsWithoutNutrition,
    this.builtInServingsWithoutProvenance = 0,
  });

  final int builtInFoodCount;

  /// Makanan bawaan (`isUserCreated = false`) tanpa provenans lengkap —
  /// SHALL selalu nol (spec food-catalog, "Makanan tanpa asal-usul ditolak
  /// masuk katalog").
  final int builtInFoodsWithoutProvenance;

  /// Makanan tanpa tepat satu takaran bawaan — SHALL selalu nol (spec,
  /// "Takaran saji yang bermakna").
  final int foodsWithoutDefaultServing;

  /// Takaran tanpa baris nilai gizi — SHALL selalu nol.
  final int servingsWithoutNutrition;

  /// Takaran makanan bawaan tanpa tingkat asal-usul beserta rujukan atau
  /// catatan — SHALL selalu nol (spec, "Takaran tanpa asal-usul ditolak
  /// masuk katalog", change 015).
  final int builtInServingsWithoutProvenance;

  bool get isHealthy =>
      builtInFoodsWithoutProvenance == 0 &&
      foodsWithoutDefaultServing == 0 &&
      servingsWithoutNutrition == 0 &&
      builtInServingsWithoutProvenance == 0;
}

/// Memeriksa keutuhan katalog makanan: provenans lengkap pada makanan
/// bawaan, tepat satu takaran bawaan per makanan, dan setiap takaran punya
/// nilai gizi.
Future<FoodCatalogCheck> verifyFoodCatalog(AppDatabase db) async {
  final builtInCountRows = await db
      .customSelect(
        'SELECT COUNT(*) AS c FROM foods '
        'WHERE is_user_created = 0 AND deleted_at IS NULL',
      )
      .get();
  final builtInFoodCount = builtInCountRows.first.data['c']! as int;

  final missingProvenanceRows = await db.customSelect('''
SELECT COUNT(*) AS c FROM foods
WHERE is_user_created = 0 AND deleted_at IS NULL
  AND (source_type IS NULL OR source_ref IS NULL OR source_version IS NULL)
''').get();

  final missingDefaultServingRows = await db.customSelect('''
SELECT COUNT(*) AS c FROM foods f
WHERE f.deleted_at IS NULL AND (
  SELECT COUNT(*) FROM food_servings s
  WHERE s.food_id = f.id AND s.is_default = 1 AND s.deleted_at IS NULL
) != 1
''').get();

  final missingNutritionRows = await db.customSelect('''
SELECT COUNT(*) AS c FROM food_servings s
WHERE s.deleted_at IS NULL AND NOT EXISTS (
  SELECT 1 FROM nutrition_values n
  WHERE n.serving_id = s.id AND n.deleted_at IS NULL
)
''').get();

  final missingServingProvenanceRows = await db.customSelect('''
SELECT COUNT(*) AS c FROM food_servings s
JOIN foods f ON f.id = s.food_id
WHERE f.is_user_created = 0 AND s.deleted_at IS NULL
  AND (s.provenance_tier IS NULL
       OR (s.provenance_tier = 'estimate' AND s.provenance_note IS NULL)
       OR (s.provenance_tier != 'estimate' AND s.provenance_ref IS NULL))
''').get();

  return FoodCatalogCheck(
    builtInFoodCount: builtInFoodCount,
    builtInFoodsWithoutProvenance:
        missingProvenanceRows.first.data['c']! as int,
    foodsWithoutDefaultServing:
        missingDefaultServingRows.first.data['c']! as int,
    servingsWithoutNutrition: missingNutritionRows.first.data['c']! as int,
    builtInServingsWithoutProvenance:
        missingServingProvenanceRows.first.data['c']! as int,
  );
}
