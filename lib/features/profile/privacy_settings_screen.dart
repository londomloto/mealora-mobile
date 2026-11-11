import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/domain/image_ai_access/image_ai_settings.dart';
import 'package:mealora/features/onboarding/widgets/onboarding_choice_card.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

class PrivacySettingsScreen extends ConsumerWidget {
  const PrivacySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = AppText.of(context);
    final consent = ref.watch(imageUploadConsentPreferenceProvider);
    final retention = ref.watch(imageRetentionPreferenceProvider);
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
                MealoraBackEyebrow(label: text.privacySettingsContextLabel),
                const SizedBox(height: MealoraSpacing.xs),
                Text(text.privacySettingsTitle, style: MealoraTypography.title),
                const SizedBox(height: MealoraSpacing.xxs),
                Text(
                  text.privacySettingsSubtitle,
                  style: MealoraTypography.subtitle,
                ),
                const SizedBox(height: MealoraSpacing.lg),
                Text(
                  text.privacySettingsUploadHeading,
                  style: MealoraTypography.sectionTitle,
                ),
                const SizedBox(height: MealoraSpacing.sm),
                OnboardingChoiceCard(
                  title: text.privacySettingsUploadAskEachTimeTitle,
                  detail: text.privacySettingsUploadAskEachTimeDetail,
                  leading: Icons.help_outline_rounded,
                  leadingBackground: MealoraColors.iconFieldBlue,
                  leadingForeground: MealoraColors.info,
                  selected:
                      consent.valueOrNull ==
                      ImageUploadConsentPreference.askEachTime,
                  onTap: () => unawaited(
                    ref
                        .read(imageUploadConsentPreferenceProvider.notifier)
                        .set(ImageUploadConsentPreference.askEachTime),
                  ),
                ),
                const SizedBox(height: MealoraSpacing.sm),
                OnboardingChoiceCard(
                  title: text.privacySettingsUploadAlwaysAllowTitle,
                  detail: text.privacySettingsUploadAlwaysAllowDetail,
                  leading: Icons.cloud_upload_outlined,
                  leadingBackground: MealoraColors.iconFieldAmber,
                  leadingForeground: MealoraColors.amberText,
                  selected:
                      consent.valueOrNull ==
                      ImageUploadConsentPreference.alwaysAllow,
                  onTap: () => unawaited(
                    ref
                        .read(imageUploadConsentPreferenceProvider.notifier)
                        .set(ImageUploadConsentPreference.alwaysAllow),
                  ),
                ),
                const SizedBox(height: MealoraSpacing.lg),
                Text(
                  text.privacySettingsRetentionHeading,
                  style: MealoraTypography.sectionTitle,
                ),
                const SizedBox(height: MealoraSpacing.sm),
                OnboardingChoiceCard(
                  title: text.privacySettingsRetentionDeleteTitle,
                  detail: text.privacySettingsRetentionDeleteDetail,
                  leading: Icons.delete_outline_rounded,
                  leadingBackground: MealoraColors.iconFieldGreen,
                  leadingForeground: MealoraColors.primary,
                  selected:
                      retention.valueOrNull ==
                      ImageRetentionPreference.deleteAfterLogging,
                  onTap: () => unawaited(
                    ref
                        .read(imageRetentionPreferenceProvider.notifier)
                        .set(ImageRetentionPreference.deleteAfterLogging),
                  ),
                ),
                const SizedBox(height: MealoraSpacing.sm),
                OnboardingChoiceCard(
                  title: text.privacySettingsRetentionKeepTitle,
                  detail: text.privacySettingsRetentionKeepDetail,
                  leading: Icons.save_outlined,
                  leadingBackground: MealoraColors.iconFieldCoral,
                  leadingForeground: MealoraColors.coralText,
                  selected:
                      retention.valueOrNull ==
                      ImageRetentionPreference.keepOnDevice,
                  onTap: () => unawaited(
                    ref
                        .read(imageRetentionPreferenceProvider.notifier)
                        .set(ImageRetentionPreference.keepOnDevice),
                  ),
                ),
                const SizedBox(height: MealoraSpacing.lg),
                MealoraNoteCard(
                  icon: Icons.shield_outlined,
                  body: text.privacySettingsNote,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
