/// Pengaturan pengingat lokal dan jam tidur (change 013).
///
/// Murni Dart: tidak tahu cara menyimpan atau menjadwalkan — lihat
/// `ReminderSettingsRepository` dan `ReminderScheduler`.
library;

/// Jam lokal tanpa tanggal (`HH:mm`).
final class ClockTime implements Comparable<ClockTime> {
  const ClockTime(this.hour, this.minute)
    : assert(hour >= 0 && hour < 24, 'hour 0–23'),
      assert(minute >= 0 && minute < 60, 'minute 0–59');

  /// Membaca `HH:mm`; `null` bila bentuk atau rentangnya salah.
  static ClockTime? tryParse(String? value) {
    if (value == null) return null;
    final match = RegExp(r'^(\d{2}):(\d{2})$').firstMatch(value);
    if (match == null) return null;
    final hour = int.parse(match.group(1)!);
    final minute = int.parse(match.group(2)!);
    if (hour > 23 || minute > 59) return null;
    return ClockTime(hour, minute);
  }

  final int hour;
  final int minute;

  /// Menit sejak 00:00.
  int get minutesOfDay => hour * 60 + minute;

  String get hhmm =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  @override
  int compareTo(ClockTime other) => minutesOfDay.compareTo(other.minutesOfDay);

  @override
  bool operator ==(Object other) =>
      other is ClockTime && other.hour == hour && other.minute == minute;

  @override
  int get hashCode => Object.hash(hour, minute);

  @override
  String toString() => hhmm;
}

/// Empat pengingat jam makan beserta ID notifikasi tetapnya (Design D3).
enum MealReminderSlot {
  breakfast('breakfast', 1001, ClockTime(7, 0)),
  lunch('lunch', 1002, ClockTime(12, 0)),
  snack('snack', 1003, ClockTime(15, 30)),
  dinner('dinner', 1004, ClockTime(19, 0));

  const MealReminderSlot(
    this.stableCode,
    this.notificationId,
    this.defaultTime,
  );

  final String stableCode;
  final int notificationId;
  final ClockTime defaultTime;
}

/// ID notifikasi tetap pengingat timbang (Design D3).
const int kWeighReminderNotificationId = 1010;

/// Semua ID notifikasi yang dimiliki fitur pengingat.
final List<int> kReminderNotificationIds = <int>[
  for (final slot in MealReminderSlot.values) slot.notificationId,
  kWeighReminderNotificationId,
];

/// Satu pengingat: menyala atau tidak, dan jamnya.
final class ReminderToggle {
  const ReminderToggle({required this.enabled, required this.time});

  final bool enabled;
  final ClockTime time;

  ReminderToggle copyWith({bool? enabled, ClockTime? time}) =>
      ReminderToggle(enabled: enabled ?? this.enabled, time: time ?? this.time);

  @override
  bool operator ==(Object other) =>
      other is ReminderToggle && other.enabled == enabled && other.time == time;

  @override
  int get hashCode => Object.hash(enabled, time);
}

/// Seluruh pengaturan layar Pengingat.
final class ReminderSettings {
  const ReminderSettings({
    required this.meals,
    required this.weigh,
    required this.weighWeekday,
    required this.bedtime,
  });

  /// Default spec: semua mati; 07:00/12:00/15:30/19:00; timbang Senin
  /// 07:00; jam tidur 22:00.
  factory ReminderSettings.defaults() => ReminderSettings(
    meals: <MealReminderSlot, ReminderToggle>{
      for (final slot in MealReminderSlot.values)
        slot: ReminderToggle(enabled: false, time: slot.defaultTime),
    },
    weigh: defaultWeighToggle,
    weighWeekday: DateTime.monday,
    bedtime: defaultBedtime,
  );

  static const ReminderToggle defaultWeighToggle = ReminderToggle(
    enabled: false,
    time: ClockTime(7, 0),
  );
  static const ClockTime defaultBedtime = ClockTime(22, 0);

  final Map<MealReminderSlot, ReminderToggle> meals;
  final ReminderToggle weigh;

  /// `DateTime.monday` (1) … `DateTime.sunday` (7).
  final int weighWeekday;
  final ClockTime bedtime;

  ReminderToggle meal(MealReminderSlot slot) => meals[slot]!;

  bool get anyEnabled =>
      weigh.enabled || meals.values.any((toggle) => toggle.enabled);

  int get enabledCount =>
      meals.values.where((toggle) => toggle.enabled).length +
      (weigh.enabled ? 1 : 0);

  ReminderSettings withMeal(MealReminderSlot slot, ReminderToggle toggle) =>
      ReminderSettings(
        meals: <MealReminderSlot, ReminderToggle>{...meals, slot: toggle},
        weigh: weigh,
        weighWeekday: weighWeekday,
        bedtime: bedtime,
      );

  ReminderSettings copyWith({
    ReminderToggle? weigh,
    int? weighWeekday,
    ClockTime? bedtime,
  }) => ReminderSettings(
    meals: meals,
    weigh: weigh ?? this.weigh,
    weighWeekday: weighWeekday ?? this.weighWeekday,
    bedtime: bedtime ?? this.bedtime,
  );
}
