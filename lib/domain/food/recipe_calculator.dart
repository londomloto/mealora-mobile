import 'package:mealora/domain/food/nutrition_profile.dart';
import 'package:mealora/domain/food/serving_size.dart';
import 'package:mealora/domain/shared/units.dart';

/// Zat gizi yang dihitung kalkulator resep, urut seperti tampilan.
enum RecipeNutrient { energy, protein, carbohydrate, fat, fiber, sugar, sodium }

/// Jumlah satu bahan resep: dalam gram, atau kelipatan takaran bahan
/// (spec custom-food-recipe, "Gizi dihitung dari bahan dan jumlahnya").
sealed class RecipeAmount {
  const RecipeAmount();

  double get value;
}

final class RecipeGrams extends RecipeAmount {
  const RecipeGrams(this.value);

  @override
  final double value;
}

final class RecipeServingMultiple extends RecipeAmount {
  const RecipeServingMultiple(this.value);

  @override
  final double value;
}

/// Satu bahan resep. [serving] `null` berarti bahan tanpa data gizi (nama
/// bebas): seluruh zat gizinya belum diketahui dan TIDAK diperkirakan.
final class RecipeIngredient {
  const RecipeIngredient({
    required this.label,
    required this.amount,
    this.serving,
  });

  final String label;
  final ServingSize? serving;
  final RecipeAmount amount;

  bool get hasNutritionData => serving != null;
}

/// Hasil resep: jumlah porsi (wajib) dan berat jadi dalam gram (opsional).
final class RecipeYield {
  const RecipeYield({required this.servings, this.finishedGrams});

  final double servings;
  final double? finishedGrams;
}

/// Alasan masukan resep tidak sah.
enum RecipeInputError {
  /// Jumlah bahan, porsi, atau berat jadi ≤ 0 atau bukan angka.
  notPositive,

  /// Jumlah gram untuk takaran tanpa padanan berat.
  gramsWithoutWeight,
}

/// Validasi masukan untuk UI dan kalkulator — `null` bila sah.
abstract final class RecipeValidation {
  static RecipeInputError? positive(double? value) =>
      value == null || !value.isFinite || value <= 0
      ? RecipeInputError.notPositive
      : null;

  static RecipeInputError? ingredient(RecipeIngredient ingredient) {
    final error = positive(ingredient.amount.value);
    if (error != null) {
      return error;
    }
    final serving = ingredient.serving;
    if (ingredient.amount is RecipeGrams &&
        serving != null &&
        !canUseGrams(serving)) {
      return RecipeInputError.gramsWithoutWeight;
    }
    return null;
  }

  /// Masukan gram hanya untuk takaran yang padanan beratnya diketahui.
  static bool canUseGrams(ServingSize serving) =>
      (serving.gramEquivalent ?? 0) > 0;
}

/// Kontribusi satu bahan terhadap total resep.
final class IngredientContribution {
  const IngredientContribution({
    required this.ingredient,
    required this.nutrition,
  });

  final RecipeIngredient ingredient;

  /// Gizi bahan ini sesuai jumlahnya; seluruhnya belum diketahui untuk
  /// bahan tanpa data gizi.
  final NutritionProfile nutrition;
}

/// Hasil hitungan resep (Design D1, change 016).
final class RecipeCalculation {
  const RecipeCalculation({
    required this.contributions,
    required this.total,
    required this.perServing,
    required this.per100gFinished,
    required this.incomplete,
  });

  final List<IngredientContribution> contributions;

  /// Jumlah dari bahan yang diketahui. Zat yang tidak diketahui pada SEMUA
  /// bahan bernilai `null`; zat yang tidak diketahui pada sebagian bahan
  /// tetap berangka tapi tercantum di [incomplete].
  final NutritionProfile total;
  final NutritionProfile perServing;

  /// `null` bila berat jadi tidak diisi.
  final NutritionProfile? per100gFinished;

  /// Zat gizi yang tidak lengkap → label bahan penyebabnya, urut resep.
  final Map<RecipeNutrient, List<String>> incomplete;

  bool get isComplete => incomplete.isEmpty;

  bool isIncomplete(RecipeNutrient nutrient) =>
      incomplete.containsKey(nutrient);

  /// Label bahan yang menyebabkan total mana pun tidak lengkap, tanpa duplikat.
  List<String> get incompleteIngredients =>
      incompleteIngredientsFor(RecipeNutrient.values);

  /// Seperti [incompleteIngredients], terbatas pada [nutrients] (mis. zat
  /// yang ditampilkan layar), urut resep.
  List<String> incompleteIngredientsFor(Iterable<RecipeNutrient> nutrients) {
    final wanted = nutrients.toSet();
    final labels = <String>{
      for (final e in incomplete.entries)
        if (wanted.contains(e.key)) ...e.value,
    };
    return <String>[
      for (final c in contributions)
        if (labels.remove(c.ingredient.label)) c.ingredient.label,
    ];
  }

  /// [perServing] dengan zat tidak lengkap di luar [kept] dijadikan belum
  /// diketahui — untuk disimpan, karena penanda tidak lengkap tidak ikut
  /// tersimpan dan angka parsial akan tampak lengkap di kemudian hari.
  NutritionProfile perServingForStorage(Set<RecipeNutrient> kept) {
    bool drop(RecipeNutrient n) => isIncomplete(n) && !kept.contains(n);
    final p = perServing;
    return NutritionProfile(
      energy: drop(RecipeNutrient.energy) ? null : p.energy,
      proteinG: drop(RecipeNutrient.protein) ? null : p.proteinG,
      carbohydrateG: drop(RecipeNutrient.carbohydrate) ? null : p.carbohydrateG,
      fatG: drop(RecipeNutrient.fat) ? null : p.fatG,
      fiberG: drop(RecipeNutrient.fiber) ? null : p.fiberG,
      sugarG: drop(RecipeNutrient.sugar) ? null : p.sugarG,
      sodiumMg: drop(RecipeNutrient.sodium) ? null : p.sodiumMg,
    );
  }
}

/// Zat gizi yang ditampilkan dan dapat dikoreksi di layar makanan sendiri.
const Set<RecipeNutrient> kRecipeDisplayedNutrients = <RecipeNutrient>{
  RecipeNutrient.energy,
  RecipeNutrient.protein,
  RecipeNutrient.carbohydrate,
  RecipeNutrient.fat,
};

/// Fungsi murni penghitung gizi resep — tanpa I/O, tanpa pembulatan antara.
abstract final class RecipeCalculator {
  /// Menghitung resep. Melempar [ArgumentError] bila masukan tidak sah;
  /// UI memvalidasi lebih dulu lewat [RecipeValidation].
  static RecipeCalculation calculate(
    List<RecipeIngredient> ingredients,
    RecipeYield recipeYield,
  ) {
    if (RecipeValidation.positive(recipeYield.servings) != null) {
      throw ArgumentError.value(recipeYield.servings, 'servings');
    }
    final finished = recipeYield.finishedGrams;
    if (finished != null && RecipeValidation.positive(finished) != null) {
      throw ArgumentError.value(finished, 'finishedGrams');
    }

    final contributions = <IngredientContribution>[];
    for (final ingredient in ingredients) {
      final error = RecipeValidation.ingredient(ingredient);
      if (error != null) {
        throw ArgumentError.value(ingredient.label, 'ingredient', '$error');
      }
      contributions.add(
        IngredientContribution(
          ingredient: ingredient,
          nutrition: contributionOf(ingredient),
        ),
      );
    }

    final incomplete = <RecipeNutrient, List<String>>{};
    final totals = <RecipeNutrient, double?>{};
    for (final nutrient in RecipeNutrient.values) {
      double? sum;
      for (final c in contributions) {
        final value = _read(c.nutrition, nutrient);
        if (value == null) {
          (incomplete[nutrient] ??= <String>[]).add(c.ingredient.label);
        } else {
          sum = (sum ?? 0) + value;
        }
      }
      totals[nutrient] = sum;
    }

    final total = _profile(totals);
    return RecipeCalculation(
      contributions: List.unmodifiable(contributions),
      total: total,
      perServing: total.scaledBy(1 / recipeYield.servings),
      per100gFinished: finished == null ? null : total.scaledBy(100 / finished),
      incomplete: Map.unmodifiable(incomplete),
    );
  }

  /// Gizi satu bahan: gram → nutrisi_takaran × gram / gramEquivalent;
  /// kelipatan → nutrisi_takaran × kelipatan.
  static NutritionProfile contributionOf(RecipeIngredient ingredient) {
    final serving = ingredient.serving;
    if (serving == null) {
      return NutritionProfile.unknown;
    }
    return switch (ingredient.amount) {
      RecipeGrams(:final value) => serving.nutrition.scaledBy(
        value / serving.gramEquivalent!,
      ),
      RecipeServingMultiple(:final value) => serving.nutrition.scaledBy(value),
    };
  }

  static double? _read(NutritionProfile p, RecipeNutrient n) => switch (n) {
    RecipeNutrient.energy => p.energy?.kcal,
    RecipeNutrient.protein => p.proteinG,
    RecipeNutrient.carbohydrate => p.carbohydrateG,
    RecipeNutrient.fat => p.fatG,
    RecipeNutrient.fiber => p.fiberG,
    RecipeNutrient.sugar => p.sugarG,
    RecipeNutrient.sodium => p.sodiumMg,
  };

  static NutritionProfile _profile(Map<RecipeNutrient, double?> v) {
    final kcal = v[RecipeNutrient.energy];
    return NutritionProfile(
      energy: kcal == null ? null : Energy.zero + _energy(kcal),
      proteinG: v[RecipeNutrient.protein],
      carbohydrateG: v[RecipeNutrient.carbohydrate],
      fatG: v[RecipeNutrient.fat],
      fiberG: v[RecipeNutrient.fiber],
      sugarG: v[RecipeNutrient.sugar],
      sodiumMg: v[RecipeNutrient.sodium],
    );
  }

  // `Energy.kcalValue` menolak > 20.000 kkal; total resep besar tetap sah,
  // jadi dibangun lewat perkalian dari 1 kkal.
  static Energy _energy(double kcal) =>
      Energy.kcalValue(1, field: 'energy').valueOrNull!.times(kcal);
}
