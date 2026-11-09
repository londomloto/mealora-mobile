import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/format/id_formatters.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/domain/nutrition/activity_level.dart';
import 'package:mealora/domain/profile/profile_validation.dart';
import 'package:mealora/domain/profile/user_profile.dart';
import 'package:mealora/domain/program/program_code.dart';
import 'package:mealora/domain/program/program_proposal_inputs.dart';
import 'package:mealora/features/onboarding/onboarding_controller.dart'
    show profileRepositoryProvider;
import 'package:mealora/features/onboarding/widgets/onboarding_choice_card.dart';
import 'package:mealora/features/program/program_revision_review_screen.dart';
import 'package:mealora/features/program/program_revision_service.dart';
import 'package:mealora/features/program/widgets/program_shared.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// `34 · Ubah profil & target` (task 8.1): penyuntingan data profil yang
/// TIDAK langsung mengubah target yang berlaku, lalu menawarkan
/// peninjauan revisi target (task 8.2) lewat
/// `ProgramRevisionReviewScreen` yang sama dengan pergantian program
/// (`28`) — Design D5.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  UserProfile? _profile;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile = await ref.read(profileRepositoryProvider).current();
    if (!mounted) {
      return;
    }
    setState(() {
      _profile = profile;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final activeProgram = ref.watch(activeProgramProvider).valueOrNull;
    final profile = _profile;

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
                        text.editProfileContextLabel,
                        style: MealoraTypography.eyebrow,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: MealoraSpacing.xs),
                Text(text.editProfileTitle, style: MealoraTypography.title),
                const SizedBox(height: MealoraSpacing.xs),
                Text(
                  text.editProfileSubtitle,
                  style: MealoraTypography.subtitle,
                ),
                const SizedBox(height: MealoraSpacing.xl),
                if (_loading || profile == null)
                  const SizedBox.shrink()
                else ...<Widget>[
                  ProgramControlTile(
                    icon: Icons.height,
                    label: text.editProfileHeightLabel,
                    detail: profile.height == null
                        ? '—'
                        : '${IdFormat.integer(profile.height!.cm)} cm',
                    onTap: () => _editHeight(profile),
                  ),
                  ProgramControlTile(
                    icon: Icons.monitor_weight_outlined,
                    label: text.editProfileWeightLabel,
                    detail: profile.currentWeight == null
                        ? '—'
                        : '${IdFormat.decimal(profile.currentWeight!.kg)} kg',
                    onTap: () => _editWeight(profile),
                  ),
                  ProgramControlTile(
                    icon: Icons.directions_walk,
                    label: text.editProfileActivityLabel,
                    detail: profile.activityLevel == null
                        ? '—'
                        : _activityLabel(text, profile.activityLevel!),
                    onTap: () => _editActivity(profile),
                  ),
                  ProgramControlTile(
                    icon: Icons.straighten,
                    label: text.editProfileUnitsLabel,
                    detail: text.editProfileUnitsValue,
                    enabled: false,
                    onTap: () {},
                  ),
                  const SizedBox(height: MealoraSpacing.lg),
                  MealoraNoteCard(
                    icon: Icons.refresh,
                    title: text.editProfileReviewNoteTitle,
                    body: text.editProfileReviewNoteBody,
                  ),
                  if (activeProgram != null) ...<Widget>[
                    const SizedBox(height: MealoraSpacing.lg),
                    MealoraPrimaryButton(
                      label: text.editProfileReviewAction,
                      onPressed: () =>
                          _reviewNewTarget(profile, activeProgram.programCode),
                    ),
                  ],
                ],
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

  Future<void> _editHeight(UserProfile profile) async {
    final controller = TextEditingController(
      text: profile.height == null ? '' : profile.height!.cm.toStringAsFixed(0),
    );
    final text = AppText.of(context);
    String? error;
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(text.editProfileHeightLabel),
          content: MealoraField(
            label: text.editProfileHeightLabel,
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            errorText: error,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(text.completeCancelAction),
            ),
            TextButton(
              onPressed: () {
                final result = ProfileValueRules.height(
                  double.tryParse(
                        controller.text.trim().replaceAll(',', '.'),
                      ) ??
                      double.nan,
                );
                if (result.isErr) {
                  setDialogState(() => error = result.failureOrNull!.detail);
                  return;
                }
                Navigator.of(dialogContext).pop(true);
              },
              child: Text(text.reviewApproveAction),
            ),
          ],
        ),
      ),
    );
    if (saved != true) {
      return;
    }
    final result = ProfileValueRules.height(
      double.parse(controller.text.trim().replaceAll(',', '.')),
    );
    await ref
        .read(profileRepositoryProvider)
        .upsert(profile.copyWith(height: result.valueOrNull));
    await _load();
  }

  Future<void> _editWeight(UserProfile profile) async {
    final controller = TextEditingController(
      text: profile.currentWeight == null
          ? ''
          : profile.currentWeight!.kg.toString(),
    );
    final text = AppText.of(context);
    String? error;
    final saved = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (dialogContext, setDialogState) => AlertDialog(
          title: Text(text.editProfileWeightLabel),
          content: MealoraField(
            label: text.editProfileWeightLabel,
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            errorText: error,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: Text(text.completeCancelAction),
            ),
            TextButton(
              onPressed: () {
                final result = ProfileValueRules.currentWeight(
                  double.tryParse(
                        controller.text.trim().replaceAll(',', '.'),
                      ) ??
                      double.nan,
                );
                if (result.isErr) {
                  setDialogState(() => error = result.failureOrNull!.detail);
                  return;
                }
                Navigator.of(dialogContext).pop(true);
              },
              child: Text(text.reviewApproveAction),
            ),
          ],
        ),
      ),
    );
    if (saved != true) {
      return;
    }
    final result = ProfileValueRules.currentWeight(
      double.parse(controller.text.trim().replaceAll(',', '.')),
    );
    await ref
        .read(profileRepositoryProvider)
        .upsert(profile.copyWith(currentWeight: result.valueOrNull));
    await _load();
  }

  Future<void> _editActivity(UserProfile profile) async {
    final text = AppText.of(context);
    final picked = await showModalBottomSheet<ActivityLevel>(
      context: context,
      isScrollControlled: true,
      backgroundColor: MealoraColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(MealoraRadius.sheet),
        ),
      ),
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(MealoraSpacing.lg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                text.editProfileActivityLabel,
                style: MealoraTypography.sectionTitle,
              ),
              const SizedBox(height: MealoraSpacing.md),
              for (final level in ActivityLevel.values) ...<Widget>[
                OnboardingChoiceCard(
                  title: _activityLabel(text, level),
                  selected: profile.activityLevel == level,
                  onTap: () => Navigator.of(sheetContext).pop(level),
                ),
                const SizedBox(height: MealoraSpacing.sm),
              ],
            ],
          ),
        ),
      ),
    );
    if (picked == null) {
      return;
    }
    await ref
        .read(profileRepositoryProvider)
        .upsert(profile.copyWith(activityLevel: picked));
    await _load();
  }

  Future<void> _reviewNewTarget(
    UserProfile profile,
    ProgramCode programCode,
  ) async {
    final activeProgram = ref.read(activeProgramProvider).valueOrNull;
    if (activeProgram == null) {
      return;
    }
    final today = ref.read(clockProvider).today();
    final inputs = ProgramProposalInputs(
      ageYears: profile.ageYearsAsOf(today)!,
      biologicalInput: profile.biologicalInput!,
      height: profile.height!,
      currentWeight: profile.currentWeight!,
      activity: profile.activityLevel!,
      specific: activeProgram.inputSnapshot.specific,
    );
    final requiresTargetWeight =
        programCode == ProgramCode.weightLoss ||
        programCode == ProgramCode.weightGain;
    final requiresHabitFocus = programCode == ProgramCode.healthyEating;

    final service = ref.read(programRevisionServiceProvider);
    final outcome = service.preview(
      programCode: programCode,
      inputs: inputs,
      requiresTargetWeight: requiresTargetWeight,
      requiresHabitFocus: requiresHabitFocus,
    );

    if (!mounted) {
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProgramRevisionReviewScreen(
          profileId: profile.id,
          programCode: programCode,
          previewInputs: inputs,
          previewOutcome: outcome,
          requiresTargetWeight: requiresTargetWeight,
          requiresHabitFocus: requiresHabitFocus,
          currentProposal: activeProgram.proposal,
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
