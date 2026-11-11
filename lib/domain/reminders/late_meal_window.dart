import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/domain/reminders/reminder_settings.dart';

/// Rentang peringatan makan menjelang tidur (change 013, Design D4).
///
/// Rentang dimulai `bedtime − 2 jam` dan selalu berakhir pukul 04:00 waktu
/// lokal berikutnya. Satu "malam" dihitung dari 04:00 ke 04:00, sehingga
/// kunci malam = tanggal lokal dari `waktu − 4 jam`; pencatatan yang
/// melewati tengah malam tetap memakai kunci malam yang sama.
abstract final class LateMealWindow {
  static const int _nightBoundaryMinutes = 4 * 60;
  static const int _leadMinutes = 2 * 60;
  static const int _minutesPerDay = 24 * 60;

  /// Kunci malam bila [localNow] (waktu dinding lokal) berada di dalam
  /// rentang untuk [bedtime], atau `null` bila di luar rentang.
  static LocalDate? nightKey(DateTime localNow, ClockTime bedtime) {
    final nowMinutes = localNow.hour * 60 + localNow.minute;
    final startMinutes = bedtime.minutesOfDay - _leadMinutes;
    final sinceBoundary = _sinceBoundary(nowMinutes);
    if (sinceBoundary < _sinceBoundary(startMinutes)) {
      return null;
    }
    final shifted = DateTime(
      localNow.year,
      localNow.month,
      localNow.day,
      localNow.hour,
      localNow.minute,
    ).subtract(const Duration(minutes: _nightBoundaryMinutes));
    return LocalDate(shifted.year, shifted.month, shifted.day);
  }

  static int _sinceBoundary(int minutesOfDay) =>
      (minutesOfDay - _nightBoundaryMinutes) % _minutesPerDay;
}
