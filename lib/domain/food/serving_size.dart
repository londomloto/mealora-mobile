import 'package:mealora/domain/food/nutrition_profile.dart';

/// Satu takaran saji sebuah makanan (spec food-catalog, "Takaran saji yang
/// bermakna"): label sehari-hari, jumlah, satuan, padanan gram bila
/// diketahui, dan nilai gizi untuk takaran ini.
final class ServingSize {
  const ServingSize({
    required this.id,
    required this.label,
    required this.amount,
    required this.unit,
    required this.isDefault,
    required this.nutrition,
    this.gramEquivalent,
  });

  final String id;

  /// Label sehari-hari lengkap (mis. "150 g · 1 mangkuk").
  final String label;

  /// Jumlah pada satuan ini (mis. `1` untuk "1 mangkuk").
  final double amount;

  /// Satuan (mis. "mangkuk", "butir", "g").
  final String unit;

  /// Padanan berat dalam gram, bila diketahui.
  final double? gramEquivalent;

  /// Takaran bawaan — satu per makanan SHALL ditandai demikian.
  final bool isDefault;

  /// Nilai gizi untuk satu takaran ini (bukan per gram/per 100 g).
  final NutritionProfile nutrition;
}
