import 'dart:async';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/domain/reminders/reminder_scheduler.dart';
import 'package:mealora/domain/reminders/reminder_settings.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// [ReminderNotificationGateway] di atas `flutter_local_notifications`
/// (change 013, Design D1): jadwal berulang `inexactAllowWhileIdle`, tanpa
/// izin alarm tepat waktu. Pemulihan setelah boot/pembaruan ditangani
/// receiver plugin di `AndroidManifest.xml`.
class LocalNotificationsGateway implements ReminderNotificationGateway {
  LocalNotificationsGateway({
    required Clock clock,
    required String channelName,
    required String channelDescription,
    FlutterLocalNotificationsPlugin? plugin,
  }) : _clock = clock,
       _channelName = channelName,
       _channelDescription = channelDescription,
       _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  static const String _channelId = 'mealora_reminders';
  static const String _smallIcon = '@mipmap/ic_launcher';

  final Clock _clock;
  final String _channelName;
  final String _channelDescription;
  final FlutterLocalNotificationsPlugin _plugin;
  final StreamController<ReminderTapTarget> _taps =
      StreamController<ReminderTapTarget>.broadcast();

  /// Memuat basis data zona waktu, menyetel zona lokal, dan menginisialisasi
  /// plugin. Dipanggil sekali saat bootstrap (task 1.3). Tidak meminta izin.
  Future<void> initialize({required String timeZoneId}) async {
    tz_data.initializeTimeZones();
    setLocalTimeZone(timeZoneId);
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings(_smallIcon),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
      onDidReceiveNotificationResponse: (response) {
        final target = ReminderTapTarget.fromPayload(response.payload);
        if (target != null) _taps.add(target);
      },
    );
  }

  @override
  void setLocalTimeZone(String timeZoneId) {
    try {
      tz.setLocalLocation(tz.getLocation(timeZoneId));
    } on Object {
      // Pengenal tidak dikenal (mis. `unknown`): pertahankan zona yang
      // sudah ada daripada menggagalkan bootstrap.
    }
  }

  AndroidFlutterLocalNotificationsPlugin? get _android => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  NotificationDetails get _details => NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      // Isi notifikasi tidak memuat data kesehatan, tetapi tetap disamarkan
      // di layar kunci sesuai bawaan sistem.
      visibility: NotificationVisibility.private,
    ),
    iOS: const DarwinNotificationDetails(),
  );

  @override
  Future<void> cancel(int id) => _plugin.cancel(id: id);

  @override
  Future<void> scheduleDaily({
    required int id,
    required ReminderMessage message,
    required ClockTime time,
    required ReminderTapTarget target,
  }) => _plugin.zonedSchedule(
    id: id,
    title: message.title,
    body: message.body,
    scheduledDate: _nextInstance(time),
    notificationDetails: _details,
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    matchDateTimeComponents: DateTimeComponents.time,
    payload: target.payload,
  );

  @override
  Future<void> scheduleWeekly({
    required int id,
    required ReminderMessage message,
    required int weekday,
    required ClockTime time,
    required ReminderTapTarget target,
  }) => _plugin.zonedSchedule(
    id: id,
    title: message.title,
    body: message.body,
    scheduledDate: _nextInstance(time, weekday: weekday),
    notificationDetails: _details,
    androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    payload: target.payload,
  );

  tz.TZDateTime _nextInstance(ClockTime time, {int? weekday}) {
    final now = tz.TZDateTime.from(_clock.nowUtc(), tz.local);
    var next = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (!next.isAfter(now)) {
      next = next.add(const Duration(days: 1));
    }
    if (weekday != null) {
      while (next.weekday != weekday) {
        next = next.add(const Duration(days: 1));
      }
    }
    return next;
  }

  @override
  Future<bool> areNotificationsEnabled() async =>
      await _android?.areNotificationsEnabled() ?? true;

  @override
  Future<bool> requestPermission() async =>
      await _android?.requestNotificationsPermission() ?? true;

  @override
  Future<void> openSystemSettings() async {
    await _android?.openAppNotificationSettings();
  }

  @override
  Future<ReminderTapTarget?> launchTarget() async {
    final details = await _plugin.getNotificationAppLaunchDetails();
    if (details == null || !details.didNotificationLaunchApp) return null;
    return ReminderTapTarget.fromPayload(details.notificationResponse?.payload);
  }

  @override
  Stream<ReminderTapTarget> get taps => _taps.stream;
}
