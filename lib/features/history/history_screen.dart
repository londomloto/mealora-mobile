import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/format/id_formatters.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/domain/diary/daily_nutrition_total.dart';
import 'package:mealora/domain/diary/meal_entry.dart';
import 'package:mealora/domain/food/meal_time.dart';
import 'package:mealora/domain/food/nutrition_profile.dart';
import 'package:mealora/domain/preferences/week_start.dart';
import 'package:mealora/features/diary/add_food_sheet.dart';
import 'package:mealora/features/diary/diary_format.dart';
import 'package:mealora/features/diary/diary_providers.dart';
import 'package:mealora/features/diary/edit_entry_screen.dart';
import 'package:mealora/features/history/history_providers.dart';
import 'package:mealora/features/weight/weight_providers.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// Pintu masuk tab Riwayat: `16 · Buku harian hari ini`, dengan keadaan hari
/// tanpa catatan (`40`) digabung sebagai salah satu isi badan layar ini —
/// chrome (hero, eyebrow, pemilih tanggal) tetap sama di kedua keadaan,
/// hanya badan yang berganti menurut ada/tidaknya catatan (task 7.1/8.5).
class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  LocalDate? _selectedDate;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final today = ref.watch(clockProvider).today();
    final selectedDate = _selectedDate ?? today;
    final isToday = selectedDate == today;
    final date = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    // Frame Pen setinggi 232 px sudah termasuk status bar 24 px. AppShell
    // membungkus layar dengan SafeArea, jadi area hero internal adalah 208 px.
    final heroHeight =
        (MealoraSpacing.mainHeroHeight + (textScale - 1).clamp(0, 1) * 220)
            .toDouble();
    final switcherHeight = (48 + (textScale - 1).clamp(0, 1) * 20).toDouble();

    final dailyTotal = ref.watch(dailyNutritionTotalProvider(selectedDate));
    final entries = ref.watch(diaryEntriesProvider(selectedDate));
    final activeProgram = ref.watch(activeProgramProvider).valueOrNull;
    final energyTarget = activeProgram?.proposal.energyTarget;

    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        bottom: MealoraSpacing.navigationContentClearance,
      ),
      child: Stack(
        children: <Widget>[
          MealoraMainHero(
            height: heroHeight,
            child: Stack(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        isToday
                            ? text.diaryEyebrowToday
                            : IdFormat.shortDate(selectedDate).toUpperCase(),
                        style: MealoraTypography.eyebrow.copyWith(
                          color: MealoraColors.onPrimaryEyebrow,
                        ),
                      ),
                      const SizedBox(height: MealoraSpacing.xxs),
                      Text(
                        text.diaryTitle,
                        style: MealoraTypography.title.copyWith(
                          color: MealoraColors.onPrimary,
                        ),
                      ),
                      const SizedBox(height: MealoraSpacing.xxs),
                      Text(
                        '${DateFormat('EEEE, d MMMM y', 'id_ID').format(date)} · ${text.diaryLocalNote}',
                        style: MealoraTypography.subtitle.copyWith(
                          color: MealoraColors.onPrimaryMuted,
                        ),
                      ),
                      const SizedBox(height: MealoraSpacing.md),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          MealoraRadius.choiceCard,
                        ),
                        child: BackdropFilter(
                          filter: ui.ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                          child: Container(
                            height: switcherHeight,
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            decoration: BoxDecoration(
                              color: MealoraColors.glassOnHero,
                              borderRadius: BorderRadius.circular(
                                MealoraRadius.choiceCard,
                              ),
                              border: Border.all(
                                color: MealoraColors.welcomeCardBorder,
                              ),
                            ),
                            child: Row(
                              children: <Widget>[
                                Semantics(
                                  button: true,
                                  label: text.diaryPreviousDaySemantics,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(
                                      MealoraRadius.chip,
                                    ),
                                    onTap: () => setState(
                                      () => _selectedDate = _shiftDate(
                                        selectedDate,
                                        -1,
                                      ),
                                    ),
                                    child: const Padding(
                                      padding: EdgeInsets.all(
                                        MealoraSpacing.sm,
                                      ),
                                      child: Icon(
                                        Icons.chevron_left_rounded,
                                        color: MealoraColors.onPrimary,
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: InkWell(
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) =>
                                            const HistoryCalendarScreen(),
                                      ),
                                    ),
                                    child: Text(
                                      DateFormat(
                                        'EEEE, d MMMM',
                                        'id_ID',
                                      ).format(date),
                                      textAlign: TextAlign.center,
                                      style:
                                          MealoraTypography.dateNavigatorTitle,
                                    ),
                                  ),
                                ),
                                Semantics(
                                  button: true,
                                  label: text.diaryNextDaySemantics,
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(
                                      MealoraRadius.chip,
                                    ),
                                    onTap: isToday
                                        ? null
                                        : () => setState(
                                            () => _selectedDate = _shiftDate(
                                              selectedDate,
                                              1,
                                            ),
                                          ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(
                                        MealoraSpacing.sm,
                                      ),
                                      child: Icon(
                                        Icons.chevron_right_rounded,
                                        color: isToday
                                            ? MealoraColors.onPrimaryFaint
                                            : MealoraColors.onPrimary,
                                      ),
                                    ),
                                  ),
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
            padding: EdgeInsets.fromLTRB(
              22,
              heroHeight - MealoraSpacing.mainHeroOverlap,
              22,
              0,
            ),
            child: dailyTotal.when(
              loading: () => const SizedBox.shrink(),
              error: (_, _) => const SizedBox.shrink(),
              data: (total) => total.hasAnyEntries
                  ? _DiaryBody(
                      total: total,
                      entries: entries.valueOrNull ?? const <MealEntry>[],
                      energyTargetKcal: energyTarget?.kcal,
                      text: text,
                    )
                  : _UnknownDiaryBody(text: text),
            ),
          ),
        ],
      ),
    );
  }

  LocalDate _shiftDate(LocalDate date, int days) {
    final shifted = DateTime(
      date.year,
      date.month,
      date.day,
    ).add(Duration(days: days));
    return LocalDate(shifted.year, shifted.month, shifted.day);
  }
}

class _DiaryBody extends StatefulWidget {
  const _DiaryBody({
    required this.total,
    required this.entries,
    required this.energyTargetKcal,
    required this.text,
    this.eyebrowLabel,
  });

  final DailyNutritionTotal total;
  final List<MealEntry> entries;
  final double? energyTargetKcal;
  final AppText text;

  /// Label eyebrow di atas angka energi — `null` memakai
  /// [AppText.diaryRecordedTodayLabel] (layar hari ini). Ruang Riwayat
  /// (`18`) mengisi label netral sendiri karena tanggalnya sudah disebut
  /// di judul tepat di atas kartu ini (task 5.4 — bukan komponen kedua,
  /// cuma label yang disesuaikan).
  final String? eyebrowLabel;

  @override
  State<_DiaryBody> createState() => _DiaryBodyState();
}

class _DiaryBodyState extends State<_DiaryBody> {
  MealTime? _expanded;

  @override
  Widget build(BuildContext context) {
    final text = widget.text;
    final consumed = widget.total.nutrition.energy;
    final percent = consumed != null && widget.energyTargetKcal != null
        ? (consumed.kcal / widget.energyTargetKcal! * 100).round()
        : null;

    return Column(
      children: <Widget>[
        ConstrainedBox(
          // Tinggi minimum, bukan tetap: kalimat target bisa terbungkus dua
          // baris (mis. tanpa program) atau membesar pada skala teks besar.
          constraints: const BoxConstraints(minHeight: 108),
          child: MealoraCard(
            padding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: MealoraSpacing.md,
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        widget.eyebrowLabel ?? text.diaryRecordedTodayLabel,
                        style: MealoraTypography.eyebrow,
                      ),
                      const SizedBox(height: MealoraSpacing.xs),
                      Text(
                        DiaryFormat.kcal(consumed, text),
                        style: MealoraTypography.display,
                      ),
                      const SizedBox(height: MealoraSpacing.xxs),
                      Text(
                        widget.energyTargetKcal == null
                            ? text.reviewNoEnergyTargetNote
                            : text.diaryTargetLabel(
                                IdFormat.integer(widget.energyTargetKcal!),
                              ),
                        style: MealoraTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (percent != null)
                  Container(
                    width: 68,
                    height: 68,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: MealoraColors.softGreen,
                      shape: BoxShape.circle,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          '$percent%',
                          style: MealoraTypography.bodyEmphasis.copyWith(
                            color: MealoraColors.primary,
                          ),
                        ),
                        Text(
                          text.diaryTargetPercentCaption,
                          style: MealoraTypography.caption,
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: MealoraSpacing.md),
        for (final mealTime in MealTime.values) ...<Widget>[
          _MealSection(
            mealTime: mealTime,
            entries: widget.entries
                .where((e) => e.mealTime == mealTime)
                .toList(growable: false),
            expanded: _expanded == mealTime,
            onToggle: () => setState(
              () => _expanded = _expanded == mealTime ? null : mealTime,
            ),
            text: text,
          ),
          const SizedBox(height: MealoraSpacing.sm),
        ],
      ],
    );
  }
}

class _MealSection extends StatelessWidget {
  const _MealSection({
    required this.mealTime,
    required this.entries,
    required this.expanded,
    required this.onToggle,
    required this.text,
  });

  final MealTime mealTime;
  final List<MealEntry> entries;
  final bool expanded;
  final VoidCallback onToggle;
  final AppText text;

  @override
  Widget build(BuildContext context) {
    final hasEntries = entries.isNotEmpty;
    final mealNutrition = NutritionProfile.sumAll(
      entries.map((e) => e.totalNutrition),
    );
    final totalKcal = hasEntries
        ? DiaryFormat.kcal(mealNutrition.energy, text)
        : text.todayMealNotLogged;
    final itemNames = entries.map((e) => e.foodNameSnapshot).join(', ');
    final icon = switch (mealTime) {
      MealTime.breakfast => Icons.wb_twilight_rounded,
      MealTime.lunch => Icons.wb_sunny_outlined,
      MealTime.snack => Icons.cookie_outlined,
      MealTime.dinner => Icons.dark_mode_outlined,
    };
    final iconBackground = switch (mealTime) {
      MealTime.breakfast => MealoraColors.iconFieldAmber,
      MealTime.lunch => MealoraColors.iconFieldGreen,
      MealTime.snack => MealoraColors.iconFieldCoral,
      MealTime.dinner => MealoraColors.iconFieldBlue,
    };
    final iconForeground = switch (mealTime) {
      MealTime.breakfast => MealoraColors.accent,
      MealTime.lunch => MealoraColors.primaryBright,
      MealTime.snack => MealoraColors.peach,
      MealTime.dinner => MealoraColors.info,
    };

    return MealoraCard(
      padding: const EdgeInsets.symmetric(
        horizontal: MealoraSpacing.md,
        vertical: 19,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          InkWell(
            onTap: hasEntries ? onToggle : null,
            child: Row(
              children: <Widget>[
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: iconBackground,
                    borderRadius: BorderRadius.circular(MealoraRadius.chip),
                  ),
                  child: Icon(icon, color: iconForeground),
                ),
                const SizedBox(width: MealoraSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        DiaryFormat.mealTimeLabel(mealTime, text),
                        style: MealoraTypography.bodyEmphasis,
                      ),
                      if (hasEntries)
                        Text(itemNames, style: MealoraTypography.caption),
                    ],
                  ),
                ),
                Text(
                  totalKcal,
                  style: MealoraTypography.bodyEmphasis.copyWith(
                    color: hasEntries
                        ? MealoraColors.primary
                        : MealoraColors.muted,
                  ),
                ),
              ],
            ),
          ),
          if (expanded && hasEntries) ...<Widget>[
            const Divider(height: MealoraSpacing.lg),
            for (final entry in entries)
              InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => EditEntryScreen(entry: entry),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: MealoraSpacing.xs,
                  ),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              entry.foodNameSnapshot,
                              style: MealoraTypography.bodySmall,
                            ),
                            Text(
                              DiaryFormat.entryAmount(
                                entry.servingLabelSnapshot,
                                entry.quantity,
                              ),
                              style: MealoraTypography.caption,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        DiaryFormat.kcal(entry.totalNutrition.energy, text),
                        style: MealoraTypography.caption,
                      ),
                      const SizedBox(width: MealoraSpacing.xxs),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: MealoraIconSize.inline,
                        color: MealoraColors.affordance,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _UnknownDiaryBody extends StatelessWidget {
  const _UnknownDiaryBody({required this.text, this.date});

  final AppText text;

  /// Tanggal yang akan dicatat bila pengguna menekan aksi mencatat — `null`
  /// berarti hari ini (layar `16`). Ruang Riwayat (`18`, change 008, task
  /// 5.6) mengisi tanggal yang sedang ditinjau supaya mencatat dari hari
  /// lampau tidak diam-diam tercatat ke hari ini.
  final LocalDate? date;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        MealoraEmptyState(
          title: text.diaryUnknownHeading,
          body: text.diaryUnknownBody,
          icon: Icons.edit_note_rounded,
        ),
        const SizedBox(height: MealoraSpacing.md),
        MealoraCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                text.diaryUnknownConsumptionLabel,
                style: MealoraTypography.bodySmall,
              ),
              const SizedBox(height: MealoraSpacing.xxs),
              Text(
                text.diaryUnknownConsumptionValue,
                style: MealoraTypography.headline,
              ),
              const SizedBox(height: MealoraSpacing.xxs),
              Text(
                text.diaryUnknownMacrosNote,
                style: MealoraTypography.caption,
              ),
            ],
          ),
        ),
        const SizedBox(height: MealoraSpacing.lg),
        MealoraPrimaryButton(
          label: text.todayLogFoodAction,
          onPressed: () => showAddFoodSheet(context, date: date),
        ),
      ],
    );
  }
}

/// Kalender riwayat `18 · Riwayat harian` (change 008, design D7).
///
/// Memakai ulang `_DiaryBody`/`_UnknownDiaryBody` persis seperti layar
/// `16` untuk ringkasan tanggal terpilih (design D6) — tidak ada komponen
/// ringkasan kedua, cuma sumber tanggalnya yang berbeda.
class HistoryCalendarScreen extends ConsumerStatefulWidget {
  const HistoryCalendarScreen({this.initialDate, super.key});

  /// Tanggal yang langsung terpilih saat dibuka (mis. dari grafik energi,
  /// change 018). `null` atau tanggal setelah hari ini berarti hari ini.
  final LocalDate? initialDate;

  @override
  ConsumerState<HistoryCalendarScreen> createState() =>
      _HistoryCalendarScreenState();
}

class _HistoryCalendarScreenState extends ConsumerState<HistoryCalendarScreen> {
  HistoryMonth? _displayedMonth;
  LocalDate? _selectedDate;

  @override
  void initState() {
    super.initState();
    final initial = widget.initialDate;
    if (initial != null &&
        initial.compareTo(ref.read(clockProvider).today()) <= 0) {
      _selectedDate = initial;
      _displayedMonth = HistoryMonth.of(initial);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final today = ref.watch(clockProvider).today();
    final selectedDate = _selectedDate ?? today;
    final displayedMonth = _displayedMonth ?? HistoryMonth.of(today);
    final selectedDateTime = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    final dailyTotal = ref.watch(dailyNutritionTotalProvider(selectedDate));
    final entries = ref.watch(diaryEntriesProvider(selectedDate));
    final activeProgram = ref.watch(activeProgramProvider).valueOrNull;
    final energyTarget = activeProgram?.proposal.energyTarget;
    final weightOnDate = ref.watch(weightRecordForDateProvider(selectedDate));

    return Scaffold(
      backgroundColor: MealoraColors.background,
      body: MealoraBlobBackdrop(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              MealoraSpacing.programHeroGutter,
              MealoraSpacing.md,
              MealoraSpacing.programHeroGutter,
              MealoraSpacing.navigationContentClearance,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Semantics(
                      button: true,
                      label: text.onboardingBackSemantics,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        child: const Padding(
                          padding: EdgeInsets.all(MealoraSpacing.xxs),
                          child: Icon(
                            Icons.arrow_back,
                            color: MealoraColors.ink,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        text.historyContextLabel,
                        style: MealoraTypography.eyebrow.copyWith(
                          color: MealoraColors.primaryDeep,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: MealoraSpacing.xxs),
                Text(text.historyPageTitle, style: MealoraTypography.title),
                const SizedBox(height: MealoraSpacing.xxs),
                Text(
                  text.historyPageSubtitle,
                  style: MealoraTypography.subtitle,
                ),
                const SizedBox(height: MealoraSpacing.lg),
                _CalendarCard(
                  month: displayedMonth,
                  selected: selectedDate,
                  today: today,
                  onPreviousMonth: () => setState(
                    () => _displayedMonth = displayedMonth.shift(-1),
                  ),
                  onNextMonth: () =>
                      setState(() => _displayedMonth = displayedMonth.shift(1)),
                  onSelectDate: (date) => setState(() {
                    _selectedDate = date;
                    _displayedMonth = HistoryMonth.of(date);
                  }),
                ),
                const SizedBox(height: MealoraSpacing.lg),
                Text(
                  DateFormat('d MMM · EEEE', 'id_ID').format(selectedDateTime),
                  style: MealoraTypography.sectionTitle,
                ),
                const SizedBox(height: MealoraSpacing.sm),
                weightOnDate.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                  data: (record) => record == null
                      ? const SizedBox.shrink()
                      : Padding(
                          padding: const EdgeInsets.only(
                            bottom: MealoraSpacing.sm,
                          ),
                          child: MealoraCard(
                            child: MealoraIconRow(
                              icon: Icons.monitor_weight_outlined,
                              iconBackground: MealoraColors.noteInfo,
                              iconForeground: MealoraColors.info,
                              title: '${IdFormat.decimal(record.weightKg)} kg',
                              detail: text.historyWeightRecordedLabel,
                            ),
                          ),
                        ),
                ),
                dailyTotal.when(
                  loading: () => const SizedBox.shrink(),
                  error: (_, _) => const SizedBox.shrink(),
                  data: (total) => total.hasAnyEntries
                      ? _DiaryBody(
                          total: total,
                          entries: entries.valueOrNull ?? const <MealEntry>[],
                          energyTargetKcal: energyTarget?.kcal,
                          text: text,
                          eyebrowLabel: text.historyEnergyRecordedLabel,
                        )
                      : _UnknownDiaryBody(text: text, date: selectedDate),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CalendarCard extends ConsumerWidget {
  const _CalendarCard({
    required this.month,
    required this.selected,
    required this.today,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onSelectDate,
  });

  final HistoryMonth month;
  final LocalDate selected;
  final LocalDate today;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<LocalDate> onSelectDate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = AppText.of(context);
    final markersAsync = ref.watch(historyMonthMarkersProvider(month));
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    // Sel kalender tumbuh mengikuti skala teks (task 6.1) — angka tanggal
    // dan titik penanda SHALL TIDAK terpotong pada skala besar.
    final cellExtent = (38 + (textScale - 1).clamp(0, 1) * 32).toDouble();
    final first = DateTime(month.year, month.month);
    final dayCount = DateTime(month.year, month.month + 1, 0).day;
    final weekStart =
        ref.watch(weekStartProvider).valueOrNull ?? WeekStart.defaultValue;
    final leading = weekStart.offsetOf(first.weekday);
    final cells = <LocalDate?>[
      ...List<LocalDate?>.filled(leading, null),
      ...List<LocalDate>.generate(
        dayCount,
        (i) => LocalDate(month.year, month.month, i + 1),
      ),
    ];
    while (cells.length % 7 != 0) {
      cells.add(null);
    }
    final markers = markersAsync.valueOrNull ?? const <String>{};

    return MealoraCard(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Semantics(
                button: true,
                label: text.historyPreviousMonthSemantics,
                child: InkWell(
                  borderRadius: BorderRadius.circular(MealoraRadius.chip),
                  onTap: onPreviousMonth,
                  child: const Padding(
                    padding: EdgeInsets.all(MealoraSpacing.xs),
                    child: Icon(
                      Icons.chevron_left_rounded,
                      color: MealoraColors.muted,
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  DateFormat('MMMM y', 'id_ID').format(first),
                  textAlign: TextAlign.center,
                  style: MealoraTypography.bodyEmphasis,
                ),
              ),
              Semantics(
                button: true,
                label: text.historyNextMonthSemantics,
                child: InkWell(
                  borderRadius: BorderRadius.circular(MealoraRadius.chip),
                  onTap: onNextMonth,
                  child: const Padding(
                    padding: EdgeInsets.all(MealoraSpacing.xs),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: MealoraColors.muted,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: MealoraSpacing.sm),
          Row(
            children: <Widget>[
              for (final day in weekStart.dayLetters)
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
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisExtent: cellExtent,
            ),
            itemCount: cells.length,
            itemBuilder: (context, index) {
              final date = cells[index];
              if (date == null) {
                return const SizedBox.shrink();
              }
              final isSelected = date == selected;
              final isFuture = date.compareTo(today) > 0;
              final hasRecord = markers.contains(date.iso);
              final dateLabel = IdFormat.shortDate(date);
              final semanticsLabel =
                  (hasRecord
                      ? text.historyDayHasRecordSemantics(dateLabel)
                      : text.historyDayNoRecordSemantics(dateLabel)) +
                  (isSelected
                      ? text.historyDaySelectedSuffix
                      : isFuture
                      ? text.historyDayFutureSuffix
                      : '');

              return Semantics(
                button: !isFuture,
                selected: isSelected,
                label: semanticsLabel,
                excludeSemantics: true,
                child: InkWell(
                  borderRadius: BorderRadius.circular(MealoraRadius.chip),
                  onTap: isFuture ? null : () => onSelectDate(date),
                  child: Container(
                    alignment: Alignment.center,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? MealoraColors.primary
                          : MealoraColors.transparent,
                      borderRadius: BorderRadius.circular(MealoraRadius.chip),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          '${date.day}',
                          style: MealoraTypography.caption.copyWith(
                            color: isSelected
                                ? MealoraColors.onPrimary
                                : isFuture
                                ? MealoraColors.selectionIdle
                                : MealoraColors.muted,
                          ),
                        ),
                        const SizedBox(height: 2),
                        SizedBox(
                          width: 4,
                          height: 4,
                          child: hasRecord
                              ? DecoratedBox(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isSelected
                                        ? MealoraColors.onPrimary
                                        : MealoraColors.affordance,
                                  ),
                                )
                              : null,
                        ),
                      ],
                    ),
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
