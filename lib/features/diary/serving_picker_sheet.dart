import 'package:flutter/material.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/domain/food/food.dart';
import 'package:mealora/domain/food/serving_size.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// Satuan tampilan takaran dasar berat/volume: "g" atau "ml".
String weightUnitLabel(ServingSize basis) => basis.unit == 'ml' ? 'ml' : 'g';

/// Takaran 100 g/100 ml makanan ini — dasar masukan jumlah bebas (design.md
/// D5). `null` bila tidak ada, sehingga masukan gram tidak ditawarkan.
ServingSize? weightBasisOf(Food food) =>
    food.servings.where((s) => s.isWeightBasis).firstOrNull;

/// Menampilkan berat dengan koma desimal Indonesia, tanpa ",0".
String formatWeight(double value) {
  final rounded = (value * 10).roundToDouble() / 10;
  return rounded == rounded.roundToDouble()
      ? rounded.toInt().toString()
      : rounded.toStringAsFixed(1).replaceAll('.', ',');
}

/// Penanda "perkiraan" di samping padanan berat takaran bertingkat
/// `estimate` (spec food-catalog, "Takaran perkiraan ditandai"; desain
/// 67 dan 71).
class ServingEstimateBadge extends StatelessWidget {
  const ServingEstimateBadge({super.key});

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return Semantics(
      label: text.servingEstimateSemantics,
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
        decoration: BoxDecoration(
          color: MealoraColors.iconFieldAmber,
          borderRadius: BorderRadius.circular(MealoraRadius.badge),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.info_outline,
              size: 11,
              color: MealoraColors.estimateText,
            ),
            const SizedBox(width: 4),
            Text(
              text.servingEstimateBadge,
              style: MealoraTypography.label.copyWith(
                color: MealoraColors.estimateText,
                letterSpacing: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Hasil lembar pilih takaran: sebuah takaran, atau beralih ke masukan
/// berat sendiri.
sealed class ServingPick {
  const ServingPick();
}

final class ServingPicked extends ServingPick {
  const ServingPicked(this.serving);
  final ServingSize serving;
}

final class WeightEntryPicked extends ServingPick {
  const WeightEntryPicked();
}

/// `67 · Pilih takaran sehari-hari`: setiap takaran tampil dengan padanan
/// beratnya, penanda "perkiraan", dan pilihan masukan berat sendiri bila
/// makanan punya takaran 100 g/100 ml.
class ServingPickerSheet extends StatelessWidget {
  const ServingPickerSheet({
    required this.food,
    required this.selected,
    this.offerWeightEntry = true,
    super.key,
  });

  final Food food;
  final ServingSize? selected;
  final bool offerWeightEntry;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final basis = offerWeightEntry ? weightBasisOf(food) : null;
    final anyEstimate = food.servings.any((s) => s.isEstimate);
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(MealoraSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              text.servingPickerTitle,
              style: MealoraTypography.sectionTitle,
            ),
            const SizedBox(height: MealoraSpacing.xxs),
            Text(
              text.servingPickerSubtitle(food.name),
              style: MealoraTypography.bodySmall,
            ),
            const SizedBox(height: MealoraSpacing.sm),
            for (final serving in food.servings)
              _ServingOption(
                serving: serving,
                selected: serving.id == selected?.id,
              ),
            if (basis != null) ...<Widget>[
              const SizedBox(height: MealoraSpacing.sm),
              Semantics(
                button: true,
                child: InkWell(
                  borderRadius: BorderRadius.circular(MealoraRadius.button),
                  onTap: () =>
                      Navigator.of(context).pop(const WeightEntryPicked()),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: MealoraSpacing.md,
                      vertical: MealoraSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: MealoraColors.surface,
                      borderRadius: BorderRadius.circular(MealoraRadius.button),
                      border: Border.all(color: MealoraColors.line),
                    ),
                    child: Row(
                      children: <Widget>[
                        const Icon(
                          Icons.scale_outlined,
                          color: MealoraColors.primary,
                          size: MealoraIconSize.action,
                        ),
                        const SizedBox(width: MealoraSpacing.sm),
                        Expanded(
                          child: Text(
                            text.servingPickerWeightEntry(
                              weightUnitLabel(basis),
                            ),
                            style: MealoraTypography.bodyEmphasis.copyWith(
                              color: MealoraColors.primary,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.chevron_right,
                          color: MealoraColors.affordance,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            if (anyEstimate) ...<Widget>[
              const SizedBox(height: MealoraSpacing.sm),
              Text(
                text.servingPickerEstimateHint,
                style: MealoraTypography.bodySmall,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ServingOption extends StatelessWidget {
  const _ServingOption({required this.serving, required this.selected});

  final ServingSize serving;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final gram = serving.gramEquivalent;
    final weight = serving.isWeightBasis
        ? text.servingPickerDirectWeight
        : gram == null
        ? null
        : text.servingPickerApproxWeight('${formatWeight(gram)} g');
    return Semantics(
      button: true,
      selected: selected,
      child: InkWell(
        onTap: () => Navigator.of(context).pop(ServingPicked(serving)),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: MealoraSpacing.sm),
          child: Row(
            children: <Widget>[
              MealoraCircleCheck(selected: selected),
              const SizedBox(width: MealoraSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(serving.label, style: MealoraTypography.bodyEmphasis),
                    if (weight != null || serving.isEstimate)
                      Padding(
                        padding: const EdgeInsets.only(top: 3),
                        child: Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: <Widget>[
                            if (weight != null)
                              Text(weight, style: MealoraTypography.bodySmall),
                            if (serving.isEstimate)
                              const ServingEstimateBadge(),
                            if (serving.provenanceTier ==
                                ServingProvenanceTier.derived)
                              Text(
                                '· ${text.servingPickerDerivedNote}',
                                style: MealoraTypography.bodySmall,
                              ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              if (serving.isDefault)
                MealoraChip(
                  label: text.servingPickerDefaultTag,
                  background: MealoraColors.iconField,
                  foreground: MealoraColors.primary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
