import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/core/ids/sequential_id_generator.dart';
import 'package:mealora/data/local/drift_diary_repository.dart';
import 'package:mealora/data/local/drift_food_repository.dart';
import 'package:mealora/data/local/drift_profile_repository.dart';
import 'package:mealora/data/local/drift_program_repository.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/domain/food/food.dart';
import 'package:mealora/domain/food/food_category.dart';
import 'package:mealora/domain/food/meal_time.dart';
import 'package:mealora/domain/food/nutrition_profile.dart';
import 'package:mealora/domain/food/serving_size.dart';
import 'package:mealora/domain/profile/user_profile.dart';
import 'package:mealora/domain/shared/units.dart';
import 'package:mealora/features/diary/diary_format.dart';
import 'package:mealora/features/diary/serving_detail_screen.dart';
import 'package:mealora/features/diary/serving_picker_sheet.dart';

import 'harness.dart';

/// Kurasi katalog: takaran sehari-hari, penanda perkiraan, masukan gram,
/// pencarian, dan riwayat (change 015, task 5.5; FRS skenario 1–7).
void main() {
  const profileId = 'profile-1';
  const riceId = 'food-tkpi-1215';

  NutritionProfile kcal(double v) => NutritionProfile(
    energy: Energy.kcalValue(v, field: 'energyKcal').valueOrNull,
  );

  /// Nasi dengan takaran bawaan sehari-hari bertingkat perkiraan dan
  /// takaran asal 100 g (desain 67).
  const centong = ServingSize(
    id: 'rice-centong',
    label: '1 centong',
    amount: 1,
    unit: 'centong',
    isDefault: true,
    gramEquivalent: 100,
    nutrition: NutritionProfile(),
    provenanceTier: ServingProvenanceTier.estimate,
  );
  final hundred = ServingSize(
    id: 'rice-100g',
    label: '100 g',
    amount: 100,
    unit: 'gram',
    isDefault: false,
    gramEquivalent: 100,
    nutrition: kcal(130),
    provenanceTier: ServingProvenanceTier.official,
  );
  final curatedRice = Food(
    id: 'food-rice',
    name: 'Nasi putih',
    category: FoodCategory.staple,
    isUserCreated: false,
    servings: <ServingSize>[centong, hundred],
  );

  Future<AppDatabase> seededDb() async {
    final db = createWidgetTestDatabase();
    await DriftProfileRepository(
      db,
      clock: createWidgetTestClock(),
    ).upsert(const UserProfile(id: profileId));
    return db;
  }

  DriftFoodRepository foods(AppDatabase db) => DriftFoodRepository(
    db,
    ids: SequentialIdGenerator(prefix: 'f'),
    clock: createWidgetTestClock(),
  );

  DriftDiaryRepository diary(AppDatabase db) => DriftDiaryRepository(
    db,
    clock: createWidgetTestClock(),
    ids: SequentialIdGenerator(prefix: 'd'),
    programRepository: DriftProgramRepository(
      db,
      clock: createWidgetTestClock(),
      ids: SequentialIdGenerator(prefix: 'p'),
    ),
  );

  Future<void> pumpDetail(
    WidgetTester tester,
    Food food, {
    AppDatabase? db,
  }) async {
    await useDesignViewport(tester);
    await tester.pumpWidget(
      wrapForTest(
        ServingDetailScreen(food: food),
        database: db,
        overrides: <Override>[
          profileRepositoryAppOverride,
          foodRepositoryAppOverride,
          diaryRepositoryAppOverride,
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  group('takaran sehari-hari & penanda perkiraan (5.1)', () {
    testWidgets('takaran bawaan sehari-hari terpilih dan bertanda '
        'perkiraan; 100 g tetap dapat dipilih dengan beratnya', (tester) async {
      await pumpDetail(tester, curatedRice);
      expect(find.text('1 centong · 100 g'), findsOneWidget);
      expect(find.text('perkiraan'), findsOneWidget);

      await tester.tap(find.text('1 centong · 100 g'));
      await tester.pumpAndSettle();
      expect(find.text('Pilih sajian'), findsOneWidget);
      expect(find.text('≈ 100 g'), findsOneWidget);
      expect(find.text('berat langsung'), findsOneWidget);
      expect(find.text('Bawaan'), findsOneWidget);
      expect(find.text('Masukkan berat sendiri (g)'), findsOneWidget);

      await tester.tap(find.text('100 g'));
      await tester.pumpAndSettle();
      expect(find.text('perkiraan'), findsNothing);
      expect(find.text('130 kkal'), findsOneWidget);
    });

    testWidgets('tanpa padanan berat, masukan gram tidak ditawarkan', (
      tester,
    ) async {
      const plain = ServingSize(
        id: 'x',
        label: '1 porsi',
        amount: 1,
        unit: 'porsi',
        isDefault: true,
        nutrition: NutritionProfile(),
      );
      await pumpDetail(
        tester,
        const Food(
          id: 'f',
          name: 'Gado-gado',
          category: FoodCategory.sideDish,
          isUserCreated: false,
          servings: <ServingSize>[plain],
        ),
      );
      await tester.tap(find.text('1 porsi'));
      await tester.pumpAndSettle();
      expect(find.textContaining('Masukkan berat sendiri'), findsNothing);
    });
  });

  group('masukan gram (5.2)', () {
    Future<void> enterWeight(WidgetTester tester, String grams) async {
      await tester.tap(find.byIcon(Icons.restaurant_outlined));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Masukkan berat sendiri (g)'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), grams);
      await tester.pumpAndSettle();
    }

    testWidgets('150 g disimpan sebagai takaran 100 g × 1,5 (FRS 4)', (
      tester,
    ) async {
      final db = await seededDb();
      addTearDown(db.close);
      final rice = (await foods(db).findById(riceId))!;
      final per100 = rice.servingById('$riceId-default').nutrition.energy!.kcal;

      await pumpDetail(tester, rice, db: db);
      await enterWeight(tester, '150');
      final save = find.textContaining('Tambahkan ke');
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();

      final entries = await diary(
        db,
      ).entriesForDate(profileId, createWidgetTestClock().today());
      expect(entries, hasLength(1));
      expect(entries.single.servingId, '$riceId-default');
      expect(entries.single.quantity, 1.5);
      expect(
        entries.single.totalNutrition.energy!.kcal,
        closeTo(per100 * 1.5, 0.01),
      );
      expect(
        DiaryFormat.entryAmount(
          entries.single.servingLabelSnapshot,
          entries.single.quantity,
        ),
        '150 g',
      );
    });

    testWidgets('0 g ditolak dengan penjelasan dan tidak disimpan (FRS 5)', (
      tester,
    ) async {
      final db = await seededDb();
      addTearDown(db.close);
      final rice = (await foods(db).findById(riceId))!;

      await pumpDetail(tester, rice, db: db);
      await enterWeight(tester, '0');
      expect(find.textContaining('Berat harus lebih dari 0 g'), findsOneWidget);

      final save = find.textContaining('Tambahkan ke');
      await tester.ensureVisible(save);
      await tester.tap(save);
      await tester.pumpAndSettle();
      expect(find.byType(ServingDetailScreen), findsOneWidget);
      final entries = await diary(
        db,
      ).entriesForDate(profileId, createWidgetTestClock().today());
      expect(entries, isEmpty);
    });
  });

  group('pencarian (5.3)', () {
    test('"telor ceplok" menemukan telur ceplok (FRS 7)', () async {
      final db = await seededDb();
      addTearDown(db.close);
      final results = await foods(db).search('telor ceplok');
      expect(
        results.map((f) => f.name.toLowerCase()),
        contains('telur ayam ceplok'),
      );
    });

    test('bentuk siap konsumsi tampil sebelum bahan kering; makanan '
        'nonaktif tidak tampil (FRS 6)', () async {
      final db = await seededDb();
      addTearDown(db.close);
      final all = await foods(db).search('teh');
      final dry = all.firstWhere((f) => f.name == 'Teh hijau daun kering');
      final other = all.firstWhere((f) => f.name != 'Teh hijau daun kering');
      await (db.update(db.foods)..where((f) => f.id.equals(dry.id))).write(
        const FoodsCompanion(form: Value('dry')),
      );
      await (db.update(db.foods)..where((f) => f.id.equals(other.id))).write(
        const FoodsCompanion(form: Value('ready')),
      );
      final ordered = await foods(db).search('teh');
      final ids = ordered.map((f) => f.id).toList();
      expect(ids.indexOf(other.id), lessThan(ids.indexOf(dry.id)));

      await (db.update(db.foods)..where((f) => f.id.equals(dry.id))).write(
        const FoodsCompanion(isActive: Value(false)),
      );
      final active = await foods(db).search('teh');
      expect(active.map((f) => f.id), isNot(contains(dry.id)));
    });

    test(
      'sinonim hanya di awal kata: "mie" tidak cocok dengan "kismis"',
      () async {
        final db = await seededDb();
        addTearDown(db.close);
        final results = await foods(db).search('mie');
        expect(
          results.every(
            (f) => RegExp(r'\b(mie|mi)', caseSensitive: false).hasMatch(f.name),
          ),
          isTrue,
        );
      },
    );
  });

  test('terakhir dicatat tetap memakai takaran 100 g setelah takaran '
      'sehari-hari menjadi bawaan, termasuk untuk makanan nonaktif (5.4, '
      'FRS 2)', () async {
    final db = await seededDb();
    addTearDown(db.close);
    final rice = (await foods(db).findById(riceId))!;
    await diary(db).addEntry(
      profileId: profileId,
      date: createWidgetTestClock().today(),
      mealTime: MealTime.lunch,
      food: rice,
      serving: rice.servingById('$riceId-default'),
      quantity: 1,
    );
    // Pembaruan katalog: takaran centong menjadi bawaan, makanan nonaktif.
    await (db.update(db.foodServings)
          ..where((s) => s.id.equals('$riceId-default')))
        .write(const FoodServingsCompanion(isDefault: Value(false)));
    await db
        .into(db.foodServings)
        .insert(
          FoodServingsCompanion.insert(
            id: '$riceId-centong',
            createdAt: DateTime.utc(2026),
            updatedAt: DateTime.utc(2026),
            foodId: riceId,
            label: '1 centong',
            amount: 1,
            unit: 'centong',
            gramEquivalent: const Value(100),
            isDefault: const Value(true),
            provenanceTier: const Value('estimate'),
            provenanceNote: const Value('uji'),
          ),
        );
    await (db.update(db.foods)..where((f) => f.id.equals(riceId))).write(
      const FoodsCompanion(isActive: Value(false)),
    );

    final recent = await foods(db).recentlyLogged(profileId);
    expect(recent.single.food.id, riceId);
    expect(recent.single.lastServing.id, '$riceId-default');
  });

  test('format jumlah catatan', () {
    expect(DiaryFormat.entryAmount('100 g', 1.5), '150 g');
    expect(DiaryFormat.entryAmount('100 ml', 2.5), '250 ml');
    expect(DiaryFormat.entryAmount('1 centong', 1), '1 centong');
    expect(DiaryFormat.entryAmount('1 centong', 1.5), '1,5 × 1 centong');
    expect(formatWeight(150), '150');
  });
}
