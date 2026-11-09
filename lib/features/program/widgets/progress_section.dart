import 'package:flutter/material.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/data/local/program_progress_snapshot.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

enum _DayState { complete, loggedIncomplete, noData }

/// "Kebiasaan minggu ini" (`05`) — kemajuan Makan Sehat SHALL berupa
/// kelengkapan pencatatan, SHALL TIDAK berupa persentase kemajuan berat
/// (spec program-management, "Program Makan Sehat").
///
/// Hari tanpa potret tersimpan ditandai berbeda dari hari yang tercatat
/// tapi belum lengkap — keduanya SHALL TIDAK tampak sebagai nol (Design
/// D6, task 2.4): batang hanya terisi pada hari yang benar-benar lengkap,
/// dan setiap batang punya label pembaca layar sendiri yang menyebut
/// keadaannya apa adanya.
class WeeklyConsistencyCard extends StatelessWidget {
  const WeeklyConsistencyCard({
    required this.snapshots,
    required this.today,
    super.key,
  });

  final List<ProgramProgressSnapshot> snapshots;
  final LocalDate today;

  static const List<String> _dayLetters = <String>[
    'S',
    'S',
    'R',
    'K',
    'J',
    'S',
    'M',
  ];

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final byDate = <String, ProgramProgressSnapshot>{
      for (final snapshot in snapshots)
        snapshot.recordedLocalDate.iso: snapshot,
    };
    final todayDateTime = DateTime(today.year, today.month, today.day);
    final monday = todayDateTime.subtract(
      Duration(days: todayDateTime.weekday - DateTime.monday),
    );
    final days = List<LocalDate>.generate(7, (i) {
      final date = monday.add(Duration(days: i));
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
                  letter: _dayLetters[i],
                  state: _stateFor(byDate[days[i].iso]),
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

  _DayState _stateFor(ProgramProgressSnapshot? snapshot) {
    if (snapshot == null) {
      return _DayState.noData;
    }
    return snapshot.diaryComplete
        ? _DayState.complete
        : _DayState.loggedIncomplete;
  }
}

class _DayBar extends StatelessWidget {
  const _DayBar({
    required this.letter,
    required this.state,
    required this.text,
  });

  final String letter;
  final _DayState state;
  final AppText text;

  @override
  Widget build(BuildContext context) {
    final semanticsLabel = switch (state) {
      _DayState.complete => text.programConsistencyDayCompleteSemantics,
      _DayState.loggedIncomplete => text.programConsistencyDayPartialSemantics,
      _DayState.noData => text.programConsistencyDayNoDataSemantics,
    };
    return Semantics(
      label: semanticsLabel,
      child: Column(
        children: <Widget>[
          Container(
            width: 18,
            height: 56,
            decoration: BoxDecoration(
              color: MealoraColors.track,
              borderRadius: BorderRadius.circular(MealoraRadius.track),
              border: state == _DayState.noData
                  ? Border.all(color: MealoraColors.affordance, width: 1)
                  : null,
            ),
            alignment: Alignment.bottomCenter,
            child: state == _DayState.complete
                ? Container(
                    width: 18,
                    height: 40,
                    decoration: BoxDecoration(
                      color: MealoraColors.primaryBright,
                      borderRadius: BorderRadius.circular(MealoraRadius.track),
                    ),
                  )
                : state == _DayState.loggedIncomplete
                ? Container(
                    width: 18,
                    height: 16,
                    decoration: BoxDecoration(
                      color: MealoraColors.accent,
                      borderRadius: BorderRadius.circular(MealoraRadius.track),
                    ),
                  )
                : null,
          ),
          const SizedBox(height: MealoraSpacing.xxs),
          Text(letter, style: MealoraTypography.caption),
        ],
      ),
    );
  }
}

/// Kemajuan berbasis berat (Turun Berat/Naik Berat/Pertahankan) — "belum
/// diketahui" sampai pemantauan berat badan (change berikutnya) menulis
/// potret berbobot (Non-Goals, design.md). Bentuknya sudah disiapkan di
/// sini supaya change itu hanya perlu mengisi nilainya, bukan membangun
/// ulang layarnya (Open Questions, design.md).
class WeightProgressPlaceholderCard extends StatelessWidget {
  const WeightProgressPlaceholderCard({super.key});

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return MealoraNoteCard(
      icon: Icons.show_chart,
      title: text.programWeightProgressUnknownTitle,
      body: text.programWeightProgressUnknownBody,
    );
  }
}
