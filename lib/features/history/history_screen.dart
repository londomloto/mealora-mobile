import 'package:flutter/material.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/features/shell/app_shell.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// Ruang "Riwayat".
///
/// Change ini hanya menyediakan kerangkanya: keadaan "belum ada data" yang
/// menjelaskan apa yang akan muncul di sini. Tidak ada angka nol yang
/// menyerupai hasil pengukuran.
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);

    return MealoraSpacePage(
      title: text.navHistory,
      subtitle: text.historySubtitle,
      child: MealoraEmptyState(
        title: text.historyEmptyTitle,
        body: text.historyEmptyBody,
        icon: Icons.calendar_today_outlined,
      ),
    );
  }
}
