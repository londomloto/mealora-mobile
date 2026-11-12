import 'package:mealora/domain/food/food.dart';
import 'package:mealora/domain/food/food_category.dart';
import 'package:mealora/domain/food/nutrition_profile.dart';
import 'package:mealora/domain/food/recent_food.dart';
import 'package:mealora/domain/food/recipe.dart';
import 'package:mealora/domain/food/recipe_calculator.dart';

/// Satu takaran yang akan dibuat bersama sebuah makanan buatan pengguna.
final class ServingSizeInput {
  const ServingSizeInput({
    required this.label,
    required this.amount,
    required this.unit,
    required this.nutrition,
    this.gramEquivalent,
  });

  final String label;
  final double amount;
  final String unit;
  final double? gramEquivalent;
  final NutritionProfile nutrition;
}

/// Kontrak katalog makanan (change 007) — diimplementasikan oleh Drift.
///
/// `Future`-based, selaras `ProgramRepository` (change 004, Design D11):
/// koneksi Drift aplikasi berjalan di isolate/web worker terpisah.
abstract interface class FoodRepository {
  /// Makanan menurut pengenalnya, termasuk seluruh takaran dan nilai
  /// gizinya. `null` bila tidak ada atau sudah ditandai terhapus.
  Future<Food?> findById(String id);

  /// Mencari makanan menurut [query]: mengabaikan huruf besar-kecil,
  /// mencocokkan bagian mana pun dari nama, mendahulukan kecocokan di awal
  /// nama (Design D3). [query] kosong mengembalikan daftar kosong — bagian
  /// "terakhir dicatat" dipakai sebelum pengguna mengetik.
  Future<List<Food>> search(String query);

  /// Makanan yang terakhir dicatat [profileId], beserta takaran terakhir
  /// yang dipakai untuk tiap makanan, terbaru lebih dulu (Design D4).
  /// Daftar kosong untuk pengguna yang belum pernah mencatat.
  Future<List<RecentFood>> recentlyLogged(String profileId, {int limit = 10});

  /// Membuat makanan buatan pengguna baru. Mengembalikan [Food] tersimpan.
  Future<Food> createUserFood({
    required String name,
    required FoodCategory category,
    required ServingSizeInput serving,
  });

  /// Menyunting nilai makanan buatan pengguna — SHALL TIDAK mengubah
  /// catatan yang sudah pernah dibuat dengan makanan ini (spec food-catalog,
  /// "Pembaruan katalog tidak mengubah catatan lama").
  Future<Food> updateUserFood(
    String foodId, {
    required String name,
    required ServingSizeInput serving,
  });

  /// Membuat makanan resep beserta bahannya dalam satu transaksi (change
  /// 016, task 2.1–2.2). [perServing] adalah nilai yang ditinjau pengguna —
  /// hasil hitungan, atau koreksinya bila [origin] `manual`. Takaran yang
  /// dibuat: "1 porsi" (bawaan), ditambah "100 g" bila berat jadi diisi.
  Future<Food> createRecipeFood({
    required String name,
    required FoodCategory category,
    required List<RecipeIngredientInput> ingredients,
    required RecipeYield recipeYield,
    required NutritionProfile perServing,
    required NutritionOrigin origin,
  });

  /// Menyunting makanan resep: mengganti bahan, hasil resep, dan nilai gizi
  /// takarannya. Catatan makan lama SHALL TIDAK berubah.
  Future<Food> updateRecipeFood(
    String foodId, {
    required String name,
    required List<RecipeIngredientInput> ingredients,
    required RecipeYield recipeYield,
    required NutritionProfile perServing,
    required NutritionOrigin origin,
  });

  /// Resep tersimpan sebuah makanan, dengan makanan & takaran bahannya yang
  /// berlaku saat ini. `null` bila makanan itu tidak punya resep.
  Future<SavedRecipe?> recipeOf(String foodId);

  /// Menghapus (lunak) makanan buatan pengguna. Melempar
  /// [FoodInUseAsIngredientException] bila makanan dipakai sebagai bahan
  /// resep yang masih ada (task 2.3).
  Future<void> deleteUserFood(String foodId);
}
