import 'package:mealora/domain/nutrition/activity_level.dart';
import 'package:mealora/domain/nutrition/biological_input.dart';
import 'package:mealora/domain/shared/units.dart';

/// Masukan mentah, belum divalidasi, untuk `NutritionCalculator.estimate`.
///
/// `null` berarti belum diisi pengguna — dibedakan dari nilai tidak masuk
/// akal seperti nol.
final class PhysiologicalFactsInput {
  const PhysiologicalFactsInput({
    this.ageYears,
    this.biologicalInput,
    this.heightCm,
    this.weightKg,
    this.activity,
  });

  final int? ageYears;
  final BiologicalInput? biologicalInput;
  final double? heightCm;
  final double? weightKg;
  final ActivityLevel? activity;
}

/// Fakta fisiologis yang sudah tervalidasi, siap dipakai persamaan energi.
final class PhysiologicalFacts {
  const PhysiologicalFacts({
    required this.ageYears,
    required this.biologicalInput,
    required this.height,
    required this.weight,
    required this.activity,
  });

  final int ageYears;
  final BiologicalInput biologicalInput;
  final Length height;
  final Mass weight;
  final ActivityLevel activity;
}
