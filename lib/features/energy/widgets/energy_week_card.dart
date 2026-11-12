import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/format/id_formatters.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/domain/diary/energy_trend.dart';
import 'package:mealora/domain/preferences/week_start.dart';
import 'package:mealora/features/energy/energy_monitor_screen.dart';
import 'package:mealora/features/energy/energy_providers.dart';
import 'package:mealora/features/energy/widgets/energy_line_chart.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// "Energi minggu ini" di ruang Program (`05b`, change 018) — minggu
/// berjalan mengikuti preferensi awal minggu, sama seperti kartu
/// "Kebiasaan minggu ini".
class EnergyWeekCard extends ConsumerWidget {
  const EnergyWeekCard({super.key});

  /// Minggu berjalan yang memuat [today].
  static EnergyRange weekOf(LocalDate today, WeekStart weekStart) {
    final weekday = DateTime(today.year, today.month, today.day).weekday;
    final first = shiftDate(today, -weekStart.offsetOf(weekday));
    return EnergyRange(first, shiftDate(first, 6));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = AppText.of(context);
    final weekStart =
        ref.watch(weekStartProvider).valueOrNull ?? WeekStart.defaultValue;
    final range = weekOf(ref.watch(clockProvider).today(), weekStart);
    final trend = ref.watch(energyTrendProvider(range)).valueOrNull;

    return Semantics(
      button: true,
      label: text.energyWeekOpenSemantics,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(builder: (_) => const EnergyMonitorScreen()),
        ),
        child: MealoraCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      text.energyWeekHeading,
                      style: MealoraTypography.sectionTitle,
                    ),
                  ),
                  const Icon(
                    Icons.chevron_right_rounded,
                    color: MealoraColors.muted,
                  ),
                ],
              ),
              const SizedBox(height: MealoraSpacing.xxs),
              Text(
                trend == null ? '' : energySummaryText(text, trend),
                style: MealoraTypography.bodySmall,
              ),
              const SizedBox(height: MealoraSpacing.sm),
              if (trend != null)
                EnergyLineChart(
                  days: trend.days,
                  labels: weekStart.dayLetters,
                  compact: true,
                ),
              const SizedBox(height: MealoraSpacing.xs),
              Text(text.energyCardFooter, style: MealoraTypography.caption),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ringkasan rata-rata terhadap target, dipakai kartu dan layar pantauan.
String energySummaryText(AppText text, EnergyTrend trend) {
  final average = trend.averageKcal;
  if (average == null) {
    // Ada catatan tetapi tidak satu hari pun lengkap energinya (change 021):
    // hari parsial tidak ikut rata-rata, bukan berarti belum ada catatan.
    return trend.hasAnyRecord
        ? text.energyNoCompleteDays
        : text.energyNoRecordsYet;
  }
  final avg = IdFormat.integer(average);
  if (trend.targetChanged) {
    return text.energySummaryTargetChanged(avg, trend.recordedDays);
  }
  final target = trend.targetKcal;
  if (target == null) {
    return text.energySummaryNoTarget(avg, trend.recordedDays);
  }
  return text.energySummary(avg, IdFormat.integer(target), trend.recordedDays);
}
