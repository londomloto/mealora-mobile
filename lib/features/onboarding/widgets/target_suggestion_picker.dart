import 'package:flutter/material.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/format/id_formatters.dart';
import 'package:mealora/domain/program/target_suggestion.dart';
import 'package:mealora/domain/shared/reason_code.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// Daftar kartu pilihan saran penyesuaian target (desain `26b`/`26c`,
/// change 019). Hanya memilih — penerapan dilakukan tombol utama layar.
class TargetSuggestionPicker extends StatelessWidget {
  const TargetSuggestionPicker({
    required this.suggestions,
    required this.reasonCode,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final List<TargetSuggestion> suggestions;
  final ReasonCode reasonCode;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(text.targetSuggestionHeading, style: MealoraTypography.caption),
        const SizedBox(height: MealoraSpacing.xs),
        for (var i = 0; i < suggestions.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: MealoraSpacing.sm),
          _SuggestionCard(
            suggestion: suggestions[i],
            copy: _copy(text, suggestions[i]),
            recommended: i == 0 && suggestions.length > 1,
            selected: i == selectedIndex,
            onTap: () => onSelected(i),
          ),
        ],
      ],
    );
  }

  (String, String) _copy(AppText text, TargetSuggestion s) {
    final weight = IdFormat.decimal(s.targetWeightKg);
    final date = s.targetDate == null ? '' : IdFormat.longDate(s.targetDate!);
    final fast = reasonCode == ReasonCode.requestedPaceTooFast;
    return switch (s.kind) {
      TargetSuggestionKind.minimumSafeWeight => (
        text.targetSuggestionMinimumTitle(weight),
        text.targetSuggestionMinimumDetail,
      ),
      TargetSuggestionKind.keepWeightChangeDate => (
        text.targetSuggestionKeepWeightTitle(weight, date),
        fast
            ? text.targetSuggestionKeepWeightFastDetail
            : text.targetSuggestionKeepWeightSlowDetail,
      ),
      TargetSuggestionKind.keepDateChangeWeight => (
        text.targetSuggestionKeepDateTitle(date, weight),
        fast
            ? text.targetSuggestionKeepDateFastDetail
            : text.targetSuggestionKeepDateSlowDetail,
      ),
    };
  }
}

class _SuggestionCard extends StatelessWidget {
  const _SuggestionCard({
    required this.suggestion,
    required this.copy,
    required this.recommended,
    required this.selected,
    required this.onTap,
  });

  final TargetSuggestion suggestion;
  final (String, String) copy;
  final bool recommended;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final (title, detail) = copy;
    final icon = switch (suggestion.kind) {
      TargetSuggestionKind.keepWeightChangeDate => Icons.event_outlined,
      _ => Icons.track_changes_outlined,
    };
    return Semantics(
      button: true,
      selected: selected,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(MealoraRadius.card),
            border: Border.all(
              color: MealoraColors.primary.withValues(alpha: selected ? 1 : 0),
              width: 2,
            ),
          ),
          child: MealoraCard(
            child: MealoraIconRow(
              icon: icon,
              title: title,
              detail: detail,
              trailing: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Icon(
                    selected
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: selected
                        ? MealoraColors.primary
                        : MealoraColors.affordance,
                  ),
                  if (recommended) ...<Widget>[
                    const SizedBox(height: MealoraSpacing.xxs),
                    Text(
                      text.targetSuggestionRecommended,
                      style: MealoraTypography.caption.copyWith(
                        color: MealoraColors.primaryDeep,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Petunjuk rentang aman di bawah isian (desain `25b`, change 019).
class TargetSafeHint extends StatelessWidget {
  const TargetSafeHint({required this.text, required this.icon, super.key});

  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 1),
          child: Icon(icon, size: 14, color: MealoraColors.primary),
        ),
        const SizedBox(width: MealoraSpacing.xxs),
        Expanded(
          child: Text(
            text,
            style: MealoraTypography.caption.copyWith(
              color: MealoraColors.primaryDeep,
            ),
          ),
        ),
      ],
    );
  }
}
