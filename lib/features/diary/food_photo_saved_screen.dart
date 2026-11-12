import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/format/id_formatters.dart';
import 'package:mealora/domain/image_ai_access/image_ai_settings.dart';
import 'package:mealora/features/diary/food_photo_draft_storage.dart';
import 'package:mealora/features/reminders/late_meal_notice.dart';
import 'package:mealora/features/share/meal_share_card.dart';
import 'package:mealora/features/share/share_card_frame.dart';
import 'package:mealora/features/share/share_preview_screen.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// `57 · Tersimpan (jalur foto)` (change 014, task 3.1/3.2, Design D3).
///
/// Catatan makan SUDAH tersimpan sebelum layar ini terbuka; menutupnya tanpa
/// berbagi tidak mengubah catatan. Foto draf tetap ada selama layar ini
/// terbuka dan baru diperlakukan sesuai pengaturan retensi saat layar
/// ditutup — lewat Selesai, tombol kembali, atau `dispose`.
class FoodPhotoSavedScreen extends ConsumerStatefulWidget {
  const FoodPhotoSavedScreen({
    required this.meal,
    required this.date,
    super.key,
  });

  final MealShareData meal;

  /// Tanggal catatan — untuk peringatan jelang tidur (change 013).
  final LocalDate date;

  @override
  ConsumerState<FoodPhotoSavedScreen> createState() =>
      _FoodPhotoSavedScreenState();
}

class _FoodPhotoSavedScreenState extends ConsumerState<FoodPhotoSavedScreen> {
  bool _photoReleased = false;

  /// Dibaca di `initState` karena `ref` tidak boleh dipakai lagi di
  /// `dispose`.
  late final Future<ImageRetentionPreference> _retention;

  @override
  void initState() {
    super.initState();
    _retention = ref
        .read(imageRetentionPreferenceProvider.future)
        .catchError((Object _) => ImageRetentionPreference.defaultValue);
  }

  @override
  void dispose() {
    // Jalur terakhir bila layar ditutup tanpa Selesai/kembali. Bila aplikasi
    // dimatikan, pembersihan berkas yatim saat start yang menanganinya
    // (task 3.3).
    unawaited(_releasePhoto());
    super.dispose();
  }

  Future<void> _releasePhoto() async {
    if (_photoReleased) return;
    _photoReleased = true;
    final path = widget.meal.photoPath;
    if (path == null) return;
    final retention = await _retention;
    if (retention == ImageRetentionPreference.deleteAfterLogging) {
      await deleteDraftPhoto(path);
    }
  }

  void _showLateMealNotice() {
    final lateMealNotice = ref.read(lateMealNoticeProvider);
    final messenger = ScaffoldMessenger.of(context);
    final text = AppText.of(context);
    unawaited(
      lateMealNotice.maybeShow(
        messenger: messenger,
        text: text,
        date: widget.date,
      ),
    );
  }

  Future<void> _finish() async {
    _showLateMealNotice();
    final navigator = Navigator.of(context);
    await _releasePhoto();
    navigator.popUntil((route) => route.isFirst);
  }

  Future<void> _openPreview() async {
    final text = AppText.of(context);
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => SharePreviewScreen(
          card: MealShareCard(data: widget.meal),
          caption: text.shareMealPreviewCaption,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final meal = widget.meal;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        unawaited(_finish());
      },
      child: Scaffold(
        backgroundColor: MealoraColors.background,
        body: MealoraBlobBackdrop(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                MealoraSpacing.screenGutter,
                MealoraSpacing.xl,
                MealoraSpacing.screenGutter,
                MealoraSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Center(
                    child: Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topRight,
                          end: Alignment.bottomLeft,
                          colors: MealoraColors.heroGradient,
                          stops: MealoraColors.heroGradientStops,
                        ),
                        borderRadius: BorderRadius.circular(
                          MealoraRadius.sheet,
                        ),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                            color: MealoraColors.shadowHero,
                            offset: Offset(0, 12),
                            blurRadius: 28,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 40,
                        color: MealoraColors.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: MealoraSpacing.md),
                  Text(
                    text.foodPhotoSavedTitle,
                    textAlign: TextAlign.center,
                    style: MealoraTypography.title,
                  ),
                  const SizedBox(height: MealoraSpacing.xxs),
                  Text(
                    text.foodPhotoSavedSubtitle(
                      meal.mealTimeLabel,
                      meal.items.length,
                      IdFormat.integer(meal.totalKcal),
                    ),
                    textAlign: TextAlign.center,
                    style: MealoraTypography.subtitle,
                  ),
                  const SizedBox(height: MealoraSpacing.lg),
                  Expanded(
                    child: Center(
                      child: Semantics(
                        label: text.shareMealPreviewCaption,
                        child: ExcludeSemantics(
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                MealoraRadius.shareCard,
                              ),
                              boxShadow: const <BoxShadow>[
                                BoxShadow(
                                  color: MealoraColors.shadowShareCard,
                                  offset: Offset(0, 14),
                                  blurRadius: 32,
                                ),
                              ],
                            ),
                            child: FittedBox(
                              child: SizedBox(
                                width: ShareCardSize.width,
                                height: ShareCardSize.height,
                                child: MealShareCard(data: meal),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: MealoraSpacing.sm),
                  Text(
                    text.foodPhotoSavedThumbCaption,
                    textAlign: TextAlign.center,
                    style: MealoraTypography.caption,
                  ),
                  const SizedBox(height: MealoraSpacing.md),
                  MealoraPrimaryButton(
                    label: text.shareAction,
                    icon: Icons.ios_share,
                    onPressed: () => unawaited(_openPreview()),
                  ),
                  const SizedBox(height: MealoraSpacing.sm),
                  OutlinedButton(
                    onPressed: () => unawaited(_finish()),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(52),
                      backgroundColor: MealoraColors.glassSoft,
                      foregroundColor: MealoraColors.primary,
                      side: const BorderSide(
                        color: MealoraColors.secondaryButtonBorder,
                      ),
                      textStyle: MealoraTypography.button,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(MealoraRadius.chip),
                      ),
                    ),
                    child: Text(text.foodPhotoSavedDoneAction),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
