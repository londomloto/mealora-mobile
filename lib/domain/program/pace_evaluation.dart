import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/domain/shared/reason_code.dart';

/// Hasil pemeriksaan laju perubahan berat yang diminta (E1–E4).
final class PaceEvaluationResult {
  const PaceEvaluationResult.ok({
    this.appliedCapKgPerWeek,
    this.warnRelativeCapApplied = false,
  }) : reasonCode = null,
       earliestSafeWeeks = null,
       earliestSafeDate = null;

  const PaceEvaluationResult.rejected({
    required this.reasonCode,
    this.appliedCapKgPerWeek,
    this.earliestSafeWeeks,
    this.earliestSafeDate,
  }) : warnRelativeCapApplied = false;

  /// `null` berarti tidak ada permintaan laju yang perlu divalidasi.
  final ReasonCode? reasonCode;
  final double? appliedCapKgPerWeek;
  final double? earliestSafeWeeks;
  final LocalDate? earliestSafeDate;
  final bool warnRelativeCapApplied;

  bool get isRejected => reasonCode != null;
}
