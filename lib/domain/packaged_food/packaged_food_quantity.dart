/// Jumlah yang dipilih pengguna untuk dicatat dari sebuah produk kemasan
/// (spec packaged-food-barcode, "Basis takaran dihitung dengan benar").
///
/// Jenis mana yang sah bergantung pada `PackagedFood.servingBasis` —
/// `calculatePackagedFoodNutrition` menolak kombinasi yang tidak sesuai.
sealed class PackagedFoodQuantity {
  const PackagedFoodQuantity();
}

/// Sejumlah sajian yang dimakan — berlaku untuk `ServingBasis.perServing`.
/// SHALL lebih besar dari nol (spec, "Jumlah tidak sah").
final class ServingsEaten extends PackagedFoodQuantity {
  const ServingsEaten(this.servings) : assert(servings > 0);

  final double servings;
}

/// Satu kemasan penuh dimakan — berlaku untuk `ServingBasis.perServing`
/// dengan `PackagedFood.unitsPerPackage` diketahui (spec, "Satu kemasan
/// berisi dua sajian").
final class WholePackageEaten extends PackagedFoodQuantity {
  const WholePackageEaten();
}

/// Sejumlah gram yang benar-benar dimakan — berlaku untuk
/// `ServingBasis.perHundredGrams` (spec, "Label per 100 g"). SHALL lebih
/// besar dari nol.
final class GramsEaten extends PackagedFoodQuantity {
  const GramsEaten(this.grams) : assert(grams > 0);

  final double grams;
}
