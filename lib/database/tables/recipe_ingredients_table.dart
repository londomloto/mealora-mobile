import 'package:drift/drift.dart';
import 'package:mealora/database/tables/food_servings_table.dart';
import 'package:mealora/database/tables/foods_table.dart';
import 'package:mealora/database/tables/user_record_columns.dart';

/// Bahan sebuah makanan resep buatan pengguna (Design D2, change 016).
///
/// Tepat satu dari [grams]/[servingMultiple] dan tepat satu dari
/// [ingredientFoodId]/[freeTextName] terisi — ditegakkan `CHECK` di bawah dan
/// validasi domain. [ingredientFoodId] memakai `restrict`, sehingga makanan
/// yang dipakai sebagai bahan tidak bisa dihapus keras.
@DataClassName('RecipeIngredientRow')
class RecipeIngredients extends Table with UserRecordColumns {
  @ReferenceName('recipeIngredientsAsRecipe')
  TextColumn get recipeFoodId =>
      text().references(Foods, #id, onDelete: KeyAction.cascade)();

  @ReferenceName('recipeIngredientsAsIngredient')
  TextColumn get ingredientFoodId =>
      text().references(Foods, #id, onDelete: KeyAction.restrict).nullable()();

  TextColumn get ingredientServingId => text()
      .references(FoodServings, #id, onDelete: KeyAction.restrict)
      .nullable()();

  /// Nama bahan tanpa data gizi.
  TextColumn get freeTextName =>
      text().withLength(min: 1, max: 120).nullable()();

  RealColumn get grams => real().nullable()();
  RealColumn get servingMultiple => real().nullable()();

  IntColumn get position => integer()();

  @override
  List<String> get customConstraints => <String>[
    'CHECK ((grams IS NULL) <> (serving_multiple IS NULL))',
    'CHECK (grams IS NULL OR grams > 0)',
    'CHECK (serving_multiple IS NULL OR serving_multiple > 0)',
    'CHECK ((ingredient_food_id IS NULL) <> (free_text_name IS NULL))',
    'CHECK ((ingredient_food_id IS NULL) = (ingredient_serving_id IS NULL))',
  ];
}
