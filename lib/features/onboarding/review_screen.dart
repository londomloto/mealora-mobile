import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/format/id_formatters.dart';
import 'package:mealora/domain/nutrition/activity_level.dart';
import 'package:mealora/domain/program/commands/activation_result.dart';
import 'package:mealora/domain/program/program_target_proposal.dart';
import 'package:mealora/domain/shared/program_outcome.dart';
import 'package:mealora/features/onboarding/onboarding_controller.dart';
import 'package:mealora/features/onboarding/onboarding_draft.dart';
import 'package:mealora/features/onboarding/onboarding_step.dart';
import 'package:mealora/features/onboarding/rejection_screen.dart';
import 'package:mealora/features/onboarding/widgets/onboarding_scaffold.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// `12 · Tinjau target` (task 5.1): nilai target, dasar perkiraan, asumsi,
/// peringatan, versi kalkulator dan kebijakan, dan pernyataan bahwa belum
/// ada program aktif (FRS 4.3.1/4.3.2/4.3.3).
///
/// Juga menangani "masukan berubah sejak pratinjau" (`12b`, Design D5)
/// sebagai keadaan internal layar ini — bahasa visualnya mengikuti `12`
/// agar terasa sebagai kelanjutan, bukan sebagai gangguan.
class OnboardingReviewScreen extends ConsumerStatefulWidget {
  const OnboardingReviewScreen({super.key});

  @override
  ConsumerState<OnboardingReviewScreen> createState() =>
      _OnboardingReviewScreenState();
}

class _OnboardingReviewScreenState
    extends ConsumerState<OnboardingReviewScreen> {
  bool _showingChangedState = false;
  bool _approving = false;
  double? _previousWeightKg;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(onboardingControllerProvider.notifier).prepareReview();
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final draft = ref.watch(onboardingControllerProvider).valueOrNull;

    if (draft?.lastOutcome == null) {
      return const Scaffold(
        backgroundColor: MealoraColors.background,
        body: SizedBox.shrink(),
      );
    }

    final outcome = draft!.lastOutcome!;
    if (outcome is! Approved<ProgramTargetProposal>) {
      return OnboardingRejectionScreen(outcome: outcome);
    }
    final proposal = outcome.value;

    return _showingChangedState
        ? _buildChangedState(text, draft, proposal)
        : _buildReview(text, draft, proposal);
  }

  Widget _buildReview(
    AppText text,
    OnboardingDraft draft,
    ProgramTargetProposal proposal,
  ) {
    return OnboardingScaffold(
      contextLabel: text.onboardingStepLabel(
        OnboardingStep.review.displayNumber!,
        OnboardingStepDisplay.displayTotal,
      ),
      title: text.reviewTitle,
      subtitle: text.reviewSubtitle,
      primaryActionLabel: text.reviewApproveAction,
      onPrimaryAction: _approving ? null : _approve,
      children: <Widget>[
        _TargetCard(
          label: text.reviewTargetLabel,
          proposal: proposal,
          noEnergyTargetNote: text.reviewNoEnergyTargetNote,
          disclaimer: text.reviewTargetDisclaimer,
        ),
        const SizedBox(height: MealoraSpacing.xl),
        Text(
          text.reviewBasisHeading,
          style: MealoraTypography.compactSectionTitle,
        ),
        const SizedBox(height: MealoraSpacing.sm),
        MealoraCard(
          padding: const EdgeInsets.symmetric(
            horizontal: MealoraSpacing.md,
            vertical: MealoraSpacing.xs,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              _BasisRow(
                label: text.reviewBasisProfileLabel,
                value: text.reviewBasisProfileValue,
              ),
              const Divider(height: 1),
              _BasisRow(
                label: text.reviewBasisActivityLabel,
                value: _activityLabel(text, draft.activityLevel!),
              ),
              const Divider(height: 1),
              _BasisRow(
                label: text.reviewBasisEquationLabel,
                value: 'Mifflin–St Jeor · ${proposal.calculatorVersion}',
              ),
            ],
          ),
        ),
        const SizedBox(height: MealoraSpacing.xl),
        MealoraNoteCard(
          icon: Icons.shield_outlined,
          background: MealoraColors.noteWarning,
          foreground: MealoraColors.accent,
          title: text.reviewVersionHeading,
          body:
              '${text.reviewVersionDetail}\n'
              '${text.reviewVersionLine(proposal.calculatorVersion, proposal.policyVersion)}',
        ),
        const SizedBox(height: MealoraSpacing.lg),
        Text(text.reviewNoActiveProgramNote, style: MealoraTypography.caption),
      ],
    );
  }

  Widget _buildChangedState(
    AppText text,
    OnboardingDraft draft,
    ProgramTargetProposal proposal,
  ) {
    return OnboardingScaffold(
      contextLabel: text.reviewChangedContextLabel,
      title: text.reviewChangedTitle,
      subtitle: text.reviewChangedSubtitle,
      primaryActionLabel: text.reviewChangedAction,
      onPrimaryAction: _approving
          ? null
          : () => setState(() => _showingChangedState = false),
      children: <Widget>[
        Text(text.reviewChangedHeading, style: MealoraTypography.sectionTitle),
        const SizedBox(height: MealoraSpacing.sm),
        MealoraCard(
          child: _BasisRow(
            label: text.reviewChangedFieldWeight,
            value: text.reviewChangedValue(
              _previousWeightKg == null
                  ? '—'
                  : '${IdFormat.decimal(_previousWeightKg!)} kg',
              '${IdFormat.decimal(draft.previewInputs!.currentWeight.kg)} kg',
            ),
          ),
        ),
        const SizedBox(height: MealoraSpacing.xl),
        _TargetCard(
          label: text.reviewChangedTargetLabel,
          proposal: proposal,
          noEnergyTargetNote: text.reviewNoEnergyTargetNote,
          disclaimer: text.reviewTargetDisclaimer,
        ),
        const SizedBox(height: MealoraSpacing.xl),
        MealoraNoteCard(
          icon: Icons.refresh,
          background: MealoraColors.noteInfo,
          foreground: MealoraColors.info,
          title: text.reviewChangedNoteHeading,
          body: text.reviewChangedNoteDetail,
        ),
        const SizedBox(height: MealoraSpacing.lg),
        Text(text.reviewChangedConfirmation, style: MealoraTypography.caption),
      ],
    );
  }

  String _activityLabel(AppText text, ActivityLevel level) => switch (level) {
    ActivityLevel.sedentary => text.onboardingActivitySedentaryTitle,
    ActivityLevel.moderatelyActive => text.onboardingActivityModerateTitle,
    ActivityLevel.veryActive => text.onboardingActivityVeryTitle,
  };

  Future<void> _approve() async {
    final draftBefore = ref.read(onboardingControllerProvider).valueOrNull;
    final weightBefore = draftBefore?.previewInputs?.currentWeight.kg;

    setState(() => _approving = true);
    final result = await ref
        .read(onboardingControllerProvider.notifier)
        .approve();
    if (!mounted) {
      return;
    }
    setState(() => _approving = false);
    if (result is ActivationInputsChangedSincePreview) {
      setState(() {
        _previousWeightKg = weightBefore;
        _showingChangedState = true;
      });
    } else if (result is ActivationSucceeded) {
      // Pemasangan baru: `OnboardingFlow` adalah seluruh isi di belakang
      // gerbang peluncuran (bootstrap.dart) — gerbang itu sendiri
      // berpindah ke `AppShell` begitu `isOnboardingCompleteProvider`
      // membaca ulang (task 5.5), tidak ada rute untuk ditutup di sini.
      //
      // Melewati pemilihan lalu memilih program lagi (task 6.4/6.5):
      // `program_screen.dart` mendorong `OnboardingFlow` sebagai rute di
      // atas `AppShell` yang sudah tampil — rute itu yang ditutup di sini
      // supaya pengguna mendarat kembali di `AppShell` (bukan ruang Hari
      // ini yang baru, karena `AppShell`-nya sudah ada di bawah).
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    }
  }
}

class _TargetCard extends StatelessWidget {
  const _TargetCard({
    required this.label,
    required this.proposal,
    required this.noEnergyTargetNote,
    required this.disclaimer,
  });

  final String label;
  final ProgramTargetProposal proposal;
  final String noEnergyTargetNote;
  final String disclaimer;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(minHeight: 172),
      padding: const EdgeInsets.all(MealoraSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment(0.34, -0.94),
          end: Alignment(-0.34, 0.94),
          colors: MealoraColors.heroGradient,
          stops: MealoraColors.heroGradientStops,
        ),
        borderRadius: BorderRadius.circular(MealoraRadius.welcomeCard),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: MealoraColors.shadowHero,
            offset: Offset(0, 16),
            blurRadius: 36,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(
            label,
            textAlign: TextAlign.center,
            style: MealoraTypography.eyebrow.copyWith(
              color: MealoraColors.onPrimaryEyebrow,
              letterSpacing: 1.3,
            ),
          ),
          const SizedBox(height: 2),
          if (proposal.showsEnergyTarget && proposal.energyTarget != null)
            Text(
              IdFormat.integer(proposal.energyTarget!.kcal),
              textAlign: TextAlign.center,
              style: MealoraTypography.targetValue,
            )
          else
            Padding(
              padding: const EdgeInsets.symmetric(vertical: MealoraSpacing.xs),
              child: Text(
                noEnergyTargetNote,
                textAlign: TextAlign.center,
                style: MealoraTypography.body.copyWith(
                  color: MealoraColors.onPrimary,
                ),
              ),
            ),
          if (proposal.showsEnergyTarget && proposal.energyTarget != null) ...[
            const SizedBox(height: 2),
            Text(
              '${text.unitKilocalorie} / hari',
              textAlign: TextAlign.center,
              style: MealoraTypography.targetUnit,
            ),
          ],
          const SizedBox(height: 2),
          Text(
            disclaimer,
            textAlign: TextAlign.center,
            style: MealoraTypography.caption.copyWith(
              color: MealoraColors.onPrimaryFaint,
            ),
          ),
        ],
      ),
    );
  }
}

class _BasisRow extends StatelessWidget {
  const _BasisRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 44),
      child: Row(
        children: <Widget>[
          Expanded(child: Text(label, style: MealoraTypography.reviewLabel)),
          Flexible(
            child: Text(
              value,
              style: MealoraTypography.reviewValue,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
