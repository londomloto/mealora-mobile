import 'dart:async' show unawaited;
import 'dart:io';

import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show SystemUiOverlayStyle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/errors/result.dart';
import 'package:mealora/domain/diary/meal_entry.dart' show NewMealEntry;
import 'package:mealora/domain/food/meal_time.dart';
import 'package:mealora/domain/food/nutrition_profile.dart';
import 'package:mealora/domain/food/partial_nutrition_total.dart';
import 'package:mealora/domain/food_photo_input/photo_draft.dart';
import 'package:mealora/domain/image_ai_access/image_ai_settings.dart';
import 'package:mealora/features/diary/diary_controller.dart';
import 'package:mealora/features/diary/diary_format.dart';
import 'package:mealora/features/diary/diary_providers.dart';
import 'package:mealora/features/diary/food_component_correction_screen.dart';
import 'package:mealora/features/diary/food_photo_draft_storage.dart';
import 'package:mealora/features/diary/food_photo_saved_screen.dart';
import 'package:mealora/features/diary/option_sheet.dart';
import 'package:mealora/features/diary/voice_input_shared.dart'
    show voiceUndeterminedLabel;
import 'package:mealora/features/reminders/late_meal_notice.dart';
import 'package:mealora/features/share/meal_share_card.dart';
import 'package:mealora/features/share/share_preview_screen.dart';
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

  /// Komponen tanpa padanan (change 021, design D2).
  List<PhotoDraftComponent> get _unmatched => _draft.components
      .where((c) => c.matchedFoodId == null)
      .toList(growable: false);

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final photo = _draft.sourceImagePath;
    final unmatchedCount = _unmatched.length;
    // Change 021 (`92`): bila ada bahan tanpa padanan, kartu ringkasan
    // menyebut jumlahnya; selain itu tetap catatan saran foto/suara.
    final noticeTitle = unmatchedCount > 0
        ? text.foodPhotoReviewUnmatchedTitle(unmatchedCount)
        : switch (widget.origin) {
            ComponentDraftOrigin.photo => text.foodPhotoReviewBadge,
            ComponentDraftOrigin.voice => text.voiceReviewBadge,
            ComponentDraftOrigin.voiceOnDevice => text.voiceReviewOnDeviceBadge,
          };
    final noticeBody = unmatchedCount > 0
        ? text.foodPhotoReviewUnmatchedBody
        : switch (widget.origin) {
            ComponentDraftOrigin.photo => text.foodPhotoReviewBadgeNote,
            ComponentDraftOrigin.voice => text.voiceReviewBadgeNote,
            ComponentDraftOrigin.voiceOnDevice =>
              text.voiceReviewOnDeviceBadgeNote,
          };
    final content = _content(text);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        unawaited(_confirmCancel());
      },
      child: Scaffold(
        backgroundColor: MealoraColors.background,
        body: MealoraBlobBackdrop(
          child: photo == null
              ? SafeArea(
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
                        _backHeader(text),
                        const SizedBox(height: MealoraSpacing.md),
                        MealoraNoteCard(
                          icon: Icons.info_outline,
                          title: noticeTitle,
                          body: noticeBody,
                          background: MealoraColors.iconFieldAmber,
                          foreground: MealoraColors.amberText,
                        ),
                        const SizedBox(height: MealoraSpacing.lg),
                        ...content,
                      ],
                    ),
                  ),
                )
              : SingleChildScrollView(
                  padding: EdgeInsets.only(
                    bottom:
                        MealoraSpacing.xl +
                        MediaQuery.paddingOf(context).bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      _PhotoHero(
                        path: photo,
                        closeLabel: text.backButtonSemantics,
                        onClose: () => unawaited(_confirmCancel()),
                        noticeTitle: noticeTitle,
                        noticeBody: noticeBody,
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          MealoraSpacing.programHeroGutter,
                          MealoraSpacing.md,
                          MealoraSpacing.programHeroGutter,
                          0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: content,
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }

  Widget _backHeader(AppText text) => Row(
    children: <Widget>[
      Semantics(
        button: true,
        label: text.backButtonSemantics,
        child: InkWell(
          onTap: () => unawaited(_confirmCancel()),
          borderRadius: BorderRadius.circular(MealoraRadius.pill),
          child: const Padding(
            padding: EdgeInsets.all(MealoraSpacing.xxs),
            child: Icon(Icons.arrow_back, color: MealoraColors.ink),
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
  );

  List<Widget> _content(AppText text) => <Widget>[
    Text(
      widget.origin.isVoice
          ? text.voiceReviewComponentsTitle
          : text.foodPhotoReviewTitle,
      style: MealoraTypography.title,
    ),
    const SizedBox(height: MealoraSpacing.xxs),
    Text(text.foodPhotoReviewSubtitle, style: MealoraTypography.subtitle),
    const SizedBox(height: MealoraSpacing.lg),
    Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          text.foodPhotoReviewEmptyTitle,
          style: MealoraTypography.sectionTitle,
        ),
        Text(
          text.foodPhotoReviewComponentCount(_draft.components.length),
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
            for (var i = 0; i < _draft.components.length; i++) ...<Widget>[
              if (i > 0) const Divider(height: 1),
              _ComponentSummaryRow(
                component: _draft.components[i],
                text: text,
                onEdit: () => unawaited(_openCorrection()),
                onComplete: () => unawaited(
                  _openCorrection(
                    focusComponentId: _draft.components[i].localId,
                  ),
                ),
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
    const SizedBox(height: MealoraSpacing.md),
    if (_unmatched.isNotEmpty) ...<Widget>[
      MealoraPrimaryButton(
        label: text.foodPhotoReviewCompleteItemsAction(_unmatched.length),
        onPressed: _saving
            ? null
            : () => unawaited(
                _openCorrection(focusComponentId: _unmatched.first.localId),
              ),
      ),
      if (widget.origin == ComponentDraftOrigin.photo) ...<Widget>[
        const SizedBox(height: MealoraSpacing.xs),
        Center(
          child: TextButton.icon(
            key: const ValueKey<String>('review-share-without-logging'),
            onPressed: () => unawaited(_shareWithoutLogging()),
            icon: const Icon(
              Icons.ios_share,
              size: 14,
              color: MealoraColors.primary,
            ),
            label: Text(
              text.foodPhotoReviewShareWithoutLogging,
              style: MealoraTypography.photoReviewLink,
            ),
          ),
        ),
      ],
    ] else
      MealoraPrimaryButton(
        label: text.foodPhotoReviewConfirmAction,
        onPressed: _canConfirm ? () => unawaited(_confirm()) : null,
      ),
  ];

  Future<void> _openCorrection({String? focusComponentId}) async {
    final updated = await Navigator.of(context).push<PhotoDraft>(
      MaterialPageRoute<PhotoDraft>(
        builder: (_) => FoodComponentCorrectionScreen(
          draft: _draft,
          origin: widget.origin,
          focusComponentId: focusComponentId,
        ),
      ),
    );
    if (updated != null && mounted) {
      setState(() => _draft = updated);
    }
  }

  /// "Bagikan saja tanpa mencatat" (change 021, design D4): kartu tanpa
  /// total dari draf apa adanya. Tidak menulis buku harian; menutup
  /// pratinjau kembali ke layar ini dengan draf utuh.
  Future<void> _shareWithoutLogging() async {
    final text = AppText.of(context);
    final data = MealShareData(
      mealTimeLabel: DiaryFormat.mealTimeLabel(_draft.mealTime, text),
      items: <MealShareItem>[
        for (final c in _draft.components)
          MealShareItem(
            name: c.matchedFoodName ?? c.foodNameGuess,
            portion: componentAmount(c, null),
            kcal: null,
          ),
      ],
      photoPath: _draft.sourceImagePath,
    ).withoutNutrition(notLogged: true);
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => SharePreviewScreen(
          card: MealShareCard(data: data),
          caption: text.shareMealNoTotalCaption,
          notice: text.shareMealNotLoggedNote,
        ),
      ),
    );
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

  /// Membuang draf DB dan — bila [keepPhoto] `false` — foto sesuai
  /// retensi. Setelah log berhasil, foto ditahan untuk layar "Tersimpan"
  /// (change 014, Design D3) dan dilepas saat layar itu ditutup.
  Future<void> _discardDraft({bool keepPhoto = false}) async {
    if (!widget.origin.persistsDraft) return;
    await discardPhotoDraft(ref, _draft.id);
    if (keepPhoto) return;
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
    final shareItems = <MealShareItem>[];
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
      shareItems.add(
        MealShareItem(
          name: food.name,
          portion: DiaryFormat.entryAmount(serving.label, component.quantity),
          kcal: serving.nutrition.scaledBy(component.quantity).energy?.kcal,
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

    final isPhoto = widget.origin == ComponentDraftOrigin.photo;
    await _discardDraft(keepPhoto: isPhoto);
    if (!mounted) return;

    if (isPhoto) {
      // Layar "Tersimpan" (change 014, task 3.1) menggantikan alur foto;
      // kembali dari sana langsung ke halaman awal.
      final text = AppText.of(context);
      unawaited(
        Navigator.of(context).pushAndRemoveUntil<void>(
          MaterialPageRoute<void>(
            builder: (_) => FoodPhotoSavedScreen(
              date: _draft.localDate,
              meal: MealShareData(
                mealTimeLabel: DiaryFormat.mealTimeLabel(_draft.mealTime, text),
                items: shareItems,
                photoPath: _draft.sourceImagePath,
              ),
            ),
          ),
          (route) => route.isFirst,
        ),
      );
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
        date: _draft.localDate,
      ),
    );
  }
}

class _ComponentSummaryRow extends ConsumerWidget {
  const _ComponentSummaryRow({
    required this.component,
    required this.text,
    required this.onEdit,
    required this.onComplete,
  });

  final PhotoDraftComponent component;
  final AppText text;
  final VoidCallback onEdit;

  /// "Lengkapi" untuk komponen tanpa padanan (change 021, design D2).
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = component.matchedFoodName ?? component.foodNameGuess;
    final unmatched = component.matchedFoodId == null;
    final servingLabel = ref
        .watch(componentServingLabelProvider(component))
        .valueOrNull;
    return FutureBuilder<NutritionProfile?>(
      future: _nutritionFor(ref),
      builder: (context, snapshot) {
        final nutrition = snapshot.data;
        final detail = unmatched
            ? text.foodComponentNotInCatalog
            : component.quantityUndetermined
            ? voiceUndeterminedLabel(text, component.quantityUnitLabel)
            : '${componentAmount(component, servingLabel)} '
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
                        style: unmatched
                            ? MealoraTypography.caption.copyWith(
                                color: MealoraColors.coralText,
                              )
                            : MealoraTypography.caption,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                if (unmatched)
                  _ActionChip(
                    label: text.foodPhotoReviewCompleteAction,
                    semanticsLabel: text.foodPhotoReviewCompleteSemantics(name),
                    background: MealoraColors.iconFieldCoral,
                    foreground: MealoraColors.coralText,
                    onTap: onComplete,
                  )
                else
                  _ActionChip(
                    label: text.foodPhotoReviewEditAction,
                    background: MealoraColors.iconFieldGreen,
                    foreground: MealoraColors.primary,
                    onTap: onEdit,
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
    return FutureBuilder<PartialNutritionTotal>(
      future: _total(ref),
      builder: (context, snapshot) {
        final total = snapshot.data;
        if (total == null) return const SizedBox.shrink();
        // Change 021 (design D1): nilai belum diketahui tidak pernah nol;
        // total belum lengkap berwarna amber (`92`).
        return Text(
          text.foodPhotoReviewTotalSummary(
            DiaryFormat.partialKcal(total.energyKcal, text),
            DiaryFormat.partialGramsCompact(total.proteinG, text),
            DiaryFormat.partialGramsCompact(total.carbohydrateG, text),
            DiaryFormat.partialGramsCompact(total.fatG, text),
          ),
          style: MealoraTypography.photoReviewTotals.copyWith(
            color: total.energyKcal.isComplete
                ? MealoraColors.ink
                : MealoraColors.amberText,
          ),
        );
      },
    );
  }

  /// Komponen tanpa padanan, takaran belum jelas, atau makanan yang hilang
  /// diwakili `null` — dihitung belum diketahui, bukan dilewati.
  Future<PartialNutritionTotal> _total(WidgetRef ref) async {
    final repository = ref.read(foodRepositoryProvider);
    final profiles = <NutritionProfile?>[];
    for (final component in components) {
      final foodId = component.matchedFoodId;
      if (foodId == null || component.quantityUndetermined) {
        profiles.add(null);
        continue;
      }
      final food = await repository.findById(foodId);
      if (food == null) {
        profiles.add(null);
        continue;
      }
      final serving = component.matchedServingId == null
          ? food.defaultServing
          : food.servingById(component.matchedServingId!);
      profiles.add(serving.nutrition.scaledBy(component.quantity));
    }
    return PartialNutritionTotal.of(profiles);
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

/// Chip aksi berbentuk pil di baris komponen (`92`): Lengkapi (coral)
/// atau Ubah (hijau).
class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
    this.semanticsLabel,
  });

  final String label;
  final String? semanticsLabel;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel ?? label,
      excludeSemantics: true,
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(MealoraRadius.chip),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(MealoraRadius.chip),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 27),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: MealoraSpacing.sm,
                vertical: 6,
              ),
              child: Center(
                widthFactor: 1,
                heightFactor: 1,
                child: Text(
                  label,
                  style: MealoraTypography.photoReviewChip.copyWith(
                    color: foreground,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Foto hero tinjau foto (`92`, change 021): foto penuh selebar layar
/// dengan tombol tutup kaca dan kartu ringkasan yang menumpang di tepi
/// bawahnya.
class _PhotoHero extends StatelessWidget {
  const _PhotoHero({
    required this.path,
    required this.closeLabel,
    required this.onClose,
    required this.noticeTitle,
    required this.noticeBody,
  });

  static const double photoHeight = 300;
  static const double noticeOverlap = 38;

  final String path;
  final String closeLabel;
  final VoidCallback onClose;
  final String noticeTitle;
  final String noticeBody;

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: _stack(top),
    );
  }

  Widget _stack(double top) {
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(bottom: 72 - noticeOverlap),
          child: ClipRRect(
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(MealoraRadius.sheet),
            ),
            child: SizedBox(
              height: photoHeight + top,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  Image.file(
                    File(path),
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) =>
                        const ColoredBox(color: MealoraColors.track),
                  ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    height: 140 + top,
                    child: const DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: <Color>[
                            MealoraColors.photoHeroScrim,
                            MealoraColors.photoHeroScrimClear,
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          left: 22,
          top: top + 32,
          child: Semantics(
            button: true,
            label: closeLabel,
            excludeSemantics: true,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(MealoraRadius.chip),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Material(
                  color: MealoraColors.photoHeroButton,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(MealoraRadius.chip),
                    side: const BorderSide(
                      color: MealoraColors.photoHeroButtonBorder,
                    ),
                  ),
                  child: InkWell(
                    onTap: onClose,
                    borderRadius: BorderRadius.circular(MealoraRadius.chip),
                    child: const SizedBox.square(
                      dimension: 44,
                      child: Icon(
                        Icons.arrow_back,
                        size: 18,
                        color: MealoraColors.onPrimary,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: 22,
          right: 22,
          bottom: 0,
          // Kaca buram + bayangan seperti desain (`MealoraCard`).
          child: MealoraCard(
            radius: MealoraRadius.cardLarge,
            padding: const EdgeInsets.symmetric(
              horizontal: MealoraSpacing.md,
              vertical: MealoraSpacing.md,
            ),
            child: Row(
              children: <Widget>[
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: MealoraColors.iconFieldAmber,
                    borderRadius: BorderRadius.circular(
                      MealoraRadius.compactIconField,
                    ),
                  ),
                  child: const Icon(
                    Icons.auto_awesome,
                    size: 18,
                    color: MealoraColors.accent,
                  ),
                ),
                const SizedBox(width: MealoraSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Text(
                        noticeTitle,
                        style: MealoraTypography.photoReviewNoticeTitle,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        noticeBody,
                        style: MealoraTypography.photoReviewNoticeBody,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
