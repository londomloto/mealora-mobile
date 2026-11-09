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
import 'package:mealora/domain/program/program_code.dart';
import 'package:mealora/domain/program/user_program.dart';
import 'package:mealora/features/shell/app_shell.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// Ruang 01 · Hari ini.
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = AppText.of(context);
    final activeProgram = ref.watch(activeProgramProvider);
    final profile = ref.watch(currentProfileProvider).valueOrNull;
    final today = ref.watch(clockProvider).today();
    final name = profile?.nickname?.trim().isNotEmpty == true
        ? profile!.nickname!.trim()
        : text.todayDefaultName;

    return activeProgram.when(
      loading: () => const SizedBox.shrink(),
      error: (_, _) => _empty(text),
      data: (program) => program == null
          ? _empty(text)
          : _ActiveToday(
              text: text,
              program: program,
              name: name,
              today: today,
            ),
    );
  }

  Widget _empty(AppText text) => MealoraSpacePage(
    title: text.navToday,
    subtitle: text.todaySubtitle,
    child: MealoraEmptyState(
      title: text.todayEmptyTitle,
      body: text.todayEmptyBody,
      icon: Icons.restaurant_menu_outlined,
    ),
  );
}

class _ActiveToday extends StatelessWidget {
  const _ActiveToday({
    required this.text,
    required this.program,
    required this.name,
    required this.today,
  });
  final AppText text;
  final UserProgram program;
  final String name;
  final LocalDate today;

  @override
  Widget build(BuildContext context) {
    final proposal = program.proposal;
    final programName = _programName(text, program.programCode);
    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        bottom: MealoraSpacing.navigationContentClearance,
      ),
      child: Stack(
        children: <Widget>[
          Container(
            width: double.infinity,
            height: 268,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: MealoraColors.heroGradient,
                stops: <double>[0, 0.55, 1],
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
                  child: CustomPaint(painter: _TodayHeroGlowPainter()),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 28, 24, 0),
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
                        ],
                      ),
                      const SizedBox(height: MealoraSpacing.lg),
                      Semantics(
                        label: text.todayProgramChipSemantics(programName),
                        child: Container(
                          height: 52,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: MealoraColors.glassOnHero,
                            borderRadius: BorderRadius.circular(
                              MealoraRadius.chip,
                            ),
                          ),
                          child: Row(
                            children: <Widget>[
                              Container(
                                width: 30,
                                height: 30,
                                decoration: const BoxDecoration(
                                  color: MealoraColors.glassOnHeroStrong,
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
                                            color: MealoraColors.onPrimary,
                                          ),
                                    ),
                                    Text(
                                      ' · ',
                                      style: MealoraTypography.chipLabel
                                          .copyWith(
                                            color: MealoraColors.onPrimary,
                                          ),
                                    ),
                                    Flexible(
                                      child: Text(
                                        programName,
                                        overflow: TextOverflow.ellipsis,
                                        style: MealoraTypography.chipLabel
                                            .copyWith(
                                              color: MealoraColors.onPrimary,
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
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 232, 22, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                MealoraCard(
                  child: Row(
                    children: <Widget>[
                      _UnknownCalorieRing(
                        label: text.todayConsumedUnknown,
                        target:
                            proposal.showsEnergyTarget &&
                                proposal.energyTarget != null
                            ? '${IdFormat.integer(proposal.energyTarget!.kcal)} ${text.unitKilocalorie}'
                            : text.reviewNoEnergyTargetNote,
                      ),
                      const SizedBox(width: MealoraSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              text.todayDailyTargetLabel.toUpperCase(),
                              style: MealoraTypography.eyebrow.copyWith(
                                color: MealoraColors.primaryDeep,
                              ),
                            ),
                            const SizedBox(height: MealoraSpacing.sm),
                            Text(
                              proposal.showsEnergyTarget &&
                                      proposal.energyTarget != null
                                  ? '${IdFormat.integer(proposal.energyTarget!.kcal)} ${text.unitKilocalorie}'
                                  : text.reviewNoEnergyTargetNote,
                              style: MealoraTypography.headline.copyWith(
                                color: MealoraColors.primaryDeep,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: MealoraSpacing.md),
                MealoraCard(
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          text.todayConsumedLabel,
                          style: MealoraTypography.bodySmall,
                        ),
                      ),
                      Text(
                        text.todayConsumedUnknown,
                        style: MealoraTypography.bodyEmphasis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: MealoraSpacing.lg),
                Text(
                  text.todayEmptyTitle,
                  style: MealoraTypography.sectionTitle,
                ),
                const SizedBox(height: MealoraSpacing.xxs),
                Text(text.todayEmptyBody, style: MealoraTypography.bodySmall),
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

class _UnknownCalorieRing extends StatelessWidget {
  const _UnknownCalorieRing({required this.label, required this.target});

  final String label;
  final String target;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 128,
      height: 128,
      child: CustomPaint(
        painter: const _EmptyRingPainter(),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                label,
                textAlign: TextAlign.center,
                style: MealoraTypography.caption,
              ),
              const SizedBox(height: MealoraSpacing.xxs),
              Text(
                target,
                textAlign: TextAlign.center,
                style: MealoraTypography.caption.copyWith(
                  color: MealoraColors.muted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyRingPainter extends CustomPainter {
  const _EmptyRingPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
      size.center(Offset.zero),
      size.shortestSide / 2 - 8,
      Paint()
        ..color = MealoraColors.track
        ..style = PaintingStyle.stroke
        ..strokeWidth = 12,
    );
  }

  @override
  bool shouldRepaint(_EmptyRingPainter oldDelegate) => false;
}

class _TodayHeroGlowPainter extends CustomPainter {
  const _TodayHeroGlowPainter();

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
  bool shouldRepaint(_TodayHeroGlowPainter oldDelegate) => false;
}
