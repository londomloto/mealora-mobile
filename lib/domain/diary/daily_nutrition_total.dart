import 'package:mealora/domain/food/nutrition_profile.dart';

/// Ringkasan gizi satu hari, dihitung dari catatan — tidak pernah disimpan
/// sebagai kolom tersendiri (Design D7, change 007).
final class DailyNutritionTotal {
  const DailyNutritionTotal({
    required this.nutrition,
    required this.loggedMealsCount,
  });

  /// Seluruhnya belum diketahui untuk hari tanpa catatan (spec
  /// daily-dashboard, "Hari tanpa catatan dinyatakan belum diketahui").
  static const DailyNutritionTotal empty = DailyNutritionTotal(
    nutrition: NutritionProfile.unknown,
    loggedMealsCount: 0,
  );

  final NutritionProfile nutrition;

  /// Jumlah waktu makan yang punya sekurang-kurangnya satu catatan hari ini.
  final int loggedMealsCount;

  bool get hasAnyEntries => loggedMealsCount > 0;
}
