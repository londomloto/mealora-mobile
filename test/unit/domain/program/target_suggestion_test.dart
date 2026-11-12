import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/errors/result.dart';
import 'package:mealora/domain/program/eligibility_gate.dart';
import 'package:mealora/domain/program/nutrition_policy.dart';
import 'package:mealora/domain/program/program_code.dart';
import 'package:mealora/domain/program/program_engine.dart';
import 'package:mealora/domain/program/target_suggestion.dart';
import 'package:mealora/domain/shared/reason_code.dart';
import 'package:mealora/domain/shared/units.dart';

final _policy = NutritionPolicy.np100(status: PolicyApprovalStatus.approved);
final calc = TargetSuggestionCalculator(_policy);
const today = LocalDate(2026, 11, 12);
final h165 = (Length.cmValue(165, field: 'h') as Ok<Length>).value;
Mass kg(double v) => (Mass.kgValue(v, field: 'w') as Ok<Mass>).value;

LocalDate plusDays(int d) {
  final t = DateTime(2026, 11, 12).add(Duration(days: d));
  return LocalDate(t.year, t.month, t.day);
}

List<TargetSuggestion> suggest(
  ReasonCode code, {
  ProgramCode program = ProgramCode.weightLoss,
  double current = 70,
  double? target,
  LocalDate? date,
  Map<String, Object?> details = const <String, Object?>{},
}) => calc.suggest(
  reasonCode: code,
  details: details,
  program: program,
  height: h165,
  currentWeight: kg(current),
  asOfDate: today,
  targetWeightKg: target,
  targetDate: date,
);

void main() {

  group('berat minimum', () {
    test('165 cm → 50,4 kg (BMI 18,5 dibulatkan ke atas)', () {
      expect(calc.minimumTargetWeightKg(h165), 50.4);
    });

    test('belowMinBmi memberi satu saran berat minimum', () {
      final s = suggest(
        ReasonCode.targetWeightOutOfRange,
        target: 48,
        details: const <String, Object?>{
          targetWeightViolationKey: TargetWeightViolation.belowMinBmi,
        },
      );
      expect(s.single.kind, TargetSuggestionKind.minimumSafeWeight);
      expect(s.single.targetWeightKg, 50.4);
    });

    test('wrongDirection tidak memberi saran', () {
      expect(
        suggest(
          ReasonCode.targetWeightOutOfRange,
          target: 72,
          details: const <String, Object?>{
            targetWeightViolationKey: TargetWeightViolation.wrongDirection,
          },
        ),
        isEmpty,
      );
    });

    test('engine menandai sub-kasus pelanggaran', () {
      final below = ProgramEngine.checkTargetWeightRange(
        targetWeight: kg(48),
        height: h165,
        currentWeight: kg(70),
        program: ProgramCode.weightLoss,
        policy: _policy.targetWeight,
      );
      expect(
        (below as EligibilityRejected).details[targetWeightViolationKey],
        TargetWeightViolation.belowMinBmi,
      );
      final wrong = ProgramEngine.checkTargetWeightRange(
        targetWeight: kg(72),
        height: h165,
        currentWeight: kg(70),
        program: ProgramCode.weightLoss,
        policy: _policy.targetWeight,
      );
      expect(
        (wrong as EligibilityRejected).details[targetWeightViolationKey],
        TargetWeightViolation.wrongDirection,
      );
    });
  });

  group('laju terlalu cepat (kasus tester 165/70)', () {
    test('60 kg dalam 12 minggu → 26 Mar 2027 atau 63,7 kg', () {
      final s = suggest(
        ReasonCode.requestedPaceTooFast,
        target: 60,
        date: plusDays(84),
      );
      expect(s, hasLength(2));
      expect(s[0].kind, TargetSuggestionKind.keepWeightChangeDate);
      expect(s[0].targetWeightKg, 60);
      expect(s[0].targetDate, const LocalDate(2027, 3, 26));
      expect(s[1].kind, TargetSuggestionKind.keepDateChangeWeight);
      expect(s[1].targetWeightKg, 63.7);
      expect(s[1].targetDate, plusDays(84));
    });

    test('57 kg dalam 12 minggu → dua saran yang lolos', () {
      final s = suggest(
        ReasonCode.requestedPaceTooFast,
        target: 57,
        date: plusDays(84),
      );
      expect(s.map((e) => e.kind), <TargetSuggestionKind>[
        TargetSuggestionKind.keepWeightChangeDate,
        TargetSuggestionKind.keepDateChangeWeight,
      ]);
      expect(s[0].targetDate, plusDays(174));
    });

    test('naik berat terlalu cepat → tanggal tercepat & berat tertinggi', () {
      final s = suggest(
        ReasonCode.requestedPaceTooFast,
        program: ProgramCode.weightGain,
        current: 55,
        target: 60,
        date: plusDays(28),
      );
      expect(s[0].targetDate, plusDays(70));
      expect(s[1].targetWeightKg, 57);
    });

    test('tanggal terlalu dekat sampai beratnya sama → saran berat dibuang', () {
      final s = suggest(
        ReasonCode.requestedPaceTooFast,
        target: 60,
        date: plusDays(1),
      );
      expect(s.single.kind, TargetSuggestionKind.keepWeightChangeDate);
    });
  });

  group('laju terlalu lambat', () {
    test('turun 2 kg dalam 52 minggu → tanggal 8 minggu', () {
      final s = suggest(
        ReasonCode.requestedPaceTooSlow,
        target: 68,
        date: plusDays(364),
      );
      expect(s[0].targetDate, plusDays(56));
    });

    test('saran berat di bawah BMI 18,5 dibuang', () {
      final s = suggest(
        ReasonCode.requestedPaceTooSlow,
        target: 68,
        date: plusDays(364),
      );
      // 70 − 0,25 × 52 = 57 kg masih lolos.
      expect(s[1].targetWeightKg, 57);
      final tooLow = suggest(
        ReasonCode.requestedPaceTooSlow,
        current: 55,
        target: 54,
        date: plusDays(364),
      );
      expect(
        tooLow.map((e) => e.kind),
        <TargetSuggestionKind>[TargetSuggestionKind.keepWeightChangeDate],
      );
    });

    test('naik berat terlalu lambat → berat dibulatkan menjauh', () {
      final s = suggest(
        ReasonCode.requestedPaceTooSlow,
        program: ProgramCode.weightGain,
        current: 55,
        target: 56,
        date: plusDays(364),
      );
      expect(s[0].targetDate, plusDays(56));
      expect(s[1].targetWeightKg, 61.5);
    });
  });

  test('energi di bawah minimum tidak diberi saran', () {
    expect(
      suggest(
        ReasonCode.targetBelowMinimumEnergy,
        target: 60,
        date: plusDays(200),
      ),
      isEmpty,
    );
  });

  group('rentang aman', () {
    test('tanpa berat tujuan hanya berat minimum', () {
      final r = calc.safeRange(
        program: ProgramCode.weightLoss,
        height: h165,
        currentWeight: kg(70),
        asOfDate: today,
      );
      expect(r.minimumTargetWeightKg, 50.4);
      expect(r.earliestDate, isNull);
    });

    test('60 kg → 26 Mar 2027 s.d. 19 Agu 2027', () {
      final r = calc.safeRange(
        program: ProgramCode.weightLoss,
        height: h165,
        currentWeight: kg(70),
        asOfDate: today,
        targetWeightKg: 60,
      );
      expect(r.earliestDate, const LocalDate(2027, 3, 26));
      expect(r.latestDate, const LocalDate(2027, 8, 19));
    });

    test('berat tujuan tak lolos gerbang → tanpa tanggal', () {
      final r = calc.safeRange(
        program: ProgramCode.weightLoss,
        height: h165,
        currentWeight: kg(70),
        asOfDate: today,
        targetWeightKg: 45,
      );
      expect(r.earliestDate, isNull);
    });
  });
}
