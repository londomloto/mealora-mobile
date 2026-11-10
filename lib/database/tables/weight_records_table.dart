import 'package:drift/drift.dart';
import 'package:mealora/database/tables/profiles_table.dart';
import 'package:mealora/database/tables/user_record_columns.dart';

/// Satu catatan berat badan: satu profil, satu tanggal lokal (change 008).
///
/// Berat "saat ini" adalah catatan terbaru yang hidup, bukan kolom
/// tersendiri pada profil (design D1) — menghindari dua sumber kebenaran
/// yang pasti berbeda cepat atau lambat.
@DataClassName('WeightRecordRow')
class WeightRecords extends Table with UserRecordColumns {
  TextColumn get profileId =>
      text().references(Profiles, #id, onDelete: KeyAction.restrict)();

  /// Tanggal lokal (`YYYY-MM-DD`) saat dicatat — tidak pernah dihitung ulang
  /// dari instan UTC pada waktu baca (spec weight-tracking, konvensi change
  /// 004/007).
  TextColumn get localDate => text().withLength(min: 10, max: 10)();

  DateTimeColumn get recordedAt => dateTime()();

  RealColumn get weightKg => real()();

  TextColumn get note => text().nullable()();
}
