import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/domain/program/eligibility_gate.dart';
import 'package:mealora/domain/program/nutrition_policy.dart';
import 'package:mealora/domain/program/program_code.dart';
import 'package:mealora/domain/program/program_engine.dart';
import 'package:mealora/domain/shared/reason_code.dart';
import 'package:mealora/domain/shared/units.dart';

/// Macam saran penyesuaian target (change 019).
enum TargetSuggestionKind {
  /// Berat tujuan minimum yang lolos batas BMI tujuan.
  minimumSafeWeight,

  /// Pertahankan berat tujuan, ganti tanggal tujuan.
  keepWeightChangeDate,

  /// Pertahankan tanggal tujuan, ganti berat tujuan.
  keepDateChangeWeight,
}

/// Satu kombinasi berat/tanggal tujuan yang sudah lolos gerbang target dan
/// laju `ProgramEngine`. Hanya diterapkan atas pilihan pengguna.
final class TargetSuggestion {
  const TargetSuggestion({
    required this.kind,
    required this.targetWeightKg,
    this.targetDate,
  });

  final TargetSuggestionKind kind;
  final double targetWeightKg;
  final LocalDate? targetDate;
}

/// Rentang aman untuk petunjuk di layar input (change 019).
final class TargetSafeRange {
  const TargetSafeRange({
    required this.minimumTargetWeightKg,
    this.earliestDate,
    this.latestDate,
  });

  final double minimumTargetWeightKg;

  /// Diisi hanya bila berat tujuan yang diberikan lolos gerbang target.
  final LocalDate? earliestDate;
  final LocalDate? latestDate;
}

/// Menghitung saran dan rentang aman dari kebijakan yang sama dengan
/// `ProgramEngine`. Murni dan deterministik.
final class TargetSuggestionCalculator {
  const TargetSuggestionCalculator(this.policy);

  final NutritionPolicy policy;

  double minimumTargetWeightKg(Length height) =>
      _ceil1(policy.targetWeight.minBmi * height.meters * height.meters);

  TargetSafeRange safeRange({
    required ProgramCode program,
    required Length height,
    required Mass currentWeight,
    required LocalDate asOfDate,
    double? targetWeightKg,
  }) {
    final minimum = minimumTargetWeightKg(height);
    if (targetWeightKg == null ||
        !_weightChanging(program) ||
        !_passesTargetGate(program, height, currentWeight, targetWeightKg)) {
      return TargetSafeRange(minimumTargetWeightKg: minimum);
    }
    final delta = (targetWeightKg - currentWeight.kg).abs();
    return TargetSafeRange(
      minimumTargetWeightKg: minimum,
      earliestDate: _addDays(asOfDate, (delta / _cap(program, currentWeight) * 7).ceil()),
      latestDate: _addDays(asOfDate, (delta / _minPace(program) * 7).floor()),
    );
  }

  /// Saran untuk penolakan target/laju; daftar kosong untuk alasan lain.
  List<TargetSuggestion> suggest({
    required ReasonCode reasonCode,
    required Map<String, Object?> details,
    required ProgramCode program,
    required Length height,
    required Mass currentWeight,
    required LocalDate asOfDate,
    required double? targetWeightKg,
    required LocalDate? targetDate,
  }) {
    final candidates = <TargetSuggestion>[];
    switch (reasonCode) {
      case ReasonCode.targetWeightOutOfRange:
        if (details[targetWeightViolationKey] !=
            TargetWeightViolation.belowMinBmi) {
          return const <TargetSuggestion>[];
        }
        candidates.add(
          TargetSuggestion(
            kind: TargetSuggestionKind.minimumSafeWeight,
            targetWeightKg: minimumTargetWeightKg(height),
            targetDate: targetDate,
          ),
        );
      case ReasonCode.requestedPaceTooFast:
      case ReasonCode.requestedPaceTooSlow:
        if (!_weightChanging(program) ||
            targetWeightKg == null ||
            targetDate == null) {
          return const <TargetSuggestion>[];
        }
        final fast = reasonCode == ReasonCode.requestedPaceTooFast;
        final pace = fast ? _cap(program, currentWeight) : _minPace(program);
        final delta = (targetWeightKg - currentWeight.kg).abs();
        final days = delta / pace * 7;
        candidates.add(
          TargetSuggestion(
            kind: TargetSuggestionKind.keepWeightChangeDate,
            targetWeightKg: targetWeightKg,
            targetDate: _addDays(asOfDate, fast ? days.ceil() : days.floor()),
          ),
        );
        final weeks = _daysBetween(asOfDate, targetDate) / 7.0;
        final loss = program == ProgramCode.weightLoss;
        final raw = loss
            ? currentWeight.kg - pace * weeks
            : currentWeight.kg + pace * weeks;
        // Terlalu cepat: bulatkan ke arah berat saat ini; terlalu lambat:
        // menjauh darinya — keduanya agar laju tetap di dalam batas.
        final roundUp = fast == loss;
        final weight = roundUp ? _ceil1(raw) : _floor1(raw);
        if ((weight - currentWeight.kg).abs() >= 0.1) {
          candidates.add(
            TargetSuggestion(
              kind: TargetSuggestionKind.keepDateChangeWeight,
              targetWeightKg: weight,
              targetDate: targetDate,
            ),
          );
        }
      default:
        return const <TargetSuggestion>[];
    }
    return candidates
        .where(
          (c) => _passes(program, height, currentWeight, asOfDate, c),
        )
        .toList(growable: false);
  }

  bool _passes(
    ProgramCode program,
    Length height,
    Mass currentWeight,
    LocalDate asOfDate,
    TargetSuggestion c,
  ) {
    if (!_passesTargetGate(program, height, currentWeight, c.targetWeightKg)) {
      return false;
    }
    final date = c.targetDate;
    if (date == null) return true;
    final weeks = _daysBetween(asOfDate, date) / 7.0;
    if (weeks <= 0) return false;
    return !ProgramEngine.evaluatePace(
      program: program,
      currentWeight: currentWeight,
      policy: policy.weightChangeRate,
      requestedDeltaKg: (c.targetWeightKg - currentWeight.kg).abs(),
      requestedWeeks: weeks,
      asOfDate: asOfDate,
    ).isRejected;
  }

  bool _passesTargetGate(
    ProgramCode program,
    Length height,
    Mass currentWeight,
    double targetKg,
  ) {
    final target = Mass.kgValue(targetKg, field: 'target').valueOrNull;
    if (target == null) return false;
    return ProgramEngine.checkTargetWeightRange(
          targetWeight: target,
          height: height,
          currentWeight: currentWeight,
          program: program,
          policy: policy.targetWeight,
        )
        is EligibilityPass;
  }

  bool _weightChanging(ProgramCode p) =>
      p == ProgramCode.weightLoss || p == ProgramCode.weightGain;

  double _cap(ProgramCode program, Mass currentWeight) {
    final r = policy.weightChangeRate;
    if (program == ProgramCode.weightGain) return r.weightGainMaxKgPerWeek;
    final relative = r.weightLossMaxFractionOfBodyWeightPerWeek * currentWeight.kg;
    return relative < r.weightLossMaxKgPerWeek
        ? relative
        : r.weightLossMaxKgPerWeek;
  }

  double _minPace(ProgramCode program) => program == ProgramCode.weightGain
      ? policy.weightChangeRate.weightGainMinKgPerWeek
      : policy.weightChangeRate.weightLossMinKgPerWeek;
}

double _ceil1(double v) => (v * 10 - 1e-9).ceil() / 10;
double _floor1(double v) => (v * 10 + 1e-9).floor() / 10;

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
