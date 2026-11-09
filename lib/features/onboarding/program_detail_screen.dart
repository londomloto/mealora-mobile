import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/domain/program/program_code.dart';
import 'package:mealora/features/onboarding/onboarding_controller.dart';
import 'package:mealora/features/onboarding/onboarding_step.dart';
import 'package:mealora/features/onboarding/widgets/onboarding_scaffold.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// Kode fokus kebiasaan Makan Sehat (`11`, FRS 3.3.4) — nilai mesin stabil
/// yang tersimpan sebagai `ProgramSpecificInput.habitFocus`.
const List<String> kHabitFocusCodes = <String>[
  'consistent_logging',
  'macros_understanding',
  'portion_awareness',
];

/// `11 · Detail program` (task 4.7): masukan tambahan sesuai program, fokus
/// kebiasaan untuk Makan Sehat, dan pengakuan bahwa hasil adalah perkiraan
/// (task 4.8, FRS 3.3.4/3.3.6).
class OnboardingProgramDetailScreen extends ConsumerWidget {
  const OnboardingProgramDetailScreen({super.key});

  String _programName(AppText text, ProgramCode code) => switch (code) {
    ProgramCode.healthyEating => text.onboardingProgramHealthyName,
    ProgramCode.weightLoss => text.onboardingProgramWeightLossName,
    ProgramCode.weightGain => text.onboardingProgramWeightGainName,
    ProgramCode.maintenance => text.onboardingProgramMaintenanceName,
  };

  String _habitFocusLabel(AppText text, String code) => switch (code) {
    'consistent_logging' => text.onboardingFocusConsistentLogging,
    'macros_understanding' => text.onboardingFocusMacros,
    'portion_awareness' => text.onboardingFocusPortions,
    _ => code,
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = AppText.of(context);
    final draft = ref.watch(onboardingControllerProvider).valueOrNull;
    final notifier = ref.read(onboardingControllerProvider.notifier);

    if (draft?.selectedProgram == null) {
      // Masuk ke langkah ini tanpa program terpilih seharusnya tidak
      // mungkin lewat alur normal (task 4.6 menahan sampai program
      // dipilih) — jaring pengaman: kembali ke pemilihan program.
      return const _MissingProgramFallback();
    }

    final program = draft!.selectedProgram!;
    final isHealthyEating = program == ProgramCode.healthyEating;
    final name = _programName(text, program);

    return OnboardingScaffold(
      contextLabel: text.onboardingStepLabel(
        OnboardingStep.programDetail.displayNumber!,
        OnboardingStepDisplay.displayTotal,
      ),
      title: isHealthyEating
          ? text.onboardingProgramDetailFocusTitle(name)
          : text.onboardingProgramDetailGenericTitle(name),
      subtitle: isHealthyEating
          ? text.onboardingProgramDetailFocusSubtitle
          : text.onboardingProgramDetailGenericSubtitle,
      onBack: () => notifier.goToStep(OnboardingStep.programSelect),
      backSemanticsLabel: text.onboardingBackSemantics,
      primaryActionLabel: draft.requiresTargetWeight
          ? text.onboardingContinueAction
          : text.onboardingPreviewAction,
      onPrimaryAction: draft.estimateAcknowledged
          ? notifier.continueFromProgramDetail
          : null,
      children: <Widget>[
        _SelectedProgramBadge(
          name: name,
          clarification: draft.requiresTargetWeight
              ? text.onboardingProgramClarificationHasTarget
              : text.onboardingProgramClarificationNoTarget,
        ),
        const SizedBox(height: MealoraSpacing.lg),
        if (isHealthyEating) ...<Widget>[
          Text(
            text.onboardingFocusHeading,
            style: MealoraTypography.sectionTitle,
          ),
          const SizedBox(height: MealoraSpacing.sm),
          MealoraCard(
            padding: const EdgeInsets.symmetric(
              horizontal: MealoraSpacing.md,
              vertical: MealoraSpacing.xxs,
            ),
            child: Column(
              children: <Widget>[
                for (final (index, code)
                    in kHabitFocusCodes.indexed) ...<Widget>[
                  if (index > 0) const Divider(height: 1),
                  _FocusToggleRow(
                    label: _habitFocusLabel(text, code),
                    selected:
                        draft.habitFocus?.split('|').contains(code) ?? false,
                    onTap: () => notifier.toggleHabitFocus(code),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: MealoraSpacing.sm),
        ],
        _AcknowledgementToggle(
          acknowledged: draft.estimateAcknowledged,
          onChanged: notifier.setEstimateAcknowledged,
        ),
      ],
    );
  }
}

class _SelectedProgramBadge extends StatelessWidget {
  const _SelectedProgramBadge({
    required this.name,
    required this.clarification,
  });

  final String name;
  final String clarification;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MealoraSpacing.lg),
      decoration: BoxDecoration(
        color: MealoraColors.glassCard,
        borderRadius: BorderRadius.circular(MealoraRadius.card),
        border: Border.all(color: MealoraColors.primary, width: 2),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: MealoraColors.shadowGlass,
            offset: Offset(0, 14),
            blurRadius: 34,
          ),
        ],
      ),
      child: MealoraIconRow(
        icon: Icons.restaurant_outlined,
        iconBackground: MealoraColors.softGreen,
        iconForeground: MealoraColors.primary,
        title: name,
        detail: clarification,
        titleStyle: MealoraTypography.sectionTitle,
      ),
    );
  }
}

/// Satu baris sakelar fokus kebiasaan di dalam "Focus list" — kotak centang
/// besar (bukan kartu terpisah) per `11 · Detail program`.
class _FocusToggleRow extends StatelessWidget {
  const _FocusToggleRow({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        splashFactory: NoSplash.splashFactory,
        overlayColor: const WidgetStatePropertyAll(MealoraColors.transparent),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: MealoraSpacing.sm),
          child: Row(
            children: <Widget>[
              MealoraSquareCheck(selected: selected, size: 20),
              const SizedBox(width: MealoraSpacing.sm),
              Expanded(child: Text(label, style: MealoraTypography.body)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AcknowledgementToggle extends StatelessWidget {
  const _AcknowledgementToggle({
    required this.acknowledged,
    required this.onChanged,
  });

  final bool acknowledged;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return Semantics(
      button: true,
      checked: acknowledged,
      label: text.onboardingAcknowledgeText,
      child: InkWell(
        onTap: () => onChanged(!acknowledged),
        splashFactory: NoSplash.splashFactory,
        overlayColor: const WidgetStatePropertyAll(MealoraColors.transparent),
        borderRadius: BorderRadius.circular(MealoraRadius.chip),
        child: Container(
          padding: const EdgeInsets.all(MealoraSpacing.md),
          decoration: BoxDecoration(
            color: acknowledged
                ? MealoraColors.noteSuccess
                : MealoraColors.glassSoft,
            borderRadius: BorderRadius.circular(MealoraRadius.chip),
            border: Border.all(color: MealoraColors.glassBorder),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              MealoraCircleCheck(selected: acknowledged, size: 20),
              const SizedBox(width: MealoraSpacing.sm),
              Expanded(
                child: Text(
                  text.onboardingAcknowledgeText,
                  style: MealoraTypography.body,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MissingProgramFallback extends ConsumerWidget {
  const _MissingProgramFallback();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(onboardingControllerProvider.notifier)
          .goToStep(OnboardingStep.programSelect);
    });
    return const Scaffold(
      backgroundColor: MealoraColors.background,
      body: SizedBox.shrink(),
    );
  }
}
