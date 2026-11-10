import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/domain/program/nutrition_policy.dart';
import 'package:mealora/domain/program/target_review_check.dart';
import 'package:mealora/domain/shared/units.dart';

/// `TargetReviewCheck` (change 008, design D5): mengusulkan peninjauan
/// target ketika berat tercatat melenceng dari berat yang dipakai
/// menghitung target yang berlaku, memakai ambang `np-1.0.0`
/// (`unintendedChangeThresholdPercent`, 5%) — tanpa pernah menolak apa pun
/// (beda dari `ProgramEngine.checkRapidWeightChange`, B9).
void main() {
  final policy = NutritionPolicy.np100(status: PolicyApprovalStatus.approved);
  final baseline = Mass.kgValue(70, field: 'baseline').valueOrNull!;

  test('tidak mengusulkan ketika berat tidak berubah', () {
    expect(
      TargetReviewCheck.isRecommended(
        baselineWeight: baseline,
        latestWeight: baseline,
        policy: policy,
      ),
      isFalse,
    );
  });

  test('tidak mengusulkan ketika perubahan di bawah ambang 5%', () {
    // 70 -> 73 = +4,28%, di bawah 5%.
    final latest = Mass.kgValue(73, field: 'latest').valueOrNull!;
    expect(
      TargetReviewCheck.isRecommended(
        baselineWeight: baseline,
        latestWeight: latest,
        policy: policy,
      ),
      isFalse,
    );
  });

  test('mengusulkan ketika penurunan melewati ambang 5%', () {
    // 70 -> 66 = -5,71%, melewati 5%.
    final latest = Mass.kgValue(66, field: 'latest').valueOrNull!;
    expect(
      TargetReviewCheck.isRecommended(
        baselineWeight: baseline,
        latestWeight: latest,
        policy: policy,
      ),
      isTrue,
    );
  });

  test(
    'mengusulkan ketika kenaikan melewati ambang 5%, bukan cuma penurunan',
    () {
      // 70 -> 74 = +5,71%, melewati 5%.
      final latest = Mass.kgValue(74, field: 'latest').valueOrNull!;
      expect(
        TargetReviewCheck.isRecommended(
          baselineWeight: baseline,
          latestWeight: latest,
          policy: policy,
        ),
        isTrue,
      );
    },
  );
}
