import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/format/id_formatters.dart';
import 'package:mealora/domain/shared/reason_code.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// Pemetaan kode alasan ke kalimat (task 6.2), ditanam di lapisan tampilan
/// — bukan di domain — sesuai `reason-code-copy.md` (task 1.3) dan
/// diperiksa terhadap tiga larangan (task 1.4): tidak mendiagnosis, tidak
/// menjanjikan hasil, tidak menyalahkan pengguna.
final class RejectionCopy {
  const RejectionCopy({required this.heading, required this.explanation});

  final String heading;
  final String explanation;
}

/// Kalimat untuk satu kode dari `ReasonCode` (I1, change 002).
RejectionCopy rejectionCopyForReasonCode(
  AppText text,
  ReasonCode code, {
  Map<String, Object?> details = const <String, Object?>{},
}) {
  switch (code) {
    case ReasonCode.ageBelowMinimum:
      return RejectionCopy(
        heading: text.rejectionAgeBelowMinimumHeading,
        explanation: text.rejectionAgeBelowMinimumExplanation,
      );
    case ReasonCode.ageAboveSupported:
      return RejectionCopy(
        heading: text.rejectionAgeAboveSupportedHeading,
        explanation: text.rejectionAgeAboveSupportedExplanation,
      );
    case ReasonCode.pregnancyOrLactation:
      return RejectionCopy(
        heading: text.rejectionPregnancyOrLactationHeading,
        explanation: text.rejectionPregnancyOrLactationExplanation,
      );
    case ReasonCode.underweightBmi:
      return RejectionCopy(
        heading: text.rejectionUnderweightBmiHeading,
        explanation: text.rejectionUnderweightBmiExplanation,
      );
    case ReasonCode.bmiAboveSupported:
      return RejectionCopy(
        heading: text.rejectionBmiAboveSupportedHeading,
        explanation: text.rejectionBmiAboveSupportedExplanation,
      );
    case ReasonCode.declaredMedicalCondition:
      return RejectionCopy(
        heading: text.rejectionDeclaredMedicalConditionHeading,
        explanation: text.rejectionDeclaredMedicalConditionExplanation,
      );
    case ReasonCode.rapidUnintendedWeightChange:
      return RejectionCopy(
        heading: text.rejectionRapidUnintendedWeightChangeHeading,
        explanation: text.rejectionRapidUnintendedWeightChangeExplanation,
      );
    case ReasonCode.targetBelowMinimumEnergy:
      return RejectionCopy(
        heading: text.rejectionTargetBelowMinimumEnergyHeading,
        explanation: text.rejectionTargetBelowMinimumEnergyExplanation,
      );
    case ReasonCode.requestedPaceTooFast:
      final earliestSafeDate = details['earliestSafeDate'] as LocalDate?;
      return RejectionCopy(
        heading: text.rejectionRequestedPaceTooFastHeading,
        explanation: text.rejectionRequestedPaceTooFastExplanation(
          earliestSafeDate == null ? '—' : IdFormat.longDate(earliestSafeDate),
        ),
      );
    case ReasonCode.requestedPaceTooSlow:
      return RejectionCopy(
        heading: text.rejectionRequestedPaceTooSlowHeading,
        explanation: text.rejectionRequestedPaceTooSlowExplanation,
      );
    case ReasonCode.targetWeightOutOfRange:
      return RejectionCopy(
        heading: text.rejectionTargetWeightOutOfRangeHeading,
        explanation: text.rejectionTargetWeightOutOfRangeExplanation,
      );
    case ReasonCode.missingRequiredInput:
      return RejectionCopy(
        heading: text.rejectionMissingRequiredInputHeading,
        explanation: text.rejectionMissingRequiredInputExplanation,
      );
  }
}

/// Kalimat untuk `MissingValidatedPolicy` — bukan anggota `ReasonCode` (I1,
/// change 002 U8); jaring pengaman rekayasa yang SHALL TIDAK muncul pada
/// wiring yang benar (task 5.3: kebijakan `np-1.0.0` final untuk MVP 1).
RejectionCopy rejectionCopyForMissingValidatedPolicy(AppText text) =>
    RejectionCopy(
      heading: text.rejectionMissingValidatedPolicyHeading,
      explanation: text.rejectionMissingValidatedPolicyExplanation,
    );
