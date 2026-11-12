import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/data/local/drift_diary_repository.dart';
import 'package:mealora/data/local/drift_food_repository.dart';
import 'package:mealora/data/local/drift_program_repository.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/domain/food/food.dart';
import 'package:mealora/domain/food/food_category.dart';
import 'package:mealora/domain/food/food_repository.dart';
import 'package:mealora/domain/food/meal_time.dart';
import 'package:mealora/domain/food/nutrition_profile.dart';
import 'package:mealora/domain/food/recipe.dart';
import 'package:mealora/domain/food/recipe_calculator.dart';
import 'package:mealora/domain/shared/units.dart';

import 'test_database.dart';

/// Makanan resep di `DriftFoodRepository` (change 016, task 2.1–2.4).
void main() {
  late AppDatabase db;
  late DriftFoodRepository repo;

  Energy kcal(double v) => Energy.kcalValue(v, field: 'e').valueOrNull!;

  setUp(() {
    db = createTestDatabase();
    repo = DriftFoodRepository(
      db,
      ids: createTestIds(),
      clock: createTestClock(),
    );
  });
  tearDown(() => db.close());

  Future<Food> per100gIngredient(String name, double energy) =>
      repo.createUserFood(
        name: name,
        category: FoodCategory.other,
        serving: ServingSizeInput(
          label: '100 g',
          amount: 100,
          unit: 'g',
          gramEquivalent: 100,
          nutrition: NutritionProfile(energy: kcal(energy), proteinG: 10),
        ),
      );

  Future<Food> createRecipe({
    required List<RecipeIngredientInput> ingredients,
    RecipeYield recipeYield = const RecipeYield(servings: 2),
    double perServingKcal = 179,
    NutritionOrigin origin = NutritionOrigin.recipe,
  }) => repo.createRecipeFood(
    name: 'Nasi telur ceplok',
    category: FoodCategory.staple,
    ingredients: ingredients,
    recipeYield: recipeYield,
    perServing: NutritionProfile(energy: kcal(perServingKcal)),
    origin: origin,
  );

  test('makanan buatan pengguna baru bertanda manual', () async {
    final food = await per100gIngredient('Nasi', 180);
    expect(food.nutritionOrigin, NutritionOrigin.manual);
    expect(food.isRecipe, isFalse);
  });

  test('membuat makanan resep beserta bahannya, lalu membaca resepnya '
      '(task 2.1)', () async {
    final rice = await per100gIngredient('Nasi', 180);
    final food = await createRecipe(
      ingredients: [
        RecipeIngredientInput.food(
          foodId: rice.id,
          servingId: rice.defaultServing.id,
          amount: const RecipeGrams(150),
        ),
        const RecipeIngredientInput.freeText(
          freeTextName: 'bumbu racik',
          amount: RecipeServingMultiple(1),
        ),
      ],
    );

    expect(food.isRecipe, isTrue);
    expect(food.isUserCreated, isTrue);

    final recipe = (await repo.recipeOf(food.id))!;
    expect(recipe.recipeYield.servings, 2);
    expect(recipe.recipeYield.finishedGrams, isNull);
    expect(recipe.ingredients.map((i) => i.label), ['Nasi', 'bumbu racik']);
    expect(recipe.ingredients.first.serving!.id, rice.defaultServing.id);
    expect((recipe.ingredients.first.amount as RecipeGrams).value, 150);
    expect(recipe.ingredients.last.food, isNull);

    final calc = RecipeCalculator.calculate(
      recipe.ingredients.map((i) => i.toCalculatorInput()).toList(),
      recipe.recipeYield,
    );
    expect(calc.total.energy!.kcal, closeTo(270, 1e-9));
    expect(calc.incomplete[RecipeNutrient.energy], ['bumbu racik']);
  });

  test('makanan biasa tidak punya resep', () async {
    final rice = await per100gIngredient('Nasi', 180);
    expect(await repo.recipeOf(rice.id), isNull);
  });

  test('takaran resep tanpa berat jadi: hanya "1 porsi" tanpa padanan gram '
      '(task 2.2)', () async {
    final rice = await per100gIngredient('Nasi', 180);
    final food = await createRecipe(
      ingredients: [
        RecipeIngredientInput.food(
          foodId: rice.id,
          servingId: rice.defaultServing.id,
          amount: const RecipeGrams(100),
        ),
      ],
    );
    expect(food.servings, hasLength(1));
    expect(food.defaultServing.label, '1 porsi');
    expect(food.defaultServing.gramEquivalent, isNull);
    expect(food.defaultServing.nutrition.energy!.kcal, 179);
  });

  test('takaran resep dengan berat jadi: porsi ber-gram dan takaran 100 g '
      '(task 2.2)', () async {
    final rice = await per100gIngredient('Nasi', 180);
    final food = await createRecipe(
      ingredients: [
        RecipeIngredientInput.food(
          foodId: rice.id,
          servingId: rice.defaultServing.id,
          amount: const RecipeGrams(100),
        ),
      ],
      recipeYield: const RecipeYield(servings: 2, finishedGrams: 210),
      perServingKcal: 228.5,
    );

    expect(food.defaultServing.gramEquivalent, 105);
    expect(food.defaultServing.label, '1 porsi · 105 g');
    final per100 = food.servings.singleWhere((s) => !s.isDefault);
    expect(per100.gramEquivalent, 100);
    expect(per100.nutrition.energy!.kcal, closeTo(228.5 * 100 / 105, 1e-9));
  });

  test('menyunting resep mengganti bahan dan menghapus takaran 100 g bila '
      'berat jadi dikosongkan', () async {
    final rice = await per100gIngredient('Nasi', 180);
    final egg = await per100gIngredient('Telur', 160);
    final food = await createRecipe(
      ingredients: [
        RecipeIngredientInput.food(
          foodId: rice.id,
          servingId: rice.defaultServing.id,
          amount: const RecipeGrams(150),
        ),
        RecipeIngredientInput.food(
          foodId: egg.id,
          servingId: egg.defaultServing.id,
          amount: const RecipeGrams(55),
        ),
      ],
      recipeYield: const RecipeYield(servings: 2, finishedGrams: 210),
    );

    final updated = await repo.updateRecipeFood(
      food.id,
      name: 'Nasi telur ceplok',
      ingredients: [
        RecipeIngredientInput.food(
          foodId: rice.id,
          servingId: rice.defaultServing.id,
          amount: const RecipeGrams(100),
        ),
      ],
      recipeYield: const RecipeYield(servings: 1),
      perServing: NutritionProfile(energy: kcal(180)),
      origin: NutritionOrigin.recipe,
    );

    expect(updated.servings, hasLength(1));
    expect(updated.defaultServing.nutrition.energy!.kcal, 180);
    final recipe = (await repo.recipeOf(food.id))!;
    expect(recipe.ingredients.map((i) => i.label), ['Nasi']);
    expect(recipe.recipeYield.finishedGrams, isNull);
  });

  test('koreksi manual tersimpan dengan asal manual dan resep tetap ada '
      '(Design D4)', () async {
    final rice = await per100gIngredient('Nasi', 180);
    final food = await createRecipe(
      ingredients: [
        RecipeIngredientInput.food(
          foodId: rice.id,
          servingId: rice.defaultServing.id,
          amount: const RecipeGrams(100),
        ),
      ],
      perServingKcal: 250,
      origin: NutritionOrigin.manual,
    );
    expect(food.nutritionOrigin, NutritionOrigin.manual);
    expect(food.defaultServing.nutrition.energy!.kcal, 250);
    expect(await repo.recipeOf(food.id), isNotNull);
  });

  test('menolak penghapusan makanan yang dipakai sebagai bahan, menyebut '
      'resepnya (task 2.3)', () async {
    final rice = await per100gIngredient('Nasi', 180);
    await createRecipe(
      ingredients: [
        RecipeIngredientInput.food(
          foodId: rice.id,
          servingId: rice.defaultServing.id,
          amount: const RecipeGrams(100),
        ),
      ],
    );

    await expectLater(
      repo.deleteUserFood(rice.id),
      throwsA(
        isA<FoodInUseAsIngredientException>().having(
          (e) => e.recipeNames,
          'recipeNames',
          ['Nasi telur ceplok'],
        ),
      ),
    );
    expect(await repo.findById(rice.id), isNotNull);
  });

  test('makanan yang tidak dipakai resep bisa dihapus', () async {
    final rice = await per100gIngredient('Nasi', 180);
    await repo.deleteUserFood(rice.id);
    expect(await repo.findById(rice.id), isNull);
  });

  test(
    'catatan lama tidak berubah setelah resep disunting (task 2.4)',
    () async {
      const profileId = 'profile-1';
      const today = LocalDate(2026, 11, 12);
      await db
          .into(db.profiles)
          .insert(
            ProfilesCompanion.insert(
              id: profileId,
              createdAt: testInstant,
              updatedAt: testInstant,
            ),
          );
      final diary = DriftDiaryRepository(
        db,
        clock: createTestClock(),
        ids: createTestIds(),
        programRepository: DriftProgramRepository(
          db,
          clock: createTestClock(),
          ids: createTestIds(),
        ),
      );
      final rice = await per100gIngredient('Nasi', 180);
      final food = await createRecipe(
        ingredients: [
          RecipeIngredientInput.food(
            foodId: rice.id,
            servingId: rice.defaultServing.id,
            amount: const RecipeGrams(150),
          ),
        ],
        perServingKcal: 135,
      );
      await diary.addEntry(
        profileId: profileId,
        date: today,
        mealTime: MealTime.lunch,
        food: food,
        serving: food.defaultServing,
        quantity: 1,
      );
      final before = await diary.dailyTotal(profileId, today);

      await repo.updateRecipeFood(
        food.id,
        name: 'Nasi telur ceplok',
        ingredients: [
          RecipeIngredientInput.food(
            foodId: rice.id,
            servingId: rice.defaultServing.id,
            amount: const RecipeGrams(50),
          ),
        ],
        recipeYield: const RecipeYield(servings: 1),
        perServing: NutritionProfile(energy: kcal(90)),
        origin: NutritionOrigin.recipe,
      );

      final after = await diary.dailyTotal(profileId, today);
      expect(before.nutrition.energy!.kcal, 135);
      expect(after.nutrition.energy!.kcal, 135);
    },
  );

  test('masukan tidak sah ditolak: tanpa bahan, porsi 0', () async {
    final rice = await per100gIngredient('Nasi', 180);
    await expectLater(createRecipe(ingredients: []), throwsArgumentError);
    await expectLater(
      createRecipe(
        ingredients: [
          RecipeIngredientInput.food(
            foodId: rice.id,
            servingId: rice.defaultServing.id,
            amount: const RecipeGrams(100),
          ),
        ],
        recipeYield: const RecipeYield(servings: 0),
      ),
      throwsArgumentError,
    );
  });
}
