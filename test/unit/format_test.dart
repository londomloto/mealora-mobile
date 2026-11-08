import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/format/id_formatters.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting(kAppLocale);
  });

  group('format angka Indonesia', () {
    test('titik sebagai pemisah ribuan', () {
      expect(IdFormat.integer(2100), '2.100');
      expect(IdFormat.integer(1420), '1.420');
      expect(IdFormat.integer(999), '999');
      expect(IdFormat.integer(1250000), '1.250.000');
    });

    test('koma sebagai pemisah desimal', () {
      expect(IdFormat.decimal(68.4), '68,4');
      expect(IdFormat.decimal(68), '68,0');
      expect(IdFormat.decimal(1234.56, decimals: 2), '1.234,56');
    });
  });

  group('format tanggal Indonesia', () {
    test('tanggal panjang memakai nama hari dan bulan Indonesia', () {
      expect(
        IdFormat.longDate(const LocalDate(2026, 11, 8)),
        'Minggu, 8 November 2026',
      );
    });

    test('tanggal pendek', () {
      expect(IdFormat.shortDate(const LocalDate(2026, 1, 9)), '9 Jan 2026');
    });
  });

  test('satuan metrik tersedia sebagai nilai bertipe', () {
    expect(MetricUnit.values, hasLength(4));
    expect(MetricUnit.values, contains(MetricUnit.kilocalorie));
  });
}
