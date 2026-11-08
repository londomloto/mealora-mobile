import 'package:flutter/material.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/features/shell/app_shell.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// Ruang "Hari ini".
///
/// Change ini hanya menyediakan kerangkanya: keadaan "belum ada data" yang
/// menjelaskan apa yang akan muncul di sini. Tidak ada angka nol yang
/// menyerupai hasil pengukuran.
class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);

    return MealoraSpacePage(
      title: text.navToday,
      subtitle: text.todaySubtitle,
      child: MealoraEmptyState(
        title: text.todayEmptyTitle,
        body: text.todayEmptyBody,
        icon: Icons.restaurant_menu_outlined,
      ),
    );
  }
}
