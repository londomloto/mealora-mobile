import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/features/profile/widgets/settings_list_card.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';

final FutureProvider<PackageInfo> _packageInfoProvider =
    FutureProvider<PackageInfo>((ref) => PackageInfo.fromPlatform());

/// `66 · Tentang Mealora`.
///
/// Syarat & ketentuan, kebijakan privasi, dan masukan disembunyikan sampai
/// kontennya siap. Kebijakan privasi wajib ada sebelum rilis Play Store.
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = AppText.of(context);
    final info = ref.watch(_packageInfoProvider).valueOrNull;
    final year = ref.watch(clockProvider).today().year.toString();

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
                MealoraBackEyebrow(label: text.aboutContextLabel),
                const SizedBox(height: MealoraSpacing.xs),
                Text(text.aboutTitle, style: MealoraTypography.title),
                const SizedBox(height: MealoraSpacing.xxs),
                Text(text.aboutSubtitle, style: MealoraTypography.subtitle),
                const SizedBox(height: MealoraSpacing.lg),
                MealoraCard(
                  child: Row(
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(
                          MealoraRadius.iconField,
                        ),
                        child: Image.asset(
                          'assets/brand/mealora-app-icon-1024.png',
                          width: 60,
                          height: 60,
                          excludeFromSemantics: true,
                        ),
                      ),
                      const SizedBox(width: MealoraSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              text.aboutAppName,
                              style: MealoraTypography.headline,
                            ),
                            if (info != null) ...<Widget>[
                              const SizedBox(height: 2),
                              Text(
                                text.aboutVersion(
                                  info.version,
                                  info.buildNumber,
                                ),
                                style: MealoraTypography.caption,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: MealoraSpacing.md),
                SettingsListCard(
                  items: <SettingsListItem>[
                    SettingsListItem(
                      icon: Icons.code_rounded,
                      color: MealoraColors.info,
                      background: MealoraColors.iconFieldBlue,
                      label: text.aboutLicensesAction,
                      onTap: () => showLicensePage(
                        context: context,
                        applicationName: text.aboutAppName,
                        applicationVersion: info?.version,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: MealoraSpacing.md),
                MealoraNoteCard(
                  icon: Icons.volunteer_activism_outlined,
                  body: text.aboutDisclaimer,
                ),
                const SizedBox(height: MealoraSpacing.lg),
                Center(
                  child: Text(
                    text.aboutFooter(year),
                    textAlign: TextAlign.center,
                    style: MealoraTypography.caption,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
