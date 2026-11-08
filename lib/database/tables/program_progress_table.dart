import 'package:drift/drift.dart';
import 'package:mealora/database/tables/user_programs_table.dart';
import 'package:mealora/database/tables/user_record_columns.dart';

/// Potret kemajuan program per tanggal lokal (assessment `program_progress`,
/// Design D5/D6, change 004).
///
/// Turunan, bukan sumber kebenaran: catatan makanan dan berat badan tetap
/// otoritatif, potret ini dapat dibangun ulang kapan saja (idempoten lewat
/// indeks unik hidup pada `(user_program_id, recorded_local_date)` — lihat
/// migrasi).
///
/// Seluruh kolom nilai dapat kosong (Design D6): `null` berarti "belum
/// diketahui", berbeda dari nol yang berarti "diketahui nol". Kolom
/// pencacah ([loggedMealsCount], [activeDayNumber]) selalu terisi karena
/// nol di sana memang fakta yang diketahui.
///
/// Nama kelas baris diberi akhiran `Row` secara eksplisit — nama bawaan
/// Drift untuk tabel ini (`ProgramProgres`, huruf "s" terakhir terpotong)
/// janggal dan membingungkan.
@DataClassName('ProgramProgressRow')
class ProgramProgress extends Table with UserRecordColumns {
  TextColumn get userProgramId =>
      text().references(UserPrograms, #id, onDelete: KeyAction.restrict)();

  /// Tanggal lokal (`YYYY-MM-DD`) saat dicatat — tidak pernah dihitung ulang
  /// dari instan UTC pada waktu baca (spec program-progress, "Zona waktu
  /// berubah").
  TextColumn get recordedLocalDate => text().withLength(min: 10, max: 10)();

  DateTimeColumn get recordedAt => dateTime()();

  RealColumn get weightKg => real().nullable()();
  RealColumn get weightChangeKg => real().nullable()();
  RealColumn get targetProgressRatio => real().nullable()();
  RealColumn get consumedEnergyKcal => real().nullable()();
  RealColumn get energyAdherenceRatio => real().nullable()();
  RealColumn get proteinG => real().nullable()();
  RealColumn get carbohydrateG => real().nullable()();
  RealColumn get fatG => real().nullable()();

  IntColumn get loggedMealsCount => integer().withDefault(const Constant(0))();
  BoolColumn get diaryComplete =>
      boolean().withDefault(const Constant(false))();

  /// Hari aktif ke berapa sejak program dimulai — hari dalam rentang jeda
  /// tidak menambah angka ini (spec program-progress, "Hari dalam keadaan
  /// jeda").
  IntColumn get activeDayNumber => integer()();

  /// Ukuran tambahan yang belum punya kolom sendiri (mis. kualitas gizi
  /// Makan Sehat) — lihat design.md, Open Questions.
  TextColumn get metricsJson => text().withDefault(const Constant('{}'))();

  TextColumn get calculationVersion => text().withLength(min: 1, max: 32)();
}
