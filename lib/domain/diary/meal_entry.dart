import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/domain/food/food.dart';
import 'package:mealora/domain/food/meal_time.dart';
import 'package:mealora/domain/food/nutrition_profile.dart';
import 'package:mealora/domain/food/serving_size.dart';

/// Satu catatan makan: satu makanan, dicatat pada satu waktu makan dan satu
/// tanggal lokal (spec food-diary, "Empat waktu makan").
///
/// Membekukan potret nilai gizi per takaran pada saat pencatatan (Design D1,
/// change 007) — rujukan ke makanan dan takaran ([foodId]/[servingId])
/// tetap disimpan untuk penelusuran, tetapi [nutritionPerServing] adalah
/// sumber nilai saat menampilkan riwayat, bukan katalog.
final class MealEntry {
  const MealEntry({
    required this.id,
    required this.profileId,
    required this.localDate,
    required this.mealTime,
    required this.foodId,
    required this.servingId,
    required this.foodNameSnapshot,
    required this.servingLabelSnapshot,
    required this.quantity,
    required this.nutritionPerServing,
    required this.createdAt,
  });

  final String id;
  final String profileId;
  final LocalDate localDate;
  final MealTime mealTime;
  final String foodId;
  final String servingId;

  /// Nama makanan pada saat dicatat — tidak berubah bila makanan disunting
  /// atau dihapus dari katalog kemudian.
  final String foodNameSnapshot;

  /// Label takaran pada saat dicatat.
  final String servingLabelSnapshot;

  /// Jumlah takaran. SHALL lebih besar dari nol.
  final double quantity;

  /// Nilai gizi beku PER TAKARAN (bukan dikalikan [quantity]) — lihat
  /// [totalNutrition].
  final NutritionProfile nutritionPerServing;

  final DateTime createdAt;

  /// Nilai gizi total catatan ini: potret per takaran dikalikan [quantity].
  NutritionProfile get totalNutrition => nutritionPerServing.scaledBy(quantity);
}

/// Satu makanan yang akan ditambahkan lewat `DiaryRepository.addEntries`
/// (spec food-photo-input, "Pencatatan menghasilkan catatan per komponen",
/// change 011) — bentuk masukan untuk [MealEntry] yang belum punya `id`,
/// sama persis dengan parameter `addEntry`, dikelompokkan supaya beberapa
/// catatan dapat ditulis dalam satu transaksi atomik.
final class NewMealEntry {
  const NewMealEntry({
    required this.food,
    required this.serving,
    required this.quantity,
  });

  final Food food;
  final ServingSize serving;

  /// SHALL lebih besar dari nol.
  final double quantity;
}
