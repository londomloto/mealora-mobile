import 'package:drift/drift.dart';
import 'package:mealora/database/app_database.dart';

part 'food_catalog_data.dart';

/// Versi sumber yang dicatat untuk seluruh baris katalog ini (TKPI, via
/// dataset Kaggle 'anasfikrihanif/indonesian-food-and-drink-nutrition-dataset')
/// -- lihat mealora-plans/docs/food-data-sources.md. Keputusan Design D2
/// direvisi: TKPI diterima dengan risiko hak pakai belum dipastikan diterima
/// sadar oleh pemilik produk (2026-11-11).
const String _kSourceType = 'tkpi';
const String _kSourceVersion = 'kaggle-indo-nutrition-v1';

/// Versi isi katalog bawaan, terpisah dari versi skema database.
///
/// Naikkan nilai ini setiap kali dataset `tool/food_catalog/` (dan
/// `food_catalog_data.dart` hasil bangkitannya) berubah agar perangkat yang
/// sudah memakai skema terbaru tetap mendapat penambahan/perbaikan katalog.
const String kFoodCatalogSeedVersion = 'tkpi-2026-11-12-v5';
const String _kFoodCatalogSeedPreferenceKey = 'food_catalog_seed_version';

/// Waktu tetap untuk created_at/updated_at/verified_at baris katalog --
/// baris katalog bukan record pengguna, nilainya sama di setiap perangkat
/// (pola Design D2, change 004: kProgramCatalogSeedTimestamp).
final DateTime kFoodCatalogSeedTimestamp = DateTime.utc(2026, 11, 11);

/// Satu makanan katalog -- dibangkitkan dari `tool/food_catalog/foods.csv`
/// (change 015, design.md D3). [category] berupa kode stabil
/// (`FoodCategory.stableCode`).
final class _SeedFood {
  const _SeedFood({
    required this.idSuffix,
    required this.name,
    required this.category,
    required this.form,
    required this.isActive,
    required this.sourceRef,
    required this.verified,
    required this.servings,
  });

  final String idSuffix;
  final String name;
  final String category;
  final String? form;
  final bool isActive;
  final String sourceRef;

  /// `false` bila belum cocok dengan TKPI 2017 -- `verifiedAt` dibiarkan
  /// kosong (change 015, task 3.2).
  final bool verified;
  final List<_SeedServing> servings;
}

/// Satu takaran katalog dengan gizi per takaran yang sudah dihitung
/// generator (nilai_100g x gram / 100, design.md D4). `null` = belum
/// diketahui.
final class _SeedServing {
  const _SeedServing({
    required this.slug,
    required this.label,
    required this.amount,
    required this.unit,
    required this.gram,
    required this.isDefault,
    required this.tier,
    required this.ref,
    required this.note,
    required this.energyKcal,
    required this.proteinG,
    required this.carbohydrateG,
    required this.fatG,
    required this.fiberG,
  });

  final String slug;
  final String label;
  final double amount;
  final String unit;
  final double gram;
  final bool isDefault;
  final String? tier;
  final String? ref;
  final String? note;
  final double? energyKcal;
  final double? proteinG;
  final double? carbohydrateG;
  final double? fatG;
  final double? fiberG;
}

String _foodId(String suffix) => 'food-$suffix';

/// Takaran asal 100 g tetap `food-<id>-default`; takaran sehari-hari
/// `food-<id>-<slug-satuan>` (design.md D1).
String _servingId(String suffix, String slug) => 'food-$suffix-$slug';
String _nutritionId(String suffix, String slug) =>
    '${_servingId(suffix, slug)}-nutrition';

/// Menyisipkan atau memperbarui katalog makanan bawaan berdasarkan pengenal
/// tetapnya (pola Design D2, change 004) -- idempoten: menjalankannya
/// berkali-kali tidak pernah menggandakan baris maupun memutus tautan
/// catatan yang sudah dibuat terhadapnya.
///
/// Takaran tidak pernah dihapus (relasi `restrict` dari catatan makan):
/// pemindahan takaran bawaan cukup lewat upsert `isDefault` pada semua
/// takaran makanan itu, dan makanan duplikat dinonaktifkan lewat `isActive`
/// (change 015, task 1.7).
Future<void> seedFoodCatalog(AppDatabase db) async {
  await db.batch((batch) {
    // Takaran bawaan dipindah lewat dataset: semua takaran makanan katalog
    // dilepas dulu, lalu upsert di bawah menandai ulang sesuai dataset --
    // takaran lama yang tidak ada di dataset tidak tertinggal sebagai
    // bawaan kedua.
    batch.customStatement(
      'UPDATE food_servings SET is_default = 0 WHERE food_id IN '
      '(SELECT id FROM foods WHERE is_user_created = 0)',
    );
    batch.insertAllOnConflictUpdate(
      db.foods,
      _kSeedFoods.map(
        (seed) => FoodsCompanion.insert(
          id: _foodId(seed.idSuffix),
          createdAt: kFoodCatalogSeedTimestamp,
          updatedAt: kFoodCatalogSeedTimestamp,
          name: seed.name,
          category: seed.category,
          isUserCreated: const Value<bool>(false),
          sourceType: const Value<String?>(_kSourceType),
          sourceRef: Value<String?>(seed.sourceRef),
          sourceVersion: const Value<String?>(_kSourceVersion),
          verifiedAt: Value<DateTime?>(
            seed.verified ? kFoodCatalogSeedTimestamp : null,
          ),
          form: Value<String?>(seed.form),
          isActive: Value<bool>(seed.isActive),
        ),
      ),
    );

    batch.insertAllOnConflictUpdate(db.foodServings, <FoodServingsCompanion>[
      for (final seed in _kSeedFoods)
        for (final serving in seed.servings)
          FoodServingsCompanion.insert(
            id: _servingId(seed.idSuffix, serving.slug),
            createdAt: kFoodCatalogSeedTimestamp,
            updatedAt: kFoodCatalogSeedTimestamp,
            foodId: _foodId(seed.idSuffix),
            label: serving.label,
            amount: serving.amount,
            unit: serving.unit,
            gramEquivalent: Value<double?>(serving.gram),
            isDefault: Value<bool>(serving.isDefault),
            provenanceTier: Value<String?>(serving.tier),
            provenanceRef: Value<String?>(serving.ref),
            provenanceNote: Value<String?>(serving.note),
          ),
    ]);

    batch.insertAllOnConflictUpdate(
      db.nutritionValues,
      <NutritionValuesCompanion>[
        for (final seed in _kSeedFoods)
          for (final serving in seed.servings)
            NutritionValuesCompanion.insert(
              id: _nutritionId(seed.idSuffix, serving.slug),
              createdAt: kFoodCatalogSeedTimestamp,
              updatedAt: kFoodCatalogSeedTimestamp,
              servingId: _servingId(seed.idSuffix, serving.slug),
              energyKcal: Value<double?>(serving.energyKcal),
              proteinG: Value<double?>(serving.proteinG),
              carbohydrateG: Value<double?>(serving.carbohydrateG),
              fatG: Value<double?>(serving.fatG),
              fiberG: Value<double?>(serving.fiberG),
            ),
      ],
    );
  });
}

/// Menyelaraskan katalog bawaan saat versi isi yang tersimpan berbeda.
///
/// Penyelarasan bersifat idempoten dan tidak menghapus makanan buatan maupun
/// catatan pengguna. Penanda versi ditulis dalam transaksi yang sama sehingga
/// kegagalan di tengah proses akan dicoba lagi pada pembukaan berikutnya.
Future<void> ensureFoodCatalogSeeded(AppDatabase db) async {
  final storedVersion =
      await (db.select(db.uiPreferences)
            ..where((row) => row.key.equals(_kFoodCatalogSeedPreferenceKey)))
          .getSingleOrNull();
  if (storedVersion?.value == kFoodCatalogSeedVersion) {
    return;
  }

  await db.transaction(() async {
    await seedFoodCatalog(db);
    await db
        .into(db.uiPreferences)
        .insertOnConflictUpdate(
          UiPreferencesCompanion.insert(
            key: _kFoodCatalogSeedPreferenceKey,
            value: kFoodCatalogSeedVersion,
            updatedAt: kFoodCatalogSeedTimestamp,
          ),
        );
  });
}
