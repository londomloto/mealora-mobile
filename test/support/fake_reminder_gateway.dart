import 'dart:async';

import 'package:mealora/domain/reminders/reminder_scheduler.dart';
import 'package:mealora/domain/reminders/reminder_settings.dart';

/// Satu jadwal yang tercatat oleh [FakeReminderGateway].
final class ScheduledReminder {
  const ScheduledReminder({
    required this.id,
    required this.message,
    required this.time,
    required this.target,
    this.weekday,
  });

  final int id;
  final ReminderMessage message;
  final ClockTime time;
  final ReminderTapTarget target;

  /// `null` untuk jadwal harian.
  final int? weekday;
}

/// Tiruan penjadwal notifikasi: mencatat jadwal di memori dan mensimulasikan
/// izin notifikasi.
class FakeReminderGateway implements ReminderNotificationGateway {
  FakeReminderGateway({this.enabled = true, this.grantOnRequest = true});

  bool enabled;
  bool grantOnRequest;
  int permissionRequests = 0;
  int settingsOpened = 0;
  final List<int> cancelled = <int>[];
  final Map<int, ScheduledReminder> scheduled = <int, ScheduledReminder>{};
  String? timeZoneId;
  ReminderTapTarget? pendingLaunch;
  // ignore: close_sinks -- hidup sepanjang uji, sama seperti gateway asli.
  final StreamController<ReminderTapTarget> tapController =
      StreamController<ReminderTapTarget>.broadcast();

  @override
  Future<void> cancel(int id) async {
    cancelled.add(id);
    scheduled.remove(id);
  }

  @override
  Future<void> scheduleDaily({
    required int id,
    required ReminderMessage message,
    required ClockTime time,
    required ReminderTapTarget target,
  }) async {
    scheduled[id] = ScheduledReminder(
      id: id,
      message: message,
      time: time,
      target: target,
    );
  }

  @override
  Future<void> scheduleWeekly({
    required int id,
    required ReminderMessage message,
    required int weekday,
    required ClockTime time,
    required ReminderTapTarget target,
  }) async {
    scheduled[id] = ScheduledReminder(
      id: id,
      message: message,
      time: time,
      target: target,
      weekday: weekday,
    );
  }

  @override
  Future<bool> areNotificationsEnabled() async => enabled;

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    enabled = grantOnRequest;
    return enabled;
  }

  @override
  Future<void> openSystemSettings() async => settingsOpened++;

  @override
  Future<ReminderTapTarget?> launchTarget() async {
    final target = pendingLaunch;
    pendingLaunch = null;
    return target;
  }

  @override
  Stream<ReminderTapTarget> get taps => tapController.stream;

  @override
  void setLocalTimeZone(String timeZoneId) => this.timeZoneId = timeZoneId;
}
