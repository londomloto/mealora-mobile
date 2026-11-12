import 'package:mealora/domain/food/nutrition_profile.dart';

/// Tingkat asal-usul padanan berat sebuah takaran (change 015, design.md
/// D6). `null` pada [ServingSize.provenanceTier] untuk takaran buatan
/// pengguna.
enum ServingProvenanceTier {
  /// Sumber resmi atau penimbangan lapangan.
  official,

  /// Dihitung dari data terukur.
  derived,

  /// Perkiraan ukuran — ditandai "perkiraan" di UI.
  estimate;

  static ServingProvenanceTier? fromStableCode(String? code) =>
      code == null ? null : ServingProvenanceTier.values.byName(code);
}

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
    this.provenanceTier,
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

  final ServingProvenanceTier? provenanceTier;

  /// Padanan beratnya perkiraan — UI menampilkan penanda "perkiraan" (spec
  /// food-catalog, "Takaran perkiraan ditandai").
  bool get isEstimate => provenanceTier == ServingProvenanceTier.estimate;

  /// Takaran berat/volume murni (`100 g`, `100 ml`) — dasar masukan jumlah
  /// bebas dalam gram/ml (design.md D5).
  bool get isWeightBasis =>
      (unit == 'gram' || unit == 'g' || unit == 'ml') && amount > 0;
}
