import 'package:mealora/core/format/id_formatters.dart';
import 'package:mealora/domain/food/meal_time.dart';
import 'package:mealora/domain/shared/units.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// Pembantu format bersama untuk layar katalog dan buku harian (change 007)
/// — satu tempat yang menegakkan "nilai belum diketahui tidak pernah
/// menjadi nol" (Design D9) di seluruh tampilan.
abstract final class DiaryFormat {
  static String kcal(Energy? energy, AppText text) => energy == null
      ? text.todayConsumedUnknown
      : '${IdFormat.integer(energy.kcal)} ${text.unitKilocalorie}';

  static String grams(double? value, AppText text) => value == null
      ? text.nutrientValueUnknown
      : '${IdFormat.decimal(value)} ${text.unitGram}';

  /// Jumlah sebuah catatan untuk ditampilkan: takaran berat murni
  /// ("100 g" × 1,5) menjadi "150 g" (change 015, design.md D5); takaran
  /// lain "1,5 × 1 centong", atau labelnya saja bila jumlahnya 1.
  static String entryAmount(String servingLabel, double quantity) {
    final weight = RegExp(
      r'^(\d+(?:[.,]\d+)?)\s*(g|ml)$',
    ).firstMatch(servingLabel.trim());
    if (weight != null) {
      final base = double.parse(weight.group(1)!.replaceAll(',', '.'));
      return '${_compact(base * quantity)} ${weight.group(2)}';
    }
    if (quantity == 1) return servingLabel;
    return '${_compact(quantity)} × $servingLabel';
  }

  /// Angka tanpa ",0" untuk bilangan bulat (150, 1,5).
  static String _compact(double value) =>
      IdFormat.decimal(value, decimals: value == value.roundToDouble() ? 0 : 1);

  static String mealTimeLabel(MealTime mealTime, AppText text) =>
      switch (mealTime) {
        MealTime.breakfast => text.mealTimeBreakfast,
        MealTime.lunch => text.mealTimeLunch,
        MealTime.snack => text.mealTimeSnack,
        MealTime.dinner => text.mealTimeDinner,
      };
}
