import 'package:drift/drift.dart';
import 'package:mealora/database/tables/foods_table.dart';
import 'package:mealora/database/tables/user_record_columns.dart';

/// Nilai `serving_basis` yang sah — sama dengan `ServingBasis` di domain
/// (domain/packaged_food, change 009).
const List<String> kServingBasisValues = <String>['per_serving', 'per_100g'];

/// Nilai `source_type` yang sah untuk produk kemasan — berbeda dari
/// `Foods.sourceType` (katalog bawaan, change 007): produk kemasan berasal
/// dari sumber daring yang disetujui, dari pengisian manual pengguna
/// (`docs/packaged-food-sources.md`, change 009), atau dari pembacaan foto
/// label yang dikonfirmasi pengguna (change 010, Design D10).
const List<String> kPackagedFoodSourceTypeValues = <String>[
  'openfoodfacts',
  'user_manual',
  'label_extraction',
];

/// Sifat tambahan produk kemasan (spec packaged-food-barcode; Design D8,
/// change 009): satu baris per [Foods], menautkan barcode, ukuran kemasan,
/// basis takaran, dan provenans yang terpisah dari provenans katalog bawaan
/// `Foods` (jenis sumbernya berbeda, dan hanya produk kemasan yang punya
/// penanda koreksi pengguna). Produk kemasan SHALL selalu punya baris ini;
/// makanan katalog bawaan dan makanan buatan pengguna SHALL TIDAK.
@DataClassName('PackagedFoodPropertiesRow')
class PackagedFoodProperties extends Table with UserRecordColumns {
  TextColumn get foodId =>
      text().references(Foods, #id, onDelete: KeyAction.cascade).unique()();

  /// Nomor barcode (EAN/UPC) — pengenal pencarian, SHALL TIDAK dipakai
  /// sebagai sumber nilai gizi (spec, "Barcode adalah pengenal produk,
  /// bukan sumber nilai gizi"). `null` untuk produk yang dikonfirmasi lewat
  /// foto label tanpa barcode (change 010) — baris semacam ini hanya
  /// ditemukan lewat pencarian nama, tidak lewat pemindaian. SQLite
  /// memperlakukan tiap `NULL` sebagai berbeda pada indeks unik di bawah,
  /// jadi banyak produk tanpa barcode boleh bersisian.
  TextColumn get barcode => text().withLength(min: 8, max: 14).nullable()();

  /// Label ukuran kemasan sehari-hari (mis. "60 g"). `null` bila tidak
  /// diketahui dari sumber.
  TextColumn get packageSize => text().withLength(min: 1, max: 40).nullable()();

  /// Jumlah sajian per kemasan — SHALL terisi untuk [servingBasis]
  /// `per_serving` (dipakai menghitung "1 kemasan penuh"); boleh kosong
  /// untuk `per_100g`, yang dihitung dari gram yang benar-benar dimakan,
  /// bukan jumlah sajian (ditegakkan kode repositori, bukan `CHECK` SQL —
  /// pola yang sama dengan provenans opsional `Foods`, lihat komentar
  /// tabel itu).
  RealColumn get unitsPerPackage => real()
      // ignore: recursive_getters — idiom Drift untuk CHECK yang merujuk kolomnya sendiri.
      .check(unitsPerPackage.isBiggerThanValue(0))
      .nullable()();

  /// Basis takaran rekaman INI — disimpan apa adanya, konversi hanya saat
  /// menghitung jumlah yang dimakan (Design D4). Lihat `ServingBasis`
  /// (domain/packaged_food).
  TextColumn get servingBasis => text()
      .withLength(min: 1, max: 16)
      // ignore: recursive_getters
      .check(servingBasis.isIn(kServingBasisValues))();

  TextColumn get sourceType => text()
      .withLength(min: 1, max: 32)
      // ignore: recursive_getters
      .check(sourceType.isIn(kPackagedFoodSourceTypeValues))();

  /// Pengenal pada sumber (mis. kode produk Open Food Facts) — `null` untuk
  /// `user_manual`.
  TextColumn get sourceRef => text().withLength(min: 1, max: 64).nullable()();

  /// Versi/rilis sumber (mis. tanggal ekspor data) — `null` untuk
  /// `user_manual`.
  TextColumn get sourceVersion =>
      text().withLength(min: 1, max: 32).nullable()();

  /// Tanggal pengguna meninjau dan mengonfirmasi nilai ini — selalu terisi
  /// (spec, "Produk ditinjau sebelum dicatat").
  DateTimeColumn get verifiedAt => dateTime()();

  /// `true` ketika pengguna pernah mengoreksi nilai gizi produk ini (Design
  /// D5) — sumber daring SHALL TIDAK menimpa nilai tanpa persetujuan ketika
  /// bendera ini menyala (task 4.5).
  BoolColumn get userCorrected =>
      boolean().withDefault(const Constant(false))();

  /// Rujukan ke foto label sumber di perangkat (change 010, task 5.2) —
  /// `null` kecuali [sourceType] `label_extraction` DAN pengaturan retensi
  /// gambar pengguna mengizinkan penyimpanan (Design D9). Nilai opsional:
  /// rekaman `label_extraction` yang retensinya "hapus setelah dicatat"
  /// SHALL TIDAK mengisi kolom ini.
  TextColumn get sourceImagePath =>
      text().withLength(min: 1, max: 512).nullable()();
}
