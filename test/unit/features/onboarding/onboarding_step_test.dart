import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/features/onboarding/onboarding_step.dart';

/// Indikator "langkah keberapa dari berapa" (task 3.4, FRS 3.3.7) — tepat
/// lima langkah bernomor, sama untuk seluruh program (`docs/mealora.pen`
/// `08`–`12`: "LANGKAH 1/5" s.d. "LANGKAH 5/5").
void main() {
  test('welcome tidak punya nomor tampil', () {
    expect(OnboardingStep.welcome.displayNumber, isNull);
  });

  test('targetWeight tidak punya nomor tampil — kelanjutan langkah 4', () {
    expect(OnboardingStep.targetWeight.displayNumber, isNull);
  });

  test('profileBasics sampai review bernomor 1 sampai 5 berurutan', () {
    expect(OnboardingStep.profileBasics.displayNumber, 1);
    expect(OnboardingStep.activity.displayNumber, 2);
    expect(OnboardingStep.programSelect.displayNumber, 3);
    expect(OnboardingStep.programDetail.displayNumber, 4);
    expect(OnboardingStep.review.displayNumber, 5);
  });

  test('total selalu 5', () {
    expect(OnboardingStepDisplay.displayTotal, 5);
  });
}
