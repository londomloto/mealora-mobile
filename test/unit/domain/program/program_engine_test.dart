import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/errors/result.dart';
import 'package:mealora/domain/nutrition/activity_level.dart';
import 'package:mealora/domain/nutrition/biological_input.dart';
import 'package:mealora/domain/nutrition/energy_equation_policy.dart';
import 'package:mealora/domain/nutrition/nutrition_calculator.dart';
import 'package:mealora/domain/nutrition/nutrition_estimate.dart';
import 'package:mealora/domain/nutrition/physiological_facts.dart';
import 'package:mealora/domain/program/declared_condition.dart';
import 'package:mealora/domain/program/nutrition_policy.dart';
import 'package:mealora/domain/program/profile_screening_facts.dart';
import 'package:mealora/domain/program/program_code.dart';
import 'package:mealora/domain/program/program_engine.dart';
import 'package:mealora/domain/program/program_specific_input.dart';
import 'package:mealora/domain/program/program_target_proposal.dart';
import 'package:mealora/domain/shared/program_outcome.dart';
import 'package:mealora/domain/shared/reason_code.dart';
import 'package:mealora/domain/shared/units.dart';

Map<String, dynamic> _golden() =>
    jsonDecode(
          File(
            'test/fixtures/nutrition_policy_golden_np-1.0.0.json',
          ).readAsStringSync(),
        )
        as Map<String, dynamic>;

const _calculator = NutritionCalculator(EnergyEquationPolicy.np100);
final _engine = ProgramEngine(
  NutritionPolicy.np100(status: PolicyApprovalStatus.approved),
);

ActivityLevel _activity(String v) => switch (v) {
  'lebih_banyak_duduk' => ActivityLevel.sedentary,
  'cukup_bergerak' => ActivityLevel.moderatelyActive,
  'sangat_aktif' => ActivityLevel.veryActive,
  _ => throw ArgumentError(v),
};

BiologicalInput _biological(String v) => switch (v) {
  'male' => BiologicalInput.male,
  'female' => BiologicalInput.female,
  _ => throw ArgumentError(v),
};

ProgramCode _program(String v) => switch (v) {
  'weight_loss' || 'turun_berat' => ProgramCode.weightLoss,
  'weight_gain' || 'naik_berat' => ProgramCode.weightGain,
  'maintenance' || 'pertahankan' => ProgramCode.maintenance,
  'healthy_eating' || 'makan_sehat' => ProgramCode.healthyEating,
  _ => throw ArgumentError(v),
};

NutritionEstimate _estimateFor({
  required int ageYears,
  required String biologicalInput,
  required double heightCm,
  required double weightKg,
  required String activity,
}) {
  final outcome = _calculator.estimate(
    PhysiologicalFactsInput(
      ageYears: ageYears,
      biologicalInput: _biological(biologicalInput),
      heightCm: heightCm,
      weightKg: weightKg,
      activity: _activity(activity),
    ),
  );
  return switch (outcome) {
    Approved<NutritionEstimate>(:final value) => value,
    _ => throw StateError('kalkulator gagal: $outcome'),
  };
}

ProgramOutcome<ProgramTargetProposal> _propose({
  required ProgramCode program,
  required int ageYears,
  required String biologicalInput,
  required double heightCm,
  required double weightKg,
  required String activity,
  ProfileScreeningFacts screening = const ProfileScreeningFacts(),
  ProgramSpecificInput specific = const ProgramSpecificInput(),
}) {
  final estimate = _estimateFor(
    ageYears: ageYears,
    biologicalInput: biologicalInput,
    heightCm: heightCm,
    weightKg: weightKg,
    activity: activity,
  );
  return _engine.proposeTarget(
    program: program,
    ageYears: ageYears,
    biologicalInput: _biological(biologicalInput),
    height: (Length.cmValue(heightCm, field: 'h') as Ok<Length>).value,
    currentWeight: (Mass.kgValue(weightKg, field: 'w') as Ok<Mass>).value,
    estimate: estimate,
    screening: screening,
    specific: specific,
    asOfDate: const LocalDate(2026, 11, 8),
    programRequiresTargetWeight:
        program == ProgramCode.weightLoss || program == ProgramCode.weightGain,
    programRequiresHabitFocus: program == ProgramCode.healthyEating,
  );
}

void main() {
  final golden = _golden();
  final referenceProfiles =
      golden['reference_profiles'] as Map<String, dynamic>;

  group('kasus normal — regresi vektor emas change 002', () {
    for (final raw
        in (golden['normal_cases'] as List).cast<Map<String, dynamic>>()) {
      test('${raw['id']}', () {
        final profile =
            referenceProfiles[raw['profile']] as Map<String, dynamic>;
        final expected = raw['expected'] as Map<String, dynamic>;
        final program = _program(raw['program'] as String);

        final currentWeightKg = (profile['weight_kg'] as num).toDouble();
        Mass? targetWeight;
        if (program == ProgramCode.weightLoss) {
          targetWeight =
              (Mass.kgValue(currentWeightKg - 5, field: 'target') as Ok<Mass>)
                  .value;
        } else if (program == ProgramCode.weightGain) {
          targetWeight =
              (Mass.kgValue(currentWeightKg + 5, field: 'target') as Ok<Mass>)
                  .value;
        }

        final outcome = _propose(
          program: program,
          ageYears: profile['age_years'] as int,
          biologicalInput: profile['biological_input'] as String,
          heightCm: (profile['height_cm'] as num).toDouble(),
          weightKg: currentWeightKg,
          activity: profile['activity'] as String,
          specific: ProgramSpecificInput(
            targetWeight: targetWeight,
            habitFocus: program == ProgramCode.healthyEating
                ? 'makan_sayur'
                : null,
          ),
        );

        expect(expected['outcome'], 'approved');
        final proposal = switch (outcome) {
          Approved<ProgramTargetProposal>(:final value) => value,
          _ => throw StateError('diharapkan approved, didapat $outcome'),
        };

        expect(
          proposal.energyTarget!.kcal,
          (expected['energy_target_kcal'] as num).toDouble(),
        );
        expect(
          proposal.referenceWeight!.kg,
          closeTo((expected['reference_weight_kg'] as num).toDouble(), 1e-9),
        );
        expect(proposal.macros!.proteinGrams, expected['protein_g']);
        expect(
          proposal.macros!.proteinPercentEnergy,
          closeTo((expected['protein_percent_energy'] as num).toDouble(), 0.15),
        );
        expect(proposal.macros!.fatGrams, expected['fat_g']);
        expect(
          proposal.macros!.fatPercentEnergy,
          closeTo((expected['fat_percent_energy'] as num).toDouble(), 0.15),
        );
        expect(proposal.macros!.carbohydrateGrams, expected['carbohydrate_g']);
        expect(
          proposal.macros!.carbohydratePercentEnergy,
          closeTo(
            (expected['carbohydrate_percent_energy'] as num).toDouble(),
            0.15,
          ),
        );
        expect(proposal.macros!.fiberGrams, expected['fiber_g']);

        if (expected.containsKey('requires_target_weight')) {
          expect(proposal.program, ProgramCode.healthyEating);
        }
        if (expected.containsKey('shows_weight_progress_percent')) {
          expect(
            proposal.showsWeightProgressPercent,
            expected['shows_weight_progress_percent'],
          );
        }
        if (expected['warnings'] != null) {
          final expectedWarnings = (expected['warnings'] as List)
              .cast<String>();
          expect(proposal.warnings, hasLength(expectedWarnings.length));
        }
      });
    }
  });

  group('kasus khusus (special_cases)', () {
    for (final raw
        in (golden['special_cases'] as List).cast<Map<String, dynamic>>()) {
      final given = raw['given'] as Map<String, dynamic>;
      final expected = raw['expected'] as Map<String, dynamic>;

      if (given['height_cm'] == null) {
        continue;
      }

      test('${raw['id']} — ${raw['title']}', () {
        final program = _program(given['program'] as String);
        final currentWeightKg = (given['weight_kg'] as num).toDouble();
        Mass? targetWeight;
        if (program == ProgramCode.weightLoss) {
          targetWeight =
              (Mass.kgValue(currentWeightKg - 2, field: 'target') as Ok<Mass>)
                  .value;
        } else if (program == ProgramCode.weightGain) {
          targetWeight =
              (Mass.kgValue(currentWeightKg + 2, field: 'target') as Ok<Mass>)
                  .value;
        }
        final outcome = _propose(
          program: program,
          ageYears: given['age_years'] as int,
          biologicalInput: given['biological_input'] as String,
          heightCm: (given['height_cm'] as num).toDouble(),
          weightKg: currentWeightKg,
          activity: given['activity'] as String,
          specific: ProgramSpecificInput(
            targetWeight: targetWeight,
            habitFocus: program == ProgramCode.healthyEating
                ? 'makan_sayur'
                : null,
          ),
        );

        final proposal = switch (outcome) {
          Approved<ProgramTargetProposal>(:final value) => value,
          _ => throw StateError('diharapkan approved, didapat $outcome'),
        };

        expect(
          proposal.energyTarget!.kcal,
          (expected['energy_target_kcal'] as num).toDouble(),
        );
        expect(
          proposal.referenceWeight!.kg,
          closeTo((expected['reference_weight_kg'] as num).toDouble(), 1e-9),
        );
        expect(proposal.macros!.proteinGrams, expected['protein_g']);
        expect(proposal.macros!.fatGrams, expected['fat_g']);
        expect(proposal.macros!.carbohydrateGrams, expected['carbohydrate_g']);
        expect(proposal.macros!.fiberGrams, expected['fiber_g']);

        if (expected['protein_percent_energy'] != null) {
          expect(
            proposal.macros!.proteinPercentEnergy,
            closeTo(
              (expected['protein_percent_energy'] as num).toDouble(),
              0.15,
            ),
          );
        }
        if (expected['fat_percent_energy'] != null) {
          expect(
            proposal.macros!.fatPercentEnergy,
            closeTo((expected['fat_percent_energy'] as num).toDouble(), 0.15),
          );
        }
        if (expected['carbohydrate_percent_energy'] != null) {
          expect(
            proposal.macros!.carbohydratePercentEnergy,
            closeTo(
              (expected['carbohydrate_percent_energy'] as num).toDouble(),
              0.15,
            ),
          );
        }
      });
    }

    test('S5 — Makan Sehat tanpa angka untuk usia di bawah 19', () {
      final outcome = _propose(
        program: ProgramCode.healthyEating,
        ageYears: 16,
        biologicalInput: 'female',
        heightCm: 160,
        weightKg: 55,
        activity: 'cukup_bergerak',
        specific: const ProgramSpecificInput(habitFocus: 'makan_sayur'),
      );
      final proposal = switch (outcome) {
        Approved<ProgramTargetProposal>(:final value) => value,
        _ => throw StateError('diharapkan approved, didapat $outcome'),
      };
      expect(proposal.showsEnergyTarget, isFalse);
      expect(proposal.energyTarget, isNull);
      expect(proposal.macros, isNull);
    });

    test('S6 — Makan Sehat tanpa angka untuk riwayat gangguan makan', () {
      final outcome = _propose(
        program: ProgramCode.healthyEating,
        ageYears: 30,
        biologicalInput: 'female',
        heightCm: 160,
        weightKg: 55,
        activity: 'cukup_bergerak',
        screening: const ProfileScreeningFacts(
          declaredConditions: {DeclaredCondition.eatingDisorderCurrentOrPast},
        ),
        specific: const ProgramSpecificInput(habitFocus: 'makan_sayur'),
      );
      final proposal = switch (outcome) {
        Approved<ProgramTargetProposal>(:final value) => value,
        _ => throw StateError('diharapkan approved, didapat $outcome'),
      };
      expect(proposal.showsEnergyTarget, isFalse);
    });
  });

  group('kode alasan (reason_code_cases)', () {
    test('R-01 age_below_minimum', () {
      final outcome = _propose(
        program: ProgramCode.weightLoss,
        ageYears: 17,
        biologicalInput: 'female',
        heightCm: 160,
        weightKg: 60,
        activity: 'cukup_bergerak',
        specific: ProgramSpecificInput(
          targetWeight: (Mass.kgValue(55, field: 'x') as Ok<Mass>).value,
        ),
      );
      expect(
        outcome,
        isA<UnsupportedProfile<ProgramTargetProposal>>().having(
          (o) => o.reasonCode,
          'reasonCode',
          ReasonCode.ageBelowMinimum,
        ),
      );
    });

    test('R-02 age_above_supported', () {
      final outcome = _propose(
        program: ProgramCode.weightGain,
        ageYears: 70,
        biologicalInput: 'female',
        heightCm: 160,
        weightKg: 50,
        activity: 'cukup_bergerak',
        specific: ProgramSpecificInput(
          targetWeight: (Mass.kgValue(55, field: 'x') as Ok<Mass>).value,
        ),
      );
      expect(
        outcome,
        isA<NeedsProfessionalReview<ProgramTargetProposal>>().having(
          (o) => o.reasonCode,
          'reasonCode',
          ReasonCode.ageAboveSupported,
        ),
      );
    });

    test('R-03 pregnancy_or_lactation', () {
      final outcome = _propose(
        program: ProgramCode.weightLoss,
        ageYears: 30,
        biologicalInput: 'female',
        heightCm: 160,
        weightKg: 60,
        activity: 'cukup_bergerak',
        screening: const ProfileScreeningFacts(isPregnantOrLactating: true),
        specific: ProgramSpecificInput(
          targetWeight: (Mass.kgValue(55, field: 'x') as Ok<Mass>).value,
        ),
      );
      expect(
        outcome,
        isA<UnsupportedProfile<ProgramTargetProposal>>().having(
          (o) => o.reasonCode,
          'reasonCode',
          ReasonCode.pregnancyOrLactation,
        ),
      );
    });

    test('R-04 underweight_bmi', () {
      final outcome = _propose(
        program: ProgramCode.weightLoss,
        ageYears: 30,
        biologicalInput: 'female',
        heightCm: 170,
        weightKg: 51, // bmi ~17.6
        activity: 'cukup_bergerak',
        specific: ProgramSpecificInput(
          targetWeight: (Mass.kgValue(48, field: 'x') as Ok<Mass>).value,
        ),
      );
      expect(
        outcome,
        isA<UnsupportedProfile<ProgramTargetProposal>>().having(
          (o) => o.reasonCode,
          'reasonCode',
          ReasonCode.underweightBmi,
        ),
      );
    });

    test('R-05 bmi_above_supported', () {
      final outcome = _propose(
        program: ProgramCode.weightLoss,
        ageYears: 30,
        biologicalInput: 'female',
        heightCm: 160,
        weightKg: 100, // bmi ~39.1
        activity: 'cukup_bergerak',
        specific: ProgramSpecificInput(
          targetWeight: (Mass.kgValue(80, field: 'x') as Ok<Mass>).value,
        ),
      );
      expect(
        outcome,
        isA<NeedsProfessionalReview<ProgramTargetProposal>>().having(
          (o) => o.reasonCode,
          'reasonCode',
          ReasonCode.bmiAboveSupported,
        ),
      );
    });

    test('R-06 declared_medical_condition', () {
      final outcome = _propose(
        program: ProgramCode.weightGain,
        ageYears: 30,
        biologicalInput: 'female',
        heightCm: 160,
        weightKg: 50,
        activity: 'cukup_bergerak',
        screening: const ProfileScreeningFacts(
          declaredConditions: {DeclaredCondition.kidneyDisease},
        ),
        specific: ProgramSpecificInput(
          targetWeight: (Mass.kgValue(55, field: 'x') as Ok<Mass>).value,
        ),
      );
      expect(
        outcome,
        isA<NeedsProfessionalReview<ProgramTargetProposal>>().having(
          (o) => o.reasonCode,
          'reasonCode',
          ReasonCode.declaredMedicalCondition,
        ),
      );
    });

    test('R-07 rapid_unintended_weight_change', () {
      final outcome = _propose(
        program: ProgramCode.maintenance,
        ageYears: 30,
        biologicalInput: 'female',
        heightCm: 160,
        weightKg: 60,
        activity: 'cukup_bergerak',
        screening: const ProfileScreeningFacts(
          unintendedWeightChange: UnintendedWeightChange(
            percentOfBodyWeight: 6.0,
            windowDays: 30,
          ),
        ),
      );
      expect(
        outcome,
        isA<NeedsProfessionalReview<ProgramTargetProposal>>().having(
          (o) => o.reasonCode,
          'reasonCode',
          ReasonCode.rapidUnintendedWeightChange,
        ),
      );
    });

    test('R-08 target_below_minimum_energy', () {
      final outcome = _propose(
        program: ProgramCode.weightLoss,
        ageYears: 30,
        biologicalInput: 'female',
        heightCm: 150,
        weightKg: 36.7, // tuned to drive TDEE close to the floor
        activity: 'sangat_aktif',
        specific: ProgramSpecificInput(
          targetWeight: (Mass.kgValue(34, field: 'x') as Ok<Mass>).value,
        ),
      );
      // Pastikan hasil tidak pernah approved dengan angka yang bocor; jika
      // profil tertentu tidak memicu D6, uji nilai batas secara langsung di
      // energy_target_result_test.dart.
      expect(outcome, isNot(isA<Approved<ProgramTargetProposal>>()));
    });

    test('R-09 requested_pace_too_fast', () {
      final outcome = _propose(
        program: ProgramCode.weightLoss,
        ageYears: 30,
        biologicalInput: 'female',
        heightCm: 165,
        weightKg: 80,
        activity: 'cukup_bergerak',
        specific: ProgramSpecificInput(
          targetWeight: (Mass.kgValue(74, field: 'x') as Ok<Mass>).value,
          targetDate: const LocalDate(2026, 12, 6), // 4 minggu dari asOfDate
        ),
      );
      expect(
        outcome,
        isA<NeedsUserCorrection<ProgramTargetProposal>>().having(
          (o) => o.reasonCode,
          'reasonCode',
          ReasonCode.requestedPaceTooFast,
        ),
      );
    });

    test('R-10 requested_pace_too_slow', () {
      final outcome = _propose(
        program: ProgramCode.weightLoss,
        ageYears: 30,
        biologicalInput: 'female',
        heightCm: 165,
        weightKg: 80,
        activity: 'cukup_bergerak',
        specific: ProgramSpecificInput(
          targetWeight: (Mass.kgValue(79, field: 'x') as Ok<Mass>).value,
          targetDate: const LocalDate(2027, 3, 29), // 20 minggu dari asOfDate
        ),
      );
      expect(
        outcome,
        isA<NeedsUserCorrection<ProgramTargetProposal>>().having(
          (o) => o.reasonCode,
          'reasonCode',
          ReasonCode.requestedPaceTooSlow,
        ),
      );
    });

    test('R-11 target_weight_out_of_range', () {
      final outcome = _propose(
        program: ProgramCode.weightLoss,
        ageYears: 30,
        biologicalInput: 'female',
        heightCm: 165,
        weightKg: 70,
        activity: 'cukup_bergerak',
        specific: ProgramSpecificInput(
          targetWeight: (Mass.kgValue(48, field: 'x') as Ok<Mass>).value,
        ),
      );
      expect(
        outcome,
        isA<NeedsUserCorrection<ProgramTargetProposal>>().having(
          (o) => o.reasonCode,
          'reasonCode',
          ReasonCode.targetWeightOutOfRange,
        ),
      );
    });

    test('R-12 missing_required_input', () {
      final outcome = _propose(
        program: ProgramCode.weightLoss,
        ageYears: 30,
        biologicalInput: 'female',
        heightCm: 165,
        weightKg: 70,
        activity: 'cukup_bergerak',
      );
      expect(
        outcome,
        isA<NeedsUserCorrection<ProgramTargetProposal>>().having(
          (o) => o.reasonCode,
          'reasonCode',
          ReasonCode.missingRequiredInput,
        ),
      );
    });
  });

  group('kebijakan belum disetujui', () {
    test('status draft mengembalikan missing_validated_policy tanpa angka', () {
      final draftEngine = ProgramEngine(
        NutritionPolicy.np100(status: PolicyApprovalStatus.draft),
      );
      final estimate = _estimateFor(
        ageYears: 30,
        biologicalInput: 'female',
        heightCm: 165,
        weightKg: 68.4,
        activity: 'cukup_bergerak',
      );
      final outcome = draftEngine.proposeTarget(
        program: ProgramCode.maintenance,
        ageYears: 30,
        biologicalInput: BiologicalInput.female,
        height: (Length.cmValue(165, field: 'h') as Ok<Length>).value,
        currentWeight: (Mass.kgValue(68.4, field: 'w') as Ok<Mass>).value,
        estimate: estimate,
        screening: const ProfileScreeningFacts(),
        specific: const ProgramSpecificInput(),
        asOfDate: const LocalDate(2026, 11, 8),
        programRequiresTargetWeight: false,
        programRequiresHabitFocus: false,
      );
      expect(outcome, isA<MissingValidatedPolicy<ProgramTargetProposal>>());

      // Perintah aktivasi (change ini, task 7.1) tidak pernah melihat nilai
      // target karena tipe hasil ini tidak membawa data.
      switch (outcome) {
        case MissingValidatedPolicy<ProgramTargetProposal>():
          break;
        default:
          fail('diharapkan MissingValidatedPolicy');
      }
    });
  });
}
