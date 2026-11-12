import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/format/id_formatters.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/domain/diary/energy_trend.dart';
import 'package:mealora/domain/preferences/week_start.dart';
import 'package:mealora/features/diary/add_food_sheet.dart';
import 'package:mealora/features/energy/energy_providers.dart';
import 'package:mealora/features/energy/widgets/energy_line_chart.dart';
import 'package:mealora/features/energy/widgets/energy_range_picker_sheet.dart';
import 'package:mealora/features/history/history_screen.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// `80 · Pantauan energi` (change 018).
///
/// Rentang bebas, bawaan tujuh hari terakhir; rentang hanya hidup di state
/// layar (design D7). Hari tanpa catatan tidak pernah tampil sebagai nol.
class EnergyMonitorScreen extends ConsumerStatefulWidget {
  const EnergyMonitorScreen({super.key});

  @override
  ConsumerState<EnergyMonitorScreen> createState() =>
      _EnergyMonitorScreenState();
}

class _EnergyMonitorScreenState extends ConsumerState<EnergyMonitorScreen> {
  EnergyRange? _range;
  int? _selected;

  Future<void> _pickRange(EnergyRange current) async {
    final today = ref.read(clockProvider).today();
    final first = await ref.read(firstDiaryDateProvider.future);
    if (!mounted) {
      return;
    }
    final picked = await showEnergyRangePicker(
      context,
      initial: current,
      today: today,
      earliest: first ?? today,
      weekStart:
          ref.read(weekStartProvider).valueOrNull ?? WeekStart.defaultValue,
    );
    if (picked != null && mounted) {
      setState(() {
        _range = picked;
        _selected = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final range =
        _range ?? EnergyRange.lastSevenDays(ref.watch(clockProvider).today());
    final trendAsync = ref.watch(energyTrendProvider(range));

    return Scaffold(
      backgroundColor: MealoraColors.background,
      appBar: AppBar(
        backgroundColor: MealoraColors.background,
        elevation: 0,
        title: Text(
          text.energyMonitorTitle,
          style: MealoraTypography.sectionTitle,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            MealoraSpacing.screenGutter,
            MealoraSpacing.sm,
            MealoraSpacing.screenGutter,
            MealoraSpacing.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                text.energyMonitorSubtitle,
                style: MealoraTypography.subtitle,
              ),
              const SizedBox(height: MealoraSpacing.lg),
              _RangeTile(range: range, onTap: () => _pickRange(range)),
              const SizedBox(height: MealoraSpacing.md),
              ...trendAsync.when(
                loading: () => const <Widget>[],
                error: (error, stackTrace) => <Widget>[
                  MealoraErrorState(
                    title: text.energyMonitorTitle,
                    body: text.energyNoRecordsYet,
                  ),
                ],
                data: (trend) => _content(context, text, trend),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _content(BuildContext context, AppText text, EnergyTrend trend) {
    if (!trend.hasAnyRecord) {
      return <Widget>[
        MealoraEmptyState(
          icon: Icons.local_fire_department_outlined,
          title: text.energyEmptyTitle,
          body: text.energyEmptyBody,
          action: MealoraPrimaryButton(
            label: text.energyEmptyAction,
            onPressed: () => showAddFoodSheet(context),
          ),
        ),
      ];
    }
    final selected = _selected != null && _selected! < trend.days.length
        ? trend.days[_selected!]
        : null;

    return <Widget>[
      _SummaryHero(trend: trend),
      const SizedBox(height: MealoraSpacing.lg),
      MealoraCard(
        radius: MealoraRadius.cardLarge,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: Text(
                    text.energyChartHeading,
                    style: MealoraTypography.sectionTitle,
                  ),
                ),
                const _LegendLine(),
                const SizedBox(width: 4),
                Text(text.energyLegendLine, style: MealoraTypography.caption),
                const SizedBox(width: MealoraSpacing.sm),
                const _LegendDash(),
                const SizedBox(width: 4),
                Text(text.energyLegendTarget, style: MealoraTypography.caption),
              ],
            ),
            const SizedBox(height: MealoraSpacing.md),
            EnergyLineChart(
              days: trend.days,
              labels: <String>[for (final d in trend.days) '${d.date.day}'],
              selectedIndex: _selected,
              onSelect: (i) => setState(() => _selected = i),
            ),
            if (selected != null) ...<Widget>[
              const SizedBox(height: MealoraSpacing.sm),
              _SelectedDay(
                day: selected,
                onOpenHistory: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        HistoryCalendarScreen(initialDate: selected.date),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      const SizedBox(height: MealoraSpacing.md),
      Row(
        children: <Widget>[
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: MealoraColors.peach.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(MealoraRadius.track),
            ),
          ),
          const SizedBox(width: MealoraSpacing.xs),
          Expanded(
            child: Text(
              text.energyMissingLegend,
              style: MealoraTypography.caption,
            ),
          ),
        ],
      ),
      const SizedBox(height: MealoraSpacing.xs),
      Row(
        children: <Widget>[
          const Icon(
            Icons.touch_app_outlined,
            size: 14,
            color: MealoraColors.muted,
          ),
          const SizedBox(width: MealoraSpacing.xs),
          Expanded(
            child: Text(text.energyTapHint, style: MealoraTypography.caption),
          ),
        ],
      ),
    ];
  }
}

class _RangeTile extends StatelessWidget {
  const _RangeTile({required this.range, required this.onTap});

  final EnergyRange range;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final value = text.energyRangeValue(
      IdFormat.shortDate(range.from),
      IdFormat.shortDate(range.to),
    );
    return Semantics(
      button: true,
      label: text.energyRangeChangeSemantics(value),
      excludeSemantics: true,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: MealoraCard(
          radius: MealoraRadius.chip,
          padding: const EdgeInsets.symmetric(
            horizontal: MealoraSpacing.md,
            vertical: MealoraSpacing.sm,
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: MealoraColors.iconField,
                  borderRadius: BorderRadius.circular(
                    MealoraRadius.compactIconField,
                  ),
                ),
                child: const Icon(
                  Icons.date_range_rounded,
                  size: 20,
                  color: MealoraColors.primaryDeep,
                ),
              ),
              const SizedBox(width: MealoraSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      text.energyRangeLabel,
                      style: MealoraTypography.eyebrow,
                    ),
                    Text(value, style: MealoraTypography.bodyEmphasis),
                  ],
                ),
              ),
              Text(
                text.energyRangeChange,
                style: MealoraTypography.label.copyWith(
                  color: MealoraColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryHero extends StatelessWidget {
  const _SummaryHero({required this.trend});

  final EnergyTrend trend;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final elapsed = trend.days
        .where((d) => d.state != DailyEnergyState.future)
        .toList(growable: false);
    final missing = elapsed
        .where((d) => d.state == DailyEnergyState.notRecorded)
        .length;
    final average = trend.averageKcal;
    final target = trend.targetKcal;
    final targetLine = trend.targetChanged
        ? text.energyHeroTargetChanged
        : target == null
        ? text.energyHeroNoTarget
        : text.energyHeroTarget(IdFormat.integer(target));
    final detail = missing == 0
        ? targetLine
        : '$targetLine · ${text.energyHeroMissing(missing)}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MealoraSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: MealoraColors.heroGradient,
          stops: MealoraColors.heroGradientStops,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(MealoraRadius.cardLarge),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: MealoraColors.shadowHero,
            offset: Offset(0, 16),
            blurRadius: 36,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            text.energyAverageEyebrow(trend.recordedDays, elapsed.length),
            style: MealoraTypography.eyebrow.copyWith(
              color: MealoraColors.onPrimaryEyebrow,
            ),
          ),
          const SizedBox(height: MealoraSpacing.xxs),
          Text(
            average == null
                ? '–'
                : text.energyKcalValue(IdFormat.integer(average)),
            style: MealoraTypography.display.copyWith(
              color: MealoraColors.onPrimary,
            ),
          ),
          const SizedBox(height: MealoraSpacing.xxs),
          Text(
            detail,
            style: MealoraTypography.bodySmall.copyWith(
              color: MealoraColors.onPrimaryMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _SelectedDay extends StatelessWidget {
  const _SelectedDay({required this.day, required this.onOpenHistory});

  final DailyEnergy day;
  final VoidCallback onOpenHistory;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final date = IdFormat.shortDate(day.date);
    final label = switch (day.state) {
      DailyEnergyState.recorded => text.energyDetailValue(
        date,
        '${day.isPartial ? '≥\u00A0' : ''}${IdFormat.integer(day.kcal!)}',
      ),
      DailyEnergyState.unknown => text.energyDetailUnknown(date),
      DailyEnergyState.notRecorded ||
      DailyEnergyState.future => text.energyDetailNotRecorded(date),
    };
    return Container(
      padding: const EdgeInsets.fromLTRB(
        MealoraSpacing.md,
        MealoraSpacing.xxs,
        MealoraSpacing.xxs,
        MealoraSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: MealoraColors.ink,
        borderRadius: BorderRadius.circular(MealoraRadius.iconField),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              label,
              style: MealoraTypography.bodyEmphasis.copyWith(
                color: MealoraColors.onPrimary,
              ),
            ),
          ),
          TextButton.icon(
            onPressed: onOpenHistory,
            icon: const Icon(
              Icons.north_east_rounded,
              size: 16,
              color: MealoraColors.onPrimary,
            ),
            label: Text(
              text.energyOpenHistory,
              style: MealoraTypography.label.copyWith(
                color: MealoraColors.onPrimary,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LegendLine extends StatelessWidget {
  const _LegendLine();

  @override
  Widget build(BuildContext context) => Container(
    width: 12,
    height: 3,
    decoration: BoxDecoration(
      color: MealoraColors.primaryBright,
      borderRadius: BorderRadius.circular(MealoraRadius.sheetHandle),
    ),
  );
}

class _LegendDash extends StatelessWidget {
  const _LegendDash();

  @override
  Widget build(BuildContext context) => Row(
    children: <Widget>[
      for (var i = 0; i < 2; i++) ...<Widget>[
        if (i > 0) const SizedBox(width: 2),
        Container(
          width: 5,
          height: 2,
          color: MealoraColors.primaryBright.withValues(alpha: 0.55),
        ),
      ],
    ],
  );
}
