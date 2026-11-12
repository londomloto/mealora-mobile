import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/domain/program/program_code.dart';
import 'package:mealora/domain/program/program_target_proposal.dart';
import 'package:mealora/domain/program/target_suggestion.dart';
import 'package:mealora/domain/shared/program_outcome.dart';
import 'package:mealora/domain/shared/reason_code.dart';
import 'package:mealora/features/onboarding/onboarding_controller.dart';
import 'package:mealora/features/onboarding/onboarding_step.dart';
import 'package:mealora/features/onboarding/rejection_copy.dart';
import 'package:mealora/features/onboarding/widgets/onboarding_scaffold.dart';
import 'package:mealora/features/onboarding/widgets/target_suggestion_picker.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

const Set<ReasonCode> _inputChangeReasonCodes = <ReasonCode>{
  ReasonCode.requestedPaceTooFast,
  ReasonCode.requestedPaceTooSlow,
  ReasonCode.targetWeightOutOfRange,
  ReasonCode.missingRequiredInput,
};

/// `26 · Target tidak dibuat` (task 6.1): satu kerangka layar untuk lima
/// keadaan hasil domain (Design D6) — judul, penjelasan, dan tawaran
/// langkah berikutnya berbeda menurut kode alasan (task 6.2, 6.3), tidak
/// pernah menampilkan angka target (Design D7, task 6.6).
class OnboardingRejectionScreen extends ConsumerStatefulWidget {
  const OnboardingRejectionScreen({required this.outcome, super.key});

  final ProgramOutcome<ProgramTargetProposal> outcome;

  @override
  ConsumerState<OnboardingRejectionScreen> createState() =>
      _OnboardingRejectionScreenState();
}

class _OnboardingRejectionScreenState
    extends ConsumerState<OnboardingRejectionScreen> {
  int _selected = 0;
  bool _applying = false;

  @override
  void didUpdateWidget(OnboardingRejectionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(oldWidget.outcome, widget.outcome)) {
      _selected = 0;
      _applying = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final outcome = widget.outcome;
    final text = AppText.of(context);
    final notifier = ref.read(onboardingControllerProvider.notifier);

    final RejectionCopy copy;
    final ReasonCode? reasonCode;
    switch (outcome) {
      case NeedsUserCorrection<ProgramTargetProposal>(
        reasonCode: final code,
        details: final details,
      ):
        reasonCode = code;
        copy = rejectionCopyForReasonCode(text, code, details: details);
      case NeedsProfessionalReview<ProgramTargetProposal>(
        reasonCode: final code,
        details: final details,
      ):
        reasonCode = code;
        copy = rejectionCopyForReasonCode(text, code, details: details);
      case UnsupportedProfile<ProgramTargetProposal>(reasonCode: final code):
        reasonCode = code;
        copy = rejectionCopyForReasonCode(text, code);
      case MissingValidatedPolicy<ProgramTargetProposal>():
        reasonCode = null;
        copy = rejectionCopyForMissingValidatedPolicy(text);
      case Approved<ProgramTargetProposal>():
        // Dijaga oleh pemanggil (review_screen.dart) — tidak pernah
        // mencapai sini dengan hasil disetujui.
        throw StateError('OnboardingRejectionScreen menerima Approved');
    }

    final offersInputChange =
        reasonCode != null && _inputChangeReasonCodes.contains(reasonCode);
    // Saran penyesuaian (change 019, desain 26b/26c): pilih kartu, lalu
    // tombol utama menerapkannya dan menghitung ulang pratinjau.
    final suggestions = offersInputChange
        ? notifier.targetSuggestions()
        : const <TargetSuggestion>[];
    final hasSuggestions = suggestions.isNotEmpty;
    final selected = _selected < suggestions.length ? _selected : 0;

    return OnboardingScaffold(
      contextLabel: text.rejectionContextLabel,
      title: text.rejectionTitle,
      subtitle: text.rejectionSubtitle,
      primaryActionLabel: hasSuggestions
          ? text.targetSuggestionApplyAction
          : offersInputChange
          ? text.rejectionChangeInputAction
          : text.rejectionAlternativeAction,
      onPrimaryAction: hasSuggestions
          ? (_applying
                ? null
                : () {
                    setState(() => _applying = true);
                    notifier.applyTargetSuggestion(suggestions[selected]);
                  })
          : offersInputChange
          ? () => notifier.goToStep(OnboardingStep.targetWeight)
          : () {
              notifier
                ..selectProgram(ProgramCode.healthyEating)
                ..goToStep(OnboardingStep.programDetail);
            },
      children: <Widget>[
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(MealoraSpacing.lg),
          decoration: BoxDecoration(
            color: MealoraColors.danger.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(MealoraRadius.cardLarge),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: MealoraColors.danger.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(MealoraRadius.chip),
                ),
                child: const Icon(
                  Icons.gpp_maybe_outlined,
                  color: MealoraColors.danger,
                ),
              ),
              const SizedBox(height: MealoraSpacing.md),
              Text(copy.heading, style: MealoraTypography.headline),
              const SizedBox(height: MealoraSpacing.xs),
              Text(copy.explanation, style: MealoraTypography.bodySmall),
            ],
          ),
        ),
        if (!offersInputChange) ...<Widget>[
          const SizedBox(height: MealoraSpacing.lg),
          MealoraCard(
            child: MealoraIconRow(
              icon: Icons.eco_outlined,
              title: text.rejectionAlternativeHeading,
              detail: text.rejectionAlternativeDetail,
              trailing: const Icon(
                Icons.chevron_right,
                color: MealoraColors.affordance,
              ),
            ),
          ),
        ],
        if (hasSuggestions) ...<Widget>[
          const SizedBox(height: MealoraSpacing.lg),
          TargetSuggestionPicker(
            suggestions: suggestions,
            reasonCode: reasonCode!,
            selectedIndex: selected,
            onSelected: (i) => setState(() => _selected = i),
          ),
          const SizedBox(height: MealoraSpacing.xs),
          Center(
            child: TextButton.icon(
              onPressed: () => notifier.goToStep(OnboardingStep.targetWeight),
              icon: const Icon(Icons.edit_outlined, size: 16),
              label: Text(text.targetSuggestionManualAction),
            ),
          ),
        ],
        const SizedBox(height: MealoraSpacing.lg),
        Text(
          hasSuggestions
              ? text.targetSuggestionNote
              : text.rejectionNoChangeNote,
          style: MealoraTypography.caption,
        ),
      ],
    );
  }
}
