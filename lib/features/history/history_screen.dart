import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// Pintu masuk tab Riwayat mengikuti `16 · Buku harian hari ini`.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = AppText.of(context);
    final today = ref.watch(clockProvider).today();
    final date = DateTime(today.year, today.month, today.day);
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final heroHeight = (232 + (textScale - 1).clamp(0, 1) * 180).toDouble();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        bottom: MealoraSpacing.navigationContentClearance,
      ),
      child: Stack(
        children: <Widget>[
          Container(
            width: double.infinity,
            height: heroHeight,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: MealoraColors.heroGradient,
                stops: MealoraColors.heroGradientStops,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(MealoraRadius.programHeroBottom),
                bottomRight: Radius.circular(MealoraRadius.programHeroBottom),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: <Widget>[
                const Positioned.fill(
                  child: CustomPaint(painter: _HistoryHeroGlowPainter()),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        text.historyTodayContextLabel,
                        style: MealoraTypography.eyebrow.copyWith(
                          color: MealoraColors.onPrimaryEyebrow,
                        ),
                      ),
                      const SizedBox(height: MealoraSpacing.xxs),
                      Text(
                        text.historyDiaryTitle,
                        style: MealoraTypography.title.copyWith(
                          color: MealoraColors.onPrimary,
                        ),
                      ),
                      const SizedBox(height: MealoraSpacing.xxs),
                      Text(
                        '${DateFormat('EEEE, d MMMM y', 'id_ID').format(date)} · ${text.historyLocalNote}',
                        style: MealoraTypography.subtitle.copyWith(
                          color: MealoraColors.onPrimaryMuted,
                        ),
                      ),
                      const SizedBox(height: MealoraSpacing.md),
                      Semantics(
                        button: true,
                        label: text.historyOpenCalendarLabel,
                        child: InkWell(
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => const HistoryCalendarScreen(),
                            ),
                          ),
                          borderRadius: BorderRadius.circular(
                            MealoraRadius.chip,
                          ),
                          child: Container(
                            height: 48,
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            decoration: BoxDecoration(
                              color: MealoraColors.glassOnHero,
                              borderRadius: BorderRadius.circular(
                                MealoraRadius.chip,
                              ),
                            ),
                            child: Row(
                              children: <Widget>[
                                const Icon(
                                  Icons.chevron_left_rounded,
                                  color: MealoraColors.onPrimary,
                                ),
                                Expanded(
                                  child: Text(
                                    DateFormat(
                                      'EEEE, d MMMM',
                                      'id_ID',
                                    ).format(date),
                                    textAlign: TextAlign.center,
                                    style: MealoraTypography.bodyEmphasis
                                        .copyWith(
                                          color: MealoraColors.onPrimary,
                                        ),
                                  ),
                                ),
                                const Icon(
                                  Icons.chevron_right_rounded,
                                  color: MealoraColors.onPrimary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(22, heroHeight - 8, 22, 0),
            child: Column(
              children: <Widget>[
                MealoraCard(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              text.historyRecordedTodayLabel,
                              style: MealoraTypography.eyebrow,
                            ),
                            const SizedBox(height: MealoraSpacing.xs),
                            Text(
                              text.todayConsumedUnknown,
                              style: MealoraTypography.headline,
                            ),
                            const SizedBox(height: MealoraSpacing.xxs),
                            Text(
                              text.historyEmptyBody,
                              style: MealoraTypography.bodySmall,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: 68,
                        height: 68,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(
                          color: MealoraColors.noteSuccess,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.calendar_month_outlined,
                          color: MealoraColors.primaryDeep,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: MealoraSpacing.md),
                MealoraEmptyState(
                  title: text.historyEmptyTitle,
                  body: text.historyEmptyBody,
                  icon: Icons.menu_book_outlined,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryHeroGlowPainter extends CustomPainter {
  const _HistoryHeroGlowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 390;
    canvas.drawCircle(
      Offset(355 * scale, 55 * scale),
      125 * scale,
      Paint()
        ..color = MealoraColors.lime.withValues(alpha: 0.36)
        ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, 60 * scale),
    );
    canvas.drawOval(
      Rect.fromLTWH(-70 * scale, 90 * scale, 230 * scale, 200 * scale),
      Paint()
        ..color = MealoraColors.accent.withValues(alpha: 0.25)
        ..maskFilter = ui.MaskFilter.blur(ui.BlurStyle.normal, 70 * scale),
    );
  }

  @override
  bool shouldRepaint(_HistoryHeroGlowPainter oldDelegate) => false;
}

/// Kalender riwayat lanjutan mengikuti `18 · Riwayat harian`.
class HistoryCalendarScreen extends ConsumerWidget {
  const HistoryCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = AppText.of(context);
    final today = ref.watch(clockProvider).today();
    final date = DateTime(today.year, today.month, today.day);

    return MealoraBlobBackdrop(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          MealoraSpacing.programHeroGutter,
          MealoraSpacing.xl,
          MealoraSpacing.programHeroGutter,
          MealoraSpacing.navigationContentClearance,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              text.historyContextLabel,
              style: MealoraTypography.eyebrow.copyWith(
                color: MealoraColors.primaryDeep,
              ),
            ),
            const SizedBox(height: MealoraSpacing.xxs),
            Text(text.historyPageTitle, style: MealoraTypography.title),
            const SizedBox(height: MealoraSpacing.xxs),
            Text(text.historyPageSubtitle, style: MealoraTypography.subtitle),
            const SizedBox(height: MealoraSpacing.lg),
            _CalendarCard(selected: date),
            const SizedBox(height: MealoraSpacing.lg),
            Text(
              DateFormat('d MMM · EEEE', 'id_ID').format(date),
              style: MealoraTypography.sectionTitle,
            ),
            const SizedBox(height: MealoraSpacing.sm),
            MealoraEmptyState(
              title: text.historyEmptyTitle,
              body: text.historyEmptyBody,
              icon: Icons.calendar_today_outlined,
            ),
          ],
        ),
      ),
    );
  }
}

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({required this.selected});
  final DateTime selected;

  @override
  Widget build(BuildContext context) {
    final first = DateTime(selected.year, selected.month);
    final dayCount = DateTime(selected.year, selected.month + 1, 0).day;
    final leading = first.weekday - DateTime.monday;
    final cells = <int?>[
      ...List<int?>.filled(leading, null),
      ...List<int>.generate(dayCount, (i) => i + 1),
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }

    return MealoraCard(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.chevron_left_rounded,
                color: MealoraColors.muted,
              ),
              Expanded(
                child: Text(
                  DateFormat('MMMM y', 'id_ID').format(selected),
                  textAlign: TextAlign.center,
                  style: MealoraTypography.bodyEmphasis,
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: MealoraColors.muted,
              ),
            ],
          ),
          const SizedBox(height: MealoraSpacing.sm),
          Row(
            children: <Widget>[
              for (final day in const <String>[
                'S',
                'S',
                'R',
                'K',
                'J',
                'S',
                'M',
              ])
                Expanded(
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: MealoraTypography.caption,
                  ),
                ),
            ],
          ),
          const SizedBox(height: MealoraSpacing.xs),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisExtent: 34,
            ),
            itemCount: cells.length,
            itemBuilder: (context, index) {
              final day = cells[index];
              final selectedDay = day == selected.day;
              return Container(
                alignment: Alignment.center,
                margin: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: selectedDay
                      ? MealoraColors.primary
                      : MealoraColors.transparent,
                  borderRadius: BorderRadius.circular(MealoraRadius.chip),
                ),
                child: day == null
                    ? null
                    : Text(
                        '$day',
                        style: MealoraTypography.caption.copyWith(
                          color: selectedDay
                              ? MealoraColors.onPrimary
                              : MealoraColors.muted,
                        ),
                      ),
              );
            },
          ),
        ],
      ),
    );
  }
}
