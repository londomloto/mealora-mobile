import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/database/seeds/program_catalog_seed.dart';
import 'package:mealora/domain/program/program_code.dart';

import 'test_database.dart';

/// Seed katalog program: pengenal tetap, idempoten (task 2.1/2.2).
void main() {
  late AppDatabase db;

  setUp(() => db = createTestDatabase());
  tearDown(() => db.close());

  test('katalog diseed otomatis saat basis data dibuat', () async {
    final rows = await db.select(db.programs).get();
    expect(rows, hasLength(4));
    expect(
      rows.map((r) => r.code).toSet(),
      ProgramCode.values.map((c) => c.stableCode).toSet(),
    );
  });

  test('menjalankan seed tiga kali menghasilkan tepat empat baris dengan '
      'pengenal yang sama', () async {
    final before = await db.select(db.programs).get();
    final idsBefore = before.map((r) => r.id).toSet();

    await seedProgramCatalog(db);
    await seedProgramCatalog(db);
    await seedProgramCatalog(db);

    final after = await db.select(db.programs).get();
    expect(after, hasLength(4));
    expect(after.map((r) => r.id).toSet(), idsBefore);
    expect(idsBefore, kProgramCatalogIds.values.toSet());
  });

  test('pengenal baris katalog sama dengan konstanta tetap', () async {
    final rows = await db.select(db.programs).get();
    for (final row in rows) {
      final code = ProgramCode.values.firstWhere(
        (c) => c.stableCode == row.code,
      );
      expect(row.id, kProgramCatalogIds[code]);
    }
  });
}
