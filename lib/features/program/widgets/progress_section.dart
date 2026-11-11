import 'package:flutter/material.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/format/id_formatters.dart';
import 'package:mealora/data/local/program_progress_snapshot.dart';
import 'package:mealora/domain/food/meal_time.dart';
import 'package:mealora/domain/preferences/week_start.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// "Kebiasaan minggu ini" (`05`) — kemajuan seluruh program SHALL berupa
/// kelengkapan pencatatan, SHALL TIDAK berupa persentase kemajuan berat;
/// pemantauan berat punya layarnya sendiri (`31`, change 008), diakses
/// lewat kartu "Catatan berat" (spec program-management, "Program Makan
/// Sehat" — kini berlaku seragam untuk semua program).
///
/// Setiap batang terbagi menjadi empat ruas (`MealTime.values.length`,
/// satu per waktu makan), terisi dari bawah sebanyak jumlah waktu makan yang
/// tercatat hari itu — bukan dua keadaan kasar (lengkap/sebagian) yang
/// tampak sama persis untuk 1 dan 3 dari 4 waktu makan. Hari tanpa potret
/// tersimpan ditandai dengan garis tepi, bukan nol ruas tanpa keterangan
/// (Design D6, task 2.4); setiap batang punya label pembaca layar sendiri
/// yang menyebut tanggal dan jumlah ruas terisi apa adanya.
class WeeklyConsistencyCard extends StatelessWidget {
  const WeeklyConsistencyCard({
    required this.snapshots,
    required this.today,
    this.weekStart = WeekStart.defaultValue,
    super.key,
  });

  final List<ProgramProgressSnapshot> snapshots;
  final LocalDate today;
  final WeekStart weekStart;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final byDate = <String, ProgramProgressSnapshot>{
      for (final snapshot in snapshots)
        snapshot.recordedLocalDate.iso: snapshot,
    };
    final todayDateTime = DateTime(today.year, today.month, today.day);
    final firstDay = todayDateTime.subtract(
      Duration(days: weekStart.offsetOf(todayDateTime.weekday)),
    );
    final dayLetters = weekStart.dayLetters;
    final days = List<LocalDate>.generate(7, (i) {
      final date = DateTime(firstDay.year, firstDay.month, firstDay.day + i);
      return LocalDate(date.year, date.month, date.day);
    });
    final loggedCount = days.where((day) {
      final snapshot = byDate[day.iso];
      return snapshot != null && snapshot.loggedMealsCount > 0;
    }).length;

    return MealoraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            text.programConsistencyHeading,
            style: MealoraTypography.sectionTitle,
          ),
          const SizedBox(height: MealoraSpacing.xxs),
          Text(
            text.programConsistencySubheading,
            style: MealoraTypography.bodySmall,
          ),
          const SizedBox(height: MealoraSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              for (var i = 0; i < 7; i++)
                _DayBar(
                  letter: dayLetters[i],
                  date: days[i],
                  snapshot: byDate[days[i].iso],
                  text: text,
                ),
            ],
          ),
          const SizedBox(height: MealoraSpacing.sm),
          Text(
            text.programConsistencyFooter(loggedCount),
            style: MealoraTypography.caption,
          ),
        ],
      ),
    );
  }
}

class _DayBar extends StatelessWidget {
  const _DayBar({
    required this.letter,
    required this.date,
    required this.snapshot,
    required this.text,
  });

  final String letter;
  final LocalDate date;
  final ProgramProgressSnapshot? snapshot;
  final AppText text;

  static const double _trackWidth = 14;
  static const double _trackHeight = 52;
  static final int _segmentCount = MealTime.values.length;

  @override
  Widget build(BuildContext context) {
    final filled = (snapshot?.loggedMealsCount ?? 0).clamp(0, _segmentCount);
    final semanticsLabel = snapshot == null
        ? text.programConsistencyDayEmptySemantics(IdFormat.longDate(date))
        : text.programConsistencyDaySegmentSemantics(
            IdFormat.longDate(date),
            filled,
            _segmentCount,
          );
    const cornerRadius = _trackWidth / 2;
    final filledHeight = _trackHeight * filled / _segmentCount;
    return Semantics(
      label: semanticsLabel,
      child: Column(
        children: <Widget>[
          SizedBox(
            width: _trackWidth,
            height: _trackHeight,
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                Container(
                  width: _trackWidth,
                  height: _trackHeight,
                  decoration: BoxDecoration(
                    color: MealoraColors.track,
                    borderRadius: BorderRadius.circular(cornerRadius),
                    border: filled == 0
                        ? Border.all(color: MealoraColors.affordance, width: 1)
                        : null,
                  ),
                ),
                if (filled > 0)
                  Container(
                    width: _trackWidth,
                    height: filledHeight,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: MealoraColors.consistencyGradient,
                      ),
                      borderRadius: BorderRadius.circular(cornerRadius),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: MealoraSpacing.xxs),
          Text(letter, style: MealoraTypography.caption),
        ],
      ),
    );
  }
}
