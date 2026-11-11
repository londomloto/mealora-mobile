import 'package:drift/drift.dart';

/// Membuat indeks pencarian draf foto makanan per profil (change
/// 011-food-photo-input, task 3.1) — satu profil biasanya punya paling
/// banyak satu draf aktif, tetapi tabel tidak menegakkan itu lewat `UNIQUE`:
/// repositori yang memutuskan draf mana yang "terbaru" lewat `updated_at`.
Future<void> createFoodPhotoDraftIndexes(DatabaseConnectionUser db) async {
  await db.customStatement('''
CREATE INDEX IF NOT EXISTS food_photo_drafts_profile
ON food_photo_drafts(profile_id, updated_at) WHERE deleted_at IS NULL;
''');
}
