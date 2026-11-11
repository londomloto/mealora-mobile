import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/errors/result.dart';
import 'package:mealora/core/format/id_formatters.dart';
import 'package:mealora/domain/diary/meal_entry.dart';
import 'package:mealora/domain/food/meal_time.dart';
import 'package:mealora/domain/food/nutrition_profile.dart';
import 'package:mealora/domain/food/serving_size.dart';
import 'package:mealora/features/diary/diary_format.dart';
import 'package:mealora/features/diary/diary_providers.dart';
import 'package:mealora/features/diary/option_sheet.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// `17 · Edit catatan makanan` (task 7.2/7.3): takaran, jumlah, waktu makan,
/// perkiraan setelah diubah, dan penghapusan — berlaku hanya pada catatan
/// ini (spec food-diary, "Menyunting, memindahkan, dan menghapus catatan").
class EditEntryScreen extends ConsumerStatefulWidget {
  const EditEntryScreen({required this.entry, super.key});

  final MealEntry entry;

  @override
  ConsumerState<EditEntryScreen> createState() => _EditEntryScreenState();
}

class _EditEntryScreenState extends ConsumerState<EditEntryScreen> {
  late ServingSize _serving;
  late MealTime _mealTime;
  late double _quantity;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _serving = ServingSize(
      id: widget.entry.servingId,
      label: widget.entry.servingLabelSnapshot,
      amount: 1,
      unit: '',
      isDefault: true,
      nutrition: widget.entry.nutritionPerServing,
    );
    _mealTime = widget.entry.mealTime;
    _quantity = widget.entry.quantity;
  }

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final estimate = _serving.nutrition.scaledBy(_quantity);

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
                MealoraBackEyebrow(
                  label: text.editEntryContextFormat(
                    DiaryFormat.mealTimeLabel(widget.entry.mealTime, text),
                    IdFormat.shortDate(widget.entry.localDate).toUpperCase(),
                  ),
                ),
                const SizedBox(height: MealoraSpacing.xs),
                Text(text.editEntryTitle, style: MealoraTypography.title),
                const SizedBox(height: MealoraSpacing.xxs),
                Text(text.editEntrySubtitle, style: MealoraTypography.subtitle),
                const SizedBox(height: MealoraSpacing.lg),
                MealoraIconRow(
                  icon: Icons.restaurant_outlined,
                  iconBackground: MealoraColors.iconFieldGreen,
                  title: widget.entry.foodNameSnapshot,
                  detail: text.editEntrySnapshotDetail(
                    widget.entry.servingLabelSnapshot,
                  ),
                  trailing: Text(
                    DiaryFormat.kcal(widget.entry.totalNutrition.energy, text),
                    style: MealoraTypography.bodyEmphasis.copyWith(
                      color: MealoraColors.primary,
                    ),
                  ),
                ),
                const SizedBox(height: MealoraSpacing.lg),
                Text(
                  text.servingDetailServingLabel,
                  style: MealoraTypography.compactFieldLabel,
                ),
                const SizedBox(height: MealoraSpacing.xs),
                _ServingPicker(
                  foodId: widget.entry.foodId,
                  serving: _serving,
                  onChanged: (value) => setState(() => _serving = value),
                ),
                const SizedBox(height: MealoraSpacing.lg),
                Text(
                  text.editEntryQuantityLabel,
                  style: MealoraTypography.compactFieldLabel,
                ),
                const SizedBox(height: MealoraSpacing.xs),
                _QuantityRow(
                  quantity: _quantity,
                  onChanged: (value) => setState(() => _quantity = value),
                ),
                const SizedBox(height: MealoraSpacing.lg),
                Text(
                  text.servingDetailMealTimeLabel,
                  style: MealoraTypography.compactFieldLabel,
                ),
                const SizedBox(height: MealoraSpacing.xs),
                _MealTimeRow(
                  mealTime: _mealTime,
                  onChanged: (value) => setState(() => _mealTime = value),
                ),
                const SizedBox(height: MealoraSpacing.lg),
                _EstimateRow(estimate: estimate, text: text),
                const SizedBox(height: MealoraSpacing.lg),
                Semantics(
                  button: true,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(MealoraRadius.chip),
                    onTap: _saving ? null : () => _confirmDelete(text),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: MealoraSpacing.sm,
                      ),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: MealoraColors.iconFieldCoral,
                        borderRadius: BorderRadius.circular(MealoraRadius.chip),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Icon(
                            Icons.delete_outline,
                            size: MealoraIconSize.inline,
                            color: MealoraColors.coralText,
                          ),
                          const SizedBox(width: MealoraSpacing.xxs),
                          Text(
                            text.editEntryDeleteAction,
                            style: MealoraTypography.bodyEmphasis.copyWith(
                              color: MealoraColors.coralText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: MealoraSpacing.xl),
                MealoraPrimaryButton(
                  label: text.editEntrySaveAction,
                  onPressed: _saving ? null : _save,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    final result = await updateFoodEntry(
      ref,
      entryId: widget.entry.id,
      serving: _serving,
      quantity: _quantity,
      mealTime: _mealTime,
    );
    if (!mounted) {
      return;
    }
    if (result is! Ok) {
      setState(() => _saving = false);
      return;
    }
    Navigator.of(context).pop();
  }

  Future<void> _confirmDelete(AppText text) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(text.editEntryDeleteConfirmTitle),
        content: Text(text.editEntryDeleteConfirmBody),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(text.editEntryDeleteCancelAction),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              text.editEntryDeleteConfirmAction,
              style: const TextStyle(color: MealoraColors.danger),
            ),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) {
      return;
    }
    setState(() => _saving = true);
    await deleteFoodEntry(ref, widget.entry.id);
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
  }
}

class _QuantityRow extends StatelessWidget {
  const _QuantityRow({required this.quantity, required this.onChanged});

  final double quantity;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MealoraSpacing.sm,
        vertical: MealoraSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: MealoraColors.glassCard,
        borderRadius: BorderRadius.circular(MealoraRadius.button),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Semantics(
            button: true,
            label: text.quantityDecreaseSemantics,
            child: InkWell(
              onTap: quantity > 0.5
                  ? () => onChanged((quantity - 0.5).clamp(0.5, 99))
                  : null,
              child: const Padding(
                padding: EdgeInsets.all(MealoraSpacing.sm),
                child: Icon(Icons.remove, color: MealoraColors.primary),
              ),
            ),
          ),
          Text(
            '${quantity.toStringAsFixed(1).replaceAll('.', ',')} sajian',
            style: MealoraTypography.headline,
          ),
          Semantics(
            button: true,
            label: text.quantityIncreaseSemantics,
            child: InkWell(
              onTap: () => onChanged((quantity + 0.5).clamp(0.5, 99)),
              child: const Padding(
                padding: EdgeInsets.all(MealoraSpacing.sm),
                child: Icon(Icons.add, color: MealoraColors.primary),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MealTimeRow extends StatelessWidget {
  const _MealTimeRow({required this.mealTime, required this.onChanged});

  final MealTime mealTime;
  final ValueChanged<MealTime> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return Wrap(
      spacing: MealoraSpacing.sm,
      runSpacing: MealoraSpacing.sm,
      children: <Widget>[
        for (final value in MealTime.values)
          ChoiceChip(
            label: Text(DiaryFormat.mealTimeLabel(value, text)),
            selected: value == mealTime,
            onSelected: (_) => onChanged(value),
          ),
      ],
    );
  }
}

class _EstimateRow extends StatelessWidget {
  const _EstimateRow({required this.estimate, required this.text});

  final NutritionProfile estimate;
  final AppText text;

  @override
  Widget build(BuildContext context) {
    return MealoraCard(
      child: Row(
        children: <Widget>[
          Expanded(
            child: Text(
              text.editEntryUpdatedEstimateLabel,
              style: MealoraTypography.bodySmall,
            ),
          ),
          Text(
            DiaryFormat.kcal(estimate.energy, text),
            style: MealoraTypography.headline.copyWith(
              color: MealoraColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Pilihan takaran SAAT INI dari katalog (bila makanan belum dihapus) —
/// memilih takaran lain membekukan potret baru pada penyimpanan (Design D9:
/// "Potret SHALL berubah hanya ketika pengguna menyunting catatan itu
/// sendiri"). Bila makanan sudah dihapus dari katalog, hanya takaran beku
/// pada catatan ini yang ditawarkan — tidak ada daftar lain untuk dipilih.
class _ServingPicker extends ConsumerWidget {
  const _ServingPicker({
    required this.foodId,
    required this.serving,
    required this.onChanged,
  });

  final String foodId;
  final ServingSize serving;
  final ValueChanged<ServingSize> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final text = AppText.of(context);
    final food = ref.watch(foodByIdProvider(foodId)).valueOrNull;
    final options = food?.servings ?? <ServingSize>[serving];

    return Semantics(
      button: true,
      label: serving.label,
      child: InkWell(
        borderRadius: BorderRadius.circular(MealoraRadius.button),
        onTap: options.length <= 1
            ? null
            : () async {
                final picked = await showModalBottomSheet<ServingSize>(
                  context: context,
                  builder: (context) => OptionSheet<ServingSize>(
                    title: text.servingPickerTitle,
                    options: options,
                    labelOf: (s) => s.label,
                    selected: serving,
                  ),
                );
                if (picked != null) {
                  onChanged(picked);
                }
              },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            horizontal: MealoraSpacing.sm,
            vertical: MealoraSpacing.sm,
          ),
          decoration: BoxDecoration(
            color: MealoraColors.glassCard,
            borderRadius: BorderRadius.circular(MealoraRadius.button),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: MealoraColors.iconField,
                  borderRadius: BorderRadius.circular(
                    MealoraRadius.compactIconField,
                  ),
                ),
                child: const Icon(
                  Icons.restaurant_outlined,
                  color: MealoraColors.primary,
                  size: MealoraIconSize.action,
                ),
              ),
              const SizedBox(width: MealoraSpacing.sm),
              Expanded(
                child: Text(
                  serving.label,
                  style: MealoraTypography.bodyEmphasis,
                ),
              ),
              if (options.length > 1)
                const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: MealoraColors.affordance,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
