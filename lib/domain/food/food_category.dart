/// Kategori makanan katalog (spec food-catalog, "Cakupan makanan Indonesia").
enum FoodCategory {
  staple,
  sideDish,
  vegetable,
  snack,
  drink,
  other;

  /// Kode mesin yang disimpan — stabil, bukan untuk ditampilkan.
  String get stableCode => switch (this) {
    FoodCategory.staple => 'staple',
    FoodCategory.sideDish => 'side_dish',
    FoodCategory.vegetable => 'vegetable',
    FoodCategory.snack => 'snack',
    FoodCategory.drink => 'drink',
    FoodCategory.other => 'other',
  };

  static FoodCategory fromStableCode(String code) =>
      FoodCategory.values.firstWhere((c) => c.stableCode == code);
}
