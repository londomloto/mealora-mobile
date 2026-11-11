import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/core/ids/sequential_id_generator.dart';
import 'package:mealora/data/local/drift_packaged_food_repository.dart';
import 'package:mealora/data/local/drift_profile_repository.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/domain/food/food.dart';
import 'package:mealora/domain/food/food_category.dart';
import 'package:mealora/domain/food/nutrition_profile.dart';
import 'package:mealora/domain/food/serving_size.dart';
import 'package:mealora/domain/packaged_food/packaged_food.dart';
import 'package:mealora/domain/packaged_food/packaged_food_provenance.dart';
import 'package:mealora/domain/packaged_food/product_data_source_client.dart';
import 'package:mealora/domain/packaged_food/serving_basis.dart';
import 'package:mealora/domain/profile/user_profile.dart';
import 'package:mealora/domain/shared/units.dart';
import 'package:mealora/features/diary/diary_controller.dart';
import 'package:mealora/features/diary/packaged_food_review_screen.dart';

import 'harness.dart';

/// `04 · Tinjau produk kemasan` (tasks 7.1-7.8, change 009): angka nyata
/// 150 kkal/sajian · 2 sajian/kemasan (task 3.7), pencatatan hanya setelah
/// konfirmasi eksplisit (task 7.5), dan jalur pencatatan yang sama dengan
/// makanan lain (task 7.6).
void main() {
  const profileId = 'profile-1';

  Future<AppDatabase> seededDatabase() async {
    final db = createWidgetTestDatabase();
    await DriftProfileRepository(
      db,
      clock: createWidgetTestClock(),
    ).upsert(const UserProfile(id: profileId));
    return db;
  }

  Override packagedFoodOverride(AppDatabase db) =>
      packagedFoodRepositoryProvider.overrideWith(
        (ref) => DriftPackagedFoodRepository(
          db,
          ids: SequentialIdGenerator(),
          clock: createWidgetTestClock(),
          client: const _NeverCalledClient(),
        ),
      );

  List<Override> overridesFor(AppDatabase db) => <Override>[
    profileRepositoryAppOverride,
    foodRepositoryAppOverride,
    diaryRepositoryAppOverride,
    packagedFoodOverride(db),
  ];

  PackagedFood goldenProduct({bool userCorrected = false}) => PackagedFood(
    food: Food(
      id: 'transient-food',
      name: 'Keripik Singkong Renyah',
      brand: 'MerekA',
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
            energy: Energy.kcalValue(150, field: 'x').valueOrNull,
            proteinG: 2,
            carbohydrateG: 18,
            fatG: 7,
          ),
        ),
      ],
    ),
    barcode: '8991234567890',
    packageSize: '60 g',
    unitsPerPackage: 2,
    servingBasis: ServingBasis.perServing,
    provenance: PackagedFoodProvenance(
      sourceType: 'openfoodfacts',
      sourceRef: '8991234567890',
      sourceVersion: '2026-11-01',
      verifiedAt: DateTime.utc(2026, 11, 1),
      userCorrected: userCorrected,
    ),
  );

  testWidgets(
    'menampilkan nilai per sajian dan memilih 1 kemasan mengalikan ke '
    '300 kkal (task 3.7/7.2/7.3)',
    (tester) async {
      final db = await seededDatabase();
      addTearDown(db.close);

      await tester.pumpWidget(
        wrapForTest(
          PackagedFoodReviewScreen(product: goldenProduct()),
          database: db,
          overrides: overridesFor(db),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Keripik Singkong Renyah'), findsOneWidget);
      expect(find.textContaining('150 kkal'), findsWidgets);
      expect(
        find.byIcon(Icons.arrow_back),
        findsOneWidget,
        reason:
            'layar yang dibuka lewat push SHALL selalu punya jalan '
            'kembali yang terlihat, bukan hanya gestur OS/browser',
      );

      final wholePackagePill = find.textContaining('1 kemasan');
      await tester.ensureVisible(wholePackagePill);
      await tester.tap(wholePackagePill);
      await tester.pumpAndSettle();

      expect(find.textContaining('300 kkal'), findsWidgets);
    },
  );

  testWidgets(
    'menutup layar tanpa menekan konfirmasi tidak membuat catatan apa pun '
    '(task 7.5)',
    (tester) async {
      final db = await seededDatabase();
      addTearDown(db.close);

      await tester.pumpWidget(
        wrapForTest(
          PackagedFoodReviewScreen(product: goldenProduct()),
          database: db,
          overrides: overridesFor(db),
        ),
      );
      await tester.pumpAndSettle();

      final entries = await db.select(db.mealEntries).get();
      expect(entries, isEmpty);
    },
  );

  testWidgets(
    'menekan konfirmasi mencatat satu butir lewat jalur buku harian yang '
    'sama (task 7.6)',
    (tester) async {
      final db = await seededDatabase();
      addTearDown(db.close);

      await tester.pumpWidget(
        wrapForTest(
          PackagedFoodReviewScreen(product: goldenProduct()),
          database: db,
          overrides: overridesFor(db),
        ),
      );
      await tester.pumpAndSettle();

      final confirmButton = find.textContaining('Catat ·');
      await tester.ensureVisible(confirmButton);
      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      final entries = await db.select(db.mealEntries).get();
      expect(entries, hasLength(1));
      final items = await db.select(db.mealEntryItems).get();
      expect(items, hasLength(1));
      expect(items.single.energyKcalSnapshot, 150);
      expect(items.single.quantity, 1);

      final packagedRows = await db.select(db.packagedFoodProperties).get();
      expect(packagedRows, hasLength(1));
      expect(packagedRows.single.barcode, '8991234567890');
    },
  );

  testWidgets('tetap terbaca pada skala teks besar (task 6.6/8.3)', (
    tester,
  ) async {
    final db = await seededDatabase();
    addTearDown(db.close);

    await tester.pumpWidget(
      wrapForTest(
        PackagedFoodReviewScreen(product: goldenProduct(userCorrected: true)),
        database: db,
        overrides: overridesFor(db),
        textScale: 2,
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Dikoreksi'), findsOneWidget);
  });
}

/// Klien tiruan yang gagal bila terpanggil — layar tinjau tidak pernah
/// memicu pencarian daring (jalur itu hanya dari layar pindai/masukan
/// manual, bukan dari layar tinjau).
final class _NeverCalledClient implements ProductDataSourceClient {
  const _NeverCalledClient();

  @override
  Future<RemoteProductLookup?> lookupByBarcode(String barcode) {
    throw StateError('Layar tinjau SHALL TIDAK memanggil sumber daring.');
  }
}
