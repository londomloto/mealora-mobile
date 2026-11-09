import 'package:flutter/material.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';

/// Kerangka bersama seluruh layar onboarding (`07`–`11`, `25` di
/// `docs/mealora.pen`): label konteks (langkah atau program), judul,
/// subjudul, isi yang dapat digulir, dan tombol utama yang menempel di
/// bawah.
///
/// [onBack] tidak digambar di rancangan visual (status bar saja pada setiap
/// mock), tetapi task 3.4 mewajibkan navigasi mundur tanpa kehilangan
/// isian — disediakan sebagai tombol panah eksplisit, bukan hanya gestur
/// sistem, supaya tetap terjangkau pembaca layar dan perangkat tanpa
/// gestur kembali.
class OnboardingScaffold extends StatelessWidget {
  const OnboardingScaffold({
    required this.contextLabel,
    required this.title,
    required this.subtitle,
    required this.children,
    required this.primaryActionLabel,
    required this.onPrimaryAction,
    this.onBack,
    this.backSemanticsLabel,
    super.key,
  });

  final String contextLabel;
  final String title;
  final String subtitle;
  final List<Widget> children;
  final String primaryActionLabel;
  final VoidCallback? onPrimaryAction;
  final VoidCallback? onBack;
  final String? backSemanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: MealoraColors.background,
      body: MealoraBlobBackdrop(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(
                    MealoraSpacing.screenGutter,
                    MealoraSpacing.md,
                    MealoraSpacing.screenGutter,
                    MealoraSpacing.xl,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          if (onBack != null)
                            Padding(
                              padding: const EdgeInsets.only(
                                right: MealoraSpacing.xs,
                              ),
                              child: Semantics(
                                button: true,
                                label: backSemanticsLabel,
                                child: InkWell(
                                  onTap: onBack,
                                  borderRadius: BorderRadius.circular(
                                    MealoraRadius.pill,
                                  ),
                                  child: const Padding(
                                    padding: EdgeInsets.all(
                                      MealoraSpacing.xxs,
                                    ),
                                    child: Icon(
                                      Icons.arrow_back,
                                      color: MealoraColors.ink,
                                      size: MealoraIconSize.action,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          Expanded(
                            child: Text(
                              contextLabel,
                              style: MealoraTypography.eyebrow,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: MealoraSpacing.xs),
                      Text(title, style: MealoraTypography.title),
                      const SizedBox(height: MealoraSpacing.xs),
                      Text(subtitle, style: MealoraTypography.subtitle),
                      const SizedBox(height: MealoraSpacing.xl),
                      ...children,
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  MealoraSpacing.screenGutter,
                  0,
                  MealoraSpacing.screenGutter,
                  MealoraSpacing.lg,
                ),
                child: MealoraPrimaryButton(
                  label: primaryActionLabel,
                  icon: Icons.arrow_forward,
                  onPressed: onPrimaryAction,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
