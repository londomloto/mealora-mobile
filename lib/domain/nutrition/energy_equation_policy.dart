import 'package:mealora/domain/nutrition/activity_level.dart';

/// Data kebijakan persamaan energi — bukan konstanta yang ditanam di
/// `NutritionCalculator` (change 003, task 2.2/2.3).
///
/// Sumber nilai: `mealora-plans/docs/nutrition-policy-v1.md` Bagian 2.C,
/// dimuat dari berkas `assets/policy/nutrition_policy_np-1.0.0.json`.
final class EnergyEquationPolicy {
  const EnergyEquationPolicy({
    required this.calculatorVersion,
    required this.weightCoefficient,
    required this.heightCoefficient,
    required this.ageCoefficient,
    required this.maleConstant,
    required this.femaleConstant,
    required this.activityMultipliers,
  });

  /// `msj-1.0.0` — persamaan Mifflin–St Jeor (C1/C2/A2).
  final String calculatorVersion;

  final double weightCoefficient;
  final double heightCoefficient;
  final double ageCoefficient;
  final double maleConstant;
  final double femaleConstant;

  /// Pengali aktivitas per [ActivityLevel] (C3a–c).
  final Map<ActivityLevel, double> activityMultipliers;

  /// Nilai `np-1.0.0` saat ini, sesuai tinjauan teknis U1 (C3a–c diubah ke
  /// 1,40 / 1,60 / 1,80).
  static const np100 = EnergyEquationPolicy(
    calculatorVersion: 'msj-1.0.0',
    weightCoefficient: 10,
    heightCoefficient: 6.25,
    ageCoefficient: -5,
    maleConstant: 5,
    femaleConstant: -161,
    activityMultipliers: <ActivityLevel, double>{
      ActivityLevel.sedentary: 1.40,
      ActivityLevel.moderatelyActive: 1.60,
      ActivityLevel.veryActive: 1.80,
    },
  );
}
