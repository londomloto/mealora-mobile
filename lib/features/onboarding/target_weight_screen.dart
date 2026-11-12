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
import 'package:mealora/domain/program/target_suggestion.dart';
import 'package:mealora/features/onboarding/onboarding_controller.dart';
import 'package:mealora/features/onboarding/onboarding_step.dart';
import 'package:mealora/features/onboarding/widgets/onboarding_scaffold.dart';
import 'package:mealora/features/onboarding/widgets/target_suggestion_picker.dart';
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
    _targetWeightController.addListener(_onWeightChanged);
    final targetDate = draft?.targetDate;
    _targetDate = targetDate == null
        ? null
        : DateTime(targetDate.year, targetDate.month, targetDate.day);
  }

  void _onWeightChanged() => setState(() {});

  @override
  void dispose() {
    _targetWeightController
      ..removeListener(_onWeightChanged)
      ..dispose();
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

    // Rentang aman (change 019, desain 25b): berat minimum selalu tampil;
    // rentang tanggal tampil dan membatasi pemilih tanggal begitu berat
    // tujuan yang valid diisi.
    final typedWeightKg = double.tryParse(
      _targetWeightController.text.trim().replaceAll(',', '.'),
    );
    final safeRange = draft.height == null || draft.currentWeight == null
        ? null
        : TargetSuggestionCalculator(ref.read(nutritionPolicyProvider))
              .safeRange(
                program: draft.selectedProgram!,
                height: draft.height!,
                currentWeight: draft.currentWeight!,
                asOfDate: today,
                targetWeightKg: typedWeightKg,
              );
    final defaultFirst = DateTime(today.year, today.month, today.day);
    final defaultLast = DateTime(today.year + 5);
    var firstDate = defaultFirst;
    var lastDate = defaultLast;
    final earliest = safeRange?.earliestDate;
    final latest = safeRange?.latestDate;
    if (earliest != null && latest != null) {
      final e = DateTime(earliest.year, earliest.month, earliest.day);
      final l = DateTime(latest.year, latest.month, latest.day);
      if (e.isAfter(firstDate)) firstDate = e;
      if (l.isBefore(lastDate)) lastDate = l;
      if (lastDate.isBefore(firstDate)) {
        firstDate = defaultFirst;
        lastDate = defaultLast;
      }
    }
    final current = _targetDate;
    final initialDate = current == null || current.isBefore(firstDate)
        ? firstDate
        : current.isAfter(lastDate)
        ? lastDate
        : current;
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
          style: MealoraTypography.compactFieldLabel,
        ),
        const SizedBox(height: MealoraSpacing.xs),
        _WeightFieldCard(
          icon: Icons.monitor_weight_outlined,
          value: draft.currentWeight == null
              ? '—'
              : text.valueWithUnit(
                  IdFormat.decimal(draft.currentWeight!.kg),
                  text.unitKilogram,
                ),
        ),
        const SizedBox(height: MealoraSpacing.lg),
        Text(
          text.onboardingGoalWeightLabel,
          style: MealoraTypography.compactFieldLabel,
        ),
        const SizedBox(height: MealoraSpacing.xs),
        _WeightFieldCard(
          icon: Icons.track_changes_outlined,
          controller: _targetWeightController,
          hint: text.onboardingGoalWeightHint,
          suffix: text.unitKilogram,
        ),
        if (safeRange != null) ...<Widget>[
          const SizedBox(height: MealoraSpacing.xxs),
          TargetSafeHint(
            icon: Icons.verified_user_outlined,
            text: text.targetHintMinimumWeight(
              IdFormat.decimal(safeRange.minimumTargetWeightKg),
            ),
          ),
        ],
        if (_targetWeightError != null) ...<Widget>[
          const SizedBox(height: MealoraSpacing.xxs),
          Text(
            _targetWeightError!,
            style: MealoraTypography.caption.copyWith(
              color: MealoraColors.danger,
            ),
          ),
        ],
        const SizedBox(height: MealoraSpacing.lg),
        MealoraDateField(
          label: text.onboardingTargetDateLabel,
          hint: text.onboardingTargetDateHint,
          value: _targetDate,
          firstDate: firstDate,
          lastDate: lastDate,
          initialDate: initialDate,
          onChanged: (value) => setState(() => _targetDate = value),
        ),
        if (earliest != null && latest != null) ...<Widget>[
          const SizedBox(height: MealoraSpacing.xxs),
          TargetSafeHint(
            icon: Icons.info_outline,
            text: text.targetHintDateRange(
              IdFormat.decimal(typedWeightKg!),
              IdFormat.longDate(earliest),
              IdFormat.longDate(latest),
            ),
          ),
        ],
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

class _WeightFieldCard extends StatelessWidget {
  const _WeightFieldCard({
    required this.icon,
    this.value,
    this.controller,
    this.hint,
    this.suffix,
  }) : assert(value != null || controller != null);

  final IconData icon;
  final String? value;
  final TextEditingController? controller;
  final String? hint;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      padding: const EdgeInsets.symmetric(horizontal: MealoraSpacing.md),
      decoration: BoxDecoration(
        color: MealoraColors.glassCard,
        borderRadius: BorderRadius.circular(MealoraRadius.button),
        border: Border.all(color: MealoraColors.glassBorder),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: MealoraColors.shadowGlass,
            offset: Offset(0, 14),
            blurRadius: 34,
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: MealoraColors.iconField,
              borderRadius: BorderRadius.circular(
                MealoraRadius.compactIconField,
              ),
            ),
            child: Icon(icon, size: 18, color: MealoraColors.primaryDeep),
          ),
          const SizedBox(width: MealoraSpacing.sm),
          Expanded(
            child: controller == null
                ? Text(value!, style: MealoraTypography.bodyEmphasis)
                : TextField(
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: MealoraTypography.bodyEmphasis,
                    decoration: InputDecoration(
                      hintText: hint,
                      suffixText: suffix,
                      isDense: true,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
          ),
          const SizedBox(width: MealoraSpacing.xs),
          const Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 18,
            color: MealoraColors.affordance,
          ),
        ],
      ),
    );
  }
}
