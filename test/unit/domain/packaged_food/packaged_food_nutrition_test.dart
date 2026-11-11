import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/domain/food/food.dart';
import 'package:mealora/domain/food/food_category.dart';
import 'package:mealora/domain/food/nutrition_profile.dart';
import 'package:mealora/domain/food/serving_size.dart';
import 'package:mealora/domain/packaged_food/packaged_food.dart';
import 'package:mealora/domain/packaged_food/packaged_food_nutrition.dart'
    show calculatePackagedFoodNutrition, packagedFoodQuantityMultiplier;
import 'package:mealora/domain/packaged_food/packaged_food_provenance.dart';
import 'package:mealora/domain/packaged_food/packaged_food_quantity.dart';
import 'package:mealora/domain/packaged_food/serving_basis.dart';
import 'package:mealora/domain/shared/units.dart';

/// Uji aritmetika basis takaran (tasks 3.6/3.7, change 009) — risiko paling
/// serius di change ini (design.md Risks), karena hasil yang salah tetap
/// tampak masuk akal. Setiap basis memakai angka yang BERBEDA satu sama
/// lain, bukan kebetulan sama (task 3.6).
void main() {
  PackagedFoodProvenance provenance({bool userCorrected = false}) =>
      PackagedFoodProvenance(
        sourceType: 'openfoodfacts',
        sourceRef: 'off-1',
        sourceVersion: '2026-11-01',
        verifiedAt: DateTime.utc(2026, 11, 1),
        userCorrected: userCorrected,
      );

  PackagedFood perServingProduct({
    required NutritionProfile perServing,
    double? unitsPerPackage,
  }) {
    final food = Food(
      id: 'food-1',
      name: 'Keripik Singkong Renyah',
      category: FoodCategory.snack,
      isUserCreated: false,
      servings: <ServingSize>[
        ServingSize(
          id: 'serving-1',
          label: '30 g · 1 sajian',
          amount: 1,
          unit: 'sajian',
          isDefault: true,
          gramEquivalent: 30,
          nutrition: perServing,
        ),
      ],
    );
    return PackagedFood(
      food: food,
      barcode: '8991234567890',
      servingBasis: ServingBasis.perServing,
      unitsPerPackage: unitsPerPackage,
      packageSize: '60 g',
      provenance: provenance(),
    );
  }

  PackagedFood perHundredGramsProduct({required NutritionProfile per100g}) {
    final food = Food(
      id: 'food-2',
      name: 'Saus Sambal Botolan',
      category: FoodCategory.other,
      isUserCreated: false,
      servings: <ServingSize>[
        ServingSize(
          id: 'serving-2',
          label: '100 g',
          amount: 100,
          unit: 'g',
          isDefault: true,
          gramEquivalent: 100,
          nutrition: per100g,
        ),
      ],
    );
    return PackagedFood(
      food: food,
      barcode: '89912340001',
      servingBasis: ServingBasis.perHundredGrams,
      provenance: provenance(),
    );
  }

  group('basis per sajian', () {
    test('satu sajian menghasilkan nilai rekaman apa adanya (task 3.1, 3.7 — '
        '150 kkal per sajian)', () {
      final product = perServingProduct(
        perServing: NutritionProfile(
          energy: Energy.kcalValue(150, field: 'energy').valueOrNull,
          proteinG: 2,
          carbohydrateG: 18,
          fatG: 7,
        ),
        unitsPerPackage: 2,
      );

      final result = calculatePackagedFoodNutrition(
        product,
        const ServingsEaten(1),
      );

      expect(result.energy, Energy.kcalValue(150, field: 'x').valueOrNull);
      expect(result.proteinG, 2);
      expect(result.carbohydrateG, 18);
      expect(result.fatG, 7);
    });

    test('beberapa sajian mengalikan nilai per sajian (task 3.1)', () {
      final product = perServingProduct(
        perServing: NutritionProfile(
          energy: Energy.kcalValue(150, field: 'energy').valueOrNull,
          proteinG: 2,
        ),
        unitsPerPackage: 2,
      );

      final result = calculatePackagedFoodNutrition(
        product,
        const ServingsEaten(2.5),
      );

      expect(result.energy, Energy.kcalValue(375, field: 'x').valueOrNull);
      expect(result.proteinG, 5);
    });

    test('satu kemasan penuh = nilai per sajian × jumlah sajian per kemasan '
        '(spec, "Satu kemasan berisi dua sajian"; task 3.2, 3.7 — 2 sajian '
        'per kemasan → 300 kkal)', () {
      final product = perServingProduct(
        perServing: NutritionProfile(
          energy: Energy.kcalValue(150, field: 'energy').valueOrNull,
          proteinG: 2,
          carbohydrateG: 18,
          fatG: 7,
        ),
        unitsPerPackage: 2,
      );

      final result = calculatePackagedFoodNutrition(
        product,
        const WholePackageEaten(),
      );

      expect(result.energy, Energy.kcalValue(300, field: 'x').valueOrNull);
      expect(result.proteinG, 4);
      expect(result.carbohydrateG, 36);
      expect(result.fatG, 14);
    });

    test('satu kemasan penuh tanpa unitsPerPackage diketahui melempar '
        'StateError, bukan diam-diam memakai angka sembarang', () {
      final product = perServingProduct(
        perServing: NutritionProfile(
          energy: Energy.kcalValue(150, field: 'energy').valueOrNull,
        ),
      );

      expect(
        () =>
            calculatePackagedFoodNutrition(product, const WholePackageEaten()),
        throwsStateError,
      );
    });

    test('GramsEaten tidak berlaku untuk basis per sajian', () {
      final product = perServingProduct(
        perServing: NutritionProfile(
          energy: Energy.kcalValue(150, field: 'energy').valueOrNull,
        ),
        unitsPerPackage: 2,
      );

      expect(
        () => calculatePackagedFoodNutrition(product, const GramsEaten(45)),
        throwsArgumentError,
      );
    });

    test('nilai yang tidak diketahui tetap tidak diketahui, bukan nol '
        '(task 3.5)', () {
      final product = perServingProduct(
        perServing: const NutritionProfile(
          energy: null,
          proteinG: 2,
          fatG: null,
        ),
        unitsPerPackage: 2,
      );

      final oneServing = calculatePackagedFoodNutrition(
        product,
        const ServingsEaten(1),
      );
      final wholePackage = calculatePackagedFoodNutrition(
        product,
        const WholePackageEaten(),
      );

      expect(oneServing.energy, isNull);
      expect(oneServing.fatG, isNull);
      expect(wholePackage.energy, isNull);
      expect(wholePackage.fatG, isNull);
    });
  });

  group('basis per 100 g', () {
    test('nilai dihitung dari gram yang benar-benar dimakan, bukan sajian '
        'maupun kemasan (spec, "Label per 100 g"; task 3.3 — angka berbeda '
        'dari kasus per-sajian di atas, bukan kebetulan sama, task 3.6)', () {
      final product = perHundredGramsProduct(
        per100g: NutritionProfile(
          energy: Energy.kcalValue(200, field: 'energy').valueOrNull,
          proteinG: 3,
          carbohydrateG: 22,
          fatG: 9,
          sodiumMg: 480,
        ),
      );

      final result = calculatePackagedFoodNutrition(
        product,
        const GramsEaten(45),
      );

      expect(result.energy, Energy.kcalValue(90, field: 'x').valueOrNull);
      expect(result.proteinG, closeTo(1.35, 1e-9));
      expect(result.carbohydrateG, closeTo(9.9, 1e-9));
      expect(result.fatG, closeTo(4.05, 1e-9));
      expect(result.sodiumMg, closeTo(216, 1e-9));
    });

    test('ServingsEaten dan WholePackageEaten tidak berlaku untuk basis '
        'per 100 g', () {
      final product = perHundredGramsProduct(
        per100g: NutritionProfile(
          energy: Energy.kcalValue(200, field: 'energy').valueOrNull,
        ),
      );

      expect(
        () => calculatePackagedFoodNutrition(product, const ServingsEaten(1)),
        throwsArgumentError,
      );
      expect(
        () =>
            calculatePackagedFoodNutrition(product, const WholePackageEaten()),
        throwsArgumentError,
      );
    });

    test('nilai yang tidak diketahui tetap tidak diketahui setelah '
        'konversi gram (task 3.5)', () {
      final product = perHundredGramsProduct(
        per100g: const NutritionProfile(energy: null, fiberG: null),
      );

      final result = calculatePackagedFoodNutrition(
        product,
        const GramsEaten(45),
      );

      expect(result.energy, isNull);
      expect(result.fiberG, isNull);
    });
  });

  group('pengali untuk DiaryRepository.addEntry (task 7.6)', () {
    test('basis per sajian: pengali sama dengan jumlah sajian atau sajian '
        'per kemasan', () {
      final product = perServingProduct(
        perServing: NutritionProfile(
          energy: Energy.kcalValue(150, field: 'energy').valueOrNull,
        ),
        unitsPerPackage: 2,
      );

      expect(
        packagedFoodQuantityMultiplier(product, const ServingsEaten(2.5)),
        2.5,
      );
      expect(
        packagedFoodQuantityMultiplier(product, const WholePackageEaten()),
        2,
      );
    });

    test('basis per 100 g: pengali adalah gram dibagi 100, supaya '
        'nutritionPerServing (per 100 g) × pengali = total yang dimakan', () {
      final product = perHundredGramsProduct(
        per100g: NutritionProfile(
          energy: Energy.kcalValue(200, field: 'energy').valueOrNull,
        ),
      );

      expect(
        packagedFoodQuantityMultiplier(product, const GramsEaten(45)),
        closeTo(0.45, 1e-9),
      );
    });
  });
}
