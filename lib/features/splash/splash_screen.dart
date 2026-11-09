import 'package:flutter/material.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// Splash bermerek Mealora.
///
/// Mengikuti `06 · Splash Mealora` di `docs/mealora-v2.pen`: gradien hijau
/// penuh layar dengan blob dekoratif, simbol aplikasi mengambang langsung di
/// atas gradien (bukan kartu putih), wordmark, tagline, indikator muat, dan
/// janji penyimpanan lokal. Tidak ada interaksi yang dibutuhkan —
/// perpindahan ke ruang utama terjadi sendiri begitu penyimpanan lokal siap.
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);

    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment(0.34, -0.94),
            end: Alignment(-0.34, 0.94),
            colors: MealoraColors.heroGradient,
            stops: MealoraColors.heroGradientStops,
          ),
        ),
        child: Stack(
          children: <Widget>[
            const Positioned(
              left: 200,
              top: -60,
              child: MealoraBlurBlob(
                color: MealoraColors.lime,
                opacity: 0.35,
                size: 320,
              ),
            ),
            const Positioned(
              left: -120,
              top: 520,
              child: MealoraBlurBlob(
                color: MealoraColors.mint,
                opacity: 0.4,
                size: 320,
              ),
            ),
            const Positioned(
              left: 120,
              top: 300,
              child: MealoraBlurBlob(
                color: MealoraColors.accent,
                opacity: 0.18,
                width: 240,
                height: 220,
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Stack(
                    children: <Widget>[
                      Positioned(
                        top: constraints.maxHeight * (296 / 844),
                        left: MealoraSpacing.screenGutter,
                        right: MealoraSpacing.screenGutter,
                        child: Column(
                          children: <Widget>[
                            _SymbolTile(
                              semanticsLabel: text.splashLogoSemantics,
                            ),
                            const SizedBox(height: 24),
                            Text(
                              text.appName.toLowerCase(),
                              style: MealoraTypography.wordmark,
                            ),
                            const SizedBox(height: MealoraSpacing.xxs),
                            Text(
                              text.appTagline,
                              textAlign: TextAlign.center,
                              style: MealoraTypography.body.copyWith(
                                color: MealoraColors.onPrimaryMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Positioned(
                        left: MealoraSpacing.screenGutter,
                        right: MealoraSpacing.screenGutter,
                        bottom: constraints.maxHeight * (49 / 844),
                        child: Text(
                          text.splashPrivacyPromise,
                          textAlign: TextAlign.center,
                          style: MealoraTypography.caption.copyWith(
                            color: MealoraColors.onPrimaryFaint,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
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
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(MealoraRadius.splashTile),
          boxShadow: const <BoxShadow>[
            BoxShadow(
              color: MealoraColors.shadowWelcomeButton,
              offset: Offset(0, 18),
              blurRadius: 40,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(MealoraRadius.splashTile),
          child: Image.asset(
            'assets/brand/mealora-app-icon-1024.png',
            fit: BoxFit.contain,
            excludeFromSemantics: true,
          ),
        ),
      ),
    );
  }
}
