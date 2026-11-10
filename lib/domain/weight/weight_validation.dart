import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/errors/failure.dart';
import 'package:mealora/core/errors/result.dart';
import 'package:mealora/domain/profile/profile_validation.dart';

/// Aturan nilai untuk catatan berat (change 008, design D9).
///
/// Rentang berat yang masuk akal memakai ulang [ProfileValueRules] — satu
/// definisi "berat masuk akal sebagai isian" untuk seluruh aplikasi, bukan
/// rentang kedua yang bisa menyimpang (lihat juga
/// `ProfileValueRules.currentWeight`).
abstract final class WeightRecordValidation {
  static Result<double> weightKg(double kg) {
    final validated = ProfileValueRules.currentWeight(kg);
    return switch (validated) {
      Ok(:final value) => Ok<double>(value.kg),
      Err(:final failure) => Err<double>(failure),
    };
  }

  /// [asOfToday] datang dari `Clock` yang disuntikkan pemanggil (konvensi
  /// change 001) — fungsi ini sendiri tidak membaca jam sistem.
  static Result<LocalDate> recordDate(
    LocalDate value, {
    required LocalDate asOfToday,
  }) {
    if (value.compareTo(asOfToday) > 0) {
      return const Err<LocalDate>(
        Failure(
          FailureCode.invalidValue,
          field: 'localDate',
          detail: 'tanggal catatan tidak boleh di masa depan',
        ),
      );
    }
    return Ok<LocalDate>(value);
  }
}
