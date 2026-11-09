import 'package:drift/drift.dart';
import 'package:mealora/database/tables/profiles_table.dart';
import 'package:mealora/database/tables/programs_table.dart';
import 'package:mealora/database/tables/user_record_columns.dart';

/// Nilai `status` yang sah — sama dengan `ProgramState` di domain
/// (change 003).
const List<String> kUserProgramStatuses = <String>[
  'draft',
  'active',
  'paused',
  'completed',
  'changed',
  'cancelled',
];

/// Pendaftaran seorang pengguna pada sebuah program (assessment
/// `user_programs`, change 004).
///
/// `profileId` adalah foreign key sungguhan ke tabel `profiles` (Design D8,
/// change 005) — sampai change 005, kolom ini hanya pengenal tanpa tabel
/// tujuan (lihat catatan migrasi versi 2 ke 3 di `app_database.dart`), dan
/// keutuhan rujukan ditegakkan kode saja.
///
/// Nama kelas baris diberi akhiran `Row` secara eksplisit — nama bawaan
/// Drift untuk tabel ini (`UserProgram`) bentrok dengan kelas domain
/// `UserProgram` (change 003).
@DataClassName('UserProgramRow')
class UserPrograms extends Table with UserRecordColumns {
  TextColumn get profileId => text()
      .withLength(min: 1, max: 64)
      .references(Profiles, #id, onDelete: KeyAction.restrict)();

  TextColumn get programId =>
      text().references(Programs, #id, onDelete: KeyAction.restrict)();

  TextColumn get status => text()
      .withLength(min: 1, max: 16)
      // ignore: recursive_getters — idiom Drift untuk CHECK yang merujuk kolomnya sendiri.
      .check(status.isIn(kUserProgramStatuses))();

  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get pausedAt => dateTime().nullable()();
  DateTimeColumn get endedAt => dateTime().nullable()();

  RealColumn get baselineWeightKg => real().nullable()();
  RealColumn get targetWeightKg => real().nullable()();

  /// Tanggal tujuan, `YYYY-MM-DD` lokal — selaras dengan `LocalDate.iso`.
  TextColumn get targetDate => text().withLength(min: 10, max: 10).nullable()();

  RealColumn get dailyEnergyTargetKcal => real().nullable()();
  RealColumn get proteinTargetG => real().nullable()();
  RealColumn get carbohydrateTargetG => real().nullable()();
  RealColumn get fatTargetG => real().nullable()();
  RealColumn get fiberTargetG => real().nullable()();

  /// Salinan JSON dari `ProgramProposalInputs` yang dipakai saat proposal
  /// disetujui (Design D9, change 003) — dibandingkan ulang saat aktivasi,
  /// dibekukan untuk riwayat.
  TextColumn get inputSnapshotJson => text()();

  TextColumn get calculatorVersion => text().withLength(min: 1, max: 32)();
  TextColumn get policyVersion => text().withLength(min: 1, max: 32)();

  /// Belum diisi kode manapun di change ini — perintah jeda (change 003)
  /// tidak meminta alasan. Kolom disediakan sesuai assessment §42 untuk
  /// change berikutnya tanpa menuntut migrasi baru.
  TextColumn get pauseReason => text().withLength(min: 1, max: 64).nullable()();

  TextColumn get completionReason =>
      text().withLength(min: 1, max: 64).nullable()();

  TextColumn get supersedesUserProgramId => text().nullable()();
  TextColumn get supersededByUserProgramId => text().nullable()();
}
