import 'package:mealora/core/clock/clock.dart';

/// Implementasi [Clock] yang membaca jam dan zona waktu perangkat.
///
/// Pengenal zona waktu IANA dibaca sekali saat aplikasi dimulai dan
/// disuntikkan lewat [timeZoneId] agar kelas ini tetap sinkron dan bebas
/// dari kanal platform.
final class SystemClock implements Clock {
  const SystemClock({required String timeZoneId}) : _timeZoneId = timeZoneId;

  final String _timeZoneId;

  @override
  DateTime nowUtc() => DateTime.now().toUtc();

  @override
  String timeZoneId() => _timeZoneId;

  @override
  LocalDate today() => LocalDate.fromLocalInstant(DateTime.now());

  @override
  DateTime localNow() => DateTime.now();

  @override
  LocalDate localDateOf(DateTime instantUtc) =>
      LocalDate.fromLocalInstant(instantUtc.toLocal());
}
