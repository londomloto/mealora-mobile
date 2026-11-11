import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/data/local/reminder_settings_repository.dart';
import 'package:mealora/features/reminders/reminders_screen.dart';

import '../support/fake_reminder_gateway.dart';
import 'harness.dart';

/// `48–52 · Pengingat` (change 013, task 3.6).
void main() {
  Future<void> pumpScreen(
    WidgetTester tester,
    FakeReminderGateway gateway,
  ) async {
    await useDesignViewport(tester);
    final db = createWidgetTestDatabase();
    addTearDown(db.close);
    await tester.pumpWidget(
      wrapForTest(
        const RemindersScreen(),
        database: db,
        reminderGateway: gateway,
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder switchFor(String label) => find.bySemanticsLabel('Pengingat $label');

  Future<void> toggle(WidgetTester tester, String label) async {
    final target = find.descendant(
      of: switchFor(label),
      matching: find.byType(Switch),
    );
    await tester.ensureVisible(target);
    await tester.tap(target);
    await tester.pumpAndSettle();
  }

  bool isOn(WidgetTester tester, String label) => tester
      .widget<Switch>(
        find.descendant(of: switchFor(label), matching: find.byType(Switch)),
      )
      .value;

  testWidgets('semua pengingat mati secara default dengan jam bawaan', (
    tester,
  ) async {
    await pumpScreen(tester, FakeReminderGateway(enabled: false));

    for (final label in <String>[
      'Sarapan',
      'Makan siang',
      'Camilan',
      'Makan malam',
      'Timbang berat',
    ]) {
      expect(isOn(tester, label), isFalse, reason: label);
    }
    expect(find.text('07:00'), findsNWidgets(2));
    expect(find.text('15:30'), findsOneWidget);
    expect(find.text('22:00'), findsOneWidget);
    expect(find.textContaining('bisa bergeser beberapa menit'), findsOneWidget);
    expect(find.textContaining('Notifikasi diblokir'), findsNothing);
  });

  testWidgets(
    'sakelar pertama meminta izin lewat pra-izin, lalu menjadwalkan',
    (tester) async {
      final gateway = FakeReminderGateway(enabled: false);
      await pumpScreen(tester, gateway);

      await toggle(tester, 'Makan siang');
      expect(find.text('Izinkan notifikasi?'), findsOneWidget);
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();

      expect(gateway.permissionRequests, 1);
      expect(isOn(tester, 'Makan siang'), isTrue);
      expect(gateway.scheduled.keys, <int>[1002]);
      expect(find.textContaining('Notifikasi diblokir'), findsNothing);

      await toggle(tester, 'Camilan');
      expect(
        find.text('Izinkan notifikasi?'),
        findsNothing,
        reason: 'izin hanya diminta saat sakelar pertama dinyalakan',
      );
      expect(gateway.scheduled.keys, unorderedEquals(<int>[1002, 1003]));
    },
  );

  testWidgets(
    'izin ditolak: pengaturan tetap menyala dan keterangan diblokir muncul',
    (tester) async {
      final gateway = FakeReminderGateway(
        enabled: false,
        grantOnRequest: false,
      );
      await pumpScreen(tester, gateway);

      await toggle(tester, 'Makan malam');
      await tester.tap(find.text('Lanjut'));
      await tester.pumpAndSettle();

      expect(isOn(tester, 'Makan malam'), isTrue);
      expect(find.textContaining('Notifikasi diblokir'), findsOneWidget);

      await tester.tap(find.text('Buka pengaturan'));
      await tester.pumpAndSettle();
      expect(gateway.settingsOpened, 1);
    },
  );

  testWidgets('memilih "Nanti" tidak meminta izin sistem', (tester) async {
    final gateway = FakeReminderGateway(enabled: false);
    await pumpScreen(tester, gateway);

    await toggle(tester, 'Sarapan');
    await tester.tap(find.text('Nanti'));
    await tester.pumpAndSettle();

    expect(gateway.permissionRequests, 0);
    expect(isOn(tester, 'Sarapan'), isTrue);
    expect(find.textContaining('Notifikasi diblokir'), findsOneWidget);
  });

  testWidgets('memilih hari timbang tersimpan', (tester) async {
    final gateway = FakeReminderGateway();
    await pumpScreen(tester, gateway);

    final saturday = find.bySemanticsLabel('Sabtu');
    await tester.ensureVisible(saturday);
    await tester.tap(saturday);
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(
      tester.element(find.byType(RemindersScreen)),
    );
    final repository = ReminderSettingsRepository(
      container.read(uiPreferenceDaoProvider),
    );
    expect((await repository.load()).weighWeekday, DateTime.saturday);
  });
}
