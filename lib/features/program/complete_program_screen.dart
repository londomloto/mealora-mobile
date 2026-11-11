import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/domain/program/user_program.dart';
import 'package:mealora/features/onboarding/widgets/onboarding_choice_card.dart';
import 'package:mealora/features/program/completion_reason.dart';
import 'package:mealora/features/program/program_name.dart';
import 'package:mealora/features/program/program_providers.dart';
import 'package:mealora/features/program/widgets/program_shared.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// `39 · Selesaikan program` (task 5.2/5.3): peninjauan PENUH, bukan dialog
/// konfirmasi singkat (Design D3) — pemilihan alasan, pernyataan ringkasan
/// akhir disimpan, pernyataan program selesai tidak dapat dilanjutkan, dan
/// jalan batal yang tidak mengubah apa pun (task 5.6).
class CompleteProgramScreen extends ConsumerStatefulWidget {
  const CompleteProgramScreen({required this.program, super.key});

  final UserProgram program;

  @override
  ConsumerState<CompleteProgramScreen> createState() =>
      _CompleteProgramScreenState();
}

class _CompleteProgramScreenState extends ConsumerState<CompleteProgramScreen> {
  ProgramCompletionReason? _reason;
  bool _submitting = false;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);

    return Scaffold(
      backgroundColor: MealoraColors.background,
      body: MealoraBlobBackdrop(
        child: SafeArea(
          child: Column(
            children: <Widget>[
              Expanded(
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
                      MealoraBackEyebrow(label: text.completeContextLabel),
                      const SizedBox(height: MealoraSpacing.xs),
                      Text(text.completeTitle, style: MealoraTypography.title),
                      const SizedBox(height: MealoraSpacing.xs),
                      Text(
                        text.completeSubtitle,
                        style: MealoraTypography.subtitle,
                      ),
                      const SizedBox(height: MealoraSpacing.xl),
                      MealoraCard(
                        child: MealoraIconRow(
                          icon: Icons.eco_outlined,
                          title: programDisplayName(
                            text,
                            widget.program.programCode,
                          ),
                          detail: text.completeProgramEyebrow,
                        ),
                      ),
                      const SizedBox(height: MealoraSpacing.lg),
                      Text(
                        text.completeReasonHeading,
                        style: MealoraTypography.label,
                      ),
                      const SizedBox(height: MealoraSpacing.xs),
                      ProgramControlTile(
                        icon: Icons.flag_outlined,
                        label: text.completeReasonHeading,
                        detail:
                            _reason?.label(text) ??
                            text.completeReasonPlaceholder,
                        onTap: _pickReason,
                      ),
                      const SizedBox(height: MealoraSpacing.lg),
                      MealoraNoteCard(
                        icon: Icons.inventory_2_outlined,
                        title: text.completeSnapshotTitle,
                        body: text.completeSnapshotBody,
                      ),
                      const SizedBox(height: MealoraSpacing.md),
                      Text(
                        text.completeFinalityNote,
                        style: MealoraTypography.bodySmall,
                      ),
                      const SizedBox(height: MealoraSpacing.lg),
                      Center(
                        child: Semantics(
                          button: true,
                          label: text.completeCancelAction,
                          child: InkWell(
                            onTap: _submitting
                                ? null
                                : () => Navigator.of(context).pop(),
                            child: Padding(
                              padding: const EdgeInsets.all(MealoraSpacing.sm),
                              child: Text(
                                text.completeCancelAction,
                                style: MealoraTypography.bodyEmphasis.copyWith(
                                  color: MealoraColors.primary,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  MealoraSpacing.screenGutter,
                  0,
                  MealoraSpacing.screenGutter,
                  MealoraSpacing.lg,
                ),
                child: MealoraPrimaryButton(
                  label: text.completeConfirmAction,
                  onPressed: (_reason == null || _submitting) ? null : _confirm,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickReason() async {
    final text = AppText.of(context);
    final picked = await showModalBottomSheet<ProgramCompletionReason>(
      context: context,
      isScrollControlled: true,
      backgroundColor: MealoraColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(MealoraRadius.sheet),
        ),
      ),
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(MealoraSpacing.lg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  text.completeReasonHeading,
                  style: MealoraTypography.sectionTitle,
                ),
                const SizedBox(height: MealoraSpacing.md),
                for (final reason
                    in ProgramCompletionReason.values) ...<Widget>[
                  OnboardingChoiceCard(
                    title: reason.label(text),
                    selected: _reason == reason,
                    onTap: () => Navigator.of(sheetContext).pop(reason),
                  ),
                  const SizedBox(height: MealoraSpacing.sm),
                ],
              ],
            ),
          ),
        );
      },
    );
    if (picked != null) {
      setState(() => _reason = picked);
    }
  }

  Future<void> _confirm() async {
    final reason = _reason;
    if (reason == null) {
      return;
    }
    setState(() => _submitting = true);
    await ref
        .read(completeProgramCommandProvider)
        .execute(userProgramId: widget.program.id, reasonCode: reason.code);
    if (!mounted) {
      return;
    }
    bumpProgramRefresh(ref);
    Navigator.of(context).pop();
  }
}
