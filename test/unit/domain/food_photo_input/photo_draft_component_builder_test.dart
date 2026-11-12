import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/core/ids/sequential_id_generator.dart';
import 'package:mealora/domain/food/food.dart';
import 'package:mealora/domain/food/food_category.dart';
import 'package:mealora/domain/food/nutrition_profile.dart';
import 'package:mealora/domain/food/serving_size.dart';
import 'package:mealora/domain/food/serving_unit_matcher.dart';
import 'package:mealora/domain/food_photo_input/food_component_recognition.dart';
import 'package:mealora/domain/food_photo_input/photo_draft_component_builder.dart';
import 'package:mealora/domain/image_ai_access/reading_confidence.dart';

ServingSize _serving(String id, double amount, String unit, {bool d = false}) =>
    ServingSize(
      id: id,
      label: '$amount $unit',
      amount: amount,
      unit: unit,
      isDefault: d,
      gramEquivalent: unit == 'gram' ? amount : 100,
      nutrition: const NutritionProfile(),
    );

/// Nasi dengan takaran bawaan sehari-hari (bukan lagi 100 g).
final _rice = Food(
  id: 'food-rice',
  name: 'Nasi putih',
  category: FoodCategory.staple,
  isUserCreated: false,
  servings: <ServingSize>[
    _serving('rice-centong', 1, 'centong', d: true),
    _serving('rice-piring', 1, 'piring'),
    _serving('rice-100g', 100, 'gram'),
  ],
);

RecognizedComponent _recognized(double? value, String? unit) =>
    RecognizedComponent(
      foodNameGuess: 'nasi putih',
      quantity: RecognizedQuantity(
        confidence: ReadingConfidence.confident,
        value: value,
        unit: unit,
      ),
      cookingMethod: const RecognizedCookingMethod(
        confidence: ReadingConfidence.unread,
      ),
    );

/// Draf foto mencocokkan satuan ke takaran (change 015, task 4.7).
void main() {
  final ids = SequentialIdGenerator();

  test('"150 g" → takaran 100 g × 1,5, bukan 150 × takaran bawaan', () {
    final c = buildPhotoDraftComponent(
      ids: ids,
      recognized: _recognized(150, 'g'),
      match: _rice,
    );
    expect(c.matchedServingId, 'rice-100g');
    expect(c.quantity, 1.5);
    expect(c.portionNeedsCheck, isFalse);
  });

  test('"1 piring" → takaran piring', () {
    final c = buildPhotoDraftComponent(
      ids: ids,
      recognized: _recognized(1, 'piring'),
      match: _rice,
    );
    expect(c.matchedServingId, 'rice-piring');
    expect(c.quantity, 1);
  });

  test('satuan tak dikenali → takaran bawaan × 1, porsi perlu dicek', () {
    final c = buildPhotoDraftComponent(
      ids: ids,
      recognized: _recognized(3, 'tumpuk'),
      match: _rice,
    );
    expect(c.matchedServingId, 'rice-centong');
    expect(c.quantity, 1);
    expect(c.portionNeedsCheck, isTrue);
  });

  test('tanpa satuan → takaran bawaan dengan jumlah terbaca', () {
    final c = buildPhotoDraftComponent(
      ids: ids,
      recognized: _recognized(2, null),
      match: _rice,
    );
    expect(c.matchedServingId, 'rice-centong');
    expect(c.quantity, 2);
  });

  test('setiap satuan di unit_ranges.csv punya alias kanonik (task 4.6)', () {
    final units = File('tool/food_catalog/unit_ranges.csv')
        .readAsLinesSync()
        .skip(1)
        .map((l) => l.split(',').first)
        .where((u) => u.isNotEmpty && u != 'density_g_per_ml');
    final canonical = ServingUnitMatcher.unitAliases.values.toSet();
    expect(units.where((u) => !canonical.contains(u)), isEmpty);
  });
}
