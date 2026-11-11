import 'dart:async' show unawaited;
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/domain/food_photo_input/photo_draft.dart';
import 'package:mealora/features/diary/food_component_correction_screen.dart';
import 'package:mealora/features/diary/food_photo_review_screen.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// `20 · Foto offline / AI gagal` (task 6.1-6.5, change 011): dibuka ketika
/// pengenalan tidak tersedia — luring, kuota habis, waktu tunggu lewat,
/// atau layanan menolak (spec, "Jalur tanpa pengenalan selalu tersedia").
/// Foto SUDAH tersimpan sebagai draf sejak sebelum pengiriman (Design D6);
/// layar ini hanya menyatakannya dan menawarkan jalur manual — SHALL TIDAK
/// pernah menjadi layar gagal buntu (task 6.4).
class FoodPhotoDraftScreen extends ConsumerWidget {
  const FoodPhotoDraftScreen({required this.draft, super.key});

  final PhotoDraft draft;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                MealoraBackEyebrow(label: text.foodPhotoDraftContextLabel),
                const SizedBox(height: MealoraSpacing.xs),
                Text(
                  text.foodPhotoDraftSavedTitle,
                  style: MealoraTypography.title,
                ),
                const SizedBox(height: MealoraSpacing.xxs),
                Text(
                  text.foodPhotoDraftSavedBody,
                  style: MealoraTypography.subtitle,
                ),
                if (draft.sourceImagePath != null) ...<Widget>[
                  const SizedBox(height: MealoraSpacing.lg),
                  MealoraCard(
                    radius: MealoraRadius.choiceCard,
                    padding: const EdgeInsets.all(MealoraSpacing.xxs),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        MealoraRadius.choiceCard - MealoraSpacing.xxs,
                      ),
                      child: Image.file(
                        File(draft.sourceImagePath!),
                        height: 160,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(height: MealoraSpacing.xs),
                  Text(
                    text.foodPhotoDraftBadge,
                    style: MealoraTypography.caption,
                  ),
                ],
                const SizedBox(height: MealoraSpacing.lg),
                MealoraNoteCard(
                  icon: Icons.cloud_off_outlined,
                  title: text.foodPhotoDraftUnavailableTitle,
                  body: text.foodPhotoDraftUnavailableBody,
                ),
                const SizedBox(height: MealoraSpacing.xl),
                Text(
                  text.foodPhotoDraftManualHeading,
                  style: MealoraTypography.sectionTitle,
                ),
                const SizedBox(height: MealoraSpacing.xxs),
                Text(
                  text.foodPhotoDraftManualDescription,
                  style: MealoraTypography.bodySmall,
                ),
                const SizedBox(height: MealoraSpacing.lg),
                MealoraPrimaryButton(
                  label: text.foodPhotoDraftManualAction,
                  icon: Icons.search,
                  onPressed: () => unawaited(_openManual(context)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openManual(BuildContext context) async {
    final updated = await Navigator.of(context).push<PhotoDraft>(
      MaterialPageRoute<PhotoDraft>(
        builder: (_) => FoodComponentCorrectionScreen(draft: draft),
      ),
    );
    if (updated == null || !context.mounted) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => FoodPhotoReviewScreen(draft: updated),
      ),
    );
  }
}
