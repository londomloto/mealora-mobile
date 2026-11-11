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
    this.sourceImagePath,
  });

  /// `'openfoodfacts'`, `'user_manual'`, atau `'label_extraction'` (change
  /// 010, Design D10) — hasil pembacaan foto label yang dikonfirmasi
  /// pengguna, berbeda dari `'user_manual'` (diketik tangan tanpa foto).
  final String sourceType;

  /// Pengenal pada sumber (mis. kode produk Open Food Facts) — `null` untuk
  /// `user_manual` dan `label_extraction`.
  final String? sourceRef;

  /// Versi/rilis sumber — `null` untuk `user_manual` dan `label_extraction`.
  final String? sourceVersion;

  /// Tanggal pengguna meninjau dan mengonfirmasi nilai ini.
  final DateTime verifiedAt;

  /// `true` ketika pengguna pernah mengoreksi nilai gizi produk ini
  /// (Design D5). Sumber daring SHALL TIDAK menimpa nilai tanpa
  /// persetujuan ketika ini menyala.
  final bool userCorrected;

  /// Rujukan ke foto label sumber di perangkat (change 010, task 5.2) —
  /// `null` kecuali [sourceType] `label_extraction` DAN pengaturan retensi
  /// gambar pengguna mengizinkan penyimpanan (Design D9). SHALL TIDAK
  /// pernah menjadi rujukan ke penyimpanan di luar perangkat.
  final String? sourceImagePath;
}
