import 'package:mealora/domain/reminders/reminder_settings.dart';

/// Tujuan saat notifikasi pengingat diketuk (payload notifikasi).
enum ReminderTapTarget {
  today('meal'),
  addWeight('weigh');

  const ReminderTapTarget(this.payload);

  final String payload;

  static ReminderTapTarget? fromPayload(String? payload) {
    for (final target in values) {
      if (target.payload == payload) return target;
    }
    return null;
  }
}

/// Isi satu notifikasi. Hanya ajakan mencatat — tanpa angka kalori atau
/// berat badan (spec "Data pengingat tetap lokal").
final class ReminderMessage {
  const ReminderMessage({required this.title, required this.body});

  final String title;
  final String body;
}

/// Copy notifikasi per pengingat, disuntikkan dari ARB l10n.
final class ReminderCopy {
  const ReminderCopy({required this.meals, required this.weigh});

  final Map<MealReminderSlot, ReminderMessage> meals;
  final ReminderMessage weigh;
}

/// Antarmuka ke penjadwal notifikasi perangkat. Implementasi Android:
/// `LocalNotificationsGateway` (mode inexact, Design D1); pengujian memakai
/// tiruan.
abstract interface class ReminderNotificationGateway {
  Future<void> cancel(int id);

  /// Notifikasi berulang setiap hari pada [time] lokal.
  Future<void> scheduleDaily({
    required int id,
    required ReminderMessage message,
    required ClockTime time,
    required ReminderTapTarget target,
  });

  /// Notifikasi berulang setiap minggu pada [weekday] (`DateTime.monday`
  /// … `DateTime.sunday`) dan [time] lokal.
  Future<void> scheduleWeekly({
    required int id,
    required ReminderMessage message,
    required int weekday,
    required ClockTime time,
    required ReminderTapTarget target,
  });

  /// Apakah notifikasi diizinkan tampil saat ini.
  Future<bool> areNotificationsEnabled();

  /// Meminta izin notifikasi ke sistem; `true` bila diberikan.
  Future<bool> requestPermission();

  /// Membuka pengaturan notifikasi aplikasi di sistem.
  Future<void> openSystemSettings();

  /// Tujuan notifikasi yang membuka aplikasi dari keadaan mati, bila ada.
  Future<ReminderTapTarget?> launchTarget();

  /// Ketukan notifikasi ketika aplikasi sedang berjalan.
  Stream<ReminderTapTarget> get taps;

  /// Menyelaraskan zona waktu penjadwal dengan [timeZoneId] (IANA).
  void setLocalTimeZone(String timeZoneId);
}

/// Rekonsiliasi idempoten (Design D3): batalkan semua ID pengingat yang
/// dikenal, lalu jadwalkan ulang yang menyala.
final class ReminderScheduler {
  const ReminderScheduler(this._gateway);

  final ReminderNotificationGateway _gateway;

  Future<void> reconcile(ReminderSettings settings, ReminderCopy copy) async {
    for (final id in kReminderNotificationIds) {
      await _gateway.cancel(id);
    }
    for (final slot in MealReminderSlot.values) {
      final toggle = settings.meal(slot);
      if (!toggle.enabled) continue;
      await _gateway.scheduleDaily(
        id: slot.notificationId,
        message: copy.meals[slot]!,
        time: toggle.time,
        target: ReminderTapTarget.today,
      );
    }
    if (settings.weigh.enabled) {
      await _gateway.scheduleWeekly(
        id: kWeighReminderNotificationId,
        message: copy.weigh,
        weekday: settings.weighWeekday,
        time: settings.weigh.time,
        target: ReminderTapTarget.addWeight,
      );
    }
  }
}
