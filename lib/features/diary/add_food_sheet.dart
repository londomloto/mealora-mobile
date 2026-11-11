import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/features/diary/barcode_scan_screen.dart';
import 'package:mealora/features/diary/food_search_screen.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// `02 · Tambah makanan` — pintu masuk pencatatan (task 8.3/8.4).
///
/// Jalur pencarian/input manual dan barcode (change 009) selalu tersedia
/// luring untuk produk tersimpan. Jalur suara dan foto ditandai belum
/// tersedia dan SHALL TIDAK membuka layar yang gagal (spec daily-dashboard,
/// "Jalur yang belum tersedia") — jalur suara menyusul pada change 012,
/// foto pada change terpisah.
Future<void> showAddFoodSheet(BuildContext context, {LocalDate? date}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: false,
    barrierColor: MealoraColors.transparent,
    transitionDuration: const Duration(milliseconds: 260),
    pageBuilder: (context, animation, secondaryAnimation) =>
        _AddFoodOverlay(animation: animation, date: date),
  );
}

class _AddFoodOverlay extends StatelessWidget {
  const _AddFoodOverlay({required this.animation, this.date});

  final Animation<double> animation;

  /// Tanggal yang akan dicatat — `null` berarti hari ini (konvensi
  /// `logFoodEntry`, change 008 task 5.6).
  final LocalDate? date;

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: <Widget>[
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => Navigator.of(context).pop(),
              child: FadeTransition(
                opacity: curved,
                child: BackdropFilter(
                  // Sedikit lebih ringan dari pemetaan langsung radius Pen.
                  filter: ImageFilter.blur(sigmaX: 4.5, sigmaY: 4.5),
                  child: const ColoredBox(color: MealoraColors.modalScrim),
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1),
                end: Offset.zero,
              ).animate(curved),
              child: _AddFoodSheet(date: date),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddFoodSheet extends StatelessWidget {
  const _AddFoodSheet({this.date});

  final LocalDate? date;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    const radius = BorderRadius.only(
      topLeft: Radius.circular(34),
      topRight: Radius.circular(34),
    );
    return DecoratedBox(
      decoration: const BoxDecoration(
        borderRadius: radius,
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: MealoraColors.shadowSheet,
            offset: Offset(0, -10),
            blurRadius: 40,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              color: MealoraColors.sheetSurface,
              borderRadius: radius,
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 22),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Center(
                      child: Container(
                        width: 48,
                        height: 5,
                        decoration: BoxDecoration(
                          color: MealoraColors.selectionIdle,
                          borderRadius: BorderRadius.circular(
                            MealoraRadius.sheetHandle,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: MealoraSpacing.lg),
                    Text(
                      text.addFoodSheetTitle,
                      style: MealoraTypography.headline,
                    ),
                    const SizedBox(height: MealoraSpacing.xxs),
                    Text(
                      text.addFoodSheetSubtitle,
                      style: MealoraTypography.bodySmall,
                    ),
                    const SizedBox(height: MealoraSpacing.lg),
                    _AddFoodRow(
                      icon: Icons.search,
                      iconBackground: MealoraColors.iconFieldAmber,
                      iconForeground: MealoraColors.accent,
                      title: text.addFoodSearchTitle,
                      description: text.addFoodSearchDescription,
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => FoodSearchScreen(date: date),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: MealoraSpacing.sm),
                    _AddFoodRow(
                      icon: Icons.mic_none_rounded,
                      iconBackground: MealoraColors.iconFieldBlue,
                      iconForeground: MealoraColors.info,
                      title: text.addFoodVoiceTitle,
                      description: text.addFoodVoiceDescription,
                      onTap: () => _announceUnavailable(context, text),
                    ),
                    const SizedBox(height: MealoraSpacing.sm),
                    _AddFoodRow(
                      icon: Icons.camera_alt_outlined,
                      iconBackground: MealoraColors.iconFieldGreen,
                      iconForeground: MealoraColors.primaryBright,
                      title: text.addFoodPhotoTitle,
                      description: text.addFoodPhotoDescription,
                      onTap: () => _announceUnavailable(context, text),
                    ),
                    const SizedBox(height: MealoraSpacing.sm),
                    _AddFoodRow(
                      icon: Icons.qr_code_scanner_rounded,
                      iconBackground: MealoraColors.iconFieldCoral,
                      iconForeground: MealoraColors.peach,
                      title: text.addFoodBarcodeTitle,
                      description: text.addFoodBarcodeDescription,
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => BarcodeScanScreen(date: date),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: MealoraSpacing.lg),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(MealoraSpacing.md),
                      decoration: BoxDecoration(
                        color: MealoraColors.noteSuccess,
                        borderRadius: BorderRadius.circular(MealoraRadius.chip),
                        border: Border.all(color: MealoraColors.glassSoft),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          const Icon(
                            Icons.shield_outlined,
                            color: MealoraColors.primary,
                            size: MealoraIconSize.alert,
                          ),
                          const SizedBox(width: MealoraSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Text(
                                  text.addFoodPrivacyLine1,
                                  style: MealoraTypography.bodyEmphasis,
                                ),
                                const SizedBox(height: MealoraSpacing.xxs),
                                Text(
                                  text.addFoodPrivacyLine2,
                                  style: MealoraTypography.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _announceUnavailable(BuildContext context, AppText text) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(text.addFoodPathUnavailable),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}

class _AddFoodRow extends StatelessWidget {
  const _AddFoodRow({
    required this.icon,
    required this.iconBackground,
    required this.iconForeground,
    required this.title,
    required this.description,
    required this.onTap,
  });

  final IconData icon;
  final Color iconBackground;
  final Color iconForeground;
  final String title;
  final String description;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$title. $description',
      child: InkWell(
        borderRadius: BorderRadius.circular(MealoraRadius.choiceCard),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          height: 76,
          padding: const EdgeInsets.symmetric(horizontal: MealoraSpacing.md),
          decoration: BoxDecoration(
            color: MealoraColors.sheetOptionSurface,
            borderRadius: BorderRadius.circular(MealoraRadius.choiceCard),
            border: Border.all(color: MealoraColors.surface),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: MealoraColors.shadowSheetOption,
                offset: Offset(0, 8),
                blurRadius: 20,
              ),
            ],
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 50,
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(
                    MealoraRadius.welcomeCard,
                  ),
                ),
                child: Icon(
                  icon,
                  color: iconForeground,
                  size: MealoraIconSize.alert,
                ),
              ),
              const SizedBox(width: MealoraSpacing.md),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: MealoraTypography.compactSectionTitle,
                    ),
                    const SizedBox(height: MealoraSpacing.xxs),
                    Text(
                      description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: MealoraTypography.caption,
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: MealoraColors.affordance,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
