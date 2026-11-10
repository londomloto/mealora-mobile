import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/database/migrations/food_catalog_verification.dart';
import 'package:mealora/database/seeds/food_catalog_seed.dart';

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

    await seedFoodCatalog(db);
    await seedFoodCatalog(db);
    await seedFoodCatalog(db);

    final after = await db.select(db.foods).get();
    expect(after, hasLength(before.length));
    expect(after.map((f) => f.id).toSet(), idsBefore);

    final servingsAfter = await db.select(db.foodServings).get();
    final nutritionAfter = await db.select(db.nutritionValues).get();
    expect(servingsAfter, hasLength(before.length));
    expect(nutritionAfter, hasLength(before.length));
  });

  test(
    'setiap makanan bawaan punya provenans lengkap (task 1.5/2.3.5)',
    () async {
      final foods = await db.select(db.foods).get();
      for (final food in foods) {
        expect(food.sourceType, isNotNull, reason: food.name);
        expect(food.sourceRef, isNotNull, reason: food.name);
        expect(food.sourceVersion, isNotNull, reason: food.name);
        expect(food.verifiedAt, isNotNull, reason: food.name);
      }
    },
  );

  test('setiap makanan punya tepat satu takaran bawaan dengan nilai gizi '
      '(spec food-catalog, "Takaran saji yang bermakna")', () async {
    final check = await verifyFoodCatalog(db);
    expect(check.isHealthy, isTrue, reason: check.toString());
    expect(check.builtInFoodCount, greaterThan(0));
  });

  test(
    'tidak ada nilai gizi dasar yang dikosongkan pada makanan bawaan',
    () async {
      final servings = await db.select(db.foodServings).get();
      for (final serving in servings) {
        final nutrition = await (db.select(
          db.nutritionValues,
        )..where((t) => t.servingId.equals(serving.id))).getSingle();
        expect(nutrition.energyKcal, isNotNull, reason: serving.label);
        expect(nutrition.proteinG, isNotNull, reason: serving.label);
        expect(nutrition.carbohydrateG, isNotNull, reason: serving.label);
        expect(nutrition.fatG, isNotNull, reason: serving.label);
      }
    },
  );
}
