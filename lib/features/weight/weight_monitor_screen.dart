import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/format/id_formatters.dart';
import 'package:mealora/domain/program/user_program.dart';
import 'package:mealora/domain/weight/weight_record.dart';
import 'package:mealora/features/weight/add_weight_screen.dart';
import 'package:mealora/features/weight/weight_controller.dart';
import 'package:mealora/features/weight/weight_providers.dart';
import 'package:mealora/features/weight/widgets/weight_trend_chart.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// `31 · Pantau berat` (change 008, design D1–D3).
///
/// Berat terbaru, perbandingan terhadap berat awal program bila berlaku,
/// tren tujuh hari terakhir dengan celah yang terlihat (design D2), dan
/// daftar catatan terakhir yang bisa disunting/dihapus (task 4.8).
class WeightMonitorScreen extends ConsumerWidget {
  const WeightMonitorScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = AppText.of(context);
    final recordsAsync = ref.watch(recentWeightRecordsProvider);

    return Scaffold(
      backgroundColor: MealoraColors.background,
      appBar: AppBar(
        backgroundColor: MealoraColors.background,
        elevation: 0,
        title: Text(
          text.weightMonitorTitle,
          style: MealoraTypography.sectionTitle,
        ),
        actions: <Widget>[
          Semantics(
            button: true,
            label: text.weightAddActionSemantics,
            child: IconButton(
              icon: const Icon(Icons.add_rounded, color: MealoraColors.ink),
              onPressed: () => _openAddWeight(context),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: recordsAsync.when(
          loading: () => const SizedBox.shrink(),
          error: (error, stackTrace) => MealoraErrorState(
            title: text.weightMonitorTitle,
            body: text.weightEmptyBody,
          ),
          data: (records) {
            if (records.isEmpty) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  MealoraSpacing.screenGutter,
                  MealoraSpacing.sm,
                  MealoraSpacing.screenGutter,
                  MealoraSpacing.xl,
                ),
                child: MealoraEmptyState(
                  icon: Icons.monitor_weight_outlined,
                  title: text.weightEmptyTitle,
                  body: text.weightEmptyBody,
                  action: MealoraPrimaryButton(
                    label: text.weightEmptyAction,
                    onPressed: () => _openAddWeight(context),
                  ),
                ),
              );
            }
            return _WeightMonitorContent(records: records);
          },
        ),
      ),
    );
  }

  Future<void> _openAddWeight(BuildContext context) async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute<bool>(builder: (_) => const AddWeightScreen()));
  }
}

class _WeightMonitorContent extends ConsumerWidget {
  const _WeightMonitorContent({required this.records});

  /// Terlama lebih dulu (`recentWeightRecordsProvider`) — dibalik di sini
  /// untuk daftar "Catatan terakhir" (terbaru lebih dulu).
  final List<WeightRecord> records;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = AppText.of(context);
    final latest = records.last;
    final activeProgram = ref.watch(activeProgramProvider).valueOrNull;
    final recent = records.reversed.toList(growable: false);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        MealoraSpacing.screenGutter,
        MealoraSpacing.sm,
        MealoraSpacing.screenGutter,
        MealoraSpacing.xl,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(text.weightMonitorSubtitle, style: MealoraTypography.subtitle),
          const SizedBox(height: MealoraSpacing.lg),
          _WeightHeroCard(latest: latest, activeProgram: activeProgram),
          const SizedBox(height: MealoraSpacing.lg),
          if (records.length < 2) ...<Widget>[
            Text(
              text.weightTrendHeading,
              style: MealoraTypography.sectionTitle,
            ),
            const SizedBox(height: MealoraSpacing.xxs),
            Text(
              text.weightTrendSingleRecordNote,
              style: MealoraTypography.bodySmall,
            ),
          ] else
            MealoraCard(
              radius: MealoraRadius.cardLarge,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Text(
                          text.weightTrendHeading,
                          style: MealoraTypography.sectionTitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: MealoraSpacing.xs),
                      ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 160),
                        child: Text(
                          text.weightTrendSubheading,
                          style: MealoraTypography.bodySmall,
                          textAlign: TextAlign.end,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: MealoraSpacing.md),
                  WeightTrendChart(records: records),
                ],
              ),
            ),
          const SizedBox(height: MealoraSpacing.lg),
          Text(
            text.weightRecentRecordsHeading,
            style: MealoraTypography.sectionTitle,
          ),
          const SizedBox(height: MealoraSpacing.md),
          MealoraCard(
            child: Column(
              children: <Widget>[
                for (var i = 0; i < recent.length; i++) ...<Widget>[
                  if (i > 0) const SizedBox(height: MealoraSpacing.sm),
                  _WeightEntryRow(record: recent[i]),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeightHeroCard extends StatelessWidget {
  const _WeightHeroCard({required this.latest, required this.activeProgram});

  final WeightRecord latest;
  final UserProgram? activeProgram;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final program = activeProgram;
    final showsComparison =
        program != null && program.proposal.showsWeightProgressPercent;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MealoraSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: MealoraColors.heroGradient,
          stops: MealoraColors.heroGradientStops,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(MealoraRadius.cardLarge),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: MealoraColors.shadowHero,
            offset: Offset(0, 16),
            blurRadius: 36,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Semantics(
            label: text.weightLatestSemantics(
              IdFormat.decimal(latest.weightKg),
              IdFormat.shortDate(latest.localDate),
            ),
            excludeSemantics: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  text.weightLatestLabel(IdFormat.shortDate(latest.localDate)),
                  style: MealoraTypography.eyebrow.copyWith(
                    color: MealoraColors.onPrimaryEyebrow,
                  ),
                ),
                const SizedBox(height: MealoraSpacing.xxs),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        IdFormat.decimal(latest.weightKg),
                        style: MealoraTypography.targetValue,
                      ),
                      const SizedBox(width: MealoraSpacing.xxs),
                      Padding(
                        padding: const EdgeInsets.only(
                          bottom: MealoraSpacing.xs,
                        ),
                        child: Text(
                          text.weightUnitKg,
                          style: MealoraTypography.targetUnit,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (showsComparison) ...<Widget>[
            const SizedBox(height: MealoraSpacing.xxs),
            Text(
              _comparisonText(text, program, latest),
              style: MealoraTypography.body.copyWith(
                color: MealoraColors.onPrimaryMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _comparisonText(
    AppText text,
    UserProgram program,
    WeightRecord latest,
  ) {
    final startWeight = program.inputSnapshot.currentWeight.kg;
    final delta = latest.weightKg - startWeight;
    final direction = delta < 0
        ? text.weightDirectionDown
        : delta > 0
        ? text.weightDirectionUp
        : text.weightDirectionFlat;
    return text.weightVsProgramStart(
      IdFormat.decimal(startWeight),
      direction,
      IdFormat.decimal(delta.abs()),
    );
  }
}

class _WeightEntryRow extends ConsumerWidget {
  const _WeightEntryRow({required this.record});

  final WeightRecord record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = AppText.of(context);
    return Semantics(
      label: text.weightEntrySemantics(
        IdFormat.shortDate(record.localDate),
        IdFormat.time(record.recordedAt),
        IdFormat.decimal(record.weightKg),
      ),
      child: MealoraIconRow(
        icon: Icons.monitor_weight_outlined,
        title: '${IdFormat.decimal(record.weightKg)} kg',
        detail:
            '${IdFormat.shortDate(record.localDate)} · ${IdFormat.time(record.recordedAt)}',
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            IconButton(
              icon: const Icon(Icons.edit_outlined, color: MealoraColors.muted),
              tooltip: text.weightEditEntryAction,
              onPressed: () => _edit(context),
            ),
            IconButton(
              icon: const Icon(
                Icons.delete_outline,
                color: MealoraColors.muted,
              ),
              tooltip: text.weightDeleteEntryAction,
              onPressed: () => _confirmDelete(context, ref, text),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _edit(BuildContext context) async {
    await Navigator.of(context).push(
      MaterialPageRoute<bool>(
        builder: (_) => AddWeightScreen(existingRecord: record),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    AppText text,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(text.weightDeleteConfirmTitle),
        content: Text(text.weightDeleteConfirmBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(text.weightDeleteCancelAction),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              text.weightDeleteConfirmAction,
              style: const TextStyle(color: MealoraColors.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true) {
      return;
    }
    await ref.read(weightRepositoryProvider).deleteRecord(record.id);
    bumpWeightRefresh(ref);
  }
}
