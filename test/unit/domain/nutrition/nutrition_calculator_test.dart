import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/domain/nutrition/activity_level.dart';
import 'package:mealora/domain/nutrition/biological_input.dart';
import 'package:mealora/domain/nutrition/energy_equation_policy.dart';
import 'package:mealora/domain/nutrition/nutrition_calculator.dart';
import 'package:mealora/domain/nutrition/nutrition_estimate.dart';
import 'package:mealora/domain/nutrition/physiological_facts.dart';
import 'package:mealora/domain/shared/program_outcome.dart';
import 'package:mealora/domain/shared/reason_code.dart';

Map<String, dynamic> _loadGoldenVectors() {
  final file = File('test/fixtures/nutrition_policy_golden_np-1.0.0.json');
  return jsonDecode(file.readAsStringSync()) as Map<String, dynamic>;
}

ActivityLevel _activityFromGolden(String value) => switch (value) {
  'lebih_banyak_duduk' => ActivityLevel.sedentary,
  'cukup_bergerak' => ActivityLevel.moderatelyActive,
  'sangat_aktif' => ActivityLevel.veryActive,
  _ => throw ArgumentError('aktivitas tidak dikenal: $value'),
};

BiologicalInput _biologicalFromGolden(String value) => switch (value) {
  'male' => BiologicalInput.male,
  'female' => BiologicalInput.female,
  _ => throw ArgumentError('masukan biologis tidak dikenal: $value'),
};

void main() {
  const calculator = NutritionCalculator(EnergyEquationPolicy.np100);
  final golden = _loadGoldenVectors();

  NutritionEstimate approve(PhysiologicalFactsInput input) {
    final outcome = calculator.estimate(input);
    return switch (outcome) {
      Approved<NutritionEstimate>(:final value) => value,
      _ => throw StateError('diharapkan approved, didapat $outcome'),
    };
  }

  group('uji golden energi — profil acuan', () {
    test('P-REF menghasilkan RMR dan TDEE sesuai vektor emas', () {
      final profile = (golden['reference_profiles'] as Map)['P-REF'] as Map;
      final estimate = approve(
        PhysiologicalFactsInput(
          ageYears: profile['age_years'] as int,
          biologicalInput: _biologicalFromGolden(
            profile['biological_input'] as String,
          ),
          heightCm: (profile['height_cm'] as num).toDouble(),
          weightKg: (profile['weight_kg'] as num).toDouble(),
          activity: _activityFromGolden(profile['activity'] as String),
        ),
      );

      expect(
        estimate.restingEnergy.kcal,
        closeTo((profile['resting_energy_kcal_raw'] as num).toDouble(), 1e-6),
      );
      expect(
        estimate.totalDailyEnergy.kcal,
        closeTo((profile['tdee_kcal_raw'] as num).toDouble(), 1e-6),
      );
      expect(
        estimate.restingEnergy.roundedToTen.kcal,
        (profile['resting_energy_kcal_shown'] as num).toDouble(),
      );
      expect(
        estimate.totalDailyEnergy.roundedToTen.kcal,
        (profile['tdee_kcal_shown'] as num).toDouble(),
      );
      expect(estimate.calculatorVersion, 'msj-1.0.0');
    });

    for (final specialCase
        in (golden['special_cases'] as List).cast<Map<String, dynamic>>()) {
      final given = specialCase['given'] as Map?;
      final expected = specialCase['expected'] as Map;
      if (given == null ||
          given['height_cm'] == null ||
          expected['resting_energy_kcal_raw'] == null) {
        continue;
      }

      test('${specialCase['id']} — ${specialCase['title']}', () {
        final estimate = approve(
          PhysiologicalFactsInput(
            ageYears: given['age_years'] as int,
            biologicalInput: _biologicalFromGolden(
              given['biological_input'] as String,
            ),
            heightCm: (given['height_cm'] as num).toDouble(),
            weightKg: (given['weight_kg'] as num).toDouble(),
            activity: _activityFromGolden(given['activity'] as String),
          ),
        );

        expect(
          estimate.restingEnergy.kcal,
          closeTo(
            (expected['resting_energy_kcal_raw'] as num).toDouble(),
            1e-6,
          ),
        );
        expect(
          estimate.totalDailyEnergy.kcal,
          closeTo((expected['tdee_kcal_raw'] as num).toDouble(), 1e-6),
        );
      });
    }
  });

  group('kasus batas masukan', () {
    test('masukan lengkap dan sah menghasilkan approved', () {
      final outcome = calculator.estimate(
        const PhysiologicalFactsInput(
          ageYears: 29,
          biologicalInput: BiologicalInput.female,
          heightCm: 165,
          weightKg: 68.4,
          activity: ActivityLevel.moderatelyActive,
        ),
      );
      expect(outcome, isA<Approved<NutritionEstimate>>());
    });

    test(
      'usia kosong mengembalikan needs_user_correction dengan nama masukan',
      () {
        final outcome = calculator.estimate(
          const PhysiologicalFactsInput(
            biologicalInput: BiologicalInput.female,
            heightCm: 165,
            weightKg: 68.4,
            activity: ActivityLevel.moderatelyActive,
          ),
        );
        expect(
          outcome,
          isA<NeedsUserCorrection<NutritionEstimate>>().having(
            (o) => o.reasonCode,
            'reasonCode',
            ReasonCode.missingRequiredInput,
          ),
        );
        expect(
          (outcome as NeedsUserCorrection<NutritionEstimate>).missingFields,
          contains('age_years'),
        );
      },
    );

    test('tinggi badan nol ditolak', () {
      final outcome = calculator.estimate(
        const PhysiologicalFactsInput(
          ageYears: 29,
          biologicalInput: BiologicalInput.female,
          heightCm: 0,
          weightKg: 68.4,
          activity: ActivityLevel.moderatelyActive,
        ),
      );
      expect(outcome, isA<NeedsUserCorrection<NutritionEstimate>>());
    });

    test('berat badan negatif ditolak', () {
      final outcome = calculator.estimate(
        const PhysiologicalFactsInput(
          ageYears: 29,
          biologicalInput: BiologicalInput.female,
          heightCm: 165,
          weightKg: -10,
          activity: ActivityLevel.moderatelyActive,
        ),
      );
      expect(outcome, isA<NeedsUserCorrection<NutritionEstimate>>());
    });

    test('seluruh masukan kosong menyebut seluruh masukan yang kurang', () {
      final outcome =
          calculator.estimate(const PhysiologicalFactsInput())
              as NeedsUserCorrection<NutritionEstimate>;
      expect(
        outcome.missingFields,
        containsAll(<String>[
          'age_years',
          'biological_input',
          'height_cm',
          'weight_kg',
          'activity_level',
        ]),
      );
    });
  });

  group('kalkulator tidak mengetahui program', () {
    test('tipe hasil tidak pernah berupa unsupported_profile, '
        'needs_professional_review, atau missing_validated_policy', () {
      final invalidOutcome = calculator.estimate(
        const PhysiologicalFactsInput(),
      );
      expect(
        invalidOutcome,
        isNot(isA<UnsupportedProfile<NutritionEstimate>>()),
      );
      expect(
        invalidOutcome,
        isNot(isA<NeedsProfessionalReview<NutritionEstimate>>()),
      );
      expect(
        invalidOutcome,
        isNot(isA<MissingValidatedPolicy<NutritionEstimate>>()),
      );
    });
  });
}
