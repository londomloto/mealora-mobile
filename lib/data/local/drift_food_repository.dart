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
import 'package:mealora/domain/food/food.dart';
import 'package:mealora/domain/food/food_category.dart';
import 'package:mealora/domain/food/food_provenance.dart';
import 'package:mealora/domain/food/food_repository.dart';
import 'package:mealora/domain/food/nutrition_profile.dart';
import 'package:mealora/domain/food/recent_food.dart';
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
    return Future.wait(rows.map(_assemble));
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
        ),
      );
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

  Future<void> _writeServing({
    required String servingId,
    required String foodId,
    required ServingSizeInput serving,
    required DateTime now,
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
        isDefault: const Value<bool>(true),
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
    final servings = <ServingSize>[];
    for (final servingRow in servingRows) {
      final nutritionRow = await (select(
        nutritionValues,
      )..where((t) => t.servingId.equals(servingRow.id))).getSingleOrNull();
      servings.add(
        ServingSize(
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
        ),
      );
    }
    return Food(
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
