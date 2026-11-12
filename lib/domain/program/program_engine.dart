import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/domain/nutrition/biological_input.dart';
import 'package:mealora/domain/nutrition/nutrition_estimate.dart';
import 'package:mealora/domain/program/declared_condition.dart';
import 'package:mealora/domain/program/eligibility_gate.dart';
import 'package:mealora/domain/program/energy_target_result.dart';
import 'package:mealora/domain/program/nutrition_policy.dart';
import 'package:mealora/domain/program/pace_evaluation.dart';
import 'package:mealora/domain/program/profile_screening_facts.dart';
import 'package:mealora/domain/program/program_code.dart';
import 'package:mealora/domain/program/program_specific_input.dart';
import 'package:mealora/domain/program/program_target_proposal.dart';
import 'package:mealora/domain/shared/program_outcome.dart';
import 'package:mealora/domain/shared/program_warning.dart';
import 'package:mealora/domain/shared/reason_code.dart';
import 'package:mealora/domain/shared/rounding.dart';
import 'package:mealora/domain/shared/units.dart';

/// Kunci `details` penolakan `targetWeightOutOfRange` yang membedakan
/// sub-kasusnya (change 019) — kode alasannya tetap satu.
const targetWeightViolationKey = 'violation';

/// Sub-kasus `targetWeightOutOfRange` (change 019).
enum TargetWeightViolation { belowMinBmi, wrongDirection }

const _weightChangingPrograms = <ProgramCode>{
  ProgramCode.weightLoss,
  ProgramCode.weightGain,
};

/// Mesin kebijakan dan kelayakan program — murni Dart, deterministik.
///
/// Menerima fakta profil, kode program, masukan khusus program, dan hasil
/// `NutritionCalculator`, lalu mengembalikan proposal target atau keadaan
/// tidak-disetujui bertipe (Design D1, assessment §39).
final class ProgramEngine {
  const ProgramEngine(this.policy);

  final NutritionPolicy policy;

  ProgramOutcome<ProgramTargetProposal> proposeTarget({
    required ProgramCode program,
    required int ageYears,
    required BiologicalInput biologicalInput,
    required Length height,
    required Mass currentWeight,
    required NutritionEstimate estimate,
    required ProfileScreeningFacts screening,
    required ProgramSpecificInput specific,
    required LocalDate asOfDate,
    required bool programRequiresTargetWeight,
    required bool programRequiresHabitFocus,
  }) {
    if (policy.status != PolicyApprovalStatus.approved) {
      return const MissingValidatedPolicy<ProgramTargetProposal>();
    }

    final missingFields = <String>[
      if (programRequiresTargetWeight && specific.targetWeight == null)
        'target_weight_kg',
      if (programRequiresHabitFocus && specific.habitFocus == null)
        'habit_focus',
    ];
    if (missingFields.isNotEmpty) {
      return NeedsUserCorrection<ProgramTargetProposal>(
        reasonCode: ReasonCode.missingRequiredInput,
        missingFields: missingFields,
      );
    }

    final ageGate = checkAge(
      ageYears: ageYears,
      program: program,
      policy: policy.eligibility,
    );
    switch (ageGate) {
      case EligibilityRejected():
        return _toOutcome(ageGate);
      case EligibilityPassWithoutTargets():
        return Approved<ProgramTargetProposal>(
          _withoutTargets(program: program, estimate: estimate),
        );
      case EligibilityPass():
    }

    final pregnancyGate = checkPregnancyOrLactation(
      isPregnantOrLactating: screening.isPregnantOrLactating,
      program: program,
    );
    if (pregnancyGate is EligibilityRejected) {
      return _toOutcome(pregnancyGate);
    }

    final bmi = computeBmi(currentWeight, height);
    final bmiGate = checkBmiRange(
      bmi: bmi,
      program: program,
      policy: policy.eligibility,
    );
    if (bmiGate is EligibilityRejected) {
      return _toOutcome(bmiGate);
    }

    final conditionGate = checkDeclaredConditions(
      conditions: screening.declaredConditions,
      program: program,
    );
    switch (conditionGate) {
      case EligibilityRejected():
        return _toOutcome(conditionGate);
      case EligibilityPassWithoutTargets():
        return Approved<ProgramTargetProposal>(
          _withoutTargets(program: program, estimate: estimate),
        );
      case EligibilityPass():
    }

    final rapidChangeGate = checkRapidWeightChange(
      change: screening.unintendedWeightChange,
      policy: policy.eligibility,
    );
    if (rapidChangeGate is EligibilityRejected) {
      return _toOutcome(rapidChangeGate);
    }

    if (specific.targetWeight != null) {
      final targetWeightGate = checkTargetWeightRange(
        targetWeight: specific.targetWeight!,
        height: height,
        currentWeight: currentWeight,
        program: program,
        policy: policy.targetWeight,
      );
      if (targetWeightGate is EligibilityRejected) {
        return _toOutcome(targetWeightGate);
      }
    }

    final paceResult = evaluatePace(
      program: program,
      currentWeight: currentWeight,
      policy: policy.weightChangeRate,
      requestedPaceKgPerWeek: specific.targetDate == null
          ? specific.requestedPaceKgPerWeek
          : null,
      requestedDeltaKg:
          specific.targetDate != null && specific.targetWeight != null
          ? (specific.targetWeight!.kg - currentWeight.kg).abs()
          : null,
      requestedWeeks: specific.targetDate != null
          ? _daysBetween(asOfDate, specific.targetDate!) / 7.0
          : null,
      asOfDate: asOfDate,
    );
    if (paceResult.isRejected) {
      return NeedsUserCorrection<ProgramTargetProposal>(
        reasonCode: paceResult.reasonCode!,
        details: <String, Object?>{
          if (paceResult.appliedCapKgPerWeek != null)
            'appliedCapKgPerWeek': paceResult.appliedCapKgPerWeek,
          if (paceResult.earliestSafeWeeks != null)
            'earliestSafeWeeks': paceResult.earliestSafeWeeks,
          if (paceResult.earliestSafeDate != null)
            'earliestSafeDate': paceResult.earliestSafeDate,
        },
      );
    }

    final energyResult = computeEnergyTarget(
      program: program,
      biologicalInput: biologicalInput,
      restingEnergyRawKcal: estimate.restingEnergy.kcal,
      tdeeRawKcal: estimate.totalDailyEnergy.kcal,
      weightLossPolicy: policy.weightLossEnergy,
      weightGainPolicy: policy.weightGainEnergy,
      maintenancePolicy: policy.maintenanceEnergy,
    );
    if (energyResult.isRejected) {
      return NeedsProfessionalReview<ProgramTargetProposal>(
        reasonCode: ReasonCode.targetBelowMinimumEnergy,
        details: <String, Object?>{
          'remainingDeficitKcal': energyResult.rejectedRemainingDeficitKcal,
        },
      );
    }

    final roundedEnergy = energyResult.roundedTarget!;
    final referenceWeight = computeReferenceWeight(
      currentWeight: currentWeight,
      height: height,
      bmiCap: policy.macronutrients.referenceWeightBmiCap,
    );
    final macroResult = computeMacronutrients(
      program: program,
      targetEnergy: roundedEnergy,
      referenceWeight: referenceWeight,
      policy: policy.macronutrients,
    );

    return Approved<ProgramTargetProposal>(
      ProgramTargetProposal(
        program: program,
        policyVersion: policy.policyVersion,
        calculatorVersion: estimate.calculatorVersion,
        showsEnergyTarget: true,
        showsWeightProgressPercent: program != ProgramCode.healthyEating,
        energyTarget: roundedEnergy,
        referenceWeight: referenceWeight,
        macros: macroResult.targets,
        toleranceBand: energyResult.toleranceBand,
        warnings: <ProgramWarning>{
          ...energyResult.warnings,
          ...macroResult.warnings,
        },
      ),
    );
  }

  ProgramTargetProposal _withoutTargets({
    required ProgramCode program,
    required NutritionEstimate estimate,
  }) => ProgramTargetProposal(
    program: program,
    policyVersion: policy.policyVersion,
    calculatorVersion: estimate.calculatorVersion,
    showsEnergyTarget: false,
    showsWeightProgressPercent: false,
  );

  ProgramOutcome<ProgramTargetProposal> _toOutcome(EligibilityRejected gate) =>
      switch (gate.kind) {
        RejectionKind.needsUserCorrection =>
          NeedsUserCorrection<ProgramTargetProposal>(
            reasonCode: gate.reasonCode,
            details: gate.details,
          ),
        RejectionKind.needsProfessionalReview =>
          NeedsProfessionalReview<ProgramTargetProposal>(
            reasonCode: gate.reasonCode,
            details: gate.details,
          ),
        RejectionKind.unsupportedProfile =>
          UnsupportedProfile<ProgramTargetProposal>(
            reasonCode: gate.reasonCode,
          ),
      };

  // --- Aturan kelayakan, masing-masing dapat diuji sendiri (B2–B9) ---

  static EligibilityGate checkAge({
    required int ageYears,
    required ProgramCode program,
    required EligibilityPolicy policy,
  }) {
    if (ageYears < policy.ageMinInclusive) {
      if (program == ProgramCode.healthyEating) {
        return const EligibilityPassWithoutTargets();
      }
      return const EligibilityRejected(
        kind: RejectionKind.unsupportedProfile,
        reasonCode: ReasonCode.ageBelowMinimum,
      );
    }
    if (ageYears > policy.ageMaxInclusive &&
        _weightChangingPrograms.contains(program)) {
      return const EligibilityRejected(
        kind: RejectionKind.needsProfessionalReview,
        reasonCode: ReasonCode.ageAboveSupported,
      );
    }
    return const EligibilityPass();
  }

  static EligibilityGate checkPregnancyOrLactation({
    required bool isPregnantOrLactating,
    required ProgramCode program,
  }) {
    if (!isPregnantOrLactating) {
      return const EligibilityPass();
    }
    return switch (program) {
      ProgramCode.weightLoss => const EligibilityRejected(
        kind: RejectionKind.unsupportedProfile,
        reasonCode: ReasonCode.pregnancyOrLactation,
      ),
      ProgramCode.weightGain ||
      ProgramCode.maintenance => const EligibilityRejected(
        kind: RejectionKind.needsProfessionalReview,
        reasonCode: ReasonCode.pregnancyOrLactation,
      ),
      ProgramCode.healthyEating => const EligibilityPass(),
    };
  }

  static EligibilityGate checkBmiRange({
    required double bmi,
    required ProgramCode program,
    required EligibilityPolicy policy,
  }) {
    if (bmi < policy.bmiUnderweightBelow && program == ProgramCode.weightLoss) {
      return const EligibilityRejected(
        kind: RejectionKind.unsupportedProfile,
        reasonCode: ReasonCode.underweightBmi,
      );
    }
    if (bmi >= policy.bmiAboveSupportedAtOrAbove &&
        _weightChangingPrograms.contains(program)) {
      return const EligibilityRejected(
        kind: RejectionKind.needsProfessionalReview,
        reasonCode: ReasonCode.bmiAboveSupported,
      );
    }
    return const EligibilityPass();
  }

  static EligibilityGate checkDeclaredConditions({
    required Set<DeclaredCondition> conditions,
    required ProgramCode program,
  }) {
    final medical = conditions.difference(<DeclaredCondition>{
      DeclaredCondition.eatingDisorderCurrentOrPast,
    });
    if (medical.isNotEmpty) {
      return const EligibilityRejected(
        kind: RejectionKind.needsProfessionalReview,
        reasonCode: ReasonCode.declaredMedicalCondition,
      );
    }
    if (conditions.contains(DeclaredCondition.eatingDisorderCurrentOrPast)) {
      if (_weightChangingPrograms.contains(program)) {
        return const EligibilityRejected(
          kind: RejectionKind.needsProfessionalReview,
          reasonCode: ReasonCode.declaredMedicalCondition,
        );
      }
      if (program == ProgramCode.healthyEating) {
        return const EligibilityPassWithoutTargets();
      }
    }
    return const EligibilityPass();
  }

  static EligibilityGate checkRapidWeightChange({
    required UnintendedWeightChange? change,
    required EligibilityPolicy policy,
  }) {
    if (change == null) {
      return const EligibilityPass();
    }
    if (change.percentOfBodyWeight > policy.unintendedChangeThresholdPercent) {
      return const EligibilityRejected(
        kind: RejectionKind.needsProfessionalReview,
        reasonCode: ReasonCode.rapidUnintendedWeightChange,
      );
    }
    return const EligibilityPass();
  }

  static EligibilityGate checkTargetWeightRange({
    required Mass targetWeight,
    required Length height,
    required Mass currentWeight,
    required ProgramCode program,
    required TargetWeightPolicy policy,
  }) {
    final targetBmi = targetWeight.kg / (height.meters * height.meters);
    if (targetBmi < policy.minBmi) {
      return const EligibilityRejected(
        kind: RejectionKind.needsUserCorrection,
        reasonCode: ReasonCode.targetWeightOutOfRange,
        details: <String, Object?>{
          targetWeightViolationKey: TargetWeightViolation.belowMinBmi,
        },
      );
    }
    if (program == ProgramCode.weightLoss &&
        targetWeight.kg >= currentWeight.kg) {
      return const EligibilityRejected(
        kind: RejectionKind.needsUserCorrection,
        reasonCode: ReasonCode.targetWeightOutOfRange,
        details: <String, Object?>{
          targetWeightViolationKey: TargetWeightViolation.wrongDirection,
        },
      );
    }
    if (program == ProgramCode.weightGain &&
        targetWeight.kg <= currentWeight.kg) {
      return const EligibilityRejected(
        kind: RejectionKind.needsUserCorrection,
        reasonCode: ReasonCode.targetWeightOutOfRange,
        details: <String, Object?>{
          targetWeightViolationKey: TargetWeightViolation.wrongDirection,
        },
      );
    }
    return const EligibilityPass();
  }

  // --- Laju perubahan berat (E1–E4) ---

  static PaceEvaluationResult evaluatePace({
    required ProgramCode program,
    required Mass currentWeight,
    required WeightChangeRatePolicy policy,
    double? requestedPaceKgPerWeek,
    double? requestedDeltaKg,
    double? requestedWeeks,
    LocalDate? asOfDate,
  }) {
    if (!_weightChangingPrograms.contains(program)) {
      return const PaceEvaluationResult.ok();
    }

    double? requestedPace;
    if (requestedDeltaKg != null &&
        requestedWeeks != null &&
        requestedWeeks > 0) {
      requestedPace = requestedDeltaKg / requestedWeeks;
    } else if (requestedPaceKgPerWeek != null) {
      requestedPace = requestedPaceKgPerWeek;
    }
    if (requestedPace == null) {
      return const PaceEvaluationResult.ok();
    }

    late final double minPace;
    late final double cap;
    var relativeCapBinds = false;
    if (program == ProgramCode.weightLoss) {
      minPace = policy.weightLossMinKgPerWeek;
      final absoluteMax = policy.weightLossMaxKgPerWeek;
      final relativeMax =
          policy.weightLossMaxFractionOfBodyWeightPerWeek * currentWeight.kg;
      cap = absoluteMax < relativeMax ? absoluteMax : relativeMax;
      relativeCapBinds = relativeMax < absoluteMax;
    } else {
      minPace = policy.weightGainMinKgPerWeek;
      cap = policy.weightGainMaxKgPerWeek;
    }

    if (requestedPace < minPace) {
      return const PaceEvaluationResult.rejected(
        reasonCode: ReasonCode.requestedPaceTooSlow,
      );
    }
    if (requestedPace > cap) {
      final earliestSafeWeeks = requestedDeltaKg != null
          ? requestedDeltaKg / cap
          : null;
      return PaceEvaluationResult.rejected(
        reasonCode: ReasonCode.requestedPaceTooFast,
        appliedCapKgPerWeek: cap,
        earliestSafeWeeks: earliestSafeWeeks,
        earliestSafeDate: earliestSafeWeeks != null && asOfDate != null
            ? _addDays(asOfDate, (earliestSafeWeeks * 7).ceil())
            : null,
      );
    }
    return PaceEvaluationResult.ok(
      appliedCapKgPerWeek: cap,
      warnRelativeCapApplied: relativeCapBinds,
    );
  }

  // --- Target energi harian (D1–D7) ---

  static EnergyTargetResult computeEnergyTarget({
    required ProgramCode program,
    required BiologicalInput biologicalInput,
    required double restingEnergyRawKcal,
    required double tdeeRawKcal,
    required WeightLossEnergyPolicy weightLossPolicy,
    required WeightGainEnergyPolicy weightGainPolicy,
    required MaintenanceEnergyPolicy maintenancePolicy,
  }) {
    switch (program) {
      case ProgramCode.weightLoss:
        final deficitRaw = tdeeRawKcal * weightLossPolicy.deficitFractionOfTdee;
        final deficitApplied = _clampD(
          deficitRaw,
          weightLossPolicy.deficitMinKcal,
          weightLossPolicy.deficitMaxKcal,
        );
        var target = tdeeRawKcal - deficitApplied;
        final warnings = <ProgramWarning>{};

        if (target < restingEnergyRawKcal) {
          target = restingEnergyRawKcal;
          warnings.add(ProgramWarning.floorApplied);
        }
        final absoluteFloor = biologicalInput == BiologicalInput.male
            ? weightLossPolicy.floorAbsoluteMaleKcal
            : weightLossPolicy.floorAbsoluteFemaleKcal;
        if (target < absoluteFloor) {
          target = absoluteFloor;
          warnings.add(ProgramWarning.floorApplied);
        }
        if (target < weightLossPolicy.hardFloorKcal) {
          target = weightLossPolicy.hardFloorKcal;
          warnings.add(ProgramWarning.floorApplied);
        }

        final remainingDeficit = tdeeRawKcal - target;
        if (remainingDeficit < weightLossPolicy.remainingDeficitMinKcal) {
          return EnergyTargetResult.rejectedBelowMinimumEnergy(
            remainingDeficitKcal: remainingDeficit,
          );
        }

        return EnergyTargetResult.approved(
          roundedTarget: Energy.kcalValue(
            Rounding.toNearest(target, 10),
            field: 'energy_target',
          ).valueOrNull!,
          deficitOrSurplusRawKcal: deficitRaw,
          deficitOrSurplusAppliedKcal: deficitApplied,
          remainingDeficitKcal: remainingDeficit,
          warnings: warnings,
        );

      case ProgramCode.weightGain:
        final surplusRaw = tdeeRawKcal * weightGainPolicy.surplusFractionOfTdee;
        final surplusApplied = _clampD(
          surplusRaw,
          weightGainPolicy.surplusMinKcal,
          weightGainPolicy.surplusMaxKcal,
        );
        final target = tdeeRawKcal + surplusApplied;
        return EnergyTargetResult.approved(
          roundedTarget: Energy.kcalValue(
            Rounding.toNearest(target, 10),
            field: 'energy_target',
          ).valueOrNull!,
          deficitOrSurplusRawKcal: surplusRaw,
          deficitOrSurplusAppliedKcal: surplusApplied,
          remainingDeficitKcal: null,
        );

      case ProgramCode.maintenance:
      case ProgramCode.healthyEating:
        final rounded = Energy.kcalValue(
          Rounding.toNearest(tdeeRawKcal, 10),
          field: 'energy_target',
        ).valueOrNull!;
        (Energy, Energy)? band;
        if (program == ProgramCode.maintenance) {
          final halfWidth = _maxD(
            rounded.kcal * maintenancePolicy.toleranceBandFraction,
            maintenancePolicy.toleranceBandMinKcal,
          );
          band = (
            Energy.kcalValue(
              rounded.kcal - halfWidth,
              field: 'band',
            ).valueOrNull!,
            Energy.kcalValue(
              rounded.kcal + halfWidth,
              field: 'band',
            ).valueOrNull!,
          );
        }
        return EnergyTargetResult.approved(
          roundedTarget: rounded,
          deficitOrSurplusRawKcal: null,
          deficitOrSurplusAppliedKcal: null,
          remainingDeficitKcal: null,
          toleranceBand: band,
        );
    }
  }

  // --- Berat acuan dan makro (F1–F13) ---

  static double computeBmi(Mass weight, Length height) =>
      weight.kg / (height.meters * height.meters);

  static Mass computeReferenceWeight({
    required Mass currentWeight,
    required Length height,
    required double bmiCap,
  }) {
    final weightAtBmiCap = bmiCap * height.meters * height.meters;
    final lower = currentWeight.kg < weightAtBmiCap
        ? currentWeight.kg
        : weightAtBmiCap;
    return Mass.kgValue(
      Rounding.toNearest(lower, 0.1),
      field: 'reference_weight',
    ).valueOrNull!;
  }

  static ({MacronutrientTargets targets, Set<ProgramWarning> warnings})
  computeMacronutrients({
    required ProgramCode program,
    required Energy targetEnergy,
    required Mass referenceWeight,
    required MacronutrientPolicy policy,
  }) {
    final targetKcal = targetEnergy.kcal;
    final warnings = <ProgramWarning>{};

    var proteinGPerKg = policy.proteinGPerKgReferenceWeight[program]!;
    var proteinG = Rounding.toNearestInt(proteinGPerKg * referenceWeight.kg);
    proteinG = _clampProteinPagar(
      proteinG: proteinG,
      referenceWeightKg: referenceWeight.kg,
      targetKcal: targetKcal,
      policy: policy,
    );

    var fatFraction = policy.fatFractionOfEnergy;
    var fatG = Rounding.toNearestInt(
      fatFraction * targetKcal / policy.kcalPerGramFat,
    );
    var carbG = Rounding.toNearestInt(
      (targetKcal -
              proteinG * policy.kcalPerGramProtein -
              fatG * policy.kcalPerGramFat) /
          policy.kcalPerGramCarbohydrate,
    );

    var carbPercent = _percentOf(carbG * policy.kcalPerGramCarbohydrate, <int>[
      proteinG * policy.kcalPerGramProtein.round(),
      fatG * policy.kcalPerGramFat.round(),
      carbG * policy.kcalPerGramCarbohydrate.round(),
    ]);

    final adjustmentSteps = <int>[];
    if (carbPercent < policy.carbohydrateTargetMinFractionOfEnergy * 100) {
      fatFraction = policy.adjustedFatFractionOfEnergy;
      fatG = Rounding.toNearestInt(
        fatFraction * targetKcal / policy.kcalPerGramFat,
      );
      carbG = Rounding.toNearestInt(
        (targetKcal -
                proteinG * policy.kcalPerGramProtein -
                fatG * policy.kcalPerGramFat) /
            policy.kcalPerGramCarbohydrate,
      );
      adjustmentSteps.add(1);

      carbPercent = _percentOf(carbG * policy.kcalPerGramCarbohydrate, <int>[
        proteinG * policy.kcalPerGramProtein.round(),
        fatG * policy.kcalPerGramFat.round(),
        carbG * policy.kcalPerGramCarbohydrate.round(),
      ]);

      if (carbPercent < policy.carbohydrateTargetMinFractionOfEnergy * 100) {
        proteinGPerKg = policy.adjustedProteinGPerKgReferenceWeight;
        proteinG = Rounding.toNearestInt(proteinGPerKg * referenceWeight.kg);
        carbG = Rounding.toNearestInt(
          (targetKcal -
                  proteinG * policy.kcalPerGramProtein -
                  fatG * policy.kcalPerGramFat) /
              policy.kcalPerGramCarbohydrate,
        );
        adjustmentSteps.add(2);

        carbPercent = _percentOf(carbG * policy.kcalPerGramCarbohydrate, <int>[
          proteinG * policy.kcalPerGramProtein.round(),
          fatG * policy.kcalPerGramFat.round(),
          carbG * policy.kcalPerGramCarbohydrate.round(),
        ]);
        if (carbPercent < policy.carbohydrateTargetMinFractionOfEnergy * 100) {
          warnings.add(ProgramWarning.carbohydrateBelowRecommendedRange);
        }
      }
    }

    final fiberG = _clampI(
      Rounding.toNearestInt(policy.fiberGPer1000Kcal * targetKcal / 1000),
      policy.fiberMinG.round(),
      policy.fiberMaxG.round(),
    );

    final proteinKcal = proteinG * policy.kcalPerGramProtein.round();
    final fatKcal = fatG * policy.kcalPerGramFat.round();
    final carbKcal = carbG * policy.kcalPerGramCarbohydrate.round();
    final macroKcals = <int>[proteinKcal, fatKcal, carbKcal];

    return (
      targets: MacronutrientTargets(
        proteinGrams: proteinG,
        proteinPercentEnergy: _roundPercent(
          _percentOf(proteinKcal, macroKcals),
        ),
        fatGrams: fatG,
        fatPercentEnergy: _roundPercent(_percentOf(fatKcal, macroKcals)),
        carbohydrateGrams: carbG,
        carbohydratePercentEnergy: _roundPercent(
          _percentOf(carbKcal, macroKcals),
        ),
        fiberGrams: fiberG,
      ),
      warnings: warnings,
    );
  }

  static int _clampProteinPagar({
    required int proteinG,
    required double referenceWeightKg,
    required double targetKcal,
    required MacronutrientPolicy policy,
  }) {
    final absoluteMinG = Rounding.toNearestInt(
      policy.proteinAbsoluteMinGPerKg * referenceWeightKg,
    );
    var result = proteinG < absoluteMinG ? absoluteMinG : proteinG;

    final minByFraction = Rounding.toNearestInt(
      policy.proteinMinFractionOfEnergy *
          targetKcal /
          policy.kcalPerGramProtein,
    );
    final maxByFraction = Rounding.toNearestInt(
      policy.proteinMaxFractionOfEnergy *
          targetKcal /
          policy.kcalPerGramProtein,
    );
    if (result < minByFraction) {
      result = minByFraction;
    }
    if (result > maxByFraction) {
      result = maxByFraction;
    }
    return result;
  }

  static double _percentOf(num part, List<int> whole) {
    final total = whole.fold<int>(0, (sum, v) => sum + v);
    if (total == 0) {
      return 0;
    }
    return part / total * 100;
  }

  static double _roundPercent(double value) => Rounding.toNearest(value, 0.1);
}

double _clampD(double value, double lower, double upper) {
  if (value < lower) {
    return lower;
  }
  if (value > upper) {
    return upper;
  }
  return value;
}

double _maxD(double a, double b) => a > b ? a : b;

int _clampI(int value, int lower, int upper) {
  if (value < lower) {
    return lower;
  }
  if (value > upper) {
    return upper;
  }
  return value;
}

int _daysBetween(LocalDate from, LocalDate to) => DateTime(
  to.year,
  to.month,
  to.day,
).difference(DateTime(from.year, from.month, from.day)).inDays;

LocalDate _addDays(LocalDate date, int days) {
  final shifted = DateTime(
    date.year,
    date.month,
    date.day,
  ).add(Duration(days: days));
  return LocalDate(shifted.year, shifted.month, shifted.day);
}
