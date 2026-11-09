import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/format/id_formatters.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/domain/program/program_code.dart';
import 'package:mealora/features/onboarding/onboarding_controller.dart';
import 'package:mealora/features/onboarding/onboarding_step.dart';
import 'package:mealora/features/onboarding/widgets/onboarding_scaffold.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// `25 · Target berat program` (task 4.9): berat awal (terbaca dari
/// profil), berat tujuan, tanggal tujuan opsional, dan keterangan bahwa
/// tanggal tidak mengesampingkan aturan keselamatan (FRS 3.3.3/3.3.5).
///
/// Hanya dilalui untuk Turun Berat/Naik Berat (task 4.10,
/// `OnboardingDraft.requiresTargetWeight`).
class OnboardingTargetWeightScreen extends ConsumerStatefulWidget {
  const OnboardingTargetWeightScreen({super.key});

  @override
  ConsumerState<OnboardingTargetWeightScreen> createState() =>
      _OnboardingTargetWeightScreenState();
}

class _OnboardingTargetWeightScreenState
    extends ConsumerState<OnboardingTargetWeightScreen> {
  late final TextEditingController _targetWeightController;
  DateTime? _targetDate;
  String? _targetWeightError;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(onboardingControllerProvider).valueOrNull;
    _targetWeightController = TextEditingController(
      text: draft?.targetWeight == null
          ? ''
          : draft!.targetWeight!.kg.toString(),
    );
    final targetDate = draft?.targetDate;
    _targetDate = targetDate == null
        ? null
        : DateTime(targetDate.year, targetDate.month, targetDate.day);
  }

  @override
  void dispose() {
    _targetWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final draft = ref.watch(onboardingControllerProvider).valueOrNull;
    final notifier = ref.read(onboardingControllerProvider.notifier);
    final today = ref.read(clockProvider).today();

    if (draft?.selectedProgram == null || !draft!.requiresTargetWeight) {
      return const SizedBox.shrink();
    }

    final isWeightLoss = draft.selectedProgram == ProgramCode.weightLoss;
    final programName = isWeightLoss
        ? text.onboardingProgramWeightLossName
        : text.onboardingProgramWeightGainName;

    return OnboardingScaffold(
      contextLabel: text.onboardingTargetWeightContext(
        programName.toUpperCase(),
      ),
      title: text.onboardingTargetWeightTitle,
      subtitle: text.onboardingTargetWeightSubtitle,
      onBack: () => notifier.goToStep(OnboardingStep.programDetail),
      backSemanticsLabel: text.onboardingBackSemantics,
      primaryActionLabel: text.onboardingReviewEligibilityAction,
      onPrimaryAction: () => _submit(notifier),
      children: <Widget>[
        MealoraCard(
          child: MealoraIconRow(
            icon: isWeightLoss ? Icons.trending_down : Icons.trending_up,
            iconBackground: MealoraColors.info.withValues(alpha: 0.14),
            iconForeground: MealoraColors.info,
            title: programName,
            detail: isWeightLoss
                ? text.onboardingTargetWeightLossNote
                : text.onboardingTargetWeightGainNote,
          ),
        ),
        const SizedBox(height: MealoraSpacing.lg),
        Text(
          text.onboardingStartingWeightLabel,
          style: MealoraTypography.label,
        ),
        const SizedBox(height: MealoraSpacing.xs),
        MealoraCard(
          padding: const EdgeInsets.symmetric(
            horizontal: MealoraSpacing.md,
            vertical: MealoraSpacing.sm,
          ),
          child: Text(
            draft.currentWeight == null
                ? '—'
                : text.valueWithUnit(
                    IdFormat.decimal(draft.currentWeight!.kg),
                    text.unitKilogram,
                  ),
            style: MealoraTypography.bodyEmphasis,
          ),
        ),
        const SizedBox(height: MealoraSpacing.lg),
        MealoraField(
          label: text.onboardingGoalWeightLabel,
          hint: text.onboardingGoalWeightHint,
          controller: _targetWeightController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          errorText: _targetWeightError,
        ),
        const SizedBox(height: MealoraSpacing.lg),
        MealoraDateField(
          label: text.onboardingTargetDateLabel,
          hint: text.onboardingTargetDateHint,
          value: _targetDate,
          firstDate: DateTime(today.year, today.month, today.day),
          lastDate: DateTime(today.year + 5),
          onChanged: (value) => setState(() => _targetDate = value),
        ),
        const SizedBox(height: MealoraSpacing.sm),
        MealoraNoteCard(
          icon: Icons.calendar_month_outlined,
          title: text.onboardingTargetDateHeading,
          body: text.onboardingTargetDateExplanation,
        ),
        const SizedBox(height: MealoraSpacing.lg),
        MealoraNoteCard(
          icon: Icons.shield_outlined,
          background: MealoraColors.accent.withValues(alpha: 0.16),
          foreground: MealoraColors.accent,
          body: text.onboardingWeightGateNote,
        ),
      ],
    );
  }

  void _submit(OnboardingController notifier) {
    final weightValue = double.tryParse(
      _targetWeightController.text.trim().replaceAll(',', '.'),
    );
    if (weightValue == null) {
      setState(
        () => _targetWeightError = AppText.of(
          context,
        ).onboardingRequiredTargetWeight,
      );
      return;
    }
    final targetDate = _targetDate;
    final result = notifier.saveTargetWeightDetails(
      targetWeightKg: weightValue,
      targetDate: targetDate == null
          ? null
          : LocalDate(targetDate.year, targetDate.month, targetDate.day),
    );
    if (result.isErr) {
      setState(() => _targetWeightError = result.failureOrNull!.detail);
    }
  }
}
