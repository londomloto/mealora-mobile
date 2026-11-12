import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/core/ids/sequential_id_generator.dart';
import 'package:mealora/data/local/drift_food_repository.dart';
import 'package:mealora/data/local/drift_profile_repository.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/domain/food/food.dart';
import 'package:mealora/domain/food/food_category.dart';
import 'package:mealora/domain/food/food_repository.dart';
import 'package:mealora/domain/food/nutrition_profile.dart';
import 'package:mealora/domain/food/recipe.dart';
import 'package:mealora/domain/food/recipe_calculator.dart';
import 'package:mealora/domain/profile/user_profile.dart';
import 'package:mealora/domain/shared/units.dart';
import 'package:mealora/features/diary/custom_food_screen.dart';

import 'harness.dart';

/// Hitung gizi dari bahan di `CustomFoodScreen` (change 016, task 4.1).
void main() {
  late AppDatabase db;
  late DriftFoodRepository repo;

  Energy kcal(double v) => Energy.kcalValue(v, field: 'e').valueOrNull!;

  setUp(() async {
    db = createWidgetTestDatabase();
    await DriftProfileRepository(
      db,
      clock: createWidgetTestClock(),
    ).upsert(const UserProfile(id: 'profile-1'));
    repo = DriftFoodRepository(
      db,
      ids: SequentialIdGenerator(prefix: 'seed'),
      clock: createWidgetTestClock(),
    );
  });
  tearDown(() => db.close());

  Future<Food> per100g(String name, double energy) => repo.createUserFood(
    name: name,
    category: FoodCategory.other,
    serving: ServingSizeInput(
      label: '100 g',
      amount: 100,
      unit: 'g',
      gramEquivalent: 100,
      nutrition: NutritionProfile(
        energy: kcal(energy),
        proteinG: 1,
        carbohydrateG: 1,
        fatG: 1,
      ),
    ),
  );

  Future<void> pump(WidgetTester tester, {Food? editFood}) async {
    await useDesignViewport(tester);
    await tester.pumpWidget(
      wrapForTest(
        CustomFoodScreen(editFood: editFood),
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

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> openRecipeMode(WidgetTester tester) =>
      tapVisible(tester, find.text('Hitung dari bahan'));

  Future<void> addIngredient(
    WidgetTester tester, {
    required String query,
    required String result,
    required String amount,
    String? mode,
  }) async {
    await tapVisible(
      tester,
      find.byKey(const ValueKey('recipe-add-ingredient')),
    );
    await tester.enterText(find.byType(TextField).last, query);
    // Melewati jeda ketik pencarian (250 ms).
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    await tester.tap(find.text(result).last);
    await tester.pumpAndSettle();
    if (mode != null) {
      await tester.tap(find.text(mode));
      await tester.pumpAndSettle();
    }
    await tester.enterText(
      find.byKey(const ValueKey('recipe-amount-input')),
      amount,
    );
    await tester.tap(find.text('Tambah ke resep'));
    await tester.pumpAndSettle();
  }

  Future<void> save(WidgetTester tester) async {
    await tapVisible(tester, find.text('Simpan makanan'));
  }

  Future<FoodRow> savedFood(String name) =>
      (db.select(db.foods)..where((t) => t.name.equals(name))).getSingle();

  Future<void> enterName(WidgetTester tester, String name) =>
      tester.enterText(find.byType(TextField).first, name);

  testWidgets('isi manual tetap bawaan dan tersimpan tanpa bahan', (
    tester,
  ) async {
    await pump(tester);
    expect(find.text('Ukuran sajian'), findsOneWidget);
    await enterName(tester, 'Tumis buncis');
    await tester.enterText(find.byType(TextField).at(1), '1 porsi');
    await save(tester);

    final food = await savedFood('Tumis buncis');
    expect(food.nutritionOrigin, 'manual');
    expect(await db.select(db.recipeIngredients).get(), isEmpty);
  });

  testWidgets('menjumlahkan bahan dalam gram (358 kkal), tersimpan sebagai '
      'resep', (tester) async {
    await per100g('Zuba nasi', 180);
    await per100g('Zuba tempe', 160);
    await pump(tester);
    await enterName(tester, 'Nasi tempe');
    await openRecipeMode(tester);

    await addIngredient(
      tester,
      query: 'zuba',
      result: 'Zuba nasi',
      amount: '150',
    );
    await addIngredient(
      tester,
      query: 'zuba tempe',
      result: 'Zuba tempe',
      amount: '55',
    );

    expect(find.text('Bahan (2)'), findsOneWidget);
    expect(find.text('270 kkal'), findsOneWidget);
    expect(find.text('88 kkal'), findsOneWidget);
    expect(find.widgetWithText(TextField, '358'), findsOneWidget);

    await save(tester);
    final food = await savedFood('Nasi tempe');
    expect(food.nutritionOrigin, 'recipe');
    expect(food.recipeYieldServings, 1);
    expect(await db.select(db.recipeIngredients).get(), hasLength(2));
  });

  testWidgets('takaran "1 butir" dihitung dengan gizi takarannya', (
    tester,
  ) async {
    await repo.createUserFood(
      name: 'Zuba telur',
      category: FoodCategory.other,
      serving: ServingSizeInput(
        label: '1 butir',
        amount: 1,
        unit: 'butir',
        gramEquivalent: 55,
        nutrition: NutritionProfile(energy: kcal(88)),
      ),
    );
    await pump(tester);
    await openRecipeMode(tester);
    await addIngredient(
      tester,
      query: 'zuba telur',
      result: 'Zuba telur',
      amount: '1',
      mode: 'Takaran (1 butir)',
    );
    expect(find.widgetWithText(TextField, '88'), findsOneWidget);
  });

  testWidgets('jumlah bahan 0 ditolak dengan penjelasan', (tester) async {
    await per100g('Zuba nasi', 180);
    await pump(tester);
    await openRecipeMode(tester);
    await tapVisible(
      tester,
      find.byKey(const ValueKey('recipe-add-ingredient')),
    );
    await tester.enterText(find.byType(TextField).last, 'zuba');
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zuba nasi').last);
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('recipe-amount-input')),
      '0',
    );
    await tester.tap(find.text('Tambah ke resep'));
    await tester.pumpAndSettle();
    expect(find.text('Jumlah harus lebih dari 0.'), findsOneWidget);
    expect(find.text('Tambah ke resep'), findsOneWidget);
  });

  testWidgets('bahan tanpa data menandai total tidak lengkap dan menyebut '
      'bahannya; menghapusnya mencabut penanda', (tester) async {
    await per100g('Zuba nasi', 180);
    await pump(tester);
    await openRecipeMode(tester);
    await addIngredient(
      tester,
      query: 'zuba',
      result: 'Zuba nasi',
      amount: '100',
    );

    await tapVisible(
      tester,
      find.byKey(const ValueKey('recipe-add-ingredient')),
    );
    await tester.enterText(find.byType(TextField).last, 'bumbu racik');
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Tambah tanpa data gizi'));
    await tester.tap(
      find
          .descendant(
            of: find.byType(AlertDialog),
            matching: find.byType(TextButton),
          )
          .last,
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('recipe-amount-input')),
      '1',
    );
    await tester.tap(find.text('Tambah ke resep'));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Total belum lengkap: bumbu racik'),
      findsOneWidget,
    );
    expect(find.text('tidak lengkap'), findsWidgets);

    await tapVisible(tester, find.byTooltip('Hapus bumbu racik'));
    // Fixture bahan tanpa serat/gula/natrium: zat yang tidak ditampilkan
    // tidak memunculkan penanda.
    expect(find.textContaining('Total belum lengkap'), findsNothing);
    expect(find.text('tidak lengkap'), findsNothing);
    expect(find.text('Bahan (1)'), findsOneWidget);
  });

  testWidgets('membuat bahan baru dari pemilihan bahan (isi per 100 g)', (
    tester,
  ) async {
    await pump(tester);
    await openRecipeMode(tester);
    await tapVisible(
      tester,
      find.byKey(const ValueKey('recipe-add-ingredient')),
    );
    await tester.enterText(find.byType(TextField).last, 'Zuba kecap');
    await tester.pumpAndSettle();
    await tapVisible(tester, find.text('Buat bahan baru'));
    expect(find.text('Nilai gizi per 100 g'), findsOneWidget);
    // Kolom lembar buat bahan: nama, energi, protein, karbohidrat, lemak.
    final fields = find.byType(TextField);
    await tester.enterText(fields.at(fields.evaluate().length - 4), '250');
    await tester.tap(find.text('Simpan'));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byKey(const ValueKey('recipe-amount-input')),
      '20',
    );
    await tester.tap(find.text('Tambah ke resep'));
    await tester.pumpAndSettle();

    expect(find.text('Bahan (1)'), findsOneWidget);
    expect(find.text('50 kkal'), findsOneWidget);
    final created = await savedFood('Zuba kecap');
    expect(created.isUserCreated, isTrue);

    // Kueri yang sama sebelum bahan dibuat kini menemukan bahan itu.
    await tapVisible(
      tester,
      find.byKey(const ValueKey('recipe-add-ingredient')),
    );
    await tester.enterText(find.byType(TextField).last, 'Zuba kecap');
    await tester.pumpAndSettle();
    expect(find.text('Zuba kecap'), findsWidgets);
    expect(find.text('Tidak ditemukan'), findsNothing);
  });

  testWidgets('mengoreksi hasil hitungan menyimpan nilai koreksi dengan asal '
      'manual', (tester) async {
    await per100g('Zuba nasi', 180);
    await pump(tester);
    await enterName(tester, 'Nasi koreksi');
    await openRecipeMode(tester);
    await addIngredient(
      tester,
      query: 'zuba',
      result: 'Zuba nasi',
      amount: '100',
    );
    await tester.enterText(find.widgetWithText(TextField, '180'), '200');
    await tester.pumpAndSettle();
    expect(find.text('Hitung ulang dari bahan'), findsOneWidget);

    await save(tester);
    final food = await savedFood('Nasi koreksi');
    expect(food.nutritionOrigin, 'manual');
    final saved = (await repo.findById(food.id))!;
    expect(saved.defaultServing.nutrition.energy!.kcal, 200);
  });

  testWidgets('menyunting resep menampilkan bahan dan menghitung ulang setelah '
      'bahan dihapus', (tester) async {
    final rice = await per100g('Zuba nasi', 180);
    final egg = await per100g('Zuba telur', 160);
    final food = await repo.createRecipeFood(
      name: 'Nasi telur',
      category: FoodCategory.other,
      ingredients: <RecipeIngredientInput>[
        RecipeIngredientInput.food(
          foodId: rice.id,
          servingId: rice.defaultServing.id,
          amount: const RecipeGrams(150),
        ),
        RecipeIngredientInput.food(
          foodId: egg.id,
          servingId: egg.defaultServing.id,
          amount: const RecipeGrams(55),
        ),
      ],
      recipeYield: const RecipeYield(servings: 1),
      perServing: NutritionProfile(energy: kcal(358)),
      origin: NutritionOrigin.recipe,
    );

    await pump(tester, editFood: food);
    expect(find.text('Sunting makanan'), findsOneWidget);
    expect(find.text('Bahan (2)'), findsOneWidget);
    expect(find.widgetWithText(TextField, '358'), findsOneWidget);

    await tapVisible(tester, find.byTooltip('Hapus Zuba telur'));
    expect(find.widgetWithText(TextField, '270'), findsOneWidget);
  });
}
