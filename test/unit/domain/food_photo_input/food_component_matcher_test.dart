import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/domain/food/food.dart';
import 'package:mealora/domain/food/food_category.dart';
import 'package:mealora/domain/food/food_repository.dart';
import 'package:mealora/domain/food/nutrition_profile.dart';
import 'package:mealora/domain/food/recent_food.dart';
import 'package:mealora/domain/food/serving_size.dart';
import 'package:mealora/domain/food_photo_input/food_component_matcher.dart';

const _riceFood = Food(
  id: 'food-rice',
  name: 'Nasi putih',
  category: FoodCategory.staple,
  isUserCreated: false,
  servings: <ServingSize>[
    ServingSize(
      id: 'serving-rice',
      label: '150 g',
      amount: 150,
      unit: 'g',
      isDefault: true,
      nutrition: NutritionProfile(),
    ),
  ],
);

/// Tiruan `FoodRepository.search` (Design D3, change 007): kecocokan
/// substring sederhana, cukup untuk menguji `FoodComponentMatcher` tanpa
/// basis data nyata.
final class _FakeFoodRepository implements FoodRepository {
  _FakeFoodRepository(this.catalog);

  final List<Food> catalog;
  final List<String> queries = <String>[];

  @override
  Future<List<Food>> search(String query) async {
    queries.add(query);
    return catalog
        .where((f) => f.name.toLowerCase().contains(query.toLowerCase()))
        .toList(growable: false);
  }

  @override
  Future<Food?> findById(String id) async =>
      catalog.where((f) => f.id == id).firstOrNull;

  @override
  Future<List<RecentFood>> recentlyLogged(
    String profileId, {
    int limit = 10,
  }) async => const <RecentFood>[];

  @override
  Future<Food> createUserFood({
    required String name,
    required FoodCategory category,
    required ServingSizeInput serving,
  }) => throw UnimplementedError();

  @override
  Future<Food> updateUserFood(
    String foodId, {
    required String name,
    required ServingSizeInput serving,
  }) => throw UnimplementedError();
}

void main() {
  test(
    'komponen yang cocok dengan katalog mengembalikan makanan teratas',
    () async {
      final repository = _FakeFoodRepository(const <Food>[_riceFood]);
      final matcher = FoodComponentMatcher(repository);

      final match = await matcher.match('nasi putih');

      expect(match?.id, 'food-rice');
      expect(repository.queries.single, 'nasi putih');
    },
  );

  test(
    'komponen tanpa padanan mengembalikan null, bukan tebakan terdekat',
    () async {
      final repository = _FakeFoodRepository(const <Food>[_riceFood]);
      final matcher = FoodComponentMatcher(repository);

      final match = await matcher.match('ayam bakar madu');

      expect(match, isNull);
    },
  );

  test('tebakan kosong tidak memanggil katalog sama sekali', () async {
    final repository = _FakeFoodRepository(const <Food>[_riceFood]);
    final matcher = FoodComponentMatcher(repository);

    final match = await matcher.match('   ');

    expect(match, isNull);
    expect(repository.queries, isEmpty);
  });
}
