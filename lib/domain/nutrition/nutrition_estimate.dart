import 'package:mealora/domain/nutrition/nutrition_assumption.dart';
import 'package:mealora/domain/shared/units.dart';

/// Perkiraan energi netral, tanpa pengetahuan program atau kebijakan
/// defisit/surplus (assessment §39).
final class NutritionEstimate {
  const NutritionEstimate({
    required this.restingEnergy,
    required this.totalDailyEnergy,
    required this.calculatorVersion,
    this.assumptions = const <NutritionAssumption>{
      NutritionAssumption.estimateNotMeasurement,
    },
  });

  /// Energi istirahat, nilai penuh tanpa pembulatan (Lampiran A langkah 2).
  final Energy restingEnergy;

  /// Pengeluaran energi harian, nilai penuh tanpa pembulatan (Lampiran A
  /// langkah 3).
  final Energy totalDailyEnergy;

  final String calculatorVersion;

  final Set<NutritionAssumption> assumptions;

  @override
  String toString() =>
      'NutritionEstimate(rmr: $restingEnergy, tdee: $totalDailyEnergy, '
      'version: $calculatorVersion)';
}
