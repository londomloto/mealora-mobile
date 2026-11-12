import 'package:drift/drift.dart';
import 'package:mealora/database/tables/user_record_columns.dart';

/// Nilai `category` yang sah — sama dengan `FoodCategory` di domain
/// (domain/food, change 007).
const List<String> kFoodCategoryValues = <String>[
  'staple',
  'side_dish',
  'vegetable',
  'snack',
  'drink',
  'other',
];

/// Nilai `form` yang sah (Design D2, change 015): `ready` = siap konsumsi
/// (seduhan, masakan), `raw` = bahan mentah, `dry` = bahan kering.
const List<String> kFoodFormValues = <String>['ready', 'raw', 'dry'];

/// Katalog makanan di perangkat: bawaan (dengan provenans) atau buatan
/// pengguna (assessment §11, spec food-catalog, change 007).
///
/// Kolom provenans ([sourceType], [sourceRef], [sourceVersion],
/// [verifiedAt]) SHALL terisi untuk makanan bawaan dan SHALL kosong untuk
/// makanan buatan pengguna (`isUserCreated = true`) — ditegakkan kode seed
/// dan repositori, bukan `CHECK` SQL, karena SQLite tidak dapat
/// mengekspresikan "semua atau tidak ada kolom ini terisi" dengan ringkas.
@DataClassName('FoodRow')
class Foods extends Table with UserRecordColumns {
  TextColumn get name => text().withLength(min: 1, max: 120)();
  TextColumn get brand => text().withLength(min: 1, max: 120).nullable()();

  TextColumn get category => text()
      .withLength(min: 1, max: 16)
      // ignore: recursive_getters — idiom Drift untuk CHECK yang merujuk kolomnya sendiri.
      .check(category.isIn(kFoodCategoryValues))();

  BoolColumn get isUserCreated =>
      boolean().withDefault(const Constant(false))();

  /// Jenis sumber (mis. `usda_fdc`, `tkpi`) — lihat
  /// `mealora-plans/docs/food-data-sources.md`.
  TextColumn get sourceType => text().withLength(min: 1, max: 32).nullable()();

  /// Pengenal pada sumber tersebut (mis. FDC ID USDA).
  TextColumn get sourceRef => text().withLength(min: 1, max: 64).nullable()();

  TextColumn get sourceVersion =>
      text().withLength(min: 1, max: 32).nullable()();

  DateTimeColumn get verifiedAt => dateTime().nullable()();

  /// Bentuk makanan untuk mengurutkan entri siap konsumsi di atas bahan
  /// (change 015). `null` untuk makanan buatan pengguna atau yang belum
  /// dikurasi.
  TextColumn get form => text()
      .withLength(min: 1, max: 8)
      // ignore: recursive_getters — idiom Drift untuk CHECK yang merujuk kolomnya sendiri.
      .check(form.isIn(kFoodFormValues))
      .nullable()();

  /// `false` menyembunyikan makanan dari pencarian tanpa menghapusnya —
  /// baris yang pernah dicatat tidak bisa dihapus karena relasi `restrict`
  /// dari `meal_entry_items` (Design D2, change 015).
  BoolColumn get isActive => boolean().withDefault(const Constant(true))();
}
