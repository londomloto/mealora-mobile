import 'package:flutter/material.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/domain/weight/weight_record.dart';
import 'package:mealora/features/weight/weight_providers.dart';

/// Tren berat empat minggu terakhir (`31`, design D2/D3, change 008).
///
/// Satu batang per hari kalender dalam jendela [kWeightTrendWindowDays] —
/// hari tanpa catatan SHALL TIDAK digambar sama sekali (bukan batang nol,
/// bukan disambung dari nilai terakhir) supaya celah benar-benar terlihat
/// sebagai celah, sesuai design D2.
class WeightTrendChart extends StatelessWidget {
  const WeightTrendChart({
    required this.records,
    required this.today,
    super.key,
  });

  final List<WeightRecord> records;
  final LocalDate today;

  static const double _trackHeight = 56;

  @override
  Widget build(BuildContext context) {
    final byDate = <String, double>{};
    for (final record in records) {
      // Beberapa catatan pada hari yang sama: ambil yang terakhir dalam
      // urutan menaik (recordedAt terbaru), selaras `WeightRepository.latest`.
      byDate[record.localDate.iso] = record.weightKg;
    }
    if (byDate.isEmpty) {
      return const SizedBox.shrink();
    }

    final values = byDate.values.toList(growable: false);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    // Jarak minimum supaya satu nilai tunggal tidak membuat batang
    // berketinggian sama persis seolah skala tak berarti.
    final range = (maxValue - minValue).clamp(0.5, double.infinity);

    final days = List<LocalDate>.generate(
      kWeightTrendWindowDays,
      (i) => _minusDays(today, kWeightTrendWindowDays - 1 - i),
    );

    return SizedBox(
      height: _trackHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          for (final day in days)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: MealoraSpacing.xxs / 4,
                ),
                child: _DayBarOrGap(
                  weightKg: byDate[day.iso],
                  minValue: minValue,
                  range: range,
                  trackHeight: _trackHeight,
                ),
              ),
            ),
        ],
      ),
    );
  }

  LocalDate _minusDays(LocalDate date, int days) {
    final cursor = DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(Duration(days: days));
    return LocalDate(cursor.year, cursor.month, cursor.day);
  }
}

class _DayBarOrGap extends StatelessWidget {
  const _DayBarOrGap({
    required this.weightKg,
    required this.minValue,
    required this.range,
    required this.trackHeight,
  });

  final double? weightKg;
  final double minValue;
  final double range;
  final double trackHeight;

  @override
  Widget build(BuildContext context) {
    if (weightKg == null) {
      return const SizedBox.shrink();
    }
    final ratio = ((weightKg! - minValue) / range).clamp(0.08, 1.0);
    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        height: trackHeight * ratio,
        decoration: BoxDecoration(
          color: MealoraColors.info,
          borderRadius: BorderRadius.circular(MealoraRadius.track),
        ),
      ),
    );
  }
}
