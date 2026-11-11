import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/data/local/reminder_settings_repository.dart';
import 'package:mealora/data/local/ui_preference_dao.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/domain/reminders/reminder_settings.dart';

import 'test_database.dart';

/// `ReminderSettingsRepository` di atas `UiPreferences` (change 013, task
/// 2.1/2.4).
void main() {
  late AppDatabase db;
  late UiPreferenceDao dao;
  late ReminderSettingsRepository repository;

  setUp(() {
    db = createTestDatabase();
    dao = UiPreferenceDao(db, clock: createTestClock());
    repository = ReminderSettingsRepository(dao);
  });
  tearDown(() => db.close());

  test(
    'default sesuai spec: semua mati, jam bawaan, Senin, tidur 22:00',
    () async {
      final settings = await repository.load();

      expect(settings.anyEnabled, isFalse);
      expect(
        settings.meal(MealReminderSlot.breakfast).time,
        const ClockTime(7, 0),
      );
      expect(
        settings.meal(MealReminderSlot.lunch).time,
        const ClockTime(12, 0),
      );
      expect(
        settings.meal(MealReminderSlot.snack).time,
        const ClockTime(15, 30),
      );
      expect(
        settings.meal(MealReminderSlot.dinner).time,
        const ClockTime(19, 0),
      );
      expect(settings.weigh, ReminderSettings.defaultWeighToggle);
      expect(settings.weighWeekday, DateTime.monday);
      expect(settings.bedtime, const ClockTime(22, 0));
    },
  );

  test('menyimpan lalu membaca kembali nilai yang sama', () async {
    final saved = ReminderSettings.defaults()
        .withMeal(
          MealReminderSlot.dinner,
          const ReminderToggle(enabled: true, time: ClockTime(19, 45)),
        )
        .copyWith(
          weigh: const ReminderToggle(enabled: true, time: ClockTime(6, 30)),
          weighWeekday: DateTime.saturday,
          bedtime: const ClockTime(23, 30),
        );

    await repository.save(saved);
    final loaded = await repository.load();

    expect(
      loaded.meal(MealReminderSlot.dinner),
      const ReminderToggle(enabled: true, time: ClockTime(19, 45)),
    );
    expect(loaded.meal(MealReminderSlot.breakfast).enabled, isFalse);
    expect(loaded.weigh, saved.weigh);
    expect(loaded.weighWeekday, DateTime.saturday);
    expect(loaded.bedtime, const ClockTime(23, 30));
    expect(
      await dao.read('reminder.meal.dinner.time'),
      '19:45',
      reason: 'key berprefiks reminder.* dengan format HH:mm (Design D2)',
    );
  });

  test('nilai rusak jatuh ke default', () async {
    await dao.write('reminder.bedtime', '25:99');
    await dao.write('reminder.weigh.weekday', '9');

    final loaded = await repository.load();

    expect(loaded.bedtime, const ClockTime(22, 0));
    expect(loaded.weighWeekday, DateTime.monday);
  });

  test(
    'kunci malam peringatan jelang tidur dan zona waktu tersimpan',
    () async {
      expect(await repository.lastLateMealNoticeNight(), isNull);
      await repository.saveLateMealNoticeNight(const LocalDate(2026, 11, 9));
      expect(
        await repository.lastLateMealNoticeNight(),
        const LocalDate(2026, 11, 9),
      );
      expect(await dao.read('late_meal.last_notice_night'), '2026-11-09');

      await repository.saveScheduledTimeZone('Asia/Makassar');
      expect(await repository.scheduledTimeZone(), 'Asia/Makassar');
    },
  );
}
