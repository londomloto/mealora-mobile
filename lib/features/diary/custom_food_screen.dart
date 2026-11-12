import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/errors/failure.dart';
import 'package:mealora/core/errors/result.dart';
import 'package:mealora/core/validation/value_rules.dart';
import 'package:mealora/domain/food/food.dart';
import 'package:mealora/domain/food/food_repository.dart';
import 'package:mealora/domain/food/nutrition_profile.dart';
import 'package:mealora/domain/food/recipe.dart';
import 'package:mealora/domain/food/recipe_calculator.dart';
import 'package:mealora/domain/nutrition_import/nutrition_import.dart';
import 'package:mealora/domain/nutrition_import/nutrition_reading.dart';
import 'package:mealora/domain/shared/units.dart';
import 'package:mealora/features/diary/diary_providers.dart';
import 'package:mealora/features/diary/food_component_picker_sheet.dart';
import 'package:mealora/features/diary/nutrition_text_import_screen.dart';
import 'package:mealora/features/diary/recipe_widgets.dart';
import 'package:mealora/features/diary/serving_detail_screen.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// `15 · Makanan buatan sendiri` (task 6.6/6.7): nama, ukuran sajian, dan
/// nilai gizi — nilai belum diketahui dikosongkan, bukan nol (spec
/// food-catalog, "Pengguna dapat membuat makanan sendiri").
///
/// Change 016 (`72`–`77`): isi manual tetap bawaan; "Hitung dari bahan"
/// menjumlahkan gizi bahan. Dengan [editFood] layar ini menyunting makanan
/// buatan pengguna, termasuk menghitung ulang resepnya.
class CustomFoodScreen extends ConsumerStatefulWidget {
  const CustomFoodScreen({
    this.date,
    this.editFood,
    this.prefill,
    this.returnCreatedFood = false,
    super.key,
  });

  /// Change 021 (design D2): makanan baru dikembalikan ke pemanggil lewat
  /// `pop(food)` alih-alih membuka `ServingDetailScreen` — dipakai saat
  /// melengkapi komponen foto tanpa padanan.
  final bool returnCreatedFood;

  /// Nilai awal hasil impor info gizi (change 020, design D4/D5) — dipakai
  /// saat dibuka dari Foto info gizi lewat menu scan. Tidak menyimpan apa
  /// pun; pengguna tetap menekan Simpan.
  final NutritionImportResult? prefill;

  /// Tanggal yang akan dicatat begitu takaran dikonfirmasi — `null` berarti
  /// hari ini (konvensi `logFoodEntry`, change 008 task 5.6).
  final LocalDate? date;

  /// Makanan buatan pengguna yang disunting; `null` untuk membuat baru.
  /// Saat menyunting, layar ditutup dengan [Food] tersimpan.
  final Food? editFood;

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
  final _servings = TextEditingController(text: '1');
  final _finishedGrams = TextEditingController();

  late final Map<RecipeNutrient, TextEditingController> _nutrientFields =
      <RecipeNutrient, TextEditingController>{
        RecipeNutrient.energy: _energy,
        RecipeNutrient.protein: _protein,
        RecipeNutrient.carbohydrate: _carbohydrate,
        RecipeNutrient.fat: _fat,
      };

  bool _recipeMode = false;
  final List<SavedRecipeIngredient> _ingredients = <SavedRecipeIngredient>[];
  RecipeCalculation? _calculation;

  /// Isi kolom gizi terakhir dari hitungan. `null` = belum pernah diisi
  /// hitungan, atau nilai tersimpan adalah koreksi manual (Design D4).
  Map<RecipeNutrient, String>? _filled;

  String? _error;
  bool _saving = false;
  bool _loading = false;

  /// Resep tersimpan berasal-manual: nilai koreksi dipertahankan sampai
  /// pengguna mengonfirmasi hitung ulang (Design D4).
  bool _keepStoredValues = false;

  bool get _editing => widget.editFood != null;

  @override
  void initState() {
    super.initState();
    for (final c in _nutrientFields.values) {
      c.addListener(_onNutrientEdited);
    }
    final prefill = widget.prefill;
    if (prefill != null) {
      _applyImport(prefill);
    }
    final food = widget.editFood;
    if (food != null) {
      _name.text = food.name;
      _serving.text = food.defaultServing.label;
      final n = food.defaultServing.nutrition;
      for (final e in _nutrientFields.entries) {
        final v = nutrientValue(n, e.key);
        e.value.text = v == null ? '' : formatRecipeNumber(v);
      }
      _loading = true;
      unawaited(_loadRecipe(food));
    }
  }

  Future<void> _loadRecipe(Food food) async {
    final recipe = await loadRecipe(ref, food.id);
    if (!mounted) {
      return;
    }
    setState(() {
      _loading = false;
      if (recipe == null) {
        return;
      }
      _recipeMode = true;
      _ingredients.addAll(recipe.ingredients);
      _servings.text = formatRecipeNumber(recipe.recipeYield.servings);
      final grams = recipe.recipeYield.finishedGrams;
      _finishedGrams.text = grams == null ? '' : formatRecipeNumber(grams);
      // Resep dihitung ulang dari nilai bahan saat ini (Design D3); nilai
      // koreksi manual dipertahankan sampai pengguna memilih hitung ulang.
      _keepStoredValues = food.nutritionOrigin != NutritionOrigin.recipe;
      _recalculate(fill: !_keepStoredValues);
    });
  }

  /// Mengisi form dari hasil impor (design D5): nama hanya bila kosong,
  /// sajian hanya bila basis terbaca, nutrien selalu ditimpa.
  void _applyImport(NutritionImportResult result) {
    final prefill = FormPrefill.from(
      result,
      currentName: _name.text,
      formatNumber: formatRecipeNumber,
    );
    if (prefill.name != null) {
      _name.text = prefill.name!;
    }
    if (prefill.servingLabel != null) {
      _serving.text = prefill.servingLabel!;
    }
    for (final e in prefill.nutrients.entries) {
      _importFields[e.key]!.text = e.value;
    }
  }

  late final Map<ImportNutrient, TextEditingController> _importFields =
      <ImportNutrient, TextEditingController>{
        ImportNutrient.energy: _energy,
        ImportNutrient.protein: _protein,
        ImportNutrient.carbohydrate: _carbohydrate,
        ImportNutrient.fat: _fat,
      };

  Future<void> _openTextImport() async {
    final result = await Navigator.of(context).push<NutritionImportResult>(
      MaterialPageRoute<NutritionImportResult>(
        builder: (_) => const NutritionTextImportScreen(),
      ),
    );
    if (result == null || !mounted) {
      return;
    }
    setState(() {
      _error = null;
      _applyImport(result);
    });
  }

  void _onNutrientEdited() {
    if (_recipeMode) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    for (final c in <TextEditingController>[
      _name,
      _serving,
      _energy,
      _protein,
      _carbohydrate,
      _fat,
      _servings,
      _finishedGrams,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  /// Hasil resep dari isian; `null` bila porsi/berat jadi tidak sah.
  RecipeYield? get _yield {
    final servings = parseRecipeNumber(_servings.text);
    if (RecipeValidation.positive(servings) != null) {
      return null;
    }
    final gramsRaw = _finishedGrams.text.trim();
    final grams = gramsRaw.isEmpty ? null : parseRecipeNumber(gramsRaw);
    if (gramsRaw.isNotEmpty && RecipeValidation.positive(grams) != null) {
      return null;
    }
    return RecipeYield(servings: servings!, finishedGrams: grams);
  }

  /// Nilai di kolom gizi berbeda dari isian hitungan terakhir.
  bool get _corrected {
    final filled = _filled;
    if (filled == null) {
      return _calculation != null;
    }
    return _nutrientFields.entries.any(
      (e) => e.value.text.trim() != filled[e.key],
    );
  }

  /// Menghitung ulang resep; mengisi kolom gizi bila [fill], atau bila
  /// kolom belum dikoreksi pengguna.
  void _recalculate({bool? fill}) {
    final recipeYield = _yield;
    if (_ingredients.isEmpty || recipeYield == null) {
      _calculation = null;
      return;
    }
    final shouldFill = fill ?? (_filled != null && !_corrected);
    _calculation = RecipeCalculator.calculate(
      _ingredients.map((i) => i.toCalculatorInput()).toList(),
      recipeYield,
    );
    if (shouldFill) {
      final filled = <RecipeNutrient, String>{};
      for (final e in _nutrientFields.entries) {
        final v = nutrientValue(_calculation!.perServing, e.key);
        filled[e.key] = v == null ? '' : formatRecipeNumber(v);
        e.value.text = filled[e.key]!;
      }
      _filled = filled;
    }
  }

  void _changeRecipe(VoidCallback change) {
    setState(() {
      final firstCalculation = _calculation == null && _filled == null;
      change();
      _recalculate(fill: firstCalculation && !_keepStoredValues ? true : null);
    });
  }

  Future<void> _addIngredient() async {
    final pick = await showRecipeIngredientPickerSheet(context);
    if (pick == null || !mounted) {
      return;
    }
    final ingredient = await showRecipeAmountSheet(context, pick: pick);
    if (ingredient == null || !mounted) {
      return;
    }
    _changeRecipe(() => _ingredients.add(ingredient));
  }

  Future<void> _confirmRecalculate(AppText text) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(text.recipeRecalculateTitle),
        content: Text(text.recipeRecalculateBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(text.recipeRecalculateCancel),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(text.recipeRecalculateConfirm),
          ),
        ],
      ),
    );
    if (confirmed ?? false) {
      setState(() => _recalculate(fill: true));
    }
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
                MealoraBackEyebrow(
                  label: _editing
                      ? text.customFoodEditContextLabel
                      : text.customFoodContextLabel,
                ),
                const SizedBox(height: MealoraSpacing.xs),
                Text(
                  _editing ? text.customFoodEditTitle : text.customFoodTitle,
                  style: MealoraTypography.title,
                ),
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
                Text(
                  text.customFoodModeHeading,
                  style: MealoraTypography.label,
                ),
                const SizedBox(height: MealoraSpacing.xxs),
                MealoraSegmentToggle<bool>(
                  key: const ValueKey('custom-food-mode'),
                  options: <SegmentOption<bool>>[
                    SegmentOption<bool>(
                      value: false,
                      icon: Icons.edit_note,
                      label: text.customFoodModeManual,
                    ),
                    SegmentOption<bool>(
                      value: true,
                      icon: Icons.playlist_add,
                      label: text.customFoodModeRecipe,
                    ),
                  ],
                  selected: _recipeMode,
                  onChanged: _loading
                      ? null
                      : (v) => setState(() => _recipeMode = v),
                ),
                const SizedBox(height: MealoraSpacing.md),
                if (_recipeMode)
                  ..._recipeSection(text)
                else
                  _GlassInputField(
                    label: text.customFoodServingLabel,
                    hint: text.customFoodServingHint,
                    controller: _serving,
                    icon: Icons.keyboard_arrow_down_rounded,
                  ),
                const SizedBox(height: MealoraSpacing.lg),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        _recipeMode
                            ? text.recipeNutritionHeading
                            : text.customFoodNutritionHeading,
                        style: MealoraTypography.headline,
                      ),
                    ),
                    // Change 020: hanya pada mode isi manual (spec
                    // "Pengguna dapat memulai dari form Buat makanan").
                    if (!_recipeMode)
                      Semantics(
                        button: true,
                        label: text.customFoodPasteAction,
                        child: InkWell(
                          key: const ValueKey('custom-food-paste-text'),
                          borderRadius: BorderRadius.circular(
                            MealoraRadius.chip,
                          ),
                          onTap: _loading
                              ? null
                              : () => unawaited(_openTextImport()),
                          child: ExcludeSemantics(
                            child: MealoraChip(
                              label: text.customFoodPasteAction,
                              icon: Icons.content_paste_go_outlined,
                              background: MealoraColors.iconFieldGreen,
                              foreground: MealoraColors.primaryDeep,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: MealoraSpacing.sm),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _NutrientField(
                        label: text.nutrientEnergy,
                        unit: text.unitKilocalorie,
                        controller: _energy,
                        incomplete: _incomplete(RecipeNutrient.energy),
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
                        incomplete: _incomplete(RecipeNutrient.protein),
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
                        incomplete: _incomplete(RecipeNutrient.carbohydrate),
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
                        incomplete: _incomplete(RecipeNutrient.fat),
                        accent: MealoraColors.coralText,
                        background: MealoraColors.iconFieldCoral,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: MealoraSpacing.lg),
                if (_recipeMode && _calculation != null && _corrected) ...[
                  MealoraNoteCard(
                    icon: Icons.edit_note,
                    body: text.recipeCorrectedNotice,
                    borderColor: MealoraColors.amberText,
                  ),
                  TextButton.icon(
                    onPressed: () => unawaited(_confirmRecalculate(text)),
                    icon: const Icon(Icons.refresh),
                    label: Text(text.recipeRecalculateAction),
                  ),
                ] else
                  MealoraNoteCard(
                    icon: Icons.info_outline,
                    body: _recipeMode || _editing
                        ? text.customFoodNote
                        : '${text.customFoodPasteHint} '
                              '${text.customFoodManualHint}',
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
                  label: _editing
                      ? text.customFoodSaveChangesAction
                      : text.customFoodSaveAction,
                  onPressed: _saving || _loading
                      ? null
                      : () => unawaited(_save(text)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _incomplete(RecipeNutrient nutrient) =>
      _recipeMode &&
      !_corrected &&
      (_calculation?.isIncomplete(nutrient) ?? false);

  List<Widget> _recipeSection(AppText text) {
    final calc = _calculation;
    final servings = parseRecipeNumber(_servings.text);
    final gramsRaw = _finishedGrams.text.trim();
    final gramsInvalid =
        gramsRaw.isNotEmpty &&
        RecipeValidation.positive(parseRecipeNumber(gramsRaw)) != null;
    return <Widget>[
      Text(
        text.recipeIngredientsHeading(_ingredients.length),
        style: MealoraTypography.headline,
      ),
      const SizedBox(height: MealoraSpacing.xs),
      MealoraCard(
        padding: const EdgeInsets.fromLTRB(
          MealoraSpacing.md,
          MealoraSpacing.xs,
          MealoraSpacing.xxs,
          MealoraSpacing.xs,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            if (_ingredients.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: MealoraSpacing.sm,
                ),
                child: Text(
                  text.recipeIngredientsEmpty,
                  style: MealoraTypography.bodyMuted,
                ),
              ),
            for (final (index, ingredient) in _ingredients.indexed)
              RecipeIngredientTile(
                key: ObjectKey(ingredient),
                ingredient: ingredient,
                contribution: RecipeCalculator.contributionOf(
                  ingredient.toCalculatorInput(),
                ),
                // Hapus langsung tanpa konfirmasi (spec custom-food-recipe).
                onRemove: () =>
                    _changeRecipe(() => _ingredients.removeAt(index)),
              ),
            TextButton.icon(
              key: const ValueKey('recipe-add-ingredient'),
              onPressed: () => unawaited(_addIngredient()),
              icon: const Icon(Icons.add),
              label: Text(text.recipeAddIngredient),
            ),
          ],
        ),
      ),
      if (calc != null &&
          calc
              .incompleteIngredientsFor(kRecipeDisplayedNutrients)
              .isNotEmpty) ...<Widget>[
        const SizedBox(height: MealoraSpacing.sm),
        RecipeIncompleteBanner(calculation: calc),
      ],
      const SizedBox(height: MealoraSpacing.lg),
      Text(text.recipeYieldHeading, style: MealoraTypography.headline),
      const SizedBox(height: MealoraSpacing.xs),
      Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  text.recipeYieldServingsLabel,
                  style: MealoraTypography.label,
                ),
                const SizedBox(height: 6),
                RecipeNumberBox(
                  fieldKey: const ValueKey('recipe-servings'),
                  controller: _servings,
                  center: true,
                  hasError: RecipeValidation.positive(servings) != null,
                  onChanged: (_) => _changeRecipe(() {}),
                  leading: RecipeStepButton(
                    icon: Icons.remove,
                    tooltip: text.recipeDecreaseServings,
                    onPressed: (servings ?? 0) > 1
                        ? () => _changeRecipe(
                            () => _servings.text = formatRecipeNumber(
                              (servings! - 1).ceilToDouble(),
                            ),
                          )
                        : null,
                  ),
                  trailing: RecipeStepButton(
                    icon: Icons.add,
                    tooltip: text.recipeIncreaseServings,
                    onPressed: () => _changeRecipe(
                      () => _servings.text = formatRecipeNumber(
                        ((servings ?? 0) + 1).floorToDouble(),
                      ),
                    ),
                  ),
                ),
                if (RecipeValidation.positive(servings) != null)
                  Text(
                    text.recipeYieldServingsError,
                    style: MealoraTypography.caption.copyWith(
                      color: MealoraColors.danger,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: MealoraSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  text.recipeYieldGramsLabel,
                  style: MealoraTypography.label,
                ),
                const SizedBox(height: 6),
                RecipeNumberBox(
                  fieldKey: const ValueKey('recipe-finished-grams'),
                  controller: _finishedGrams,
                  hasError: gramsInvalid,
                  onChanged: (_) => _changeRecipe(() {}),
                ),
                const SizedBox(height: 4),
                Text(
                  gramsInvalid
                      ? text.recipeYieldGramsError
                      : text.recipeYieldGramsHelper,
                  style: MealoraTypography.caption.copyWith(
                    color: gramsInvalid ? MealoraColors.danger : null,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      const SizedBox(height: MealoraSpacing.md),
      MealoraNoteCard(
        icon: Icons.water_drop_outlined,
        body: text.recipeOilReminder,
        borderColor: MealoraColors.glassSoft,
      ),
      if (calc != null)
        TextButton.icon(
          key: const ValueKey('recipe-breakdown'),
          onPressed: () => unawaited(
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => RecipeBreakdownScreen(
                  calculation: calc,
                  recipeYield: _yield!,
                ),
              ),
            ),
          ),
          icon: const Icon(Icons.table_chart_outlined),
          label: Text(text.recipeBreakdownAction),
        ),
    ];
  }

  Future<void> _save(AppText text) async {
    if (_recipeMode) {
      await _saveRecipe(text);
      return;
    }
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

    final editFood = widget.editFood;
    final food = editFood == null
        ? await createUserFood(
            ref,
            name: name.valueOrNull!,
            serving: servingInput,
          )
        : await updateUserFood(
            ref,
            editFood.id,
            name: name.valueOrNull!,
            serving: servingInput,
          );
    await _finish(food);
  }

  Future<void> _saveRecipe(AppText text) async {
    final name = ValueRules.requiredText(_name.text, field: 'name');
    final recipeYield = _yield;
    final calc = _calculation;
    final fields = <RecipeNutrient, Result<double?>>{
      for (final e in _nutrientFields.entries)
        e.key: _parseNutrient(e.value.text, field: e.key.name),
    };
    final String? error;
    if (name is Err<String>) {
      error = text.customFoodNameRequiredError;
    } else if (_ingredients.isEmpty) {
      error = text.recipeNoIngredientsError;
    } else if (recipeYield == null) {
      error =
          RecipeValidation.positive(parseRecipeNumber(_servings.text)) == null
          ? text.recipeYieldGramsError
          : text.recipeYieldServingsError;
    } else if (fields.values.any((r) => r is Err<double?>)) {
      error = text.customFoodNegativeValueError;
    } else {
      error = null;
    }
    if (error != null || calc == null || recipeYield == null) {
      setState(() => _error = error ?? text.recipeNoIngredientsError);
      return;
    }

    setState(() {
      _error = null;
      _saving = true;
    });

    // Tanpa koreksi: nilai hitungan apa adanya (tanpa pembulatan tampilan).
    // Dengan koreksi: kolom yang tampil dari isian pengguna, zat lain tetap
    // dari hitungan; asal dicatat `manual` (Design D4).
    final corrected = _corrected;
    final calculated = calc.perServingForStorage(kRecipeDisplayedNutrients);
    final perServing = corrected
        ? NutritionProfile(
            energy: _energyOf(fields[RecipeNutrient.energy]!.valueOrNull),
            proteinG: fields[RecipeNutrient.protein]!.valueOrNull,
            carbohydrateG: fields[RecipeNutrient.carbohydrate]!.valueOrNull,
            fatG: fields[RecipeNutrient.fat]!.valueOrNull,
            fiberG: calculated.fiberG,
            sugarG: calculated.sugarG,
            sodiumMg: calculated.sodiumMg,
          )
        : calculated;

    final food = await saveRecipeFood(
      ref,
      foodId: widget.editFood?.id,
      name: name.valueOrNull!,
      ingredients: _ingredients.map((i) => i.toInput()).toList(),
      recipeYield: recipeYield,
      perServing: perServing,
      origin: corrected ? NutritionOrigin.manual : NutritionOrigin.recipe,
    );
    await _finish(food);
  }

  static Energy? _energyOf(double? kcal) =>
      kcal == null ? null : Energy.kcalValue(kcal, field: 'energy').valueOrNull;

  Future<void> _finish(Food food) async {
    if (!mounted) {
      return;
    }
    if (_editing || widget.returnCreatedFood) {
      Navigator.of(context).pop(food);
      return;
    }
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => ServingDetailScreen(food: food, date: widget.date),
      ),
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
    this.incomplete = false,
  });

  final String label;
  final String unit;
  final TextEditingController controller;
  final Color accent;
  final Color background;

  /// Total hasil hitungan tidak lengkap (Design D1): ditandai, tidak pernah
  /// tampil seolah lengkap.
  final bool incomplete;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(minHeight: 86),
      child: MealoraCard(
        radius: MealoraRadius.choiceCard,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(label, style: MealoraTypography.label),
            if (incomplete)
              Container(
                margin: const EdgeInsets.only(top: 2),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                decoration: BoxDecoration(
                  color: MealoraColors.iconFieldAmber,
                  borderRadius: BorderRadius.circular(MealoraRadius.track),
                ),
                child: Text(
                  AppText.of(context).recipeIncompleteChip,
                  style: MealoraTypography.caption.copyWith(
                    color: MealoraColors.amberText,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
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
                        style: MealoraTypography.nutrientFieldValue.copyWith(
                          color: accent,
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
