import 'package:flutter/material.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/features/shell/app_shell.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// Ruang "Program".
///
/// Change ini hanya menyediakan kerangkanya: keadaan "belum ada data" yang
/// menjelaskan apa yang akan muncul di sini. Tidak ada angka nol yang
/// menyerupai hasil pengukuran.
class ProgramScreen extends StatelessWidget {
  const ProgramScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);

    return MealoraSpacePage(
      title: text.navProgram,
      subtitle: text.programSubtitle,
      child: MealoraEmptyState(
        title: text.programEmptyTitle,
        body: text.programEmptyBody,
        icon: Icons.flag_outlined,
      ),
    );
  }
}
