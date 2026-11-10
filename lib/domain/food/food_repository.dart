import 'package:mealora/domain/food/food.dart';
import 'package:mealora/domain/food/food_category.dart';
import 'package:mealora/domain/food/nutrition_profile.dart';
import 'package:mealora/domain/food/recent_food.dart';

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
}
