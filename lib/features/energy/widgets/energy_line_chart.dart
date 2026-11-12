import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/core/format/id_formatters.dart';
import 'package:mealora/domain/diary/energy_trend.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// Grafik garis energi harian (change 018, design D3/D4; layar `05b`, `80`).
///
/// Garis energi terputus di setiap tanggal tanpa nilai — tidak pernah
/// ditarik ke 0 dan tidak disambung melewati celah. Garis target digambar
/// putus-putus dan bertangga bila target berubah; tanggal tanpa target
/// tidak punya garis target.
///
/// [compact] untuk kartu Program: slot dibagi rata selebar kartu.
/// Mode penuh memakai lebar slot minimum tetap dan dapat digeser mendatar,
/// dibuka di ujung kanan (tanggal terbaru).
class EnergyLineChart extends StatefulWidget {
  const EnergyLineChart({
    required this.days,
    required this.labels,
    this.compact = false,
    this.selectedIndex,
    this.onSelect,
    super.key,
  }) : assert(days.length == labels.length, 'satu label per tanggal');

  final List<DailyEnergy> days;

  /// Label sumbu-X per tanggal (huruf hari atau nomor tanggal).
  final List<String> labels;
  final bool compact;
  final int? selectedIndex;
  final ValueChanged<int>? onSelect;

  static const double _plotHeightCompact = 84;
  static const double _plotHeightFull = 140;
  static const double _minSlotWidthFull = 32;
  static const double _minTapWidth = 40;

  /// Rentang tampilan minimum (kkal) — selisih harian kecil tidak dipaksa
  /// mengisi seluruh tinggi grafik (pola grafik berat, change 008).
  static const double _minDisplayRangeKcal = 1000;

  @override
  State<EnergyLineChart> createState() => _EnergyLineChartState();
}

class _EnergyLineChartState extends State<EnergyLineChart> {
  final ScrollController _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
  }

  @override
  void didUpdateWidget(EnergyLineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.days.length != widget.days.length ||
        (oldWidget.days.isNotEmpty &&
            widget.days.isNotEmpty &&
            oldWidget.days.last.date != widget.days.last.date)) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
    }
  }

  void _scrollToEnd() {
    if (mounted && _scroll.hasClients) {
      _scroll.jumpTo(_scroll.position.maxScrollExtent);
    }
  }

  @override
  void dispose() {
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final plotHeight = widget.compact
        ? EnergyLineChart._plotHeightCompact
        : EnergyLineChart._plotHeightFull;
    final scale = _YScale.of(widget.days);

    return LayoutBuilder(
      builder: (context, constraints) {
        final count = widget.days.length;
        final fitWidth = constraints.maxWidth / count;
        final slotWidth = widget.compact
            ? fitWidth
            : math.max(fitWidth, EnergyLineChart._minSlotWidthFull);
        final contentWidth = slotWidth * count;

        final chart = SizedBox(
          width: contentWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              SizedBox(
                height: plotHeight,
                child: Stack(
                  children: <Widget>[
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _EnergyLinePainter(
                          days: widget.days,
                          scale: scale,
                          slotWidth: slotWidth,
                          selectedIndex: widget.selectedIndex,
                          showGrid: !widget.compact,
                          showMissingBands: !widget.compact,
                        ),
                      ),
                    ),
                    Positioned.fill(
                      child: Row(
                        children: <Widget>[
                          for (var i = 0; i < count; i++)
                            SizedBox(
                              width: slotWidth,
                              child: _SlotHitArea(
                                day: widget.days[i],
                                text: text,
                                selected: widget.selectedIndex == i,
                                onTap:
                                    widget.onSelect == null ||
                                        widget.days[i].state ==
                                            DailyEnergyState.future
                                    ? null
                                    : () => widget.onSelect!(i),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 6),
              ExcludeSemantics(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    for (var i = 0; i < count; i++)
                      SizedBox(
                        width: slotWidth,
                        child: _DayLabel(
                          label: widget.labels[i],
                          day: widget.days[i],
                          compact: widget.compact,
                          selected: widget.selectedIndex == i,
                          text: text,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );

        if (contentWidth <= constraints.maxWidth + 0.5) {
          return chart;
        }
        return SingleChildScrollView(
          controller: _scroll,
          scrollDirection: Axis.horizontal,
          child: chart,
        );
      },
    );
  }
}

/// Skala sumbu-Y dari nilai energi dan target, dengan rentang tampilan
/// minimum dan ruang kepala supaya titik tidak menempel di tepi.
final class _YScale {
  const _YScale(this.min, this.max);

  factory _YScale.of(List<DailyEnergy> days) {
    final values = <double>[
      for (final d in days)
        if (d.kcal != null) d.kcal!,
      for (final d in days)
        if (d.targetKcal != null && d.state != DailyEnergyState.future)
          d.targetKcal!,
    ];
    if (values.isEmpty) {
      return const _YScale(0, EnergyLineChart._minDisplayRangeKcal);
    }
    final lo = values.reduce(math.min);
    final hi = values.reduce(math.max);
    final range = math.max(hi - lo, EnergyLineChart._minDisplayRangeKcal);
    final center = (lo + hi) / 2;
    final padded = range * 1.2;
    final min = math.max(0.0, center - padded / 2);
    return _YScale(min, min + padded);
  }

  final double min;
  final double max;

  /// 0 = bawah, 1 = atas.
  double fraction(double kcal) => ((kcal - min) / (max - min)).clamp(0.0, 1.0);
}

class _EnergyLinePainter extends CustomPainter {
  _EnergyLinePainter({
    required this.days,
    required this.scale,
    required this.slotWidth,
    required this.selectedIndex,
    required this.showGrid,
    required this.showMissingBands,
  });

  final List<DailyEnergy> days;
  final _YScale scale;
  final double slotWidth;
  final int? selectedIndex;
  final bool showGrid;
  final bool showMissingBands;

  static const double _vPad = 10;

  double _x(int i) => slotWidth * (i + 0.5);

  double _y(double kcal, Size size) =>
      _vPad + (1 - scale.fraction(kcal)) * (size.height - _vPad * 2);

  @override
  void paint(Canvas canvas, Size size) {
    if (showMissingBands) {
      final band = Paint()..color = MealoraColors.peach.withValues(alpha: 0.10);
      for (var i = 0; i < days.length; i++) {
        if (days[i].state == DailyEnergyState.notRecorded ||
            days[i].state == DailyEnergyState.unknown) {
          final w = math.min(16.0, slotWidth * 0.6);
          canvas.drawRRect(
            RRect.fromRectAndRadius(
              Rect.fromCenter(
                center: Offset(_x(i), size.height / 2),
                width: w,
                height: size.height,
              ),
              Radius.circular(w / 2),
            ),
            band,
          );
        }
      }
    }

    if (showGrid) {
      final grid = Paint()
        ..color = MealoraColors.ink.withValues(alpha: 0.06)
        ..strokeWidth = 1;
      for (final f in const <double>[0.2, 0.5, 0.8]) {
        final y = _vPad + f * (size.height - _vPad * 2);
        canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
      }
    }

    _paintTarget(canvas, size);
    _paintLine(canvas, size);
  }

  void _paintTarget(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = MealoraColors.primaryBright.withValues(alpha: 0.55)
      ..strokeWidth = 1.5;
    const dash = 6.0;
    const gap = 4.0;
    for (var i = 0; i < days.length; i++) {
      final target = days[i].targetKcal;
      if (target == null || days[i].state == DailyEnergyState.future) {
        continue;
      }
      final y = _y(target, size);
      final start = slotWidth * i;
      final end = start + slotWidth;
      // Pola putus-putus dihitung dari x=0 supaya menyambung antar slot.
      var x = (start / (dash + gap)).floor() * (dash + gap);
      while (x < end) {
        final a = math.max(x, start);
        final b = math.min(x + dash, end);
        if (b > a) {
          canvas.drawLine(Offset(a, y), Offset(b, y), paint);
        }
        x += dash + gap;
      }
      // Tangga vertikal ketika target berubah dari slot sebelumnya.
      final prev = i > 0 ? days[i - 1].targetKcal : null;
      if (prev != null && prev != target) {
        canvas.drawLine(Offset(start, _y(prev, size)), Offset(start, y), paint);
      }
    }
  }

  void _paintLine(Canvas canvas, Size size) {
    final line = Paint()
      ..color = MealoraColors.primaryBright
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    Path? segment;
    for (var i = 0; i < days.length; i++) {
      final kcal = days[i].kcal;
      if (kcal == null) {
        if (segment != null) {
          canvas.drawPath(segment, line);
          segment = null;
        }
        continue;
      }
      final point = Offset(_x(i), _y(kcal, size));
      if (segment == null) {
        segment = Path()..moveTo(point.dx, point.dy);
      } else {
        segment.lineTo(point.dx, point.dy);
      }
    }
    if (segment != null) {
      canvas.drawPath(segment, line);
    }

    final dot = Paint()..color = MealoraColors.primaryBright;
    final ring = Paint()
      ..color = MealoraColors.primaryBright
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    final hole = Paint()..color = MealoraColors.surface;
    for (var i = 0; i < days.length; i++) {
      final kcal = days[i].kcal;
      if (kcal == null) {
        continue;
      }
      final center = Offset(_x(i), _y(kcal, size));
      if (i == selectedIndex) {
        canvas
          ..drawCircle(center, 6, hole)
          ..drawCircle(center, 6, ring);
      } else {
        canvas.drawCircle(center, 3.5, dot);
      }
    }
  }

  @override
  bool shouldRepaint(_EnergyLinePainter old) =>
      old.days != days ||
      old.slotWidth != slotWidth ||
      old.selectedIndex != selectedIndex ||
      old.scale.min != scale.min ||
      old.scale.max != scale.max;
}

class _SlotHitArea extends StatelessWidget {
  const _SlotHitArea({
    required this.day,
    required this.text,
    required this.selected,
    required this.onTap,
  });

  final DailyEnergy day;
  final AppText text;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final date = IdFormat.shortDate(day.date);
    final label = switch (day.state) {
      DailyEnergyState.recorded => text.energyDaySemantics(
        date,
        IdFormat.integer(day.kcal!),
      ),
      DailyEnergyState.unknown => text.energyDayUnknownSemantics(date),
      DailyEnergyState.notRecorded => text.energyDayNotRecordedSemantics(date),
      DailyEnergyState.future => text.energyDayFutureSemantics(date),
    };
    return Semantics(
      label: label,
      button: onTap != null,
      selected: selected,
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: const SizedBox(
          height: double.infinity,
          width: EnergyLineChart._minTapWidth,
        ),
      ),
    );
  }
}

class _DayLabel extends StatelessWidget {
  const _DayLabel({
    required this.label,
    required this.day,
    required this.compact,
    required this.selected,
    required this.text,
  });

  final String label;
  final DailyEnergy day;
  final bool compact;
  final bool selected;
  final AppText text;

  @override
  Widget build(BuildContext context) {
    final missing =
        day.state == DailyEnergyState.notRecorded ||
        day.state == DailyEnergyState.unknown;
    final style = MealoraTypography.caption.copyWith(
      color: missing ? MealoraColors.coralText : null,
      fontWeight: missing || selected ? FontWeight.w700 : null,
    );
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(label, style: style, textAlign: TextAlign.center),
        if (missing) ...<Widget>[
          const SizedBox(height: 2),
          if (compact)
            Text(
              day.state == DailyEnergyState.unknown
                  ? text.energyDayUnknownShort
                  : text.energyDayNotRecordedShort,
              style: MealoraTypography.caption.copyWith(
                color: MealoraColors.coralText,
                fontWeight: FontWeight.w700,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.visible,
              softWrap: false,
            )
          else
            Container(
              width: 4,
              height: 4,
              decoration: const BoxDecoration(
                color: MealoraColors.coralText,
                shape: BoxShape.circle,
              ),
            ),
        ],
      ],
    );
  }
}
