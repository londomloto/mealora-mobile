import 'dart:async' show unawaited;

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
import 'package:mealora/features/diary/custom_food_screen.dart';
import 'package:mealora/features/diary/diary_format.dart';
import 'package:mealora/features/diary/diary_providers.dart';
import 'package:mealora/features/diary/option_sheet.dart';
import 'package:mealora/features/diary/serving_picker_sheet.dart';
import 'package:mealora/features/reminders/late_meal_notice.dart';
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

  /// Masukan jumlah bebas dalam gram/ml (desain 68/69, design.md D5):
  /// disimpan sebagai takaran 100 g/100 ml × (berat / 100).
  bool _weightMode = false;
  final TextEditingController _weightController = TextEditingController();
  bool _weightInvalid = false;

  ServingSize? get _weightBasis => weightBasisOf(widget.food);

  double? get _weight =>
      double.tryParse(_weightController.text.trim().replaceAll(',', '.'));

  @override
  void dispose() {
    _weightController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _serving = widget.initialServing ?? widget.food.defaultServing;
    _mealTime = widget.initialMealTime;
  }

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final basis = _weightBasis;
    final weight = _weight;
    final estimate = !_weightMode
        ? _serving.nutrition.scaledBy(_quantity)
        : (basis != null && weight != null && weight > 0)
        ? basis.nutrition.scaledBy(weight / basis.amount)
        : null;
    final unit = basis == null ? 'g' : weightUnitLabel(basis);

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
                MealoraBackEyebrow(label: text.servingDetailContextLabel),
                const SizedBox(height: MealoraSpacing.xs),
                Text(widget.food.name, style: MealoraTypography.title),
                const SizedBox(height: MealoraSpacing.xxs),
                Text(
                  text.servingDetailSubtitle,
                  style: MealoraTypography.subtitle,
                ),
                const SizedBox(height: MealoraSpacing.lg),
                Wrap(
                  spacing: MealoraSpacing.xs,
                  runSpacing: MealoraSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    MealoraChip(
                      label: widget.food.isUserCreated
                          ? text.servingDetailSourceCustom
                          : text.servingDetailSourceCatalog,
                      background: MealoraColors.iconFieldGreen,
                      foreground: MealoraColors.primary,
                    ),
                    if (widget.food.isUserCreated) ...<Widget>[
                      TextButton.icon(
                        key: const ValueKey('serving-detail-edit-food'),
                        onPressed: () => unawaited(_editFood()),
                        icon: const Icon(Icons.edit_outlined, size: 18),
                        label: Text(text.customFoodEditAction),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: MealoraSpacing.lg),
                Text(
                  text.servingDetailServingLabel,
                  style: MealoraTypography.compactFieldLabel,
                ),
                const SizedBox(height: MealoraSpacing.xs),
                _PickerField(
                  icon: _weightMode
                      ? Icons.scale_outlined
                      : Icons.restaurant_outlined,
                  value: _weightMode
                      ? text.servingDetailWeightServing(unit)
                      : _servingLabel(_serving),
                  estimate: !_weightMode && _serving.isEstimate,
                  onTap: _pickServing,
                ),
                const SizedBox(height: MealoraSpacing.lg),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        _weightMode
                            ? text.servingDetailWeightLabel
                            : text.servingDetailQuantityLabel,
                        style: MealoraTypography.compactFieldLabel,
                      ),
                    ),
                    if (_weightMode)
                      TextButton.icon(
                        onPressed: () => setState(() {
                          _weightMode = false;
                          _weightInvalid = false;
                        }),
                        icon: const Icon(Icons.repeat, size: 14),
                        label: Text(text.servingDetailUseServingAction),
                      ),
                  ],
                ),
                const SizedBox(height: MealoraSpacing.xs),
                if (_weightMode)
                  _WeightField(
                    controller: _weightController,
                    unit: unit,
                    invalid: _weightInvalid,
                    errorText: text.servingDetailWeightInvalid(unit),
                    onChanged: (_) => setState(() {
                      final w = _weight;
                      _weightInvalid = w != null && w <= 0;
                    }),
                  )
                else
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

  /// Label takaran dengan padanan beratnya bila label belum menyebutnya
  /// (spec food-catalog, "Takaran saji yang bermakna").
  String _servingLabel(ServingSize serving) {
    final gram = serving.gramEquivalent;
    if (gram == null || serving.isWeightBasis) return serving.label;
    final weight = '${formatWeight(gram)} g';
    return serving.label.contains(weight)
        ? serving.label
        : '${serving.label} · $weight';
  }

  /// Menyunting makanan buatan pengguna (change 016), lalu membuka ulang
  /// detail sajian dengan nilai terbaru.
  Future<void> _editFood() async {
    final updated = await Navigator.of(context).push<Food>(
      MaterialPageRoute<Food>(
        builder: (_) =>
            CustomFoodScreen(editFood: widget.food, date: widget.date),
      ),
    );
    if (updated == null || !mounted) {
      return;
    }
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ServingDetailScreen(
          food: updated,
          initialMealTime: widget.initialMealTime,
          date: widget.date,
        ),
      ),
    );
  }

  Future<void> _pickServing() async {
    final picked = await showModalBottomSheet<ServingPick>(
      context: context,
      isScrollControlled: true,
      builder: (context) => ServingPickerSheet(
        food: widget.food,
        selected: _weightMode ? null : _serving,
      ),
    );
    if (picked == null) return;
    setState(() {
      switch (picked) {
        case ServingPicked(:final serving):
          _serving = serving;
          _weightMode = false;
          _weightInvalid = false;
        case WeightEntryPicked():
          _weightMode = true;
      }
    });
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
    var serving = _serving;
    var quantity = _quantity;
    if (_weightMode) {
      final basis = _weightBasis;
      final weight = _weight;
      if (basis == null || weight == null || weight <= 0) {
        setState(() => _weightInvalid = true);
        return;
      }
      serving = basis;
      quantity = weight / basis.amount;
    }
    setState(() => _saving = true);
    final result = await logFoodEntry(
      ref,
      mealTime: _mealTime,
      food: widget.food,
      serving: serving,
      quantity: quantity,
      date: widget.date,
    );
    if (!mounted) {
      return;
    }
    if (result is Err) {
      setState(() => _saving = false);
      return;
    }
    // Peringatan jelang tidur (change 013, task 4.3): hanya setelah Ok.
    final lateMealNotice = ref.read(lateMealNoticeProvider);
    final messenger = ScaffoldMessenger.of(context);
    final noticeText = AppText.of(context);
    Navigator.of(context).popUntil((route) => route.isFirst);
    unawaited(
      lateMealNotice.maybeShow(
        messenger: messenger,
        text: noticeText,
        date: widget.date,
      ),
    );
  }
}

class _EstimateCard extends StatelessWidget {
  const _EstimateCard({required this.estimate, required this.text});

  /// `null` saat berat belum sah — angka tidak ditampilkan.
  final NutritionProfile? estimate;
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
            estimate == null ? '—' : DiaryFormat.kcal(estimate!.energy, text),
            style: MealoraTypography.headline.copyWith(
              color: MealoraColors.primary,
            ),
          ),
          const SizedBox(height: MealoraSpacing.xxs),
          if (estimate case final e?)
            Text(
              text.macroMacrosShort(
                DiaryFormat.grams(e.proteinG, text),
                DiaryFormat.grams(e.carbohydrateG, text),
                DiaryFormat.grams(e.fatG, text),
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
    this.estimate = false,
  });

  final IconData icon;
  final String value;
  final VoidCallback onTap;
  final bool estimate;

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
                child: Wrap(
                  spacing: MealoraSpacing.xs,
                  runSpacing: 4,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    Text(value, style: MealoraTypography.bodyEmphasis),
                    if (estimate) const ServingEstimateBadge(),
                  ],
                ),
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

class _WeightField extends StatelessWidget {
  const _WeightField({
    required this.controller,
    required this.unit,
    required this.invalid,
    required this.errorText,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String unit;
  final bool invalid;
  final String errorText;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final borderColor = invalid ? MealoraColors.danger : MealoraColors.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          style: MealoraTypography.headline,
          onChanged: onChanged,
          decoration: InputDecoration(
            suffixText: unit,
            filled: true,
            fillColor: MealoraColors.surface,
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(MealoraRadius.button),
              borderSide: BorderSide(color: borderColor, width: 1.5),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(MealoraRadius.button),
              borderSide: BorderSide(color: borderColor, width: 2),
            ),
          ),
        ),
        if (invalid)
          Padding(
            padding: const EdgeInsets.only(top: MealoraSpacing.xs),
            child: Row(
              children: <Widget>[
                const Icon(
                  Icons.error_outline,
                  size: 14,
                  color: MealoraColors.danger,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    errorText,
                    style: MealoraTypography.bodySmall.copyWith(
                      color: MealoraColors.danger,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
