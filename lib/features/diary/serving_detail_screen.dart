import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/errors/result.dart';
import 'package:mealora/domain/food/food.dart';
import 'package:mealora/domain/food/meal_time.dart';
import 'package:mealora/domain/food/nutrition_profile.dart';
import 'package:mealora/domain/food/serving_size.dart';
import 'package:mealora/features/diary/diary_format.dart';
import 'package:mealora/features/diary/diary_providers.dart';
import 'package:mealora/features/diary/option_sheet.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// `14 · Detail sajian` (task 6.5): memilih takaran, jumlah, dan waktu
/// makan, dengan perkiraan gizi sebelum menyimpan (spec food-diary, "Takaran
/// dan jumlah dipilih sebelum disimpan").
class ServingDetailScreen extends ConsumerStatefulWidget {
  const ServingDetailScreen({
    required this.food,
    this.initialServing,
    this.initialMealTime = MealTime.lunch,
    this.date,
    super.key,
  });

  final Food food;
  final ServingSize? initialServing;
  final MealTime initialMealTime;

  /// Tanggal yang dicatat — `null` berarti hari ini (konvensi
  /// `logFoodEntry`, change 008 task 5.6).
  final LocalDate? date;

  @override
  ConsumerState<ServingDetailScreen> createState() =>
      _ServingDetailScreenState();
}

class _ServingDetailScreenState extends ConsumerState<ServingDetailScreen> {
  late ServingSize _serving;
  late MealTime _mealTime;
  double _quantity = 1;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _serving = widget.initialServing ?? widget.food.defaultServing;
    _mealTime = widget.initialMealTime;
  }

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final estimate = _serving.nutrition.scaledBy(_quantity);

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
                  text.servingDetailContextLabel,
                  style: MealoraTypography.eyebrow,
                ),
                const SizedBox(height: MealoraSpacing.xs),
                Text(widget.food.name, style: MealoraTypography.title),
                const SizedBox(height: MealoraSpacing.xxs),
                Text(
                  text.servingDetailSubtitle,
                  style: MealoraTypography.subtitle,
                ),
                const SizedBox(height: MealoraSpacing.lg),
                MealoraChip(
                  label: widget.food.isUserCreated
                      ? text.servingDetailSourceCustom
                      : text.servingDetailSourceCatalog,
                  background: MealoraColors.iconFieldGreen,
                  foreground: MealoraColors.primary,
                ),
                const SizedBox(height: MealoraSpacing.lg),
                Text(
                  text.servingDetailServingLabel,
                  style: MealoraTypography.compactFieldLabel,
                ),
                const SizedBox(height: MealoraSpacing.xs),
                _PickerField(
                  icon: Icons.restaurant_outlined,
                  value: _serving.label,
                  onTap: _pickServing,
                ),
                const SizedBox(height: MealoraSpacing.lg),
                Text(
                  text.servingDetailQuantityLabel,
                  style: MealoraTypography.compactFieldLabel,
                ),
                const SizedBox(height: MealoraSpacing.xs),
                _QuantityStepper(
                  quantity: _quantity,
                  onChanged: (value) => setState(() => _quantity = value),
                ),
                const SizedBox(height: MealoraSpacing.lg),
                Text(
                  text.servingDetailMealTimeLabel,
                  style: MealoraTypography.compactFieldLabel,
                ),
                const SizedBox(height: MealoraSpacing.xs),
                _PickerField(
                  icon: _mealTimeIcon(_mealTime),
                  value: DiaryFormat.mealTimeLabel(_mealTime, text),
                  onTap: _pickMealTime,
                ),
                const SizedBox(height: MealoraSpacing.lg),
                _EstimateCard(estimate: estimate, text: text),
                const SizedBox(height: MealoraSpacing.xl),
                MealoraPrimaryButton(
                  label: text.servingDetailAddAction(
                    DiaryFormat.mealTimeLabel(_mealTime, text),
                  ),
                  onPressed: _saving ? null : _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  IconData _mealTimeIcon(MealTime mealTime) => switch (mealTime) {
    MealTime.breakfast => Icons.wb_twilight_rounded,
    MealTime.lunch => Icons.wb_sunny_outlined,
    MealTime.snack => Icons.cookie_outlined,
    MealTime.dinner => Icons.dark_mode_outlined,
  };

  Future<void> _pickServing() async {
    final text = AppText.of(context);
    final picked = await showModalBottomSheet<ServingSize>(
      context: context,
      builder: (context) => OptionSheet<ServingSize>(
        title: text.servingPickerTitle,
        options: widget.food.servings,
        labelOf: (s) => s.label,
        selected: _serving,
      ),
    );
    if (picked != null) {
      setState(() => _serving = picked);
    }
  }

  Future<void> _pickMealTime() async {
    final text = AppText.of(context);
    final picked = await showModalBottomSheet<MealTime>(
      context: context,
      builder: (context) => OptionSheet<MealTime>(
        title: text.mealTimePickerTitle,
        options: MealTime.values,
        labelOf: (m) => DiaryFormat.mealTimeLabel(m, text),
        selected: _mealTime,
      ),
    );
    if (picked != null) {
      setState(() => _mealTime = picked);
    }
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final result = await logFoodEntry(
      ref,
      mealTime: _mealTime,
      food: widget.food,
      serving: _serving,
      quantity: _quantity,
      date: widget.date,
    );
    if (!mounted) {
      return;
    }
    if (result is Err) {
      setState(() => _saving = false);
      return;
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

class _EstimateCard extends StatelessWidget {
  const _EstimateCard({required this.estimate, required this.text});

  final NutritionProfile estimate;
  final AppText text;

  @override
  Widget build(BuildContext context) {
    return MealoraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(text.servingDetailEstimateLabel, style: MealoraTypography.label),
          const SizedBox(height: MealoraSpacing.xs),
          Text(
            DiaryFormat.kcal(estimate.energy, text),
            style: MealoraTypography.headline.copyWith(
              color: MealoraColors.primary,
            ),
          ),
          const SizedBox(height: MealoraSpacing.xxs),
          Text(
            text.macroMacrosShort(
              DiaryFormat.grams(estimate.proteinG, text),
              DiaryFormat.grams(estimate.carbohydrateG, text),
              DiaryFormat.grams(estimate.fatG, text),
            ),
            style: MealoraTypography.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _PickerField extends StatelessWidget {
  const _PickerField({
    required this.icon,
    required this.value,
    required this.onTap,
  });

  final IconData icon;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: value,
      child: InkWell(
        borderRadius: BorderRadius.circular(MealoraRadius.button),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: MealoraSpacing.sm,
            vertical: MealoraSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: MealoraColors.glassCard,
            borderRadius: BorderRadius.circular(MealoraRadius.button),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: MealoraColors.iconField,
                  borderRadius: BorderRadius.circular(
                    MealoraRadius.compactIconField,
                  ),
                ),
                child: Icon(
                  icon,
                  color: MealoraColors.primary,
                  size: MealoraIconSize.action,
                ),
              ),
              const SizedBox(width: MealoraSpacing.sm),
              Expanded(
                child: Text(value, style: MealoraTypography.bodyEmphasis),
              ),
              const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: MealoraColors.affordance,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({required this.quantity, required this.onChanged});

  final double quantity;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MealoraSpacing.sm,
        vertical: MealoraSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: MealoraColors.glassCard,
        borderRadius: BorderRadius.circular(MealoraRadius.button),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          _StepButton(
            icon: Icons.remove,
            semanticsLabel: text.quantityDecreaseSemantics,
            onTap: quantity > 0.5
                ? () => onChanged((quantity - 0.5).clamp(0.5, 99))
                : null,
          ),
          Text(
            quantity.toStringAsFixed(1).replaceAll('.', ','),
            style: MealoraTypography.headline,
          ),
          _StepButton(
            icon: Icons.add,
            semanticsLabel: text.quantityIncreaseSemantics,
            onTap: () => onChanged((quantity + 0.5).clamp(0.5, 99)),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.semanticsLabel,
    required this.onTap,
  });

  final IconData icon;
  final String semanticsLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: InkWell(
        borderRadius: BorderRadius.circular(MealoraRadius.compactIconField),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: MealoraColors.iconFieldGreen,
            borderRadius: BorderRadius.circular(MealoraRadius.compactIconField),
          ),
          child: Icon(icon, color: MealoraColors.primary),
        ),
      ),
    );
  }
}
