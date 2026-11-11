import 'package:mealora/domain/packaged_food/packaged_food.dart';

/// Kontrak repositori produk kemasan (change 009) — diimplementasikan oleh
/// Drift, memakai `ProductDataSourceClient` di baliknya (Design D2).
abstract interface class PackagedFoodRepository {
  /// Mencari produk menurut [barcode]: perangkat lebih dulu, baru sumber
  /// daring bila tidak ketemu di perangkat (Design D1). `null` bila tidak
  /// ditemukan di perangkat maupun daring (atau sumber daring gagal/lambat
  /// — task 4.6).
  ///
  /// Hasil dari sumber daring BELUM tersimpan — hanya menjadi rekaman
  /// sungguhan setelah [confirm] dipanggil (spec, "Produk ditinjau sebelum
  /// dicatat"); pengenal pada hasil yang belum tersimpan ini sementara dan
  /// dibuang bila tidak pernah dikonfirmasi.
  Future<PackagedFood?> findByBarcode(String barcode);

  /// Menyimpan [product] sebagai produk yang dikonfirmasi pengguna,
  /// beserta seluruh provenansnya (task 4.4).
  ///
  /// Bila barcode [product] sudah tersimpan, baris yang ada diperbarui
  /// (bukan duplikat baru) dan `userCorrected` SHALL TIDAK pernah turun
  /// dari `true` ke `false` lewat panggilan ini — sekali terkoreksi, tetap
  /// tercatat terkoreksi (Design D5), meskipun `product.provenance`
  /// masuk membawa `userCorrected: false`. Mengembalikan [PackagedFood]
  /// tersimpan dengan pengenal aslinya.
  Future<PackagedFood> confirm(PackagedFood product);
}
