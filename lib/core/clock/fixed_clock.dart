import 'package:mealora/core/clock/clock.dart';

/// [Clock] berwaktu tetap untuk pengujian dan pratinjau.
///
/// Waktu hanya berubah bila dimajukan secara eksplisit lewat [advance].
final class FixedClock implements Clock {
  FixedClock({
    required DateTime instantUtc,
    required String timeZoneId,
    required Duration utcOffset,
  }) : assert(instantUtc.isUtc, 'instantUtc harus UTC'),
       _instantUtc = instantUtc,
       _timeZoneId = timeZoneId,
       _utcOffset = utcOffset;

  DateTime _instantUtc;
  final String _timeZoneId;
  final Duration _utcOffset;

  void advance(Duration duration) => _instantUtc = _instantUtc.add(duration);

  @override
  DateTime nowUtc() => _instantUtc;

  @override
  String timeZoneId() => _timeZoneId;

  @override
  LocalDate today() => localDateOf(_instantUtc);

  @override
  LocalDate localDateOf(DateTime instantUtc) {
    final shifted = instantUtc.toUtc().add(_utcOffset);
    return LocalDate(shifted.year, shifted.month, shifted.day);
  }
}
