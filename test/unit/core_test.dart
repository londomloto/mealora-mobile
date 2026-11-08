import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/clock/fixed_clock.dart';
import 'package:mealora/core/errors/failure.dart';
import 'package:mealora/core/errors/result.dart';
import 'package:mealora/core/ids/sequential_id_generator.dart';
import 'package:mealora/core/ids/uuid_id_generator.dart';
import 'package:mealora/core/validation/value_rules.dart';

void main() {
  group('Clock', () {
    test('waktu deterministik ketika sumbernya ditimpa', () {
      final clock = FixedClock(
        instantUtc: DateTime.utc(2026, 11, 8, 2, 30),
        timeZoneId: 'Asia/Jakarta',
        utcOffset: const Duration(hours: 7),
      );

      expect(clock.nowUtc(), DateTime.utc(2026, 11, 8, 2, 30));
      expect(clock.nowUtc(), DateTime.utc(2026, 11, 8, 2, 30));
      expect(clock.timeZoneId(), 'Asia/Jakarta');
    });

    test('tanggal lokal dihitung pada zona waktu pencatatan', () {
      final jakarta = FixedClock(
        instantUtc: DateTime.utc(2026, 11, 7, 20),
        timeZoneId: 'Asia/Jakarta',
        utcOffset: const Duration(hours: 7),
      );

      // 7 November 20:00 UTC adalah 8 November 03:00 di Jakarta.
      expect(jakarta.today().iso, '2026-11-08');
    });

    test('tanggal lokal yang sudah tercatat tidak berubah '
        'ketika perangkat berpindah zona waktu', () {
      final recordedAt = DateTime.utc(2026, 11, 7, 20);

      final atRecordingTime = FixedClock(
        instantUtc: recordedAt,
        timeZoneId: 'Asia/Jakarta',
        utcOffset: const Duration(hours: 7),
      );
      final storedLocalDate = atRecordingTime.localDateOf(recordedAt).iso;

      final afterTravel = FixedClock(
        instantUtc: recordedAt,
        timeZoneId: 'America/Los_Angeles',
        utcOffset: const Duration(hours: -8),
      );

      // Jam yang baru menghitung tanggal berbeda untuk instan yang sama...
      expect(afterTravel.localDateOf(recordedAt).iso, '2026-11-07');
      // ...tetapi nilai yang sudah tersimpan tidak ikut berubah.
      expect(storedLocalDate, '2026-11-08');
    });

    test('LocalDate dapat dibaca dan ditulis kembali', () {
      expect(LocalDate.parse('2026-01-09').iso, '2026-01-09');
      expect(
        () => LocalDate.parse('9 Januari 2026'),
        throwsA(isA<FormatException>()),
      );
    });
  });

  group('IdGenerator', () {
    test('pengenal uji berurutan dan deterministik', () {
      final ids = SequentialIdGenerator();

      expect(ids.next(), 'test-0001');
      expect(ids.next(), 'test-0002');
      expect(SequentialIdGenerator().next(), 'test-0001');
    });

    test('pengenal UUID unik dan tidak berupa nomor urut', () {
      const generator = UuidIdGenerator();
      final first = generator.next();
      final second = generator.next();

      expect(first, isNot(second));
      expect(int.tryParse(first), isNull);
      expect(first.length, 36);
    });

    test('pengenal UUID v7 terurut menurut waktu', () async {
      const generator = UuidIdGenerator();
      final first = generator.next();
      await Future<void>.delayed(const Duration(milliseconds: 5));
      final second = generator.next();

      expect(first.compareTo(second), lessThan(0));
    });
  });

  group('Result', () {
    test('hasil berhasil membawa nilai', () {
      const result = Ok<int>(7);

      expect(result.isOk, isTrue);
      expect(result.valueOrNull, 7);
      expect(result.failureOrNull, isNull);
      expect(result.map((value) => value * 2).valueOrNull, 14);
    });

    test('kegagalan membawa kode alasan yang dapat dipetakan', () {
      const result = Err<int>(
        Failure(FailureCode.valueOutOfRange, field: 'amount'),
      );

      expect(result.isErr, isTrue);
      expect(result.valueOrNull, isNull);
      expect(result.failureOrNull?.code, FailureCode.valueOutOfRange);
      expect(result.map((value) => value * 2).failureOrNull?.field, 'amount');
    });
  });

  group('ValueRules', () {
    test('jumlah harus lebih besar dari nol', () {
      expect(ValueRules.positiveAmount(0.1, field: 'a').isOk, isTrue);
      expect(
        ValueRules.positiveAmount(0, field: 'a').failureOrNull?.code,
        FailureCode.valueOutOfRange,
      );
      expect(
        ValueRules.positiveAmount(-1, field: 'a').failureOrNull?.code,
        FailureCode.valueOutOfRange,
      );
      expect(
        ValueRules.positiveAmount(double.nan, field: 'a').failureOrNull?.code,
        FailureCode.invalidValue,
      );
      expect(
        ValueRules.positiveAmount(
          double.infinity,
          field: 'a',
        ).failureOrNull?.code,
        FailureCode.invalidValue,
      );
    });

    test('nilai gizi: null berarti belum diketahui, nol tetap nol', () {
      final unknown = ValueRules.nutrientValue(null, field: 'n');
      final measuredZero = ValueRules.nutrientValue(0, field: 'n');

      expect(unknown.isOk, isTrue);
      expect(unknown.valueOrNull, isNull);
      expect(measuredZero.isOk, isTrue);
      expect(measuredZero.valueOrNull, 0);
      expect(
        ValueRules.nutrientValue(-0.1, field: 'n').failureOrNull?.code,
        FailureCode.valueOutOfRange,
      );
    });

    test('teks wajib menolak isian kosong', () {
      expect(
        ValueRules.requiredText('  Nasi  ', field: 't').valueOrNull,
        'Nasi',
      );
      expect(
        ValueRules.requiredText('   ', field: 't').failureOrNull?.code,
        FailureCode.invalidValue,
      );
    });
  });
}
