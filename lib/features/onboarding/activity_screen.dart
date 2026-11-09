import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/domain/nutrition/activity_level.dart';
import 'package:mealora/features/onboarding/onboarding_controller.dart';
import 'package:mealora/features/onboarding/onboarding_step.dart';
import 'package:mealora/features/onboarding/widgets/onboarding_choice_card.dart';
import 'package:mealora/features/onboarding/widgets/onboarding_scaffold.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// `09 · Aktivitas harian` (task 4.5): tiga pilihan dengan penjelasan
/// sehari-hari, dan keterangan bahwa pilihan memengaruhi perkiraan serta
/// dapat diubah (FRS 2.3.4).
class OnboardingActivityScreen extends ConsumerStatefulWidget {
  const OnboardingActivityScreen({super.key});

  @override
  ConsumerState<OnboardingActivityScreen> createState() =>
      _OnboardingActivityScreenState();
}

class _OnboardingActivityScreenState
    extends ConsumerState<OnboardingActivityScreen> {
  ActivityLevel? _selected;

  @override
  void initState() {
    super.initState();
    _selected = ref
        .read(onboardingControllerProvider)
        .valueOrNull
        ?.activityLevel;
  }

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);

    return OnboardingScaffold(
      contextLabel: text.onboardingStepLabel(
        OnboardingStep.activity.displayNumber!,
        OnboardingStepDisplay.displayTotal,
      ),
      title: text.onboardingActivityTitle,
      subtitle: text.onboardingActivitySubtitle,
      onBack: () => ref
          .read(onboardingControllerProvider.notifier)
          .goToStep(OnboardingStep.profileBasics),
      backSemanticsLabel: text.onboardingBackSemantics,
      primaryActionLabel: text.onboardingContinueAction,
      onPrimaryAction: _selected == null
          ? null
          : () => ref
                .read(onboardingControllerProvider.notifier)
                .saveActivityLevel(_selected!),
      children: <Widget>[
        OnboardingChoiceCard(
          title: text.onboardingActivitySedentaryTitle,
          detail: text.onboardingActivitySedentaryDetail,
          leading: Icons.weekend_outlined,
          leadingBackground: MealoraColors.info.withValues(alpha: 0.14),
          leadingForeground: MealoraColors.info,
          selected: _selected == ActivityLevel.sedentary,
          onTap: () => setState(() => _selected = ActivityLevel.sedentary),
        ),
        const SizedBox(height: MealoraSpacing.sm),
        OnboardingChoiceCard(
          title: text.onboardingActivityModerateTitle,
          detail: text.onboardingActivityModerateDetail,
          leading: Icons.directions_walk,
          leadingBackground: MealoraColors.softGreen,
          leadingForeground: MealoraColors.primaryBright,
          selected: _selected == ActivityLevel.moderatelyActive,
          onTap: () =>
              setState(() => _selected = ActivityLevel.moderatelyActive),
        ),
        const SizedBox(height: MealoraSpacing.sm),
        OnboardingChoiceCard(
          title: text.onboardingActivityVeryTitle,
          detail: text.onboardingActivityVeryDetail,
          leading: Icons.directions_bike,
          leadingBackground: MealoraColors.accent.withValues(alpha: 0.16),
          leadingForeground: MealoraColors.accent,
          selected: _selected == ActivityLevel.veryActive,
          onTap: () => setState(() => _selected = ActivityLevel.veryActive),
        ),
        const SizedBox(height: MealoraSpacing.lg),
        ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 76),
          child: MealoraNoteCard(
            icon: Icons.info_outline,
            body: text.onboardingActivityNote,
            foreground: MealoraColors.primaryDeep,
          ),
        ),
      ],
    );
  }
}
