import 'package:mealora/database/app_database.dart';
import 'package:mealora/domain/program/program_code.dart';

/// Memverifikasi katalog program pasca-migrasi (task 7.4, assessment §43):
/// tepat empat baris, dengan kode yang sama persis dengan [ProgramCode]
/// domain — tidak kurang, tidak lebih, tidak ganda.
Future<bool> verifyProgramCatalog(AppDatabase db) async {
  final rows = await db.select(db.programs).get();
  if (rows.length != ProgramCode.values.length) {
    return false;
  }
  final codes = rows.map((r) => r.code).toSet();
  if (codes.length != rows.length) {
    return false; // kode ganda
  }
  final expected = ProgramCode.values.map((c) => c.stableCode).toSet();
  return codes.containsAll(expected) && expected.containsAll(codes);
}
