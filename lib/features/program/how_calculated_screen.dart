import 'package:flutter/material.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/format/id_formatters.dart';
import 'package:mealora/domain/nutrition/activity_level.dart';
import 'package:mealora/domain/program/user_program.dart';
import 'package:mealora/domain/shared/program_warning.dart';
import 'package:mealora/features/program/widgets/program_shared.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// Rincian "Bagaimana dihitung" untuk program yang sedang berjalan (task
/// 4.1–4.3; layar `46` dirancang di `docs/mealora-v2.pen` lewat MCP
/// pen.dev mengikuti struktur `30 · Detail program selesai`).
///
/// Membaca nilai [program] apa adanya — TIDAK menghitung ulang apa pun
/// (Design D2/D8): seluruh angka di sini datang dari
/// `UserProgram.proposal`/`inputSnapshot` yang sudah tersimpan sejak
/// program ini diaktifkan atau direvisi terakhir kali.
class HowCalculatedScreen extends StatelessWidget {
  const HowCalculatedScreen({required this.program, super.key});

  final UserProgram program;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final proposal = program.proposal;
    final inputs = program.inputSnapshot;
    final lastCalculatedLabel = IdFormat.shortDate(
      LocalDate(
        program.startedAt.year,
        program.startedAt.month,
        program.startedAt.day,
      ),
    );

    return Scaffold(
      backgroundColor: MealoraColors.background,
      body: MealoraBlobBackdrop(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              MealoraSpacing.screenGutter,
              MealoraSpacing.md,
              MealoraSpacing.screenGutter,
              MealoraSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Semantics(
                      button: true,
                      label: text.howCalculatedBackSemantics,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
                        borderRadius: BorderRadius.circular(MealoraRadius.pill),
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
                        text.howCalculatedContextLabel,
                        style: MealoraTypography.eyebrow,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: MealoraSpacing.xs),
                Text(text.howCalculatedTitle, style: MealoraTypography.title),
                const SizedBox(height: MealoraSpacing.xs),
                Text(
                  text.howCalculatedSubtitle(lastCalculatedLabel),
                  style: MealoraTypography.subtitle,
                ),
                const SizedBox(height: MealoraSpacing.xl),
                TargetHeroCard(
                  eyebrow: text.howCalculatedTargetEyebrow,
                  value:
                      proposal.showsEnergyTarget &&
                          proposal.energyTarget != null
                      ? IdFormat.integer(proposal.energyTarget!.kcal)
                      : null,
                  unit:
                      proposal.showsEnergyTarget &&
                          proposal.energyTarget != null
                      ? text.unitKilocalorie
                      : null,
                  noValueNote: proposal.showsEnergyTarget
                      ? null
                      : text.reviewNoEnergyTargetNote,
                  caption: text.howCalculatedTargetCaption,
                  footer: Text(
                    text.reviewVersionLine(
                      proposal.calculatorVersion,
                      proposal.policyVersion,
                    ),
                    style: MealoraTypography.caption.copyWith(
                      color: MealoraColors.onPrimaryMuted,
                    ),
                  ),
                ),
                const SizedBox(height: MealoraSpacing.xl),
                Text(
                  text.howCalculatedInputsHeading,
                  style: MealoraTypography.sectionTitle,
                ),
                const SizedBox(height: MealoraSpacing.sm),
                FactsCard(
                  rows: <FactRow>[
                    FactRow(
                      label: text.howCalculatedHeightLabel,
                      value: '${IdFormat.integer(inputs.height.cm)} cm',
                    ),
                    FactRow(
                      label: text.howCalculatedWeightLabel,
                      value: '${IdFormat.decimal(inputs.currentWeight.kg)} kg',
                    ),
                    FactRow(
                      label: text.reviewBasisActivityLabel,
                      value: _activityLabel(text, inputs.activity),
                    ),
                    FactRow(
                      label: text.howCalculatedLastCalculatedLabel,
                      value: lastCalculatedLabel,
                    ),
                  ],
                ),
                const SizedBox(height: MealoraSpacing.xl),
                Text(
                  text.howCalculatedAssumptionsHeading,
                  style: MealoraTypography.sectionTitle,
                ),
                const SizedBox(height: MealoraSpacing.sm),
                FactsCard(
                  rows: <FactRow>[
                    FactRow(
                      label: text.reviewBasisEquationLabel,
                      value: 'Mifflin–St Jeor · ${proposal.calculatorVersion}',
                    ),
                    FactRow(
                      label: text.howCalculatedActivityFactorLabel,
                      value: _activityLabel(text, inputs.activity),
                    ),
                    FactRow(
                      label: text.howCalculatedRoundingLabel,
                      value: text.howCalculatedRoundingValue,
                    ),
                  ],
                ),
                if (proposal.warnings.isNotEmpty) ...<Widget>[
                  const SizedBox(height: MealoraSpacing.xl),
                  Text(
                    text.howCalculatedWarningsHeading,
                    style: MealoraTypography.sectionTitle,
                  ),
                  const SizedBox(height: MealoraSpacing.sm),
                  for (final warning in proposal.warnings) ...<Widget>[
                    MealoraNoteCard(
                      icon: Icons.warning_amber_rounded,
                      background: MealoraColors.accent.withValues(alpha: 0.14),
                      foreground: MealoraColors.accent,
                      title: _warningTitle(text, warning),
                      body: _warningBody(text, warning),
                    ),
                    const SizedBox(height: MealoraSpacing.sm),
                  ],
                ],
                const SizedBox(height: MealoraSpacing.xl),
                Text(
                  text.howCalculatedReadOnlyNote,
                  style: MealoraTypography.caption,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _activityLabel(AppText text, ActivityLevel level) => switch (level) {
    ActivityLevel.sedentary => text.onboardingActivitySedentaryTitle,
    ActivityLevel.moderatelyActive => text.onboardingActivityModerateTitle,
    ActivityLevel.veryActive => text.onboardingActivityVeryTitle,
  };

  String _warningTitle(AppText text, ProgramWarning warning) =>
      switch (warning) {
        ProgramWarning.floorApplied => text.howCalculatedWarningFloorTitle,
        ProgramWarning.relativePaceCapApplied =>
          text.howCalculatedWarningPaceCapTitle,
        ProgramWarning.carbohydrateBelowRecommendedRange =>
          text.howCalculatedWarningCarbTitle,
      };

  String _warningBody(AppText text, ProgramWarning warning) =>
      switch (warning) {
        ProgramWarning.floorApplied => text.reviewWarningFloorApplied,
        ProgramWarning.relativePaceCapApplied =>
          text.reviewWarningRelativePaceCapApplied,
        ProgramWarning.carbohydrateBelowRecommendedRange =>
          text.reviewWarningCarbohydrateBelowRecommendedRange,
      };
}
