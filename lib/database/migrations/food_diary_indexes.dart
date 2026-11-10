import 'package:drift/drift.dart';

/// Membuat indeks pendukung katalog makanan dan buku harian (task 2.6,
/// change 007).
///
/// Pencarian memakai pencocokan substring tanpa peka huruf besar-kecil
/// (Design D3) — bukan indeks teks penuh — jadi indeks nama di sini
/// mempercepat pemindaian umum, bukan pencocokan substring itu sendiri.
Future<void> createFoodDiaryIndexes(DatabaseConnectionUser db) async {
  await db.customStatement('''
CREATE INDEX IF NOT EXISTS foods_name
ON foods(name) WHERE deleted_at IS NULL;
''');

  await db.customStatement('''
CREATE INDEX IF NOT EXISTS food_servings_food
ON food_servings(food_id) WHERE deleted_at IS NULL;
''');

  await db.customStatement('''
CREATE INDEX IF NOT EXISTS meal_entries_profile_date
ON meal_entries(profile_id, local_date) WHERE deleted_at IS NULL;
''');

  await db.customStatement('''
CREATE INDEX IF NOT EXISTS meal_entry_items_entry
ON meal_entry_items(meal_entry_id) WHERE deleted_at IS NULL;
''');
}
