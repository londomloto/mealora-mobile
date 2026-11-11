import 'dart:async' show unawaited;
import 'dart:typed_data' show Uint8List;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/format/id_formatters.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/domain/food/food.dart';
import 'package:mealora/domain/food/food_category.dart';
import 'package:mealora/domain/food/nutrition_profile.dart';
import 'package:mealora/domain/food/serving_size.dart';
import 'package:mealora/domain/image_ai_access/image_ai_settings.dart';
import 'package:mealora/domain/image_ai_access/label_extraction.dart';
import 'package:mealora/domain/image_ai_access/reading_confidence.dart';
import 'package:mealora/domain/packaged_food/packaged_food.dart';
import 'package:mealora/domain/packaged_food/packaged_food_provenance.dart';
import 'package:mealora/domain/packaged_food/serving_basis.dart';
import 'package:mealora/domain/shared/units.dart';
import 'package:mealora/features/diary/option_sheet.dart';
import 'package:mealora/features/diary/packaged_food_review_screen.dart';
import 'package:mealora/features/diary/source_image_storage.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// `24 · Tinjau ekstraksi label` (task 7.1-7.9, change 010) — bagian
/// terberat (workorder.md): foto asli berdampingan dengan nilai yang
/// terbaca, penanda keyakinan per nilai, basis yang ditegaskan, dan
/// konfirmasi yang tertahan sampai seluruh nilai penting beres (Design D5).
///
/// SHALL TIDAK membuat catatan maupun rekaman produk apa pun sebelum tombol
/// konfirmasi DI LAYAR INI ditekan (task 7.9) — menutupnya (eyebrow kembali
/// atau tombol sistem) selalu melalui dialog konfirmasi batal, tidak pernah
/// `Navigator.pop` langsung.
class NutritionLabelReviewScreen extends ConsumerStatefulWidget {
  const NutritionLabelReviewScreen({
    required this.photoBytes,
    required this.extraction,
    this.barcode,
    this.date,
    super.key,
  });

  final Uint8List photoBytes;
  final LabelExtraction extraction;

  /// `null` ketika produk dikonfirmasi tanpa barcode (change 010, jalur
  /// foto langsung dari layar pindai) — produk tersimpan dengan barcode
  /// kosong, hanya ditemukan kembali lewat pencarian nama.
  final String? barcode;
  final LocalDate? date;

  @override
  ConsumerState<NutritionLabelReviewScreen> createState() =>
      _NutritionLabelReviewScreenState();
}

class _NutritionLabelReviewScreenState
    extends ConsumerState<NutritionLabelReviewScreen> {
  final _name = TextEditingController();
  late ServingBasis? _basis;
  bool _basisTouched = false;
  late final ReadingConfidence _basisInitialConfidence;

  late final _ReviewField _servingSize;
  late final _ReviewField _servingsPerPackage;
  late final _ReviewField _energy;
  late final _ReviewField _protein;
  late final _ReviewField _carbohydrate;
  late final _ReviewField _fat;

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _basis = widget.extraction.basis.kind.asServingBasis;
    _basisInitialConfidence = widget.extraction.basis.confidence;

    _servingSize = _ReviewField(widget.extraction.servingSize);
    _servingsPerPackage = _ReviewField(widget.extraction.servingsPerPackage);
    _energy = _ReviewField(widget.extraction.energyKcal);
    _protein = _ReviewField(widget.extraction.protein);
    _carbohydrate = _ReviewField(widget.extraction.carbohydrate);
    _fat = _ReviewField(widget.extraction.fat);
  }

  @override
  void dispose() {
    _name.dispose();
    _servingSize.dispose();
    _servingsPerPackage.dispose();
    _energy.dispose();
    _protein.dispose();
    _carbohydrate.dispose();
    _fat.dispose();
    super.dispose();
  }

  bool get _isPerServing => _basis == ServingBasis.perServing;

  bool get _basisResolved =>
      _basis != null &&
      (_basisInitialConfidence == ReadingConfidence.confident || _basisTouched);

  List<String> _pendingFieldLabels(AppText text) {
    final pending = <String>[];
    if (!_basisResolved) pending.add(text.labelReviewBasisLabel);
    if (!_energy.isResolved) pending.add(text.nutrientEnergy);
    if (!_protein.isResolved) pending.add(text.nutrientProtein);
    if (!_carbohydrate.isResolved) pending.add(text.nutrientCarbohydrate);
    if (!_fat.isResolved) pending.add(text.nutrientFat);
    return pending;
  }

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final pending = _pendingFieldLabels(text);
    final canConfirm = pending.isEmpty && !_saving;

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
                          text.labelReviewContextLabel,
                          style: MealoraTypography.eyebrow,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: MealoraSpacing.xs),
                  Text(text.labelReviewTitle, style: MealoraTypography.title),
                  const SizedBox(height: MealoraSpacing.xxs),
                  Text(
                    text.labelReviewSubtitle,
                    style: MealoraTypography.subtitle,
                  ),
                  const SizedBox(height: MealoraSpacing.lg),
                  MealoraCard(
                    radius: MealoraRadius.choiceCard,
                    padding: const EdgeInsets.all(MealoraSpacing.xxs),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        MealoraRadius.choiceCard - MealoraSpacing.xxs,
                      ),
                      child: Image.memory(
                        widget.photoBytes,
                        height: 196,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: MealoraSpacing.lg),
                  _ReviewGlassInputField(
                    label: text.labelReviewNameLabel,
                    hint: text.labelReviewNameHint,
                    controller: _name,
                  ),
                  const SizedBox(height: MealoraSpacing.md),
                  _BasisField(
                    label: text.labelReviewBasisLabel,
                    value: _basis == null ? null : _basisLabel(_basis!, text),
                    confidence: _basis == null
                        ? ReadingConfidence.unread
                        : (_basisResolved
                              ? ReadingConfidence.confident
                              : _basisInitialConfidence),
                    text: text,
                    onTap: _pickBasis,
                  ),
                  if (_basis == null) ...<Widget>[
                    const SizedBox(height: MealoraSpacing.xxs),
                    Text(
                      text.labelReviewBasisUnreadNote,
                      style: MealoraTypography.caption.copyWith(
                        color: MealoraColors.danger,
                      ),
                    ),
                  ],
                  if (_isPerServing) ...<Widget>[
                    const SizedBox(height: MealoraSpacing.md),
                    _ReviewNutrientRow(
                      label: text.customFoodServingLabel,
                      unit: text.unitGram,
                      field: _servingSize,
                      text: text,
                      onChanged: () => setState(() {}),
                      allowMarkAbsent: false,
                    ),
                    const SizedBox(height: MealoraSpacing.sm),
                    _ReviewNutrientRow(
                      label: text.packagedFoodFillUnitsPerPackageLabel,
                      unit: '',
                      field: _servingsPerPackage,
                      text: text,
                      onChanged: () => setState(() {}),
                      allowMarkAbsent: false,
                    ),
                    if (_servingSize.value != null &&
                        _servingsPerPackage.value != null) ...<Widget>[
                      const SizedBox(height: MealoraSpacing.xs),
                      Text(
                        text.labelReviewPackageArithmeticNote(
                          IdFormat.decimal(_servingsPerPackage.value!),
                          '${IdFormat.decimal(_servingSize.value!)} '
                          '${text.unitGram}',
                        ),
                        style: MealoraTypography.caption,
                      ),
                    ],
                  ],
                  const SizedBox(height: MealoraSpacing.lg),
                  Text(
                    _isPerServing
                        ? text.customFoodNutritionHeading
                        : text.packagedFoodReviewNutritionHeadingPer100g,
                    style: MealoraTypography.headline,
                  ),
                  const SizedBox(height: MealoraSpacing.sm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: _ReviewNutrientRow(
                          label: text.nutrientEnergy,
                          unit: text.unitKilocalorie,
                          field: _energy,
                          text: text,
                          onChanged: () => setState(() {}),
                          accent: MealoraColors.amberText,
                          accentBackground: MealoraColors.iconFieldAmber,
                        ),
                      ),
                      const SizedBox(width: MealoraSpacing.sm),
                      Expanded(
                        child: _ReviewNutrientRow(
                          label: text.nutrientProtein,
                          unit: text.unitGram,
                          field: _protein,
                          text: text,
                          onChanged: () => setState(() {}),
                          accent: MealoraColors.primary,
                          accentBackground: MealoraColors.iconFieldGreen,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: MealoraSpacing.sm),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Expanded(
                        child: _ReviewNutrientRow(
                          label: text.nutrientCarbohydrate,
                          unit: text.unitGram,
                          field: _carbohydrate,
                          text: text,
                          onChanged: () => setState(() {}),
                          accent: MealoraColors.amberText,
                          accentBackground: MealoraColors.iconFieldAmber,
                        ),
                      ),
                      const SizedBox(width: MealoraSpacing.sm),
                      Expanded(
                        child: _ReviewNutrientRow(
                          label: text.nutrientFat,
                          unit: text.unitGram,
                          field: _fat,
                          text: text,
                          onChanged: () => setState(() {}),
                          accent: MealoraColors.coralText,
                          accentBackground: MealoraColors.iconFieldCoral,
                        ),
                      ),
                    ],
                  ),
                  if (pending.isNotEmpty) ...<Widget>[
                    const SizedBox(height: MealoraSpacing.md),
                    Semantics(
                      liveRegion: true,
                      child: MealoraNoteCard(
                        icon: Icons.info_outline,
                        body: text.labelReviewPendingValuesNote(
                          pending.join(', '),
                        ),
                        background: MealoraColors.iconFieldAmber,
                        foreground: MealoraColors.amberText,
                      ),
                    ),
                  ],
                  const SizedBox(height: MealoraSpacing.xl),
                  MealoraPrimaryButton(
                    label: text.labelReviewConfirmAction,
                    onPressed: canConfirm ? () => unawaited(_confirm()) : null,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _basisLabel(ServingBasis basis, AppText text) => switch (basis) {
    ServingBasis.perServing => text.packagedFoodFillBasisPerServing,
    ServingBasis.perHundredGrams => text.packagedFoodFillBasisPer100g,
  };

  Future<void> _pickBasis() async {
    final picked = await showModalBottomSheet<ServingBasis>(
      context: context,
      builder: (context) => OptionSheet<ServingBasis>(
        title: AppText.of(context).labelReviewBasisLabel,
        options: ServingBasis.values,
        labelOf: (b) => _basisLabel(b, AppText.of(context)),
        selected: _basis ?? ServingBasis.perServing,
      ),
    );
    if (picked != null) {
      setState(() {
        _basis = picked;
        _basisTouched = true;
      });
    }
  }

  Future<void> _confirmCancel() async {
    final text = AppText.of(context);
    final shouldCancel = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(text.labelReviewCancelConfirmTitle),
        content: Text(text.labelReviewCancelConfirmBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(text.labelReviewCancelKeepReviewingAction),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(text.labelReviewCancelConfirmAction),
          ),
        ],
      ),
    );
    if (shouldCancel == true && mounted) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _confirm() async {
    setState(() => _saving = true);

    final retention = await ref.read(imageRetentionPreferenceProvider.future);
    String? sourceImagePath;
    if (retention == ImageRetentionPreference.keepOnDevice) {
      sourceImagePath = await saveSourceImage(
        widget.photoBytes,
        fileId: ref.read(idGeneratorProvider).next(),
      );
    }

    final isPerServing = _isPerServing;
    final nutrition = NutritionProfile(
      energy: _energy.value == null
          ? null
          : Energy.kcalValue(_energy.value!, field: 'energy').valueOrNull,
      proteinG: _protein.value,
      carbohydrateG: _carbohydrate.value,
      fatG: _fat.value,
    );

    final servingGrams = _servingSize.value;
    final product = PackagedFood(
      food: Food(
        id: 'pending-label-food',
        name: _name.text.trim(),
        category: FoodCategory.other,
        isUserCreated: true,
        servings: <ServingSize>[
          ServingSize(
            id: 'pending-label-serving',
            label: isPerServing
                ? (servingGrams == null
                      ? '1 sajian'
                      : '${IdFormat.decimal(servingGrams)} g · 1 sajian')
                : '100 g',
            amount: isPerServing ? 1 : 100,
            unit: isPerServing ? 'sajian' : 'g',
            gramEquivalent: isPerServing ? servingGrams : 100,
            isDefault: true,
            nutrition: nutrition,
          ),
        ],
      ),
      barcode: widget.barcode,
      unitsPerPackage: isPerServing ? _servingsPerPackage.value : null,
      servingBasis: _basis!,
      provenance: PackagedFoodProvenance(
        sourceType: 'label_extraction',
        verifiedAt: ref.read(clockProvider).nowUtc(),
        userCorrected: false,
        sourceImagePath: sourceImagePath,
      ),
    );

    if (!mounted) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) =>
            PackagedFoodReviewScreen(product: product, date: widget.date),
      ),
    );
  }
}

/// Satu nilai yang dapat disunting hasil ekstraksi — melacak apakah
/// pengguna sudah menyunting ATAU menyatakan nilainya memang tidak
/// tercantum (task 7.6/7.7), terpisah dari nilai itu sendiri.
class _ReviewField {
  _ReviewField(ExtractedNumber extracted)
    : controller = TextEditingController(
        text: extracted.value == null ? '' : IdFormat.decimal(extracted.value!),
      ),
      _initialConfidence = extracted.confidence;

  final TextEditingController controller;
  final ReadingConfidence _initialConfidence;
  bool _touched = false;
  bool _markedAbsent = false;

  bool get isResolved =>
      _initialConfidence == ReadingConfidence.confident ||
      _touched ||
      _markedAbsent;

  ReadingConfidence get displayConfidence =>
      isResolved ? ReadingConfidence.confident : _initialConfidence;

  double? get value {
    final trimmed = controller.text.trim();
    if (trimmed.isEmpty) return null;
    return double.tryParse(trimmed.replaceAll(',', '.'));
  }

  void markTouched() {
    _touched = true;
    _markedAbsent = false;
  }

  void markAbsent() {
    controller.clear();
    _markedAbsent = true;
    _touched = false;
  }

  void dispose() => controller.dispose();
}

class _BasisField extends StatelessWidget {
  const _BasisField({
    required this.label,
    required this.value,
    required this.confidence,
    required this.text,
    required this.onTap,
  });

  final String label;
  final String? value;
  final ReadingConfidence confidence;
  final AppText text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final displayValue = value ?? text.labelReviewConfidenceUnread;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 2),
          child: Text(label, style: MealoraTypography.label),
        ),
        const SizedBox(height: MealoraSpacing.xxs),
        Semantics(
          button: true,
          label:
              '$label. $displayValue. '
              '${_confidenceLabel(confidence, text)}',
          child: InkWell(
            borderRadius: BorderRadius.circular(MealoraRadius.button),
            onTap: onTap,
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
                      displayValue,
                      style: MealoraTypography.bodyEmphasis,
                    ),
                  ),
                  _ConfidenceBadge(confidence: confidence, text: text),
                  const SizedBox(width: MealoraSpacing.xs),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: MealoraColors.affordance,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Field kaca yang mengikuti bahasa visual `15 · Makanan buatan sendiri`,
/// tetapi tetap berupa input teks biasa agar hasil ekstraksi mudah dikoreksi.
class _ReviewGlassInputField extends StatelessWidget {
  const _ReviewGlassInputField({
    required this.label,
    required this.hint,
    required this.controller,
  });

  final String label;
  final String hint;
  final TextEditingController controller;

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
                      contentPadding: EdgeInsets.zero,
                      isDense: true,
                    ),
                  ),
                ),
                const SizedBox(width: MealoraSpacing.sm),
                const Icon(
                  Icons.edit_outlined,
                  size: MealoraIconSize.inline,
                  color: MealoraColors.affordance,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ReviewNutrientRow extends StatelessWidget {
  const _ReviewNutrientRow({
    required this.label,
    required this.unit,
    required this.field,
    required this.text,
    required this.onChanged,
    this.allowMarkAbsent = true,
    this.accent = MealoraColors.ink,
    this.accentBackground = MealoraColors.iconField,
  });

  final String label;
  final String unit;
  final _ReviewField field;
  final AppText text;
  final VoidCallback onChanged;
  final bool allowMarkAbsent;
  final Color accent;
  final Color accentBackground;

  @override
  Widget build(BuildContext context) {
    return MealoraCard(
      radius: MealoraRadius.choiceCard,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: MealoraTypography.label),
          const SizedBox(height: MealoraSpacing.xxs),
          Row(
            children: <Widget>[
              Expanded(
                child: Semantics(
                  label:
                      '$label. '
                      '${_confidenceLabel(field.displayConfidence, text)}',
                  textField: true,
                  child: TextField(
                    controller: field.controller,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: MealoraTypography.nutrientFieldValue.copyWith(
                      color: accent,
                    ),
                    decoration: InputDecoration(
                      isDense: true,
                      filled: false,
                      fillColor: MealoraColors.transparent,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      suffixText: unit.isEmpty ? null : unit,
                      suffixStyle: MealoraTypography.bodySmall.copyWith(
                        color: accent,
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                    onChanged: (_) {
                      field.markTouched();
                      onChanged();
                    },
                  ),
                ),
              ),
              _ConfidenceBadge(confidence: field.displayConfidence, text: text),
              if (allowMarkAbsent && field.controller.text.isEmpty) ...<Widget>[
                const SizedBox(width: MealoraSpacing.xs),
                Semantics(
                  button: true,
                  selected: field._markedAbsent,
                  label: text.labelReviewMarkAbsentAction,
                  child: InkWell(
                    onTap: () {
                      field.markAbsent();
                      onChanged();
                    },
                    child: Icon(
                      Icons.block_outlined,
                      size: MealoraIconSize.action,
                      color: field._markedAbsent
                          ? MealoraColors.primary
                          : MealoraColors.muted,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: MealoraSpacing.xxs),
          Container(
            width: 28,
            height: 4,
            decoration: BoxDecoration(
              color: accentBackground,
              borderRadius: BorderRadius.circular(MealoraRadius.track),
            ),
          ),
          // Teks, bukan hanya warna ikon — pengguna low-vision maupun
          // pembaca layar SHALL TIDAK bergantung pada warna saja untuk
          // tahu sebuah nilai sudah ditandai tidak tercantum (task 9.2).
          if (field._markedAbsent) ...<Widget>[
            const SizedBox(height: MealoraSpacing.xxs),
            Semantics(
              liveRegion: true,
              child: Text(
                text.labelReviewValueMarkedAbsent,
                style: MealoraTypography.caption.copyWith(
                  color: MealoraColors.primary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ConfidenceBadge extends StatelessWidget {
  const _ConfidenceBadge({required this.confidence, required this.text});

  final ReadingConfidence confidence;
  final AppText text;

  @override
  Widget build(BuildContext context) {
    final (icon, color, label) = switch (confidence) {
      ReadingConfidence.confident => (
        Icons.check_circle_outline,
        MealoraColors.primary,
        text.labelReviewConfidenceConfident,
      ),
      ReadingConfidence.needsCheck => (
        Icons.error_outline,
        MealoraColors.amberText,
        text.labelReviewConfidenceNeedsCheck,
      ),
      ReadingConfidence.unread => (
        Icons.help_outline,
        MealoraColors.danger,
        text.labelReviewConfidenceUnread,
      ),
    };
    return Semantics(
      label: label,
      child: Icon(icon, size: MealoraIconSize.action, color: color),
    );
  }
}

String _confidenceLabel(ReadingConfidence confidence, AppText text) =>
    switch (confidence) {
      ReadingConfidence.confident => text.labelReviewConfidenceConfident,
      ReadingConfidence.needsCheck => text.labelReviewConfidenceNeedsCheck,
      ReadingConfidence.unread => text.labelReviewConfidenceUnread,
    };
