import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/domain/shared/program_outcome.dart';
import 'package:mealora/domain/shared/reason_code.dart';

String describe(ProgramOutcome<int> outcome) => switch (outcome) {
  Approved<int>(:final value) => 'approved:$value',
  NeedsUserCorrection<int>(:final reasonCode) =>
    'correction:${reasonCode.name}',
  NeedsProfessionalReview<int>(:final reasonCode) =>
    'review:${reasonCode.name}',
  UnsupportedProfile<int>(:final reasonCode) =>
    'unsupported:${reasonCode.name}',
  MissingValidatedPolicy<int>() => 'missing_policy',
};

void main() {
  test('switch menangani seluruh lima keadaan secara menyeluruh', () {
    expect(describe(const Approved<int>(42)), 'approved:42');
    expect(
      describe(
        const NeedsUserCorrection<int>(
          reasonCode: ReasonCode.missingRequiredInput,
        ),
      ),
      'correction:missingRequiredInput',
    );
    expect(
      describe(
        const NeedsProfessionalReview<int>(
          reasonCode: ReasonCode.ageAboveSupported,
        ),
      ),
      'review:ageAboveSupported',
    );
    expect(
      describe(
        const UnsupportedProfile<int>(reasonCode: ReasonCode.underweightBmi),
      ),
      'unsupported:underweightBmi',
    );
    expect(describe(const MissingValidatedPolicy<int>()), 'missing_policy');
  });

  test('kesetaraan nilai pada setiap varian', () {
    expect(const Approved<int>(1), const Approved<int>(1));
    expect(
      const NeedsUserCorrection<int>(
        reasonCode: ReasonCode.missingRequiredInput,
        missingFields: ['height_cm'],
      ),
      const NeedsUserCorrection<int>(
        reasonCode: ReasonCode.missingRequiredInput,
        missingFields: ['height_cm'],
      ),
    );
    expect(
      const UnsupportedProfile<int>(reasonCode: ReasonCode.underweightBmi),
      const UnsupportedProfile<int>(reasonCode: ReasonCode.underweightBmi),
    );
    expect(
      const MissingValidatedPolicy<int>(),
      const MissingValidatedPolicy<int>(),
    );
  });
}
