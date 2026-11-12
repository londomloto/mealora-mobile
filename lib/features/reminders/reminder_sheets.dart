import 'package:flutter/material.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/domain/reminders/reminder_settings.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

const int _minuteStep = 5;
const double _wheelItemExtent = 40;

Future<T?> _showMealoraSheet<T>(BuildContext context, WidgetBuilder builder) =>
    showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: MealoraColors.sheetSurface,
      barrierColor: MealoraColors.modalScrim,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(MealoraRadius.sheet),
        ),
      ),
      builder: builder,
    );

/// `51 · Sheet pilih jam` — roda jam dan menit (kelipatan 5 menit).
Future<ClockTime?> showReminderTimePicker(
  BuildContext context, {
  required ClockTime initial,
  required String subtitle,
}) => _showMealoraSheet<ClockTime>(
  context,
  (_) => _TimePickerSheet(initial: initial, subtitle: subtitle),
);

/// `52 · Sheet pra-izin notifikasi`; `true` bila pengguna memilih Lanjut.
Future<bool> showNotificationPermissionSheet(BuildContext context) async =>
    await _showMealoraSheet<bool>(context, (_) => const _PermissionSheet()) ??
    false;

class _TimePickerSheet extends StatefulWidget {
  const _TimePickerSheet({required this.initial, required this.subtitle});

  final ClockTime initial;
  final String subtitle;

  @override
  State<_TimePickerSheet> createState() => _TimePickerSheetState();
}

class _TimePickerSheetState extends State<_TimePickerSheet> {
  late int _hour = widget.initial.hour;
  late int _minuteIndex =
      (widget.initial.minute / _minuteStep).round() % (60 ~/ _minuteStep);
  late final FixedExtentScrollController _hours = FixedExtentScrollController(
    initialItem: _hour,
  );
  late final FixedExtentScrollController _minutes = FixedExtentScrollController(
    initialItem: _minuteIndex,
  );

  @override
  void dispose() {
    _hours.dispose();
    _minutes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          MealoraSpacing.lg,
          MealoraSpacing.sm,
          MealoraSpacing.lg,
          MealoraSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const _SheetHandle(),
            Text(
              text.remindersTimePickerTitle,
              style: MealoraTypography.headline,
            ),
            const SizedBox(height: MealoraSpacing.xxs),
            Text(widget.subtitle, style: MealoraTypography.bodySmall),
            const SizedBox(height: MealoraSpacing.md),
            MealoraCard(
              padding: const EdgeInsets.all(MealoraSpacing.xs),
              child: SizedBox(
                height: _wheelItemExtent * 5,
                child: Stack(
                  alignment: Alignment.center,
                  children: <Widget>[
                    Container(
                      height: _wheelItemExtent,
                      decoration: BoxDecoration(
                        color: MealoraColors.primarySelectedTint,
                        borderRadius: BorderRadius.circular(
                          MealoraRadius.compactIconField,
                        ),
                      ),
                    ),
                    Row(
                      children: <Widget>[
                        Expanded(
                          child: _Wheel(
                            controller: _hours,
                            count: 24,
                            selected: _hour,
                            label: (i) => i.toString().padLeft(2, '0'),
                            onChanged: (i) => setState(() => _hour = i),
                          ),
                        ),
                        Text(':', style: MealoraTypography.headline),
                        Expanded(
                          child: _Wheel(
                            controller: _minutes,
                            count: 60 ~/ _minuteStep,
                            selected: _minuteIndex,
                            label: (i) =>
                                (i * _minuteStep).toString().padLeft(2, '0'),
                            onChanged: (i) => setState(() => _minuteIndex = i),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: MealoraSpacing.sm),
            Text(
              text.remindersTimePickerNote,
              style: MealoraTypography.caption,
            ),
            const SizedBox(height: MealoraSpacing.md),
            _SheetActions(
              secondaryLabel: text.remindersTimePickerCancel,
              onSecondary: () => Navigator.of(context).pop(),
              primaryLabel: text.remindersTimePickerSave,
              onPrimary: () => Navigator.of(
                context,
              ).pop(ClockTime(_hour, _minuteIndex * _minuteStep)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Wheel extends StatelessWidget {
  const _Wheel({
    required this.controller,
    required this.count,
    required this.selected,
    required this.label,
    required this.onChanged,
  });

  final FixedExtentScrollController controller;
  final int count;
  final int selected;
  final String Function(int) label;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return ListWheelScrollView.useDelegate(
      controller: controller,
      itemExtent: _wheelItemExtent,
      physics: const FixedExtentScrollPhysics(),
      diameterRatio: 3,
      onSelectedItemChanged: (index) => onChanged(index % count),
      childDelegate: ListWheelChildLoopingListDelegate(
        children: <Widget>[
          for (var i = 0; i < count; i++)
            Center(
              child: Text(
                label(i),
                style: i == selected
                    ? MealoraTypography.headline
                    : MealoraTypography.body.copyWith(
                        color: MealoraColors.muted,
                      ),
              ),
            ),
        ],
      ),
    );
  }
}

class _PermissionSheet extends StatelessWidget {
  const _PermissionSheet();

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          MealoraSpacing.lg,
          MealoraSpacing.sm,
          MealoraSpacing.lg,
          MealoraSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            const _SheetHandle(),
            Text(
              text.remindersPermissionTitle,
              style: MealoraTypography.headline,
            ),
            const SizedBox(height: MealoraSpacing.xxs),
            Text(
              text.remindersPermissionBody,
              style: MealoraTypography.bodySmall,
            ),
            const SizedBox(height: MealoraSpacing.md),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: MealoraColors.iconField,
                borderRadius: BorderRadius.circular(MealoraRadius.iconField),
              ),
              child: const Icon(
                Icons.notifications_active_outlined,
                color: MealoraColors.primaryDeep,
              ),
            ),
            const SizedBox(height: MealoraSpacing.md),
            MealoraNoteCard(
              icon: Icons.lock_outline_rounded,
              body: text.remindersPermissionLocalNote,
            ),
            const SizedBox(height: MealoraSpacing.md),
            _SheetActions(
              secondaryLabel: text.remindersPermissionLater,
              onSecondary: () => Navigator.of(context).pop(false),
              primaryLabel: text.remindersPermissionContinue,
              onPrimary: () => Navigator.of(context).pop(true),
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        margin: const EdgeInsets.only(bottom: MealoraSpacing.md),
        decoration: BoxDecoration(
          color: MealoraColors.line,
          borderRadius: BorderRadius.circular(MealoraRadius.sheetHandle),
        ),
      ),
    );
  }
}

class _SheetActions extends StatelessWidget {
  const _SheetActions({
    required this.secondaryLabel,
    required this.onSecondary,
    required this.primaryLabel,
    required this.onPrimary,
  });

  final String secondaryLabel;
  final VoidCallback onSecondary;
  final String primaryLabel;
  final VoidCallback onPrimary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: OutlinedButton(
            onPressed: onSecondary,
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(MealoraTouch.minTarget + 8),
              backgroundColor: MealoraColors.surface,
              foregroundColor: MealoraColors.ink,
              side: const BorderSide(color: MealoraColors.line),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(MealoraRadius.button),
              ),
            ),
            child: Text(
              secondaryLabel,
              style: MealoraTypography.button.copyWith(
                color: MealoraColors.ink,
              ),
            ),
          ),
        ),
        const SizedBox(width: MealoraSpacing.sm),
        Expanded(
          child: MealoraPrimaryButton(
            label: primaryLabel,
            onPressed: onPrimary,
            icon: null,
          ),
        ),
      ],
    );
  }
}
