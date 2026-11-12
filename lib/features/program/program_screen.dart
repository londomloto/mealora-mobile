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
import 'package:mealora/domain/preferences/week_start.dart';
import 'package:mealora/domain/program/program_code.dart';
import 'package:mealora/domain/program/program_proposal_inputs.dart';
import 'package:mealora/domain/program/program_state.dart';
import 'package:mealora/domain/program/user_program.dart';
import 'package:mealora/domain/shared/units.dart';
import 'package:mealora/features/energy/widgets/energy_week_card.dart';
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
import 'package:mealora/features/program/program_revision_review_screen.dart';
import 'package:mealora/features/program/program_revision_service.dart';
import 'package:mealora/features/program/widgets/program_shared.dart';
import 'package:mealora/features/program/widgets/progress_section.dart';
import 'package:mealora/features/shell/app_shell.dart';
import 'package:mealora/features/weight/weight_controller.dart';
import 'package:mealora/features/weight/weight_monitor_screen.dart';
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

    // Scaffold sendiri (bukan cuma mengandalkan Scaffold AppShell) supaya
    // layar ini tetap punya ancestor Material saat dibuka langsung lewat
    // `MaterialPageRoute` dari menu Profil ("Program saya"), bukan hanya
    // lewat tab navigasi bawah. Scaffold bersarang aman di Flutter; `top:
    // false` menjaga header hero tetap edge-to-edge seperti rancangan.
    return Scaffold(
      backgroundColor: MealoraColors.background,
      body: SafeArea(
        top: false,
        bottom: false,
        child: _buildBody(context, ref, text, activeProgram),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    AppText text,
    AsyncValue<UserProgram?> activeProgram,
  ) {
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
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final headerHeight =
        (MealoraSpacing.mainHeroHeight + (textScale - 1).clamp(0, 1) * 220)
            .toDouble();

    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        bottom: MealoraSpacing.navigationContentClearance,
      ),
      child: Stack(
        children: <Widget>[
          _ProgramHeader(height: headerHeight),
          Padding(
            padding: EdgeInsets.fromLTRB(
              MealoraSpacing.screenGutter,
              headerHeight - MealoraSpacing.mainHeroOverlap,
              MealoraSpacing.screenGutter,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _ProgramHero(program: program, lastCalculated: lastCalculated),
                const SizedBox(height: MealoraSpacing.sm),
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
                  data: (snapshots) => WeeklyConsistencyCard(
                    snapshots: snapshots,
                    today: today,
                    weekStart:
                        ref.watch(weekStartProvider).valueOrNull ??
                        WeekStart.defaultValue,
                  ),
                ),
                const SizedBox(height: MealoraSpacing.sm),
                const EnergyWeekCard(),
                const SizedBox(height: MealoraSpacing.sm),
                progressAsync.when(
                  loading: () => const SizedBox.shrink(),
                  error: (error, stackTrace) => const SizedBox.shrink(),
                  data: (snapshots) => _LatestWeightTile(snapshots: snapshots),
                ),
                ref
                    .watch(targetReviewRecommendedProvider(program.id))
                    .maybeWhen(
                      data: (recommended) => recommended
                          ? Padding(
                              padding: const EdgeInsets.only(
                                top: MealoraSpacing.sm,
                              ),
                              child: _TargetReviewBanner(program: program),
                            )
                          : const SizedBox.shrink(),
                      orElse: () => const SizedBox.shrink(),
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
                        icon: Icons.pause_rounded,
                        label: text.programPauseAction,
                        iconColor: MealoraColors.accent,
                        iconBackground: MealoraColors.noteWarning,
                        onTap: () => _pause(context, ref),
                      ),
                      const SizedBox(width: MealoraSpacing.sm),
                      ProgramActionButton(
                        icon: Icons.swap_horiz_rounded,
                        label: text.programChangeAction,
                        iconColor: MealoraColors.primaryBright,
                        iconBackground: MealoraColors.noteSuccess,
                        onTap: () => _openChange(context),
                      ),
                      const SizedBox(width: MealoraSpacing.sm),
                      ProgramActionButton(
                        icon: Icons.history_rounded,
                        label: text.programHistoryAction,
                        iconColor: MealoraColors.peach,
                        iconBackground: MealoraColors.historyActionTint,
                        onTap: () => _openHistory(context),
                      ),
                    ],
                  ),
              ],
            ),
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

/// Header hijau penuh pada `05 · Program saya`.
///
/// Header sengaja bukan [MealoraSpacePage]: layar acuan memakai bidang hero
/// edge-to-edge dan kartu program yang menumpuk di atas batas bawahnya.
class _ProgramHeader extends StatelessWidget {
  const _ProgramHeader({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return MealoraMainHero(
      height: height,
      child: Padding(
        // 44 px, selaras judul hero `01 · Hari ini` (today_screen.dart) —
        // rancangan menempatkan judul kedua layar pada y yang sama (66 px
        // dari atas hero), bukan kebetulan; beda nilai sebelumnya (28 px)
        // membuat judul "melompat" saat berpindah tab.
        padding: const EdgeInsets.fromLTRB(
          MealoraSpacing.programHeroGutter,
          44,
          MealoraSpacing.programHeroGutter,
          0,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    text.programPageTitle,
                    style: MealoraTypography.title.copyWith(
                      color: MealoraColors.onPrimary,
                    ),
                  ),
                  const SizedBox(height: MealoraSpacing.xxs),
                  Text(
                    text.programPageSubtitle,
                    style: MealoraTypography.subtitle.copyWith(
                      color: MealoraColors.onPrimaryMuted,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: MealoraSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(MealoraRadius.iconField),
              child: Image.asset(
                'assets/brand/mealora-app-icon-1024.png',
                width: 40,
                height: 40,
                fit: BoxFit.contain,
                excludeFromSemantics: true,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Melukis blob Screen 05 langsung ke canvas hero.
///
/// Berbeda dari widget [ImageFiltered], blur ini tidak memiliki bounding box
/// persegi yang dapat muncul sebagai garis pada Flutter Web.
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
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: MealoraColors.noteSuccess,
                  borderRadius: BorderRadius.circular(
                    MealoraRadius.compactIconField,
                  ),
                ),
                child: Icon(
                  _isPaused
                      ? Icons.pause_rounded
                      : Icons.energy_savings_leaf_outlined,
                  color: _isPaused
                      ? MealoraColors.accent
                      : MealoraColors.primary,
                  size: MealoraIconSize.alert,
                ),
              ),
              const SizedBox(width: MealoraSpacing.sm),
              Expanded(
                child: Text(
                  _isPaused
                      ? text.programPausedEyebrow
                      : text.programActiveEyebrow,
                  style: MealoraTypography.eyebrow,
                ),
              ),
              Flexible(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: ProgramStatusChip(
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
                ),
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
          const Divider(height: MealoraSpacing.lg, color: MealoraColors.line),
          Semantics(
            button: true,
            label: text.programHowCalculatedAction,
            excludeSemantics: true,
            child: InkWell(
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => HowCalculatedScreen(program: program),
                ),
              ),
              borderRadius: BorderRadius.circular(MealoraRadius.chip),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: MealoraSpacing.xs,
                ),
                child: Flex(
                  direction: MediaQuery.textScalerOf(context).scale(1) > 1.3
                      ? Axis.vertical
                      : Axis.horizontal,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    if (MediaQuery.textScalerOf(context).scale(1) <= 1.3)
                      Expanded(child: _TargetLabel(text: text))
                    else
                      _TargetLabel(text: text),
                    if (MediaQuery.textScalerOf(context).scale(1) > 1.3)
                      const SizedBox(height: MealoraSpacing.sm),
                    Text(
                      proposal.showsEnergyTarget &&
                              proposal.energyTarget != null
                          ? '${IdFormat.integer(proposal.energyTarget!.kcal)} ${text.unitKilocalorie}'
                          : text.reviewNoEnergyTargetNote,
                      style: MealoraTypography.sectionTitle.copyWith(
                        color: MealoraColors.primary,
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ],
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

class _TargetLabel extends StatelessWidget {
  const _TargetLabel({required this.text});

  final AppText text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(text.programTargetLabel, style: MealoraTypography.caption),
        const SizedBox(height: MealoraSpacing.xxs),
        Text(
          text.programHowCalculatedAction,
          style: MealoraTypography.caption.copyWith(
            color: MealoraColors.primary,
          ),
        ),
      ],
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
    return Semantics(
      button: true,
      label: text.weightMonitorTitle,
      child: Material(
        color: MealoraColors.transparent,
        borderRadius: BorderRadius.circular(MealoraRadius.card),
        child: InkWell(
          borderRadius: BorderRadius.circular(MealoraRadius.card),
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const WeightMonitorScreen(),
            ),
          ),
          child: _buildCard(text, latest),
        ),
      ),
    );
  }

  Widget _buildCard(AppText text, ProgramProgressSnapshot? latest) {
    return MealoraCard(
      child: Row(
        children: <Widget>[
          Container(
            width: MealoraTouch.minTarget,
            height: MealoraTouch.minTarget,
            decoration: BoxDecoration(
              color: MealoraColors.noteInfo,
              borderRadius: BorderRadius.circular(
                MealoraRadius.compactIconField,
              ),
            ),
            child: const Icon(
              Icons.monitor_weight_outlined,
              color: MealoraColors.info,
            ),
          ),
          const SizedBox(width: MealoraSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  text.programLatestWeightLabel,
                  style: MealoraTypography.bodySmall,
                ),
                const SizedBox(height: MealoraSpacing.xxs),
                Text(
                  latest == null
                      ? text.programNoWeightRecordedYet
                      : '${IdFormat.decimal(latest.weightKg!)} kg',
                  style: latest == null
                      ? MealoraTypography.bodySmall
                      : MealoraTypography.sectionTitle,
                ),
              ],
            ),
          ),
          if (latest != null) ...<Widget>[
            Text(
              IdFormat.shortDate(latest.recordedLocalDate),
              style: MealoraTypography.caption,
            ),
            const SizedBox(width: MealoraSpacing.xxs),
          ],
          const Icon(
            Icons.chevron_right,
            color: MealoraColors.affordance,
            size: MealoraIconSize.action,
          ),
        ],
      ),
    );
  }
}

/// Usulan peninjauan target dari berat yang tercatat (change 008, design
/// D5) — murni dihitung ulang setiap kali ruang Program dibuka
/// (`targetReviewRecommendedProvider`), tidak ada status "sudah dilihat"
/// yang tersimpan: begitu berat kembali dalam ambang, usulan ini hilang
/// sendiri. Mengetuknya membuka layar pratinjau target yang sama persis
/// dengan jalur "ubah profil" (`34`, `edit_profile_screen.dart`), bedanya
/// cuma sumber `currentWeight` — dari `WeightRepository.latest()`, bukan
/// dari kolom profil (design D1: berat tidak lagi hidup di profil).
class _TargetReviewBanner extends ConsumerWidget {
  const _TargetReviewBanner({required this.program});

  final UserProgram program;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = AppText.of(context);
    return MealoraNoteCard(
      icon: Icons.fact_check_outlined,
      foreground: MealoraColors.info,
      background: MealoraColors.noteInfo,
      title: text.programTargetReviewTitle,
      body: text.programTargetReviewBody,
      semanticsLabel: text.programTargetReviewSemantics,
      onTap: () => _openTargetReview(context, ref),
    );
  }

  Future<void> _openTargetReview(BuildContext context, WidgetRef ref) async {
    final latest = await ref
        .read(weightRepositoryProvider)
        .latest(program.profileId);
    final latestWeight = latest == null
        ? null
        : Mass.kgValue(latest.weightKg, field: 'latestWeight').valueOrNull;
    if (latestWeight == null) {
      return;
    }

    final inputs = ProgramProposalInputs(
      ageYears: program.inputSnapshot.ageYears,
      biologicalInput: program.inputSnapshot.biologicalInput,
      height: program.inputSnapshot.height,
      currentWeight: latestWeight,
      activity: program.inputSnapshot.activity,
      screening: program.inputSnapshot.screening,
      specific: program.inputSnapshot.specific,
    );
    final requiresTargetWeight =
        program.programCode == ProgramCode.weightLoss ||
        program.programCode == ProgramCode.weightGain;

    final service = ref.read(programRevisionServiceProvider);
    final outcome = service.preview(
      programCode: program.programCode,
      inputs: inputs,
      requiresTargetWeight: requiresTargetWeight,
      requiresHabitFocus: false,
    );

    if (!context.mounted) {
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ProgramRevisionReviewScreen(
          profileId: program.profileId,
          programCode: program.programCode,
          previewInputs: inputs,
          previewOutcome: outcome,
          requiresTargetWeight: requiresTargetWeight,
          requiresHabitFocus: false,
          currentProposal: program.proposal,
          buildCurrentInputs: () => _rebuildCurrentInputs(ref, inputs),
        ),
      ),
    );
  }

  Future<ProgramProposalInputs> _rebuildCurrentInputs(
    WidgetRef ref,
    ProgramProposalInputs previous,
  ) async {
    final latest = await ref
        .read(weightRepositoryProvider)
        .latest(program.profileId);
    final latestWeight = latest == null
        ? null
        : Mass.kgValue(latest.weightKg, field: 'latestWeight').valueOrNull;
    if (latestWeight == null) {
      return previous;
    }
    return ProgramProposalInputs(
      ageYears: previous.ageYears,
      biologicalInput: previous.biologicalInput,
      height: previous.height,
      currentWeight: latestWeight,
      activity: previous.activity,
      screening: previous.screening,
      specific: previous.specific,
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
