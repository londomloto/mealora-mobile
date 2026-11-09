import 'package:flutter/material.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/features/profile/edit_profile_screen.dart';
import 'package:mealora/features/program/history_screens.dart';
import 'package:mealora/features/program/program_screen.dart';
import 'package:mealora/features/program/widgets/program_shared.dart';
import 'package:mealora/features/shell/app_shell.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// Ruang "Profil" (`33 · Profil & pengaturan`).
///
/// Butir "Ubah profil" dan "Program saya" dan "Riwayat program" tersambung
/// (task 9.1) — butir lain (Satuan & bahasa, Privasi & data lokal, Tentang
/// Mealora) dibiarkan belum aktif sesuai tasks.md change 006 group 9.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);

    return MealoraSpacePage(
      title: text.navProfile,
      subtitle: text.profileSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(text.profileSettingsHeading, style: MealoraTypography.label),
          const SizedBox(height: 8),
          ProgramControlList(
            tiles: <ProgramControlTile>[
              ProgramControlTile(
                icon: Icons.edit_outlined,
                label: text.profileEditAction,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const EditProfileScreen(),
                  ),
                ),
              ),
              ProgramControlTile(
                icon: Icons.flag_outlined,
                label: text.navProgram,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ProgramScreen(),
                  ),
                ),
              ),
              ProgramControlTile(
                icon: Icons.history,
                label: text.navHistory,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ProgramHistoryListScreen(),
                  ),
                ),
              ),
              ProgramControlTile(
                icon: Icons.straighten,
                label: text.profileUnitsLanguageAction,
                enabled: false,
                onTap: () {},
              ),
              ProgramControlTile(
                icon: Icons.lock_outline,
                label: text.profilePrivacyAction,
                enabled: false,
                onTap: () {},
              ),
              ProgramControlTile(
                icon: Icons.info_outline,
                label: text.profileAboutAction,
                enabled: false,
                onTap: () {},
              ),
            ],
          ),
        ],
      ),
    );
  }
}
