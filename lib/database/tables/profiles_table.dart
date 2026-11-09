import 'package:drift/drift.dart';
import 'package:mealora/database/tables/user_record_columns.dart';

/// Nilai `biological_input` yang sah — sama dengan `BiologicalInput` di
/// domain (domain/nutrition, change 002).
const List<String> kBiologicalInputValues = <String>['male', 'female'];

/// Nilai `activity_level` yang sah — sama dengan `ActivityLevel` di domain
/// (domain/nutrition, change 002).
const List<String> kActivityLevelValues = <String>[
  'sedentary',
  'moderatelyActive',
  'veryActive',
];

/// Profil lokal pengguna (assessment §11, Design D8, change 005).
///
/// Satu tabel per perangkat, mengikuti konvensi record pengguna change 001.
/// Setiap bidang domain boleh kosong — profil disimpan bertahap selama
/// onboarding (Design D2) — kecuali [onboardingComplete], yang berdefault
/// salah dan satu-satunya penanda yang dipakai untuk memutuskan apakah
/// perhitungan target boleh dijalankan.
///
/// Nama kelas baris diberi akhiran `Row` secara eksplisit, selaras dengan
/// `UserProgramRow`/`ProgramEventRow` (change 004) — menghindari bentrok
/// dengan kelas domain `UserProfile`.
@DataClassName('ProfileRow')
class Profiles extends Table with UserRecordColumns {
  TextColumn get nickname => text().withLength(min: 1, max: 60).nullable()();

  /// `YYYY-MM-DD`, selaras dengan `LocalDate.iso` (konvensi change 001/004).
  TextColumn get birthDate => text().withLength(min: 10, max: 10).nullable()();

  RealColumn get heightCm => real().nullable()();
  RealColumn get currentWeightKg => real().nullable()();

  // `x IN (...)` pada SQLite bernilai NULL (bukan salah) ketika `x` sendiri
  // NULL, dan CHECK menerima NULL sebagai lolos — jadi `isIn` saja sudah
  // cukup untuk kolom nullable ini, tanpa `| isNull()` terpisah.
  TextColumn get biologicalInput => text()
      .withLength(min: 1, max: 16)
      .nullable()
      // ignore: recursive_getters — idiom Drift untuk CHECK yang merujuk kolomnya sendiri.
      .check(biologicalInput.isIn(kBiologicalInputValues))();

  TextColumn get activityLevel => text()
      .withLength(min: 1, max: 24)
      .nullable()
      // ignore: recursive_getters
      .check(activityLevel.isIn(kActivityLevelValues))();

  BoolColumn get onboardingComplete =>
      boolean().withDefault(const Constant(false))();
}
