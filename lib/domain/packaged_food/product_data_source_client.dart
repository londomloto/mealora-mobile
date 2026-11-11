import 'package:mealora/domain/food/nutrition_profile.dart';
import 'package:mealora/domain/packaged_food/serving_basis.dart';

/// Hasil pencarian daring untuk satu barcode — fakta produk SAJA, belum
/// menjadi rekaman tersimpan dan belum punya provenans lengkap (Design D2,
/// change 009). Repositori yang melengkapi `verifiedAt`/`userCorrected`
/// ketika menyusun kandidat untuk ditinjau, dan yang menyimpannya setelah
/// pengguna mengonfirmasi (spec, "Produk ditinjau sebelum dicatat").
final class RemoteProductLookup {
  const RemoteProductLookup({
    required this.name,
    required this.servingBasis,
    required this.nutritionAtRecordedBasis,
    this.brand,
    this.packageSize,
    this.servingSizeGrams,
    this.unitsPerPackage,
    this.sourceRef,
    this.sourceVersion,
  });

  final String name;
  final String? brand;

  /// Label ukuran kemasan apa adanya dari sumber (mis. "60 g").
  final String? packageSize;

  /// Padanan gram satu sajian, bila sumber menyatakannya — dipakai sebagai
  /// `ServingSize.gramEquivalent` pada [ServingBasis.perServing].
  final double? servingSizeGrams;

  /// `null` bila sumber tidak menyatakan jumlah sajian per kemasan secara
  /// dapat ditelusuri — jalur "satu kemasan penuh" tidak ditawarkan untuk
  /// produk ini (bukan kesalahan; lihat `PackagedFood.unitsPerPackage`).
  final double? unitsPerPackage;

  /// Basis nilai gizi PADA RESPONS SUMBER INI — disimpan apa adanya
  /// (Design D4), bukan dikonversi di sini.
  final ServingBasis servingBasis;
  final NutritionProfile nutritionAtRecordedBasis;

  /// Pengenal pada sumber (mis. kode produk) — `null` bila sumber tidak
  /// memberinya terpisah dari barcode itu sendiri.
  final String? sourceRef;

  /// Versi/rilis sumber (mis. tanggal data terakhir diperbarui pada
  /// sumber) — `null` bila tidak diketahui.
  final String? sourceVersion;
}

/// Klien sumber data produk kemasan yang dapat diganti (Design D2, change
/// 009) — dipanggil repositori HANYA ketika barcode tidak ketemu di
/// perangkat dan perangkat sedang daring (Design D1). Implementasi SHALL
/// TIDAK mengirim apa pun selain nomor barcode (Design D3): tanpa gambar,
/// pengenal perangkat, atau data profil pengguna.
abstract interface class ProductDataSourceClient {
  /// `null` bila tidak ditemukan pada sumber ini, lambat melewati batas
  /// waktu, atau sumber gagal/menolak permintaan — implementasi
  /// memperlakukan ketiganya sama dan SHALL TIDAK melempar pengecualian ke
  /// pemanggil (task 4.6): repositori memperlakukan `null` sebagai "belum
  /// ditemukan daring", bukan sebagai kegagalan yang mengorbankan jalur
  /// luring.
  Future<RemoteProductLookup?> lookupByBarcode(String barcode);
}
