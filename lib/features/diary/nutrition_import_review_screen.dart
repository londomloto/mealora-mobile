import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/domain/nutrition_import/nutrition_import.dart';
import 'package:mealora/domain/nutrition_import/nutrition_reading.dart';
import 'package:mealora/features/diary/recipe_widgets.dart'
    show formatRecipeNumber, parseRecipeNumber;
import 'package:mealora/l10n/generated/app_localizations.dart';

/// `84 · Tinjau hasil tempel` dan `89 · dibaca tanpa AI` (change 020,
/// design D5). Semua nilai bisa diubah; "Pakai di Buat makanan" menutup
/// layar dengan [NutritionImportResult] tanpa menyimpan apa pun (spec
/// "Tujuan hasil mengikuti konteks dan jenis sumber").
class NutritionImportReviewScreen extends StatefulWidget {
  const NutritionImportReviewScreen({
    required this.reading,
    required this.tier,
    this.analyzePhoto,
    super.key,
  });

  final NutritionReading reading;
  final ReadingTier tier;

  /// Bila tidak `null` (sumber foto), menampilkan "Hasil kurang tepat?
  /// Analisis foto dengan AI" (layar 90). Foto hanya diunggah saat tautan
  /// ini ditekan (temuan uji HP #5).
  final Future<NutritionReadOutcome> Function()? analyzePhoto;

  @override
  State<NutritionImportReviewScreen> createState() =>
      _NutritionImportReviewScreenState();
}

class _NutritionImportReviewScreenState
    extends State<NutritionImportReviewScreen> {
  late NutritionReading _reading = widget.reading;
  late ReadingTier _tier = widget.tier;
  final TextEditingController _serving = TextEditingController();
  final Map<ImportNutrient, TextEditingController> _fields =
      <ImportNutrient, TextEditingController>{
        for (final n in ImportNutrient.values) n: TextEditingController(),
      };
  bool _invalid = false;
  bool _analyzing = false;
  bool _analyzeFailed = false;

  bool get _offline => _tier == ReadingTier.offline;

  @override
  void initState() {
    super.initState();
    _fill();
  }

  void _fill() {
    _serving.text = _reading.basis.servingLabel(formatRecipeNumber) ?? '';
    for (final e in _fields.entries) {
      e.value.text = switch (_reading.nutrient(e.key).proposed) {
        final double v => formatRecipeNumber(v),
        null => '',
      };
    }
  }

  Future<void> _analyzePhoto() async {
    setState(() {
      _analyzing = true;
      _analyzeFailed = false;
    });
    final outcome = await widget.analyzePhoto!();
    if (!mounted) return;
    setState(() {
      _analyzing = false;
      if (outcome is NutritionReadSuccess && outcome.reading.hasAnyNutrient) {
        _reading = outcome.reading;
        _tier = outcome.tier;
        _invalid = false;
        _fill();
      } else {
        _analyzeFailed = true;
      }
    });
  }

  @override
  void dispose() {
    _serving.dispose();
    for (final c in _fields.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _use() {
    final values = <ImportNutrient, double?>{};
    for (final e in _fields.entries) {
      final raw = e.value.text.trim();
      if (raw.isEmpty) {
        values[e.key] = null;
        continue;
      }
      final v = parseRecipeNumber(raw);
      if (v == null || v < 0 || !v.isFinite) {
        setState(() => _invalid = true);
        return;
      }
      values[e.key] = v;
    }
    final serving = _serving.text.trim();
    Navigator.of(context).pop(
      NutritionImportResult(
        foodName: _reading.foodName,
        servingLabel: serving.isEmpty ? null : serving,
        values: values,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final reading = _reading;
    final hasRange = ImportNutrient.values.any(
      (n) => reading.nutrient(n).status == NutrientReadStatus.range,
    );
    final basisRead = reading.basis.kind != NutritionBasisKind.unread;

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
                  label: _offline
                      ? text.nutritionReviewContextLabelOffline
                      : text.nutritionReviewContextLabel,
                ),
                const SizedBox(height: MealoraSpacing.xs),
                Text(text.nutritionReviewTitle, style: MealoraTypography.title),
                const SizedBox(height: MealoraSpacing.xxs),
                Text(
                  _offline
                      ? text.nutritionReviewSubtitleOffline
                      : text.nutritionReviewSubtitle,
                  style: MealoraTypography.subtitle,
                ),
                const SizedBox(height: MealoraSpacing.lg),
                MealoraCard(
                  padding: const EdgeInsets.all(MealoraSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        text.nutritionReviewBasisEyebrow,
                        style: MealoraTypography.eyebrow,
                      ),
                      const SizedBox(height: MealoraSpacing.xxs),
                      Semantics(
                        textField: true,
                        label: text.nutritionReviewServingLabel,
                        child: TextField(
                          key: const ValueKey('nutrition-review-serving'),
                          controller: _serving,
                          style: MealoraTypography.headline,
                          decoration: _plainDecoration(
                            text.nutritionReviewServingHint,
                          ),
                        ),
                      ),
                      if (reading.basis.description != null) ...<Widget>[
                        const SizedBox(height: MealoraSpacing.xxs),
                        Text(
                          reading.basis.description!,
                          style: MealoraTypography.bodySmall,
                        ),
                      ],
                      const SizedBox(height: MealoraSpacing.xxs),
                      Text(
                        basisRead
                            ? text.nutritionReviewBasisHint
                            : text.nutritionReviewBasisMissing,
                        style: MealoraTypography.caption.copyWith(
                          color: MealoraColors.amberText,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: MealoraSpacing.lg),
                Text(
                  text.nutritionReviewResultsHeading,
                  style: MealoraTypography.headline,
                ),
                const SizedBox(height: MealoraSpacing.xs),
                MealoraCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: MealoraSpacing.md,
                    vertical: MealoraSpacing.xs,
                  ),
                  child: Column(
                    children: <Widget>[
                      for (final (i, n) in ImportNutrient.values.indexed) ...[
                        if (i > 0) const Divider(height: 1),
                        _NutrientRow(
                          nutrient: n,
                          reading: reading.nutrient(n),
                          controller: _fields[n]!,
                          offline: _offline,
                          text: text,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: MealoraSpacing.sm),
                if (reading.ignoredNutrients.isNotEmpty)
                  Text(
                    text.nutritionReviewIgnored(
                      reading.ignoredNutrients.join(', '),
                    ),
                    style: MealoraTypography.caption,
                  ),
                if (hasRange && !_offline)
                  Text(
                    text.nutritionReviewRangeNote,
                    style: MealoraTypography.caption,
                  ),
                if (_offline)
                  Text(
                    text.nutritionReviewOfflineNote,
                    style: MealoraTypography.caption,
                  ),
                const SizedBox(height: MealoraSpacing.md),
                MealoraNoteCard(
                  icon: Icons.sell_outlined,
                  title: reading.foodName == null
                      ? text.nutritionReviewNameMissing
                      : text.nutritionReviewNameSuggestion(
                          _capitalize(reading.foodName!),
                        ),
                  body: reading.foodName == null
                      ? text.nutritionReviewNameMissingBody
                      : text.nutritionReviewNameSuggestionBody,
                  borderColor: MealoraColors.glassSoft,
                ),
                if (_invalid) ...<Widget>[
                  const SizedBox(height: MealoraSpacing.sm),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      text.nutritionReviewInvalidValue,
                      style: MealoraTypography.caption.copyWith(
                        color: MealoraColors.danger,
                      ),
                    ),
                  ),
                ],
                if (widget.analyzePhoto != null) ...<Widget>[
                  const SizedBox(height: MealoraSpacing.lg),
                  Center(
                    child: _analyzing
                        ? const CircularProgressIndicator()
                        : TextButton.icon(
                            key: const ValueKey('nutrition-review-analyze'),
                            onPressed: () => unawaited(_analyzePhoto()),
                            icon: const Icon(Icons.image_search_outlined),
                            label: Text(text.reviewAnalyzePhotoLink),
                          ),
                  ),
                  if (_analyzeFailed)
                    Semantics(
                      liveRegion: true,
                      child: Text(
                        text.analyzePhotoFailed,
                        textAlign: TextAlign.center,
                        style: MealoraTypography.caption.copyWith(
                          color: MealoraColors.danger,
                        ),
                      ),
                    ),
                  const SizedBox(height: MealoraSpacing.sm),
                ],
                const SizedBox(height: MealoraSpacing.lg),
                MealoraPrimaryButton(
                  label: text.nutritionReviewUseAction,
                  onPressed: _use,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NutrientRow extends StatelessWidget {
  const _NutrientRow({
    required this.nutrient,
    required this.reading,
    required this.controller,
    required this.offline,
    required this.text,
  });

  final ImportNutrient nutrient;
  final NutrientReading reading;
  final TextEditingController controller;
  final bool offline;
  final AppText text;

  @override
  Widget build(BuildContext context) {
    final (label, unit) = switch (nutrient) {
      ImportNutrient.energy => (text.nutrientEnergy, text.unitKilocalorie),
      ImportNutrient.protein => (text.nutrientProtein, text.unitGram),
      ImportNutrient.carbohydrate => (text.nutrientCarbohydrate, text.unitGram),
      ImportNutrient.fat => (text.nutrientFat, text.unitGram),
    };
    final source = reading.status == NutrientReadStatus.range
        ? ' · ${text.nutritionReviewSourceRange(formatRecipeNumber(reading.min!), formatRecipeNumber(reading.max!))}'
        : '';
    final (badge, fg, bg) = switch (reading.status) {
      NutrientReadStatus.unread => (
        text.nutritionReviewBadgeUnread,
        MealoraColors.coralText,
        MealoraColors.iconFieldCoral,
      ),
      _ when offline => (
        text.nutritionReviewBadgeCheck,
        MealoraColors.amberText,
        MealoraColors.iconFieldAmber,
      ),
      NutrientReadStatus.range => (
        text.nutritionReviewBadgeMidpoint,
        MealoraColors.amberText,
        MealoraColors.iconFieldAmber,
      ),
      NutrientReadStatus.read => (
        text.nutritionReviewBadgeRead,
        MealoraColors.primaryDeep,
        MealoraColors.iconFieldGreen,
      ),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: MealoraSpacing.sm),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text('$label$source', style: MealoraTypography.label),
                Semantics(
                  textField: true,
                  label: '$label. $badge',
                  child: TextField(
                    key: ValueKey('nutrition-review-${nutrient.name}'),
                    controller: controller,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    style: MealoraTypography.bodyEmphasis,
                    decoration: _plainDecoration('–').copyWith(
                      suffixText: unit,
                      suffixStyle: MealoraTypography.bodySmall,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: MealoraSpacing.sm),
          ExcludeSemantics(
            child: MealoraChip(label: badge, background: bg, foreground: fg),
          ),
        ],
      ),
    );
  }
}

InputDecoration _plainDecoration(String hint) => InputDecoration(
  hintText: hint,
  hintStyle: MealoraTypography.bodyMuted,
  isDense: true,
  filled: false,
  fillColor: MealoraColors.transparent,
  border: InputBorder.none,
  enabledBorder: InputBorder.none,
  focusedBorder: InputBorder.none,
  disabledBorder: InputBorder.none,
  errorBorder: InputBorder.none,
  focusedErrorBorder: InputBorder.none,
  contentPadding: EdgeInsets.zero,
);

String _capitalize(String s) =>
    s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
