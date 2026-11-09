import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/features/onboarding/onboarding_controller.dart';
import 'package:mealora/features/onboarding/onboarding_step.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// `07 · Selamat datang` — layar pertama yang dilihat pengguna, menyatakan
/// sejak awal bahwa Mealora bekerja tanpa akun, bisa dipakai offline, dan
/// menyimpan data di perangkat (task 4.1, program-onboarding spec,
/// "Onboarding berjalan tanpa akun dan tanpa koneksi").
///
/// Mengikuti `07 · Selamat datang` di `docs/mealora-v2.pen`: gradien hero
/// penuh layar, ubin ikon kaca, dan kartu kaca berisi tiga janji singkat.
/// Tidak menampilkan indikator langkah — rancangan hanya menomori langkah
/// mulai dari profil (`08`).
class OnboardingWelcomeScreen extends ConsumerWidget {
  const OnboardingWelcomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                opacity: 0.34,
                size: 320,
              ),
            ),
            const Positioned(
              left: 120,
              top: 300,
              child: MealoraBlurBlob(
                color: MealoraColors.accent,
                opacity: 0.22,
                width: 240,
                height: 220,
              ),
            ),
            SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      MealoraSpacing.screenGutter,
                      MealoraSpacing.xxl,
                      MealoraSpacing.screenGutter,
                      MealoraSpacing.lg,
                    ),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight:
                            constraints.maxHeight -
                            MealoraSpacing.xxl -
                            MealoraSpacing.lg,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Semantics(
                                image: true,
                                label: text.onboardingWelcomeHeroSemantics,
                                child: Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: MealoraColors.glassOnHero,
                                    borderRadius: BorderRadius.circular(
                                      MealoraRadius.iconField,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.restaurant_outlined,
                                    color: MealoraColors.onPrimary,
                                    size: MealoraIconSize.raisedAction,
                                  ),
                                ),
                              ),
                              const SizedBox(height: MealoraSpacing.lg),
                              Text(
                                text.onboardingWelcomeEyebrow,
                                style: MealoraTypography.eyebrow.copyWith(
                                  color: MealoraColors.onPrimaryMuted,
                                ),
                              ),
                              const SizedBox(height: MealoraSpacing.xs),
                              Text(
                                text.onboardingWelcomeHeading,
                                style: MealoraTypography.display.copyWith(
                                  color: MealoraColors.onPrimary,
                                ),
                              ),
                              const SizedBox(height: MealoraSpacing.sm),
                              Text(
                                text.onboardingWelcomeDescription,
                                style: MealoraTypography.body.copyWith(
                                  color: MealoraColors.onPrimaryMuted,
                                ),
                              ),
                            ],
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Container(
                                padding: const EdgeInsets.all(
                                  MealoraSpacing.lg,
                                ),
                                decoration: BoxDecoration(
                                  color: MealoraColors.glassOnHero,
                                  borderRadius: BorderRadius.circular(
                                    MealoraRadius.cardLarge,
                                  ),
                                ),
                                child: Column(
                                  children: <Widget>[
                                    _HeroPromiseRow(
                                      icon: Icons.edit_note_outlined,
                                      title:
                                          text.onboardingWelcomePromiseLogTitle,
                                      detail: text
                                          .onboardingWelcomePromiseLogDetail,
                                    ),
                                    const SizedBox(height: MealoraSpacing.sm),
                                    _HeroPromiseRow(
                                      icon: Icons.track_changes_outlined,
                                      title: text
                                          .onboardingWelcomePromiseFairTitle,
                                      detail: text
                                          .onboardingWelcomePromiseFairDetail,
                                    ),
                                    const SizedBox(height: MealoraSpacing.sm),
                                    _HeroPromiseRow(
                                      icon: Icons.shield_outlined,
                                      title: text
                                          .onboardingWelcomePromisePrivacyTitle,
                                      detail: text
                                          .onboardingWelcomePromisePrivacyDetail,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: MealoraSpacing.lg),
                              _HeroWhiteButton(
                                label: text.onboardingWelcomeAction,
                                onPressed: () => ref
                                    .read(onboardingControllerProvider.notifier)
                                    .goToStep(OnboardingStep.profileBasics),
                              ),
                              const SizedBox(height: MealoraSpacing.sm),
                              Text(
                                text.onboardingWelcomePrivacy,
                                textAlign: TextAlign.center,
                                style: MealoraTypography.caption.copyWith(
                                  color: MealoraColors.onPrimaryFaint,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
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

class _HeroPromiseRow extends StatelessWidget {
  const _HeroPromiseRow({
    required this.icon,
    required this.title,
    required this.detail,
  });

  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: MealoraColors.glassOnHeroStrong,
            borderRadius: BorderRadius.circular(MealoraRadius.iconField),
          ),
          child: Icon(icon, color: MealoraColors.onPrimary, size: 18),
        ),
        const SizedBox(width: MealoraSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                title,
                style: MealoraTypography.chipLabel.copyWith(
                  color: MealoraColors.onPrimary,
                ),
              ),
              Text(
                detail,
                style: MealoraTypography.caption.copyWith(
                  color: MealoraColors.onPrimaryMuted,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Tombol primer putih di atas gradien hero — "Primary button" di
/// `07 · Selamat datang`, satu-satunya layar yang memakai varian ini (tombol
/// gradien standar akan hilang di atas latar yang sama-sama hijau).
class _HeroWhiteButton extends StatelessWidget {
  const _HeroWhiteButton({required this.label, required this.onPressed});

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: MealoraColors.surface,
        foregroundColor: MealoraColors.primary,
        textStyle: MealoraTypography.button,
        minimumSize: const Size.fromHeight(58),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MealoraRadius.button),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: MealoraColors.primary),
            ),
          ),
          const SizedBox(width: MealoraSpacing.xs),
          const Icon(
            Icons.arrow_forward,
            size: MealoraIconSize.action,
            color: MealoraColors.primary,
          ),
        ],
      ),
    );
  }
}
