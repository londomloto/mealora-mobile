import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/domain/reminders/late_meal_window.dart';
import 'package:mealora/domain/reminders/reminder_settings.dart';

/// Rentang peringatan makan menjelang tidur (change 013, task 4.1).
void main() {
  const bedtime22 = ClockTime(22, 0);
  DateTime at(int day, int hour, int minute) =>
      DateTime(2026, 11, day, hour, minute);

  test('jam tidur 22:00, mencatat 20:30 → di dalam rentang', () {
    expect(
      LateMealWindow.nightKey(at(9, 20, 30), bedtime22),
      const LocalDate(2026, 11, 9),
    );
  });

  test('jam tidur 22:00, mencatat 19:45 → di luar rentang', () {
    expect(LateMealWindow.nightKey(at(9, 19, 45), bedtime22), isNull);
  });

  test('batas awal tepat 20:00 termasuk, batas akhir 04:00 tidak', () {
    expect(LateMealWindow.nightKey(at(9, 20, 0), bedtime22), isNotNull);
    expect(LateMealWindow.nightKey(at(10, 3, 59), bedtime22), isNotNull);
    expect(LateMealWindow.nightKey(at(10, 4, 0), bedtime22), isNull);
  });

  test('lewat tengah malam memakai kunci malam sebelumnya', () {
    expect(
      LateMealWindow.nightKey(at(10, 0, 30), bedtime22),
      const LocalDate(2026, 11, 9),
    );
  });

  test('jam tidur 01:00, mencatat 23:30 → di dalam rentang', () {
    const bedtime01 = ClockTime(1, 0);
    expect(
      LateMealWindow.nightKey(at(9, 23, 30), bedtime01),
      const LocalDate(2026, 11, 9),
    );
    expect(LateMealWindow.nightKey(at(9, 22, 30), bedtime01), isNull);
    expect(
      LateMealWindow.nightKey(at(10, 2, 0), bedtime01),
      const LocalDate(2026, 11, 9),
    );
  });

  test('jam tidur 23:30 menggeser awal rentang ke 21:30', () {
    const bedtime = ClockTime(23, 30);
    expect(LateMealWindow.nightKey(at(9, 21, 15), bedtime), isNull);
    expect(LateMealWindow.nightKey(at(9, 21, 30), bedtime), isNotNull);
  });

  test('melewati batas bulan', () {
    expect(
      LateMealWindow.nightKey(DateTime(2026, 12, 1, 1), bedtime22),
      const LocalDate(2026, 11, 30),
    );
  });
}
