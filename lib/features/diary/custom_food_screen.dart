import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/errors/failure.dart';
import 'package:mealora/core/errors/result.dart';
import 'package:mealora/core/validation/value_rules.dart';
import 'package:mealora/domain/food/food_repository.dart';
import 'package:mealora/domain/food/nutrition_profile.dart';
import 'package:mealora/domain/shared/units.dart';
import 'package:mealora/features/diary/diary_providers.dart';
import 'package:mealora/features/diary/serving_detail_screen.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// `15 · Makanan buatan sendiri` (task 6.6/6.7): nama, ukuran sajian, dan
/// nilai gizi — nilai belum diketahui dikosongkan, bukan nol (spec
/// food-catalog, "Pengguna dapat membuat makanan sendiri").
class CustomFoodScreen extends ConsumerStatefulWidget {
  const CustomFoodScreen({super.key});

  @override
  ConsumerState<CustomFoodScreen> createState() => _CustomFoodScreenState();
}

class _CustomFoodScreenState extends ConsumerState<CustomFoodScreen> {
  final _name = TextEditingController();
  final _serving = TextEditingController();
  final _energy = TextEditingController();
  final _protein = TextEditingController();
  final _carbohydrate = TextEditingController();
  final _fat = TextEditingController();

  String? _error;
  bool _saving = false;

  @override
  void dispose() {
    _name.dispose();
    _serving.dispose();
    _energy.dispose();
    _protein.dispose();
    _carbohydrate.dispose();
    _fat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);

    return Scaffold(
      backgroundColor: MealoraColors.background,
      body: MealoraBlobBackdrop(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              MealoraSpacing.programHeroGutter,
              MealoraSpacing.lg,
              MealoraSpacing.programHeroGutter,
              MealoraSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  text.customFoodContextLabel,
                  style: MealoraTypography.eyebrow,
                ),
                const SizedBox(height: MealoraSpacing.xs),
                Text(text.customFoodTitle, style: MealoraTypography.title),
                const SizedBox(height: MealoraSpacing.xxs),
                Text(
                  text.customFoodSubtitle,
                  style: MealoraTypography.subtitle,
                ),
                const SizedBox(height: MealoraSpacing.lg),
                _GlassInputField(
                  label: text.customFoodNameLabel,
                  hint: text.customFoodNameHint,
                  controller: _name,
                  icon: Icons.edit_outlined,
                ),
                const SizedBox(height: MealoraSpacing.md),
                _GlassInputField(
                  label: text.customFoodServingLabel,
                  hint: text.customFoodServingHint,
                  controller: _serving,
                  icon: Icons.keyboard_arrow_down_rounded,
                ),
                const SizedBox(height: MealoraSpacing.lg),
                Text(
                  text.customFoodNutritionHeading,
                  style: MealoraTypography.headline,
                ),
                const SizedBox(height: MealoraSpacing.sm),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _NutrientField(
                        label: text.nutrientEnergy,
                        unit: text.unitKilocalorie,
                        controller: _energy,
                        accent: MealoraColors.amberText,
                        background: MealoraColors.iconFieldAmber,
                      ),
                    ),
                    const SizedBox(width: MealoraSpacing.sm),
                    Expanded(
                      child: _NutrientField(
                        label: text.nutrientProtein,
                        unit: text.unitGram,
                        controller: _protein,
                        accent: MealoraColors.primary,
                        background: MealoraColors.iconFieldGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: MealoraSpacing.sm),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _NutrientField(
                        label: text.nutrientCarbohydrate,
                        unit: text.unitGram,
                        controller: _carbohydrate,
                        accent: MealoraColors.amberText,
                        background: MealoraColors.iconFieldAmber,
                      ),
                    ),
                    const SizedBox(width: MealoraSpacing.sm),
                    Expanded(
                      child: _NutrientField(
                        label: text.nutrientFat,
                        unit: text.unitGram,
                        controller: _fat,
                        accent: MealoraColors.coralText,
                        background: MealoraColors.iconFieldCoral,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: MealoraSpacing.lg),
                MealoraNoteCard(
                  icon: Icons.info_outline,
                  body: text.customFoodNote,
                  borderColor: MealoraColors.glassSoft,
                ),
                if (_error != null) ...<Widget>[
                  const SizedBox(height: MealoraSpacing.sm),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      _error!,
                      style: MealoraTypography.caption.copyWith(
                        color: MealoraColors.danger,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 68),
                MealoraPrimaryButton(
                  label: text.customFoodSaveAction,
                  onPressed: _saving ? null : () => unawaited(_save(text)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save(AppText text) async {
    final name = ValueRules.requiredText(_name.text, field: 'name');
    final servingLabel = ValueRules.requiredText(
      _serving.text,
      field: 'serving',
    );
    final energy = _parseNutrient(_energy.text, field: 'energy');
    final protein = _parseNutrient(_protein.text, field: 'protein');
    final carbohydrate = _parseNutrient(
      _carbohydrate.text,
      field: 'carbohydrate',
    );
    final fat = _parseNutrient(_fat.text, field: 'fat');

    final failure = <Result<Object?>>[
      name,
      servingLabel,
      energy,
      protein,
      carbohydrate,
      fat,
    ].whereType<Err<Object?>>().firstOrNull;

    if (failure != null) {
      setState(() => _error = _messageFor(failure.failure, text));
      return;
    }

    setState(() {
      _error = null;
      _saving = true;
    });

    final energyValue = energy.valueOrNull;
    final servingInput = ServingSizeInput(
      label: servingLabel.valueOrNull!,
      amount: 1,
      unit: 'porsi',
      nutrition: NutritionProfile(
        energy: energyValue == null
            ? null
            : Energy.kcalValue(energyValue, field: 'energy').valueOrNull,
        proteinG: protein.valueOrNull,
        carbohydrateG: carbohydrate.valueOrNull,
        fatG: fat.valueOrNull,
      ),
    );

    final food = await createUserFood(
      ref,
      name: name.valueOrNull!,
      serving: servingInput,
    );

    if (!mounted) {
      return;
    }
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => ServingDetailScreen(food: food)),
    );
  }

  Result<double?> _parseNutrient(String raw, {required String field}) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return const Ok<double?>(null);
    }
    final parsed = double.tryParse(trimmed.replaceAll(',', '.'));
    if (parsed == null) {
      return Err<double?>(
        Failure(FailureCode.invalidValue, field: field, detail: 'bukan angka'),
      );
    }
    return ValueRules.nutrientValue(parsed, field: field);
  }

  String _messageFor(Failure failure, AppText text) {
    if (failure.field == 'name') {
      return text.customFoodNameRequiredError;
    }
    if (failure.field == 'serving') {
      return text.customFoodServingRequiredError;
    }
    return text.customFoodNegativeValueError;
  }
}

class _GlassInputField extends StatelessWidget {
  const _GlassInputField({
    required this.label,
    required this.hint,
    required this.controller,
    required this.icon,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 2),
          child: Text(label, style: MealoraTypography.label),
        ),
        const SizedBox(height: MealoraSpacing.xxs),
        SizedBox(
          height: 56,
          child: MealoraCard(
            radius: MealoraRadius.button,
            padding: const EdgeInsets.symmetric(horizontal: MealoraSpacing.md),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: MealoraTypography.bodyEmphasis,
                    decoration: InputDecoration(
                      hintText: hint,
                      hintStyle: MealoraTypography.bodyMuted,
                      filled: false,
                      fillColor: MealoraColors.transparent,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                const SizedBox(width: MealoraSpacing.sm),
                Icon(icon, size: 18, color: MealoraColors.affordance),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _NutrientField extends StatelessWidget {
  const _NutrientField({
    required this.label,
    required this.unit,
    required this.controller,
    required this.accent,
    required this.background,
  });

  final String label;
  final String unit;
  final TextEditingController controller;
  final Color accent;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 86,
      child: MealoraCard(
        radius: MealoraRadius.choiceCard,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(label, style: MealoraTypography.label),
            const SizedBox(height: 3),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (context, value, _) {
                final inputWidth = (value.text.length * 12.0 + 8)
                    .clamp(24.0, 72.0)
                    .toDouble();
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    SizedBox(
                      width: inputWidth,
                      child: TextField(
                        controller: controller,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: MealoraTypography.headline.copyWith(
                          color: accent,
                          fontSize: 19,
                          height: 1.1,
                        ),
                        decoration: const InputDecoration(
                          filled: false,
                          fillColor: MealoraColors.transparent,
                          isDense: true,
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2, left: 4),
                      child: Text(
                        unit,
                        style: MealoraTypography.bodySmall.copyWith(
                          color: accent,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 5),
            Container(
              width: 28,
              height: 4,
              decoration: BoxDecoration(
                color: background,
                borderRadius: BorderRadius.circular(MealoraRadius.track),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
