import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/errors/failure.dart';
import 'package:mealora/core/errors/result.dart';
import 'package:mealora/domain/shared/units.dart';

/// Rentang nilai profil yang dianggap masuk akal (FRS 2.3.5, scenario
/// "Tinggi badan tidak masuk akal").
///
/// Sengaja lebih ketat dari rentang fisik umum di `Length`/`Mass`
/// (domain/shared/units.dart, dipakai program dan kalkulator): rentang di
/// sana hanya menolak nilai yang mustahil secara fisik untuk siapa pun,
/// sedangkan rentang di sini khusus untuk orang yang memakai Mealora.
/// Keputusan kelayakan program (usia atau IMT di luar cakupan kebijakan
/// gizi) tetap domain terpisah (change 002/003, `EligibilityGate`) — ini
/// hanya pemeriksaan "masuk akal sebagai isian", bukan penilaian kelayakan.
abstract final class ProfileValueRules {
  static const int minAgeYears = 13;
  static const int maxAgeYears = 120;
  static const double minHeightCm = 90;
  static const double maxHeightCm = 250;
  static const double minWeightKg = 20;
  static const double maxWeightKg = 300;
  static const int maxNicknameLength = 60;

  static Result<Length> height(double cm) {
    if (cm.isNaN || cm.isInfinite) {
      return const Err<Length>(
        Failure(
          FailureCode.invalidValue,
          field: 'height',
          detail: 'bukan angka',
        ),
      );
    }
    if (cm < minHeightCm || cm > maxHeightCm) {
      return const Err<Length>(
        Failure(
          FailureCode.valueOutOfRange,
          field: 'height',
          detail: 'harus antara $minHeightCm dan $maxHeightCm cm',
        ),
      );
    }
    return Length.cmValue(cm, field: 'height');
  }

  static Result<Mass> currentWeight(double kg) =>
      _weight(kg, field: 'currentWeight');

  /// Berat tujuan (Turun Berat/Naik Berat, `25 · Target berat program`) —
  /// rentang masuk akal yang sama dengan [currentWeight]; batas laju dan
  /// kelayakan terhadap berat saat ini adalah domain terpisah
  /// (`EligibilityGate`, change 002/003), bukan pemeriksaan di sini.
  static Result<Mass> targetWeight(double kg) =>
      _weight(kg, field: 'targetWeight');

  static Result<Mass> _weight(double kg, {required String field}) {
    if (kg.isNaN || kg.isInfinite) {
      return Err<Mass>(
        Failure(FailureCode.invalidValue, field: field, detail: 'bukan angka'),
      );
    }
    if (kg < minWeightKg || kg > maxWeightKg) {
      return Err<Mass>(
        Failure(
          FailureCode.valueOutOfRange,
          field: field,
          detail: 'harus antara $minWeightKg dan $maxWeightKg kg',
        ),
      );
    }
    return Mass.kgValue(kg, field: field);
  }

  /// [asOfToday] datang dari `Clock` yang disuntikkan pemanggil (konvensi
  /// change 001) — fungsi ini sendiri tidak membaca jam sistem.
  static Result<LocalDate> birthDate(
    LocalDate value, {
    required LocalDate asOfToday,
  }) {
    final age = ageInYears(value, asOfToday);
    if (age == null) {
      return const Err<LocalDate>(
        Failure(
          FailureCode.invalidValue,
          field: 'birthDate',
          detail: 'tanggal lahir tidak boleh di masa depan',
        ),
      );
    }
    if (age < minAgeYears || age > maxAgeYears) {
      return const Err<LocalDate>(
        Failure(
          FailureCode.valueOutOfRange,
          field: 'birthDate',
          detail: 'usia harus antara $minAgeYears dan $maxAgeYears tahun',
        ),
      );
    }
    return Ok<LocalDate>(value);
  }

  static Result<String> nickname(String value) {
    final trimmed = value.trim();
    if (trimmed.length > maxNicknameLength) {
      return const Err<String>(
        Failure(
          FailureCode.valueOutOfRange,
          field: 'nickname',
          detail: 'maksimum $maxNicknameLength karakter',
        ),
      );
    }
    return Ok<String>(trimmed);
  }

  /// Usia dalam tahun penuh pada [asOf], atau `null` bila [birth] berada di
  /// masa depan relatif terhadap [asOf].
  static int? ageInYears(LocalDate birth, LocalDate asOf) {
    if (birth.compareTo(asOf) > 0) {
      return null;
    }
    var age = asOf.year - birth.year;
    final hadBirthdayThisYear =
        (asOf.month > birth.month) ||
        (asOf.month == birth.month && asOf.day >= birth.day);
    if (!hadBirthdayThisYear) {
      age -= 1;
    }
    return age;
  }
}
