import 'package:intl/intl.dart';
import 'package:mealora/core/clock/clock.dart';

/// Locale tampilan tunggal MVP 1.
const String kAppLocale = 'id_ID';

/// Format angka dan tanggal menurut konvensi Indonesia.
///
/// Titik sebagai pemisah ribuan, koma sebagai pemisah desimal. Satuan tidak
/// pernah ditempel manual di sini — lapisan tampilan merangkainya lewat string
/// lokalisasi `valueWithUnit` supaya kalimat tetap utuh dan satuan dapat
/// diganti belakangan.
abstract final class IdFormat {
  /// Bilangan bulat, mis. `2100` menjadi `2.100`.
  static String integer(num value) =>
      NumberFormat.decimalPattern(kAppLocale).format(value.round());

  /// Bilangan desimal dengan [decimals] angka di belakang koma,
  /// mis. `68.4` menjadi `68,4`.
  static String decimal(num value, {int decimals = 1}) {
    final pattern = NumberFormat.decimalPattern(kAppLocale)
      ..minimumFractionDigits = decimals
      ..maximumFractionDigits = decimals;
    return pattern.format(value);
  }

  /// Tanggal panjang, mis. `Sabtu, 8 November 2026`.
  static String longDate(LocalDate date) => DateFormat(
    'EEEE, d MMMM y',
    kAppLocale,
  ).format(DateTime(date.year, date.month, date.day));

  /// Tanggal pendek, mis. `8 Nov 2026`.
  static String shortDate(LocalDate date) => DateFormat(
    'd MMM y',
    kAppLocale,
  ).format(DateTime(date.year, date.month, date.day));
}

/// Satuan metrik yang dipakai Mealora.
///
/// Nilai kanonis selalu disimpan metrik; konversi hanya terjadi di batas
/// tampilan bila kelak ada satuan lain.
enum MetricUnit { kilogram, centimeter, kilocalorie, gram }
