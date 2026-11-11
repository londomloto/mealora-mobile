/// Asal-usul nilai gizi sebuah produk kemasan (spec packaged-food-barcode,
/// §50.4; Design D2/D5, change 009).
///
/// Berbeda dari `FoodProvenance` (katalog bawaan, change 007): jenis
/// sumbernya sendiri (`openfoodfacts`/`user_manual`, bukan `usda_fdc`), dan
/// menambah [userCorrected] — produk kemasan adalah satu-satunya jenis
/// makanan yang nilainya bisa datang dari sumber komunitas lalu dikoreksi
/// pengguna terhadap kemasan di tangannya.
final class PackagedFoodProvenance {
  const PackagedFoodProvenance({
    required this.sourceType,
    required this.verifiedAt,
    required this.userCorrected,
    this.sourceRef,
    this.sourceVersion,
  });

  /// `'openfoodfacts'` atau `'user_manual'`.
  final String sourceType;

  /// Pengenal pada sumber (mis. kode produk Open Food Facts) — `null` untuk
  /// `user_manual`.
  final String? sourceRef;

  /// Versi/rilis sumber — `null` untuk `user_manual`.
  final String? sourceVersion;

  /// Tanggal pengguna meninjau dan mengonfirmasi nilai ini.
  final DateTime verifiedAt;

  /// `true` ketika pengguna pernah mengoreksi nilai gizi produk ini
  /// (Design D5). Sumber daring SHALL TIDAK menimpa nilai tanpa
  /// persetujuan ketika ini menyala.
  final bool userCorrected;
}
