import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/core/errors/failure.dart';
import 'package:mealora/core/errors/result.dart';
import 'package:mealora/domain/shared/units.dart';

void main() {
  group('Energy', () {
    test('menolak NaN dan tak hingga', () {
      expect(
        Energy.kcalValue(double.nan, field: 'x').failureOrNull?.code,
        FailureCode.invalidValue,
      );
      expect(
        Energy.kcalValue(double.infinity, field: 'x').failureOrNull?.code,
        FailureCode.invalidValue,
      );
    });

    test('menolak nilai di luar rentang yang masuk akal', () {
      expect(Energy.kcalValue(50000, field: 'x').isErr, isTrue);
    });

    test(
      'membulatkan ke kelipatan 10 kkal terdekat, setengah menjauhi nol',
      () {
        final cases = <double, double>{
          1800.0: 1800,
          1804.9: 1800,
          1805.0: 1810,
          1805.1: 1810,
          2960.0: 2960,
          2254.8: 2250,
        };
        cases.forEach((input, expected) {
          final energy =
              (Energy.kcalValue(input, field: 'x') as Ok<Energy>).value;
          expect(
            energy.roundedToTen.kcal,
            expected,
            reason: '$input -> $expected',
          );
        });
      },
    );

    test('tidak dapat tertukar dengan Mass secara statis (uji kompilasi)', () {
      // Fungsi berikut hanya ada untuk memastikan tanda tangan tipe benar;
      // mengganti Energy dengan Mass pada baris ini akan gagal kompilasi.
      Energy identity(Energy e) => e;
      final energy = (Energy.kcalValue(100, field: 'x') as Ok<Energy>).value;
      expect(identity(energy), energy);
    });
  });

  group('Mass', () {
    test('menolak nol dan negatif', () {
      expect(Mass.kgValue(0, field: 'w').isErr, isTrue);
      expect(Mass.kgValue(-5, field: 'w').isErr, isTrue);
    });

    test('membulatkan ke 0,1 kg terdekat', () {
      final mass = (Mass.kgValue(62.649, field: 'w') as Ok<Mass>).value;
      expect(mass.roundedToOneDecimal.kg, closeTo(62.6, 1e-9));
    });
  });

  group('Length', () {
    test('menolak nol dan nilai tidak masuk akal', () {
      expect(Length.cmValue(0, field: 'h').isErr, isTrue);
      expect(Length.cmValue(400, field: 'h').isErr, isTrue);
    });

    test('menerima tinggi badan wajar', () {
      expect(Length.cmValue(165, field: 'h').isOk, isTrue);
    });
  });

  group('Percentage', () {
    test('menolak nilai bukan angka dan di luar rentang', () {
      expect(Percentage.fractionValue(double.nan, field: 'p').isErr, isTrue);
      expect(Percentage.fractionValue(-0.1, field: 'p').isErr, isTrue);
      expect(Percentage.fractionValue(3, field: 'p').isErr, isTrue);
    });

    test('asPercent mengonversi pecahan ke 0-100', () {
      final p =
          (Percentage.fractionValue(0.222, field: 'p') as Ok<Percentage>).value;
      expect(p.asPercent, closeTo(22.2, 1e-9));
    });
  });
}
