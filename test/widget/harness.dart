import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/app/theme/app_theme.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/clock/fixed_clock.dart';
import 'package:mealora/core/ids/sequential_id_generator.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/domain/reminders/reminder_scheduler.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

import '../support/fake_reminder_gateway.dart';

/// Ukuran layar acuan desain (`docs/mealora.pen`).
const Size kDesignViewport = Size(390, 844);

Clock createWidgetTestClock() => FixedClock(
  instantUtc: DateTime.utc(2026, 11, 8, 2, 30),
  timeZoneId: 'Asia/Jakarta',
  utcOffset: const Duration(hours: 7),
);

/// Basis data in-memory untuk uji widget.
AppDatabase createWidgetTestDatabase() => AppDatabase(NativeDatabase.memory());

/// Membungkus [child] dengan tema, lokalisasi, dan penyedia Mealora.
///
/// [overrides] menambah penyedia lain di atas yang baku (clock, id
/// generator, dan basis data bila [database] diberikan) — mis.
/// `profileRepositoryAppOverride`/`diaryRepositoryAppOverride` untuk uji
/// yang benar-benar membaca/menulis lewat repositori Drift (change 007).
Widget wrapForTest(
  Widget child, {
  AppDatabase? database,
  double textScale = 1,
  List<Override> overrides = const <Override>[],
  ReminderNotificationGateway? reminderGateway,
}) {
  return ProviderScope(
    overrides: <Override>[
      clockProvider.overrideWithValue(createWidgetTestClock()),
      idGeneratorProvider.overrideWithValue(SequentialIdGenerator()),
      if (database != null) appDatabaseProvider.overrideWithValue(database),
      reminderNotificationGatewayProvider.overrideWithValue(
        reminderGateway ?? FakeReminderGateway(),
      ),
      ...overrides,
    ],
    child: MaterialApp(
      theme: MealoraTheme.light(),
      localizationsDelegates: AppText.localizationsDelegates,
      supportedLocales: AppText.supportedLocales,
      locale: const Locale('id'),
      home: Builder(
        builder: (context) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child,
        ),
      ),
    ),
  );
}

/// Menyetel ukuran layar uji ke viewport desain.
Future<void> useDesignViewport(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(kDesignViewport);
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

/// Teks lokalisasi untuk dipakai di dalam uji.
AppText textOf(WidgetTester tester, Finder anchor) =>
    AppText.of(tester.element(anchor));
