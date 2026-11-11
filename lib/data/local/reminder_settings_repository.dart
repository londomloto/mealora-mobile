import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/data/local/ui_preference_dao.dart';
import 'package:mealora/domain/reminders/reminder_settings.dart';

/// Kunci `UiPreferences` untuk pengingat dan jam tidur (change 013, Design
/// D2). Preferensi perangkat — tidak disinkronkan, tanpa migrasi skema.
abstract final class ReminderPreferenceKeys {
  static String mealEnabled(MealReminderSlot slot) =>
      'reminder.meal.${slot.stableCode}.enabled';
  static String mealTime(MealReminderSlot slot) =>
      'reminder.meal.${slot.stableCode}.time';
  static const String weighEnabled = 'reminder.weigh.enabled';
  static const String weighTime = 'reminder.weigh.time';
  static const String weighWeekday = 'reminder.weigh.weekday';
  static const String bedtime = 'reminder.bedtime';

  /// Zona waktu (IANA) saat jadwal terakhir direkonsiliasi.
  static const String scheduledTimeZone = 'reminder.scheduled_time_zone';

  /// Kunci malam (`YYYY-MM-DD`) peringatan jelang tidur terakhir.
  static const String lateMealLastNoticeNight = 'late_meal.last_notice_night';
}

/// Baca/tulis [ReminderSettings] di atas [UiPreferenceDao]; nilai yang
/// hilang atau rusak jatuh ke default spec.
class ReminderSettingsRepository {
  const ReminderSettingsRepository(this._dao);

  final UiPreferenceDao _dao;

  Future<ReminderSettings> load() async {
    final defaults = ReminderSettings.defaults();
    final meals = <MealReminderSlot, ReminderToggle>{};
    for (final slot in MealReminderSlot.values) {
      meals[slot] = ReminderToggle(
        enabled:
            await _dao.read(ReminderPreferenceKeys.mealEnabled(slot)) == 'true',
        time:
            ClockTime.tryParse(
              await _dao.read(ReminderPreferenceKeys.mealTime(slot)),
            ) ??
            slot.defaultTime,
      );
    }
    final weekday = int.tryParse(
      await _dao.read(ReminderPreferenceKeys.weighWeekday) ?? '',
    );
    return ReminderSettings(
      meals: meals,
      weigh: ReminderToggle(
        enabled: await _dao.read(ReminderPreferenceKeys.weighEnabled) == 'true',
        time:
            ClockTime.tryParse(
              await _dao.read(ReminderPreferenceKeys.weighTime),
            ) ??
            defaults.weigh.time,
      ),
      weighWeekday:
          weekday != null &&
              weekday >= DateTime.monday &&
              weekday <= DateTime.sunday
          ? weekday
          : defaults.weighWeekday,
      bedtime:
          ClockTime.tryParse(await _dao.read(ReminderPreferenceKeys.bedtime)) ??
          defaults.bedtime,
    );
  }

  Future<void> save(ReminderSettings settings) async {
    for (final slot in MealReminderSlot.values) {
      final toggle = settings.meal(slot);
      await _dao.write(
        ReminderPreferenceKeys.mealEnabled(slot),
        '${toggle.enabled}',
      );
      await _dao.write(ReminderPreferenceKeys.mealTime(slot), toggle.time.hhmm);
    }
    await _dao.write(
      ReminderPreferenceKeys.weighEnabled,
      '${settings.weigh.enabled}',
    );
    await _dao.write(
      ReminderPreferenceKeys.weighTime,
      settings.weigh.time.hhmm,
    );
    await _dao.write(
      ReminderPreferenceKeys.weighWeekday,
      '${settings.weighWeekday}',
    );
    await _dao.write(ReminderPreferenceKeys.bedtime, settings.bedtime.hhmm);
  }

  Future<String?> scheduledTimeZone() =>
      _dao.read(ReminderPreferenceKeys.scheduledTimeZone);

  Future<void> saveScheduledTimeZone(String timeZoneId) =>
      _dao.write(ReminderPreferenceKeys.scheduledTimeZone, timeZoneId);

  Future<LocalDate?> lastLateMealNoticeNight() async {
    final stored = await _dao.read(
      ReminderPreferenceKeys.lateMealLastNoticeNight,
    );
    if (stored == null) return null;
    try {
      return LocalDate.parse(stored);
    } on FormatException {
      return null;
    }
  }

  Future<void> saveLateMealNoticeNight(LocalDate night) =>
      _dao.write(ReminderPreferenceKeys.lateMealLastNoticeNight, night.iso);
}
