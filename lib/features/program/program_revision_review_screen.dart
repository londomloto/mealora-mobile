import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/format/id_formatters.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/domain/program/program_code.dart';
import 'package:mealora/domain/program/program_proposal_inputs.dart';
import 'package:mealora/domain/program/program_target_proposal.dart';
import 'package:mealora/domain/program/target_suggestion.dart';
import 'package:mealora/domain/shared/program_outcome.dart';
import 'package:mealora/domain/shared/program_warning.dart';
import 'package:mealora/features/onboarding/onboarding_controller.dart'
    show nutritionPolicyProvider;
import 'package:mealora/features/onboarding/rejection_copy.dart';
import 'package:mealora/features/onboarding/widgets/target_suggestion_picker.dart';
import 'package:mealora/features/program/program_providers.dart';
import 'package:mealora/features/program/program_revision_service.dart';
import 'package:mealora/features/program/widgets/program_shared.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// Peninjauan target pengganti/revisi — dipakai baik oleh pergantian
/// program (`28` → `12`, task 6.1/6.2) maupun revisi target dari ubah
/// profil (`34`, task 8.2): keduanya layar pratinjau target yang sama
/// dengan bingkai berbeda (Design D5), bukan jalur aktivasi kedua (task
/// 6.2) — penerapannya sama-sama lewat `ProgramRevisionService.approve`
/// (`ChangeProgramCommand`, change 003).
class ProgramRevisionReviewScreen extends ConsumerStatefulWidget {
  const ProgramRevisionReviewScreen({
    required this.profileId,
    required this.programCode,
    required this.previewInputs,
    required this.previewOutcome,
    required this.requiresTargetWeight,
    required this.requiresHabitFocus,
    required this.buildCurrentInputs,
    this.currentProposal,
    super.key,
  });

  final String profileId;
  final ProgramCode programCode;
  final ProgramProposalInputs previewInputs;
  final ProgramOutcome<ProgramTargetProposal> previewOutcome;
  final bool requiresTargetWeight;
  final bool requiresHabitFocus;

  /// Membaca ulang fakta profil terkini saat disetujui (task 6.3, 8.2) —
  /// bukan memakai [previewInputs] yang mungkin sudah usang.
  final Future<ProgramProposalInputs> Function() buildCurrentInputs;

  /// Target yang SEDANG berlaku, untuk perbandingan apa adanya tanpa
  /// penilaian (task 8.3) — `null` pada jalur pergantian program (`28`),
  /// terisi pada jalur revisi profil (`34`).
  final ProgramTargetProposal? currentProposal;

  @override
  ConsumerState<ProgramRevisionReviewScreen> createState() =>
      _ProgramRevisionReviewScreenState();
}

class _ProgramRevisionReviewScreenState
    extends ConsumerState<ProgramRevisionReviewScreen> {
  late ProgramOutcome<ProgramTargetProposal> _outcome;
  late ProgramProposalInputs _previewInputs;
  bool _approving = false;

  @override
  void initState() {
    super.initState();
    _outcome = widget.previewOutcome;
    _previewInputs = widget.previewInputs;
  }

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final outcome = _outcome;

    if (outcome is! Approved<ProgramTargetProposal>) {
      // Saran berat minimum (change 019, desain 26c). Alur ganti program
      // tidak punya tanggal tujuan, jadi hanya kasus BMI yang mungkin.
      final suggestions = switch (outcome) {
        NeedsUserCorrection<ProgramTargetProposal>(
          reasonCode: final code,
          details: final details,
        ) =>
          TargetSuggestionCalculator(ref.read(nutritionPolicyProvider)).suggest(
            reasonCode: code,
            details: details,
            program: widget.programCode,
            height: _previewInputs.height,
            currentWeight: _previewInputs.currentWeight,
            asOfDate: ref.read(clockProvider).today(),
            targetWeightKg: _previewInputs.specific.targetWeight?.kg,
            targetDate: null,
          ),
        _ => const <TargetSuggestion>[],
      };
      return _RevisionRejectedView(
        outcome: outcome,
        suggestions: suggestions,
      );
    }
    final proposal = outcome.value;

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
                        text.reviewStepLabel,
                        style: MealoraTypography.eyebrow,
                      ),
                      const SizedBox(height: MealoraSpacing.xs),
                      Text(text.reviewTitle, style: MealoraTypography.title),
                      const SizedBox(height: MealoraSpacing.xs),
                      Text(
                        text.reviewSubtitle,
                        style: MealoraTypography.subtitle,
                      ),
                      const SizedBox(height: MealoraSpacing.xl),
                      TargetHeroCard(
                        eyebrow: text.reviewTargetLabel,
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
                        caption: text.reviewTargetDisclaimer,
                      ),
                      if (widget.currentProposal != null) ...<Widget>[
                        const SizedBox(height: MealoraSpacing.lg),
                        Text(
                          text.revisionComparisonHeading,
                          style: MealoraTypography.sectionTitle,
                        ),
                        const SizedBox(height: MealoraSpacing.sm),
                        FactsCard(
                          rows: <FactRow>[
                            FactRow(
                              label: text.revisionComparisonCurrentLabel,
                              value: _energyLabel(
                                text,
                                widget.currentProposal!,
                              ),
                            ),
                            FactRow(
                              label: text.revisionComparisonNewLabel,
                              value: _energyLabel(text, proposal),
                            ),
                          ],
                        ),
                      ],
                      const SizedBox(height: MealoraSpacing.xl),
                      Text(
                        text.reviewBasisHeading,
                        style: MealoraTypography.sectionTitle,
                      ),
                      const SizedBox(height: MealoraSpacing.sm),
                      FactsCard(
                        rows: <FactRow>[
                          FactRow(
                            label: text.howCalculatedWeightLabel,
                            value:
                                '${IdFormat.decimal(_previewInputs.currentWeight.kg)} kg',
                          ),
                          FactRow(
                            label: text.reviewBasisEquationLabel,
                            value:
                                'Mifflin–St Jeor · ${proposal.calculatorVersion}',
                          ),
                        ],
                      ),
                      if (proposal.warnings.isNotEmpty) ...<Widget>[
                        const SizedBox(height: MealoraSpacing.lg),
                        for (final warning in proposal.warnings) ...<Widget>[
                          MealoraNoteCard(
                            icon: Icons.warning_amber_rounded,
                            background: MealoraColors.accent.withValues(
                              alpha: 0.14,
                            ),
                            foreground: MealoraColors.accent,
                            body: _warningBody(text, warning),
                          ),
                          const SizedBox(height: MealoraSpacing.sm),
                        ],
                      ],
                      const SizedBox(height: MealoraSpacing.lg),
                      MealoraNoteCard(
                        icon: Icons.shield_outlined,
                        background: MealoraColors.accent.withValues(
                          alpha: 0.14,
                        ),
                        foreground: MealoraColors.accent,
                        title: text.reviewVersionHeading,
                        body: text.reviewVersionDetail,
                      ),
                      const SizedBox(height: MealoraSpacing.xs),
                      Text(
                        text.reviewVersionLine(
                          proposal.calculatorVersion,
                          proposal.policyVersion,
                        ),
                        style: MealoraTypography.caption,
                      ),
                      const SizedBox(height: MealoraSpacing.lg),
                      Text(
                        widget.currentProposal == null
                            ? text.revisionCancelNoteChange
                            : text.revisionCancelNoteProfile,
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
                  label: text.reviewApproveAction,
                  onPressed: _approving ? null : _approve,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _energyLabel(AppText text, ProgramTargetProposal proposal) {
    if (!proposal.showsEnergyTarget || proposal.energyTarget == null) {
      return text.reviewNoEnergyTargetNote;
    }
    return '${IdFormat.integer(proposal.energyTarget!.kcal)} ${text.unitKilocalorie}';
  }

  String _warningBody(AppText text, ProgramWarning warning) =>
      switch (warning) {
        ProgramWarning.floorApplied => text.reviewWarningFloorApplied,
        ProgramWarning.relativePaceCapApplied =>
          text.reviewWarningRelativePaceCapApplied,
        ProgramWarning.carbohydrateBelowRecommendedRange =>
          text.reviewWarningCarbohydrateBelowRecommendedRange,
      };

  Future<void> _approve() async {
    setState(() => _approving = true);
    final currentInputs = await widget.buildCurrentInputs();
    final service = ref.read(programRevisionServiceProvider);
    final result = await service.approve(
      profileId: widget.profileId,
      programCode: widget.programCode,
      previewInputs: _previewInputs,
      currentInputs: currentInputs,
      requiresTargetWeight: widget.requiresTargetWeight,
      requiresHabitFocus: widget.requiresHabitFocus,
    );
    if (!mounted) {
      return;
    }
    setState(() => _approving = false);

    switch (result) {
      case RevisionSucceeded():
        bumpProgramRefresh(ref);
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      case RevisionInputsChanged(
        :final refreshedInputs,
        :final refreshedOutcome,
      ):
        setState(() {
          _previewInputs = refreshedInputs;
          _outcome = refreshedOutcome;
        });
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(content: Text(AppText.of(context).reviewChangedSubtitle)),
          );
      case RevisionRejected(:final outcome):
        setState(() => _outcome = outcome);
      case RevisionNoRunningProgram():
      case RevisionFailed():
        if (mounted) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(AppText.of(context).revisionFailedMessage),
              ),
            );
        }
    }
  }
}

class _RevisionRejectedView extends StatelessWidget {
  const _RevisionRejectedView({
    required this.outcome,
    this.suggestions = const <TargetSuggestion>[],
  });

  final ProgramOutcome<ProgramTargetProposal> outcome;

  /// Dipilih lewat tombol; berat saran dikembalikan ke layar pemilihan
  /// program sebagai hasil rute, yang lalu meninjau ulang (change 019).
  final List<TargetSuggestion> suggestions;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final copy = switch (outcome) {
      NeedsUserCorrection<ProgramTargetProposal>(
        reasonCode: final code,
        details: final details,
      ) =>
        rejectionCopyForReasonCode(text, code, details: details),
      NeedsProfessionalReview<ProgramTargetProposal>(
        reasonCode: final code,
        details: final details,
      ) =>
        rejectionCopyForReasonCode(text, code, details: details),
      UnsupportedProfile<ProgramTargetProposal>(reasonCode: final code) =>
        rejectionCopyForReasonCode(text, code),
      MissingValidatedPolicy<ProgramTargetProposal>() =>
        rejectionCopyForMissingValidatedPolicy(text),
      Approved<ProgramTargetProposal>() => throw StateError('unreachable'),
    };

    return Scaffold(
      backgroundColor: MealoraColors.background,
      body: MealoraBlobBackdrop(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(MealoraSpacing.screenGutter),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Semantics(
                      button: true,
                      label: text.onboardingBackSemantics,
                      child: InkWell(
                        onTap: () => Navigator.of(context).pop(),
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
                        text.revisionRejectedContextLabel,
                        style: MealoraTypography.eyebrow,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: MealoraSpacing.xs),
                Text(
                  text.revisionRejectedTitle,
                  style: MealoraTypography.title,
                ),
                const SizedBox(height: MealoraSpacing.lg),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(MealoraSpacing.lg),
                  decoration: BoxDecoration(
                    color: MealoraColors.danger.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(
                      MealoraRadius.cardLarge,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(copy.heading, style: MealoraTypography.headline),
                      const SizedBox(height: MealoraSpacing.xs),
                      Text(
                        copy.explanation,
                        style: MealoraTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (suggestions.isNotEmpty &&
                    outcome
                        is NeedsUserCorrection<ProgramTargetProposal>) ...<
                  Widget
                >[
                  const SizedBox(height: MealoraSpacing.lg),
                  TargetSuggestionPicker(
                    suggestions: suggestions,
                    reasonCode:
                        (outcome as NeedsUserCorrection<ProgramTargetProposal>)
                            .reasonCode,
                    selectedIndex: 0,
                    onSelected: (_) {},
                  ),
                  const SizedBox(height: MealoraSpacing.md),
                  MealoraPrimaryButton(
                    label: text.targetSuggestionApplyAction,
                    onPressed: () => Navigator.of(
                      context,
                    ).pop<double>(suggestions.first.targetWeightKg),
                  ),
                  const SizedBox(height: MealoraSpacing.xs),
                  Center(
                    child: TextButton.icon(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: Text(text.targetSuggestionManualAction),
                    ),
                  ),
                ],
                const SizedBox(height: MealoraSpacing.lg),
                Text(
                  suggestions.isNotEmpty
                      ? text.targetSuggestionNote
                      : text.revisionRejectedNoChangeNote,
                  style: MealoraTypography.caption,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
