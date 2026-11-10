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

  static String mealTimeLabel(MealTime mealTime, AppText text) =>
      switch (mealTime) {
        MealTime.breakfast => text.mealTimeBreakfast,
        MealTime.lunch => text.mealTimeLunch,
        MealTime.snack => text.mealTimeSnack,
        MealTime.dinner => text.mealTimeDinner,
      };
}
