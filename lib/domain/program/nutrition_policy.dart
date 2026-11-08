import 'package:mealora/domain/program/program_code.dart';

/// Status persetujuan kebijakan. Selama `draft`, `ProgramEngine` SHALL
/// mengembalikan `missing_validated_policy` untuk seluruh usulan target
/// (Design D2, assessment §39).
enum PolicyApprovalStatus { draft, approved }

/// Rentang usia dan ambang skrining kelayakan (Bagian 2.B).
final class EligibilityPolicy {
  const EligibilityPolicy({
    required this.ageMinInclusive,
    required this.ageMaxInclusive,
    required this.bmiUnderweightBelow,
    required this.bmiAboveSupportedAtOrAbove,
    required this.unintendedChangeThresholdPercent,
    required this.unintendedChangeWindowDays,
  });

  final int ageMinInclusive;
  final int ageMaxInclusive;
  final double bmiUnderweightBelow;
  final double bmiAboveSupportedAtOrAbove;
  final double unintendedChangeThresholdPercent;
  final int unintendedChangeWindowDays;
}

/// Kebijakan target energi Turun Berat (D1–D7).
final class WeightLossEnergyPolicy {
  const WeightLossEnergyPolicy({
    required this.deficitFractionOfTdee,
    required this.deficitMinKcal,
    required this.deficitMaxKcal,
    required this.floorAbsoluteFemaleKcal,
    required this.floorAbsoluteMaleKcal,
    required this.hardFloorKcal,
    required this.remainingDeficitMinKcal,
  });

  final double deficitFractionOfTdee;
  final double deficitMinKcal;
  final double deficitMaxKcal;
  final double floorAbsoluteFemaleKcal;
  final double floorAbsoluteMaleKcal;
  final double hardFloorKcal;
  final double remainingDeficitMinKcal;
}

/// Kebijakan target energi Naik Berat (D8–D9).
final class WeightGainEnergyPolicy {
  const WeightGainEnergyPolicy({
    required this.surplusFractionOfTdee,
    required this.surplusMinKcal,
    required this.surplusMaxKcal,
  });

  final double surplusFractionOfTdee;
  final double surplusMinKcal;
  final double surplusMaxKcal;
}

/// Kebijakan pita toleransi Pertahankan (D10–D11).
final class MaintenanceEnergyPolicy {
  const MaintenanceEnergyPolicy({
    required this.toleranceBandFraction,
    required this.toleranceBandMinKcal,
  });

  final double toleranceBandFraction;
  final double toleranceBandMinKcal;
}

/// Batas laju perubahan berat (Bagian 2.E).
final class WeightChangeRatePolicy {
  const WeightChangeRatePolicy({
    required this.weightLossMinKgPerWeek,
    required this.weightLossMaxKgPerWeek,
    required this.weightLossMaxFractionOfBodyWeightPerWeek,
    required this.weightGainMinKgPerWeek,
    required this.weightGainMaxKgPerWeek,
  });

  final double weightLossMinKgPerWeek;
  final double weightLossMaxKgPerWeek;
  final double weightLossMaxFractionOfBodyWeightPerWeek;
  final double weightGainMinKgPerWeek;
  final double weightGainMaxKgPerWeek;
}

/// Ambang berat tujuan (E7).
final class TargetWeightPolicy {
  const TargetWeightPolicy({required this.minBmi});

  final double minBmi;
}

/// Kebijakan protein, lemak, karbohidrat, dan serat (Bagian 2.F).
final class MacronutrientPolicy {
  const MacronutrientPolicy({
    required this.referenceWeightBmiCap,
    required this.proteinGPerKgReferenceWeight,
    required this.proteinMinFractionOfEnergy,
    required this.proteinMaxFractionOfEnergy,
    required this.proteinAbsoluteMinGPerKg,
    required this.fatFractionOfEnergy,
    required this.fatMinFractionOfEnergy,
    required this.fatMaxFractionOfEnergy,
    required this.carbohydrateTargetMinFractionOfEnergy,
    required this.fiberGPer1000Kcal,
    required this.fiberMinG,
    required this.fiberMaxG,
    required this.adjustedFatFractionOfEnergy,
    required this.adjustedProteinGPerKgReferenceWeight,
    required this.kcalPerGramProtein,
    required this.kcalPerGramCarbohydrate,
    required this.kcalPerGramFat,
  });

  final double referenceWeightBmiCap;
  final Map<ProgramCode, double> proteinGPerKgReferenceWeight;
  final double proteinMinFractionOfEnergy;
  final double proteinMaxFractionOfEnergy;
  final double proteinAbsoluteMinGPerKg;
  final double fatFractionOfEnergy;
  final double fatMinFractionOfEnergy;
  final double fatMaxFractionOfEnergy;
  final double carbohydrateTargetMinFractionOfEnergy;
  final double fiberGPer1000Kcal;
  final double fiberMinG;
  final double fiberMaxG;

  /// F11 langkah 1: lemak diturunkan ke pecahan ini.
  final double adjustedFatFractionOfEnergy;

  /// F11 langkah 2: protein diturunkan ke g/kg berat acuan ini.
  final double adjustedProteinGPerKgReferenceWeight;

  final double kcalPerGramProtein;
  final double kcalPerGramCarbohydrate;
  final double kcalPerGramFat;
}

/// Kebijakan gizi berversi `np-1.0.0`.
///
/// Seluruh angka hidup di sini, bukan ditanam di `ProgramEngine` (Design
/// D2/D10, task 5.1). Sumber: `mealora-plans/docs/nutrition-policy-v1.md`.
final class NutritionPolicy {
  const NutritionPolicy({
    required this.policyVersion,
    required this.status,
    required this.eligibility,
    required this.weightLossEnergy,
    required this.weightGainEnergy,
    required this.maintenanceEnergy,
    required this.weightChangeRate,
    required this.targetWeight,
    required this.macronutrients,
  });

  final String policyVersion;
  final PolicyApprovalStatus status;
  final EligibilityPolicy eligibility;
  final WeightLossEnergyPolicy weightLossEnergy;
  final WeightGainEnergyPolicy weightGainEnergy;
  final MaintenanceEnergyPolicy maintenanceEnergy;
  final WeightChangeRatePolicy weightChangeRate;
  final TargetWeightPolicy targetWeight;
  final MacronutrientPolicy macronutrients;

  /// Nilai `np-1.0.0`, dengan [status] diberikan pemanggil — mesin tidak
  /// pernah memutuskan sendiri apakah kebijakan sudah disetujui.
  static NutritionPolicy np100({required PolicyApprovalStatus status}) =>
      NutritionPolicy(
        policyVersion: 'np-1.0.0',
        status: status,
        eligibility: const EligibilityPolicy(
          ageMinInclusive: 19,
          ageMaxInclusive: 64,
          bmiUnderweightBelow: 18.5,
          bmiAboveSupportedAtOrAbove: 37.5,
          unintendedChangeThresholdPercent: 5.0,
          unintendedChangeWindowDays: 30,
        ),
        weightLossEnergy: const WeightLossEnergyPolicy(
          deficitFractionOfTdee: 0.20,
          deficitMinKcal: 300,
          deficitMaxKcal: 750,
          floorAbsoluteFemaleKcal: 1200,
          floorAbsoluteMaleKcal: 1500,
          hardFloorKcal: 800,
          remainingDeficitMinKcal: 300,
        ),
        weightGainEnergy: const WeightGainEnergyPolicy(
          surplusFractionOfTdee: 0.10,
          surplusMinKcal: 250,
          surplusMaxKcal: 500,
        ),
        maintenanceEnergy: const MaintenanceEnergyPolicy(
          toleranceBandFraction: 0.05,
          toleranceBandMinKcal: 100,
        ),
        weightChangeRate: const WeightChangeRatePolicy(
          weightLossMinKgPerWeek: 0.25,
          weightLossMaxKgPerWeek: 0.75,
          weightLossMaxFractionOfBodyWeightPerWeek: 0.0075,
          weightGainMinKgPerWeek: 0.125,
          weightGainMaxKgPerWeek: 0.5,
        ),
        targetWeight: const TargetWeightPolicy(minBmi: 18.5),
        macronutrients: const MacronutrientPolicy(
          referenceWeightBmiCap: 23.0,
          proteinGPerKgReferenceWeight: <ProgramCode, double>{
            ProgramCode.weightLoss: 1.6,
            ProgramCode.weightGain: 1.4,
            ProgramCode.maintenance: 1.4,
            ProgramCode.healthyEating: 1.4,
          },
          proteinMinFractionOfEnergy: 0.10,
          proteinMaxFractionOfEnergy: 0.35,
          proteinAbsoluteMinGPerKg: 0.8,
          fatFractionOfEnergy: 0.25,
          fatMinFractionOfEnergy: 0.20,
          fatMaxFractionOfEnergy: 0.35,
          carbohydrateTargetMinFractionOfEnergy: 0.45,
          fiberGPer1000Kcal: 14,
          fiberMinG: 20,
          fiberMaxG: 38,
          adjustedFatFractionOfEnergy: 0.20,
          adjustedProteinGPerKgReferenceWeight: 1.2,
          kcalPerGramProtein: 4,
          kcalPerGramCarbohydrate: 4,
          kcalPerGramFat: 9,
        ),
      );
}
