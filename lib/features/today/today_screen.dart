import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/format/id_formatters.dart';
import 'package:mealora/domain/program/program_code.dart';
import 'package:mealora/domain/program/user_program.dart';
import 'package:mealora/features/shell/app_shell.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// Ruang "Hari ini".
///
/// Task 7.1: begitu ada program aktif, menampilkan chip program dan target
/// energi harian menggantikan keadaan kosong change 001. Task 7.2:
/// konsumsi tetap "belum diketahui", bukan nol, karena pencatatan makanan
/// belum tersedia pada pengiriman ini (Design D10).
class TodayScreen extends ConsumerWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = AppText.of(context);
    final activeProgram = ref.watch(activeProgramProvider);

    return activeProgram.when(
      loading: () => const SizedBox.shrink(),
      error: (error, stackTrace) => MealoraSpacePage(
        title: text.navToday,
        subtitle: text.todaySubtitle,
        child: MealoraEmptyState(
          title: text.todayEmptyTitle,
          body: text.todayEmptyBody,
          icon: Icons.restaurant_menu_outlined,
        ),
      ),
      data: (program) => program == null
          ? MealoraSpacePage(
              title: text.navToday,
              subtitle: text.todaySubtitle,
              child: MealoraEmptyState(
                title: text.todayEmptyTitle,
                body: text.todayEmptyBody,
                icon: Icons.restaurant_menu_outlined,
              ),
            )
          : _ActiveProgramToday(text: text, program: program),
    );
  }
}

/// Hero bergradien di puncak "Hari ini" — sapaan, tanggal, dan chip program
/// aktif di atas permukaan kaca gelap, sesuai "Hero field" di `01 · Hari
/// ini` (`mealora-v2.pen`).
class _ActiveProgramToday extends StatelessWidget {
  const _ActiveProgramToday({required this.text, required this.program});

  final AppText text;
  final UserProgram program;

  @override
  Widget build(BuildContext context) {
    final proposal = program.proposal;
    final name = _programName(text, program.programCode);

    return Column(
      children: <Widget>[
        DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment(0.34, -0.94),
              end: Alignment(-0.34, 0.94),
              colors: MealoraColors.heroGradient,
              stops: MealoraColors.heroGradientStops,
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                MealoraSpacing.screenGutter,
                MealoraSpacing.lg,
                MealoraSpacing.screenGutter,
                MealoraSpacing.xxl,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    text.navToday,
                    style: MealoraTypography.display.copyWith(
                      color: MealoraColors.onPrimary,
                    ),
                  ),
                  const SizedBox(height: MealoraSpacing.xxs),
                  Text(
                    text.todaySubtitle,
                    style: MealoraTypography.body.copyWith(
                      color: MealoraColors.onPrimaryMuted,
                    ),
                  ),
                  const SizedBox(height: MealoraSpacing.md),
                  Semantics(
                    label: text.todayProgramChipSemantics(name),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: MealoraSpacing.md,
                        vertical: MealoraSpacing.sm,
                      ),
                      decoration: BoxDecoration(
                        color: MealoraColors.glassOnHero,
                        borderRadius: BorderRadius.circular(
                          MealoraRadius.chip,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Icon(
                            Icons.eco_outlined,
                            size: MealoraIconSize.inline,
                            color: MealoraColors.onPrimary,
                          ),
                          const SizedBox(width: MealoraSpacing.xxs),
                          Text(
                            name,
                            style: MealoraTypography.chipLabel.copyWith(
                              color: MealoraColors.onPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              MealoraSpacing.screenGutter,
              MealoraSpacing.lg,
              MealoraSpacing.screenGutter,
              MealoraSpacing.xxl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                MealoraCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        text.todayDailyTargetLabel,
                        style: MealoraTypography.label,
                      ),
                      const SizedBox(height: MealoraSpacing.xs),
                      if (proposal.showsEnergyTarget &&
                          proposal.energyTarget != null)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.baseline,
                          textBaseline: TextBaseline.alphabetic,
                          children: <Widget>[
                            Flexible(
                              child: Text(
                                IdFormat.integer(proposal.energyTarget!.kcal),
                                style: MealoraTypography.display,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: MealoraSpacing.xs),
                            Text(
                              text.unitKilocalorie,
                              style: MealoraTypography.body,
                            ),
                          ],
                        )
                      else
                        Text(
                          text.reviewNoEnergyTargetNote,
                          style: MealoraTypography.body,
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
                        style: MealoraTypography.body,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _programName(AppText text, ProgramCode code) => switch (code) {
    ProgramCode.healthyEating => text.onboardingProgramHealthyName,
    ProgramCode.weightLoss => text.onboardingProgramWeightLossName,
    ProgramCode.weightGain => text.onboardingProgramWeightGainName,
    ProgramCode.maintenance => text.onboardingProgramMaintenanceName,
  };
}
