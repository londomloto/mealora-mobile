/// Asal-usul nilai gizi sebuah makanan katalog bawaan (spec food-catalog,
/// "Setiap makanan katalog memiliki asal-usul data"; Design D2, change 007).
///
/// `null` pada `Food.provenance` berarti makanan buatan pengguna — provenans
/// hanya berlaku untuk makanan bawaan (spec, "Makanan buatan pengguna
/// SHALL ditandai berbeda dari makanan katalog bawaan").
final class FoodProvenance {
  const FoodProvenance({
    required this.sourceType,
    required this.sourceRef,
    required this.sourceVersion,
    this.verifiedAt,
  });

  /// Jenis sumber (mis. `usda_fdc`, `tkpi`) — lihat
  /// `mealora-plans/docs/food-data-sources.md`.
  final String sourceType;

  /// Pengenal pada sumber tersebut (mis. FDC ID USDA).
  final String sourceRef;

  /// Versi/rilis sumber (mis. `SR Legacy`).
  final String sourceVersion;

  /// Tanggal nilai terakhir diverifikasi terhadap sumber. `null` bila
  /// makanan belum cocok dengan TKPI 2017 (belum terverifikasi, change 015
  /// task 3.2).
  final DateTime? verifiedAt;
}
