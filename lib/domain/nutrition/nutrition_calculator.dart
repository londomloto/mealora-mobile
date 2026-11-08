import 'package:mealora/domain/nutrition/biological_input.dart';
import 'package:mealora/domain/nutrition/energy_equation_policy.dart';
import 'package:mealora/domain/nutrition/nutrition_estimate.dart';
import 'package:mealora/domain/nutrition/physiological_facts.dart';
import 'package:mealora/domain/shared/program_outcome.dart';
import 'package:mealora/domain/shared/reason_code.dart';
import 'package:mealora/domain/shared/units.dart';

/// Komponen Dart murni yang memperkirakan energi istirahat dan pengeluaran
/// energi harian dari fakta fisiologis netral.
///
/// Tidak mengetahui kode program, status program, defisit, surplus, maupun
/// kebijakan `ProgramEngine` apa pun (assessment §39, Design D1). Satu-
/// satunya kebijakan yang dipakai adalah [EnergyEquationPolicy] — persamaan
/// energi itu sendiri, bukan kebijakan target.
final class NutritionCalculator {
  const NutritionCalculator(this.policy);

  final EnergyEquationPolicy policy;

  /// Rentang usia yang masih masuk akal secara fisik untuk persamaan ini.
  /// Ini bukan rentang kelayakan program (itu milik `ProgramEngine`).
  static const _minAgeYears = 1;
  static const _maxAgeYears = 120;

  ProgramOutcome<NutritionEstimate> estimate(PhysiologicalFactsInput input) {
    final missingFields = <String>[];

    if (input.ageYears == null) {
      missingFields.add('age_years');
    } else if (input.ageYears! < _minAgeYears ||
        input.ageYears! > _maxAgeYears) {
      missingFields.add('age_years');
    }

    if (input.biologicalInput == null) {
      missingFields.add('biological_input');
    }

    Length? height;
    if (input.heightCm == null) {
      missingFields.add('height_cm');
    } else {
      final result = Length.cmValue(input.heightCm!, field: 'height_cm');
      if (result.isErr) {
        missingFields.add('height_cm');
      } else {
        height = result.valueOrNull;
      }
    }

    Mass? weight;
    if (input.weightKg == null) {
      missingFields.add('weight_kg');
    } else {
      final result = Mass.kgValue(input.weightKg!, field: 'weight_kg');
      if (result.isErr) {
        missingFields.add('weight_kg');
      } else {
        weight = result.valueOrNull;
      }
    }

    if (input.activity == null) {
      missingFields.add('activity_level');
    }

    if (missingFields.isNotEmpty) {
      return NeedsUserCorrection<NutritionEstimate>(
        reasonCode: ReasonCode.missingRequiredInput,
        missingFields: missingFields,
      );
    }

    final facts = PhysiologicalFacts(
      ageYears: input.ageYears!,
      biologicalInput: input.biologicalInput!,
      height: height!,
      weight: weight!,
      activity: input.activity!,
    );

    return Approved<NutritionEstimate>(_calculate(facts));
  }

  NutritionEstimate _calculate(PhysiologicalFacts facts) {
    final constant = switch (facts.biologicalInput) {
      BiologicalInput.male => policy.maleConstant,
      BiologicalInput.female => policy.femaleConstant,
    };

    final restingEnergyKcal =
        policy.weightCoefficient * facts.weight.kg +
        policy.heightCoefficient * facts.height.cm +
        policy.ageCoefficient * facts.ageYears +
        constant;

    final multiplier = policy.activityMultipliers[facts.activity]!;
    final totalDailyEnergyKcal = restingEnergyKcal * multiplier;

    return NutritionEstimate(
      restingEnergy: Energy.kcalValue(
        restingEnergyKcal,
        field: 'resting_energy',
      ).valueOrNull!,
      totalDailyEnergy: Energy.kcalValue(
        totalDailyEnergyKcal,
        field: 'total_daily_energy',
      ).valueOrNull!,
      calculatorVersion: policy.calculatorVersion,
    );
  }
}
