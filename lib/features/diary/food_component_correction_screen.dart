import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/domain/food/food.dart';
import 'package:mealora/domain/food/serving_size.dart';
import 'package:mealora/domain/food_photo_input/photo_draft.dart';
import 'package:mealora/domain/nutrition_import/nutrition_import.dart';
import 'package:mealora/domain/nutrition_import/nutrition_reading.dart';
import 'package:mealora/features/diary/custom_food_screen.dart';
import 'package:mealora/features/diary/diary_controller.dart';
import 'package:mealora/features/diary/diary_format.dart';
import 'package:mealora/features/diary/diary_providers.dart';
import 'package:mealora/features/diary/food_component_picker_sheet.dart';
import 'package:mealora/features/diary/voice_input_shared.dart'
    show voiceUndeterminedLabel;
import 'package:mealora/l10n/generated/app_localizations.dart';

/// `38 · Koreksi komponen foto` (task 5.3-5.6, change 011): daftar lengkap
/// komponen draf yang dapat dikoreksi — padanan, porsi, metode masak,
/// penambahan bahan tak terlihat (minyak, saus), dan penghapusan komponen
/// keliru (Design D4/D5). Dicapai dari `FoodPhotoReviewScreen` (`03`) lewat
/// "Ubah" pada komponen mana pun; "Tinjau total baru" mengembalikan draf
/// yang sudah dikoreksi ke layar itu.
///
/// SHALL TIDAK mencatat apa pun — murni mengubah [PhotoDraft] yang
/// disimpan ulang pada setiap perubahan (Design D6).
class FoodComponentCorrectionScreen extends ConsumerStatefulWidget {
  const FoodComponentCorrectionScreen({
    required this.draft,
    this.origin = ComponentDraftOrigin.photo,
    this.focusComponentId,
    super.key,
  });

  final PhotoDraft draft;
  final ComponentDraftOrigin origin;

  /// Change 021 (design D2): "Lengkapi" di tinjau foto langsung membuka
  /// sheet komponen ini, lalu kembali ke tinjau foto begitu sheet ditutup.
  final String? focusComponentId;

  @override
  ConsumerState<FoodComponentCorrectionScreen> createState() =>
      _FoodComponentCorrectionScreenState();
}

class _FoodComponentCorrectionScreenState
    extends ConsumerState<FoodComponentCorrectionScreen> {
  late PhotoDraft _draft;

  @override
  void initState() {
    super.initState();
    _draft = widget.draft;
    final focusId = widget.focusComponentId;
    if (focusId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final component = _draft.components
            .where((c) => c.localId == focusId)
            .firstOrNull;
        if (component == null || !mounted) return;
        await _editComponent(component);
        if (mounted) Navigator.of(context).pop(_draft);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {},
      child: Scaffold(
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
                  Row(
                    children: <Widget>[
                      Semantics(
                        button: true,
                        label: text.backButtonSemantics,
                        child: InkWell(
                          onTap: () => Navigator.of(context).pop(_draft),
                          borderRadius: BorderRadius.circular(
                            MealoraRadius.pill,
                          ),
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
                          widget.origin.isVoice
                              ? text.voiceComponentCorrectionBadge
                              : text.foodComponentCorrectionBadge,
                          style: MealoraTypography.eyebrow,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: MealoraSpacing.xs),
                  Text(
                    text.foodComponentCorrectionTitle,
                    style: MealoraTypography.title,
                  ),
                  const SizedBox(height: MealoraSpacing.xxs),
                  Text(
                    text.foodComponentCorrectionSubtitle,
                    style: MealoraTypography.subtitle,
                  ),
                  const SizedBox(height: MealoraSpacing.lg),
                  Text(
                    text.foodComponentCorrectionHeading,
                    style: MealoraTypography.sectionTitle,
                  ),
                  const SizedBox(height: MealoraSpacing.sm),
                  if (_draft.components.isEmpty)
                    MealoraEmptyState(
                      icon: Icons.restaurant_outlined,
                      title: text.foodPhotoReviewEmptyTitle,
                      body: text.foodComponentCorrectionSubtitle,
                    )
                  else
                    MealoraCard(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Column(
                        children: <Widget>[
                          for (
                            var i = 0;
                            i < _draft.components.length;
                            i++
                          ) ...<Widget>[
                            if (i > 0) const Divider(height: 1),
                            _ComponentRow(
                              component: _draft.components[i],
                              text: text,
                              onTap: () => unawaited(
                                _editComponent(_draft.components[i]),
                              ),
                              onRemove: () =>
                                  _removeComponent(_draft.components[i]),
                            ),
                          ],
                        ],
                      ),
                    ),
                  const SizedBox(height: MealoraSpacing.sm),
                  Semantics(
                    button: true,
                    child: InkWell(
                      onTap: () => unawaited(_addComponent()),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Icon(Icons.add, color: MealoraColors.primary),
                          const SizedBox(width: MealoraSpacing.xxs),
                          Flexible(
                            child: Text(
                              text.foodComponentCorrectionAddAction,
                              style: MealoraTypography.bodyEmphasis.copyWith(
                                color: MealoraColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: MealoraSpacing.xl),
                  MealoraPrimaryButton(
                    label: text.foodComponentCorrectionConfirmAction,
                    onPressed: () => Navigator.of(context).pop(_draft),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _addComponent() async {
    final food = await showFoodComponentPickerSheet(context);
    if (food == null) return;
    final component = PhotoDraftComponent(
      localId: ref.read(idGeneratorProvider).next(),
      foodNameGuess: food.name,
      matchedFoodId: food.id,
      matchedServingId: food.defaultServing.id,
      matchedFoodName: food.name,
      quantity: 1,
      portionNeedsCheck: true,
      cookingMethodNeedsCheck: false,
    );
    await _updateDraft([..._draft.components, component]);
  }

  void _removeComponent(PhotoDraftComponent component) {
    unawaited(
      _updateDraft(
        _draft.components.where((c) => c.localId != component.localId).toList(),
      ),
    );
  }

  Future<void> _editComponent(PhotoDraftComponent component) async {
    final updated = await showModalBottomSheet<PhotoDraftComponent>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _ComponentEditorSheet(component: component),
    );
    if (updated == null) return;
    await _updateDraft(
      _draft.components
          .map((c) => c.localId == updated.localId ? updated : c)
          .toList(),
    );
  }

  Future<void> _updateDraft(List<PhotoDraftComponent> components) async {
    final updated = _draft.withComponents(components);
    setState(() => _draft = updated);
    if (widget.origin.persistsDraft) await savePhotoDraft(ref, updated);
  }
}

class _ComponentRow extends ConsumerWidget {
  const _ComponentRow({
    required this.component,
    required this.text,
    required this.onTap,
    required this.onRemove,
  });

  final PhotoDraftComponent component;
  final AppText text;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final servingLabel = ref
        .watch(componentServingLabelProvider(component))
        .valueOrNull;
    final (statusColor, statusLabel) = _status(component, text);
    final name = component.matchedFoodName ?? component.foodNameGuess;
    final quantityText = component.quantityUndetermined
        ? voiceUndeterminedLabel(text, component.quantityUnitLabel)
        : componentAmount(component, servingLabel);

    return Semantics(
      button: true,
      label: '$name. $quantityText. $statusLabel',
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: MealoraSpacing.md,
            vertical: MealoraSpacing.sm,
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(
                  color: statusColor,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: MealoraSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(name, style: MealoraTypography.bodyEmphasis),
                    Text(
                      '$quantityText · $statusLabel',
                      style: MealoraTypography.caption,
                    ),
                  ],
                ),
              ),
              Semantics(
                button: true,
                label: text.foodComponentCorrectionRemoveAction,
                child: InkWell(
                  onTap: onRemove,
                  child: const Padding(
                    padding: EdgeInsets.all(MealoraSpacing.xxs),
                    child: Icon(
                      Icons.delete_outline,
                      color: MealoraColors.affordance,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  (Color, String) _status(PhotoDraftComponent c, AppText text) {
    if (c.foodMatchNeedsCheck) {
      return (MealoraColors.coralText, text.foodComponentNotInCatalog);
    }
    if (c.quantityUndetermined) {
      return (
        MealoraColors.danger,
        voiceUndeterminedLabel(text, c.quantityUnitLabel),
      );
    }
    if (c.cookingMethodNeedsCheck) {
      return (
        MealoraColors.amberText,
        text.foodComponentCookingMethodNeedsCheck,
      );
    }
    if (c.portionNeedsCheck) {
      return (MealoraColors.amberText, text.foodComponentPortionNeedsCheck);
    }
    return (MealoraColors.primary, text.foodComponentMatchOk);
  }
}

class _ComponentEditorSheet extends ConsumerStatefulWidget {
  const _ComponentEditorSheet({required this.component});

  final PhotoDraftComponent component;

  @override
  ConsumerState<_ComponentEditorSheet> createState() =>
      _ComponentEditorSheetState();
}

class _ComponentEditorSheetState extends ConsumerState<_ComponentEditorSheet> {
  late double _quantity;
  late String? _matchedFoodId;
  late String? _matchedServingId;
  late String? _matchedFoodName;
  String? _servingLabel;
  late final TextEditingController _cookingMethod;

  @override
  void initState() {
    super.initState();
    _quantity = widget.component.quantity <= 0 ? 1 : widget.component.quantity;
    _matchedFoodId = widget.component.matchedFoodId;
    _matchedServingId = widget.component.matchedServingId;
    _matchedFoodName = widget.component.matchedFoodName;
    _cookingMethod = TextEditingController(
      text: widget.component.cookingMethod ?? '',
    );
    unawaited(_loadServingLabel());
  }

  /// Label sajian padanan untuk satuan takaran (change 021, design D6).
  Future<void> _loadServingLabel() async {
    final foodId = _matchedFoodId;
    if (foodId == null) return;
    final food = await ref.read(foodRepositoryProvider).findById(foodId);
    if (food == null || !mounted) return;
    setState(() => _servingLabel = _servingOf(food, _matchedServingId).label);
  }

  @override
  void dispose() {
    _cookingMethod.dispose();
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              text.foodComponentEditorFoodLabel,
              style: MealoraTypography.label,
            ),
            const SizedBox(height: MealoraSpacing.xxs),
            if (_matchedFoodId == null)
              _NotInCatalogCard(
                name: widget.component.foodNameGuess,
                text: text,
                onSearch: () => unawaited(_changeFood(bindAndClose: true)),
                onCreate: () => unawaited(_createFood()),
              )
            else
              MealoraCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: MealoraSpacing.md,
                  vertical: MealoraSpacing.sm,
                ),
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        _matchedFoodName ?? widget.component.foodNameGuess,
                        style: MealoraTypography.bodyEmphasis,
                      ),
                    ),
                    TextButton(
                      onPressed: () => unawaited(_changeFood()),
                      child: Text(text.foodComponentEditorFoodChangeAction),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: MealoraSpacing.md),
            Text(
              text.foodComponentEditorQuantityLabel,
              style: MealoraTypography.label,
            ),
            const SizedBox(height: MealoraSpacing.xxs),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  onPressed: _quantity > 0.5
                      ? () => setState(() => _quantity -= 0.5)
                      : null,
                  icon: const Icon(Icons.remove),
                ),
                Flexible(
                  child: Text(
                    DiaryFormat.entryAmount(
                      _servingLabel ??
                          unitServingLabel(widget.component.quantityUnitLabel),
                      _quantity,
                    ),
                    textAlign: TextAlign.center,
                    style: MealoraTypography.headline,
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _quantity += 0.5),
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            const SizedBox(height: MealoraSpacing.md),
            Text(
              text.foodComponentEditorCookingMethodLabel,
              style: MealoraTypography.label,
            ),
            const SizedBox(height: MealoraSpacing.xxs),
            TextField(
              controller: _cookingMethod,
              decoration: InputDecoration(
                hintText: text.foodComponentEditorCookingMethodHint,
                isDense: true,
              ),
            ),
            const SizedBox(height: MealoraSpacing.lg),
            MealoraPrimaryButton(
              label: text.foodComponentEditorSaveAction,
              onPressed: _save,
            ),
          ],
        ),
      ),
    );
  }

  /// [bindAndClose]: komponen tanpa padanan langsung tersimpan dan sheet
  /// tertutup begitu makanan dipilih (change 021, design D2).
  Future<void> _changeFood({bool bindAndClose = false}) async {
    final food = await showFoodComponentPickerSheet(context);
    if (food == null || !mounted) return;
    _bind(food);
    if (bindAndClose) _save();
  }

  /// "Buat makanan ini": form Buat makanan berisi nama dan sajian
  /// perkiraan; makanan tersimpan menjadi padanan. Batal = tetap tanpa
  /// padanan.
  Future<void> _createFood() async {
    final component = widget.component;
    final food = await Navigator.of(context).push<Food>(
      MaterialPageRoute<Food>(
        builder: (_) => CustomFoodScreen(
          returnCreatedFood: true,
          prefill: NutritionImportResult(
            foodName: component.foodNameGuess,
            servingLabel: component.quantityUnitLabel == null
                ? null
                : unitServingLabel(component.quantityUnitLabel),
            values: const <ImportNutrient, double?>{},
          ),
        ),
      ),
    );
    if (food == null || !mounted) return;
    _bind(food);
    _save();
  }

  void _bind(Food food) {
    setState(() {
      _matchedFoodId = food.id;
      _matchedServingId = food.defaultServing.id;
      _matchedFoodName = food.name;
      _servingLabel = food.defaultServing.label;
    });
  }

  void _save() {
    final cookingMethod = _cookingMethod.text.trim();
    Navigator.of(context).pop(
      PhotoDraftComponent(
        localId: widget.component.localId,
        foodNameGuess: widget.component.foodNameGuess,
        matchedFoodId: _matchedFoodId,
        matchedServingId: _matchedServingId,
        matchedFoodName: _matchedFoodName,
        quantity: _quantity,
        quantityUnitLabel: widget.component.quantityUnitLabel,
        cookingMethod: cookingMethod.isEmpty ? null : cookingMethod,
        portionNeedsCheck: false,
        cookingMethodNeedsCheck: false,
      ),
    );
  }
}

/// Kartu amber "Belum ada di katalog" dan dua pilihan (`93`): Cari di
/// katalog atau Buat makanan ini.
class _NotInCatalogCard extends StatelessWidget {
  const _NotInCatalogCard({
    required this.name,
    required this.text,
    required this.onSearch,
    required this.onCreate,
  });

  final String name;
  final AppText text;
  final VoidCallback onSearch;
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            color: MealoraColors.iconFieldAmber,
            borderRadius: BorderRadius.circular(MealoraRadius.button),
            border: Border.all(color: MealoraColors.notInCatalogBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(name, style: MealoraTypography.notInCatalogName),
              const SizedBox(height: MealoraSpacing.xxs),
              Text(
                text.foodComponentNotInCatalogHint,
                style: MealoraTypography.notInCatalogHint,
              ),
            ],
          ),
        ),
        const SizedBox(height: MealoraSpacing.sm),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Expanded(
                child: _ComponentOption(
                  icon: Icons.search,
                  title: text.foodComponentSearchCatalogAction,
                  subtitle: text.foodComponentSearchCatalogSub,
                  background: MealoraColors.glassSoft,
                  border: MealoraColors.componentOptionBorder,
                  onTap: onSearch,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _ComponentOption(
                  icon: Icons.add_circle_outline,
                  title: text.foodComponentCreateFoodAction,
                  subtitle: text.foodComponentCreateFoodSub,
                  background: MealoraColors.iconFieldGreen,
                  border: MealoraColors.componentOptionCreateBorder,
                  onTap: onCreate,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ComponentOption extends StatelessWidget {
  const _ComponentOption({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.background,
    required this.border,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color background;
  final Color border;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(MealoraRadius.chip + 6);
    return Semantics(
      button: true,
      label: '$title. $subtitle',
      excludeSemantics: true,
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: radius,
          side: BorderSide(color: border),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Icon(icon, size: 18, color: MealoraColors.primary),
                const SizedBox(height: MealoraSpacing.xxs),
                Text(title, style: MealoraTypography.componentOptionTitle),
                const SizedBox(height: MealoraSpacing.xxs),
                Text(subtitle, style: MealoraTypography.componentOptionSub),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

ServingSize _servingOf(Food food, String? servingId) =>
    servingId == null ? food.defaultServing : food.servingById(servingId);

/// Label sajian satu satuan dari tebakan model ("potong" → "1 potong").
String unitServingLabel(String? unit) {
  final trimmed = unit?.trim() ?? '';
  if (trimmed.isEmpty) return '1 porsi';
  return RegExp(r'^\d').hasMatch(trimmed) ? trimmed : '1 $trimmed';
}

/// Takaran komponen dengan satuan (change 021, design D6): "1 potong",
/// "1,5 × 1 cangkir". Tanpa padanan memakai satuan tebakan model.
String componentAmount(PhotoDraftComponent component, String? servingLabel) =>
    DiaryFormat.entryAmount(
      servingLabel ?? unitServingLabel(component.quantityUnitLabel),
      component.quantity,
    );

/// Label sajian padanan sebuah komponen, `null` bila tanpa padanan.
final componentServingLabelProvider = FutureProvider.autoDispose
    .family<String?, PhotoDraftComponent>((ref, component) async {
      final foodId = component.matchedFoodId;
      if (foodId == null) return null;
      final food = await ref.read(foodRepositoryProvider).findById(foodId);
      if (food == null) return null;
      return _servingOf(food, component.matchedServingId).label;
    });
