import 'package:drift/drift.dart';

/// Indeks bahan resep (change 016): membaca resep menurut makanannya dan
/// mencari resep yang memakai suatu makanan sebagai bahan.
Future<void> createRecipeIngredientIndexes(DatabaseConnectionUser db) async {
  await db.customStatement(
    'CREATE INDEX IF NOT EXISTS recipe_ingredients_recipe_idx '
    'ON recipe_ingredients (recipe_food_id, position)',
  );
  await db.customStatement(
    'CREATE INDEX IF NOT EXISTS recipe_ingredients_ingredient_idx '
    'ON recipe_ingredients (ingredient_food_id)',
  );
}
