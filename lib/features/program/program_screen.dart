import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/format/id_formatters.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/data/local/program_progress_snapshot.dart';
import 'package:mealora/domain/program/program_state.dart';
import 'package:mealora/domain/program/user_program.dart';
import 'package:mealora/features/onboarding/onboarding_controller.dart';
import 'package:mealora/features/onboarding/onboarding_flow.dart';
import 'package:mealora/features/onboarding/onboarding_step.dart';
import 'package:mealora/features/onboarding/rejection_copy.dart';
import 'package:mealora/features/onboarding/widgets/onboarding_scaffold.dart';
import 'package:mealora/features/program/change_program_flow.dart';
import 'package:mealora/features/program/complete_program_screen.dart';
import 'package:mealora/features/program/history_screens.dart';
import 'package:mealora/features/program/how_calculated_screen.dart';
import 'package:mealora/features/program/program_name.dart';
import 'package:mealora/features/program/program_providers.dart';
import 'package:mealora/features/program/widgets/program_shared.dart';
import 'package:mealora/features/program/widgets/progress_section.dart';
import 'package:mealora/features/shell/app_shell.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// Ruang "Program".
///
/// `05 · Program saya` dan `27 · Program dijeda` adalah SATU layar dengan
/// susunan yang sama, bukan dua layar terpisah (Design D1, change 006) —
/// yang berbeda hanya penanda keadaan dan daftar kendali yang tersedia.
/// Lihat [_RunningProgramView].
///
/// Empat keadaan khusus (§45, Design D7, task 3.1–3.4): belum ada program
/// (`_NoProgramState`, sudah ada sejak change 001), profil belum lengkap
/// (`_ProfileIncompleteState`, jaring pengaman — gerbang peluncuran
/// `app/bootstrap.dart` seharusnya sudah menahan ini lebih dulu), belum
/// ada catatan berat (ditangani di dalam [_RunningProgramView], bukan
/// layar penuh — "berat terbaru" hanyalah satu bagian dari ruang ini), dan
/// kebijakan tidak tersedia (muncul di jalur ganti/revisi, bukan di sini —
/// ruang ini sendiri tidak pernah menghitung kebijakan).
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
      data: (program) {
        if (program == null) {
          // Dibaca lewat `isOnboardingCompleteProvider` (app/providers.dart,
          // `FutureProvider<bool>`), bukan `profileRepositoryProvider`
          // langsung — provider sinkron yang belum ditimpa melempar
          // `UnimplementedError` seketika saat `build` (bukan tertangkap
          // sebagai `AsyncError`), yang akan merusak layar ini di uji yang
          // tidak perlu peduli pada profil sama sekali.
          final onboardingComplete = ref.watch(isOnboardingCompleteProvider);
          return onboardingComplete.when(
            loading: () => MealoraSpacePage(
              title: text.navProgram,
              subtitle: text.programSubtitle,
              child: const SizedBox.shrink(),
            ),
            error: (error, stackTrace) => const _NoProgramState(),
            data: (complete) => complete
                ? const _NoProgramState()
                : const _ProfileIncompleteState(),
          );
        }
        return _RunningProgramView(program: program);
      },
    );
  }
}

/// Keadaan "profil belum lengkap" (task 3.2, §45) — jaring pengaman:
/// arsitektur aplikasi ini sudah menahan profil tidak lengkap di gerbang
/// peluncuran (`isOnboardingCompleteProvider`, `app/bootstrap.dart`)
/// sebelum ruang utama ditampilkan, jadi keadaan ini seharusnya tidak
/// pernah dijangkau lewat jalur normal — tetap dibangun sebagai jaring
/// pengaman sesuai permintaan eksplisit §45/spec, bukan sebagai kasus tepi
/// yang ditambal kemudian (Design D7).
class _ProfileIncompleteState extends ConsumerWidget {
  const _ProfileIncompleteState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = AppText.of(context);
    return MealoraSpacePage(
      title: text.navProgram,
      subtitle: text.programSubtitle,
      child: MealoraEmptyState(
        title: text.profileIncompleteTitle,
        body: text.profileIncompleteBody,
        icon: Icons.person_outline_rounded,
        action: MealoraPrimaryButton(
          label: text.profileIncompleteAction,
          onPressed: () {
            ref
                .read(onboardingControllerProvider.notifier)
                .goToStep(OnboardingStep.profileBasics);
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const OnboardingFlow()),
            );
          },
        ),
      ),
    );
  }
}

class _NoProgramState extends ConsumerWidget {
  const _NoProgramState();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = AppText.of(context);
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

/// Program aktif (`05`) atau dijeda (`27`) — satu layar, bukan dua (Design
/// D1): program, target, kemajuan, berat terbaru, dan kendali selalu
/// tampil; yang berbeda adalah penanda keadaan dan daftar kendali (task
/// 2.1).
class _RunningProgramView extends ConsumerWidget {
  const _RunningProgramView({required this.program});

  final UserProgram program;

  bool get _isPaused => program.state == ProgramState.paused;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = AppText.of(context);
    final progressAsync = ref.watch(programProgressProvider(program.id));
    final today = ref.watch(clockProvider).today();
    final lastCalculated = IdFormat.shortDate(
      LocalDate(
        program.startedAt.year,
        program.startedAt.month,
        program.startedAt.day,
      ),
    );

    return MealoraSpacePage(
      title: text.navProgram,
      subtitle: text.programSubtitle,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _ProgramHero(program: program, lastCalculated: lastCalculated),
          const SizedBox(height: MealoraSpacing.lg),
          if (_isPaused) ...<Widget>[
            MealoraNoteCard(
              icon: Icons.pause_circle_outline,
              title: text.pausedExplanationTitle,
              body: text.pausedExplanationBody,
            ),
            const SizedBox(height: MealoraSpacing.lg),
          ],
          progressAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (error, stackTrace) => const SizedBox.shrink(),
            data: (snapshots) => program.proposal.showsWeightProgressPercent
                ? const WeightProgressPlaceholderCard()
                : WeeklyConsistencyCard(snapshots: snapshots, today: today),
          ),
          const SizedBox(height: MealoraSpacing.lg),
          progressAsync.when(
            loading: () => const SizedBox.shrink(),
            error: (error, stackTrace) => const SizedBox.shrink(),
            data: (snapshots) => _LatestWeightTile(snapshots: snapshots),
          ),
          const SizedBox(height: MealoraSpacing.lg),
          Text(
            _isPaused
                ? text.programControlsPausedHeading
                : text.programControlsHeading,
            style: MealoraTypography.label,
          ),
          const SizedBox(height: MealoraSpacing.sm),
          if (_isPaused)
            ProgramControlList(
              tiles: <ProgramControlTile>[
                ProgramControlTile(
                  icon: Icons.play_circle_outline,
                  label: text.programResumeAction,
                  onTap: () => _resume(context, ref),
                ),
                ProgramControlTile(
                  icon: Icons.swap_horiz,
                  label: text.programChangeAction,
                  onTap: () => _openChange(context),
                ),
                ProgramControlTile(
                  icon: Icons.flag_outlined,
                  label: text.programCompleteAction,
                  onTap: () => _openComplete(context),
                ),
              ],
            )
          else
            Row(
              children: <Widget>[
                ProgramActionButton(
                  icon: Icons.pause_circle_outline,
                  label: text.programPauseAction,
                  onTap: () => _pause(context, ref),
                ),
                const SizedBox(width: MealoraSpacing.sm),
                ProgramActionButton(
                  icon: Icons.swap_horiz,
                  label: text.programChangeAction,
                  onTap: () => _openChange(context),
                ),
                const SizedBox(width: MealoraSpacing.sm),
                ProgramActionButton(
                  icon: Icons.history,
                  label: text.programHistoryAction,
                  onTap: () => _openHistory(context),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _pause(BuildContext context, WidgetRef ref) async {
    await ref
        .read(pauseProgramCommandProvider)
        .execute(userProgramId: program.id);
    bumpProgramRefresh(ref);
  }

  Future<void> _resume(BuildContext context, WidgetRef ref) async {
    await ref
        .read(resumeProgramCommandProvider)
        .execute(userProgramId: program.id);
    bumpProgramRefresh(ref);
  }

  void _openChange(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProgramChangePreviewScreen(currentProgram: program),
      ),
    );
  }

  void _openComplete(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CompleteProgramScreen(program: program),
      ),
    );
  }

  void _openHistory(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(builder: (_) => const ProgramHistoryListScreen()),
    );
  }
}

class _ProgramHero extends StatelessWidget {
  const _ProgramHero({required this.program, required this.lastCalculated});

  final UserProgram program;
  final String lastCalculated;

  bool get _isPaused => program.state == ProgramState.paused;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final proposal = program.proposal;

    return MealoraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: Text(
                  _isPaused
                      ? text.programPausedEyebrow
                      : text.programActiveEyebrow,
                  style: MealoraTypography.eyebrow,
                ),
              ),
              ProgramStatusChip(
                label: _isPaused
                    ? text.programPausedStatus
                    : text.programActiveStatus,
                icon: _isPaused
                    ? Icons.pause_circle_outline
                    : Icons.play_circle_outline,
                background: _isPaused
                    ? MealoraColors.accent.withValues(alpha: 0.16)
                    : MealoraColors.softGreen,
                foreground: _isPaused
                    ? MealoraColors.accent
                    : MealoraColors.primary,
              ),
            ],
          ),
          const SizedBox(height: MealoraSpacing.sm),
          Text(
            programDisplayName(text, program.programCode),
            style: MealoraTypography.headline,
          ),
          const SizedBox(height: MealoraSpacing.xxs),
          Text(
            programDescription(text, program.programCode),
            style: MealoraTypography.bodySmall,
          ),
          if (_isPaused) ...<Widget>[
            const SizedBox(height: MealoraSpacing.sm),
            Text(
              text.pausedSinceLabel(_pausedSince(program)),
              style: MealoraTypography.caption,
            ),
            const Divider(height: MealoraSpacing.lg, color: MealoraColors.line),
            Text(
              text.pausedDaysNotCountedExplanation,
              style: MealoraTypography.bodySmall,
            ),
          ],
          const Divider(height: MealoraSpacing.xl, color: MealoraColors.line),
          Text(text.programTargetLabel, style: MealoraTypography.label),
          const SizedBox(height: MealoraSpacing.xxs),
          Text(
            proposal.showsEnergyTarget && proposal.energyTarget != null
                ? '${IdFormat.integer(proposal.energyTarget!.kcal)} ${text.unitKilocalorie}'
                : text.reviewNoEnergyTargetNote,
            style: MealoraTypography.bodyEmphasis,
          ),
          const SizedBox(height: MealoraSpacing.sm),
          Align(
            alignment: Alignment.centerLeft,
            child: Semantics(
              button: true,
              label: text.programHowCalculatedAction,
              // Task 9.2 — cegah `Text` di bawah menduplikasi label ini
              // (lihat catatan yang sama di `ProgramControlTile`).
              excludeSemantics: true,
              child: InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => HowCalculatedScreen(program: program),
                  ),
                ),
                borderRadius: BorderRadius.circular(MealoraRadius.pill),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: MealoraSpacing.xs,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Flexible(
                        child: Text(
                          text.programHowCalculatedAction,
                          style: MealoraTypography.bodySmall.copyWith(
                            color: MealoraColors.primary,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right,
                        color: MealoraColors.primary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: MealoraSpacing.xxs),
          Text(
            text.programLastCalculatedLabel(lastCalculated),
            style: MealoraTypography.caption,
          ),
        ],
      ),
    );
  }

  String _pausedSince(UserProgram program) {
    final openInterval = program.pauseIntervals
        .where((p) => p.isOpen)
        .lastOrNull;
    final startedAt = openInterval?.startedAt ?? program.startedAt;
    return IdFormat.shortDate(
      LocalDate(startedAt.year, startedAt.month, startedAt.day),
    );
  }
}

class _LatestWeightTile extends StatelessWidget {
  const _LatestWeightTile({required this.snapshots});

  final List<ProgramProgressSnapshot> snapshots;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final latest = latestWeightSnapshot(snapshots);
    return MealoraCard(
      child: MealoraIconRow(
        icon: Icons.monitor_weight_outlined,
        title: text.programLatestWeightLabel,
        detail: latest == null
            ? text.programNoWeightRecordedYet
            : '${IdFormat.decimal(latest.weightKg!)} kg · '
                  '${IdFormat.shortDate(latest.recordedLocalDate)}',
      ),
    );
  }
}

/// Keadaan "kebijakan tidak tersedia" (§45, task 3.4) — memakai kerangka
/// penolakan dari change 005 (`rejectionCopyForMissingValidatedPolicy`),
/// tanpa satu pun angka target. Muncul pada jalur ganti/revisi target,
/// bukan sebagai layar ruang Program itu sendiri (ruang ini tidak pernah
/// menghitung kebijakan) — lihat `ProgramRevisionReviewScreen`
/// (`_RevisionRejectedView`) yang sudah menangani `MissingValidatedPolicy`
/// lewat fungsi yang sama ini, diekspos di sini sebagai dokumentasi
/// keterkaitan.
RejectionCopy programPolicyUnavailableCopy(AppText text) =>
    rejectionCopyForMissingValidatedPolicy(text);
