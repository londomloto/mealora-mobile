import 'package:mealora/domain/food/food_category.dart';
import 'package:mealora/domain/food/food_provenance.dart';
import 'package:mealora/domain/food/recipe.dart';
import 'package:mealora/domain/food/serving_size.dart';

/// Satu makanan pada katalog perangkat: bawaan (dengan provenans) atau
/// buatan pengguna (spec food-catalog).
final class Food {
  const Food({
    required this.id,
    required this.name,
    required this.category,
    required this.isUserCreated,
    required this.servings,
    this.brand,
    this.provenance,
    this.form,
    this.nutritionOrigin,
  });

  /// Bentuk makanan bila dikurasi (change 015); `null` bila belum diketahui.
  final FoodForm? form;

  /// Asal nilai gizi makanan buatan pengguna (change 016); `null` untuk
  /// makanan bawaan.
  final NutritionOrigin? nutritionOrigin;

  bool get isRecipe => nutritionOrigin == NutritionOrigin.recipe;

  final String id;
  final String name;
  final String? brand;
  final FoodCategory category;

  /// `true` untuk makanan yang dibuat pengguna sendiri — ditandai berbeda
  /// dari makanan bawaan di seluruh tampilan (spec, "Makanan buatan pengguna
  /// SHALL ditandai berbeda").
  final bool isUserCreated;

  /// `null` untuk makanan buatan pengguna. Makanan bawaan SHALL selalu
  /// memiliki provenans lengkap (spec, "Makanan tanpa asal-usul ditolak
  /// masuk katalog").
  final FoodProvenance? provenance;

  final List<ServingSize> servings;

  /// Takaran bawaan — SHALL selalu ada tepat satu per makanan.
  ServingSize get defaultServing =>
      servings.firstWhere((s) => s.isDefault, orElse: () => servings.first);

  ServingSize servingById(String servingId) =>
      servings.firstWhere((s) => s.id == servingId);
}
