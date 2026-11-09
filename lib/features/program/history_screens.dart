import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/format/id_formatters.dart';
import 'package:mealora/domain/program/program_state.dart';
import 'package:mealora/domain/program/user_program.dart';
import 'package:mealora/domain/shared/program_warning.dart';
import 'package:mealora/features/program/completion_reason.dart';
import 'package:mealora/features/program/program_name.dart';
import 'package:mealora/features/program/program_providers.dart';
import 'package:mealora/features/program/widgets/program_shared.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// `29 · Riwayat program` (task 7.1): seluruh program berurutan menurut
/// waktu beserta keadaan akhir dan rentang tanggal — dibaca apa adanya
/// (Design D6), tidak menghitung ulang apa pun.
class ProgramHistoryListScreen extends ConsumerWidget {
  const ProgramHistoryListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = AppText.of(context);
    final history = ref.watch(programHistoryProvider);

    return Scaffold(
      backgroundColor: MealoraColors.background,
      body: MealoraBlobBackdrop(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              MealoraSpacing.screenGutter,
              MealoraSpacing.md,
              MealoraSpacing.screenGutter,
              MealoraSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _BackRow(label: text.historyProgramContextLabel),
                const SizedBox(height: MealoraSpacing.xs),
                Text(text.historyProgramTitle, style: MealoraTypography.title),
                const SizedBox(height: MealoraSpacing.xs),
                Text(
                  text.historyProgramSubtitle,
                  style: MealoraTypography.subtitle,
                ),
                const SizedBox(height: MealoraSpacing.xl),
                history.when(
                  loading: () => const SizedBox.shrink(),
                  error: (error, stackTrace) => MealoraErrorState(
                    title: text.historyProgramErrorTitle,
                    body: text.historyProgramErrorBody,
                  ),
                  data: (programs) => programs.isEmpty
                      ? MealoraEmptyState(
                          title: text.historyProgramEmptyTitle,
                          body: text.historyProgramEmptyBody,
                          icon: Icons.history,
                        )
                      : Column(
                          children: <Widget>[
                            // Terbaru di atas — `history()` mengembalikan
                            // urutan menaik menurut waktu mulai.
                            for (final program
                                in programs.reversed) ...<Widget>[
                              _HistoryEntry(program: program),
                              const SizedBox(height: MealoraSpacing.sm),
                            ],
                          ],
                        ),
                ),
                const SizedBox(height: MealoraSpacing.lg),
                MealoraNoteCard(
                  icon: Icons.shield_outlined,
                  title: text.historyProgramNoteTitle,
                  body: text.historyProgramNoteBody,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HistoryEntry extends StatelessWidget {
  const _HistoryEntry({required this.program});

  final UserProgram program;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return ProgramControlTile(
      icon: Icons.eco_outlined,
      label: programDisplayName(text, program.programCode),
      detail:
          '${_stateLabel(text, program.state)} · ${_dateRange(text, program)}',
      semanticsLabel:
          '${programDisplayName(text, program.programCode)}. '
          '${_stateLabel(text, program.state)}. ${_dateRange(text, program)}. '
          '${text.historyProgramEntryExtra}',
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => ProgramDetailHistoryScreen(program: program),
        ),
      ),
    );
  }

  String _dateRange(AppText text, UserProgram program) {
    final start = IdFormat.shortDate(_localDateOf(program.startedAt));
    if (program.endedAt == null) {
      return text.historyProgramRangeRunning(start);
    }
    final end = IdFormat.shortDate(_localDateOf(program.endedAt!));
    return text.historyProgramRangeEnded(start, end);
  }
}

String _stateLabel(AppText text, ProgramState state) => switch (state) {
  ProgramState.draft => text.historyProgramStateDraft,
  ProgramState.active => text.historyProgramStateActive,
  ProgramState.paused => text.historyProgramStatePaused,
  ProgramState.completed => text.historyProgramStateCompleted,
  ProgramState.changed => text.historyProgramStateChanged,
  ProgramState.cancelled => text.historyProgramStateCancelled,
};

LocalDate _localDateOf(DateTime instant) => LocalDate.fromLocalInstant(instant);

class _BackRow extends StatelessWidget {
  const _BackRow({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return Row(
      children: <Widget>[
        Semantics(
          button: true,
          label: text.onboardingBackSemantics,
          child: InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(MealoraRadius.pill),
            child: const Padding(
              padding: EdgeInsets.all(MealoraSpacing.xxs),
              child: Icon(Icons.arrow_back, color: MealoraColors.ink),
            ),
          ),
        ),
        Expanded(child: Text(label, style: MealoraTypography.eyebrow)),
      ],
    );
  }
}

/// `30 · Detail program selesai` — juga dipakai untuk entri yang masih
/// berjalan di dalam riwayat (task 7.2): masukan, target, asumsi,
/// peringatan, kedua versi, alasan berakhir, dan kemajuan akhir yang
/// tersedia. Membaca [program] dan potret kemajuannya apa adanya (task 7.3)
/// — tidak menghitung ulang, tidak mengisi celah kosong dengan nilai
/// terakhir yang diketahui (task 7.4).
class ProgramDetailHistoryScreen extends ConsumerWidget {
  const ProgramDetailHistoryScreen({required this.program, super.key});

  final UserProgram program;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = AppText.of(context);
    final proposal = program.proposal;
    final progress = ref.watch(programProgressProvider(program.id));
    final start = IdFormat.shortDate(_localDateOf(program.startedAt));
    final subtitle = program.endedAt == null
        ? text.historyProgramRangeRunning(start)
        : text.historyProgramRangeEnded(
            start,
            IdFormat.shortDate(_localDateOf(program.endedAt!)),
          );

    return Scaffold(
      backgroundColor: MealoraColors.background,
      body: MealoraBlobBackdrop(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              MealoraSpacing.screenGutter,
              MealoraSpacing.md,
              MealoraSpacing.screenGutter,
              MealoraSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _BackRow(
                  label:
                      '${text.historyDetailContextLabel} · ${_stateLabel(text, program.state)}',
                ),
                const SizedBox(height: MealoraSpacing.xs),
                Text(
                  programDisplayName(text, program.programCode),
                  style: MealoraTypography.title,
                ),
                const SizedBox(height: MealoraSpacing.xs),
                Text(subtitle, style: MealoraTypography.subtitle),
                const SizedBox(height: MealoraSpacing.xl),
                TargetHeroCard(
                  eyebrow: text.historyDetailTargetEyebrow,
                  value:
                      proposal.showsEnergyTarget &&
                          proposal.energyTarget != null
                      ? IdFormat.integer(proposal.energyTarget!.kcal)
                      : null,
                  unit:
                      proposal.showsEnergyTarget &&
                          proposal.energyTarget != null
                      ? text.unitKilocalorie
                      : null,
                  noValueNote: proposal.showsEnergyTarget
                      ? null
                      : text.reviewNoEnergyTargetNote,
                  caption: text.historyDetailTargetCaption,
                  footer: Text(
                    text.reviewVersionLine(
                      proposal.calculatorVersion,
                      proposal.policyVersion,
                    ),
                    style: MealoraTypography.caption.copyWith(
                      color: MealoraColors.onPrimaryMuted,
                    ),
                  ),
                ),
                const SizedBox(height: MealoraSpacing.xl),
                Text(
                  text.historyDetailFactsHeading,
                  style: MealoraTypography.sectionTitle,
                ),
                const SizedBox(height: MealoraSpacing.sm),
                FactsCard(
                  rows: <FactRow>[
                    FactRow(
                      label: text.historyDetailStatusLabel,
                      value: _stateLabel(text, program.state),
                    ),
                    FactRow(
                      label: text.historyDetailStartingWeightLabel,
                      value:
                          '${IdFormat.decimal(program.inputSnapshot.currentWeight.kg)} kg',
                    ),
                    progress.when(
                      loading: () => FactRow(
                        label: text.historyDetailLatestWeightLabel,
                        value: text.historyDetailNoDataOnLastDay,
                      ),
                      error: (error, stackTrace) => FactRow(
                        label: text.historyDetailLatestWeightLabel,
                        value: text.historyDetailNoDataOnLastDay,
                      ),
                      data: (snapshots) {
                        final latest = latestWeightSnapshot(snapshots);
                        return FactRow(
                          label: text.historyDetailLatestWeightLabel,
                          value: latest == null
                              ? text.historyDetailNoDataOnLastDay
                              : '${IdFormat.decimal(latest.weightKg!)} kg',
                        );
                      },
                    ),
                    FactRow(
                      label: text.historyDetailTargetWeightLabel,
                      value: program.inputSnapshot.specific.targetWeight == null
                          ? text.historyDetailTargetWeightNotRequired
                          : '${IdFormat.decimal(program.inputSnapshot.specific.targetWeight!.kg)} kg',
                    ),
                    FactRow(
                      label: text.historyDetailEndReasonLabel,
                      value: _endReasonLabel(text, program),
                    ),
                  ],
                ),
                if (proposal.warnings.isNotEmpty) ...<Widget>[
                  const SizedBox(height: MealoraSpacing.lg),
                  for (final warning in proposal.warnings) ...<Widget>[
                    MealoraNoteCard(
                      icon: Icons.warning_amber_rounded,
                      background: MealoraColors.accent.withValues(alpha: 0.14),
                      foreground: MealoraColors.accent,
                      body: _warningBody(text, warning),
                    ),
                    const SizedBox(height: MealoraSpacing.sm),
                  ],
                ],
                const SizedBox(height: MealoraSpacing.lg),
                MealoraNoteCard(
                  icon: Icons.inventory_2_outlined,
                  body: text.historyDetailNote,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _endReasonLabel(AppText text, UserProgram program) {
    if (program.state == ProgramState.changed) {
      return text.historyDetailEndReasonChanged;
    }
    if (program.state.isRunning) {
      return text.historyDetailEndReasonNotEnded;
    }
    final code = program.completionReason;
    if (code == null) {
      return text.historyDetailEndReasonUnknown;
    }
    final reason = ProgramCompletionReason.values
        .where((r) => r.code == code)
        .firstOrNull;
    return reason?.label(text) ?? code;
  }

  String _warningBody(AppText text, ProgramWarning warning) =>
      switch (warning) {
        ProgramWarning.floorApplied => text.reviewWarningFloorApplied,
        ProgramWarning.relativePaceCapApplied =>
          text.reviewWarningRelativePaceCapApplied,
        ProgramWarning.carbohydrateBelowRecommendedRange =>
          text.reviewWarningCarbohydrateBelowRecommendedRange,
      };
}
