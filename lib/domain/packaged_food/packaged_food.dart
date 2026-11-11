import 'package:mealora/domain/food/food.dart';
import 'package:mealora/domain/food/nutrition_profile.dart';
import 'package:mealora/domain/packaged_food/packaged_food_provenance.dart';
import 'package:mealora/domain/packaged_food/serving_basis.dart';

/// Satu produk kemasan: makanan katalog (change 007) ditambah sifat kemasan
/// — barcode, ukuran, basis takaran, dan provenans (spec
/// packaged-food-barcode, Design D8, change 009).
///
/// [food] membawa nama, merek (`Food.brand`), dan takaran bawaan yang
/// nilainya adalah [valuesAtRecordedBasis] — PADA BASIS [servingBasis] itu
/// sendiri, bukan sudah dikonversi. Gunakan
/// `calculatePackagedFoodNutrition` (packaged_food_nutrition.dart) untuk
/// menghitung jumlah yang benar-benar dimakan.
final class PackagedFood {
  const PackagedFood({
    required this.food,
    required this.servingBasis,
    required this.provenance,
    this.barcode,
    this.packageSize,
    this.unitsPerPackage,
  });

  final Food food;

  /// Nomor barcode (EAN/UPC) — pengenal pencarian, bukan sumber nilai gizi
  /// (spec, "Barcode adalah pengenal produk, bukan sumber nilai gizi").
  /// `null` ketika produk dikonfirmasi lewat foto label tanpa barcode
  /// (change 010) — kemasan rusak/tidak punya barcode, atau pengguna
  /// memilih jalur foto langsung dari layar pindai tanpa memindai dulu.
  /// Produk semacam ini HANYA dapat ditemukan kembali lewat pencarian
  /// nama, tidak lewat pemindaian.
  final String? barcode;

  /// Label ukuran kemasan sehari-hari (mis. "60 g"). `null` bila tidak
  /// diketahui.
  final String? packageSize;

  /// Jumlah sajian per kemasan. SHALL ada ketika [servingBasis] adalah
  /// [ServingBasis.perServing] dan pengguna ingin mencatat satu kemasan
  /// penuh — boleh `null` bila tidak diketahui dari sumber, atau selalu
  /// pada [ServingBasis.perHundredGrams] (spec, "Satu kemasan penuh
  /// dihitung sebagai nilai per sajian dikalikan jumlah sajian per
  /// kemasan" hanya mendefinisikan jalur ini untuk basis per-sajian).
  final double? unitsPerPackage;

  final ServingBasis servingBasis;
  final PackagedFoodProvenance provenance;

  /// Nilai gizi rekaman PADA BASISNYA SENDIRI — satu sajian bila
  /// [servingBasis] adalah [ServingBasis.perServing], atau 100 g bila
  /// [ServingBasis.perHundredGrams] (Design D4: disimpan apa adanya).
  NutritionProfile get valuesAtRecordedBasis => food.defaultServing.nutrition;
}
