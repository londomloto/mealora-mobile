import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/data/local/drift_food_repository.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/domain/food/food_category.dart';
import 'package:mealora/domain/food/food_repository.dart';
import 'package:mealora/domain/food/nutrition_profile.dart';

import 'test_database.dart';

/// `DriftFoodRepository` (change 007, task 3.1/3.2/3.4) di atas SQLite
/// nyata: pencarian luring dan makanan buatan pengguna.
void main() {
  late AppDatabase db;
  late DriftFoodRepository repository;

  setUp(() {
    db = createTestDatabase();
    repository = DriftFoodRepository(
      db,
      ids: createTestIds(),
      clock: createTestClock(),
    );
  });
  tearDown(() => db.close());

  group('search (task 3.2)', () {
    test('mengabaikan huruf besar-kecil', () async {
      final lower = await repository.search('nasi putih');
      final upper = await repository.search('NASI PUTIH');
      final mixed = await repository.search('Nasi Putih');

      expect(lower.map((f) => f.id), upper.map((f) => f.id));
      expect(lower.map((f) => f.id), mixed.map((f) => f.id));
      expect(lower, isNotEmpty);
    });

    test('mencocokkan bagian mana pun dari nama', () async {
      final results = await repository.search('putih');
      expect(results.map((f) => f.name), contains('Nasi putih'));
    });

    test('mendahulukan kecocokan di awal nama', () async {
      final results = await repository.search('nasi');
      expect(results, isNotEmpty);
      // Setiap makanan yang namanya DIAWALI "nasi" tampil sebelum makanan
      // yang hanya MEMUAT "nasi" di bagian lain namanya.
      final startsWithIndex = results.indexWhere(
        (f) => f.name.toLowerCase().startsWith('nasi'),
      );
      final notStartsWithIndex = results.indexWhere(
        (f) => !f.name.toLowerCase().startsWith('nasi'),
      );
      if (notStartsWithIndex != -1) {
        expect(startsWithIndex, lessThan(notStartsWithIndex));
      }
    });

    test('kueri kosong memberi daftar kosong (bagian terakhir dicatat '
        'dipakai sebelum mengetik, task 6.1)', () async {
      expect(await repository.search(''), isEmpty);
      expect(await repository.search('   '), isEmpty);
    });

    test('pencarian tanpa hasil memberi daftar kosong', () async {
      expect(await repository.search('xyzxyzxyz-tidak-ada'), isEmpty);
    });
  });

  group('makanan buatan sendiri (task 3.4)', () {
    test(
      'tersedia pada pencarian berikutnya dan ditandai buatan pengguna',
      () async {
        final food = await repository.createUserFood(
          name: 'Tumis buncis rumahan',
          category: FoodCategory.other,
          serving: const ServingSizeInput(
            label: '1 porsi · 180 g',
            amount: 1,
            unit: 'porsi',
            nutrition: NutritionProfile(
              proteinG: 7,
              carbohydrateG: 16,
              fatG: 10,
            ),
          ),
        );

        expect(food.isUserCreated, isTrue);
        expect(food.provenance, isNull);

        final results = await repository.search('tumis buncis');
        expect(results.map((f) => f.id), contains(food.id));
      },
    );

    test('nilai yang dikosongkan tersimpan sebagai belum diketahui, bukan '
        'nol (spec, "Nilai gizi dikosongkan")', () async {
      final food = await repository.createUserFood(
        name: 'Camilan tanpa label lengkap',
        category: FoodCategory.other,
        serving: const ServingSizeInput(
          label: '1 bungkus',
          amount: 1,
          unit: 'bungkus',
          nutrition: NutritionProfile(
            proteinG: 2,
          ), // karbo, lemak, energi kosong
        ),
      );

      final reloaded = await repository.findById(food.id);
      final nutrition = reloaded!.defaultServing.nutrition;
      expect(nutrition.proteinG, 2);
      expect(nutrition.energy, isNull);
      expect(nutrition.carbohydrateG, isNull);
      expect(nutrition.fatG, isNull);
    });

    test(
      'menyunting makanan sendiri tidak mengubah pengenal makanan',
      () async {
        final food = await repository.createUserFood(
          name: 'Sarapan racikan sendiri',
          category: FoodCategory.other,
          serving: const ServingSizeInput(
            label: '1 porsi',
            amount: 1,
            unit: 'porsi',
            nutrition: NutritionProfile(energy: null),
          ),
        );

        final updated = await repository.updateUserFood(
          food.id,
          name: 'Sarapan racikan sendiri (revisi)',
          serving: const ServingSizeInput(
            label: '1 porsi besar',
            amount: 1,
            unit: 'porsi',
            nutrition: NutritionProfile(proteinG: 12),
          ),
        );

        expect(updated.id, food.id);
        expect(updated.name, 'Sarapan racikan sendiri (revisi)');
        expect(updated.defaultServing.label, '1 porsi besar');
        expect(updated.defaultServing.nutrition.proteinG, 12);
      },
    );
  });
}
