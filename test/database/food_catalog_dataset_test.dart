import 'dart:io';

import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/database/seeds/food_catalog_seed.dart';

import '../../tool/food_catalog/catalog_dataset.dart';
import 'test_database.dart';

/// Dataset kurasi → seed (change 015, task 1.6 dan 1.7).
void main() {
  final dataset = CatalogDataset.load('tool/food_catalog');

  test('seed hasil bangkitan sinkron dengan dataset kurasi (task 1.6)', () {
    String compact(String s) => s.replaceAll(RegExp(r'\s+'), '');
    final committed = File(
      'lib/database/seeds/food_catalog_data.dart',
    ).readAsStringSync();
    expect(
      compact(committed) == compact(generateSeedSource(dataset)),
      isTrue,
      reason:
          'food_catalog_data.dart tidak sesuai dataset. Jalankan '
          '`dart run tool/generate_food_catalog.dart`.',
    );
  });

  test('gizi per takaran = nilai_100g × gram / 100 (design.md D4)', () {
    expect(perServing(130, 100), 130);
    expect(perServing(130, 150), 195);
    expect(perServing(2.4, 250), 6);
    expect(perServing(null, 150), isNull);
  });

  group('seed (task 1.7)', () {
    late AppDatabase db;
    setUp(() => db = createTestDatabase());
    tearDown(() => db.close());

    test('takaran bawaan, takaran tambahan, dan status aktif mengikuti '
        'dataset saat seed dijalankan ulang', () async {
      const foodId = 'food-tkpi-1215';
      // Keadaan versi lama: takaran tambahan menjadi bawaan, makanan
      // nonaktif. Seed ulang harus menyelaraskan ke dataset tanpa
      // menghapus baris tambahan.
      await db
          .into(db.foodServings)
          .insert(
            FoodServingsCompanion.insert(
              id: '$foodId-legacy',
              createdAt: kFoodCatalogSeedTimestamp,
              updatedAt: kFoodCatalogSeedTimestamp,
              foodId: foodId,
              label: '1 porsi lama',
              amount: 1,
              unit: 'porsi',
              isDefault: const Value(true),
            ),
          );
      await (db.update(db.foodServings)
            ..where((s) => s.id.equals('$foodId-default')))
          .write(const FoodServingsCompanion(isDefault: Value(false)));
      await (db.update(db.foods)..where((f) => f.id.equals(foodId))).write(
        const FoodsCompanion(isActive: Value(false)),
      );

      await seedFoodCatalog(db);

      final servings = await (db.select(
        db.foodServings,
      )..where((s) => s.foodId.equals(foodId))).get();
      final expected = dataset.servings.where(
        (s) => 'food-${s.foodId}' == foodId,
      );
      for (final s in expected) {
        final row = servings.singleWhere((r) => r.id == s.servingId);
        expect(row.isDefault, s.isDefault, reason: s.servingId);
        expect(row.provenanceTier, s.tier);
      }
      expect(servings.map((s) => s.id), contains('$foodId-legacy'));
      expect(servings.where((s) => s.isDefault), hasLength(1));
      final food = await (db.select(
        db.foods,
      )..where((f) => f.id.equals(foodId))).getSingle();
      expect(
        food.isActive,
        dataset.foods.singleWhere((f) => 'food-${f.id}' == foodId).active,
      );
    });

    test('jumlah takaran tersimpan sama dengan dataset', () async {
      final servings =
          await (db.select(db.foodServings)..where(
                (s) => s.foodId.isIn(dataset.foods.map((f) => 'food-${f.id}')),
              ))
              .get();
      expect(servings, hasLength(dataset.servings.length));
    });
  });
}
