import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/data/local/drift_diary_repository.dart';
import 'package:mealora/data/local/drift_food_repository.dart';
import 'package:mealora/data/local/drift_packaged_food_repository.dart';
import 'package:mealora/data/local/drift_program_repository.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/domain/food/food.dart';
import 'package:mealora/domain/food/food_category.dart';
import 'package:mealora/domain/food/meal_time.dart';
import 'package:mealora/domain/food/nutrition_profile.dart';
import 'package:mealora/domain/food/serving_size.dart';
import 'package:mealora/domain/packaged_food/packaged_food.dart';
import 'package:mealora/domain/packaged_food/packaged_food_provenance.dart';
import 'package:mealora/domain/packaged_food/packaged_food_repository.dart';
import 'package:mealora/domain/packaged_food/product_data_source_client.dart';
import 'package:mealora/domain/packaged_food/serving_basis.dart';
import 'package:mealora/domain/shared/units.dart';

import '../unit/domain/packaged_food/fakes/fake_product_data_source_client.dart';
import 'test_database.dart';

/// `DriftPackagedFoodRepository` (change 009, tasks 4.3-4.8) di atas
/// SQLite nyata: urutan pencarian perangkat-lebih-dulu, penyimpanan
/// konfirmasi, dan koreksi pengguna yang bertahan.
void main() {
  late AppDatabase db;
  late FakeProductDataSourceClient client;
  late PackagedFoodRepository repository;

  setUp(() {
    db = createTestDatabase();
    client = FakeProductDataSourceClient();
    repository = DriftPackagedFoodRepository(
      db,
      ids: createTestIds(),
      clock: createTestClock(),
      client: client,
    );
  });
  tearDown(() => db.close());

  PackagedFood transientProduct({
    required String barcode,
    double energyKcal = 150,
    double unitsPerPackage = 2,
    bool userCorrected = false,
  }) {
    return PackagedFood(
      food: Food(
        id: 'transient-food',
        name: 'Keripik Singkong Renyah',
        category: FoodCategory.snack,
        isUserCreated: true,
        servings: <ServingSize>[
          ServingSize(
            id: 'transient-serving',
            label: '30 g · 1 sajian',
            amount: 1,
            unit: 'sajian',
            isDefault: true,
            gramEquivalent: 30,
            nutrition: NutritionProfile(
              energy: Energy.kcalValue(energyKcal, field: 'x').valueOrNull,
              proteinG: 2,
              carbohydrateG: 18,
              fatG: 7,
            ),
          ),
        ],
      ),
      barcode: barcode,
      packageSize: '60 g',
      unitsPerPackage: unitsPerPackage,
      servingBasis: ServingBasis.perServing,
      provenance: PackagedFoodProvenance(
        sourceType: 'openfoodfacts',
        sourceRef: barcode,
        sourceVersion: '2026-11-01',
        verifiedAt: testInstant,
        userCorrected: userCorrected,
      ),
    );
  }

  group('pencarian perangkat-lebih-dulu (Design D1, task 4.7)', () {
    test('produk tersimpan ditemukan tanpa memanggil sumber daring', () async {
      await repository.confirm(transientProduct(barcode: '8991111111111'));

      final found = await repository.findByBarcode('8991111111111');

      expect(found, isNotNull);
      expect(found!.food.name, 'Keripik Singkong Renyah');
      expect(client.calledWithBarcodes, isEmpty);
    });

    test('pencarian daring hanya dipanggil ketika barcode tidak ada di '
        'perangkat', () async {
      client.seed(
        '8992222222222',
        const RemoteProductLookup(
          name: 'Produk Daring',
          servingBasis: ServingBasis.perServing,
          nutritionAtRecordedBasis: NutritionProfile(),
        ),
      );

      final found = await repository.findByBarcode('8992222222222');

      expect(found, isNotNull);
      expect(found!.food.name, 'Produk Daring');
      expect(client.calledWithBarcodes, <String>['8992222222222']);
    });

    test(
      'tidak ditemukan di perangkat maupun daring menghasilkan null',
      () async {
        final found = await repository.findByBarcode('8993333333333');

        expect(found, isNull);
        expect(client.calledWithBarcodes, <String>['8993333333333']);
      },
    );

    test('sumber daring gagal (melempar) tidak mengorbankan jalur luring: '
        'hasilnya null, bukan pengecualian (task 4.6)', () async {
      client.throwOnLookup = true;

      final found = await repository.findByBarcode('8994444444444');

      expect(found, isNull);
    });

    test('hasil daring BELUM tersimpan sebelum confirm dipanggil', () async {
      client.seed(
        '8995555555555',
        const RemoteProductLookup(
          name: 'Belum Dikonfirmasi',
          servingBasis: ServingBasis.perServing,
          nutritionAtRecordedBasis: NutritionProfile(),
        ),
      );

      await repository.findByBarcode('8995555555555');
      client.calledWithBarcodes.clear();
      final secondLookup = await repository.findByBarcode('8995555555555');

      expect(
        secondLookup,
        isNotNull,
        reason: 'produk masih tidak ada di perangkat, jadi dicari daring lagi',
      );
      expect(client.calledWithBarcodes, <String>['8995555555555']);
    });
  });

  group('confirm — penyimpanan produk yang dikonfirmasi (task 4.4)', () {
    test('menyimpan produk baru beserta provenansnya', () async {
      final confirmed = await repository.confirm(
        transientProduct(barcode: '8996666666666'),
      );

      expect(confirmed.barcode, '8996666666666');
      expect(confirmed.provenance.sourceType, 'openfoodfacts');
      expect(confirmed.provenance.verifiedAt, testInstant);
      expect(confirmed.unitsPerPackage, 2);

      final reread = await repository.findByBarcode('8996666666666');
      expect(reread!.food.defaultServing.nutrition.energy?.kcal, 150);
    });

    test('mengonfirmasi ulang barcode yang sama memperbarui baris yang '
        'ada, bukan membuat duplikat', () async {
      await repository.confirm(transientProduct(barcode: '8997777777777'));
      await repository.confirm(
        transientProduct(barcode: '8997777777777', energyKcal: 160),
      );

      final found = await repository.findByBarcode('8997777777777');
      expect(found!.food.defaultServing.nutrition.energy?.kcal, 160);
    });
  });

  group('koreksi pengguna menang dan bertahan (Design D5, task 4.5/4.8)', () {
    test('koreksi tersimpan dan ditandai userCorrected', () async {
      await repository.confirm(transientProduct(barcode: '8998888888888'));
      final corrected = await repository.confirm(
        transientProduct(
          barcode: '8998888888888',
          energyKcal: 170,
          userCorrected: true,
        ),
      );

      expect(corrected.provenance.userCorrected, isTrue);
      expect(corrected.food.defaultServing.nutrition.energy?.kcal, 170);
    });

    test('koreksi bertahan setelah pemindaian ulang: userCorrected tidak '
        'pernah turun kembali ke false (task 4.8)', () async {
      await repository.confirm(transientProduct(barcode: '8999999999999'));
      await repository.confirm(
        transientProduct(
          barcode: '8999999999999',
          energyKcal: 170,
          userCorrected: true,
        ),
      );

      // Pemindaian ulang berikutnya yang tidak menyentuh nilai (mis.
      // sekadar mencatat lagi) SHALL TIDAK menurunkan bendera koreksi.
      final reconfirmed = await repository.confirm(
        transientProduct(barcode: '8999999999999', energyKcal: 170),
      );

      expect(reconfirmed.provenance.userCorrected, isTrue);

      final rescanned = await repository.findByBarcode('8999999999999');
      expect(rescanned!.provenance.userCorrected, isTrue);
      expect(rescanned.food.defaultServing.nutrition.energy?.kcal, 170);
    });

    test('koreksi bertahan meskipun sumber daring berubah setelahnya: '
        'pencarian perangkat-lebih-dulu tidak pernah memanggil sumber '
        'daring untuk barcode yang sudah tersimpan', () async {
      await repository.confirm(transientProduct(barcode: '8990000000001'));
      await repository.confirm(
        transientProduct(
          barcode: '8990000000001',
          energyKcal: 170,
          userCorrected: true,
        ),
      );

      client.seed(
        '8990000000001',
        const RemoteProductLookup(
          name: 'Versi Daring Baru',
          servingBasis: ServingBasis.perServing,
          nutritionAtRecordedBasis: NutritionProfile(proteinG: 999),
        ),
      );

      final found = await repository.findByBarcode('8990000000001');

      expect(found!.food.defaultServing.nutrition.energy?.kcal, 170);
      expect(found.provenance.userCorrected, isTrue);
      expect(
        client.calledWithBarcodes,
        isEmpty,
        reason:
            'barcode sudah ada di perangkat — sumber daring tidak pernah '
            'dipanggil (Design D1)',
      );
    });
  });

  group('ditemukan lewat jalur katalog biasa (task 8.1)', () {
    test('produk yang dikonfirmasi ditemukan lewat pencarian nama '
        '(FoodRepository, change 007) dan muncul di terakhir dicatat setelah '
        'dicatat — tanpa kode tambahan, karena produk kemasan adalah '
        '`Food` biasa (Design D8)', () async {
      await repository.confirm(transientProduct(barcode: '8995550000001'));

      final foodRepository = DriftFoodRepository(
        db,
        ids: createTestIds(),
        clock: createTestClock(),
      );
      final bySearch = await foodRepository.search('Keripik Singkong');
      expect(bySearch.map((f) => f.name), contains('Keripik Singkong Renyah'));

      final confirmed = await repository.findByBarcode('8995550000001');
      final diaryRepository = DriftDiaryRepository(
        db,
        clock: createTestClock(),
        ids: createTestIds(),
        programRepository: DriftProgramRepository(
          db,
          clock: createTestClock(),
          ids: createTestIds(),
        ),
      );
      const profileId = 'profile-recent-1';
      await db
          .into(db.profiles)
          .insert(
            ProfilesCompanion.insert(
              id: profileId,
              createdAt: testInstant,
              updatedAt: testInstant,
            ),
          );
      await diaryRepository.addEntry(
        profileId: profileId,
        date: createTestClock().today(),
        mealTime: MealTime.snack,
        food: confirmed!.food,
        serving: confirmed.food.defaultServing,
        quantity: 1,
      );

      final recent = await foodRepository.recentlyLogged(profileId);
      expect(
        recent.map((r) => r.food.name),
        contains('Keripik Singkong Renyah'),
      );
    });
  });

  group('produk tanpa barcode (change 010, "Foto Info Gizi tanpa pindai")', () {
    PackagedFood transientProductWithoutBarcode({
      String name = 'Produk Tanpa Barcode',
    }) {
      return PackagedFood(
        food: Food(
          id: 'transient-food-no-barcode',
          name: name,
          category: FoodCategory.snack,
          isUserCreated: true,
          servings: <ServingSize>[
            ServingSize(
              id: 'transient-serving-no-barcode',
              label: '1 sajian',
              amount: 1,
              unit: 'sajian',
              isDefault: true,
              nutrition: NutritionProfile(
                energy: Energy.kcalValue(100, field: 'x').valueOrNull,
                proteinG: 1,
                carbohydrateG: 10,
                fatG: 3,
              ),
            ),
          ],
        ),
        servingBasis: ServingBasis.perServing,
        provenance: PackagedFoodProvenance(
          sourceType: 'label_extraction',
          verifiedAt: testInstant,
          userCorrected: false,
        ),
      );
    }

    test('tersimpan dengan barcode null dan dapat ditemukan lewat pencarian '
        'nama', () async {
      await repository.confirm(
        transientProductWithoutBarcode(name: 'Kue Tanpa Barcode'),
      );

      final foodRepository = DriftFoodRepository(
        db,
        ids: createTestIds(),
        clock: createTestClock(),
      );
      final bySearch = await foodRepository.search('Kue Tanpa Barcode');
      expect(bySearch.map((f) => f.name), contains('Kue Tanpa Barcode'));

      final row = await (db.select(
        db.packagedFoodProperties,
      )..where((t) => t.foodId.equals(bySearch.single.id))).getSingle();
      expect(row.barcode, isNull);
    });

    test('dua kali konfirmasi tanpa barcode menghasilkan DUA baris terpisah '
        '— tidak ada pengenal untuk dicocokkan', () async {
      await repository.confirm(transientProductWithoutBarcode());
      await repository.confirm(transientProductWithoutBarcode());

      final rows = await db.select(db.packagedFoodProperties).get();
      expect(rows, hasLength(2));
      expect(rows.every((r) => r.barcode == null), isTrue);
    });
  });
}
