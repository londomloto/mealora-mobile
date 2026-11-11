import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mealora/app/app.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/core/clock/system_clock.dart';
import 'package:mealora/core/format/id_formatters.dart';
import 'package:mealora/core/ids/uuid_id_generator.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/data/notifications/local_notifications_gateway.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting(kAppLocale);
  final timeZoneId = await _resolveTimeZoneId();
  final clock = SystemClock(timeZoneId: timeZoneId);

  // Pengingat lokal (change 013, task 1.3): basis data zona waktu dan
  // plugin disiapkan sebelum UI; izin TIDAK diminta di sini.
  final text = lookupAppText(const Locale('id'));
  final reminders = LocalNotificationsGateway(
    clock: clock,
    channelName: text.reminderChannelName,
    channelDescription: text.reminderChannelDescription,
  );
  await reminders.initialize(timeZoneId: timeZoneId);

  runApp(
    ProviderScope(
      overrides: <Override>[
        clockProvider.overrideWithValue(clock),
        reminderNotificationGatewayProvider.overrideWithValue(reminders),
        idGeneratorProvider.overrideWithValue(const UuidIdGenerator()),
        profileRepositoryAppOverride,
        programRepositoryAppOverride,
        foodRepositoryAppOverride,
        diaryRepositoryAppOverride,
        weightRepositoryAppOverride,
        packagedFoodRepositoryAppOverride,
        nutritionLabelProviderAppOverride,
        foodComponentRecognitionProviderAppOverride,
        speechRecognizerAppOverride,
        foodSentenceParserAppOverride,
        photoDraftRepositoryAppOverride,
      ],
      child: const MealoraApp(),
    ),
  );
}

/// Pengenal zona waktu IANA perangkat.
///
/// Bila platform tidak dapat memberikannya, aplikasi tetap berjalan dengan
/// penanda `unknown`: nilai ini hanya disimpan bersama record, tidak dipakai
/// untuk menghitung ulang tanggal lokal.
Future<String> _resolveTimeZoneId() async {
  try {
    final info = await FlutterTimezone.getLocalTimezone();
    return info.identifier;
  } on Object {
    return 'unknown';
  }
}
