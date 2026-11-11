import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/features/profile/about_screen.dart';
import 'package:mealora/features/profile/display_settings_screen.dart';
import 'package:mealora/features/profile/edit_profile_screen.dart';
import 'package:mealora/features/profile/privacy_settings_screen.dart';
import 'package:mealora/features/profile/widgets/settings_list_card.dart';
import 'package:mealora/features/program/history_screens.dart';
import 'package:mealora/features/program/program_screen.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// `33 · Profil & pengaturan`.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = AppText.of(context);
    final profile = ref.watch(currentProfileProvider).valueOrNull;
    final name = profile?.nickname?.trim().isNotEmpty == true
        ? profile!.nickname!.trim()
        : text.todayDefaultName;

    return MealoraBlobBackdrop(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          MealoraSpacing.programHeroGutter,
          MealoraSpacing.xl,
          MealoraSpacing.programHeroGutter,
          MealoraSpacing.navigationContentClearance,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              text.profileContextLabel,
              style: MealoraTypography.eyebrow.copyWith(
                color: MealoraColors.primaryDeep,
              ),
            ),
            const SizedBox(height: MealoraSpacing.xxs),
            Text(text.profilePageTitle(name), style: MealoraTypography.title),
            const SizedBox(height: MealoraSpacing.xxs),
            Text(text.profilePageSubtitle, style: MealoraTypography.subtitle),
            const SizedBox(height: MealoraSpacing.lg),
            MealoraCard(
              child: Row(
                children: <Widget>[
                  Container(
                    width: 56,
                    height: 56,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: MealoraColors.heroGradient,
                        stops: MealoraColors.heroGradientStops,
                      ),
                      borderRadius: BorderRadius.circular(
                        MealoraRadius.choiceCard,
                      ),
                    ),
                    child: Text(
                      name.characters.first.toUpperCase(),
                      style: MealoraTypography.headline.copyWith(
                        color: MealoraColors.onPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(width: MealoraSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(name, style: MealoraTypography.sectionTitle),
                        const SizedBox(height: MealoraSpacing.xxs),
                        Text(
                          text.profileLocalDetail,
                          style: MealoraTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: MealoraSpacing.lg),
            Text(
              text.profileSettingsHeading,
              style: MealoraTypography.sectionTitle,
            ),
            const SizedBox(height: MealoraSpacing.sm),
            SettingsListCard(
              items: <SettingsListItem>[
                SettingsListItem(
                  icon: Icons.person_outline_rounded,
                  color: MealoraColors.primaryDeep,
                  background: MealoraColors.iconField,
                  label: text.profileEditAction,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const EditProfileScreen(),
                    ),
                  ),
                ),
                SettingsListItem(
                  icon: Icons.track_changes_rounded,
                  color: MealoraColors.accent,
                  background: MealoraColors.noteWarning,
                  label: text.programPageTitle,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ProgramScreen(),
                    ),
                  ),
                ),
                SettingsListItem(
                  icon: Icons.history_rounded,
                  color: MealoraColors.peach,
                  background: MealoraColors.historyActionTint,
                  label: text.historyProgramTitle,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const ProgramHistoryListScreen(),
                    ),
                  ),
                ),
                SettingsListItem(
                  icon: Icons.language_rounded,
                  color: MealoraColors.info,
                  background: MealoraColors.noteInfo,
                  label: text.profileUnitsLanguageAction,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const DisplaySettingsScreen(),
                    ),
                  ),
                ),
                SettingsListItem(
                  icon: Icons.shield_outlined,
                  color: MealoraColors.primaryDeep,
                  background: MealoraColors.iconField,
                  label: text.profilePrivacyAction,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const PrivacySettingsScreen(),
                    ),
                  ),
                ),
                SettingsListItem(
                  icon: Icons.info_outline_rounded,
                  color: MealoraColors.muted,
                  background: MealoraColors.line,
                  label: text.profileAboutAction,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => const AboutScreen(),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
