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
Future<Food?> showFoodComponentPickerSheet(BuildContext context) {
  return showModalBottomSheet<Food>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _FoodComponentPickerSheet(),
  );
}

class _FoodComponentPickerSheet extends ConsumerStatefulWidget {
  const _FoodComponentPickerSheet();

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
      initialChildSize: 0.75,
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
                  text.foodComponentPickerTitle,
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
                        ),
                ),
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
      builder: (context) => const _QuickCreateFoodSheet(),
    );
    if (created != null && context.mounted) {
      Navigator.of(context).pop(created);
    }
  }
}

class _ResultsList extends ConsumerWidget {
  const _ResultsList({
    required this.query,
    required this.scrollController,
    required this.text,
  });

  final String query;
  final ScrollController scrollController;
  final AppText text;

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
                food.defaultServing.label,
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
  const _QuickCreateFoodSheet();

  @override
  ConsumerState<_QuickCreateFoodSheet> createState() =>
      _QuickCreateFoodSheetState();
}

class _QuickCreateFoodSheetState extends ConsumerState<_QuickCreateFoodSheet> {
  final _name = TextEditingController();
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
                text.foodComponentPickerCreateLink,
                style: MealoraTypography.sectionTitle,
              ),
              const SizedBox(height: MealoraSpacing.md),
              _field(text.customFoodNameLabel, _name),
              const SizedBox(height: MealoraSpacing.sm),
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
        label: servingLabel.valueOrNull!,
        amount: 1,
        unit: 'porsi',
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
