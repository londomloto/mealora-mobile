import 'package:mealora/domain/food/nutrition_profile.dart';
import 'package:mealora/domain/packaged_food/packaged_food.dart';
import 'package:mealora/domain/packaged_food/packaged_food_quantity.dart';
import 'package:mealora/domain/packaged_food/serving_basis.dart';

/// Menghitung nilai gizi yang dimakan dari basis takaran rekaman [product]
/// (spec packaged-food-barcode, "Basis takaran dihitung dengan benar";
/// Design D4, change 009).
///
/// Konversi terjadi HANYA di sini — nilai rekaman produk tidak pernah
/// diubah. Melempar [ArgumentError] bila [quantity] tidak sesuai
/// [PackagedFood.servingBasis] (kesalahan pemrograman di lapisan pemanggil,
/// bukan jalur kegagalan pengguna — UI SHALL TIDAK menawarkan kombinasi
/// yang tidak sah), dan [StateError] bila satu kemasan diminta tanpa
/// `unitsPerPackage` diketahui.
NutritionProfile calculatePackagedFoodNutrition(
  PackagedFood product,
  PackagedFoodQuantity quantity,
) {
  return product.valuesAtRecordedBasis.scaledBy(
    packagedFoodQuantityMultiplier(product, quantity),
  );
}

/// Pengali takaran bawaan [product] (`Food.defaultServing`) yang setara
/// dengan [quantity] — dipakai langsung sebagai `quantity` pada
/// `DiaryRepository.addEntry` (change 007) supaya pencatatan produk
/// kemasan lewat jalur yang sama persis dengan makanan lain (task 7.6):
/// tidak ada skema penyimpanan baru untuk butir catatan, hanya pengali
/// yang dihitung berbeda menurut basis takaran rekamannya.
double packagedFoodQuantityMultiplier(
  PackagedFood product,
  PackagedFoodQuantity quantity,
) {
  switch (product.servingBasis) {
    case ServingBasis.perServing:
      return switch (quantity) {
        ServingsEaten(:final servings) => servings,
        WholePackageEaten() => _requireUnitsPerPackage(product),
        GramsEaten() => throw ArgumentError(
          'GramsEaten tidak berlaku untuk ServingBasis.perServing',
        ),
      };
    case ServingBasis.perHundredGrams:
      return switch (quantity) {
        GramsEaten(:final grams) => grams / 100,
        ServingsEaten() || WholePackageEaten() => throw ArgumentError(
          'Hanya GramsEaten yang berlaku untuk ServingBasis.perHundredGrams',
        ),
      };
  }
}

double _requireUnitsPerPackage(PackagedFood product) {
  final units = product.unitsPerPackage;
  if (units == null) {
    throw StateError(
      'unitsPerPackage wajib diketahui untuk menghitung satu kemasan penuh',
    );
  }
  return units;
}
