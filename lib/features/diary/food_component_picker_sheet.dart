import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/errors/result.dart';
import 'package:mealora/core/validation/value_rules.dart';
import 'package:mealora/domain/food/food.dart';
import 'package:mealora/domain/food/food_repository.dart' show ServingSizeInput;
import 'package:mealora/domain/food/nutrition_profile.dart';
import 'package:mealora/domain/shared/units.dart';
import 'package:mealora/features/diary/diary_providers.dart';
import 'package:mealora/features/diary/recipe_widgets.dart' show foodFormLabel;
import 'package:mealora/l10n/generated/app_localizations.dart';

/// Pencarian/pembuatan makanan untuk memadankan satu komponen foto (change
/// 011, task 5.4/5.5) — dipakai dari `FoodComponentCorrectionScreen` (`38`)
/// baik untuk mengganti padanan komponen yang sudah ada maupun menambah
/// komponen yang tidak terdeteksi. Mengembalikan [Food] terpilih lewat
/// `Navigator.pop`, atau `null` bila dibatalkan.
///
/// Memakai ulang `foodSearchProvider` (features/diary, change 007, Design
/// D3) apa adanya — SATU-SATUNYA titik yang membaca katalog untuk jalur
/// foto (Design D1).
Future<Food?> showFoodComponentPickerSheet(BuildContext context) async {
  final picked = await showModalBottomSheet<Object>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _FoodComponentPickerSheet(),
  );
  return picked is Food ? picked : null;
}

/// Hasil pemilihan bahan resep (change 016, Design D5): makanan katalog/
/// buatan pengguna, atau bahan tanpa data gizi (nama saja).
sealed class RecipeIngredientPick {
  const RecipeIngredientPick();
}

final class PickedFood extends RecipeIngredientPick {
  const PickedFood(this.food);
  final Food food;
}

final class PickedFreeText extends RecipeIngredientPick {
  const PickedFreeText(this.name);
  final String name;
}

/// Pemilihan bahan resep — memakai ulang lembar pemilihan komponen foto,
/// ditambah "buat bahan baru" (isi per 100 g) dan "tambah tanpa data gizi".
Future<RecipeIngredientPick?> showRecipeIngredientPickerSheet(
  BuildContext context,
) async {
  final picked = await showModalBottomSheet<Object>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _FoodComponentPickerSheet(recipeMode: true),
  );
  return switch (picked) {
    final Food food => PickedFood(food),
    final PickedFreeText freeText => freeText,
    _ => null,
  };
}

class _FoodComponentPickerSheet extends ConsumerStatefulWidget {
  const _FoodComponentPickerSheet({this.recipeMode = false});

  final bool recipeMode;

  @override
  ConsumerState<_FoodComponentPickerSheet> createState() =>
      _FoodComponentPickerSheetState();
}

class _FoodComponentPickerSheetState
    extends ConsumerState<_FoodComponentPickerSheet> {
  final _controller = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: widget.recipeMode ? 0.9 : 0.75,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(MealoraSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  widget.recipeMode
                      ? text.recipePickerTitle
                      : text.foodComponentPickerTitle,
                  style: MealoraTypography.sectionTitle,
                ),
                const SizedBox(height: MealoraSpacing.sm),
                SizedBox(
                  height: 52,
                  child: MealoraCard(
                    radius: MealoraRadius.button,
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    child: Row(
                      children: <Widget>[
                        const Icon(
                          Icons.search,
                          size: 18,
                          color: MealoraColors.primaryDeep,
                        ),
                        const SizedBox(width: MealoraSpacing.sm),
                        Expanded(
                          child: TextField(
                            controller: _controller,
                            autofocus: true,
                            style: MealoraTypography.bodyEmphasis,
                            onChanged: (value) =>
                                setState(() => _query = value.trim()),
                            decoration: InputDecoration(
                              hintText: text.foodComponentPickerHint,
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
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: MealoraSpacing.sm),
                if (!widget.recipeMode)
                  Semantics(
                    button: true,
                    child: InkWell(
                      onTap: () => unawaited(_createFood(context)),
                      child: Text(
                        text.foodComponentPickerCreateLink,
                        style: MealoraTypography.bodyEmphasis.copyWith(
                          color: MealoraColors.primary,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: MealoraSpacing.md),
                Expanded(
                  child: _query.isEmpty
                      ? const SizedBox.shrink()
                      : _ResultsList(
                          query: _query,
                          scrollController: scrollController,
                          text: text,
                          showForm: widget.recipeMode,
                        ),
                ),
                if (widget.recipeMode) ...<Widget>[
                  const SizedBox(height: MealoraSpacing.sm),
                  Text(
                    text.recipePickerFallbackHeading,
                    style: MealoraTypography.bodyEmphasis,
                  ),
                  const SizedBox(height: MealoraSpacing.xs),
                  _FallbackAction(
                    icon: Icons.add_circle_outline,
                    title: text.recipePickerCreateTitle,
                    body: text.recipePickerCreateBody,
                    primary: true,
                    onTap: () => unawaited(_createFood(context)),
                  ),
                  const SizedBox(height: MealoraSpacing.xs),
                  _FallbackAction(
                    icon: Icons.blur_circular_outlined,
                    title: text.recipePickerFreeTextTitle,
                    body: text.recipePickerFreeTextBody,
                    onTap: () => unawaited(_addFreeText(context)),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _createFood(BuildContext context) async {
    final created = await showModalBottomSheet<Food>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _QuickCreateFoodSheet(
        per100g: widget.recipeMode,
        initialName: _query,
      ),
    );
    if (created != null && context.mounted) {
      Navigator.of(context).pop(created);
    }
  }

  Future<void> _addFreeText(BuildContext context) async {
    final name = await showDialog<String>(
      context: context,
      builder: (context) => _FreeTextNameDialog(initialName: _query),
    );
    if (name != null && name.isNotEmpty && context.mounted) {
      Navigator.of(context).pop(PickedFreeText(name));
    }
  }
}

class _FallbackAction extends StatelessWidget {
  const _FallbackAction({
    required this.icon,
    required this.title,
    required this.body,
    required this.onTap,
    this.primary = false,
  });

  final IconData icon;
  final String title;
  final String body;
  final VoidCallback onTap;
  final bool primary;

  @override
  Widget build(BuildContext context) {
    final accent = primary
        ? MealoraColors.primaryDeep
        : MealoraColors.amberText;
    return Semantics(
      button: true,
      child: InkWell(
        borderRadius: BorderRadius.circular(MealoraRadius.button),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: MealoraSpacing.md,
            vertical: MealoraSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: MealoraColors.glassCard,
            borderRadius: BorderRadius.circular(MealoraRadius.button),
            border: Border.all(
              color: primary ? accent : MealoraColors.glassBorder,
              width: primary ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: <Widget>[
              Icon(icon, size: 20, color: accent),
              const SizedBox(width: MealoraSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      style: MealoraTypography.bodyEmphasis.copyWith(
                        color: primary ? accent : null,
                      ),
                    ),
                    Text(body, style: MealoraTypography.caption),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right,
                size: 18,
                color: MealoraColors.affordance,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FreeTextNameDialog extends StatefulWidget {
  const _FreeTextNameDialog({required this.initialName});

  final String initialName;

  @override
  State<_FreeTextNameDialog> createState() => _FreeTextNameDialogState();
}

class _FreeTextNameDialogState extends State<_FreeTextNameDialog> {
  late final _controller = TextEditingController(text: widget.initialName);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return AlertDialog(
      title: Text(text.recipePickerFreeTextTitle),
      content: TextField(
        controller: _controller,
        autofocus: true,
        decoration: InputDecoration(labelText: text.recipeFreeTextNameLabel),
      ),
      actions: <Widget>[
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(MaterialLocalizations.of(context).cancelButtonLabel),
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
          child: Text(MaterialLocalizations.of(context).okButtonLabel),
        ),
      ],
    );
  }
}

class _ResultsList extends ConsumerWidget {
  const _ResultsList({
    required this.query,
    required this.scrollController,
    required this.text,
    this.showForm = false,
  });

  final String query;
  final ScrollController scrollController;
  final AppText text;
  final bool showForm;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(foodSearchProvider(query));
    return results.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (_, _) => const SizedBox.shrink(),
      data: (foods) {
        if (foods.isEmpty) {
          return MealoraEmptyState(
            icon: Icons.search_off_rounded,
            title: text.foodComponentPickerNoResultsTitle,
            body: text.foodComponentPickerNoResultsBody,
          );
        }
        return ListView.separated(
          controller: scrollController,
          itemCount: foods.length,
          separatorBuilder: (_, _) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final food = foods[index];
            return ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(food.name, style: MealoraTypography.bodyEmphasis),
              subtitle: Text(
                <String>[
                  food.defaultServing.label,
                  if (showForm && food.form != null)
                    foodFormLabel(text, food.form!),
                ].join(' · '),
                style: MealoraTypography.caption,
              ),
              onTap: () => Navigator.of(context).pop(food),
            );
          },
        );
      },
    );
  }
}

/// Formulir ringkas membuat makanan buatan pengguna baru tanpa langsung
/// mencatatnya (berbeda dari `CustomFoodScreen`, `15`, yang berakhir pada
/// pencatatan langsung) — dipakai saat komponen foto tidak punya padanan
/// sama sekali (spec, "Komponen tanpa padanan").
class _QuickCreateFoodSheet extends ConsumerStatefulWidget {
  const _QuickCreateFoodSheet({this.per100g = false, this.initialName = ''});

  /// Bahan resep baru: nilai diisi per 100 g (takaran 100 g ber-padanan
  /// berat) supaya bisa dipakai dengan gram (Design D5, change 016).
  final bool per100g;
  final String initialName;

  @override
  ConsumerState<_QuickCreateFoodSheet> createState() =>
      _QuickCreateFoodSheetState();
}

class _QuickCreateFoodSheetState extends ConsumerState<_QuickCreateFoodSheet> {
  late final _name = TextEditingController(text: widget.initialName);
  final _serving = TextEditingController(text: '1 porsi');
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
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(
          MealoraSpacing.lg,
          MealoraSpacing.lg,
          MealoraSpacing.lg,
          MealoraSpacing.lg + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                widget.per100g
                    ? text.recipePickerCreateTitle
                    : text.foodComponentPickerCreateLink,
                style: MealoraTypography.sectionTitle,
              ),
              const SizedBox(height: MealoraSpacing.md),
              _field(text.customFoodNameLabel, _name),
              const SizedBox(height: MealoraSpacing.sm),
              if (widget.per100g)
                Text(text.recipePer100gHeading, style: MealoraTypography.label)
              else
                _field(text.customFoodServingLabel, _serving),
              const SizedBox(height: MealoraSpacing.sm),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _field(text.nutrientEnergy, _energy, numeric: true),
                  ),
                  const SizedBox(width: MealoraSpacing.sm),
                  Expanded(
                    child: _field(
                      text.nutrientProtein,
                      _protein,
                      numeric: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: MealoraSpacing.sm),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _field(
                      text.nutrientCarbohydrate,
                      _carbohydrate,
                      numeric: true,
                    ),
                  ),
                  const SizedBox(width: MealoraSpacing.sm),
                  Expanded(
                    child: _field(text.nutrientFat, _fat, numeric: true),
                  ),
                ],
              ),
              if (_error != null) ...<Widget>[
                const SizedBox(height: MealoraSpacing.sm),
                Text(
                  _error!,
                  style: MealoraTypography.caption.copyWith(
                    color: MealoraColors.danger,
                  ),
                ),
              ],
              const SizedBox(height: MealoraSpacing.lg),
              MealoraPrimaryButton(
                label: text.foodComponentEditorSaveAction,
                onPressed: _saving ? null : () => unawaited(_save()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    bool numeric = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: MealoraTypography.label),
        const SizedBox(height: MealoraSpacing.xxs),
        TextField(
          controller: controller,
          keyboardType: numeric
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          decoration: const InputDecoration(isDense: true),
        ),
      ],
    );
  }

  Future<void> _save() async {
    final name = ValueRules.requiredText(_name.text.trim(), field: 'name');
    final servingLabel = ValueRules.requiredText(
      _serving.text.trim(),
      field: 'serving',
    );
    if (name is Err<String> || servingLabel is Err<String>) {
      setState(() => _error = 'Nama dan takaran wajib diisi.');
      return;
    }

    setState(() {
      _error = null;
      _saving = true;
    });

    final energyValue = double.tryParse(
      _energy.text.trim().replaceAll(',', '.'),
    );
    final food = await createUserFood(
      ref,
      name: name.valueOrNull!,
      serving: ServingSizeInput(
        label: widget.per100g ? '100 g' : servingLabel.valueOrNull!,
        amount: widget.per100g ? 100 : 1,
        unit: widget.per100g ? 'g' : 'porsi',
        gramEquivalent: widget.per100g ? 100 : null,
        nutrition: NutritionProfile(
          energy: energyValue == null
              ? null
              : Energy.kcalValue(energyValue, field: 'energy').valueOrNull,
          proteinG: double.tryParse(_protein.text.trim().replaceAll(',', '.')),
          carbohydrateG: double.tryParse(
            _carbohydrate.text.trim().replaceAll(',', '.'),
          ),
          fatG: double.tryParse(_fat.text.trim().replaceAll(',', '.')),
        ),
      ),
    );

    if (!mounted) return;
    Navigator.of(context).pop(food);
  }
}
