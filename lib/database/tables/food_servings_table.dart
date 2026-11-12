import 'package:drift/drift.dart';
import 'package:mealora/database/tables/foods_table.dart';
import 'package:mealora/database/tables/user_record_columns.dart';

/// Nilai `provenanceTier` yang sah (Design D2/D6, change 015).
const List<String> kServingProvenanceTierValues = <String>[
  'official',
  'derived',
  'estimate',
];

/// Takaran saji sebuah makanan (spec food-catalog, "Takaran saji yang
/// bermakna"): label sehari-hari, jumlah, satuan, dan padanan gram bila
/// diketahui. Setiap makanan SHALL punya sekurang-kurangnya satu takaran,
/// dengan tepat satu ditandai [isDefault].
@DataClassName('FoodServingRow')
class FoodServings extends Table with UserRecordColumns {
  TextColumn get foodId =>
      text().references(Foods, #id, onDelete: KeyAction.restrict)();

  /// Label lengkap sehari-hari (mis. "150 g · 1 mangkuk").
  TextColumn get label => text().withLength(min: 1, max: 80)();

  RealColumn get amount => real()();
  TextColumn get unit => text().withLength(min: 1, max: 24)();
  RealColumn get gramEquivalent => real().nullable()();

  BoolColumn get isDefault => boolean().withDefault(const Constant(false))();

  /// Tingkat asal-usul padanan berat takaran ini: `official`, `derived`,
  /// atau `estimate` (Design D6, change 015). Wajib untuk takaran katalog
  /// bawaan (ditegakkan seed dan pemeriksa mutu), `null` untuk takaran
  /// buatan pengguna.
  TextColumn get provenanceTier => text()
      .withLength(min: 1, max: 16)
      // ignore: recursive_getters — idiom Drift untuk CHECK yang merujuk kolomnya sendiri.
      .check(provenanceTier.isIn(kServingProvenanceTierValues))
      .nullable()();

  /// Rujukan dokumen beserta halaman, atau rumus turunan.
  TextColumn get provenanceRef =>
      text().withLength(min: 1, max: 160).nullable()();

  /// Dasar perkiraan untuk tingkat `estimate`, atau catatan perbedaan sumber.
  TextColumn get provenanceNote =>
      text().withLength(min: 1, max: 240).nullable()();
}
