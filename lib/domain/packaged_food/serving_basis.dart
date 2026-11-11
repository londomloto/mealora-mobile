/// Basis takaran nilai gizi sebuah produk kemasan (spec
/// packaged-food-barcode, "Basis takaran dihitung dengan benar"; Design D4,
/// change 009).
///
/// Rekaman produk SHALL menyimpan basis aslinya apa adanya — konversi hanya
/// terjadi saat menghitung jumlah yang dimakan, tidak pernah saat menyimpan.
enum ServingBasis {
  /// Nilai pada rekaman adalah untuk SATU sajian — semantiknya sama persis
  /// dengan `ServingSize.nutrition` pada makanan non-kemasan (change 007).
  perServing,

  /// Nilai pada rekaman adalah per 100 gram — dikonversi memakai jumlah
  /// gram yang benar-benar dimakan, bukan jumlah sajian.
  perHundredGrams;

  /// Kode mesin yang disimpan — stabil, bukan untuk ditampilkan.
  String get stableCode => switch (this) {
    ServingBasis.perServing => 'per_serving',
    ServingBasis.perHundredGrams => 'per_100g',
  };

  static ServingBasis fromStableCode(String code) =>
      ServingBasis.values.firstWhere((b) => b.stableCode == code);
}
