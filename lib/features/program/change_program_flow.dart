import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/domain/program/program_code.dart';
import 'package:mealora/domain/program/program_proposal_inputs.dart';
import 'package:mealora/domain/program/program_specific_input.dart';
import 'package:mealora/domain/program/user_program.dart';
import 'package:mealora/domain/shared/units.dart';
import 'package:mealora/features/onboarding/onboarding_controller.dart'
    show profileRepositoryProvider;
import 'package:mealora/features/onboarding/program_detail_screen.dart'
    show kHabitFocusCodes;
import 'package:mealora/features/onboarding/widgets/onboarding_choice_card.dart';
import 'package:mealora/features/program/program_name.dart';
import 'package:mealora/features/program/program_revision_review_screen.dart';
import 'package:mealora/features/program/program_revision_service.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// `28 · Pratinjau ganti program` (task 6.1): program sekarang, program
/// pengganti beserta targetnya, penegasan program lama pindah ke riwayat,
/// penegasan catatan tetap utuh, dan jalan batal yang tidak mengubah apa
/// pun (task 6.5).
class ProgramChangePreviewScreen extends StatelessWidget {
  const ProgramChangePreviewScreen({required this.currentProgram, super.key});

  final UserProgram currentProgram;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);

    return Scaffold(
      backgroundColor: MealoraColors.background,
      body: MealoraBlobBackdrop(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
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
                      Text(
                        text.changeContextLabel,
                        style: MealoraTypography.eyebrow,
                      ),
                      const SizedBox(height: MealoraSpacing.xs),
                      Text(text.changeTitle, style: MealoraTypography.title),
                      const SizedBox(height: MealoraSpacing.xs),
                      Text(
                        text.changeSubtitle,
                        style: MealoraTypography.subtitle,
                      ),
                      const SizedBox(height: MealoraSpacing.xl),
                      MealoraCard(
                        child: MealoraIconRow(
                          icon: Icons.eco_outlined,
                          title: programDisplayName(
                            text,
                            currentProgram.programCode,
                          ),
                          detail: text.changeCurrentProgramEyebrow,
                        ),
                      ),
                      const SizedBox(height: MealoraSpacing.sm),
                      const Icon(Icons.south, color: MealoraColors.affordance),
                      const SizedBox(height: MealoraSpacing.sm),
                      MealoraCard(
                        child: MealoraIconRow(
                          icon: Icons.swap_horiz,
                          title: text.changeReplacementEyebrow,
                          detail: text.changeReplacementDescription,
                        ),
                      ),
                      const SizedBox(height: MealoraSpacing.lg),
                      MealoraNoteCard(
                        icon: Icons.history,
                        title: text.changeHistoryNoteTitle,
                        body: text.changeHistoryNoteBody,
                      ),
                      const SizedBox(height: MealoraSpacing.lg),
                      Text(
                        text.changeCancelFootnote,
                        style: MealoraTypography.caption,
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  MealoraSpacing.screenGutter,
                  0,
                  MealoraSpacing.screenGutter,
                  MealoraSpacing.lg,
                ),
                child: MealoraPrimaryButton(
                  label: text.changeReviewAction,
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => _PickReplacementProgramScreen(
                        currentProgram: currentProgram,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PickReplacementProgramScreen extends ConsumerStatefulWidget {
  const _PickReplacementProgramScreen({required this.currentProgram});

  final UserProgram currentProgram;

  @override
  ConsumerState<_PickReplacementProgramScreen> createState() =>
      _PickReplacementProgramScreenState();
}

class _PickReplacementProgramScreenState
    extends ConsumerState<_PickReplacementProgramScreen> {
  ProgramCode? _selected;
  String? _habitFocus;
  final TextEditingController _targetWeightController = TextEditingController();
  String? _error;
  bool _preparing = false;

  @override
  void dispose() {
    _targetWeightController.dispose();
    super.dispose();
  }

  bool get _requiresTargetWeight =>
      _selected == ProgramCode.weightLoss ||
      _selected == ProgramCode.weightGain;
  bool get _requiresHabitFocus => _selected == ProgramCode.healthyEating;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final canContinue =
        _selected != null &&
        (!_requiresTargetWeight ||
            _targetWeightController.text.trim().isNotEmpty) &&
        (!_requiresHabitFocus || _habitFocus != null);

    return Scaffold(
      backgroundColor: MealoraColors.background,
      body: MealoraBlobBackdrop(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
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
                      Text(
                        text.changeContextLabel,
                        style: MealoraTypography.eyebrow,
                      ),
                      const SizedBox(height: MealoraSpacing.xs),
                      Text(
                        text.changePickReplacementTitle,
                        style: MealoraTypography.title,
                      ),
                      const SizedBox(height: MealoraSpacing.xs),
                      Text(
                        text.changePickReplacementSubtitle,
                        style: MealoraTypography.subtitle,
                      ),
                      const SizedBox(height: MealoraSpacing.xl),
                      for (final code in ProgramCode.values.where(
                        (c) => c != widget.currentProgram.programCode,
                      )) ...<Widget>[
                        OnboardingChoiceCard(
                          title: programDisplayName(text, code),
                          detail: programDescription(text, code),
                          selected: _selected == code,
                          onTap: () => setState(() {
                            _selected = code;
                            _habitFocus = null;
                            _error = null;
                          }),
                        ),
                        const SizedBox(height: MealoraSpacing.sm),
                      ],
                      if (_requiresHabitFocus) ...<Widget>[
                        const SizedBox(height: MealoraSpacing.md),
                        Text(
                          text.changeHabitFocusHeading,
                          style: MealoraTypography.label,
                        ),
                        const SizedBox(height: MealoraSpacing.xs),
                        for (final code in kHabitFocusCodes) ...<Widget>[
                          OnboardingChoiceCard(
                            title: _habitFocusLabel(text, code),
                            selected: _habitFocus == code,
                            onTap: () => setState(() => _habitFocus = code),
                          ),
                          const SizedBox(height: MealoraSpacing.xs),
                        ],
                      ],
                      if (_requiresTargetWeight) ...<Widget>[
                        const SizedBox(height: MealoraSpacing.md),
                        MealoraField(
                          label: text.onboardingGoalWeightLabel,
                          hint: text.onboardingGoalWeightHint,
                          controller: _targetWeightController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (_) => setState(() {}),
                        ),
                      ],
                      if (_error != null) ...<Widget>[
                        const SizedBox(height: MealoraSpacing.sm),
                        Text(
                          _error!,
                          style: MealoraTypography.caption.copyWith(
                            color: MealoraColors.danger,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  MealoraSpacing.screenGutter,
                  0,
                  MealoraSpacing.screenGutter,
                  MealoraSpacing.lg,
                ),
                child: MealoraPrimaryButton(
                  label: text.changeReviewReplacementAction,
                  onPressed: (!canContinue || _preparing) ? null : _continue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _habitFocusLabel(AppText text, String code) => switch (code) {
    'consistent_logging' => text.onboardingFocusConsistentLogging,
    'macros_understanding' => text.onboardingFocusMacros,
    'portion_awareness' => text.onboardingFocusPortions,
    _ => code,
  };

  Future<void> _continue() async {
    setState(() {
      _preparing = true;
      _error = null;
    });
    final profile = await ref.read(profileRepositoryProvider).current();
    if (profile == null) {
      setState(() => _preparing = false);
      return;
    }
    double? targetWeightKg;
    if (_requiresTargetWeight) {
      targetWeightKg = double.tryParse(
        _targetWeightController.text.trim().replaceAll(',', '.'),
      );
      if (targetWeightKg == null) {
        setState(() {
          _preparing = false;
          _error = AppText.of(context).onboardingRequiredTargetWeight;
        });
        return;
      }
    }

    final today = ref.read(clockProvider).today();
    final inputs = ProgramProposalInputs(
      ageYears: profile.ageYearsAsOf(today)!,
      biologicalInput: profile.biologicalInput!,
      height: profile.height!,
      currentWeight: profile.currentWeight!,
      activity: profile.activityLevel!,
      specific: ProgramSpecificInput(
        targetWeight: targetWeightKg == null
            ? null
            : Mass.kgValue(targetWeightKg, field: 'targetWeight').valueOrNull,
        habitFocus: _habitFocus,
      ),
    );

    final service = ref.read(programRevisionServiceProvider);
    final outcome = service.preview(
      programCode: _selected!,
      inputs: inputs,
      requiresTargetWeight: _requiresTargetWeight,
      requiresHabitFocus: _requiresHabitFocus,
    );

    if (!mounted) {
      return;
    }
    setState(() => _preparing = false);
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProgramRevisionReviewScreen(
          profileId: profile.id,
          programCode: _selected!,
          previewInputs: inputs,
          previewOutcome: outcome,
          requiresTargetWeight: _requiresTargetWeight,
          requiresHabitFocus: _requiresHabitFocus,
          buildCurrentInputs: () => _rebuildCurrentInputs(inputs),
        ),
      ),
    );
  }

  Future<ProgramProposalInputs> _rebuildCurrentInputs(
    ProgramProposalInputs previous,
  ) async {
    final profile = await ref.read(profileRepositoryProvider).current();
    if (profile == null) {
      return previous;
    }
    final today = ref.read(clockProvider).today();
    return ProgramProposalInputs(
      ageYears: profile.ageYearsAsOf(today)!,
      biologicalInput: profile.biologicalInput!,
      height: profile.height!,
      currentWeight: profile.currentWeight!,
      activity: profile.activityLevel!,
      specific: previous.specific,
    );
  }
}
