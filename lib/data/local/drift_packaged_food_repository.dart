import 'package:drift/drift.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/ids/id_generator.dart';
import 'package:mealora/data/local/user_record_support.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/database/tables/food_servings_table.dart';
import 'package:mealora/database/tables/foods_table.dart';
import 'package:mealora/database/tables/nutrition_values_table.dart';
import 'package:mealora/database/tables/packaged_food_properties_table.dart';
import 'package:mealora/domain/food/food.dart';
import 'package:mealora/domain/food/food_category.dart';
import 'package:mealora/domain/food/nutrition_profile.dart';
import 'package:mealora/domain/food/serving_size.dart';
import 'package:mealora/domain/packaged_food/packaged_food.dart';
import 'package:mealora/domain/packaged_food/packaged_food_provenance.dart';
import 'package:mealora/domain/packaged_food/packaged_food_repository.dart';
import 'package:mealora/domain/packaged_food/product_data_source_client.dart';
import 'package:mealora/domain/packaged_food/serving_basis.dart';
import 'package:mealora/domain/shared/units.dart';

part 'drift_packaged_food_repository.g.dart';

/// Implementasi `PackagedFoodRepository` (change 009) memakai DAO Drift —
/// Drift tidak pernah bocor ke lapisan domain (Design D9, change 004).
///
/// Mengikuti urutan pencarian perangkat-lebih-dulu (Design D1): hanya
/// memanggil [_client] ketika barcode tidak ketemu di perangkat. Kegagalan
/// [_client] (jaringan, waktu habis, format tak terduga) ditangkap di sini
/// sebagai lapis pertahanan kedua — kontraknya sendiri sudah menjanjikan
/// `null`, bukan melempar (task 4.6).
@DriftAccessor(
  tables: <Type>[Foods, FoodServings, NutritionValues, PackagedFoodProperties],
)
class DriftPackagedFoodRepository extends DatabaseAccessor<AppDatabase>
    with _$DriftPackagedFoodRepositoryMixin
    implements PackagedFoodRepository {
  DriftPackagedFoodRepository(
    super.db, {
    required IdGenerator ids,
    required Clock clock,
    required ProductDataSourceClient client,
  }) : _ids = ids,
       _clock = clock,
       _client = client;

  final IdGenerator _ids;
  final Clock _clock;
  final ProductDataSourceClient _client;

  @override
  Future<PackagedFood?> findByBarcode(String barcode) async {
    final local = await _findLocal(barcode);
    if (local != null) {
      return local;
    }

    RemoteProductLookup? remote;
    try {
      remote = await _client.lookupByBarcode(barcode);
    } on Object {
      remote = null;
    }
    if (remote == null) {
      return null;
    }

    final isPerServing = remote.servingBasis == ServingBasis.perServing;
    final nutrition = remote.nutritionAtRecordedBasis;
    final food = Food(
      id: _ids.next(),
      name: remote.name,
      brand: remote.brand,
      category: FoodCategory.other,
      isUserCreated: true,
      servings: <ServingSize>[
        ServingSize(
          id: _ids.next(),
          label: _defaultServingLabel(
            isPerServing: isPerServing,
            servingSizeGrams: remote.servingSizeGrams,
          ),
          amount: isPerServing ? 1 : 100,
          unit: isPerServing ? 'sajian' : 'g',
          gramEquivalent: isPerServing ? remote.servingSizeGrams : 100,
          isDefault: true,
          nutrition: nutrition,
        ),
      ],
    );

    return PackagedFood(
      food: food,
      barcode: barcode,
      packageSize: remote.packageSize,
      unitsPerPackage: remote.unitsPerPackage,
      servingBasis: remote.servingBasis,
      provenance: PackagedFoodProvenance(
        sourceType: 'openfoodfacts',
        sourceRef: remote.sourceRef ?? barcode,
        sourceVersion: remote.sourceVersion,
        verifiedAt: _clock.nowUtc(),
        userCorrected: false,
        sourceImagePath: null,
      ),
    );
  }

  @override
  Future<PackagedFood> confirm(PackagedFood product) async {
    final now = _clock.nowUtc();
    final serving = product.food.defaultServing;

    return transaction(() async {
      // Produk tanpa barcode (change 010: jalur foto langsung, atau
      // kemasan tanpa barcode) SHALL TIDAK dicocokkan ke baris mana pun —
      // tidak ada pengenal yang stabil untuk dicocokkan, jadi setiap
      // konfirmasi semacam ini SELALU menjadi baris baru (tidak pernah
      // memperbarui baris tanpa-barcode yang sudah ada).
      final existing = product.barcode == null
          ? null
          : await (select(packagedFoodProperties)..where(
                  (t) =>
                      t.barcode.equals(product.barcode!) &
                      UserRecords.active(t.deletedAt),
                ))
                .getSingleOrNull();

      final String packagedFoodPropertiesId;

      if (existing == null) {
        final foodId = _ids.next();
        final servingId = _ids.next();
        packagedFoodPropertiesId = _ids.next();
        await into(foods).insert(
          FoodsCompanion.insert(
            id: foodId,
            createdAt: now,
            updatedAt: now,
            name: product.food.name,
            brand: Value<String?>(product.food.brand),
            category: product.food.category.stableCode,
            isUserCreated: const Value<bool>(true),
          ),
        );
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
        await into(packagedFoodProperties).insert(
          PackagedFoodPropertiesCompanion.insert(
            id: packagedFoodPropertiesId,
            createdAt: now,
            updatedAt: now,
            foodId: foodId,
            barcode: Value<String?>(product.barcode),
            packageSize: Value<String?>(product.packageSize),
            unitsPerPackage: Value<double?>(product.unitsPerPackage),
            servingBasis: product.servingBasis.stableCode,
            sourceType: product.provenance.sourceType,
            sourceRef: Value<String?>(product.provenance.sourceRef),
            sourceVersion: Value<String?>(product.provenance.sourceVersion),
            verifiedAt: now,
            userCorrected: Value<bool>(product.provenance.userCorrected),
            sourceImagePath: Value<String?>(product.provenance.sourceImagePath),
          ),
        );
      } else {
        packagedFoodPropertiesId = existing.id;
        final servingRow =
            await (select(foodServings)..where(
                  (t) =>
                      t.foodId.equals(existing.foodId) &
                      t.isDefault.equals(true),
                ))
                .getSingle();

        await (update(foods)..where((t) => t.id.equals(existing.foodId))).write(
          FoodsCompanion(
            name: Value<String>(product.food.name),
            brand: Value<String?>(product.food.brand),
            updatedAt: Value<DateTime>(now),
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
        await (update(
          packagedFoodProperties,
        )..where((t) => t.id.equals(existing.id))).write(
          PackagedFoodPropertiesCompanion(
            packageSize: Value<String?>(product.packageSize),
            unitsPerPackage: Value<double?>(product.unitsPerPackage),
            servingBasis: Value<String>(product.servingBasis.stableCode),
            sourceType: Value<String>(product.provenance.sourceType),
            sourceRef: Value<String?>(product.provenance.sourceRef),
            sourceVersion: Value<String?>(product.provenance.sourceVersion),
            verifiedAt: Value<DateTime>(now),
            // Sekali terkoreksi, tetap tercatat terkoreksi (Design D5)
            // — konfirmasi berikutnya yang tidak menyentuh nilai SHALL
            // TIDAK menurunkan bendera ini kembali ke `false`.
            userCorrected: Value<bool>(
              product.provenance.userCorrected || existing.userCorrected,
            ),
            sourceImagePath: Value<String?>(product.provenance.sourceImagePath),
            updatedAt: Value<DateTime>(now),
            revision: Value<int>(existing.revision + 1),
          ),
        );
      }

      return (await _findByPropertiesId(packagedFoodPropertiesId))!;
    });
  }

  Future<PackagedFood?> _findLocal(String barcode) async {
    final props =
        await (select(packagedFoodProperties)..where(
              (t) =>
                  t.barcode.equals(barcode) & UserRecords.active(t.deletedAt),
            ))
            .getSingleOrNull();
    return props == null ? null : _buildFromRow(props);
  }

  /// Memuat ulang produk yang baru saja disimpan lewat [confirm] memakai
  /// pengenal barisnya sendiri (BUKAN barcode) — satu-satunya pengenal
  /// yang SELALU ada, termasuk untuk produk tanpa barcode (change 010).
  Future<PackagedFood?> _findByPropertiesId(String id) async {
    final props = await (select(
      packagedFoodProperties,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    return props == null ? null : _buildFromRow(props);
  }

  Future<PackagedFood> _buildFromRow(PackagedFoodPropertiesRow props) async {
    final foodRow = await (select(
      foods,
    )..where((t) => t.id.equals(props.foodId))).getSingle();
    final servingRow =
        await (select(foodServings)..where(
              (t) => t.foodId.equals(props.foodId) & t.isDefault.equals(true),
            ))
            .getSingle();
    final nutritionRow = await (select(
      nutritionValues,
    )..where((t) => t.servingId.equals(servingRow.id))).getSingleOrNull();

    return PackagedFood(
      food: Food(
        id: foodRow.id,
        name: foodRow.name,
        brand: foodRow.brand,
        category: FoodCategory.fromStableCode(foodRow.category),
        isUserCreated: foodRow.isUserCreated,
        servings: <ServingSize>[
          ServingSize(
            id: servingRow.id,
            label: servingRow.label,
            amount: servingRow.amount,
            unit: servingRow.unit,
            gramEquivalent: servingRow.gramEquivalent,
            isDefault: servingRow.isDefault,
            nutrition: _nutritionFrom(nutritionRow),
          ),
        ],
      ),
      barcode: props.barcode,
      packageSize: props.packageSize,
      unitsPerPackage: props.unitsPerPackage,
      servingBasis: ServingBasis.fromStableCode(props.servingBasis),
      provenance: PackagedFoodProvenance(
        sourceType: props.sourceType,
        sourceRef: props.sourceRef,
        sourceVersion: props.sourceVersion,
        verifiedAt: props.verifiedAt,
        userCorrected: props.userCorrected,
        sourceImagePath: props.sourceImagePath,
      ),
    );
  }

  String _defaultServingLabel({
    required bool isPerServing,
    double? servingSizeGrams,
  }) {
    if (!isPerServing) {
      return '100 g';
    }
    if (servingSizeGrams == null) {
      return '1 sajian';
    }
    final grams = servingSizeGrams == servingSizeGrams.roundToDouble()
        ? servingSizeGrams.toStringAsFixed(0)
        : servingSizeGrams.toString();
    return '$grams g · 1 sajian';
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
