import 'package:flutter/material.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/features/diary/packaged_food_manual_fill_screen.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// `22 · Barcode tidak ditemukan` (task 6.3-6.5, change 009): menampilkan
/// barcode yang terbaca, menyatakan produk belum ada, dan menawarkan
/// sekurang-kurangnya dua jalur lanjutan (spec, "Produk tidak ditemukan
/// menawarkan jalur lanjutan") — pengisian manual yang tersedia luring, dan
/// foto label gizi yang ditandai belum tersedia dan SHALL TIDAK dapat
/// dibuka (non-goal change ini; change terpisah menyusul).
///
/// Pengguna luring yang memindai produk tak dikenal diarahkan ke sini,
/// bukan jalan buntu (spec, "Produk tidak tersimpan dan perangkat luring").
class PackagedFoodNotFoundScreen extends StatelessWidget {
  const PackagedFoodNotFoundScreen({
    required this.barcode,
    this.date,
    super.key,
  });

  final String barcode;
  final LocalDate? date;

  @override
  Widget build(BuildContext context) {
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
                MealoraBackEyebrow(
                  label: text.packagedFoodNotFoundContextLabel,
                ),
                const SizedBox(height: MealoraSpacing.xs),
                Text(
                  text.packagedFoodNotFoundTitle,
                  style: MealoraTypography.title,
                ),
                const SizedBox(height: MealoraSpacing.xxs),
                Text(
                  text.packagedFoodNotFoundSubtitle(barcode),
                  style: MealoraTypography.subtitle,
                ),
                const SizedBox(height: MealoraSpacing.lg),
                MealoraEmptyState(
                  icon: Icons.qr_code_scanner_rounded,
                  title: text.packagedFoodNotFoundHeading,
                  body: text.packagedFoodNotFoundBody,
                ),
                const SizedBox(height: MealoraSpacing.lg),
                MealoraNoteCard(
                  icon: Icons.edit_outlined,
                  title: text.packagedFoodNotFoundManualTitle,
                  body: text.packagedFoodNotFoundManualDescription,
                  background: MealoraColors.iconFieldGreen,
                  foreground: MealoraColors.primary,
                  onTap: () => _openManualFill(context),
                  semanticsLabel:
                      '${text.packagedFoodNotFoundManualTitle}. '
                      '${text.packagedFoodNotFoundManualDescription}',
                ),
                const SizedBox(height: MealoraSpacing.sm),
                MealoraNoteCard(
                  icon: Icons.camera_alt_outlined,
                  title: text.packagedFoodNotFoundPhotoTitle,
                  body: text.packagedFoodNotFoundPhotoDescription,
                  background: MealoraColors.iconFieldBlue,
                  foreground: MealoraColors.info,
                  onTap: () => _announceUnavailable(context, text),
                  semanticsLabel:
                      '${text.packagedFoodNotFoundPhotoTitle}. '
                      '${text.packagedFoodNotFoundPhotoDescription}',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _openManualFill(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) =>
            PackagedFoodManualFillScreen(barcode: barcode, date: date),
      ),
    );
  }

  void _announceUnavailable(BuildContext context, AppText text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text.packagedFoodPathUnavailable),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}
