import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/domain/food/nutrition_profile.dart';
import 'package:mealora/domain/food/recipe_calculator.dart';
import 'package:mealora/domain/food/serving_size.dart';
import 'package:mealora/domain/shared/units.dart';

/// `RecipeCalculator` — spec custom-food-recipe (change 016).
void main() {
  Energy kcal(double v) => Energy.kcalValue(v, field: 'e').valueOrNull!;

  ServingSize per100g(double energy, {double? fiber = 1}) => ServingSize(
    id: 's',
    label: '100 g',
    amount: 100,
    unit: 'g',
    gramEquivalent: 100,
    isDefault: true,
    nutrition: NutritionProfile(
      energy: kcal(energy),
      proteinG: 10,
      carbohydrateG: 20,
      fatG: 5,
      fiberG: fiber,
      sugarG: 2,
      sodiumMg: 50,
    ),
  );

  final egg = ServingSize(
    id: 'egg',
    label: '1 butir',
    amount: 1,
    unit: 'butir',
    gramEquivalent: 55,
    isDefault: true,
    nutrition: NutritionProfile(energy: kcal(88), proteinG: 7),
  );

  final portion = ServingSize(
    id: 'p',
    label: '1 porsi',
    amount: 1,
    unit: 'porsi',
    isDefault: true,
    nutrition: NutritionProfile(energy: kcal(250)),
  );

  const one = RecipeYield(servings: 1);

  test('menjumlahkan bahan dalam gram (358 kkal)', () {
    final r = RecipeCalculator.calculate([
      RecipeIngredient(
        label: 'A',
        serving: per100g(180),
        amount: const RecipeGrams(150),
      ),
      RecipeIngredient(
        label: 'B',
        serving: per100g(160),
        amount: const RecipeGrams(55),
      ),
    ], one);

    expect(r.total.energy!.kcal, closeTo(358, 1e-9));
    expect(r.contributions.map((c) => c.nutrition.energy!.kcal), [
      closeTo(270, 1e-9),
      closeTo(88, 1e-9),
    ]);
    expect(r.isComplete, isTrue);
  });

  test('takaran "1 butir" dihitung sama dengan 55 g', () {
    final bySeving = RecipeCalculator.contributionOf(
      RecipeIngredient(
        label: 'Telur',
        serving: egg,
        amount: const RecipeServingMultiple(1),
      ),
    );
    final byGram = RecipeCalculator.contributionOf(
      RecipeIngredient(
        label: 'Telur',
        serving: egg,
        amount: const RecipeGrams(55),
      ),
    );
    expect(bySeving.energy!.kcal, closeTo(byGram.energy!.kcal, 1e-9));
  });

  test('takaran tanpa padanan berat memakai kelipatan', () {
    final c = RecipeCalculator.contributionOf(
      RecipeIngredient(
        label: 'Opor',
        serving: portion,
        amount: const RecipeServingMultiple(0.5),
      ),
    );
    expect(c.energy!.kcal, closeTo(125, 1e-9));
  });

  test('per porsi (300 kkal) dan per 100 g hasil (150 kkal)', () {
    final r = RecipeCalculator.calculate([
      RecipeIngredient(
        label: 'A',
        serving: per100g(1200),
        amount: const RecipeGrams(100),
      ),
    ], const RecipeYield(servings: 4, finishedGrams: 800));

    expect(r.total.energy!.kcal, closeTo(1200, 1e-9));
    expect(r.perServing.energy!.kcal, closeTo(300, 1e-9));
    expect(r.per100gFinished!.energy!.kcal, closeTo(150, 1e-9));
  });

  test('tanpa berat jadi tidak ada takaran per 100 g', () {
    final r = RecipeCalculator.calculate([
      RecipeIngredient(
        label: 'A',
        serving: per100g(100),
        amount: const RecipeGrams(100),
      ),
    ], one);
    expect(r.per100gFinished, isNull);
  });

  test('serat tidak diketahui pada satu bahan ditandai beserta bahannya', () {
    final r = RecipeCalculator.calculate([
      RecipeIngredient(
        label: 'Nasi',
        serving: per100g(180),
        amount: const RecipeGrams(100),
      ),
      RecipeIngredient(
        label: 'Kecap',
        serving: per100g(60, fiber: null),
        amount: const RecipeGrams(100),
      ),
    ], one);

    expect(r.incomplete.keys, [RecipeNutrient.fiber]);
    expect(r.incomplete[RecipeNutrient.fiber], ['Kecap']);
    expect(r.total.fiberG, 1, reason: 'jumlah bahan yang diketahui');
    expect(r.isIncomplete(RecipeNutrient.energy), isFalse);
  });

  test('bahan tanpa data membuat seluruh zat tidak lengkap', () {
    final r = RecipeCalculator.calculate([
      RecipeIngredient(
        label: 'Nasi',
        serving: per100g(180),
        amount: const RecipeGrams(100),
      ),
      const RecipeIngredient(
        label: 'bumbu racik',
        amount: RecipeServingMultiple(1),
      ),
    ], one);

    expect(r.incomplete.keys.toSet(), RecipeNutrient.values.toSet());
    expect(r.incompleteIngredients, ['bumbu racik']);
    expect(r.total.energy!.kcal, closeTo(180, 1e-9));
  });

  test('zat yang tidak diketahui pada semua bahan bernilai null', () {
    final r = RecipeCalculator.calculate([
      const RecipeIngredient(label: 'X', amount: RecipeServingMultiple(1)),
    ], one);
    expect(r.total.isFullyUnknown, isTrue);
  });

  test('menghapus bahan menghitung ulang dan mencabut penanda', () {
    final base = [
      RecipeIngredient(
        label: 'A',
        serving: per100g(180),
        amount: const RecipeGrams(150),
      ),
      const RecipeIngredient(
        label: 'bumbu racik',
        amount: RecipeServingMultiple(1),
      ),
    ];
    final after = RecipeCalculator.calculate(base.sublist(0, 1), one);
    expect(after.total.energy!.kcal, closeTo(270, 1e-9));
    expect(after.isComplete, isTrue);
  });

  test('penanda terbatas pada zat yang ditampilkan; zat tersembunyi yang '
      'tidak lengkap disimpan sebagai belum diketahui', () {
    final r = RecipeCalculator.calculate([
      RecipeIngredient(
        label: 'Nasi',
        serving: per100g(180),
        amount: const RecipeGrams(100),
      ),
      RecipeIngredient(
        label: 'Kecap',
        serving: per100g(60, fiber: null),
        amount: const RecipeGrams(100),
      ),
    ], one);

    expect(r.incompleteIngredientsFor(kRecipeDisplayedNutrients), isEmpty);
    expect(r.incompleteIngredients, ['Kecap']);
    final stored = r.perServingForStorage(kRecipeDisplayedNutrients);
    expect(stored.fiberG, isNull);
    expect(stored.energy!.kcal, closeTo(240, 1e-9));
    expect(stored.sugarG, 4);
  });

  group('validasi', () {
    test('jumlah 0 atau negatif ditolak', () {
      for (final v in [0.0, -1.0, double.nan]) {
        expect(RecipeValidation.positive(v), RecipeInputError.notPositive);
      }
      expect(RecipeValidation.positive(0.5), isNull);
    });

    test('gram untuk takaran tanpa padanan berat ditolak', () {
      expect(
        RecipeValidation.ingredient(
          RecipeIngredient(
            label: 'Opor',
            serving: portion,
            amount: const RecipeGrams(100),
          ),
        ),
        RecipeInputError.gramsWithoutWeight,
      );
      expect(RecipeValidation.canUseGrams(portion), isFalse);
      expect(RecipeValidation.canUseGrams(egg), isTrue);
    });

    test('kalkulator melempar untuk bahan 0 g, porsi 0, berat jadi 0', () {
      final ok = RecipeIngredient(
        label: 'A',
        serving: per100g(100),
        amount: const RecipeGrams(100),
      );
      expect(
        () => RecipeCalculator.calculate([
          RecipeIngredient(
            label: 'A',
            serving: per100g(100),
            amount: const RecipeGrams(0),
          ),
        ], one),
        throwsArgumentError,
      );
      expect(
        () => RecipeCalculator.calculate([ok], const RecipeYield(servings: 0)),
        throwsArgumentError,
      );
      expect(
        () => RecipeCalculator.calculate([
          ok,
        ], const RecipeYield(servings: 1, finishedGrams: 0)),
        throwsArgumentError,
      );
    });
  });
}
