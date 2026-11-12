import 'dart:ui' as ui;

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
import 'package:mealora/domain/diary/daily_nutrition_total.dart';
import 'package:mealora/domain/diary/meal_entry.dart';
import 'package:mealora/domain/food/meal_time.dart';
import 'package:mealora/domain/food/nutrition_profile.dart';
import 'package:mealora/domain/food_photo_input/photo_draft.dart';
import 'package:mealora/domain/nutrition/activity_level.dart';
import 'package:mealora/domain/program/program_code.dart';
import 'package:mealora/domain/program/program_target_proposal.dart';
import 'package:mealora/domain/program/user_program.dart';
import 'package:mealora/features/diary/diary_format.dart';
import 'package:mealora/features/diary/diary_providers.dart';
import 'package:mealora/features/diary/food_photo_review_screen.dart';
import 'package:mealora/features/share/daily_summary_share_card.dart';
import 'package:mealora/features/share/share_preview_screen.dart';
import 'package:mealora/features/shell/destinations.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// Ruang `01 · Hari ini` (task 8.1/8.2/8.6/8.7): energi tercatat, target bila
/// ada, sisa perkiraan, kemajuan makro, dan daftar waktu makan — tetap hidup
/// tanpa program berjalan (spec daily-dashboard, "Keadaan tanpa target").
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = AppText.of(context);
    final activeProgram = ref.watch(activeProgramProvider);
    final profile = ref.watch(currentProfileProvider).valueOrNull;
    final today = ref.watch(clockProvider).today();
    final dailyTotal = ref.watch(dailyNutritionTotalProvider(today));
    final entries = ref.watch(diaryEntriesProvider(today));
    final pendingDraft = ref.watch(pendingPhotoDraftProvider).valueOrNull;
    final name = profile?.nickname?.trim().isNotEmpty == true
        ? profile!.nickname!.trim()
        : text.todayDefaultName;

    if (profile == null) {
      return const SizedBox.shrink();
    }

    return activeProgram.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
      data: (program) => _TodayBody(
        text: text,
        program: program,
        name: name,
        today: today,
        activityLevel: profile.activityLevel,
        dailyTotal: dailyTotal.valueOrNull ?? DailyNutritionTotal.empty,
        entries: entries.valueOrNull ?? const <MealEntry>[],
        pendingDraft: pendingDraft,
        onProgramTap: () => ref
            .read(selectedDestinationProvider.notifier)
            .select(MealoraDestination.program),
      ),
    );
  }
}

class _TodayBody extends StatelessWidget {
  const _TodayBody({
    required this.text,
    required this.program,
    required this.name,
    required this.today,
    required this.activityLevel,
    required this.dailyTotal,
    required this.entries,
    required this.pendingDraft,
    required this.onProgramTap,
  });

  final AppText text;
  final UserProgram? program;
  final String name;
  final LocalDate today;
  final ActivityLevel? activityLevel;
  final DailyNutritionTotal dailyTotal;
  final List<MealEntry> entries;

  /// Draf foto makanan belum selesai (change 011, task 3.4) — `null` bila
  /// tidak ada. Bukan bagian dari rancangan `01` di `mealora-v2.pen` (belum
  /// ada layar pemulihan draf di sana); dipakai ulang `MealoraNoteCard`
  /// yang sudah ada alih-alih merancang komponen baru, konsisten dengan
  /// bahasa visual yang berlaku.
  final PhotoDraft? pendingDraft;

  /// Kartu "Program aktif" membuka tab Program.
  final VoidCallback onProgramTap;

  @override
  Widget build(BuildContext context) {
    final proposal = program?.proposal;
    final programName = program == null
        ? null
        : _programName(text, program!.programCode);
    final energyTarget = proposal?.energyTarget;
    final showsEnergyTarget = proposal?.showsEnergyTarget ?? false;
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    // Frame Pen memakai tinggi hero 268 px dari tepi layar, termasuk status
    // bar 24 px. AppShell sudah menambahkan SafeArea, jadi tinggi konten hero
    // harus dikurangi inset tersebut agar kartu tetap mulai di y=232.
    final heroHeight =
        (MealoraSpacing.mainHeroHeight + (textScale - 1).clamp(0, 1) * 220)
            .toDouble();

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
                  padding: const EdgeInsets.fromLTRB(24, 44, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  text.todayGreeting(name),
                                  style: MealoraTypography.title.copyWith(
                                    color: MealoraColors.onPrimary,
                                  ),
                                ),
                                const SizedBox(height: MealoraSpacing.xxs),
                                Text(
                                  IdFormat.longDate(today),
                                  style: MealoraTypography.subtitle.copyWith(
                                    color: MealoraColors.onPrimaryMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(
                              MealoraRadius.iconField,
                            ),
                            child: Image.asset(
                              'assets/brand/mealora-app-icon-1024.png',
                              width: 40,
                              height: 40,
                            ),
                          ),
                          const SizedBox(width: 10),
                          _ShareSummaryButton(
                            data: dailyTotal.hasAnyEntries
                                ? DailySummaryShareData(
                                    date: today,
                                    consumedKcal:
                                        dailyTotal.nutrition.energy?.kcal ?? 0,
                                    targetKcal: showsEnergyTarget
                                        ? energyTarget?.kcal
                                        : null,
                                    proteinG: dailyTotal.nutrition.proteinG,
                                    carbohydrateG:
                                        dailyTotal.nutrition.carbohydrateG,
                                    fatG: dailyTotal.nutrition.fatG,
                                  )
                                : null,
                          ),
                        ],
                      ),
                      const SizedBox(height: MealoraSpacing.lg),
                      if (programName != null)
                        Semantics(
                          label: text.todayProgramChipSemantics(programName),
                          button: true,
                          onTap: onProgramTap,
                          child: GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: onProgramTap,
                            excludeFromSemantics: true,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                MealoraRadius.chip,
                              ),
                              child: BackdropFilter(
                                filter: ui.ImageFilter.blur(
                                  sigmaX: 16,
                                  sigmaY: 16,
                                ),
                                child: Container(
                                  height: 52,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: MealoraColors.glassOnHero,
                                    borderRadius: BorderRadius.circular(
                                      MealoraRadius.chip,
                                    ),
                                    border: Border.all(
                                      color: MealoraColors.welcomeCardBorder,
                                    ),
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      Container(
                                        width: 30,
                                        height: 30,
                                        decoration: const BoxDecoration(
                                          color:
                                              MealoraColors.glassOnHeroStrong,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.energy_savings_leaf_outlined,
                                          size: 16,
                                          color: MealoraColors.onPrimaryMuted,
                                        ),
                                      ),
                                      const SizedBox(width: MealoraSpacing.sm),
                                      Expanded(
                                        child: Row(
                                          children: <Widget>[
                                            Text(
                                              text.todayProgramActiveLabel,
                                              style: MealoraTypography.chipLabel
                                                  .copyWith(
                                                    color:
                                                        MealoraColors.onPrimary,
                                                  ),
                                            ),
                                            Text(
                                              ' · ',
                                              style: MealoraTypography.chipLabel
                                                  .copyWith(
                                                    color:
                                                        MealoraColors.onPrimary,
                                                  ),
                                            ),
                                            Flexible(
                                              child: Text(
                                                programName,
                                                overflow: TextOverflow.ellipsis,
                                                style: MealoraTypography
                                                    .chipLabel
                                                    .copyWith(
                                                      color: MealoraColors
                                                          .onPrimary,
                                                    ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons.chevron_right_rounded,
                                        color: MealoraColors.onPrimaryMuted,
                                      ),
                                    ],
                                  ),
                                ),
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _SummaryCard(
                  dailyTotal: dailyTotal,
                  showsEnergyTarget: showsEnergyTarget,
                  energyTargetKcal: energyTarget?.kcal,
                  activityLevel: activityLevel,
                  text: text,
                ),
                if (pendingDraft != null) ...<Widget>[
                  const SizedBox(height: MealoraSpacing.md),
                  _PendingDraftBanner(draft: pendingDraft!, text: text),
                ],
                if (proposal?.macros != null) ...<Widget>[
                  const SizedBox(height: MealoraSpacing.md),
                  _MacroCard(
                    dailyTotal: dailyTotal,
                    macros: proposal!.macros!,
                    text: text,
                  ),
                ],
                const SizedBox(height: MealoraSpacing.lg),
                Text(
                  text.todayMealsHeading,
                  style: MealoraTypography.sectionTitle,
                ),
                if (dailyTotal.hasAnyEntries) ...<Widget>[
                  const SizedBox(height: MealoraSpacing.xxs),
                  Text(
                    text.todayMealsCountFormat(dailyTotal.loggedMealsCount),
                    style: MealoraTypography.bodySmall,
                  ),
                ],
                const SizedBox(height: MealoraSpacing.md),
                _MealListCard(entries: entries, text: text),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _programName(AppText text, ProgramCode code) => switch (code) {
    ProgramCode.healthyEating => text.onboardingProgramHealthyName,
    ProgramCode.weightLoss => text.onboardingProgramWeightLossName,
    ProgramCode.weightGain => text.onboardingProgramWeightGainName,
    ProgramCode.maintenance => text.onboardingProgramMaintenanceName,
  };
}

/// Tawaran melanjutkan draf foto makanan (change 011, task 3.4) — muncul
/// begitu `pendingPhotoDraftProvider` menemukan draf yang belum dibuang,
/// termasuk tepat setelah aplikasi dibuka kembali usai ditutup paksa di
/// tengah peninjauan: penyimpanan draf sudah bertahan (Design D6), ruang
/// utama inilah titik yang memulihkannya ke navigasi.
/// Tombol Bagikan ringkasan di header (change 014, task 2.2, rancangan
/// `55`/`56`). [data] `null` berarti belum ada catatan hari ini: tombol
/// tampil nonaktif, dan mengetuknya menjelaskan alasannya alih-alih diam.
class _ShareSummaryButton extends StatelessWidget {
  const _ShareSummaryButton({required this.data});

  final DailySummaryShareData? data;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final enabled = data != null;
    return Semantics(
      button: true,
      enabled: enabled,
      label: text.shareSummarySemantics,
      hint: enabled ? null : text.shareSummaryDisabledReason,
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          key: const ValueKey<String>('today-share-summary'),
          borderRadius: BorderRadius.circular(MealoraRadius.iconField),
          onTap: () {
            if (data == null) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(content: Text(text.shareSummaryDisabledReason)),
                );
              return;
            }
            Navigator.of(context).push<void>(
              MaterialPageRoute<void>(
                builder: (_) => SharePreviewScreen(
                  card: DailySummaryShareCard(data: data!),
                  caption: text.shareSummaryPreviewCaption,
                ),
              ),
            );
          },
          child: ExcludeSemantics(
            child: Opacity(
              opacity: enabled ? 1 : 0.5,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: MealoraColors.glassOnHero,
                  borderRadius: BorderRadius.circular(MealoraRadius.iconField),
                  border: Border.all(color: MealoraColors.welcomeCardBorder),
                ),
                child: const Icon(
                  Icons.ios_share,
                  size: 20,
                  color: MealoraColors.onPrimary,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PendingDraftBanner extends StatelessWidget {
  const _PendingDraftBanner({required this.draft, required this.text});

  final PhotoDraft draft;
  final AppText text;

  @override
  Widget build(BuildContext context) {
    return MealoraNoteCard(
      icon: Icons.restaurant_outlined,
      title: text.todayPendingDraftTitle,
      body: text.todayPendingDraftBody,
      background: MealoraColors.iconFieldAmber,
      foreground: MealoraColors.amberText,
      semanticsLabel: text.todayPendingDraftSemantics,
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => FoodPhotoReviewScreen(draft: draft),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.dailyTotal,
    required this.showsEnergyTarget,
    required this.energyTargetKcal,
    required this.activityLevel,
    required this.text,
  });

  final DailyNutritionTotal dailyTotal;
  final bool showsEnergyTarget;
  final double? energyTargetKcal;
  final ActivityLevel? activityLevel;
  final AppText text;

  @override
  Widget build(BuildContext context) {
    final consumed = dailyTotal.nutrition.energy;
    final displayedConsumedKcal = consumed?.kcal ?? 0;
    final hasTarget = showsEnergyTarget && energyTargetKcal != null;
    final remainingKcal = hasTarget
        ? (energyTargetKcal! - displayedConsumedKcal)
              .clamp(0, double.infinity)
              .toDouble()
        : null;
    final excessKcal = hasTarget
        ? displayedConsumedKcal - energyTargetKcal!
        : null;
    final largeText = MediaQuery.textScalerOf(context).scale(1) > 1.3;
    final ring = _CalorieRing(
      consumedKcal: displayedConsumedKcal,
      targetKcal: hasTarget ? energyTargetKcal : null,
    );
    final details = Padding(
      padding: EdgeInsets.only(top: largeText ? 0 : 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            text.todayEstimateLabel.toUpperCase(),
            style: MealoraTypography.eyebrow.copyWith(
              color: MealoraColors.primaryDeep,
            ),
          ),
          const SizedBox(height: MealoraSpacing.xxs),
          Text(text.todayRemainingLabel, style: MealoraTypography.caption),
          Text(
            remainingKcal == null
                ? text.reviewNoEnergyTargetNote
                : '${IdFormat.integer(remainingKcal)} ${text.unitKilocalorie}',
            maxLines: largeText ? 3 : 1,
            overflow: TextOverflow.ellipsis,
            style: remainingKcal == null
                ? MealoraTypography.bodySmall
                : MealoraTypography.headline.copyWith(
                    color: MealoraColors.primaryDeep,
                  ),
          ),
          const Spacer(),
          _SummaryStatRow(
            icon: Icons.local_fire_department_outlined,
            iconColor: MealoraColors.accent,
            label: text.todayLoggedLabel,
            value:
                '${IdFormat.integer(displayedConsumedKcal)} ${text.unitKilocalorie}',
            largeText: largeText,
          ),
          const SizedBox(height: MealoraSpacing.xs),
          _SummaryStatRow(
            icon: Icons.directions_walk_rounded,
            iconColor: MealoraColors.info,
            label: text.todayActivityLabel,
            value: _activityLabel(text, activityLevel),
            largeText: largeText,
          ),
          if (excessKcal != null && excessKcal > 0)
            Semantics(
              label: text.todayExcessOverTarget(IdFormat.integer(excessKcal)),
              child: const SizedBox.shrink(),
            ),
        ],
      ),
    );

    return SizedBox(
      height: largeText ? 640 : 192,
      child: MealoraCard(
        radius: MealoraRadius.cardLarge,
        padding: const EdgeInsets.all(20),
        child: largeText
            ? Column(
                children: <Widget>[
                  ring,
                  const SizedBox(height: 18),
                  Expanded(child: details),
                ],
              )
            : Row(
                children: <Widget>[
                  ring,
                  const SizedBox(width: 18),
                  Expanded(child: details),
                ],
              ),
      ),
    );
  }

  String _activityLabel(AppText text, ActivityLevel? level) => switch (level) {
    ActivityLevel.sedentary => text.todayActivityLight,
    ActivityLevel.moderatelyActive => text.todayActivityModerate,
    ActivityLevel.veryActive => text.todayActivityHigh,
    null => '–',
  };
}

class _SummaryStatRow extends StatelessWidget {
  const _SummaryStatRow({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.largeText,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final bool largeText;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 145;
        final horizontalPadding = compact ? 6.0 : 10.0;
        final iconGap = compact ? MealoraSpacing.xxs : MealoraSpacing.xs;

        return Container(
          height: largeText ? 64 : 32,
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          decoration: BoxDecoration(
            color: MealoraColors.glassSoft,
            borderRadius: BorderRadius.circular(MealoraRadius.compactIconField),
          ),
          child: Row(
            children: <Widget>[
              Icon(icon, size: compact ? 12 : 14, color: iconColor),
              SizedBox(width: iconGap),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: MealoraTypography.caption,
                ),
              ),
              const SizedBox(width: MealoraSpacing.xxs),
              Flexible(
                child: Text(
                  value,
                  textAlign: TextAlign.end,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.ellipsis,
                  style: MealoraTypography.caption.copyWith(
                    color: MealoraColors.ink,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MacroCard extends StatelessWidget {
  const _MacroCard({
    required this.dailyTotal,
    required this.macros,
    required this.text,
  });

  final DailyNutritionTotal dailyTotal;
  final MacronutrientTargets macros;
  final AppText text;

  @override
  Widget build(BuildContext context) {
    return MealoraCard(
      radius: MealoraRadius.choiceCard,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _MacroColumn(
              label: text.nutrientProtein,
              consumed: dailyTotal.nutrition.proteinG,
              target: macros.proteinGrams.toDouble(),
              color: MealoraColors.primaryBright,
              text: text,
            ),
          ),
          const SizedBox(width: MealoraSpacing.md),
          Expanded(
            child: _MacroColumn(
              label: text.nutrientCarbohydrate,
              consumed: dailyTotal.nutrition.carbohydrateG,
              target: macros.carbohydrateGrams.toDouble(),
              color: MealoraColors.accent,
              text: text,
            ),
          ),
          const SizedBox(width: MealoraSpacing.md),
          Expanded(
            child: _MacroColumn(
              label: text.nutrientFat,
              consumed: dailyTotal.nutrition.fatG,
              target: macros.fatGrams.toDouble(),
              color: MealoraColors.peach,
              text: text,
            ),
          ),
        ],
      ),
    );
  }
}

class _MacroColumn extends StatelessWidget {
  const _MacroColumn({
    required this.label,
    required this.consumed,
    required this.target,
    required this.color,
    required this.text,
  });

  final String label;
  final double? consumed;
  final double target;
  final Color color;
  final AppText text;

  @override
  Widget build(BuildContext context) {
    final ratio = consumed == null
        ? 0.0
        : (consumed! / target).clamp(0, 1).toDouble();
    final consumedText = consumed == null
        ? text.nutrientValueUnknown
        : IdFormat.decimal(consumed!);
    final valueText =
        '$consumedText / ${IdFormat.decimal(target, decimals: 0)} ${text.unitGram}';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: MealoraTypography.label),
        const SizedBox(height: MealoraSpacing.xxs),
        SizedBox(
          width: double.infinity,
          height: 20,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              valueText,
              maxLines: 1,
              softWrap: false,
              style: MealoraTypography.macroValue,
            ),
          ),
        ),
        const SizedBox(height: MealoraSpacing.xxs),
        ClipRRect(
          borderRadius: BorderRadius.circular(MealoraRadius.track),
          child: LinearProgressIndicator(
            value: ratio,
            minHeight: 7,
            backgroundColor: MealoraColors.track,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

class _MealListCard extends StatelessWidget {
  const _MealListCard({required this.entries, required this.text});

  final List<MealEntry> entries;
  final AppText text;

  @override
  Widget build(BuildContext context) {
    return MealoraCard(
      radius: MealoraRadius.choiceCard,
      padding: const EdgeInsets.symmetric(horizontal: MealoraSpacing.md),
      child: Column(
        children: <Widget>[
          for (var i = 0; i < MealTime.values.length; i++) ...<Widget>[
            if (i > 0) const Divider(height: 1),
            _MealRow(
              mealTime: MealTime.values[i],
              entries: entries
                  .where((e) => e.mealTime == MealTime.values[i])
                  .toList(growable: false),
              text: text,
            ),
          ],
        ],
      ),
    );
  }
}

class _MealRow extends StatelessWidget {
  const _MealRow({
    required this.mealTime,
    required this.entries,
    required this.text,
  });

  final MealTime mealTime;
  final List<MealEntry> entries;
  final AppText text;

  @override
  Widget build(BuildContext context) {
    final icon = switch (mealTime) {
      MealTime.breakfast => Icons.wb_twilight_rounded,
      MealTime.lunch => Icons.wb_sunny_outlined,
      MealTime.snack => Icons.cookie_outlined,
      MealTime.dinner => Icons.dark_mode_outlined,
    };
    final iconForeground = switch (mealTime) {
      MealTime.breakfast => MealoraColors.accent,
      MealTime.lunch => MealoraColors.primaryBright,
      MealTime.snack => MealoraColors.peach,
      MealTime.dinner => MealoraColors.info,
    };
    final mealNutrition = NutritionProfile.sumAll(
      entries.map((e) => e.totalNutrition),
    );
    final kcal = entries.isEmpty
        ? text.todayMealNotLogged
        : DiaryFormat.kcal(mealNutrition.energy, text);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: <Widget>[
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: MealoraColors.glassStrong,
              borderRadius: BorderRadius.circular(
                MealoraRadius.compactIconField,
              ),
            ),
            child: Icon(icon, size: 14, color: iconForeground),
          ),
          const SizedBox(width: MealoraSpacing.sm),
          Expanded(
            child: Text(
              DiaryFormat.mealTimeLabel(mealTime, text),
              style: MealoraTypography.bodyEmphasis,
            ),
          ),
          Flexible(
            child: Text(
              kcal,
              textAlign: TextAlign.end,
              style: MealoraTypography.bodySmall.copyWith(
                color: entries.isEmpty
                    ? MealoraColors.muted
                    : MealoraColors.ink,
                fontWeight: entries.isEmpty ? null : FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CalorieRing extends StatelessWidget {
  const _CalorieRing({required this.consumedKcal, required this.targetKcal});

  final double? consumedKcal;
  final double? targetKcal;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final textScale = MediaQuery.textScalerOf(
      context,
    ).scale(1).clamp(1, 1.6).toDouble();
    final ratio =
        (consumedKcal != null && targetKcal != null && targetKcal! > 0)
        ? (consumedKcal! / targetKcal!).clamp(0, 1).toDouble()
        : null;
    final dimension = 128 * textScale;

    return SizedBox(
      width: dimension,
      height: dimension,
      child: CustomPaint(
        painter: _RingPainter(ratio: ratio),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(MealoraSpacing.xs),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  consumedKcal == null
                      ? text.todayConsumedUnknown
                      : IdFormat.integer(consumedKcal!),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  style: MealoraTypography.calorieRingValue,
                ),
                if (targetKcal != null) ...<Widget>[
                  const SizedBox(height: MealoraSpacing.xxs),
                  Text(
                    'dari ${IdFormat.integer(targetKcal!)} ${text.unitKilocalorie}',
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    style: MealoraTypography.caption.copyWith(
                      color: MealoraColors.muted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  const _RingPainter({required this.ratio});

  final double? ratio;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 8;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = MealoraColors.track
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12,
    );
    if (ratio != null) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -1.5708,
        6.28319 * ratio!,
        false,
        Paint()
          ..color = MealoraColors.primaryBright
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = 12,
      );
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) => oldDelegate.ratio != ratio;
}
