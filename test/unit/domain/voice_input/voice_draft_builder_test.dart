import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/core/ids/sequential_id_generator.dart';
import 'package:mealora/domain/food/food.dart';
import 'package:mealora/domain/food/food_category.dart';
import 'package:mealora/domain/food/food_repository.dart';
import 'package:mealora/domain/food/nutrition_profile.dart';
import 'package:mealora/domain/food/serving_size.dart';
import 'package:mealora/domain/food_photo_input/food_component_matcher.dart';
import 'package:mealora/domain/voice_input/food_sentence_parser.dart';
import 'package:mealora/domain/voice_input/voice_draft_builder.dart';

const _rice = Food(
  id: 'food-rice',
  name: 'Nasi putih',
  category: FoodCategory.staple,
  isUserCreated: false,
  servings: <ServingSize>[
    ServingSize(
      id: 'rice-100g',
      label: '100 g',
      amount: 100,
      unit: 'gram',
      isDefault: true,
      nutrition: NutritionProfile(),
    ),
    ServingSize(
      id: 'rice-plate',
      label: '1 piring',
      amount: 1,
      unit: 'piring',
      isDefault: false,
      nutrition: NutritionProfile(),
    ),
  ],
);

final class _CatalogRepository implements FoodRepository {
  @override
  Future<List<Food>> search(String query) async =>
      _rice.name.toLowerCase().contains(query.toLowerCase())
      ? const <Food>[_rice]
      : const <Food>[];

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

ParsedSentence _sentence(
  List<ParsedFoodItem> items, {
  ParseSource source = ParseSource.service,
}) => ParsedSentence(items: items, source: source);

void main() {
  final builder = VoiceDraftBuilder(
    matcher: FoodComponentMatcher(_CatalogRepository()),
    ids: SequentialIdGenerator(),
  );

  group('VoiceDraftBuilder (change 012, grup 7)', () {
    test(
      'jumlah dan satuan baku yang cocok dengan takaran: ditentukan',
      () async {
        final [c] = await builder.build(
          _sentence(const [
            ParsedFoodItem(
              foodName: 'nasi',
              quantity: 2,
              unit: 'piring',
              unitStatus: ParsedUnitStatus.standard,
            ),
          ]),
        );
        expect(c.matchedFoodId, 'food-rice');
        expect(c.matchedServingId, 'rice-plate');
        expect(c.quantity, 2);
        expect(c.quantityUndetermined, isFalse);
      },
    );

    test('gram dikonversi ke kelipatan takaran', () async {
      final [c] = await builder.build(
        _sentence(const [
          ParsedFoodItem(
            foodName: 'nasi',
            quantity: 200,
            unit: 'gram',
            unitStatus: ParsedUnitStatus.standard,
          ),
        ]),
      );
      expect(c.matchedServingId, 'rice-100g');
      expect(c.quantity, 2);
      expect(c.quantityUndetermined, isFalse);
    });

    test('jumlah tidak disebut: belum ditentukan, tidak ditebak (task 7.1, '
        '7.2)', () async {
      final [c] = await builder.build(
        _sentence(const [
          ParsedFoodItem(
            foodName: 'nasi',
            unitStatus: ParsedUnitStatus.missing,
          ),
        ]),
      );
      expect(c.quantityUndetermined, isTrue);
      expect(c.portionNeedsCheck, isTrue);
    });

    test('satuan tidak baku: belum ditentukan, takaran makanan tetap '
        'ditawarkan (task 7.3)', () async {
      final [c] = await builder.build(
        _sentence(const [
          ParsedFoodItem(
            foodName: 'nasi',
            quantity: 1,
            unit: 'piring penuh',
            unitStatus: ParsedUnitStatus.nonstandard,
          ),
        ]),
      );
      expect(c.quantityUndetermined, isTrue);
      expect(c.quantityUnitLabel, 'piring penuh');
      expect(c.matchedFoodId, 'food-rice');
    });

    test('satuan baku yang tidak ada di takaran makanan: belum ditentukan, '
        'bukan dipetakan ke takaran bawaan', () async {
      final [c] = await builder.build(
        _sentence(const [
          ParsedFoodItem(
            foodName: 'nasi',
            quantity: 1,
            unit: 'mangkuk',
            unitStatus: ParsedUnitStatus.standard,
          ),
        ]),
      );
      expect(c.quantityUndetermined, isTrue);
    });

    test('tanpa padanan katalog: tidak ada makanan maupun nilai gizi '
        '(task 7.5)', () async {
      final [c] = await builder.build(
        _sentence(const [
          ParsedFoodItem(
            foodName: 'pempek',
            quantity: 1,
            unit: 'porsi',
            unitStatus: ParsedUnitStatus.standard,
          ),
        ]),
      );
      expect(c.matchedFoodId, isNull);
      expect(c.foodMatchNeedsCheck, isTrue);
    });

    test(
      'hasil pengurai di perangkat selalu perlu diperiksa (task 5.10)',
      () async {
        final [c] = await builder.build(
          _sentence(const [
            ParsedFoodItem(
              foodName: 'nasi',
              quantity: 1,
              unit: 'piring',
              unitStatus: ParsedUnitStatus.standard,
              needsCheck: true,
            ),
          ], source: ParseSource.onDevice),
        );
        expect(c.quantityUndetermined, isFalse);
        expect(c.portionNeedsCheck, isTrue);
      },
    );
  });
}
