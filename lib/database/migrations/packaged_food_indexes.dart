import 'package:drift/drift.dart';

/// Membuat indeks pencarian barcode produk kemasan di perangkat (task 2.3,
/// change 009).
///
/// Unik di antara baris aktif: satu barcode menunjuk ke paling banyak satu
/// produk tersimpan, konsisten dengan pencarian perangkat-lebih-dulu
/// (Design D1) — repositori mencari baris yang sudah ada sebelum membuat
/// yang baru, jadi duplikat barcode aktif adalah kesalahan, bukan keadaan
/// yang sah.
Future<void> createPackagedFoodIndexes(DatabaseConnectionUser db) async {
  await db.customStatement('''
CREATE UNIQUE INDEX IF NOT EXISTS packaged_food_properties_barcode
ON packaged_food_properties(barcode) WHERE deleted_at IS NULL;
''');

  await db.customStatement('''
CREATE INDEX IF NOT EXISTS packaged_food_properties_food
ON packaged_food_properties(food_id) WHERE deleted_at IS NULL;
''');
}
