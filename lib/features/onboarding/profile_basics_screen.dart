import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/domain/nutrition/biological_input.dart';
import 'package:mealora/features/onboarding/onboarding_controller.dart';
import 'package:mealora/features/onboarding/onboarding_step.dart';
import 'package:mealora/features/onboarding/widgets/onboarding_choice_card.dart';
import 'package:mealora/features/onboarding/widgets/onboarding_scaffold.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// `08 · Profil awal` (task 4.2): nama panggilan opsional, tanggal lahir,
/// tinggi badan, berat saat ini, dan masukan biologis untuk persamaan
/// energi — dengan keterangan bahwa masukan itu dipakai hanya untuk
/// persamaan, bukan identitas gender (task 4.3, FRS 2.3.3).
class OnboardingProfileBasicsScreen extends ConsumerStatefulWidget {
  const OnboardingProfileBasicsScreen({super.key});

  @override
  ConsumerState<OnboardingProfileBasicsScreen> createState() =>
      _OnboardingProfileBasicsScreenState();
}

class _OnboardingProfileBasicsScreenState
    extends ConsumerState<OnboardingProfileBasicsScreen> {
  late final TextEditingController _nicknameController;
  late final TextEditingController _heightController;
  late final TextEditingController _weightController;

  DateTime? _birthDate;
  BiologicalInput? _biologicalInput;

  String? _birthDateError;
  String? _heightError;
  String? _weightError;
  String? _biologicalInputError;

  @override
  void initState() {
    super.initState();
    final draft = ref.read(onboardingControllerProvider).valueOrNull;
    _nicknameController = TextEditingController(text: draft?.nickname ?? '');
    _heightController = TextEditingController(
      text: draft?.height == null ? '' : draft!.height!.cm.toString(),
    );
    _weightController = TextEditingController(
      text: draft?.currentWeight == null
          ? ''
          : draft!.currentWeight!.kg.toString(),
    );
    final birthDate = draft?.birthDate;
    _birthDate = birthDate == null
        ? null
        : DateTime(birthDate.year, birthDate.month, birthDate.day);
    _biologicalInput = draft?.biologicalInput;
  }

  @override
  void dispose() {
    _nicknameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final today = ref.read(clockProvider).today();

    return OnboardingScaffold(
      contextLabel: text.onboardingStepLabel(
        OnboardingStep.profileBasics.displayNumber!,
        OnboardingStepDisplay.displayTotal,
      ),
      title: text.onboardingProfileTitle,
      subtitle: text.onboardingProfileSubtitle,
      primaryActionLabel: text.onboardingContinueAction,
      onPrimaryAction: () => _submit(today),
      children: <Widget>[
        MealoraField(
          label: text.onboardingNicknameLabel,
          hint: text.onboardingNicknameHint,
          controller: _nicknameController,
        ),
        const SizedBox(height: MealoraSpacing.lg),
        MealoraDateField(
          label: text.onboardingBirthDateLabel,
          hint: text.onboardingBirthDateHint,
          value: _birthDate,
          firstDate: DateTime(today.year - 120),
          lastDate: DateTime(today.year, today.month, today.day),
          errorText: _birthDateError,
          onChanged: (value) => setState(() {
            _birthDate = value;
            _birthDateError = null;
          }),
        ),
        const SizedBox(height: MealoraSpacing.lg),
        MealoraField(
          label: text.onboardingHeightLabel,
          hint: text.onboardingHeightHint,
          controller: _heightController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          errorText: _heightError,
        ),
        const SizedBox(height: MealoraSpacing.lg),
        MealoraField(
          label: text.onboardingWeightLabel,
          hint: text.onboardingWeightHint,
          controller: _weightController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          errorText: _weightError,
        ),
        const SizedBox(height: MealoraSpacing.lg),
        Text(
          text.onboardingBiologicalInputLabel,
          style: MealoraTypography.label,
        ),
        const SizedBox(height: MealoraSpacing.xs),
        OnboardingChoiceCard(
          title: text.onboardingBiologicalInputFemale,
          leading: Icons.female_rounded,
          leadingBackground: MealoraColors.peach.withValues(alpha: 0.16),
          leadingForeground: MealoraColors.peach,
          selected: _biologicalInput == BiologicalInput.female,
          onTap: () =>
              setState(() => _biologicalInput = BiologicalInput.female),
        ),
        const SizedBox(height: MealoraSpacing.xs),
        OnboardingChoiceCard(
          title: text.onboardingBiologicalInputMale,
          leading: Icons.male_rounded,
          leadingBackground: MealoraColors.info.withValues(alpha: 0.14),
          leadingForeground: MealoraColors.info,
          selected: _biologicalInput == BiologicalInput.male,
          onTap: () => setState(() => _biologicalInput = BiologicalInput.male),
        ),
        if (_biologicalInputError != null) ...<Widget>[
          const SizedBox(height: MealoraSpacing.xxs),
          Semantics(
            liveRegion: true,
            child: Text(
              _biologicalInputError!,
              style: MealoraTypography.caption.copyWith(
                color: MealoraColors.danger,
              ),
            ),
          ),
        ],
        const SizedBox(height: MealoraSpacing.xs),
        Text(
          text.onboardingBiologicalInputDisclosure,
          style: MealoraTypography.caption,
        ),
      ],
    );
  }

  Future<void> _submit(LocalDate today) async {
    final text = AppText.of(context);
    final heightValue = double.tryParse(
      _heightController.text.trim().replaceAll(',', '.'),
    );
    final weightValue = double.tryParse(
      _weightController.text.trim().replaceAll(',', '.'),
    );
    final birthDate = _birthDate;

    setState(() {
      _birthDateError = birthDate == null
          ? text.onboardingRequiredBirthDate
          : null;
      _heightError = heightValue == null ? text.onboardingRequiredHeight : null;
      _weightError = weightValue == null ? text.onboardingRequiredWeight : null;
      _biologicalInputError = _biologicalInput == null
          ? text.onboardingRequiredBiologicalInput
          : null;
    });
    if (birthDate == null ||
        heightValue == null ||
        weightValue == null ||
        _biologicalInput == null) {
      return;
    }

    final result = await ref
        .read(onboardingControllerProvider.notifier)
        .saveProfileBasics(
          nickname: _nicknameController.text,
          birthDate: LocalDate(birthDate.year, birthDate.month, birthDate.day),
          heightCm: heightValue,
          currentWeightKg: weightValue,
          biologicalInput: _biologicalInput!,
          today: today,
        );

    if (!mounted) {
      return;
    }
    if (result.isErr) {
      final failure = result.failureOrNull!;
      setState(() {
        switch (failure.field) {
          case 'birthDate':
            _birthDateError = failure.detail;
          case 'height':
            _heightError = failure.detail;
          case 'currentWeight':
            _weightError = failure.detail;
        }
      });
    }
  }
}
