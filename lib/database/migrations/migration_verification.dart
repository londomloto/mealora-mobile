import 'package:drift/drift.dart';

/// Hasil pemeriksaan pasca-migrasi.
final class MigrationCheck {
  const MigrationCheck({
    required this.schemaVersion,
    required this.expectedSchemaVersion,
    required this.foreignKeyViolations,
    required this.foreignKeysEnabled,
  });

  final int schemaVersion;
  final int expectedSchemaVersion;
  final int foreignKeyViolations;
  final bool foreignKeysEnabled;

  bool get isHealthy =>
      schemaVersion == expectedSchemaVersion &&
      foreignKeyViolations == 0 &&
      foreignKeysEnabled;

  @override
  String toString() =>
      'MigrationCheck(schemaVersion: $schemaVersion, '
      'expected: $expectedSchemaVersion, '
      'foreignKeyViolations: $foreignKeyViolations, '
      'foreignKeysEnabled: $foreignKeysEnabled)';
}

/// Memeriksa keadaan penyimpanan setelah migrasi dijalankan: versi skema
/// benar, kunci asing aktif, dan `PRAGMA foreign_key_check` bersih.
Future<MigrationCheck> verifyMigration(
  DatabaseConnectionUser db, {
  required int expectedSchemaVersion,
}) async {
  final versionRows = await db.customSelect('PRAGMA user_version').get();
  final fkRows = await db.customSelect('PRAGMA foreign_keys').get();
  final violations = await db.customSelect('PRAGMA foreign_key_check').get();

  return MigrationCheck(
    schemaVersion: versionRows.first.data.values.first! as int,
    expectedSchemaVersion: expectedSchemaVersion,
    foreignKeyViolations: violations.length,
    foreignKeysEnabled: (fkRows.first.data.values.first! as int) == 1,
  );
}
