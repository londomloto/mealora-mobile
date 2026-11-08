import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/database/migrations/program_catalog_verification.dart';

import 'test_database.dart';

/// Verifikasi katalog pasca-migrasi (task 7.4).
void main() {
  late AppDatabase db;

  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  test('katalog yang diseed otomatis dinyatakan valid', () async {
    expect(await verifyProgramCatalog(db), isTrue);
  });

  test('katalog dengan baris yang dihapus dinyatakan tidak valid', () async {
    final rows = await db.select(db.programs).get();
    await (db.delete(
      db.programs,
    )..where((t) => t.id.equals(rows.first.id))).go();

    expect(await verifyProgramCatalog(db), isFalse);
  });

  test(
    'katalog dengan baris ekstra (lebih dari empat) dinyatakan tidak valid',
    () async {
      await db
          .into(db.programs)
          .insert(
            ProgramsCompanion.insert(
              id: 'extra-program',
              code: 'extra_code',
              name: 'Ekstra',
              description: 'Ekstra',
              requiresWeightTarget: false,
              sortOrder: 99,
              definitionVersion: 1,
              createdAt: testInstant,
              updatedAt: testInstant,
            ),
          );

      expect(await verifyProgramCatalog(db), isFalse);
    },
  );
}
