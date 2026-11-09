import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/errors/failure.dart';
import 'package:mealora/domain/profile/profile_validation.dart';

/// Validasi nilai profil (FRS 2.3.5, task 2.5): kesalahan bertipe yang
/// menyebut bidang mana yang bermasalah, bukan kalimat bebas.
void main() {
  group('height', () {
    test(
      'menolak tinggi badan 15 cm (scenario 6.3) dengan field yang jelas',
      () {
        final result = ProfileValueRules.height(15);
        expect(result.isErr, isTrue);
        expect(result.failureOrNull?.code, FailureCode.valueOutOfRange);
        expect(result.failureOrNull?.field, 'height');
      },
    );

    test('menerima tinggi badan yang masuk akal', () {
      final result = ProfileValueRules.height(165);
      expect(result.isOk, isTrue);
      expect(result.valueOrNull?.cm, 165);
    });

    test('menolak nilai bukan angka', () {
      final result = ProfileValueRules.height(double.nan);
      expect(result.failureOrNull?.code, FailureCode.invalidValue);
      expect(result.failureOrNull?.field, 'height');
    });
  });

  group('currentWeight', () {
    test('menolak berat badan di luar rentang masuk akal', () {
      final result = ProfileValueRules.currentWeight(5);
      expect(result.isErr, isTrue);
      expect(result.failureOrNull?.code, FailureCode.valueOutOfRange);
      expect(result.failureOrNull?.field, 'currentWeight');
    });

    test('menerima berat badan yang masuk akal', () {
      final result = ProfileValueRules.currentWeight(68.4);
      expect(result.isOk, isTrue);
    });
  });

  group('targetWeight', () {
    test(
      'menolak berat tujuan di luar rentang masuk akal dengan field sendiri',
      () {
        final result = ProfileValueRules.targetWeight(5);
        expect(result.isErr, isTrue);
        expect(result.failureOrNull?.code, FailureCode.valueOutOfRange);
        expect(result.failureOrNull?.field, 'targetWeight');
      },
    );

    test('menerima berat tujuan yang masuk akal', () {
      final result = ProfileValueRules.targetWeight(62);
      expect(result.isOk, isTrue);
    });
  });

  group('birthDate', () {
    const today = LocalDate(2026, 11, 9);

    test('menolak tanggal lahir di masa depan', () {
      final result = ProfileValueRules.birthDate(
        const LocalDate(2027, 1, 1),
        asOfToday: today,
      );
      expect(result.failureOrNull?.code, FailureCode.invalidValue);
      expect(result.failureOrNull?.field, 'birthDate');
    });

    test('menolak usia di bawah batas minimum', () {
      final result = ProfileValueRules.birthDate(
        const LocalDate(2020, 1, 1),
        asOfToday: today,
      );
      expect(result.failureOrNull?.code, FailureCode.valueOutOfRange);
      expect(result.failureOrNull?.field, 'birthDate');
    });

    test('menolak usia di atas batas maksimum', () {
      final result = ProfileValueRules.birthDate(
        const LocalDate(1890, 1, 1),
        asOfToday: today,
      );
      expect(result.failureOrNull?.code, FailureCode.valueOutOfRange);
    });

    test('menerima tanggal lahir yang masuk akal', () {
      final result = ProfileValueRules.birthDate(
        const LocalDate(1997, 5, 20),
        asOfToday: today,
      );
      expect(result.isOk, isTrue);
    });
  });

  group('ageInYears', () {
    test('belum ulang tahun tahun ini mengurangi satu tahun', () {
      final age = ProfileValueRules.ageInYears(
        const LocalDate(1997, 12, 1),
        const LocalDate(2026, 11, 9),
      );
      expect(age, 28);
    });

    test('sudah ulang tahun tahun ini', () {
      final age = ProfileValueRules.ageInYears(
        const LocalDate(1997, 1, 1),
        const LocalDate(2026, 11, 9),
      );
      expect(age, 29);
    });

    test('tepat hari ulang tahun dihitung sudah bertambah', () {
      final age = ProfileValueRules.ageInYears(
        const LocalDate(1997, 11, 9),
        const LocalDate(2026, 11, 9),
      );
      expect(age, 29);
    });
  });

  group('nickname', () {
    test('menerima dan memangkas spasi tepi', () {
      final result = ProfileValueRules.nickname('  Budi  ');
      expect(result.valueOrNull, 'Budi');
    });

    test('menolak nama panggilan yang terlalu panjang', () {
      final result = ProfileValueRules.nickname('a' * 61);
      expect(result.failureOrNull?.code, FailureCode.valueOutOfRange);
      expect(result.failureOrNull?.field, 'nickname');
    });
  });
}
