import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/data/local/reminder_settings_repository.dart';
import 'package:mealora/data/local/ui_preference_dao.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/domain/reminders/reminder_scheduler.dart';
import 'package:mealora/domain/reminders/reminder_settings.dart';
import 'package:mealora/features/reminders/reminder_lifecycle.dart';
import 'package:mealora/features/shell/destinations.dart';
import 'package:mealora/features/weight/add_weight_screen.dart';

import '../support/fake_reminder_gateway.dart';
import 'harness.dart';

/// `ReminderLifecycle` (change 013, task 2.3/3.5).
void main() {
  late AppDatabase db;
  late ReminderSettingsRepository repository;

  setUp(() async {
    db = createWidgetTestDatabase();
    repository = ReminderSettingsRepository(
      UiPreferenceDao(db, clock: createWidgetTestClock()),
    );
    await repository.save(
      ReminderSettings.defaults().withMeal(
        MealReminderSlot.lunch,
        const ReminderToggle(enabled: true, time: ClockTime(12, 0)),
      ),
    );
  });
  tearDown(() => db.close());

  Future<void> pump(
    WidgetTester tester,
    FakeReminderGateway gateway, {
    required String Function() timeZone,
  }) async {
    await useDesignViewport(tester);
    await tester.pumpWidget(
      wrapForTest(
        const ReminderLifecycle(child: Scaffold(body: Text('ruang utama'))),
        database: db,
        reminderGateway: gateway,
        overrides: <Override>[
          deviceTimeZoneReaderProvider.overrideWithValue(
            () async => timeZone(),
          ),
          profileRepositoryAppOverride,
          programRepositoryAppOverride,
          weightRepositoryAppOverride,
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('saat aplikasi dimulai, jadwal direkonsiliasi', (tester) async {
    final gateway = FakeReminderGateway();
    await pump(tester, gateway, timeZone: () => 'Asia/Jakarta');

    expect(gateway.scheduled.keys, <int>[1002]);
    expect(gateway.timeZoneId, 'Asia/Jakarta');
    expect(await repository.scheduledTimeZone(), 'Asia/Jakarta');
  });

  testWidgets(
    'kembali ke foreground dengan zona waktu berbeda menjadwalkan ulang',
    (tester) async {
      final gateway = FakeReminderGateway();
      var zone = 'Asia/Jakarta';
      await pump(tester, gateway, timeZone: () => zone);
      gateway.cancelled.clear();

      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();
      expect(gateway.cancelled, isEmpty, reason: 'zona sama → tidak ada ulang');

      zone = 'Asia/Makassar';
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pumpAndSettle();

      expect(gateway.cancelled, isNotEmpty);
      expect(gateway.timeZoneId, 'Asia/Makassar');
      expect(gateway.scheduled.keys, <int>[1002]);
      expect(await repository.scheduledTimeZone(), 'Asia/Makassar');
    },
  );

  testWidgets('dibuka dari notifikasi timbang → layar tambah berat', (
    tester,
  ) async {
    final gateway = FakeReminderGateway()
      ..pendingLaunch = ReminderTapTarget.addWeight;
    await pump(tester, gateway, timeZone: () => 'Asia/Jakarta');

    expect(find.byType(AddWeightScreen), findsOneWidget);
  });

  testWidgets('ketuk notifikasi makan → ruang Hari ini', (tester) async {
    final gateway = FakeReminderGateway();
    await pump(tester, gateway, timeZone: () => 'Asia/Jakarta');
    final container = ProviderScope.containerOf(
      tester.element(find.text('ruang utama')),
    );
    await container
        .read(selectedDestinationProvider.notifier)
        .select(MealoraDestination.program);

    gateway.tapController.add(ReminderTapTarget.today);
    await tester.pumpAndSettle();

    expect(
      container.read(selectedDestinationProvider).value,
      MealoraDestination.today,
    );
  });
}
