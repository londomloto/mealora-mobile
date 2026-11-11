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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeDateFormatting(kAppLocale);
  final timeZoneId = await _resolveTimeZoneId();

  runApp(
    ProviderScope(
      overrides: <Override>[
        clockProvider.overrideWithValue(SystemClock(timeZoneId: timeZoneId)),
        idGeneratorProvider.overrideWithValue(const UuidIdGenerator()),
        profileRepositoryAppOverride,
        programRepositoryAppOverride,
        foodRepositoryAppOverride,
        diaryRepositoryAppOverride,
        weightRepositoryAppOverride,
        packagedFoodRepositoryAppOverride,
        nutritionLabelProviderAppOverride,
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
