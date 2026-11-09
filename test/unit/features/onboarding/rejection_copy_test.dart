import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/format/id_formatters.dart';
import 'package:mealora/domain/shared/reason_code.dart';
import 'package:mealora/features/onboarding/rejection_copy.dart';
import 'package:mealora/l10n/generated/app_localizations_id.dart';

/// Task 6.2/6.7: setiap kode alasan memetakan ke kalimat lewat
/// `rejection_copy.dart` (task 1.3/1.4) — judul boleh digeneralisasi
/// ("Belum bisa membuat target otomatis") untuk tidak mendiagnosis, tetapi
/// penjelasan tiap kode harus berbeda dan tidak kosong. Pernyataan "tidak
/// ada target yang dibuat/berubah" sendiri adalah elemen tetap di
/// `rejection_screen.dart` (`rejectionContextLabel`/`rejectionNoChangeNote`),
/// bukan bagian dari penjelasan per kode, dan diuji lewat
/// `onboarding_flow_test.dart`.
void main() {
  final text = AppTextId();

  setUpAll(() async {
    await initializeDateFormatting(kAppLocale);
  });

  test('setiap ReasonCode menghasilkan judul dan penjelasan tidak kosong', () {
    for (final code in ReasonCode.values) {
      final copy = rejectionCopyForReasonCode(text, code);
      expect(copy.heading, isNotEmpty, reason: 'kode: $code');
      expect(copy.explanation, isNotEmpty, reason: 'kode: $code');
    }
  });

  test('setiap ReasonCode memetakan ke pasangan judul/penjelasan miliknya '
      'sendiri, bukan tertukar dengan kode lain', () {
    final expected = <ReasonCode, RejectionCopy>{
      ReasonCode.ageBelowMinimum: RejectionCopy(
        heading: text.rejectionAgeBelowMinimumHeading,
        explanation: text.rejectionAgeBelowMinimumExplanation,
      ),
      ReasonCode.ageAboveSupported: RejectionCopy(
        heading: text.rejectionAgeAboveSupportedHeading,
        explanation: text.rejectionAgeAboveSupportedExplanation,
      ),
      ReasonCode.pregnancyOrLactation: RejectionCopy(
        heading: text.rejectionPregnancyOrLactationHeading,
        explanation: text.rejectionPregnancyOrLactationExplanation,
      ),
      ReasonCode.underweightBmi: RejectionCopy(
        heading: text.rejectionUnderweightBmiHeading,
        explanation: text.rejectionUnderweightBmiExplanation,
      ),
      ReasonCode.bmiAboveSupported: RejectionCopy(
        heading: text.rejectionBmiAboveSupportedHeading,
        explanation: text.rejectionBmiAboveSupportedExplanation,
      ),
      ReasonCode.declaredMedicalCondition: RejectionCopy(
        heading: text.rejectionDeclaredMedicalConditionHeading,
        explanation: text.rejectionDeclaredMedicalConditionExplanation,
      ),
      ReasonCode.rapidUnintendedWeightChange: RejectionCopy(
        heading: text.rejectionRapidUnintendedWeightChangeHeading,
        explanation: text.rejectionRapidUnintendedWeightChangeExplanation,
      ),
      ReasonCode.targetBelowMinimumEnergy: RejectionCopy(
        heading: text.rejectionTargetBelowMinimumEnergyHeading,
        explanation: text.rejectionTargetBelowMinimumEnergyExplanation,
      ),
      ReasonCode.requestedPaceTooSlow: RejectionCopy(
        heading: text.rejectionRequestedPaceTooSlowHeading,
        explanation: text.rejectionRequestedPaceTooSlowExplanation,
      ),
      ReasonCode.targetWeightOutOfRange: RejectionCopy(
        heading: text.rejectionTargetWeightOutOfRangeHeading,
        explanation: text.rejectionTargetWeightOutOfRangeExplanation,
      ),
      ReasonCode.missingRequiredInput: RejectionCopy(
        heading: text.rejectionMissingRequiredInputHeading,
        explanation: text.rejectionMissingRequiredInputExplanation,
      ),
    };

    for (final entry in expected.entries) {
      final copy = rejectionCopyForReasonCode(text, entry.key);
      expect(copy.heading, entry.value.heading, reason: 'kode: ${entry.key}');
      expect(
        copy.explanation,
        entry.value.explanation,
        reason: 'kode: ${entry.key}',
      );
    }
  });

  test('laju terlalu cepat menyebut tanggal paling awal yang memenuhi batas '
      'saat tersedia (task 6.3)', () {
    const earliestSafeDate = LocalDate(2026, 12, 25);
    final withDate = rejectionCopyForReasonCode(
      text,
      ReasonCode.requestedPaceTooFast,
      details: const <String, Object?>{'earliestSafeDate': earliestSafeDate},
    );
    expect(withDate.explanation, contains(IdFormat.longDate(earliestSafeDate)));

    final withoutDate = rejectionCopyForReasonCode(
      text,
      ReasonCode.requestedPaceTooFast,
    );
    expect(withoutDate.explanation, isNotEmpty);
    expect(withoutDate.explanation, isNot(contains('null')));
  });

  test('MissingValidatedPolicy (jaring pengaman rekayasa, bukan ReasonCode) '
      'juga punya judul dan penjelasan tidak kosong', () {
    final copy = rejectionCopyForMissingValidatedPolicy(text);
    expect(copy.heading, isNotEmpty);
    expect(copy.explanation, isNotEmpty);
  });
}
