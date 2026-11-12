import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/domain/preferences/week_start.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// `65 · Bahasa & tampilan`. Hanya Bahasa Indonesia yang tersedia saat ini;
/// English ditampilkan nonaktif sampai terjemahannya ada.
class DisplaySettingsScreen extends ConsumerWidget {
  const DisplaySettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = AppText.of(context);
    final weekStart =
        ref.watch(weekStartProvider).valueOrNull ?? WeekStart.defaultValue;
    return Scaffold(
      backgroundColor: MealoraColors.background,
      body: MealoraBlobBackdrop(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              MealoraSpacing.programHeroGutter,
              MealoraSpacing.lg,
              MealoraSpacing.programHeroGutter,
              MealoraSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                MealoraBackEyebrow(label: text.displaySettingsContextLabel),
                const SizedBox(height: MealoraSpacing.xs),
                Text(text.displaySettingsTitle, style: MealoraTypography.title),
                const SizedBox(height: MealoraSpacing.xxs),
                Text(
                  text.displaySettingsSubtitle,
                  style: MealoraTypography.subtitle,
                ),
                const SizedBox(height: MealoraSpacing.lg),
                Text(
                  text.displaySettingsLanguageHeading,
                  style: MealoraTypography.sectionTitle,
                ),
                const SizedBox(height: MealoraSpacing.sm),
                MealoraCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: MealoraSpacing.md,
                    vertical: MealoraSpacing.xxs,
                  ),
                  child: Column(
                    children: <Widget>[
                      _LanguageRow(
                        label: text.displaySettingsLanguageIndonesian,
                        detail: text.displaySettingsLanguageCurrent,
                        trailing: const MealoraCircleCheck(selected: true),
                        selected: true,
                      ),
                      const Divider(height: 1, color: MealoraColors.line),
                      _LanguageRow(
                        label: text.displaySettingsLanguageEnglish,
                        detail: text.displaySettingsLanguageComingSoon,
                        trailing: _ComingSoonChip(
                          label: text.displaySettingsLanguageComingSoonChip,
                        ),
                        selected: false,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: MealoraSpacing.lg),
                Text(
                  text.displaySettingsCalendarHeading,
                  style: MealoraTypography.sectionTitle,
                ),
                const SizedBox(height: MealoraSpacing.sm),
                MealoraCard(
                  padding: const EdgeInsets.all(MealoraSpacing.md),
                  child: Row(
                    children: <Widget>[
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              text.displaySettingsWeekStartLabel,
                              style: MealoraTypography.bodyEmphasis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              text.displaySettingsWeekStartDetail,
                              style: MealoraTypography.caption,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: MealoraSpacing.sm),
                      _Segmented<WeekStart>(
                        value: weekStart,
                        options: <(WeekStart, String)>[
                          (
                            WeekStart.monday,
                            text.displaySettingsWeekStartMonday,
                          ),
                          (
                            WeekStart.sunday,
                            text.displaySettingsWeekStartSunday,
                          ),
                        ],
                        onChanged: (value) => unawaited(
                          ref.read(weekStartProvider.notifier).set(value),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: MealoraSpacing.lg),
                MealoraNoteCard(
                  icon: Icons.calendar_today_outlined,
                  body: text.displaySettingsNote,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.label,
    required this.detail,
    required this.trailing,
    required this.selected,
  });

  final String label;
  final String detail;
  final Widget trailing;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(vertical: MealoraSpacing.sm),
      child: Row(
        children: <Widget>[
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: selected ? MealoraColors.iconField : MealoraColors.line,
              borderRadius: BorderRadius.circular(
                MealoraRadius.compactIconField,
              ),
            ),
            child: Icon(
              Icons.translate_rounded,
              size: 18,
              color: selected ? MealoraColors.primaryDeep : MealoraColors.muted,
            ),
          ),
          const SizedBox(width: MealoraSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  label,
                  style: selected
                      ? MealoraTypography.bodyEmphasis
                      : MealoraTypography.bodyEmphasis.copyWith(
                          color: MealoraColors.muted,
                        ),
                ),
                const SizedBox(height: 2),
                Text(detail, style: MealoraTypography.caption),
              ],
            ),
          ),
          const SizedBox(width: MealoraSpacing.sm),
          trailing,
        ],
      ),
    );
    return Semantics(selected: selected, enabled: selected, child: row);
  }
}

class _ComingSoonChip extends StatelessWidget {
  const _ComingSoonChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MealoraSpacing.xs,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: MealoraColors.iconFieldAmber,
        borderRadius: BorderRadius.circular(MealoraRadius.pill),
      ),
      child: Text(
        label,
        style: MealoraTypography.caption.copyWith(
          color: MealoraColors.amberText,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

/// Kontrol segmen dua pilihan bergaya pil (rancangan `65`).
class _Segmented<T> extends StatelessWidget {
  const _Segmented({
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final T value;
  final List<(T, String)> options;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: MealoraColors.surface,
        borderRadius: BorderRadius.circular(MealoraRadius.pill),
        border: Border.all(color: MealoraColors.line),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final (option, label) in options)
            Semantics(
              button: true,
              selected: option == value,
              label: label,
              excludeSemantics: true,
              child: InkWell(
                borderRadius: BorderRadius.circular(MealoraRadius.pill),
                onTap: () => onChanged(option),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  constraints: const BoxConstraints(
                    minWidth: 64,
                    minHeight: MealoraTouch.minTarget,
                  ),
                  alignment: Alignment.center,
                  padding: const EdgeInsets.symmetric(
                    horizontal: MealoraSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: option == value ? MealoraColors.primary : null,
                    borderRadius: BorderRadius.circular(MealoraRadius.pill),
                  ),
                  child: Text(
                    label,
                    style: MealoraTypography.chipLabel.copyWith(
                      color: option == value
                          ? MealoraColors.onPrimary
                          : MealoraColors.ink,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
