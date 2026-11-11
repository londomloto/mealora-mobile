import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/features/diary/nutrition_label_photo_screen.dart';
import 'package:mealora/features/diary/packaged_food_manual_fill_screen.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// `22 · Barcode tidak ditemukan` (task 6.3-6.5, change 009; tautan foto
/// label disambungkan pada change 010, task 6): menampilkan barcode yang
/// terbaca, menyatakan produk belum ada, dan menawarkan sekurang-kurangnya
/// dua jalur lanjutan (spec, "Produk tidak ditemukan menawarkan jalur
/// lanjutan") — pengisian manual yang tersedia luring, dan foto label gizi
/// (`23 · Foto label gizi`, change 010).
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
                const _UnknownProductIllustration(),
                const SizedBox(height: MealoraSpacing.lg),
                Text(
                  text.packagedFoodNotFoundHeading,
                  textAlign: TextAlign.center,
                  style: MealoraTypography.headline,
                ),
                const SizedBox(height: MealoraSpacing.xs),
                Text(
                  text.packagedFoodNotFoundBody,
                  textAlign: TextAlign.center,
                  style: MealoraTypography.bodySmall,
                ),
                const SizedBox(height: MealoraSpacing.lg),
                _PathCard(
                  icon: Icons.camera_alt_outlined,
                  title: text.packagedFoodNotFoundPhotoTitle,
                  body: text.packagedFoodNotFoundPhotoDescription,
                  iconBackground: MealoraColors.iconFieldBlue,
                  iconForeground: MealoraColors.info,
                  onTap: () => _openLabelPhoto(context),
                  semanticsLabel:
                      '${text.packagedFoodNotFoundPhotoTitle}. '
                      '${text.packagedFoodNotFoundPhotoDescription}',
                ),
                const SizedBox(height: MealoraSpacing.sm),
                _PathCard(
                  icon: Icons.edit_outlined,
                  title: text.packagedFoodNotFoundManualTitle,
                  body: text.packagedFoodNotFoundManualDescription,
                  iconBackground: MealoraColors.iconFieldGreen,
                  iconForeground: MealoraColors.primary,
                  onTap: () => _openManualFill(context),
                  semanticsLabel:
                      '${text.packagedFoodNotFoundManualTitle}. '
                      '${text.packagedFoodNotFoundManualDescription}',
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

  void _openLabelPhoto(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => NutritionLabelPhotoScreen(barcode: barcode, date: date),
      ),
    );
  }
}

class _UnknownProductIllustration extends StatelessWidget {
  const _UnknownProductIllustration();

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(MealoraRadius.welcomeCard),
    child: BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
      child: Container(
        width: double.infinity,
        height: 170,
        decoration: BoxDecoration(
          color: MealoraColors.glassSoft,
          borderRadius: BorderRadius.circular(MealoraRadius.welcomeCard),
          border: Border.all(color: MealoraColors.glassBorder),
        ),
        alignment: Alignment.center,
        child: Container(
          width: 68,
          height: 68,
          decoration: BoxDecoration(
            color: MealoraColors.softGreen,
            borderRadius: BorderRadius.circular(MealoraRadius.chip),
          ),
          child: const Icon(
            Icons.qr_code_scanner_rounded,
            color: MealoraColors.primary,
            size: MealoraIconSize.alert,
          ),
        ),
      ),
    ),
  );
}

class _PathCard extends StatelessWidget {
  const _PathCard({
    required this.icon,
    required this.title,
    required this.body,
    required this.iconBackground,
    required this.iconForeground,
    required this.onTap,
    required this.semanticsLabel,
  });

  final IconData icon;
  final String title;
  final String body;
  final Color iconBackground;
  final Color iconForeground;
  final VoidCallback onTap;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: semanticsLabel,
    child: DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(MealoraRadius.card),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: MealoraColors.shadowGlass,
            offset: Offset(0, 14),
            blurRadius: 34,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(MealoraRadius.card),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Material(
            color: MealoraColors.glassCard,
            child: InkWell(
              onTap: onTap,
              child: Container(
                height: 84,
                padding: const EdgeInsets.symmetric(
                  horizontal: MealoraSpacing.md,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: MealoraColors.glassBorder),
                  borderRadius: BorderRadius.circular(MealoraRadius.card),
                ),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: iconBackground,
                        borderRadius: BorderRadius.circular(
                          MealoraRadius.choiceIcon,
                        ),
                      ),
                      child: Icon(icon, color: iconForeground),
                    ),
                    const SizedBox(width: MealoraSpacing.sm),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(title, style: MealoraTypography.bodyEmphasis),
                          const SizedBox(height: MealoraSpacing.xxs),
                          Text(body, style: MealoraTypography.caption),
                        ],
                      ),
                    ),
                    const SizedBox(width: MealoraSpacing.xs),
                    const Icon(
                      Icons.chevron_right,
                      color: MealoraColors.affordance,
                      size: MealoraIconSize.action,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
