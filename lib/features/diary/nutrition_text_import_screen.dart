import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show Clipboard;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/domain/image_ai_access/label_service_failure.dart';
import 'package:mealora/domain/nutrition_import/nutrition_import.dart';
import 'package:mealora/features/diary/label_extraction_failure_text.dart';
import 'package:mealora/features/diary/nutrition_import_review_screen.dart';
import 'package:mealora/features/diary/nutrition_label_photo_screen.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// `83 · Tempel info gizi` dan `85 · gizi tidak ditemukan` (change 020,
/// design D5). Teks dari clipboard bisa disunting, lalu dibaca lewat
/// proksi. Hasil tinjau dikembalikan ke form Buat makanan lewat
/// `Navigator.pop` sebagai [NutritionImportResult]; `null` berarti pengguna
/// memilih isi manual atau kembali.
class NutritionTextImportScreen extends ConsumerStatefulWidget {
  const NutritionTextImportScreen({this.readClipboard, super.key});

  /// Pengganti pembacaan clipboard untuk pengujian; `null` (bawaan) memakai
  /// clipboard sistem.
  final Future<String?> Function()? readClipboard;

  @override
  ConsumerState<NutritionTextImportScreen> createState() =>
      _NutritionTextImportScreenState();
}

enum _Problem { none, noNumbers, emptyClipboard, service }

class _NutritionTextImportScreenState
    extends ConsumerState<NutritionTextImportScreen> {
  final _text = TextEditingController();
  bool _reading = false;
  _Problem _problem = _Problem.none;
  LabelServiceFailureReason? _failure;

  @override
  void initState() {
    super.initState();
    _text.addListener(() => setState(() {}));
    unawaited(_paste(initial: true));
  }

  @override
  void dispose() {
    _text.dispose();
    super.dispose();
  }

  Future<void> _paste({bool initial = false}) async {
    final String? clip;
    try {
      clip = widget.readClipboard != null
          ? await widget.readClipboard!()
          : (await Clipboard.getData(Clipboard.kTextPlain))?.text;
    } on Object {
      return;
    }
    if (!mounted) return;
    final value = clip?.trim() ?? '';
    setState(() {
      if (value.isEmpty) {
        if (!initial) _problem = _Problem.emptyClipboard;
        return;
      }
      _text.text = value;
      _problem = _Problem.none;
    });
  }

  Future<void> _openPhoto() async {
    final result = await Navigator.of(context).push<NutritionImportResult>(
      MaterialPageRoute<NutritionImportResult>(
        builder: (_) => const NutritionLabelPhotoScreen(returnToForm: true),
      ),
    );
    if (result != null && mounted) {
      Navigator.of(context).pop(result);
    }
  }

  Future<void> _read() async {
    setState(() {
      _reading = true;
      _problem = _Problem.none;
    });
    final outcome = await ref
        .read(nutritionTextReaderProvider)
        .readText(_text.text);
    if (!mounted) return;
    setState(() => _reading = false);

    switch (outcome) {
      case NutritionReadSuccess(:final reading, :final tier)
          when reading.hasAnyNutrient:
        final result = await Navigator.of(context).push<NutritionImportResult>(
          MaterialPageRoute<NutritionImportResult>(
            builder: (_) =>
                NutritionImportReviewScreen(reading: reading, tier: tier),
          ),
        );
        if (result != null && mounted) {
          Navigator.of(context).pop(result);
        }
      case NutritionReadSuccess() || NutritionReadNoText():
        setState(() => _problem = _Problem.noNumbers);
      case NutritionReadUnavailable(:final reason):
        setState(() {
          _problem = _Problem.service;
          _failure = reason;
        });
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final length = _text.text.trim().length;
    final tooLong = length > maxNutritionTextChars;
    final canRead = !_reading && length > 0 && !tooLong;
    final hasError = _problem == _Problem.noNumbers || tooLong;

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
                MealoraBackEyebrow(label: text.nutritionPasteContextLabel),
                const SizedBox(height: MealoraSpacing.xs),
                Text(text.nutritionPasteTitle, style: MealoraTypography.title),
                const SizedBox(height: MealoraSpacing.xxs),
                Text(
                  text.nutritionPasteSubtitle,
                  style: MealoraTypography.subtitle,
                ),
                const SizedBox(height: MealoraSpacing.lg),
                DecoratedBox(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: hasError
                          ? MealoraColors.coralText
                          : MealoraColors.primary,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(MealoraRadius.card),
                  ),
                  child: MealoraCard(
                    padding: const EdgeInsets.fromLTRB(
                      MealoraSpacing.md,
                      MealoraSpacing.sm,
                      MealoraSpacing.xs,
                      MealoraSpacing.sm,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                text.nutritionPasteFieldLabel(
                                  length,
                                  maxNutritionTextChars,
                                ),
                                style: MealoraTypography.eyebrow,
                              ),
                            ),
                            if (_text.text.isNotEmpty)
                              IconButton(
                                tooltip: text.nutritionPasteClearAction,
                                onPressed: _text.clear,
                                icon: const Icon(Icons.close),
                              ),
                          ],
                        ),
                        TextField(
                          key: const ValueKey('nutrition-paste-text'),
                          controller: _text,
                          minLines: 5,
                          maxLines: 10,
                          style: MealoraTypography.bodySmall,
                          decoration: InputDecoration(
                            hintText: text.nutritionPasteFieldHint,
                            hintStyle: MealoraTypography.bodyMuted,
                            isDense: true,
                            filled: false,
                            fillColor: MealoraColors.transparent,
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                        const SizedBox(height: MealoraSpacing.xxs),
                        Text(
                          tooLong
                              ? text.nutritionPasteTooLong(
                                  maxNutritionTextChars,
                                )
                              : text.nutritionPasteIgnoredHint,
                          style: MealoraTypography.caption.copyWith(
                            color: tooLong ? MealoraColors.danger : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: MealoraSpacing.md),
                ..._notes(text),
                const SizedBox(height: MealoraSpacing.md),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: MealoraGlassButton(
                        key: const ValueKey('nutrition-paste-repaste'),
                        onPressed: _reading ? null : () => unawaited(_paste()),
                        icon: Icons.content_paste_outlined,
                        label: text.nutritionPasteRepasteAction,
                      ),
                    ),
                    const SizedBox(width: MealoraSpacing.sm),
                    Expanded(
                      child: MealoraGlassButton(
                        key: const ValueKey('nutrition-paste-photo'),
                        onPressed: _reading
                            ? null
                            : () => unawaited(_openPhoto()),
                        icon: Icons.photo_camera_outlined,
                        label: text.nutritionPastePhotoAction,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: MealoraSpacing.sm),
                Center(
                  child: TextButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.edit_outlined,
                      size: MealoraIconSize.inline,
                      color: MealoraColors.primaryDeep,
                    ),
                    label: Text(
                      text.nutritionPasteManualLink,
                      style: MealoraTypography.bodyEmphasis.copyWith(
                        color: MealoraColors.primaryDeep,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: MealoraSpacing.md),
                if (_reading)
                  const Center(child: CircularProgressIndicator())
                else
                  MealoraPrimaryButton(
                    label: text.nutritionPasteReadAction,
                    icon: Icons.auto_awesome_outlined,
                    onPressed: canRead ? () => unawaited(_read()) : null,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _notes(AppText text) {
    switch (_problem) {
      case _Problem.noNumbers:
        return <Widget>[
          Semantics(
            liveRegion: true,
            child: MealoraNoteCard(
              icon: Icons.error_outline,
              title: text.nutritionPasteNoNumbersTitle,
              body: text.nutritionPasteNoNumbersBody,
              foreground: MealoraColors.coralText,
              background: MealoraColors.iconFieldCoral,
              borderColor: MealoraColors.coralText,
            ),
          ),
        ];
      case _Problem.emptyClipboard:
        return <Widget>[
          Semantics(
            liveRegion: true,
            child: MealoraNoteCard(
              icon: Icons.content_paste_off_outlined,
              body: text.nutritionPasteEmptyClipboard,
              borderColor: MealoraColors.amberText,
            ),
          ),
        ];
      case _Problem.service:
        final reason = _failure;
        return <Widget>[
          Semantics(
            liveRegion: true,
            child: MealoraNoteCard(
              icon: Icons.cloud_off_outlined,
              title: text.labelExtractionUnavailableTitle,
              body: reason == null
                  ? text.nutritionPasteOnlineBody
                  : labelExtractionFailureHeadline(text, reason),
              borderColor: MealoraColors.amberText,
            ),
          ),
        ];
      case _Problem.none:
        return <Widget>[
          MealoraNoteCard(
            icon: Icons.verified_user_outlined,
            body: text.nutritionPastePrivacyBody,
            borderColor: MealoraColors.glassSoft,
          ),
        ];
    }
  }
}
