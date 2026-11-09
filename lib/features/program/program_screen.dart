import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/domain/program/program_code.dart';
import 'package:mealora/domain/program/user_program.dart';
import 'package:mealora/features/onboarding/onboarding_controller.dart';
import 'package:mealora/features/onboarding/onboarding_flow.dart';
import 'package:mealora/features/onboarding/onboarding_step.dart';
import 'package:mealora/features/onboarding/widgets/onboarding_scaffold.dart';
import 'package:mealora/features/shell/app_shell.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// Ruang "Program".
///
/// `36 · Belum ada program` (task 6.4/6.5) menggantikan keadaan kosong
/// change 001 begitu profil lengkap tanpa program berjalan — muncul pada
/// ketiga jalurnya: melewati pemilihan (scenario 6.13), program berakhir
/// (change berikutnya), dan pengguna dari versi sebelum program ada
/// (scenario 6.14), karena ketiganya sama-sama berarti
/// `activeProgramProvider` kosong.
///
/// Siklus hidup program penuh (jeda, ganti, riwayat, selesaikan) adalah
/// change berikutnya (Non-Goals) — saat ada program berjalan, ruang ini
/// untuk sementara hanya menyebut programnya.
class ProgramScreen extends ConsumerWidget {
  const ProgramScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = AppText.of(context);
    final activeProgram = ref.watch(activeProgramProvider);

    return activeProgram.when(
      loading: () => MealoraSpacePage(
        title: text.navProgram,
        subtitle: text.programSubtitle,
        child: const SizedBox.shrink(),
      ),
      error: (error, stackTrace) => MealoraSpacePage(
        title: text.navProgram,
        subtitle: text.programSubtitle,
        child: MealoraEmptyState(
          title: text.programEmptyTitle,
          body: text.programEmptyBody,
          icon: Icons.flag_outlined,
        ),
      ),
      data: (program) => program == null
          ? _NoProgramState(text: text, ref: ref)
          : _ActiveProgramSummary(text: text, program: program),
    );
  }
}

class _NoProgramState extends StatelessWidget {
  const _NoProgramState({required this.text, required this.ref});

  final AppText text;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return OnboardingScaffold(
      contextLabel: text.noProgramContextLabel,
      title: text.noProgramTitle,
      subtitle: text.noProgramSubtitle,
      primaryActionLabel: text.noProgramAction,
      onPrimaryAction: () => _startProgramSelection(ref, context),
      children: <Widget>[
        MealoraEmptyState(
          title: text.noProgramHeading,
          body: text.noProgramDescription,
          icon: Icons.track_changes_outlined,
        ),
        const SizedBox(height: MealoraSpacing.lg),
        MealoraNoteCard(
          icon: Icons.history,
          title: text.noProgramHistoryHeading,
          body: text.noProgramHistoryExplanation,
        ),
      ],
    );
  }

  /// Membuka kembali alur onboarding pada langkah pilih program, didorong
  /// sebagai rute di atas `AppShell` — gerbang peluncuran
  /// (`_OnboardingGate`) tidak dilibatkan lagi karena profil sudah lengkap
  /// selamanya (Design D2); hanya langkah program yang perlu diulang.
  /// `review_screen.dart` menutup rute ini sendiri begitu aktivasi
  /// berhasil (`Navigator.pop`).
  void _startProgramSelection(WidgetRef ref, BuildContext context) {
    ref
        .read(onboardingControllerProvider.notifier)
        .goToStep(OnboardingStep.programSelect);
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const OnboardingFlow()));
  }
}

class _ActiveProgramSummary extends StatelessWidget {
  const _ActiveProgramSummary({required this.text, required this.program});

  final AppText text;
  final UserProgram program;

  @override
  Widget build(BuildContext context) {
    return MealoraSpacePage(
      title: text.navProgram,
      subtitle: text.programSubtitle,
      child: MealoraCard(
        child: MealoraIconRow(
          icon: Icons.eco_outlined,
          title: _programName(text, program.programCode),
          titleStyle: MealoraTypography.sectionTitle,
        ),
      ),
    );
  }

  String _programName(AppText text, ProgramCode code) => switch (code) {
    ProgramCode.healthyEating => text.onboardingProgramHealthyName,
    ProgramCode.weightLoss => text.onboardingProgramWeightLossName,
    ProgramCode.weightGain => text.onboardingProgramWeightGainName,
    ProgramCode.maintenance => text.onboardingProgramMaintenanceName,
  };
}
