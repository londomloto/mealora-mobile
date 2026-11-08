import 'package:flutter/material.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// Splash bermerek Mealora.
///
/// Mengikuti `06 · Splash Mealora` di `docs/mealora.pen`: simbol di atas
/// kartu putih, wordmark, tagline, indikator muat, dan janji penyimpanan
/// lokal. Tidak ada interaksi yang dibutuhkan — perpindahan ke ruang utama
/// terjadi sendiri begitu penyimpanan lokal siap.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);

    return Scaffold(
      backgroundColor: MealoraColors.background,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(MealoraSpacing.screenGutter),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Spacer(),
              _SymbolTile(semanticsLabel: text.splashLogoSemantics),
              const SizedBox(height: MealoraSpacing.xxl),
              Text(
                text.appName.toLowerCase(),
                style: MealoraTypography.wordmark,
              ),
              const SizedBox(height: MealoraSpacing.xs),
              Text(
                text.appTagline,
                textAlign: TextAlign.center,
                style: MealoraTypography.bodySmall,
              ),
              const Spacer(),
              Semantics(
                label: text.splashLoadingSemantics,
                liveRegion: true,
                child: const SizedBox(
                  width: 94,
                  height: 5,
                  child: _LoadingTrack(),
                ),
              ),
              const SizedBox(height: MealoraSpacing.xl),
              Text(
                text.splashPrivacyPromise,
                textAlign: TextAlign.center,
                style: MealoraTypography.caption,
              ),
              const SizedBox(height: MealoraSpacing.lg),
            ],
          ),
        ),
      ),
    );
  }
}

class _SymbolTile extends StatelessWidget {
  const _SymbolTile({required this.semanticsLabel});

  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: semanticsLabel,
      child: Container(
        width: 172,
        height: 172,
        decoration: BoxDecoration(
          color: MealoraColors.surface,
          borderRadius: BorderRadius.circular(MealoraRadius.splashTile),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: MealoraColors.shadow.withValues(alpha: 0.12),
              offset: const Offset(0, 16),
              blurRadius: 34,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(
            MealoraSpacing.xl + MealoraSpacing.xxs / 2,
          ),
          child: Image.asset(
            'assets/brand/mealora-symbol.png',
            fit: BoxFit.contain,
            excludeFromSemantics: true,
          ),
        ),
      ),
    );
  }
}

class _LoadingTrack extends StatelessWidget {
  const _LoadingTrack();

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(MealoraRadius.track),
      child: const LinearProgressIndicator(
        backgroundColor: MealoraColors.track,
        color: MealoraColors.primary,
        minHeight: 5,
      ),
    );
  }
}
