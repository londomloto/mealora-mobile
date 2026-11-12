import 'package:mealora/domain/food/food.dart';
import 'package:mealora/domain/food/serving_size.dart';

/// Pencocokan satuan (dari ucapan atau pengenalan foto) ke takaran sebuah
/// makanan — satu logika untuk input suara dan draf foto (change 015,
/// design.md D8/D10).
abstract final class ServingUnitMatcher {
  /// Bentuk sehari-hari → satuan kanonik yang dipakai `food_servings.unit`
  /// (lihat `tool/food_catalog/unit_ranges.csv`).
  static const Map<String, String> unitAliases = <String, String>{
    'g': 'gram',
    'gr': 'gram',
    'gram': 'gram',
    'mililiter': 'ml',
    'ml': 'ml',
    'sendok teh': 'sdt',
    'sdt': 'sdt',
    'sendok makan': 'sdm',
    'sdm': 'sdm',
    'sendok': 'sdm',
    'gelas': 'gelas',
    'gls': 'gelas',
    'cangkir': 'gelas',
    'mangkok': 'mangkuk',
    'mangkuk': 'mangkuk',
    'centong': 'centong',
    'centhong': 'centong',
    'entong': 'centong',
    'piring': 'piring',
    'potong': 'potong',
    'ptg': 'potong',
    'iris': 'iris',
    'buah': 'buah',
    'bh': 'buah',
    'butir': 'butir',
    'btr': 'butir',
    'biji': 'biji',
    'ekor': 'ekor',
    'lembar': 'lembar',
    'lbr': 'lembar',
    'porsi': 'porsi',
    'bungkus': 'bungkus',
    'bks': 'bungkus',
  };

  static String? canonicalUnit(String? raw) {
    final unit = raw?.toLowerCase().trim();
    if (unit == null || unit.isEmpty) return null;
    return unitAliases[unit] ?? unit;
  }

  /// Takaran makanan yang satuannya sama dengan [unit], atau yang labelnya
  /// menyebut satuan itu. `null` bila tidak ada yang cocok.
  static ServingSize? servingForUnit(Food food, String? unit) {
    final canonical = canonicalUnit(unit);
    if (canonical == null) return null;
    for (final serving in food.servings) {
      if (canonicalUnit(serving.unit) == canonical) return serving;
    }
    final word = RegExp('\\b${RegExp.escape(canonical)}\\b');
    for (final serving in food.servings) {
      if (word.hasMatch(serving.label.toLowerCase())) return serving;
    }
    return null;
  }
}
