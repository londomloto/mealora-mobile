import 'package:drift/drift.dart';

/// Membuat indeks pendukung catatan berat (task 1.3, change 008).
Future<void> createWeightIndexes(DatabaseConnectionUser db) async {
  await db.customStatement('''
CREATE INDEX IF NOT EXISTS weight_records_profile_date
ON weight_records(profile_id, local_date) WHERE deleted_at IS NULL;
''');
}
