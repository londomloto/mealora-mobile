import 'package:mealora/domain/food/food.dart';
import 'package:mealora/domain/food/recipe_calculator.dart';
import 'package:mealora/domain/food/serving_size.dart';

/// Asal nilai gizi makanan buatan pengguna (Design D2/D4, change 016).
enum NutritionOrigin {
  manual,
  recipe;

  String get stableCode => name;

  static NutritionOrigin? fromStableCode(String? code) =>
      code == null ? null : NutritionOrigin.values.byName(code);
}

/// Bentuk makanan (change 015): siap konsumsi, mentah, atau kering.
enum FoodForm {
  ready,
  raw,
  dry;

  static FoodForm? fromStableCode(String? code) =>
      code == null ? null : FoodForm.values.byName(code);
}

/// Satu bahan yang akan disimpan bersama makanan resep. Tepat satu dari
/// [foodId]/[freeTextName]; [servingId] wajib bila [foodId] terisi.
final class RecipeIngredientInput {
  const RecipeIngredientInput.food({
    required String this.foodId,
    required String this.servingId,
    required this.amount,
  }) : freeTextName = null;

  const RecipeIngredientInput.freeText({
    required String this.freeTextName,
    required this.amount,
  }) : foodId = null,
       servingId = null;

  final String? foodId;
  final String? servingId;
  final String? freeTextName;
  final RecipeAmount amount;
}

/// Bahan resep tersimpan beserta makanan & takarannya yang berlaku saat ini
/// — dipakai layar sunting untuk menghitung ulang (Design D3).
final class SavedRecipeIngredient {
  const SavedRecipeIngredient({
    required this.label,
    required this.amount,
    this.food,
    this.serving,
  });

  final String label;
  final Food? food;
  final ServingSize? serving;
  final RecipeAmount amount;

  RecipeIngredient toCalculatorInput() =>
      RecipeIngredient(label: label, serving: serving, amount: amount);

  RecipeIngredientInput toInput() => food == null
      ? RecipeIngredientInput.freeText(freeTextName: label, amount: amount)
      : RecipeIngredientInput.food(
          foodId: food!.id,
          servingId: serving!.id,
          amount: amount,
        );
}

final class SavedRecipe {
  const SavedRecipe({required this.ingredients, required this.recipeYield});

  final List<SavedRecipeIngredient> ingredients;
  final RecipeYield recipeYield;
}

/// Makanan tidak bisa dihapus karena dipakai sebagai bahan resep lain
/// (task 2.3, change 016).
final class FoodInUseAsIngredientException implements Exception {
  const FoodInUseAsIngredientException(this.recipeNames);

  final List<String> recipeNames;

  @override
  String toString() =>
      'FoodInUseAsIngredientException(${recipeNames.join(', ')})';
}
