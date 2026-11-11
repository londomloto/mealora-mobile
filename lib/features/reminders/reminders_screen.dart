import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/domain/reminders/reminder_settings.dart';
import 'package:mealora/features/reminders/reminder_providers.dart';
import 'package:mealora/features/reminders/reminder_sheets.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// `48–50 · Pengingat`: pengingat jam makan, timbang mingguan, dan jam
/// tidur (change 013).
class RemindersScreen extends ConsumerWidget {
  const RemindersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = AppText.of(context);
    final settings = ref.watch(reminderSettingsProvider).valueOrNull;
    final permitted = ref.watch(notificationsEnabledProvider).valueOrNull;
    final blocked =
        settings != null && settings.anyEnabled && permitted == false;

    return Scaffold(
      backgroundColor: MealoraColors.background,
      body: MealoraBlobBackdrop(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              MealoraSpacing.programHeroGutter,
              MealoraSpacing.lg,
              MealoraSpacing.programHeroGutter,
              MealoraSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                MealoraBackEyebrow(label: text.remindersContextLabel),
                const SizedBox(height: MealoraSpacing.xs),
                Text(text.remindersTitle, style: MealoraTypography.title),
                const SizedBox(height: MealoraSpacing.xxs),
                Text(text.remindersSubtitle, style: MealoraTypography.subtitle),
                if (blocked) ...<Widget>[
                  const SizedBox(height: MealoraSpacing.md),
                  _BlockedNote(
                    text: text,
                    onOpenSettings: () => unawaited(
                      ref
                          .read(reminderNotificationGatewayProvider)
                          .openSystemSettings(),
                    ),
                  ),
                ],
                if (settings != null)
                  ..._sections(context, ref, text, settings),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _sections(
    BuildContext context,
    WidgetRef ref,
    AppText text,
    ReminderSettings settings,
  ) {
    Future<void> save(ReminderSettings next, {bool turningOn = false}) async {
      final controller = ref.read(reminderSettingsProvider.notifier);
      await controller.save(next);
      if (turningOn && !settings.anyEnabled && context.mounted) {
        await _ensurePermission(context, ref);
      }
    }

    Future<ClockTime?> pick(ClockTime initial, String subtitle) =>
        showReminderTimePicker(context, initial: initial, subtitle: subtitle);

    return <Widget>[
      const SizedBox(height: MealoraSpacing.lg),
      Text(text.remindersMealsHeading, style: MealoraTypography.sectionTitle),
      const SizedBox(height: MealoraSpacing.sm),
      MealoraCard(
        padding: const EdgeInsets.symmetric(
          horizontal: MealoraSpacing.md,
          vertical: MealoraSpacing.xxs,
        ),
        child: Column(
          children: <Widget>[
            for (final slot in MealReminderSlot.values) ...<Widget>[
              _ReminderRow(
                style: _SlotStyle.of(slot),
                label: _slotLabel(slot, text),
                time: settings.meal(slot).time,
                enabled: settings.meal(slot).enabled,
                onTimeTap: () async {
                  final picked = await pick(
                    settings.meal(slot).time,
                    text.remindersTimePickerDaily(_slotLabel(slot, text)),
                  );
                  if (picked == null) return;
                  final latest = ref.read(reminderSettingsProvider).value!;
                  await save(
                    latest.withMeal(
                      slot,
                      latest.meal(slot).copyWith(time: picked),
                    ),
                  );
                },
                onChanged: (on) => unawaited(
                  save(
                    settings.withMeal(
                      slot,
                      settings.meal(slot).copyWith(enabled: on),
                    ),
                    turningOn: on,
                  ),
                ),
              ),
              if (slot != MealReminderSlot.values.last)
                const Divider(height: 1, color: MealoraColors.line),
            ],
          ],
        ),
      ),
      const SizedBox(height: MealoraSpacing.lg),
      Text(text.remindersWeighHeading, style: MealoraTypography.sectionTitle),
      const SizedBox(height: MealoraSpacing.sm),
      MealoraCard(
        padding: const EdgeInsets.all(MealoraSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _ReminderRow(
              style: const _SlotStyle(
                Icons.monitor_weight_outlined,
                MealoraColors.primaryDeep,
                MealoraColors.iconField,
              ),
              label: text.remindersWeighLabel,
              detail: text.remindersWeighDetail,
              enabled: settings.weigh.enabled,
              onChanged: (on) => unawaited(
                save(
                  settings.copyWith(
                    weigh: settings.weigh.copyWith(enabled: on),
                  ),
                  turningOn: on,
                ),
              ),
            ),
            const SizedBox(height: MealoraSpacing.sm),
            _WeekdayPicker(
              text: text,
              selected: settings.weighWeekday,
              onSelected: (weekday) =>
                  unawaited(save(settings.copyWith(weighWeekday: weekday))),
            ),
            const SizedBox(height: MealoraSpacing.sm),
            Row(
              children: <Widget>[
                Text(
                  text.remindersWeighTimeLabel,
                  style: MealoraTypography.caption,
                ),
                const SizedBox(width: MealoraSpacing.xs),
                _TimePill(
                  time: settings.weigh.time,
                  semanticsLabel: text.remindersTimeSemantics(
                    text.remindersWeighLabel,
                    settings.weigh.time.hhmm,
                  ),
                  onTap: () async {
                    final picked = await pick(
                      settings.weigh.time,
                      text.remindersTimePickerWeekly,
                    );
                    if (picked == null) return;
                    final latest = ref.read(reminderSettingsProvider).value!;
                    await save(
                      latest.copyWith(
                        weigh: latest.weigh.copyWith(time: picked),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
      const SizedBox(height: MealoraSpacing.lg),
      Text(text.remindersBedtimeHeading, style: MealoraTypography.sectionTitle),
      const SizedBox(height: MealoraSpacing.sm),
      MealoraCard(
        padding: const EdgeInsets.all(MealoraSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _ReminderRow(
              style: const _SlotStyle(
                Icons.bed_outlined,
                MealoraColors.info,
                MealoraColors.noteInfo,
              ),
              label: text.remindersBedtimeLabel,
              time: settings.bedtime,
              onTimeTap: () async {
                final picked = await pick(
                  settings.bedtime,
                  text.remindersTimePickerBedtime,
                );
                if (picked == null) return;
                final latest = ref.read(reminderSettingsProvider).value!;
                await save(latest.copyWith(bedtime: picked));
              },
            ),
            const SizedBox(height: MealoraSpacing.xs),
            Text(text.remindersBedtimeNote, style: MealoraTypography.caption),
          ],
        ),
      ),
    ];
  }

  /// Pra-izin (`52`) lalu permintaan sistem, hanya saat sakelar pertama
  /// dinyalakan dan izin belum ada (task 3.2). Ditolak → pengaturan tetap
  /// tersimpan; keterangan "diblokir" muncul lewat
  /// [notificationsEnabledProvider].
  Future<void> _ensurePermission(BuildContext context, WidgetRef ref) async {
    final gateway = ref.read(reminderNotificationGatewayProvider);
    if (await gateway.areNotificationsEnabled()) return;
    if (!context.mounted) return;
    final proceed = await showNotificationPermissionSheet(context);
    if (proceed) {
      await gateway.requestPermission();
    }
    ref.invalidate(notificationsEnabledProvider);
  }

  static String _slotLabel(MealReminderSlot slot, AppText text) =>
      switch (slot) {
        MealReminderSlot.breakfast => text.remindersBreakfast,
        MealReminderSlot.lunch => text.remindersLunch,
        MealReminderSlot.snack => text.remindersSnack,
        MealReminderSlot.dinner => text.remindersDinner,
      };
}

class _SlotStyle {
  const _SlotStyle(this.icon, this.color, this.background);

  factory _SlotStyle.of(MealReminderSlot slot) => switch (slot) {
    MealReminderSlot.breakfast => const _SlotStyle(
      Icons.wb_twilight_rounded,
      MealoraColors.amberText,
      MealoraColors.iconFieldAmber,
    ),
    MealReminderSlot.lunch => const _SlotStyle(
      Icons.wb_sunny_outlined,
      MealoraColors.primaryDeep,
      MealoraColors.iconFieldGreen,
    ),
    MealReminderSlot.snack => const _SlotStyle(
      Icons.cookie_outlined,
      MealoraColors.coralText,
      MealoraColors.iconFieldCoral,
    ),
    MealReminderSlot.dinner => const _SlotStyle(
      Icons.nightlight_outlined,
      MealoraColors.info,
      MealoraColors.iconFieldBlue,
    ),
  };

  final IconData icon;
  final Color color;
  final Color background;
}

class _ReminderRow extends StatelessWidget {
  const _ReminderRow({
    required this.style,
    required this.label,
    this.detail,
    this.time,
    this.onTimeTap,
    this.enabled,
    this.onChanged,
  });

  final _SlotStyle style;
  final String label;
  final String? detail;
  final ClockTime? time;
  final VoidCallback? onTimeTap;
  final bool? enabled;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 58),
      child: Row(
        children: <Widget>[
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: style.background,
              borderRadius: BorderRadius.circular(
                MealoraRadius.compactIconField,
              ),
            ),
            child: Icon(style.icon, color: style.color, size: 18),
          ),
          const SizedBox(width: MealoraSpacing.sm),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(label, style: MealoraTypography.bodyEmphasis),
                if (detail != null)
                  Text(detail!, style: MealoraTypography.caption),
              ],
            ),
          ),
          if (time != null) ...<Widget>[
            const SizedBox(width: MealoraSpacing.xs),
            _TimePill(
              time: time!,
              dimmed: enabled == false,
              semanticsLabel: text.remindersTimeSemantics(label, time!.hhmm),
              onTap: onTimeTap,
            ),
          ],
          if (enabled != null) ...<Widget>[
            const SizedBox(width: MealoraSpacing.xs),
            Semantics(
              label: text.remindersToggleSemantics(label),
              child: Switch(
                value: enabled!,
                onChanged: onChanged,
                activeTrackColor: MealoraColors.primary,
                activeThumbColor: MealoraColors.onPrimary,
                inactiveTrackColor: MealoraColors.line,
                inactiveThumbColor: MealoraColors.surface,
                trackOutlineColor: const WidgetStatePropertyAll<Color>(
                  MealoraColors.transparent,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _TimePill extends StatelessWidget {
  const _TimePill({
    required this.time,
    required this.semanticsLabel,
    this.onTap,
    this.dimmed = false,
  });

  final ClockTime time;
  final String semanticsLabel;
  final VoidCallback? onTap;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final color = dimmed ? MealoraColors.muted : MealoraColors.ink;
    return Semantics(
      button: true,
      label: semanticsLabel,
      excludeSemantics: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(MealoraRadius.pill),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 36),
          padding: const EdgeInsets.symmetric(horizontal: MealoraSpacing.sm),
          decoration: BoxDecoration(
            color: MealoraColors.surface,
            borderRadius: BorderRadius.circular(MealoraRadius.pill),
            border: Border.all(color: MealoraColors.line),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                time.hhmm,
                style: MealoraTypography.bodyEmphasis.copyWith(color: color),
              ),
              Icon(Icons.expand_more_rounded, size: 16, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

class _WeekdayPicker extends StatelessWidget {
  const _WeekdayPicker({
    required this.text,
    required this.selected,
    required this.onSelected,
  });

  final AppText text;
  final int selected;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final days = <(int, String, String)>[
      (
        DateTime.monday,
        text.remindersWeekdayShortMon,
        text.remindersWeekdayMon,
      ),
      (
        DateTime.tuesday,
        text.remindersWeekdayShortTue,
        text.remindersWeekdayTue,
      ),
      (
        DateTime.wednesday,
        text.remindersWeekdayShortWed,
        text.remindersWeekdayWed,
      ),
      (
        DateTime.thursday,
        text.remindersWeekdayShortThu,
        text.remindersWeekdayThu,
      ),
      (
        DateTime.friday,
        text.remindersWeekdayShortFri,
        text.remindersWeekdayFri,
      ),
      (
        DateTime.saturday,
        text.remindersWeekdayShortSat,
        text.remindersWeekdaySat,
      ),
      (
        DateTime.sunday,
        text.remindersWeekdayShortSun,
        text.remindersWeekdaySun,
      ),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        for (final (weekday, short, full) in days)
          Expanded(
            child: Semantics(
              button: true,
              selected: weekday == selected,
              label: full,
              excludeSemantics: true,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: () => onSelected(weekday),
                child: SizedBox(
                  height: MealoraTouch.minTarget,
                  child: Center(
                    child: Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: weekday == selected
                            ? MealoraColors.primaryDeep
                            : MealoraColors.surface,
                        border: Border.all(
                          color: weekday == selected
                              ? MealoraColors.primaryDeep
                              : MealoraColors.line,
                        ),
                      ),
                      child: Text(
                        short,
                        style: MealoraTypography.chipLabel.copyWith(
                          color: weekday == selected
                              ? MealoraColors.onPrimary
                              : MealoraColors.ink,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _BlockedNote extends StatelessWidget {
  const _BlockedNote({required this.text, required this.onOpenSettings});

  final AppText text;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(MealoraSpacing.md),
      decoration: BoxDecoration(
        color: MealoraColors.noteWarning,
        borderRadius: BorderRadius.circular(MealoraRadius.choiceCard),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Icon(
            Icons.notifications_off_outlined,
            color: MealoraColors.amberText,
            size: 20,
          ),
          const SizedBox(width: MealoraSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  text.remindersBlockedBody,
                  style: MealoraTypography.bodySmall,
                ),
                TextButton(
                  onPressed: onOpenSettings,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, MealoraTouch.minTarget),
                    alignment: Alignment.centerLeft,
                    foregroundColor: MealoraColors.primaryDeep,
                  ),
                  child: Text(
                    text.remindersBlockedAction,
                    style: MealoraTypography.bodyEmphasis.copyWith(
                      color: MealoraColors.primaryDeep,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
