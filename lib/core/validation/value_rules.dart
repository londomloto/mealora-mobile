import 'package:mealora/core/errors/failure.dart';
import 'package:mealora/core/errors/result.dart';

/// Aturan nilai yang berlaku sebelum apa pun ditulis ke penyimpanan lokal.
///
/// Nilai yang belum diketahui disimpan sebagai `null`, bukan nol — nol adalah
/// hasil pengukuran, "belum diketahui" bukan.
abstract final class ValueRules {
  /// Jumlah, berat, tinggi, dan besaran sejenis: harus angka berhingga > 0.
  static Result<double> positiveAmount(double value, {required String field}) {
    if (value.isNaN || value.isInfinite) {
      return Err<double>(
        Failure(FailureCode.invalidValue, field: field, detail: 'bukan angka'),
      );
    }
    if (value <= 0) {
      return Err<double>(
        Failure(
          FailureCode.valueOutOfRange,
          field: field,
          detail: 'harus lebih besar dari nol',
        ),
      );
    }
    return Ok<double>(value);
  }

  /// Nilai gizi: `null` berarti belum diketahui; selain itu harus angka
  /// berhingga >= 0.
  static Result<double?> nutrientValue(double? value, {required String field}) {
    if (value == null) {
      return const Ok<double?>(null);
    }
    if (value.isNaN || value.isInfinite) {
      return Err<double?>(
        Failure(FailureCode.invalidValue, field: field, detail: 'bukan angka'),
      );
    }
    if (value < 0) {
      return Err<double?>(
        Failure(
          FailureCode.valueOutOfRange,
          field: field,
          detail: 'tidak boleh negatif',
        ),
      );
    }
    return Ok<double?>(value);
  }

  /// Teks wajib: tidak boleh kosong setelah spasi tepi dibuang.
  static Result<String> requiredText(String value, {required String field}) {
    final trimmed = value.trim();
    if (trimmed.isEmpty) {
      return Err<String>(
        Failure(
          FailureCode.invalidValue,
          field: field,
          detail: 'tidak boleh kosong',
        ),
      );
    }
    return Ok<String>(trimmed);
  }
}
