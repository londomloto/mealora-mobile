import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/database/migrations/food_catalog_verification.dart';
import 'package:mealora/database/seeds/food_catalog_seed.dart';

import '../../tool/food_catalog/catalog_dataset.dart';
import 'test_database.dart';

/// Seed katalog makanan: pengenal tetap, idempoten, provenans lengkap
/// (task 2.8, change 007).
void main() {
  late AppDatabase db;

  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  test('katalog diseed otomatis saat basis data dibuat', () async {
    final foods = await db.select(db.foods).get();
    expect(foods, isNotEmpty);
    expect(foods.every((f) => !f.isUserCreated), isTrue);
  });

  test('menjalankan seed tiga kali menghasilkan jumlah baris dan pengenal '
      'yang sama (task 2.8)', () async {
    final before = await db.select(db.foods).get();
    final idsBefore = before.map((f) => f.id).toSet();
    final servingsBefore = await db.select(db.foodServings).get();

    await seedFoodCatalog(db);
    await seedFoodCatalog(db);
    await seedFoodCatalog(db);

    final after = await db.select(db.foods).get();
    expect(after, hasLength(before.length));
    expect(after.map((f) => f.id).toSet(), idsBefore);

    final servingsAfter = await db.select(db.foodServings).get();
    final nutritionAfter = await db.select(db.nutritionValues).get();
    expect(servingsAfter, hasLength(servingsBefore.length));
    expect(nutritionAfter, hasLength(servingsBefore.length));
  });

  test('katalog lama diselaraskan tanpa menghapus makanan buatan', () async {
    const rendangId = 'food-tkpi-1045';
    const customFoodId = 'food-custom-test';

    await (db.delete(
      db.nutritionValues,
    )..where((row) => row.servingId.equals('$rendangId-default'))).go();
    await (db.delete(
      db.foodServings,
    )..where((row) => row.foodId.equals(rendangId))).go();
    await (db.delete(db.foods)..where((row) => row.id.equals(rendangId))).go();
    await db
        .into(db.foods)
        .insert(
          FoodsCompanion.insert(
            id: customFoodId,
            createdAt: kFoodCatalogSeedTimestamp,
            updatedAt: kFoodCatalogSeedTimestamp,
            name: 'Makanan buatan pengguna',
            category: 'other',
          ),
        );
    await (db.delete(
      db.uiPreferences,
    )..where((row) => row.key.equals('food_catalog_seed_version'))).go();

    await ensureFoodCatalogSeeded(db);

    final rendang = await (db.select(
      db.foods,
    )..where((row) => row.id.equals(rendangId))).getSingleOrNull();
    final customFood = await (db.select(
      db.foods,
    )..where((row) => row.id.equals(customFoodId))).getSingleOrNull();
    expect(rendang?.name, 'Rendang sapi masakan');
    expect(customFood?.name, 'Makanan buatan pengguna');
  });

  test(
    'setiap makanan bawaan punya provenans lengkap (task 1.5/2.3.5)',
    () async {
      final foods = await db.select(db.foods).get();
      for (final food in foods) {
        expect(food.sourceType, isNotNull, reason: food.name);
        expect(food.sourceRef, isNotNull, reason: food.name);
        expect(food.sourceVersion, isNotNull, reason: food.name);
        // verifiedAt boleh kosong: belum cocok dengan TKPI 2017 (change
        // 015, task 3.2).
      }
    },
  );

  test('setiap makanan punya tepat satu takaran bawaan dengan nilai gizi '
      '(spec food-catalog, "Takaran saji yang bermakna")', () async {
    final check = await verifyFoodCatalog(db);
    expect(check.isHealthy, isTrue, reason: check.toString());
    expect(check.builtInFoodCount, greaterThan(0));
  });

  test('energi makanan bawaan selalu terisi; makro yang tidak dinyatakan '
      'sumber disimpan kosong, bukan nol (change 015, spec '
      'food-catalog-quality)', () async {
    final servings = await db.select(db.foodServings).get();
    final missingMacro = <String>[];
    for (final serving in servings) {
      final nutrition = await (db.select(
        db.nutritionValues,
      )..where((t) => t.servingId.equals(serving.id))).getSingle();
      expect(nutrition.energyKcal, isNotNull, reason: serving.id);
      if (nutrition.proteinG == null ||
          nutrition.carbohydrateG == null ||
          nutrition.fatG == null) {
        missingMacro.add(serving.foodId);
      }
    }
    // Makro kosong hanya bila memang kosong di dataset kurasi: kosong di
    // TKPI 2017, atau nol yang tidak terkonfirmasi (task 3.4, alasan per
    // item di tool/food_catalog/tkpi2017_review.csv).
    final dataset = CatalogDataset.load('tool/food_catalog');
    final expected = {
      for (final f in dataset.foods)
        if (f.proteinG == null || f.carbohydrateG == null || f.fatG == null)
          'food-${f.id}',
    };
    expect(missingMacro.toSet(), expected);
  });
}
