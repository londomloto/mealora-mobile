/// Nilai terbungkus tipe untuk satuan yang dipakai domain nutrisi dan
/// program.
///
/// Energi, massa, panjang, dan persentase dibungkus tipe tersendiri, bukan
/// `double` telanjang, sehingga kilogram tidak dapat diberikan ke parameter
/// yang mengharapkan kilokalori (change 003, Design D3). Setiap konstruktor
/// menolak nilai bukan-angka, tak hingga, dan nilai di luar rentang yang
/// masuk akal secara fisik.
library;

import 'package:mealora/core/errors/failure.dart';
import 'package:mealora/core/errors/result.dart';
import 'package:mealora/domain/shared/rounding.dart';

bool _isUsable(double value) => !value.isNaN && !value.isInfinite;

/// Energi dalam kilokalori (kkal).
///
/// Boleh negatif untuk merepresentasikan selisih (defisit/surplus
/// bertanda), tetapi selalu berhingga dan masuk akal secara fisik.
final class Energy {
  const Energy._(this.kcal);

  static Result<Energy> kcalValue(double kcal, {required String field}) {
    if (!_isUsable(kcal)) {
      return Err<Energy>(
        Failure(FailureCode.invalidValue, field: field, detail: 'bukan angka'),
      );
    }
    if (kcal.abs() > 20000) {
      return Err<Energy>(
        Failure(
          FailureCode.valueOutOfRange,
          field: field,
          detail: 'di luar rentang energi yang masuk akal',
        ),
      );
    }
    return Ok<Energy>(Energy._(kcal));
  }

  /// Nol kkal, dipakai sebagai titik awal akumulasi.
  static const zero = Energy._(0);

  final double kcal;

  /// Energi ini dibulatkan ke kelipatan 10 kkal terdekat (G1).
  Energy get roundedToTen => Energy._(Rounding.toNearest(kcal, 10));

  Energy operator +(Energy other) => Energy._(kcal + other.kcal);

  Energy operator -(Energy other) => Energy._(kcal - other.kcal);

  Energy operator -() => Energy._(-kcal);

  Energy times(double factor) => Energy._(kcal * factor);

  bool operator <(Energy other) => kcal < other.kcal;

  bool operator <=(Energy other) => kcal <= other.kcal;

  bool operator >(Energy other) => kcal > other.kcal;

  bool operator >=(Energy other) => kcal >= other.kcal;

  @override
  bool operator ==(Object other) => other is Energy && other.kcal == kcal;

  @override
  int get hashCode => kcal.hashCode;

  @override
  String toString() => '${kcal.toStringAsFixed(2)} kkal';
}

/// Massa dalam kilogram (kg). Selalu lebih besar dari nol.
final class Mass {
  const Mass._(this.kg);

  static Result<Mass> kgValue(double kg, {required String field}) {
    if (!_isUsable(kg)) {
      return Err<Mass>(
        Failure(FailureCode.invalidValue, field: field, detail: 'bukan angka'),
      );
    }
    if (kg <= 0 || kg > 500) {
      return Err<Mass>(
        Failure(
          FailureCode.valueOutOfRange,
          field: field,
          detail: 'di luar rentang berat badan yang masuk akal',
        ),
      );
    }
    return Ok<Mass>(Mass._(kg));
  }

  final double kg;

  /// Massa ini dibulatkan ke 0,1 kg terdekat (G3).
  Mass get roundedToOneDecimal => Mass._(Rounding.toNearest(kg, 0.1));

  bool operator <(Mass other) => kg < other.kg;

  bool operator <=(Mass other) => kg <= other.kg;

  bool operator >(Mass other) => kg > other.kg;

  bool operator >=(Mass other) => kg >= other.kg;

  @override
  bool operator ==(Object other) => other is Mass && other.kg == kg;

  @override
  int get hashCode => kg.hashCode;

  @override
  String toString() => '${kg.toStringAsFixed(2)} kg';
}

/// Panjang dalam sentimeter (cm). Dipakai untuk tinggi badan. Selalu lebih
/// besar dari nol.
final class Length {
  const Length._(this.cm);

  static Result<Length> cmValue(double cm, {required String field}) {
    if (!_isUsable(cm)) {
      return Err<Length>(
        Failure(FailureCode.invalidValue, field: field, detail: 'bukan angka'),
      );
    }
    if (cm <= 0 || cm > 300) {
      return Err<Length>(
        Failure(
          FailureCode.valueOutOfRange,
          field: field,
          detail: 'di luar rentang tinggi badan yang masuk akal',
        ),
      );
    }
    return Ok<Length>(Length._(cm));
  }

  final double cm;

  double get meters => cm / 100;

  @override
  bool operator ==(Object other) => other is Length && other.cm == cm;

  @override
  int get hashCode => cm.hashCode;

  @override
  String toString() => '${cm.toStringAsFixed(1)} cm';
}

/// Persentase sebagai pecahan (0,0–1,0), bukan angka 0–100 telanjang.
final class Percentage {
  const Percentage._(this.fraction);

  static Result<Percentage> fractionValue(
    double fraction, {
    required String field,
  }) {
    if (!_isUsable(fraction)) {
      return Err<Percentage>(
        Failure(FailureCode.invalidValue, field: field, detail: 'bukan angka'),
      );
    }
    if (fraction < 0 || fraction > 2) {
      return Err<Percentage>(
        Failure(
          FailureCode.valueOutOfRange,
          field: field,
          detail: 'di luar rentang persentase yang masuk akal',
        ),
      );
    }
    return Ok<Percentage>(Percentage._(fraction));
  }

  final double fraction;

  double get asPercent => fraction * 100;

  @override
  bool operator ==(Object other) =>
      other is Percentage && other.fraction == fraction;

  @override
  int get hashCode => fraction.hashCode;

  @override
  String toString() => '${asPercent.toStringAsFixed(1)}%';
}
