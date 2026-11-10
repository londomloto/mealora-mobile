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
        _ProfileFormCard(
          nicknameController: _nicknameController,
          heightController: _heightController,
          weightController: _weightController,
          birthDate: _birthDate,
          biologicalInput: _biologicalInput,
          firstDate: DateTime(today.year - 120),
          lastDate: DateTime(today.year, today.month, today.day),
          onBirthDateChanged: (value) => setState(() {
            _birthDate = value;
            _birthDateError = null;
          }),
          onBiologicalInputChanged: (value) => setState(() {
            _biologicalInput = value;
            _biologicalInputError = null;
          }),
        ),
        if (_birthDateError != null ||
            _heightError != null ||
            _weightError != null ||
            _biologicalInputError != null) ...<Widget>[
          const SizedBox(height: MealoraSpacing.xxs),
          Semantics(
            liveRegion: true,
            child: Text(
              _birthDateError ??
                  _heightError ??
                  _weightError ??
                  _biologicalInputError!,
              style: MealoraTypography.caption.copyWith(
                color: MealoraColors.danger,
              ),
            ),
          ),
        ],
        const SizedBox(height: MealoraSpacing.md),
        MealoraNoteCard(
          icon: Icons.info_outline,
          body: text.onboardingBiologicalInputDisclosure,
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

class _ProfileFormCard extends StatelessWidget {
  const _ProfileFormCard({
    required this.nicknameController,
    required this.heightController,
    required this.weightController,
    required this.birthDate,
    required this.biologicalInput,
    required this.firstDate,
    required this.lastDate,
    required this.onBirthDateChanged,
    required this.onBiologicalInputChanged,
  });

  final TextEditingController nicknameController;
  final TextEditingController heightController;
  final TextEditingController weightController;
  final DateTime? birthDate;
  final BiologicalInput? biologicalInput;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onBirthDateChanged;
  final ValueChanged<BiologicalInput> onBiologicalInputChanged;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return MealoraCard(
      padding: const EdgeInsets.symmetric(
        horizontal: MealoraSpacing.sm,
        vertical: MealoraSpacing.xs,
      ),
      child: Column(
        children: <Widget>[
          _EditableProfileRow(
            icon: Icons.person_outline,
            label: text.onboardingNicknameLabel,
            hint: text.onboardingNicknameHint,
            controller: nicknameController,
          ),
          const Divider(),
          _ActionProfileRow(
            icon: Icons.calendar_today_outlined,
            label: text.onboardingBirthDateLabel,
            value: birthDate == null
                ? text.onboardingBirthDateHint
                : MaterialLocalizations.of(
                    context,
                  ).formatMediumDate(birthDate!),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: birthDate ?? lastDate,
                firstDate: firstDate,
                lastDate: lastDate,
              );
              if (picked != null) onBirthDateChanged(picked);
            },
          ),
          const Divider(),
          _EditableProfileRow(
            icon: Icons.height,
            label: text.onboardingHeightLabel,
            hint: text.onboardingHeightHint,
            controller: heightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            suffix: 'cm',
          ),
          const Divider(),
          _EditableProfileRow(
            icon: Icons.monitor_weight_outlined,
            label: text.onboardingWeightLabel,
            hint: text.onboardingWeightHint,
            controller: weightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            suffix: 'kg',
          ),
          const Divider(),
          _ActionProfileRow(
            icon: Icons.balance_outlined,
            label: text.onboardingBiologicalInputLabel,
            value: switch (biologicalInput) {
              BiologicalInput.female => text.onboardingBiologicalInputFemale,
              BiologicalInput.male => text.onboardingBiologicalInputMale,
              null => text.onboardingBiologicalInputHint,
            },
            onTap: () => _pickBiologicalInput(context),
          ),
        ],
      ),
    );
  }

  Future<void> _pickBiologicalInput(BuildContext context) async {
    final text = AppText.of(context);
    final value = await showModalBottomSheet<BiologicalInput>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.female_rounded),
              title: Text(text.onboardingBiologicalInputFemale),
              onTap: () => Navigator.pop(context, BiologicalInput.female),
            ),
            ListTile(
              leading: const Icon(Icons.male_rounded),
              title: Text(text.onboardingBiologicalInputMale),
              onTap: () => Navigator.pop(context, BiologicalInput.male),
            ),
          ],
        ),
      ),
    );
    if (value != null) onBiologicalInputChanged(value);
  }
}

class _EditableProfileRow extends StatelessWidget {
  const _EditableProfileRow({
    required this.icon,
    required this.label,
    required this.hint,
    required this.controller,
    this.keyboardType,
    this.suffix,
  });

  final IconData icon;
  final String label;
  final String hint;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    return _ProfileRowShell(
      icon: icon,
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        style: MealoraTypography.body,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: MealoraTypography.caption,
          floatingLabelStyle: MealoraTypography.caption,
          floatingLabelBehavior: FloatingLabelBehavior.always,
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
    );
  }
}

class _ActionProfileRow extends StatelessWidget {
  const _ActionProfileRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(MealoraRadius.iconField),
    child: _ProfileRowShell(
      icon: icon,
      trailing: const Icon(
        Icons.chevron_right,
        size: MealoraIconSize.action,
        color: MealoraColors.affordance,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: MealoraTypography.caption),
          Text(value, style: MealoraTypography.body),
        ],
      ),
    ),
  );
}

class _ProfileRowShell extends StatelessWidget {
  const _ProfileRowShell({
    required this.icon,
    required this.child,
    this.trailing,
  });

  final IconData icon;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(
      context,
    ).scale(1).clamp(1, 2).toDouble();
    final rowHeight = textScale == 1 ? 60.0 : 120 * textScale;
    return SizedBox(
      height: rowHeight,
      child: Row(
        children: <Widget>[
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: MealoraColors.iconField,
              borderRadius: BorderRadius.circular(MealoraRadius.iconField),
            ),
            child: Icon(icon, size: 18, color: MealoraColors.primaryDeep),
          ),
          const SizedBox(width: MealoraSpacing.sm),
          Expanded(child: child),
          ?trailing,
        ],
      ),
    );
  }
}
