import 'package:drift/drift.dart';

/// Membuat indeks pendukung tabel program (assessment §42, change 004).
///
/// Dua indeks unik parsial pertama adalah lapis pertama penegakan "satu
/// program berjalan per profil" (Design D3) — lapis keduanya adalah trigger
/// di `program_invariant_trigger.dart`, karena kedua indeks ini sendiri
/// tidak mencegah satu profil punya satu baris `active` *dan* satu baris
/// `paused` sekaligus.
Future<void> createProgramIndexes(DatabaseConnectionUser db) async {
  await db.customStatement('''
CREATE UNIQUE INDEX IF NOT EXISTS user_programs_one_active_per_profile
ON user_programs(profile_id)
WHERE status = 'active' AND deleted_at IS NULL;
''');

  await db.customStatement('''
CREATE UNIQUE INDEX IF NOT EXISTS user_programs_one_paused_per_profile
ON user_programs(profile_id)
WHERE status = 'paused' AND deleted_at IS NULL;
''');

  await db.customStatement('''
CREATE INDEX IF NOT EXISTS user_programs_profile_history
ON user_programs(profile_id, started_at);
''');

  // Indeks unik hidup pada pasangan (user_program_id, recorded_local_date) —
  // ini yang membuat pembangunan ulang potret kemajuan menjadi
  // penyisipan-atau-perbarui, bukan penambahan (Design D5).
  await db.customStatement('''
CREATE UNIQUE INDEX IF NOT EXISTS program_progress_one_per_user_program_per_date
ON program_progress(user_program_id, recorded_local_date)
WHERE deleted_at IS NULL;
''');

  await db.customStatement('''
CREATE INDEX IF NOT EXISTS program_events_user_program_history
ON program_events(user_program_id, occurred_at);
''');
}
