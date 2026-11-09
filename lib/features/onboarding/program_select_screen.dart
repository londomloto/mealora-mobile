import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/domain/program/program_code.dart';
import 'package:mealora/features/onboarding/onboarding_controller.dart';
import 'package:mealora/features/onboarding/onboarding_step.dart';
import 'package:mealora/features/onboarding/widgets/onboarding_choice_card.dart';
import 'package:mealora/features/onboarding/widgets/onboarding_scaffold.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// `10 · Pilih program` (task 4.6): empat program, keterangan bahwa
/// program dapat diganti, dan keterangan bahwa rekomendasi berat
/// memerlukan kebijakan tervalidasi (FRS 3.3.1, 3.3.2).
class OnboardingProgramSelectScreen extends ConsumerWidget {
  const OnboardingProgramSelectScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = AppText.of(context);
    final selected = ref.watch(
      onboardingControllerProvider.select(
        (value) => value.valueOrNull?.selectedProgram,
      ),
    );
    final notifier = ref.read(onboardingControllerProvider.notifier);

    Widget programCard(ProgramCode code, String name, String description) {
      final (icon, background, foreground) = switch (code) {
        ProgramCode.healthyEating => (
          Icons.restaurant_outlined,
          MealoraColors.softGreen,
          MealoraColors.primaryBright,
        ),
        ProgramCode.weightLoss => (
          Icons.trending_down,
          MealoraColors.info.withValues(alpha: 0.14),
          MealoraColors.info,
        ),
        ProgramCode.weightGain => (
          Icons.trending_up,
          MealoraColors.peach.withValues(alpha: 0.16),
          MealoraColors.peach,
        ),
        ProgramCode.maintenance => (
          Icons.balance_outlined,
          MealoraColors.accent.withValues(alpha: 0.16),
          MealoraColors.accent,
        ),
      };
      return Padding(
        padding: const EdgeInsets.only(bottom: MealoraSpacing.sm),
        child: OnboardingChoiceCard(
          title: name,
          detail: description,
          leading: icon,
          leadingBackground: background,
          leadingForeground: foreground,
          minHeight: 78,
          selected: selected == code,
          onTap: () => notifier.selectProgram(code),
        ),
      );
    }

    return OnboardingScaffold(
      contextLabel: text.onboardingStepLabel(
        OnboardingStep.programSelect.displayNumber!,
        OnboardingStepDisplay.displayTotal,
      ),
      title: text.onboardingProgramSelectTitle,
      subtitle: text.onboardingProgramSelectSubtitle,
      onBack: () => notifier.goToStep(OnboardingStep.activity),
      backSemanticsLabel: text.onboardingBackSemantics,
      primaryActionLabel: text.onboardingContinueAction,
      onPrimaryAction: selected == null
          ? null
          : () => notifier.goToStep(OnboardingStep.programDetail),
      children: <Widget>[
        programCard(
          ProgramCode.healthyEating,
          text.onboardingProgramHealthyName,
          text.onboardingProgramHealthyDescription,
        ),
        programCard(
          ProgramCode.weightLoss,
          text.onboardingProgramWeightLossName,
          text.onboardingProgramWeightLossDescription,
        ),
        programCard(
          ProgramCode.weightGain,
          text.onboardingProgramWeightGainName,
          text.onboardingProgramWeightGainDescription,
        ),
        programCard(
          ProgramCode.maintenance,
          text.onboardingProgramMaintenanceName,
          text.onboardingProgramMaintenanceDescription,
        ),
        const SizedBox(height: MealoraSpacing.sm),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 70),
          child: MealoraNoteCard(
            icon: Icons.info_outline,
            body: text.onboardingProgramTerms,
            background: MealoraColors.noteWarning,
            foreground: MealoraColors.accent,
          ),
        ),
      ],
    );
  }
}
