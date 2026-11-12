import 'package:flutter/material.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/domain/food/nutrition_profile.dart';
import 'package:mealora/domain/food/recipe.dart';
import 'package:mealora/domain/food/recipe_calculator.dart';
import 'package:mealora/domain/food/serving_size.dart';
import 'package:mealora/features/diary/food_component_picker_sheet.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// Satu pilihan pada [MealoraSegmentToggle].
final class SegmentOption<T> {
  const SegmentOption({required this.value, required this.label, this.icon});

  final T value;
  final String label;
  final IconData? icon;
}

/// Pilihan bersegmen bergaya kaca (desain `72`/`76`): segmen aktif berupa
/// pil putih berbayang dengan teks hijau tebal, label satu baris.
class MealoraSegmentToggle<T> extends StatelessWidget {
  const MealoraSegmentToggle({
    required this.options,
    required this.selected,
    required this.onChanged,
    super.key,
  });

  final List<SegmentOption<T>> options;
  final T selected;

  /// `null` menonaktifkan pilihan.
  final ValueChanged<T>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: MealoraColors.segmentTrack,
        borderRadius: BorderRadius.circular(MealoraRadius.chip),
        border: Border.all(color: MealoraColors.glassSoft),
      ),
      child: Row(
        children: <Widget>[
          for (final (i, option) in options.indexed) ...<Widget>[
            if (i > 0) const SizedBox(width: 4),
            Expanded(child: _segment(option, option.value == selected)),
          ],
        ],
      ),
    );
  }

  Widget _segment(SegmentOption<T> option, bool active) {
    final color = active
        ? MealoraColors.primary
        : MealoraColors.segmentInactive;
    return Semantics(
      button: true,
      selected: active,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onChanged == null ? null : () => onChanged!(option.value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: active ? MealoraColors.surface : null,
            borderRadius: BorderRadius.circular(MealoraRadius.iconField),
            border: Border.all(
              color: active
                  ? MealoraColors.segmentActiveBorder
                  : MealoraColors.transparent,
            ),
            boxShadow: active
                ? const <BoxShadow>[
                    BoxShadow(
                      color: MealoraColors.segmentActiveShadow,
                      offset: Offset(0, 2),
                      blurRadius: 8,
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (option.icon != null) ...<Widget>[
                Icon(option.icon, size: 16, color: color),
                const SizedBox(width: 6),
              ],
              Flexible(
                child: Text(
                  option.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: MealoraTypography.bodySmall.copyWith(
                    color: color,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w600,
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

/// Kotak isian angka hasil resep (desain `73`): putih, garis tipis, tinggi
/// 52, angka tebal 20; garis merah bila [hasError].
class RecipeNumberBox extends StatelessWidget {
  const RecipeNumberBox({
    required this.controller,
    required this.onChanged,
    this.fieldKey,
    this.leading,
    this.trailing,
    this.center = false,
    this.hasError = false,
    super.key,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final Key? fieldKey;
  final Widget? leading;
  final Widget? trailing;
  final bool center;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: EdgeInsets.symmetric(horizontal: leading == null ? 14 : 6),
      decoration: BoxDecoration(
        // Kaca seperti desain `73`, tanpa BackdropFilter (berat di HP kelas
        // bawah; latar di bawahnya polos sehingga hasilnya hampir sama).
        color: MealoraColors.glassCard,
        borderRadius: BorderRadius.circular(MealoraRadius.button),
        border: Border.all(
          color: hasError ? MealoraColors.danger : MealoraColors.glassBorder,
          width: hasError ? 1.5 : 1,
        ),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: MealoraColors.shadowGlass,
            offset: Offset(0, 14),
            blurRadius: 34,
          ),
        ],
      ),
      child: Row(
        children: <Widget>[
          ?leading,
          Expanded(
            child: TextField(
              key: fieldKey,
              controller: controller,
              onChanged: onChanged,
              textAlign: center ? TextAlign.center : TextAlign.start,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              style: MealoraTypography.numberField,
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
          ?trailing,
        ],
      ),
    );
  }
}

/// Tombol −/+ stepper porsi: 36×36, hijau muda.
class RecipeStepButton extends StatelessWidget {
  const RecipeStepButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    super.key,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        enabled: enabled,
        label: tooltip,
        child: InkWell(
          borderRadius: BorderRadius.circular(MealoraRadius.compactIconField),
          onTap: onPressed,
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: enabled
                  ? MealoraColors.iconFieldGreen
                  : MealoraColors.track,
              borderRadius: BorderRadius.circular(
                MealoraRadius.compactIconField,
              ),
            ),
            child: Icon(
              icon,
              size: 16,
              color: enabled ? MealoraColors.primary : MealoraColors.muted,
            ),
          ),
        ),
      ),
    );
  }
}

/// Label bentuk makanan (change 015) untuk daftar bahan.
String foodFormLabel(AppText text, FoodForm form) => switch (form) {
  FoodForm.ready => text.foodFormReady,
  FoodForm.raw => text.foodFormRaw,
  FoodForm.dry => text.foodFormDry,
};

/// Angka tampilan: dibulatkan 1 desimal hanya saat tampil (Design D1),
/// tanpa ",0", dengan koma desimal.
String formatRecipeNumber(double value) {
  final rounded = (value * 10).round() / 10;
  final text = rounded == rounded.roundToDouble()
      ? rounded.toInt().toString()
      : rounded.toString();
  return text.replaceAll('.', ',');
}

/// Mengurai angka masukan pengguna ("2,5" atau "2.5"); `null` bila kosong
/// atau bukan angka.
double? parseRecipeNumber(String raw) =>
    double.tryParse(raw.trim().replaceAll(',', '.'));

/// Jumlah bahan untuk tampilan daftar ("150 g" atau "1 × 1 butir").
String recipeAmountLabel(AppText text, SavedRecipeIngredient ingredient) =>
    switch (ingredient.amount) {
      RecipeGrams(:final value) => text.recipeAmountGrams(
        formatRecipeNumber(value),
      ),
      RecipeServingMultiple(:final value) => text.recipeAmountServing(
        formatRecipeNumber(value),
        ingredient.serving?.label ?? text.recipeAmountLabelServing,
      ),
    };

/// Takaran yang dipakai untuk masukan gram: takaran berat murni lebih dulu,
/// lalu takaran mana pun yang padanan beratnya diketahui.
ServingSize? _gramServingOf(List<ServingSize> servings) =>
    servings
        .where((s) => s.isWeightBasis && s.gramEquivalent != null)
        .firstOrNull ??
    servings.where(RecipeValidation.canUseGrams).firstOrNull;

/// Lembar jumlah bahan (`76`, task 3.4): gram hanya untuk takaran dengan
/// padanan berat, selain itu kelipatan takaran; jumlah ≤ 0 ditolak.
Future<SavedRecipeIngredient?> showRecipeAmountSheet(
  BuildContext context, {
  required RecipeIngredientPick pick,
  SavedRecipeIngredient? initial,
}) => showModalBottomSheet<SavedRecipeIngredient>(
  context: context,
  isScrollControlled: true,
  builder: (_) => _RecipeAmountSheet(pick: pick, initial: initial),
);

class _RecipeAmountSheet extends StatefulWidget {
  const _RecipeAmountSheet({required this.pick, this.initial});

  final RecipeIngredientPick pick;
  final SavedRecipeIngredient? initial;

  @override
  State<_RecipeAmountSheet> createState() => _RecipeAmountSheetState();
}

class _RecipeAmountSheetState extends State<_RecipeAmountSheet> {
  late final ServingSize? _gramServing;
  late final ServingSize? _multipleServing;
  late bool _gramMode;
  late final _amount = TextEditingController(
    text: widget.initial == null
        ? ''
        : formatRecipeNumber(widget.initial!.amount.value),
  );
  bool _showError = false;

  @override
  void initState() {
    super.initState();
    final pick = widget.pick;
    if (pick is PickedFood) {
      final servings = pick.food.servings;
      _gramServing = _gramServingOf(servings);
      final defaultServing = pick.food.defaultServing;
      // Takaran berat murni ("100 g") cukup lewat mode gram.
      _multipleServing = defaultServing.isWeightBasis && _gramServing != null
          ? null
          : defaultServing;
    } else {
      _gramServing = null;
      _multipleServing = null;
    }
    final initialAmount = widget.initial?.amount;
    _gramMode = initialAmount == null
        ? (_gramServing != null || pick is PickedFreeText) &&
              _multipleServing == null
        : initialAmount is RecipeGrams;
    if (pick is PickedFreeText && initialAmount == null) {
      _gramMode = true;
    }
  }

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  bool get _canGram => widget.pick is PickedFreeText || _gramServing != null;
  bool get _canMultiple =>
      widget.pick is PickedFreeText || _multipleServing != null;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final pick = widget.pick;
    final name = switch (pick) {
      PickedFood(:final food) => food.name,
      PickedFreeText(:final name) => name,
    };
    final form = pick is PickedFood ? pick.food.form : null;
    final value = parseRecipeNumber(_amount.text);
    final invalid = RecipeValidation.positive(value) != null;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          MealoraSpacing.lg,
          MealoraSpacing.lg,
          MealoraSpacing.lg,
          MealoraSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                Flexible(
                  child: Text(name, style: MealoraTypography.sectionTitle),
                ),
                if (form != null) ...<Widget>[
                  const SizedBox(width: MealoraSpacing.xs),
                  _FormChip(label: foodFormLabel(text, form)),
                ],
              ],
            ),
            if (form == FoodForm.raw) ...<Widget>[
              const SizedBox(height: MealoraSpacing.xxs),
              Text(text.recipeAmountRawHint, style: MealoraTypography.caption),
            ],
            if (_canGram && _canMultiple) ...<Widget>[
              const SizedBox(height: MealoraSpacing.md),
              MealoraSegmentToggle<bool>(
                options: <SegmentOption<bool>>[
                  SegmentOption<bool>(
                    value: true,
                    label: text.recipeAmountModeGram,
                  ),
                  SegmentOption<bool>(
                    value: false,
                    label: _multipleServing == null
                        ? text.recipeAmountModeMultiple
                        : text.recipeAmountModeServing(_multipleServing.label),
                  ),
                ],
                selected: _gramMode,
                onChanged: (v) => setState(() => _gramMode = v),
              ),
            ],
            const SizedBox(height: MealoraSpacing.md),
            TextField(
              key: const ValueKey('recipe-amount-input'),
              controller: _amount,
              autofocus: true,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: _gramMode
                    ? text.recipeAmountLabelGram
                    : text.recipeAmountLabelServing,
                errorText: _showError && invalid
                    ? text.recipeAmountZeroError
                    : null,
              ),
            ),
            if (!_canGram) ...<Widget>[
              const SizedBox(height: MealoraSpacing.sm),
              MealoraNoteCard(
                icon: Icons.info_outline,
                body: text.recipeAmountGramRule,
                borderColor: MealoraColors.glassSoft,
              ),
            ],
            const SizedBox(height: MealoraSpacing.lg),
            MealoraPrimaryButton(
              label: text.recipeAmountAddAction,
              onPressed: () => _submit(name),
            ),
          ],
        ),
      ),
    );
  }

  void _submit(String name) {
    final value = parseRecipeNumber(_amount.text);
    if (RecipeValidation.positive(value) != null) {
      setState(() => _showError = true);
      return;
    }
    final amount = _gramMode
        ? RecipeGrams(value!)
        : RecipeServingMultiple(value!);
    final pick = widget.pick;
    Navigator.of(context).pop(switch (pick) {
      PickedFood(:final food) => SavedRecipeIngredient(
        label: food.name,
        food: food,
        serving: _gramMode ? _gramServing : _multipleServing,
        amount: amount,
      ),
      PickedFreeText() => SavedRecipeIngredient(label: name, amount: amount),
    });
  }
}

class _FormChip extends StatelessWidget {
  const _FormChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: MealoraColors.iconFieldGreen,
      borderRadius: BorderRadius.circular(MealoraRadius.track),
    ),
    child: Text(label, style: MealoraTypography.caption),
  );
}

/// Satu baris daftar bahan (`73`) dengan tombol hapus langsung.
class RecipeIngredientTile extends StatelessWidget {
  const RecipeIngredientTile({
    required this.ingredient,
    required this.contribution,
    required this.onRemove,
    super.key,
  });

  final SavedRecipeIngredient ingredient;
  final NutritionProfile contribution;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final noData = ingredient.food == null;
    final kcal = contribution.energy?.kcal;
    final form = ingredient.food?.form;
    final warn = noData ? MealoraColors.amberText : MealoraColors.ink;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: MealoraSpacing.xs),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Wrap(
                  spacing: MealoraSpacing.xs,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: <Widget>[
                    Text(
                      ingredient.label,
                      style: MealoraTypography.bodyEmphasis,
                    ),
                    if (form != null)
                      _FormChip(label: foodFormLabel(text, form)),
                  ],
                ),
                Text(
                  noData
                      ? '${recipeAmountLabel(text, ingredient)} · '
                            '${text.recipeIngredientNoData}'
                      : recipeAmountLabel(text, ingredient),
                  style: MealoraTypography.caption.copyWith(
                    color: noData ? MealoraColors.amberText : null,
                  ),
                ),
              ],
            ),
          ),
          Text(
            kcal == null
                ? text.nutrientValueUnknown
                : '${formatRecipeNumber(kcal)} ${text.unitKilocalorie}',
            style: MealoraTypography.bodyEmphasis.copyWith(color: warn),
          ),
          IconButton(
            tooltip: text.recipeRemoveIngredient(ingredient.label),
            onPressed: onRemove,
            icon: const Icon(
              Icons.delete_outline,
              color: MealoraColors.coralText,
            ),
          ),
        ],
      ),
    );
  }
}

/// `74 · Rincian per bahan` (task 3.5): kontribusi tiap bahan, total resep,
/// dan per sajian, dengan penanda tidak lengkap.
class RecipeBreakdownScreen extends StatelessWidget {
  const RecipeBreakdownScreen({
    required this.calculation,
    required this.recipeYield,
    super.key,
  });

  final RecipeCalculation calculation;
  final RecipeYield recipeYield;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final calc = calculation;
    const cols = <RecipeNutrient>[
      RecipeNutrient.energy,
      RecipeNutrient.protein,
      RecipeNutrient.carbohydrate,
      RecipeNutrient.fat,
    ];

    String cell(NutritionProfile p, RecipeNutrient n, {bool mark = false}) {
      final v = nutrientValue(p, n);
      if (v == null) {
        return '?';
      }
      return '${formatRecipeNumber(v)}${mark && calc.isIncomplete(n) ? '*' : ''}';
    }

    TableRow row(
      List<String> cells, {
      bool bold = false,
      bool header = false,
    }) => TableRow(
      children: <Widget>[
        for (final (i, c) in cells.indexed)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Text(
              c,
              textAlign: i == 0 ? TextAlign.start : TextAlign.end,
              style: header
                  ? MealoraTypography.caption
                  : bold
                  ? MealoraTypography.bodyEmphasis
                  : MealoraTypography.bodySmall,
            ),
          ),
      ],
    );

    final per100g = calc.per100gFinished?.energy?.kcal;
    return Scaffold(
      backgroundColor: MealoraColors.background,
      body: MealoraBlobBackdrop(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              MealoraSpacing.programHeroGutter,
              MealoraSpacing.lg,
              MealoraSpacing.programHeroGutter,
              MealoraSpacing.xl,
            ),
            children: <Widget>[
              MealoraBackEyebrow(label: text.customFoodContextLabel),
              const SizedBox(height: MealoraSpacing.xs),
              Text(text.recipeBreakdownTitle, style: MealoraTypography.title),
              Text(
                text.recipeBreakdownSubtitle,
                style: MealoraTypography.subtitle,
              ),
              if (calc
                  .incompleteIngredientsFor(kRecipeDisplayedNutrients)
                  .isNotEmpty) ...<Widget>[
                const SizedBox(height: MealoraSpacing.md),
                RecipeIncompleteBanner(calculation: calc),
              ],
              const SizedBox(height: MealoraSpacing.md),
              MealoraCard(
                padding: const EdgeInsets.all(MealoraSpacing.md),
                child: Table(
                  columnWidths: const <int, TableColumnWidth>{
                    0: FlexColumnWidth(2.4),
                  },
                  children: <TableRow>[
                    row(<String>[
                      text.recipeBreakdownIngredientColumn,
                      text.unitKilocalorie,
                      'P',
                      'K',
                      'L',
                    ], header: true),
                    for (final c in calc.contributions)
                      row(<String>[
                        '${c.ingredient.label} · '
                            '${recipeAmountLabel(text, _saved(c.ingredient))}',
                        for (final n in cols) cell(c.nutrition, n),
                      ]),
                    row(<String>[
                      text.recipeBreakdownTotalRow,
                      for (final n in cols) cell(calc.total, n, mark: true),
                    ], bold: true),
                  ],
                ),
              ),
              const SizedBox(height: MealoraSpacing.lg),
              Text(
                text.recipeBreakdownPerServing(
                  formatRecipeNumber(recipeYield.servings),
                ),
                style: MealoraTypography.headline,
              ),
              const SizedBox(height: MealoraSpacing.sm),
              Row(
                children: <Widget>[
                  for (final n in cols)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 3),
                        child: MealoraCard(
                          padding: const EdgeInsets.all(MealoraSpacing.sm),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  nutrientLabel(text, n),
                                  maxLines: 1,
                                  style: MealoraTypography.caption,
                                ),
                              ),
                              Text(
                                cell(calc.perServing, n, mark: true),
                                style: MealoraTypography.bodyEmphasis,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              if (per100g != null) ...<Widget>[
                const SizedBox(height: MealoraSpacing.md),
                Text(
                  text.recipeBreakdownPer100g(
                    formatRecipeNumber(recipeYield.finishedGrams!),
                    '${formatRecipeNumber(per100g)}'
                    '${calc.isIncomplete(RecipeNutrient.energy) ? '*' : ''}',
                  ),
                  style: MealoraTypography.bodySmall,
                ),
              ],
              if (calc
                  .incompleteIngredientsFor(kRecipeDisplayedNutrients)
                  .isNotEmpty) ...<Widget>[
                const SizedBox(height: MealoraSpacing.xs),
                Text(
                  text.recipeBreakdownIncompleteMark,
                  style: MealoraTypography.caption,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  static SavedRecipeIngredient _saved(RecipeIngredient i) =>
      SavedRecipeIngredient(
        label: i.label,
        serving: i.serving,
        amount: i.amount,
      );
}

/// Penanda "tidak lengkap" yang menyebut bahan penyebabnya (task 3.5).
class RecipeIncompleteBanner extends StatelessWidget {
  const RecipeIncompleteBanner({required this.calculation, super.key});

  final RecipeCalculation calculation;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return Semantics(
      liveRegion: true,
      child: MealoraNoteCard(
        icon: Icons.warning_amber_rounded,
        body: text.recipeIncompleteBanner(
          calculation
              .incompleteIngredientsFor(kRecipeDisplayedNutrients)
              .join(', '),
        ),
        borderColor: MealoraColors.amberText,
      ),
    );
  }
}

double? nutrientValue(NutritionProfile p, RecipeNutrient n) => switch (n) {
  RecipeNutrient.energy => p.energy?.kcal,
  RecipeNutrient.protein => p.proteinG,
  RecipeNutrient.carbohydrate => p.carbohydrateG,
  RecipeNutrient.fat => p.fatG,
  RecipeNutrient.fiber => p.fiberG,
  RecipeNutrient.sugar => p.sugarG,
  RecipeNutrient.sodium => p.sodiumMg,
};

String nutrientLabel(AppText text, RecipeNutrient n) => switch (n) {
  RecipeNutrient.energy => text.nutrientEnergy,
  RecipeNutrient.protein => text.nutrientProtein,
  RecipeNutrient.carbohydrate => text.nutrientCarbohydrate,
  RecipeNutrient.fat => text.nutrientFat,
  RecipeNutrient.fiber => text.nutrientFiber,
  RecipeNutrient.sugar => text.nutrientSugar,
  RecipeNutrient.sodium => text.nutrientSodium,
};
