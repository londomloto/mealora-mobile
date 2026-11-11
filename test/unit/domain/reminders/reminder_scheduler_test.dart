import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/domain/reminders/reminder_scheduler.dart';
import 'package:mealora/domain/reminders/reminder_settings.dart';

import '../../../support/fake_reminder_gateway.dart';

/// `ReminderScheduler.reconcile` (change 013, task 2.2/2.4).
void main() {
  final copy = ReminderCopy(
    meals: <MealReminderSlot, ReminderMessage>{
      for (final slot in MealReminderSlot.values)
        slot: ReminderMessage(title: 'Waktunya ${slot.name}', body: 'Catat'),
    },
    weigh: const ReminderMessage(title: 'Waktunya timbang', body: 'Catat'),
  );

  test(
    'default: membatalkan semua ID dan tidak menjadwalkan apa pun',
    () async {
      final gateway = FakeReminderGateway();
      await ReminderScheduler(
        gateway,
      ).reconcile(ReminderSettings.defaults(), copy);

      expect(
        gateway.cancelled,
        unorderedEquals(<int>[1001, 1002, 1003, 1004, 1010]),
      );
      expect(gateway.scheduled, isEmpty);
    },
  );

  test('hanya pengingat yang menyala dijadwalkan, harian/mingguan', () async {
    final gateway = FakeReminderGateway();
    final settings = ReminderSettings.defaults()
        .withMeal(
          MealReminderSlot.lunch,
          const ReminderToggle(enabled: true, time: ClockTime(12, 30)),
        )
        .copyWith(
          weigh: const ReminderToggle(enabled: true, time: ClockTime(6, 30)),
          weighWeekday: DateTime.saturday,
        );

    await ReminderScheduler(gateway).reconcile(settings, copy);

    expect(gateway.scheduled.keys, unorderedEquals(<int>[1002, 1010]));
    final lunch = gateway.scheduled[1002]!;
    expect(lunch.time, const ClockTime(12, 30));
    expect(lunch.weekday, isNull);
    expect(lunch.target, ReminderTapTarget.today);
    final weigh = gateway.scheduled[1010]!;
    expect(weigh.weekday, DateTime.saturday);
    expect(weigh.time, const ClockTime(6, 30));
    expect(weigh.target, ReminderTapTarget.addWeight);
  });

  test('mematikan satu pengingat tidak memengaruhi yang lain', () async {
    final gateway = FakeReminderGateway();
    final scheduler = ReminderScheduler(gateway);
    var settings = ReminderSettings.defaults();
    for (final slot in MealReminderSlot.values) {
      settings = settings.withMeal(
        slot,
        settings.meal(slot).copyWith(enabled: true),
      );
    }
    await scheduler.reconcile(settings, copy);
    expect(gateway.scheduled, hasLength(4));

    settings = settings.withMeal(
      MealReminderSlot.breakfast,
      settings.meal(MealReminderSlot.breakfast).copyWith(enabled: false),
    );
    await scheduler.reconcile(settings, copy);

    expect(gateway.scheduled.keys, unorderedEquals(<int>[1002, 1003, 1004]));
  });

  test('payload ketukan dipetakan balik ke tujuannya', () {
    for (final target in ReminderTapTarget.values) {
      expect(ReminderTapTarget.fromPayload(target.payload), target);
    }
    expect(ReminderTapTarget.fromPayload('lain'), isNull);
    expect(ReminderTapTarget.fromPayload(null), isNull);
  });
}
