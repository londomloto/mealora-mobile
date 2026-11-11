import 'dart:async' show unawaited;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/errors/result.dart';
import 'package:mealora/core/format/id_formatters.dart';
import 'package:mealora/domain/diary/meal_entry.dart' show NewMealEntry;
import 'package:mealora/domain/food/meal_time.dart';
import 'package:mealora/domain/food/nutrition_profile.dart';
import 'package:mealora/domain/food_photo_input/photo_draft.dart';
import 'package:mealora/domain/image_ai_access/image_ai_settings.dart';
import 'package:mealora/features/diary/diary_controller.dart';
import 'package:mealora/features/diary/diary_format.dart';
import 'package:mealora/features/diary/diary_providers.dart';
import 'package:mealora/features/diary/food_component_correction_screen.dart';
import 'package:mealora/features/diary/food_photo_draft_storage.dart';
import 'package:mealora/features/diary/option_sheet.dart';
import 'package:mealora/features/diary/voice_input_shared.dart'
    show voiceUndeterminedLabel;
import 'package:mealora/l10n/generated/app_localizations.dart';

/// `03 · Tinjau foto makanan` (task 5.1/5.2/5.8/5.9, change 011): ringkasan
/// komponen yang sudah dipadankan, siap dikonfirmasi — satu-satunya layar
/// yang SHALL mencatat (spec, "Foto mengusulkan komponen, bukan mencatat").
/// Menutup layar ini TANPA konfirmasi SHALL TIDAK pernah membuat catatan
/// apa pun (task 5.9).
class FoodPhotoReviewScreen extends ConsumerStatefulWidget {
  const FoodPhotoReviewScreen({
    required this.draft,
    this.origin = ComponentDraftOrigin.photo,
    super.key,
  });

  final PhotoDraft draft;

  /// Jalur suara (change 012, design D7) memakai ulang layar ini.
  final ComponentDraftOrigin origin;

  @override
  ConsumerState<FoodPhotoReviewScreen> createState() =>
      _FoodPhotoReviewScreenState();
}

class _FoodPhotoReviewScreenState extends ConsumerState<FoodPhotoReviewScreen> {
  late PhotoDraft _draft;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _draft = widget.draft;
  }

  bool get _canConfirm =>
      !_saving &&
      _draft.components.isNotEmpty &&
      _draft.components.every(
        (c) => c.matchedFoodId != null && !c.quantityUndetermined,
      );

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        unawaited(_confirmCancel());
      },
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
                          onTap: () => unawaited(_confirmCancel()),
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
                              ? text.voiceReviewComponentsContextLabel
                              : text.foodPhotoReviewContextLabel,
                          style: MealoraTypography.eyebrow,
                        ),
                      ),
                    ],
                  ),
                  if (_draft.sourceImagePath != null) ...<Widget>[
                    const SizedBox(height: MealoraSpacing.sm),
                    MealoraCard(
                      radius: MealoraRadius.choiceCard,
                      padding: const EdgeInsets.all(MealoraSpacing.xxs),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          MealoraRadius.choiceCard - MealoraSpacing.xxs,
                        ),
                        child: Image.file(
                          File(_draft.sourceImagePath!),
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: MealoraSpacing.md),
                  MealoraNoteCard(
                    icon: Icons.info_outline,
                    title: switch (widget.origin) {
                      ComponentDraftOrigin.photo => text.foodPhotoReviewBadge,
                      ComponentDraftOrigin.voice => text.voiceReviewBadge,
                      ComponentDraftOrigin.voiceOnDevice =>
                        text.voiceReviewOnDeviceBadge,
                    },
                    body: switch (widget.origin) {
                      ComponentDraftOrigin.photo =>
                        text.foodPhotoReviewBadgeNote,
                      ComponentDraftOrigin.voice => text.voiceReviewBadgeNote,
                      ComponentDraftOrigin.voiceOnDevice =>
                        text.voiceReviewOnDeviceBadgeNote,
                    },
                    background: MealoraColors.iconFieldAmber,
                    foreground: MealoraColors.amberText,
                  ),
                  const SizedBox(height: MealoraSpacing.lg),
                  Text(
                    widget.origin.isVoice
                        ? text.voiceReviewComponentsTitle
                        : text.foodPhotoReviewTitle,
                    style: MealoraTypography.title,
                  ),
                  const SizedBox(height: MealoraSpacing.xxs),
                  Text(
                    text.foodPhotoReviewSubtitle,
                    style: MealoraTypography.subtitle,
                  ),
                  const SizedBox(height: MealoraSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text(
                        text.foodPhotoReviewEmptyTitle,
                        style: MealoraTypography.sectionTitle,
                      ),
                      Text(
                        text.foodPhotoReviewComponentCount(
                          _draft.components.length,
                        ),
                        style: MealoraTypography.caption,
                      ),
                    ],
                  ),
                  const SizedBox(height: MealoraSpacing.sm),
                  if (_draft.components.isEmpty)
                    MealoraEmptyState(
                      icon: Icons.restaurant_outlined,
                      title: text.foodPhotoReviewEmptyTitle,
                      body: text.foodComponentCorrectionAddAction,
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
                            _ComponentSummaryRow(
                              component: _draft.components[i],
                              text: text,
                              onEdit: () => unawaited(_openCorrection()),
                            ),
                          ],
                        ],
                      ),
                    ),
                  const SizedBox(height: MealoraSpacing.md),
                  _MealTimeField(
                    mealTime: _draft.mealTime,
                    onPicked: (mealTime) => unawaited(_setMealTime(mealTime)),
                  ),
                  const SizedBox(height: MealoraSpacing.lg),
                  _TotalSummary(components: _draft.components, text: text),
                  const SizedBox(height: MealoraSpacing.lg),
                  MealoraPrimaryButton(
                    label: text.foodPhotoReviewConfirmAction,
                    onPressed: _canConfirm ? () => unawaited(_confirm()) : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openCorrection() async {
    final updated = await Navigator.of(context).push<PhotoDraft>(
      MaterialPageRoute<PhotoDraft>(
        builder: (_) =>
            FoodComponentCorrectionScreen(draft: _draft, origin: widget.origin),
      ),
    );
    if (updated != null && mounted) {
      setState(() => _draft = updated);
    }
  }

  Future<void> _setMealTime(MealTime mealTime) async {
    await _updateDraft(
      PhotoDraft(
        id: _draft.id,
        profileId: _draft.profileId,
        localDate: _draft.localDate,
        mealTime: mealTime,
        sourceImagePath: _draft.sourceImagePath,
        components: _draft.components,
        createdAt: _draft.createdAt,
      ),
    );
  }

  Future<void> _updateDraft(PhotoDraft draft) async {
    setState(() => _draft = draft);
    if (widget.origin.persistsDraft) await savePhotoDraft(ref, draft);
  }

  Future<void> _confirmCancel() async {
    final text = AppText.of(context);
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(text.foodPhotoReviewCancelConfirmTitle),
        content: Text(
          widget.origin.isVoice
              ? text.voiceReviewCancelConfirmBody
              : text.foodPhotoReviewCancelConfirmBody,
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(text.foodPhotoReviewCancelKeepReviewingAction),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(text.foodPhotoReviewCancelConfirmAction),
          ),
        ],
      ),
    );
    if (shouldCancel != true || !mounted) return;
    await _discardDraft();
    if (mounted) Navigator.of(context).pop();
  }

  Future<void> _discardDraft() async {
    if (!widget.origin.persistsDraft) return;
    await discardPhotoDraft(ref, _draft.id);
    final path = _draft.sourceImagePath;
    if (path == null) return;
    final retention = await ref.read(imageRetentionPreferenceProvider.future);
    if (retention == ImageRetentionPreference.deleteAfterLogging) {
      await deleteDraftPhoto(path);
    }
  }

  Future<void> _confirm() async {
    setState(() => _saving = true);
    final entries = <NewMealEntry>[];
    for (final component in _draft.components) {
      final food = await ref
          .read(foodRepositoryProvider)
          .findById(component.matchedFoodId!);
      if (food == null) {
        continue;
      }
      final serving = component.matchedServingId == null
          ? food.defaultServing
          : food.servingById(component.matchedServingId!);
      entries.add(
        NewMealEntry(
          food: food,
          serving: serving,
          quantity: component.quantity,
        ),
      );
    }

    if (entries.isEmpty) {
      setState(() => _saving = false);
      return;
    }

    final result = await logFoodEntries(
      ref,
      mealTime: _draft.mealTime,
      entries: entries,
      date: _draft.localDate,
    );
    if (!mounted) return;
    if (result is Err) {
      setState(() => _saving = false);
      return;
    }

    await _discardDraft();
    if (!mounted) return;
    Navigator.of(context).popUntil((route) => route.isFirst);
  }
}

class _ComponentSummaryRow extends ConsumerWidget {
  const _ComponentSummaryRow({
    required this.component,
    required this.text,
    required this.onEdit,
  });

  final PhotoDraftComponent component;
  final AppText text;
  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = component.matchedFoodName ?? component.foodNameGuess;
    return FutureBuilder<NutritionProfile?>(
      future: _nutritionFor(ref),
      builder: (context, snapshot) {
        final nutrition = snapshot.data;
        final detail = component.matchedFoodId == null
            ? text.foodComponentMatchMissing
            : component.quantityUndetermined
            ? voiceUndeterminedLabel(text, component.quantityUnitLabel)
            : '${component.quantity.toStringAsFixed(1).replaceAll('.', ',')}× '
                  '·  ${DiaryFormat.kcal(nutrition?.energy, text)}';
        return SizedBox(
          height: 52,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: MealoraSpacing.md),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: MealoraTypography.bodyEmphasis,
                      ),
                      Text(
                        detail,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: MealoraTypography.caption,
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: onEdit,
                  child: Text(text.foodPhotoReviewEditAction),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<NutritionProfile?> _nutritionFor(WidgetRef ref) async {
    final foodId = component.matchedFoodId;
    final servingId = component.matchedServingId;
    if (foodId == null || component.quantityUndetermined) return null;
    final food = await ref.read(foodRepositoryProvider).findById(foodId);
    if (food == null) return null;
    final serving = servingId == null
        ? food.defaultServing
        : food.servingById(servingId);
    return serving.nutrition.scaledBy(component.quantity);
  }
}

class _TotalSummary extends ConsumerWidget {
  const _TotalSummary({required this.components, required this.text});

  final List<PhotoDraftComponent> components;
  final AppText text;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<NutritionProfile>(
      future: _total(ref),
      builder: (context, snapshot) {
        final total = snapshot.data ?? NutritionProfile.unknown;
        return Text(
          text.foodPhotoReviewTotalSummary(
            IdFormat.decimal(total.energy?.kcal ?? 0),
            IdFormat.decimal(total.proteinG ?? 0),
            IdFormat.decimal(total.carbohydrateG ?? 0),
            IdFormat.decimal(total.fatG ?? 0),
          ),
          style: MealoraTypography.bodyEmphasis,
        );
      },
    );
  }

  Future<NutritionProfile> _total(WidgetRef ref) async {
    final repository = ref.read(foodRepositoryProvider);
    final profiles = <NutritionProfile>[];
    for (final component in components) {
      final foodId = component.matchedFoodId;
      if (foodId == null || component.quantityUndetermined) continue;
      final food = await repository.findById(foodId);
      if (food == null) continue;
      final serving = component.matchedServingId == null
          ? food.defaultServing
          : food.servingById(component.matchedServingId!);
      profiles.add(serving.nutrition.scaledBy(component.quantity));
    }
    return NutritionProfile.sumAll(profiles);
  }
}

class _MealTimeField extends StatelessWidget {
  const _MealTimeField({required this.mealTime, required this.onPicked});

  final MealTime mealTime;
  final ValueChanged<MealTime> onPicked;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return Semantics(
      button: true,
      label:
          '${text.servingDetailMealTimeLabel}. '
          '${DiaryFormat.mealTimeLabel(mealTime, text)}',
      child: InkWell(
        borderRadius: BorderRadius.circular(MealoraRadius.button),
        onTap: () => unawaited(_pick(context)),
        child: MealoraCard(
          radius: MealoraRadius.button,
          padding: const EdgeInsets.symmetric(
            horizontal: MealoraSpacing.md,
            vertical: MealoraSpacing.md,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  DiaryFormat.mealTimeLabel(mealTime, text),
                  style: MealoraTypography.bodyEmphasis,
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

  Future<void> _pick(BuildContext context) async {
    final text = AppText.of(context);
    final picked = await showModalBottomSheet<MealTime>(
      context: context,
      builder: (context) => OptionSheet<MealTime>(
        title: text.mealTimePickerTitle,
        options: MealTime.values,
        labelOf: (m) => DiaryFormat.mealTimeLabel(m, text),
        selected: mealTime,
      ),
    );
    if (picked != null) {
      onPicked(picked);
    }
  }
}
