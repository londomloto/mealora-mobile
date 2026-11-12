import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/features/diary/add_food_sheet.dart';
import 'package:mealora/features/history/history_screen.dart';
import 'package:mealora/features/profile/profile_screen.dart';
import 'package:mealora/features/program/program_screen.dart';
import 'package:mealora/features/share/startup_cleanup.dart';
import 'package:mealora/features/shell/destinations.dart';
import 'package:mealora/features/shell/floating_navigation.dart';
import 'package:mealora/features/today/today_screen.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// Ruang utama aplikasi: empat tujuan dengan navigasi kapsul mengambang.
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedDestinationProvider).valueOrNull;
    // Sekali per proses; hasilnya tidak memengaruhi tampilan.
    ref.watch(startupStorageCleanupProvider);

    if (selected == null) {
      return const Scaffold(
        backgroundColor: MealoraColors.background,
        body: SizedBox.shrink(),
      );
    }

    return Scaffold(
      backgroundColor: MealoraColors.background,
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: switch (selected) {
          MealoraDestination.today => const TodayScreen(),
          MealoraDestination.program => const ProgramScreen(),
          MealoraDestination.history => const HistoryScreen(),
          MealoraDestination.profile => const ProfileScreen(),
        },
      ),
      bottomNavigationBar: FloatingNavigation(
        selected: selected,
        onSelected: (destination) =>
            ref.read(selectedDestinationProvider.notifier).select(destination),
        onRecord: () => showAddFoodSheet(context),
      ),
    );
  }
}

/// Kerangka halaman yang dipakai keempat ruang utama.
class MealoraSpacePage extends StatelessWidget {
  const MealoraSpacePage({
    required this.title,
    required this.subtitle,
    required this.child,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        MealoraSpacing.screenGutter,
        MealoraSpacing.xl,
        MealoraSpacing.screenGutter,
        MealoraSpacing.navigationContentClearance,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Semantics(
            header: true,
            child: Text(text.appName, style: MealoraTypography.caption),
          ),
          const SizedBox(height: MealoraSpacing.xxs),
          Text(title, style: MealoraTypography.title),
          const SizedBox(height: MealoraSpacing.xs),
          Text(subtitle, style: MealoraTypography.subtitle),
          const SizedBox(height: MealoraSpacing.xl),
          child,
        ],
      ),
    );
  }
}
