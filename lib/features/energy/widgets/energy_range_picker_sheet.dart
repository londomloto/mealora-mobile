import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/format/id_formatters.dart';
import 'package:mealora/domain/preferences/week_start.dart';
import 'package:mealora/features/energy/energy_providers.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// Lembar bawah pemilih rentang tanggal (`81`, change 018, design D6).
///
/// Ketuk pertama memilih tanggal mulai, ketuk kedua tanggal akhir (ditukar
/// bila lebih awal). Tanggal setelah [today] dan sebelum [earliest]
/// dinonaktifkan. Mengembalikan rentang yang diterapkan, atau `null`.
Future<EnergyRange?> showEnergyRangePicker(
  BuildContext context, {
  required EnergyRange initial,
  required LocalDate today,
  required LocalDate earliest,
  required WeekStart weekStart,
}) => showModalBottomSheet<EnergyRange>(
  context: context,
  isScrollControlled: true,
  backgroundColor: MealoraColors.transparent,
  barrierColor: MealoraColors.modalScrim,
  builder: (_) => _EnergyRangePickerSheet(
    initial: initial,
    today: today,
    earliest: earliest,
    weekStart: weekStart,
  ),
);

class _EnergyRangePickerSheet extends StatefulWidget {
  const _EnergyRangePickerSheet({
    required this.initial,
    required this.today,
    required this.earliest,
    required this.weekStart,
  });

  final EnergyRange initial;
  final LocalDate today;
  final LocalDate earliest;
  final WeekStart weekStart;

  @override
  State<_EnergyRangePickerSheet> createState() =>
      _EnergyRangePickerSheetState();
}

class _EnergyRangePickerSheetState extends State<_EnergyRangePickerSheet> {
  late LocalDate _start = widget.initial.from;
  late LocalDate? _end = widget.initial.to;
  late DateTime _month = DateTime(
    widget.initial.to.year,
    widget.initial.to.month,
  );

  bool _isDisabled(LocalDate date) =>
      date.compareTo(widget.today) > 0 || date.compareTo(widget.earliest) < 0;

  void _tap(LocalDate date) {
    setState(() {
      final end = _end;
      if (end == null) {
        if (date.compareTo(_start) < 0) {
          _end = _start;
          _start = date;
        } else {
          _end = date;
        }
      } else {
        _start = date;
        _end = null;
      }
    });
  }

  EnergyRange get _range => EnergyRange(_start, _end ?? _start);

  bool get _canGoBack =>
      DateTime(widget.earliest.year, widget.earliest.month).isBefore(_month);

  bool get _canGoForward =>
      _month.isBefore(DateTime(widget.today.year, widget.today.month));

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final range = _range;

    return Container(
      decoration: const BoxDecoration(
        color: MealoraColors.surface,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(MealoraRadius.sheet),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        MealoraSpacing.screenGutter,
        MealoraSpacing.xs,
        MealoraSpacing.screenGutter,
        MealoraSpacing.xl + MediaQuery.paddingOf(context).bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: MealoraColors.ink.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(MealoraRadius.sheetHandle),
                ),
              ),
            ),
            const SizedBox(height: MealoraSpacing.md),
            Text(
              text.energyRangePickerTitle,
              style: MealoraTypography.sectionTitle,
            ),
            const SizedBox(height: MealoraSpacing.xxs),
            Text(
              text.energyRangePickerSubtitle,
              style: MealoraTypography.bodySmall,
            ),
            const SizedBox(height: MealoraSpacing.md),
            Row(
              children: <Widget>[
                IconButton(
                  tooltip: text.energyRangePrevMonth,
                  onPressed: _canGoBack
                      ? () => setState(
                          () =>
                              _month = DateTime(_month.year, _month.month - 1),
                        )
                      : null,
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                Expanded(
                  child: Text(
                    DateFormat('MMMM y', kAppLocale).format(_month),
                    textAlign: TextAlign.center,
                    style: MealoraTypography.bodyEmphasis,
                  ),
                ),
                IconButton(
                  tooltip: text.energyRangeNextMonth,
                  onPressed: _canGoForward
                      ? () => setState(
                          () =>
                              _month = DateTime(_month.year, _month.month + 1),
                        )
                      : null,
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
            const SizedBox(height: MealoraSpacing.xs),
            _MonthGrid(
              month: _month,
              weekStart: widget.weekStart,
              start: _start,
              end: _end,
              isDisabled: _isDisabled,
              today: widget.today,
              onTap: _tap,
            ),
            const SizedBox(height: MealoraSpacing.md),
            Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        text.energyRangeValue(
                          IdFormat.shortDate(range.from),
                          IdFormat.shortDate(range.to),
                        ),
                        style: MealoraTypography.bodyEmphasis,
                      ),
                      Text(
                        text.energyRangeDays(range.dayCount),
                        style: MealoraTypography.caption,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: MealoraSpacing.sm),
                SizedBox(
                  width: 140,
                  child: MealoraPrimaryButton(
                    label: text.energyRangeApply,
                    icon: null,
                    onPressed: () => Navigator.of(context).pop(range),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.month,
    required this.weekStart,
    required this.start,
    required this.end,
    required this.isDisabled,
    required this.today,
    required this.onTap,
  });

  final DateTime month;
  final WeekStart weekStart;
  final LocalDate start;
  final LocalDate? end;
  final bool Function(LocalDate) isDisabled;
  final LocalDate today;
  final ValueChanged<LocalDate> onTap;

  static const double _cell = 40;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(month.year, month.month);
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leading = weekStart.offsetOf(first.weekday);
    final cells = <LocalDate?>[
      for (var i = 0; i < leading; i++) null,
      for (var d = 1; d <= daysInMonth; d++)
        LocalDate(month.year, month.month, d),
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    final rangeEnd = end ?? start;

    return Column(
      children: <Widget>[
        ExcludeSemantics(
          child: Row(
            children: <Widget>[
              for (final letter in weekStart.dayLetters)
                Expanded(
                  child: Text(
                    letter,
                    textAlign: TextAlign.center,
                    style: MealoraTypography.caption.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: MealoraSpacing.xxs),
        for (var row = 0; row < cells.length ~/ 7; row++)
          Row(
            children: <Widget>[
              for (var col = 0; col < 7; col++)
                Expanded(
                  child: _cellFor(context, cells[row * 7 + col], rangeEnd, col),
                ),
            ],
          ),
      ],
    );
  }

  Widget _cellFor(
    BuildContext context,
    LocalDate? date,
    LocalDate rangeEnd,
    int col,
  ) {
    if (date == null) {
      return const SizedBox(height: _cell);
    }
    final disabled = isDisabled(date);
    final isStart = date == start;
    final isEnd = date == rangeEnd;
    final edge = isStart || isEnd;
    final inRange = date.compareTo(start) >= 0 && date.compareTo(rangeEnd) <= 0;
    final singleDay = start == rangeEnd;

    BorderRadius? bandRadius;
    if (inRange && !singleDay) {
      const r = Radius.circular(_cell / 2);
      bandRadius = BorderRadius.horizontal(
        left: isStart || col == 0 ? r : Radius.zero,
        right: isEnd || col == 6 ? r : Radius.zero,
      );
    }

    final label = IdFormat.shortDate(date);
    return Semantics(
      label: label,
      button: !disabled,
      enabled: !disabled,
      selected: inRange,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: disabled ? null : () => onTap(date),
        child: Container(
          height: _cell,
          decoration: bandRadius == null
              ? null
              : BoxDecoration(
                  color: MealoraColors.primarySelectedTint,
                  borderRadius: bandRadius,
                ),
          alignment: Alignment.center,
          child: Container(
            width: 36,
            height: 36,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: edge ? MealoraColors.primaryBright : null,
              border: date == today && !edge
                  ? Border.all(color: MealoraColors.primaryBright, width: 1.5)
                  : null,
            ),
            child: Text(
              '${date.day}',
              style: MealoraTypography.body.copyWith(
                color: edge
                    ? MealoraColors.onPrimary
                    : disabled
                    ? MealoraColors.ink.withValues(alpha: 0.25)
                    : MealoraColors.ink,
                fontWeight: edge || date == today ? FontWeight.w700 : null,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
