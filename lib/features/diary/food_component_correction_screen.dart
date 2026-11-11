import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/domain/food_photo_input/photo_draft.dart';
import 'package:mealora/features/diary/diary_providers.dart';
import 'package:mealora/features/diary/food_component_picker_sheet.dart';
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
  const FoodComponentCorrectionScreen({required this.draft, super.key});

  final PhotoDraft draft;

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
                          text.foodComponentCorrectionBadge,
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
                          Text(
                            text.foodComponentCorrectionAddAction,
                            style: MealoraTypography.bodyEmphasis.copyWith(
                              color: MealoraColors.primary,
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
    await savePhotoDraft(ref, updated);
  }
}

class _ComponentRow extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final (statusColor, statusLabel) = _status(component, text);
    final name = component.matchedFoodName ?? component.foodNameGuess;
    final quantityText = component.matchedServingId == null
        ? component.foodNameGuess
        : '${component.quantity.toStringAsFixed(1).replaceAll('.', ',')}×';

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
      return (MealoraColors.danger, text.foodComponentMatchMissing);
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
                Text(
                  _quantity.toStringAsFixed(1).replaceAll('.', ','),
                  style: MealoraTypography.headline,
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

  Future<void> _changeFood() async {
    final food = await showFoodComponentPickerSheet(context);
    if (food == null) return;
    setState(() {
      _matchedFoodId = food.id;
      _matchedServingId = food.defaultServing.id;
      _matchedFoodName = food.name;
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
