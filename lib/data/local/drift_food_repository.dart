import 'package:drift/drift.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/ids/id_generator.dart';
import 'package:mealora/data/local/user_record_support.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/database/seeds/food_catalog_seed.dart';
import 'package:mealora/database/tables/food_servings_table.dart';
import 'package:mealora/database/tables/foods_table.dart';
import 'package:mealora/database/tables/meal_entries_table.dart';
import 'package:mealora/database/tables/meal_entry_items_table.dart';
import 'package:mealora/database/tables/nutrition_values_table.dart';
import 'package:mealora/database/tables/recipe_ingredients_table.dart';
import 'package:mealora/domain/food/food.dart';
import 'package:mealora/domain/food/food_category.dart';
import 'package:mealora/domain/food/food_provenance.dart';
import 'package:mealora/domain/food/food_repository.dart';
import 'package:mealora/domain/food/nutrition_profile.dart';
import 'package:mealora/domain/food/recent_food.dart';
import 'package:mealora/domain/food/recipe.dart';
import 'package:mealora/domain/food/recipe_calculator.dart';
import 'package:mealora/domain/food/serving_size.dart';
import 'package:mealora/domain/shared/units.dart';

part 'drift_food_repository.g.dart';

/// Implementasi `FoodRepository` (change 007) memakai DAO Drift — Drift
/// tidak pernah bocor ke lapisan domain (Design D9, change 004).
@DriftAccessor(
  tables: <Type>[
    Foods,
    FoodServings,
    NutritionValues,
    MealEntries,
    MealEntryItems,
    RecipeIngredients,
  ],
)
class DriftFoodRepository extends DatabaseAccessor<AppDatabase>
    with _$DriftFoodRepositoryMixin
    implements FoodRepository {
  DriftFoodRepository(
    super.db, {
    required IdGenerator ids,
    required Clock clock,
  }) : _ids = ids,
       _clock = clock;

  final IdGenerator _ids;
  final Clock _clock;

  @override
  Future<Food?> findById(String id) async {
    final row =
        await (select(foods)
              ..where((t) => t.id.equals(id) & UserRecords.active(t.deletedAt)))
            .getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _assemble(row);
  }

  @override
  Future<List<Food>> search(String query) async {
    final tokens = query
        .trim()
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();
    if (tokens.isEmpty) {
      return const <Food>[];
    }
    // Setiap kata kueri harus muncul di nama (urutan bebas), dengan sinonim
    // sehari-hari dari `synonyms.csv` sebagai alternatif ("telor" → telur,
    // change 015 D8). Kata asli dicocokkan sebagai potongan seperti
    // sebelumnya; sinonim hanya di awal kata supaya "mi" tidak cocok dengan
    // "kismis". SQLite `LIKE` tidak peka huruf besar-kecil untuk ASCII.
    final trimmed = query.trim();
    final rows =
        await (select(foods)
              ..where((t) {
                var condition =
                    UserRecords.active(t.deletedAt) & t.isActive.equals(true);
                for (final token in tokens) {
                  var any = t.name.like('%$token%');
                  for (final alt in _synonymsOf(token)) {
                    any = any | t.name.like('$alt%') | t.name.like('% $alt%');
                  }
                  condition = condition & any;
                }
                return condition;
              })
              ..orderBy([
                // Bentuk siap konsumsi lebih dulu, bahan mentah/kering
                // terakhir (spec food-catalog, "Bentuk siap konsumsi
                // dibedakan dari bahan").
                (t) => OrderingTerm(
                  expression: CaseWhenExpression<int>(
                    cases: [
                      CaseWhen(
                        t.form.equals('ready'),
                        then: const Constant<int>(0),
                      ),
                      CaseWhen(
                        t.form.isIn(const <String>['raw', 'dry']),
                        then: const Constant<int>(2),
                      ),
                    ],
                    orElse: const Constant<int>(1),
                  ),
                ),
                (t) => OrderingTerm(
                  expression: CaseWhenExpression<int>(
                    cases: [
                      CaseWhen(
                        t.name.like('$trimmed%'),
                        then: const Constant<int>(0),
                      ),
                    ],
                    orElse: const Constant<int>(1),
                  ),
                ),
                (t) => OrderingTerm.asc(t.name),
              ]))
            .get();
    return _assembleAll(rows);
  }

  /// Merakit banyak [rows] sekaligus dengan dua kueri per potongan (takaran
  /// + gizi), bukan 1 + N kueri per makanan — kueri pendek seperti "nasi"
  /// bisa mencocokkan ratusan makanan.
  Future<List<Food>> _assembleAll(List<FoodRow> rows) async {
    if (rows.isEmpty) {
      return const <Food>[];
    }
    // Di bawah batas variabel SQLite (999 pada versi lama).
    const chunkSize = 500;
    final servingsByFood = <String, List<FoodServingRow>>{};
    for (var i = 0; i < rows.length; i += chunkSize) {
      final ids = [for (final r in rows.skip(i).take(chunkSize)) r.id];
      final servingRows =
          await (select(foodServings)..where(
                (t) => t.foodId.isIn(ids) & UserRecords.active(t.deletedAt),
              ))
              .get();
      for (final s in servingRows) {
        (servingsByFood[s.foodId] ??= <FoodServingRow>[]).add(s);
      }
    }
    final allServingIds = [
      for (final list in servingsByFood.values)
        for (final s in list) s.id,
    ];
    final nutritionByServing = <String, NutritionValueRow>{};
    for (var i = 0; i < allServingIds.length; i += chunkSize) {
      final ids = allServingIds.skip(i).take(chunkSize).toList();
      final nutritionRows = await (select(
        nutritionValues,
      )..where((t) => t.servingId.isIn(ids))).get();
      for (final n in nutritionRows) {
        nutritionByServing[n.servingId] = n;
      }
    }
    return <Food>[
      for (final row in rows)
        _foodFrom(row, <ServingSize>[
          for (final s in servingsByFood[row.id] ?? const <FoodServingRow>[])
            _servingWith(s, nutritionByServing[s.id]),
        ]),
    ];
  }

  /// Bentuk lain dari [token] menurut sinonim pencarian, dua arah.
  static Set<String> _synonymsOf(String token) => <String>{
    ?kFoodSearchSynonyms[token],
    for (final e in kFoodSearchSynonyms.entries)
      if (e.value == token) e.key,
  }..remove(token);

  @override
  Future<List<RecentFood>> recentlyLogged(
    String profileId, {
    int limit = 10,
  }) async {
    final query =
        select(mealEntryItems).join([
            innerJoin(
              mealEntries,
              mealEntries.id.equalsExp(mealEntryItems.mealEntryId),
            ),
          ])
          ..where(
            mealEntries.profileId.equals(profileId) &
                UserRecords.active(mealEntries.deletedAt) &
                UserRecords.active(mealEntryItems.deletedAt),
          )
          ..orderBy([OrderingTerm.desc(mealEntries.createdAt)]);

    final rows = await query.get();
    final seenFoodIds = <String>{};
    final result = <RecentFood>[];
    for (final row in rows) {
      final item = row.readTable(mealEntryItems);
      final entry = row.readTable(mealEntries);
      if (!seenFoodIds.add(item.foodId)) {
        continue;
      }
      final food = await findById(item.foodId);
      if (food == null) {
        continue;
      }
      final serving = food.servings
          .where((s) => s.id == item.servingId)
          .firstOrNull;
      if (serving == null) {
        continue;
      }
      result.add(
        RecentFood(
          food: food,
          lastServing: serving,
          lastLoggedAt: entry.createdAt,
        ),
      );
      if (result.length >= limit) {
        break;
      }
    }
    return result;
  }

  @override
  Future<Food> createUserFood({
    required String name,
    required FoodCategory category,
    required ServingSizeInput serving,
  }) async {
    final now = _clock.nowUtc();
    final foodId = _ids.next();
    final servingId = _ids.next();
    await transaction(() async {
      await into(foods).insert(
        FoodsCompanion.insert(
          id: foodId,
          createdAt: now,
          updatedAt: now,
          name: name,
          category: category.stableCode,
          isUserCreated: const Value<bool>(true),
          nutritionOrigin: Value<String?>(NutritionOrigin.manual.stableCode),
        ),
      );
      await _writeServing(
        servingId: servingId,
        foodId: foodId,
        serving: serving,
        now: now,
      );
    });
    return (await findById(foodId))!;
  }

  @override
  Future<Food> updateUserFood(
    String foodId, {
    required String name,
    required ServingSizeInput serving,
  }) async {
    final now = _clock.nowUtc();
    final existing = await (select(
      foods,
    )..where((t) => t.id.equals(foodId))).getSingle();
    final servingRow =
        await (select(
              foodServings,
            )..where((t) => t.foodId.equals(foodId) & t.isDefault.equals(true)))
            .getSingle();

    await transaction(() async {
      await (update(foods)..where((t) => t.id.equals(foodId))).write(
        FoodsCompanion(
          name: Value<String>(name),
          updatedAt: Value<DateTime>(now),
          createdAt: Value<DateTime>(existing.createdAt),
          revision: Value<int>(existing.revision + 1),
          // Isi manual atas makanan resep: resep tetap tersimpan sebagai
          // rujukan, tapi bukan lagi sumber angka (Design D4).
          nutritionOrigin: Value<String?>(NutritionOrigin.manual.stableCode),
        ),
      );
      // Takaran tambahan (mis. "100 g" makanan resep) akan basi terhadap
      // nilai manual baru, jadi dihapus lunak; catatan lama tetap utuh
      // karena menyimpan potret gizinya sendiri.
      await (update(foodServings)..where(
            (t) =>
                t.foodId.equals(foodId) &
                t.isDefault.equals(false) &
                UserRecords.active(t.deletedAt),
          ))
          .write(FoodServingsCompanion(deletedAt: Value<DateTime?>(now)));
      await (update(
        foodServings,
      )..where((t) => t.id.equals(servingRow.id))).write(
        FoodServingsCompanion(
          label: Value<String>(serving.label),
          amount: Value<double>(serving.amount),
          unit: Value<String>(serving.unit),
          gramEquivalent: Value<double?>(serving.gramEquivalent),
          updatedAt: Value<DateTime>(now),
        ),
      );
      final nutritionRow = await (select(
        nutritionValues,
      )..where((t) => t.servingId.equals(servingRow.id))).getSingle();
      await (update(nutritionValues)
            ..where((t) => t.id.equals(nutritionRow.id)))
          .write(_nutritionCompanion(serving.nutrition, updatedAt: now));
    });

    return (await findById(foodId))!;
  }

  @override
  Future<Food> createRecipeFood({
    required String name,
    required FoodCategory category,
    required List<RecipeIngredientInput> ingredients,
    required RecipeYield recipeYield,
    required NutritionProfile perServing,
    required NutritionOrigin origin,
  }) async {
    _checkRecipe(ingredients, recipeYield);
    final now = _clock.nowUtc();
    final foodId = _ids.next();
    await transaction(() async {
      await into(foods).insert(
        FoodsCompanion.insert(
          id: foodId,
          createdAt: now,
          updatedAt: now,
          name: name,
          category: category.stableCode,
          isUserCreated: const Value<bool>(true),
          nutritionOrigin: Value<String?>(origin.stableCode),
          recipeYieldServings: Value<double?>(recipeYield.servings),
          recipeYieldGrams: Value<double?>(recipeYield.finishedGrams),
        ),
      );
      await _writeRecipeServings(foodId, recipeYield, perServing, now);
      await _writeIngredients(foodId, ingredients, now);
    });
    return (await findById(foodId))!;
  }

  @override
  Future<Food> updateRecipeFood(
    String foodId, {
    required String name,
    required List<RecipeIngredientInput> ingredients,
    required RecipeYield recipeYield,
    required NutritionProfile perServing,
    required NutritionOrigin origin,
  }) async {
    _checkRecipe(ingredients, recipeYield);
    final now = _clock.nowUtc();
    final existing = await (select(
      foods,
    )..where((t) => t.id.equals(foodId))).getSingle();
    await transaction(() async {
      await (update(foods)..where((t) => t.id.equals(foodId))).write(
        FoodsCompanion(
          name: Value<String>(name),
          updatedAt: Value<DateTime>(now),
          revision: Value<int>(existing.revision + 1),
          nutritionOrigin: Value<String?>(origin.stableCode),
          recipeYieldServings: Value<double?>(recipeYield.servings),
          recipeYieldGrams: Value<double?>(recipeYield.finishedGrams),
        ),
      );
      await (update(recipeIngredients)..where(
            (t) =>
                t.recipeFoodId.equals(foodId) & UserRecords.active(t.deletedAt),
          ))
          .write(RecipeIngredientsCompanion(deletedAt: Value<DateTime?>(now)));
      await _writeRecipeServings(foodId, recipeYield, perServing, now);
      await _writeIngredients(foodId, ingredients, now);
    });
    return (await findById(foodId))!;
  }

  @override
  Future<SavedRecipe?> recipeOf(String foodId) async {
    final food = await (select(
      foods,
    )..where((t) => t.id.equals(foodId))).getSingleOrNull();
    if (food == null || food.recipeYieldServings == null) {
      return null;
    }
    final rows =
        await (select(recipeIngredients)
              ..where(
                (t) =>
                    t.recipeFoodId.equals(foodId) &
                    UserRecords.active(t.deletedAt),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.position)]))
            .get();
    final ingredients = <SavedRecipeIngredient>[];
    for (final row in rows) {
      final amount = row.grams != null
          ? RecipeGrams(row.grams!)
          : RecipeServingMultiple(row.servingMultiple!);
      if (row.ingredientFoodId == null) {
        ingredients.add(
          SavedRecipeIngredient(label: row.freeTextName!, amount: amount),
        );
        continue;
      }
      // Bahan dibaca tanpa saringan terhapus: makanan/takaran yang dipakai
      // resep tetap dihitung dengan nilai tersimpannya.
      final ingredientRow = await (select(
        foods,
      )..where((t) => t.id.equals(row.ingredientFoodId!))).getSingle();
      final ingredientFood = await _assemble(ingredientRow);
      final servingRow = await (select(
        foodServings,
      )..where((t) => t.id.equals(row.ingredientServingId!))).getSingle();
      ingredients.add(
        SavedRecipeIngredient(
          label: ingredientFood.name,
          food: ingredientFood,
          serving: await _servingFrom(servingRow),
          amount: amount,
        ),
      );
    }
    return SavedRecipe(
      ingredients: ingredients,
      recipeYield: RecipeYield(
        servings: food.recipeYieldServings!,
        finishedGrams: food.recipeYieldGrams,
      ),
    );
  }

  @override
  Future<void> deleteUserFood(String foodId) async {
    final recipe = alias(foods, 'recipe');
    final usages =
        await (select(recipeIngredients).join([
              innerJoin(
                recipe,
                recipe.id.equalsExp(recipeIngredients.recipeFoodId),
              ),
            ])..where(
              recipeIngredients.ingredientFoodId.equals(foodId) &
                  UserRecords.active(recipeIngredients.deletedAt) &
                  UserRecords.active(recipe.deletedAt),
            ))
            .get();
    if (usages.isNotEmpty) {
      throw FoodInUseAsIngredientException(
        <String>{
          for (final row in usages) row.readTable(recipe).name,
        }.toList(growable: false),
      );
    }
    final now = _clock.nowUtc();
    await (update(
      foods,
    )..where((t) => t.id.equals(foodId) & t.isUserCreated.equals(true))).write(
      FoodsCompanion(
        deletedAt: Value<DateTime?>(now),
        updatedAt: Value<DateTime>(now),
      ),
    );
  }

  void _checkRecipe(
    List<RecipeIngredientInput> ingredients,
    RecipeYield recipeYield,
  ) {
    if (ingredients.isEmpty) {
      throw ArgumentError.value(ingredients, 'ingredients', 'kosong');
    }
    if (RecipeValidation.positive(recipeYield.servings) != null ||
        (recipeYield.finishedGrams != null &&
            RecipeValidation.positive(recipeYield.finishedGrams) != null)) {
      throw ArgumentError.value(recipeYield, 'recipeYield');
    }
    for (final i in ingredients) {
      if (RecipeValidation.positive(i.amount.value) != null) {
        throw ArgumentError.value(i.amount.value, 'amount');
      }
    }
  }

  Future<void> _writeIngredients(
    String recipeFoodId,
    List<RecipeIngredientInput> ingredients,
    DateTime now,
  ) async {
    for (final (position, i) in ingredients.indexed) {
      await into(recipeIngredients).insert(
        RecipeIngredientsCompanion.insert(
          id: _ids.next(),
          createdAt: now,
          updatedAt: now,
          recipeFoodId: recipeFoodId,
          ingredientFoodId: Value<String?>(i.foodId),
          ingredientServingId: Value<String?>(i.servingId),
          freeTextName: Value<String?>(i.freeTextName),
          grams: Value<double?>(
            i.amount is RecipeGrams ? i.amount.value : null,
          ),
          servingMultiple: Value<double?>(
            i.amount is RecipeServingMultiple ? i.amount.value : null,
          ),
          position: position,
        ),
      );
    }
  }

  /// Takaran makanan resep (task 2.2): "1 porsi" bawaan berisi gizi per
  /// sajian; bila berat jadi diisi, porsi diberi padanan gram dan takaran
  /// "100 g" ditambahkan supaya makanan bisa dicatat dalam gram dan dipakai
  /// sebagai bahan resep lain.
  Future<void> _writeRecipeServings(
    String foodId,
    RecipeYield recipeYield,
    NutritionProfile perServing,
    DateTime now,
  ) async {
    final finished = recipeYield.finishedGrams;
    final portionGrams = finished == null
        ? null
        : finished / recipeYield.servings;
    final portion = ServingSizeInput(
      label: portionGrams == null
          ? '1 porsi'
          : '1 porsi · ${_formatGrams(portionGrams)} g',
      amount: 1,
      unit: 'porsi',
      gramEquivalent: portionGrams,
      nutrition: perServing,
    );

    final active =
        await (select(foodServings)..where(
              (t) => t.foodId.equals(foodId) & UserRecords.active(t.deletedAt),
            ))
            .get();
    final defaultRow = active.where((s) => s.isDefault).firstOrNull;
    if (defaultRow == null) {
      await _writeServing(
        servingId: _ids.next(),
        foodId: foodId,
        serving: portion,
        now: now,
      );
    } else {
      await _updateServing(defaultRow.id, portion, now);
    }

    final weightRow = active
        .where((s) => !s.isDefault && s.unit == 'g' && s.amount == 100)
        .firstOrNull;
    if (portionGrams == null) {
      if (weightRow != null) {
        await (update(foodServings)..where((t) => t.id.equals(weightRow.id)))
            .write(FoodServingsCompanion(deletedAt: Value<DateTime?>(now)));
      }
      return;
    }
    final per100g = ServingSizeInput(
      label: '100 g',
      amount: 100,
      unit: 'g',
      gramEquivalent: 100,
      nutrition: perServing.scaledBy(100 / portionGrams),
    );
    if (weightRow == null) {
      await _writeServing(
        servingId: _ids.next(),
        foodId: foodId,
        serving: per100g,
        now: now,
        isDefault: false,
      );
    } else {
      await _updateServing(weightRow.id, per100g, now);
    }
  }

  Future<void> _updateServing(
    String servingId,
    ServingSizeInput serving,
    DateTime now,
  ) async {
    await (update(foodServings)..where((t) => t.id.equals(servingId))).write(
      FoodServingsCompanion(
        label: Value<String>(serving.label),
        amount: Value<double>(serving.amount),
        unit: Value<String>(serving.unit),
        gramEquivalent: Value<double?>(serving.gramEquivalent),
        updatedAt: Value<DateTime>(now),
      ),
    );
    await (update(nutritionValues)..where((t) => t.servingId.equals(servingId)))
        .write(_nutritionCompanion(serving.nutrition, updatedAt: now));
  }

  static String _formatGrams(double grams) {
    final rounded = (grams * 10).round() / 10;
    return rounded == rounded.roundToDouble()
        ? rounded.toInt().toString()
        : rounded.toString().replaceAll('.', ',');
  }

  Future<void> _writeServing({
    required String servingId,
    required String foodId,
    required ServingSizeInput serving,
    required DateTime now,
    bool isDefault = true,
  }) async {
    await into(foodServings).insert(
      FoodServingsCompanion.insert(
        id: servingId,
        createdAt: now,
        updatedAt: now,
        foodId: foodId,
        label: serving.label,
        amount: serving.amount,
        unit: serving.unit,
        gramEquivalent: Value<double?>(serving.gramEquivalent),
        isDefault: Value<bool>(isDefault),
      ),
    );
    await into(nutritionValues).insert(
      _nutritionCompanion(
        serving.nutrition,
        id: _ids.next(),
        createdAt: now,
        updatedAt: now,
        servingId: servingId,
      ),
    );
  }

  NutritionValuesCompanion _nutritionCompanion(
    NutritionProfile nutrition, {
    String? id,
    DateTime? createdAt,
    required DateTime updatedAt,
    String? servingId,
  }) {
    final base = id == null
        ? NutritionValuesCompanion(updatedAt: Value<DateTime>(updatedAt))
        : NutritionValuesCompanion.insert(
            id: id,
            createdAt: createdAt!,
            updatedAt: updatedAt,
            servingId: servingId!,
          );
    return base.copyWith(
      energyKcal: Value<double?>(nutrition.energy?.kcal),
      proteinG: Value<double?>(nutrition.proteinG),
      carbohydrateG: Value<double?>(nutrition.carbohydrateG),
      fatG: Value<double?>(nutrition.fatG),
      fiberG: Value<double?>(nutrition.fiberG),
      sugarG: Value<double?>(nutrition.sugarG),
      sodiumMg: Value<double?>(nutrition.sodiumMg),
    );
  }

  Future<Food> _assemble(FoodRow row) async {
    final servingRows =
        await (select(foodServings)..where(
              (t) => t.foodId.equals(row.id) & UserRecords.active(t.deletedAt),
            ))
            .get();
    final servings = <ServingSize>[
      for (final servingRow in servingRows) await _servingFrom(servingRow),
    ];
    return _foodFrom(row, servings);
  }

  Food _foodFrom(FoodRow row, List<ServingSize> servings) {
    return Food(
      form: FoodForm.fromStableCode(row.form),
      nutritionOrigin: NutritionOrigin.fromStableCode(row.nutritionOrigin),
      id: row.id,
      name: row.name,
      brand: row.brand,
      category: FoodCategory.fromStableCode(row.category),
      isUserCreated: row.isUserCreated,
      provenance: row.sourceType == null
          ? null
          : FoodProvenance(
              sourceType: row.sourceType!,
              sourceRef: row.sourceRef!,
              sourceVersion: row.sourceVersion!,
              verifiedAt: row.verifiedAt,
            ),
      servings: servings,
    );
  }

  Future<ServingSize> _servingFrom(FoodServingRow servingRow) async {
    final nutritionRow = await (select(
      nutritionValues,
    )..where((t) => t.servingId.equals(servingRow.id))).getSingleOrNull();
    return _servingWith(servingRow, nutritionRow);
  }

  ServingSize _servingWith(
    FoodServingRow servingRow,
    NutritionValueRow? nutritionRow,
  ) {
    return ServingSize(
      id: servingRow.id,
      label: servingRow.label,
      amount: servingRow.amount,
      unit: servingRow.unit,
      gramEquivalent: servingRow.gramEquivalent,
      isDefault: servingRow.isDefault,
      nutrition: _nutritionFrom(nutritionRow),
      provenanceTier: ServingProvenanceTier.fromStableCode(
        servingRow.provenanceTier,
      ),
    );
  }

  NutritionProfile _nutritionFrom(NutritionValueRow? row) {
    if (row == null) {
      return NutritionProfile.unknown;
    }
    return NutritionProfile(
      energy: row.energyKcal == null
          ? null
          : Energy.kcalValue(row.energyKcal!, field: 'energyKcal').valueOrNull,
      proteinG: row.proteinG,
      carbohydrateG: row.carbohydrateG,
      fatG: row.fatG,
      fiberG: row.fiberG,
      sugarG: row.sugarG,
      sodiumMg: row.sodiumMg,
    );
  }
}
