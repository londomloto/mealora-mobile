import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/errors/result.dart';
import 'package:mealora/domain/nutrition/biological_input.dart';
import 'package:mealora/domain/program/eligibility_gate.dart';
import 'package:mealora/domain/program/nutrition_policy.dart';
import 'package:mealora/domain/program/program_code.dart';
import 'package:mealora/domain/program/program_engine.dart';
import 'package:mealora/domain/shared/reason_code.dart';
import 'package:mealora/domain/shared/units.dart';

void main() {
  final policy = NutritionPolicy.np100(status: PolicyApprovalStatus.approved);

  group('B-AGE — aturan usia', () {
    test('B-AGE-01: 18 tahun, turun_berat -> unsupported_profile', () {
      final gate = ProgramEngine.checkAge(
        ageYears: 18,
        program: ProgramCode.weightLoss,
        policy: policy.eligibility,
      );
      expect(
        gate,
        isA<EligibilityRejected>().having(
          (g) => g.reasonCode,
          'reasonCode',
          ReasonCode.ageBelowMinimum,
        ),
      );
    });

    test('B-AGE-02/03: 19 dan 64 tahun lolos', () {
      for (final age in [19, 64]) {
        final gate = ProgramEngine.checkAge(
          ageYears: age,
          program: ProgramCode.weightLoss,
          policy: policy.eligibility,
        );
        expect(gate, isA<EligibilityPass>(), reason: 'usia $age');
      }
    });

    test('B-AGE-04: 65 tahun, turun_berat -> needs_professional_review', () {
      final gate = ProgramEngine.checkAge(
        ageYears: 65,
        program: ProgramCode.weightLoss,
        policy: policy.eligibility,
      );
      expect(
        gate,
        isA<EligibilityRejected>().having(
          (g) => g.reasonCode,
          'reasonCode',
          ReasonCode.ageAboveSupported,
        ),
      );
    });

    test('B-AGE-05: 65 tahun, makan_sehat tetap penuh', () {
      final gate = ProgramEngine.checkAge(
        ageYears: 65,
        program: ProgramCode.healthyEating,
        policy: policy.eligibility,
      );
      expect(gate, isA<EligibilityPass>());
    });

    test('B-AGE-06: 18 tahun, makan_sehat -> lolos tanpa target', () {
      final gate = ProgramEngine.checkAge(
        ageYears: 18,
        program: ProgramCode.healthyEating,
        policy: policy.eligibility,
      );
      expect(gate, isA<EligibilityPassWithoutTargets>());
    });
  });

  group('B-BMI — aturan indeks massa tubuh', () {
    test('B-BMI-01: 18.4, turun_berat -> unsupported_profile', () {
      final gate = ProgramEngine.checkBmiRange(
        bmi: 18.4,
        program: ProgramCode.weightLoss,
        policy: policy.eligibility,
      );
      expect(
        gate,
        isA<EligibilityRejected>().having(
          (g) => g.reasonCode,
          'reasonCode',
          ReasonCode.underweightBmi,
        ),
      );
    });

    test('B-BMI-02/03: 18.5 dan 18.6 lolos', () {
      for (final bmi in [18.5, 18.6]) {
        expect(
          ProgramEngine.checkBmiRange(
            bmi: bmi,
            program: ProgramCode.weightLoss,
            policy: policy.eligibility,
          ),
          isA<EligibilityPass>(),
        );
      }
    });

    test('B-BMI-04: 37.4 masih lolos, B-BMI-05: 37.5 ditolak', () {
      expect(
        ProgramEngine.checkBmiRange(
          bmi: 37.4,
          program: ProgramCode.weightLoss,
          policy: policy.eligibility,
        ),
        isA<EligibilityPass>(),
      );
      expect(
        ProgramEngine.checkBmiRange(
          bmi: 37.5,
          program: ProgramCode.weightLoss,
          policy: policy.eligibility,
        ),
        isA<EligibilityRejected>().having(
          (g) => g.reasonCode,
          'reasonCode',
          ReasonCode.bmiAboveSupported,
        ),
      );
    });

    test('B-BMI-07: 37.6 pada makan_sehat tetap lolos penuh', () {
      expect(
        ProgramEngine.checkBmiRange(
          bmi: 37.6,
          program: ProgramCode.healthyEating,
          policy: policy.eligibility,
        ),
        isA<EligibilityPass>(),
      );
    });
  });

  group('B-PACE — laju perubahan berat', () {
    test('B-PACE-01: terlalu lambat', () {
      final result = ProgramEngine.evaluatePace(
        program: ProgramCode.weightLoss,
        currentWeight: (Mass.kgValue(80, field: 'w') as Ok<Mass>).value,
        policy: policy.weightChangeRate,
        requestedPaceKgPerWeek: 0.24,
      );
      expect(result.reasonCode, ReasonCode.requestedPaceTooSlow);
    });

    test('B-PACE-02: 0,25 tepat batas bawah, lolos dengan cap 0,6', () {
      final result = ProgramEngine.evaluatePace(
        program: ProgramCode.weightLoss,
        currentWeight: (Mass.kgValue(80, field: 'w') as Ok<Mass>).value,
        policy: policy.weightChangeRate,
        requestedPaceKgPerWeek: 0.25,
      );
      expect(result.isRejected, isFalse);
      expect(result.appliedCapKgPerWeek, closeTo(0.6, 1e-9));
    });

    test('B-PACE-03/04: batas relatif pada berat 101 kg', () {
      final within = ProgramEngine.evaluatePace(
        program: ProgramCode.weightLoss,
        currentWeight: (Mass.kgValue(101, field: 'w') as Ok<Mass>).value,
        policy: policy.weightChangeRate,
        requestedPaceKgPerWeek: 0.75,
      );
      expect(within.isRejected, isFalse);
      expect(within.appliedCapKgPerWeek, closeTo(0.75, 1e-9));

      final tooFast = ProgramEngine.evaluatePace(
        program: ProgramCode.weightLoss,
        currentWeight: (Mass.kgValue(101, field: 'w') as Ok<Mass>).value,
        policy: policy.weightChangeRate,
        requestedPaceKgPerWeek: 0.76,
      );
      expect(tooFast.reasonCode, ReasonCode.requestedPaceTooFast);
    });

    test('B-PACE-05/06: cap relatif mengikat pada berat 52 kg', () {
      final tooFast = ProgramEngine.evaluatePace(
        program: ProgramCode.weightLoss,
        currentWeight: (Mass.kgValue(52, field: 'w') as Ok<Mass>).value,
        policy: policy.weightChangeRate,
        requestedPaceKgPerWeek: 0.40,
      );
      expect(tooFast.reasonCode, ReasonCode.requestedPaceTooFast);
      expect(tooFast.appliedCapKgPerWeek, closeTo(0.39, 1e-9));

      final ok = ProgramEngine.evaluatePace(
        program: ProgramCode.weightLoss,
        currentWeight: (Mass.kgValue(52, field: 'w') as Ok<Mass>).value,
        policy: policy.weightChangeRate,
        requestedPaceKgPerWeek: 0.39,
      );
      expect(ok.isRejected, isFalse);
      expect(ok.warnRelativeCapApplied, isTrue);
    });

    test('B-PACE-08/09/10: naik_berat tidak memakai cap relatif', () {
      expect(
        ProgramEngine.evaluatePace(
          program: ProgramCode.weightGain,
          currentWeight: (Mass.kgValue(60, field: 'w') as Ok<Mass>).value,
          policy: policy.weightChangeRate,
          requestedPaceKgPerWeek: 0.124,
        ).reasonCode,
        ReasonCode.requestedPaceTooSlow,
      );
      expect(
        ProgramEngine.evaluatePace(
          program: ProgramCode.weightGain,
          currentWeight: (Mass.kgValue(60, field: 'w') as Ok<Mass>).value,
          policy: policy.weightChangeRate,
          requestedPaceKgPerWeek: 0.5,
        ).isRejected,
        isFalse,
      );
      expect(
        ProgramEngine.evaluatePace(
          program: ProgramCode.weightGain,
          currentWeight: (Mass.kgValue(60, field: 'w') as Ok<Mass>).value,
          policy: policy.weightChangeRate,
          requestedPaceKgPerWeek: 0.51,
        ).reasonCode,
        ReasonCode.requestedPaceTooFast,
      );
    });

    test(
      'B-PACE-11: laju dari delta dan minggu, tanggal paling awal 10 minggu',
      () {
        final result = ProgramEngine.evaluatePace(
          program: ProgramCode.weightLoss,
          currentWeight: (Mass.kgValue(80, field: 'w') as Ok<Mass>).value,
          policy: policy.weightChangeRate,
          requestedDeltaKg: 6.0,
          requestedWeeks: 4,
          asOfDate: const LocalDate(2026, 11, 8),
        );
        expect(result.reasonCode, ReasonCode.requestedPaceTooFast);
        expect(result.appliedCapKgPerWeek, closeTo(0.6, 1e-9));
        expect(result.earliestSafeWeeks, closeTo(10.0, 1e-9));
      },
    );
  });

  group('B-TGT — rentang dan arah berat tujuan', () {
    test('B-TGT-01: IMT tujuan di bawah 18,5 ditolak', () {
      final gate = ProgramEngine.checkTargetWeightRange(
        targetWeight: (Mass.kgValue(48, field: 't') as Ok<Mass>).value,
        height: (Length.cmValue(165, field: 'h') as Ok<Length>).value,
        currentWeight: (Mass.kgValue(70, field: 'w') as Ok<Mass>).value,
        program: ProgramCode.weightLoss,
        policy: policy.targetWeight,
      );
      expect(
        gate,
        isA<EligibilityRejected>().having(
          (g) => g.reasonCode,
          'reasonCode',
          ReasonCode.targetWeightOutOfRange,
        ),
      );
    });

    test('B-TGT-02: Turun Berat dengan target lebih berat ditolak', () {
      final gate = ProgramEngine.checkTargetWeightRange(
        targetWeight: (Mass.kgValue(75, field: 't') as Ok<Mass>).value,
        height: (Length.cmValue(165, field: 'h') as Ok<Length>).value,
        currentWeight: (Mass.kgValue(70, field: 'w') as Ok<Mass>).value,
        program: ProgramCode.weightLoss,
        policy: policy.targetWeight,
      );
      expect(gate, isA<EligibilityRejected>());
    });

    test('B-TGT-03: Naik Berat dengan target lebih ringan ditolak', () {
      final gate = ProgramEngine.checkTargetWeightRange(
        targetWeight: (Mass.kgValue(55, field: 't') as Ok<Mass>).value,
        height: (Length.cmValue(165, field: 'h') as Ok<Length>).value,
        currentWeight: (Mass.kgValue(60, field: 'w') as Ok<Mass>).value,
        program: ProgramCode.weightGain,
        policy: policy.targetWeight,
      );
      expect(gate, isA<EligibilityRejected>());
    });

    test('B-TGT-04: arah dan rentang benar lolos', () {
      final gate = ProgramEngine.checkTargetWeightRange(
        targetWeight: (Mass.kgValue(63, field: 't') as Ok<Mass>).value,
        height: (Length.cmValue(165, field: 'h') as Ok<Length>).value,
        currentWeight: (Mass.kgValue(70, field: 'w') as Ok<Mass>).value,
        program: ProgramCode.weightLoss,
        policy: policy.targetWeight,
      );
      expect(gate, isA<EligibilityPass>());
    });
  });

  group('D6 — defisit tersisa di bawah minimum', () {
    test(
      'B-D6-01: defisit mentah di bawah 300 dinaikkan lalu tetap ditolak',
      () {
        final result = ProgramEngine.computeEnergyTarget(
          program: ProgramCode.weightLoss,
          biologicalInput: BiologicalInput.female,
          restingEnergyRawKcal: 1067.86,
          tdeeRawKcal: 1495.0,
          weightLossPolicy: policy.weightLossEnergy,
          weightGainPolicy: policy.weightGainEnergy,
          maintenancePolicy: policy.maintenanceEnergy,
        );
        expect(result.isRejected, isTrue);
        expect(result.rejectedRemainingDeficitKcal, closeTo(295.0, 1e-6));
      },
    );

    test('B-D6-02: defisit tersisa tepat 300 disetujui', () {
      final result = ProgramEngine.computeEnergyTarget(
        program: ProgramCode.weightLoss,
        biologicalInput: BiologicalInput.female,
        restingEnergyRawKcal: 1071.43,
        tdeeRawKcal: 1500.0,
        weightLossPolicy: policy.weightLossEnergy,
        weightGainPolicy: policy.weightGainEnergy,
        maintenancePolicy: policy.maintenanceEnergy,
      );
      expect(result.isRejected, isFalse);
      expect(result.roundedTarget!.kcal, 1200);
      expect(result.remainingDeficitKcal, closeTo(300.0, 1e-6));
    });
  });

  group('B-BAND — pita toleransi Pertahankan', () {
    test('B-BAND-03: pita minimum 100 kkal mengikat di bawah energi kecil', () {
      final result = ProgramEngine.computeEnergyTarget(
        program: ProgramCode.maintenance,
        biologicalInput: BiologicalInput.female,
        restingEnergyRawKcal: 1200,
        tdeeRawKcal: 1800,
        weightLossPolicy: policy.weightLossEnergy,
        weightGainPolicy: policy.weightGainEnergy,
        maintenancePolicy: policy.maintenanceEnergy,
      );
      expect(result.toleranceBand!.$1.kcal, closeTo(1700, 1e-6));
      expect(result.toleranceBand!.$2.kcal, closeTo(1900, 1e-6));
    });

    test('B-BAND-01: pita 5 persen pada energi lebih besar', () {
      final result = ProgramEngine.computeEnergyTarget(
        program: ProgramCode.maintenance,
        biologicalInput: BiologicalInput.female,
        restingEnergyRawKcal: 1500,
        tdeeRawKcal: 2250,
        weightLossPolicy: policy.weightLossEnergy,
        weightGainPolicy: policy.weightGainEnergy,
        maintenancePolicy: policy.maintenanceEnergy,
      );
      expect(result.toleranceBand!.$1.kcal, closeTo(2137.5, 1e-6));
      expect(result.toleranceBand!.$2.kcal, closeTo(2362.5, 1e-6));
    });
  });
}
