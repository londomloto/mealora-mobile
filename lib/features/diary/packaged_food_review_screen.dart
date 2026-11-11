import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/errors/result.dart';
import 'package:mealora/core/format/id_formatters.dart';
import 'package:mealora/domain/food/food.dart';
import 'package:mealora/domain/food/meal_time.dart';
import 'package:mealora/domain/food/nutrition_profile.dart';
import 'package:mealora/domain/food/serving_size.dart';
import 'package:mealora/domain/packaged_food/packaged_food.dart';
import 'package:mealora/domain/packaged_food/packaged_food_nutrition.dart';
import 'package:mealora/domain/packaged_food/packaged_food_provenance.dart';
import 'package:mealora/domain/packaged_food/packaged_food_quantity.dart';
import 'package:mealora/domain/packaged_food/serving_basis.dart';
import 'package:mealora/domain/shared/units.dart';
import 'package:mealora/features/diary/diary_format.dart';
import 'package:mealora/features/diary/option_sheet.dart';
import 'package:mealora/features/diary/packaged_food_providers.dart';
import 'package:mealora/features/reminders/late_meal_notice.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// `04 · Tinjau produk kemasan` (tasks 7.1-7.8, change 009): nama, merek,
/// ukuran kemasan, takaran saji, jumlah sajian per kemasan, nilai gizi,
/// penanda asal data, dan tanggal verifikasi — seluruhnya ditinjau sebelum
/// dicatat (spec, "Produk ditinjau sebelum dicatat").
///
/// SHALL TIDAK membuat catatan apa pun sebelum [MealoraPrimaryButton]
/// ditekan (task 7.5) — menutup layar ini (tombol kembali OS/AppBar) tidak
/// memanggil `confirmAndLogPackagedFood` di mana pun pada berkas ini.
class PackagedFoodReviewScreen extends ConsumerStatefulWidget {
  const PackagedFoodReviewScreen({required this.product, this.date, super.key});

  final PackagedFood product;
  final LocalDate? date;

  @override
  ConsumerState<PackagedFoodReviewScreen> createState() =>
      _PackagedFoodReviewScreenState();
}

class _PackagedFoodReviewScreenState
    extends ConsumerState<PackagedFoodReviewScreen> {
  late MealTime _mealTime;
  late bool _wholePackage;
  double _servings = 1;
  final _gramsController = TextEditingController(text: '100');

  bool _correcting = false;
  late final TextEditingController _energy;
  late final TextEditingController _protein;
  late final TextEditingController _carbohydrate;
  late final TextEditingController _fat;

  bool _saving = false;
  String? _quantityError;

  bool get _isPerServing =>
      widget.product.servingBasis == ServingBasis.perServing;

  @override
  void initState() {
    super.initState();
    _mealTime = MealTime.lunch;
    _wholePackage = false;
    final current = widget.product.valuesAtRecordedBasis;
    _energy = TextEditingController(
      text: current.energy == null
          ? ''
          : IdFormat.decimal(current.energy!.kcal),
    );
    _protein = TextEditingController(
      text: current.proteinG == null ? '' : IdFormat.decimal(current.proteinG!),
    );
    _carbohydrate = TextEditingController(
      text: current.carbohydrateG == null
          ? ''
          : IdFormat.decimal(current.carbohydrateG!),
    );
    _fat = TextEditingController(
      text: current.fatG == null ? '' : IdFormat.decimal(current.fatG!),
    );
  }

  @override
  void dispose() {
    _gramsController.dispose();
    _energy.dispose();
    _protein.dispose();
    _carbohydrate.dispose();
    _fat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final product = widget.product;

    final quantity = _currentQuantity();
    final total = quantity == null
        ? null
        : calculatePackagedFoodNutrition(product, quantity);

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
                MealoraBackEyebrow(label: text.packagedFoodReviewContextLabel),
                const SizedBox(height: MealoraSpacing.xs),
                Text(
                  text.packagedFoodReviewTitle,
                  style: MealoraTypography.title,
                ),
                const SizedBox(height: MealoraSpacing.xxs),
                Text(
                  text.packagedFoodReviewSubtitle,
                  style: MealoraTypography.subtitle,
                ),
                const SizedBox(height: MealoraSpacing.md),
                Wrap(
                  spacing: MealoraSpacing.xs,
                  runSpacing: MealoraSpacing.xs,
                  children: <Widget>[
                    MealoraChip(
                      icon: Icons.scanner_outlined,
                      label: product.provenance.sourceType == 'openfoodfacts'
                          ? text.packagedFoodReviewSourceOpenFoodFacts
                          : text.packagedFoodReviewSourceManual,
                      background: MealoraColors.iconFieldBlue,
                      foreground: MealoraColors.info,
                    ),
                    if (product.provenance.userCorrected)
                      MealoraChip(
                        icon: Icons.edit_outlined,
                        label: text.packagedFoodReviewCorrectedBadge,
                        background: MealoraColors.iconFieldGreen,
                        foreground: MealoraColors.primary,
                      ),
                  ],
                ),
                const SizedBox(height: MealoraSpacing.md),
                MealoraCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        product.food.name,
                        style: MealoraTypography.headline,
                      ),
                      if (_identityLine(product)
                          case final identity?) ...<Widget>[
                        const SizedBox(height: MealoraSpacing.xxs),
                        Text(identity, style: MealoraTypography.bodySmall),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: MealoraSpacing.md),
                Text(
                  text.servingDetailMealTimeLabel,
                  style: MealoraTypography.compactFieldLabel,
                ),
                const SizedBox(height: MealoraSpacing.xs),
                _MealTimeField(mealTime: _mealTime, onTap: _pickMealTime),
                const SizedBox(height: MealoraSpacing.lg),
                _NutritionCard(
                  heading: _isPerServing
                      ? text.packagedFoodReviewNutritionHeadingPerServing
                      : text.packagedFoodReviewNutritionHeadingPer100g,
                  nutrition: product.valuesAtRecordedBasis,
                  text: text,
                ),
                const SizedBox(height: MealoraSpacing.lg),
                Text(
                  text.packagedFoodReviewQuantityHeading,
                  style: MealoraTypography.compactFieldLabel,
                ),
                const SizedBox(height: MealoraSpacing.xs),
                if (_isPerServing)
                  _ServingQuantitySelector(
                    unitsPerPackage: product.unitsPerPackage,
                    wholePackage: _wholePackage,
                    servings: _servings,
                    onWholePackageToggled: (value) =>
                        setState(() => _wholePackage = value),
                    onServingsChanged: (value) =>
                        setState(() => _servings = value),
                    text: text,
                  )
                else
                  MealoraField(
                    label: text.packagedFoodReviewGramsLabel,
                    controller: _gramsController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    errorText: _quantityError,
                    onChanged: (_) {
                      if (_quantityError != null) {
                        setState(() => _quantityError = null);
                      } else {
                        setState(() {});
                      }
                    },
                  ),
                const SizedBox(height: MealoraSpacing.lg),
                _EstimateCard(estimate: total, text: text),
                const SizedBox(height: MealoraSpacing.md),
                Semantics(
                  button: true,
                  label: text.packagedFoodReviewCorrectionLink,
                  child: InkWell(
                    onTap: () => setState(() => _correcting = !_correcting),
                    child: Text(
                      text.packagedFoodReviewCorrectionLink,
                      style: MealoraTypography.bodyEmphasis.copyWith(
                        color: MealoraColors.primaryDeep,
                      ),
                    ),
                  ),
                ),
                if (_correcting) ...<Widget>[
                  const SizedBox(height: MealoraSpacing.sm),
                  _CorrectionFields(
                    energy: _energy,
                    protein: _protein,
                    carbohydrate: _carbohydrate,
                    fat: _fat,
                    text: text,
                    onChanged: () => setState(() {}),
                  ),
                ],
                const SizedBox(height: MealoraSpacing.md),
                Text(
                  text.packagedFoodReviewVerifiedOn(
                    IdFormat.shortDate(
                      LocalDate.fromLocalInstant(product.provenance.verifiedAt),
                    ),
                  ),
                  style: MealoraTypography.caption,
                ),
                const SizedBox(height: MealoraSpacing.xl),
                MealoraPrimaryButton(
                  label: text.packagedFoodReviewConfirmAction(
                    DiaryFormat.kcal(total?.energy, text),
                  ),
                  onPressed: _saving || total == null
                      ? null
                      : () => unawaited(_confirm(text)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// `null` ketika tidak ada merek, ukuran kemasan, maupun barcode untuk
  /// ditampilkan (change 010: produk tanpa barcode) — baris kedua kartu ini
  /// dilewati sepenuhnya, bukan dipaksa menampilkan sesuatu.
  String? _identityLine(PackagedFood product) {
    final parts = <String>[
      if (product.food.brand != null) product.food.brand!,
      if (product.packageSize != null) 'Kemasan ${product.packageSize}',
    ];
    if (parts.isNotEmpty) {
      return parts.join('  ·  ');
    }
    return product.barcode;
  }

  PackagedFoodQuantity? _currentQuantity() {
    if (_isPerServing) {
      if (_wholePackage) {
        return widget.product.unitsPerPackage == null
            ? null
            : const WholePackageEaten();
      }
      return _servings > 0 ? ServingsEaten(_servings) : null;
    }
    final grams = double.tryParse(
      _gramsController.text.trim().replaceAll(',', '.'),
    );
    return (grams != null && grams > 0) ? GramsEaten(grams) : null;
  }

  Future<void> _pickMealTime() async {
    final text = AppText.of(context);
    final picked = await showModalBottomSheet<MealTime>(
      context: context,
      builder: (context) => OptionSheet<MealTime>(
        title: text.mealTimePickerTitle,
        options: MealTime.values,
        labelOf: (m) => DiaryFormat.mealTimeLabel(m, text),
        selected: _mealTime,
      ),
    );
    if (picked != null) {
      setState(() => _mealTime = picked);
    }
  }

  Future<void> _confirm(AppText text) async {
    final quantity = _currentQuantity();
    if (quantity == null) {
      setState(() => _quantityError = text.barcodeManualInvalidError);
      return;
    }

    setState(() => _saving = true);

    final corrected = _applyCorrections(widget.product.valuesAtRecordedBasis);
    final isCorrected =
        widget.product.provenance.userCorrected || _hasEdits(corrected);
    final productToConfirm = _withNutrition(
      widget.product,
      corrected,
      isCorrected,
    );

    final result = await confirmAndLogPackagedFood(
      ref,
      product: productToConfirm,
      mealTime: _mealTime,
      quantity: quantity,
      date: widget.date,
    );

    if (!mounted) {
      return;
    }
    if (result is Err) {
      setState(() => _saving = false);
      return;
    }
    // Peringatan jelang tidur (change 013, task 4.3): hanya setelah Ok.
    final lateMealNotice = ref.read(lateMealNoticeProvider);
    final messenger = ScaffoldMessenger.of(context);
    final noticeText = AppText.of(context);
    Navigator.of(context).popUntil((route) => route.isFirst);
    unawaited(
      lateMealNotice.maybeShow(
        messenger: messenger,
        text: noticeText,
        date: widget.date,
      ),
    );
  }

  NutritionProfile _applyCorrections(NutritionProfile original) {
    double? parse(TextEditingController controller) {
      final trimmed = controller.text.trim();
      if (trimmed.isEmpty) {
        return null;
      }
      return double.tryParse(trimmed.replaceAll(',', '.'));
    }

    final energyValue = parse(_energy);
    return NutritionProfile(
      energy: energyValue == null
          ? null
          : Energy.kcalValue(energyValue, field: 'energy').valueOrNull,
      proteinG: parse(_protein),
      carbohydrateG: parse(_carbohydrate),
      fatG: parse(_fat),
      fiberG: original.fiberG,
      sugarG: original.sugarG,
      sodiumMg: original.sodiumMg,
    );
  }

  bool _hasEdits(NutritionProfile corrected) {
    final original = widget.product.valuesAtRecordedBasis;
    return corrected.energy?.kcal != original.energy?.kcal ||
        corrected.proteinG != original.proteinG ||
        corrected.carbohydrateG != original.carbohydrateG ||
        corrected.fatG != original.fatG;
  }

  /// Menyusun ulang [product] dengan [nutrition] sebagai nilai takaran
  /// bawaan — dipanggil pada setiap konfirmasi (bukan hanya saat benar-benar
  /// dikoreksi) karena nilainya selalu melewati koreksi yang mungkin kosong
  /// (task 7.4); [userCorrected] menang hanya ketika memang ada perubahan
  /// (Design D5).
  PackagedFood _withNutrition(
    PackagedFood product,
    NutritionProfile nutrition,
    bool userCorrected,
  ) {
    final serving = product.food.defaultServing;
    final correctedServing = ServingSize(
      id: serving.id,
      label: serving.label,
      amount: serving.amount,
      unit: serving.unit,
      gramEquivalent: serving.gramEquivalent,
      isDefault: serving.isDefault,
      nutrition: nutrition,
    );
    final correctedFood = Food(
      id: product.food.id,
      name: product.food.name,
      brand: product.food.brand,
      category: product.food.category,
      isUserCreated: product.food.isUserCreated,
      provenance: product.food.provenance,
      servings: <ServingSize>[correctedServing],
    );
    return PackagedFood(
      food: correctedFood,
      barcode: product.barcode,
      packageSize: product.packageSize,
      unitsPerPackage: product.unitsPerPackage,
      servingBasis: product.servingBasis,
      provenance: PackagedFoodProvenance(
        sourceType: product.provenance.sourceType,
        sourceRef: product.provenance.sourceRef,
        sourceVersion: product.provenance.sourceVersion,
        verifiedAt: product.provenance.verifiedAt,
        userCorrected: userCorrected,
      ),
    );
  }
}

class _MealTimeField extends StatelessWidget {
  const _MealTimeField({required this.mealTime, required this.onTap});

  final MealTime mealTime;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final label = DiaryFormat.mealTimeLabel(mealTime, text);
    return Semantics(
      button: true,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(MealoraRadius.button),
        onTap: onTap,
        child: MealoraCard(
          radius: MealoraRadius.button,
          padding: const EdgeInsets.symmetric(
            horizontal: MealoraSpacing.md,
            vertical: MealoraSpacing.sm,
          ),
          child: Row(
            children: <Widget>[
              Expanded(
                child: Text(label, style: MealoraTypography.bodyEmphasis),
              ),
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

/// Kartu nilai gizi PADA BASIS REKAMAN (bukan sudah dikalikan jumlah) —
/// spec, "Basis ditampilkan kepada pengguna": basis yang berlaku tampil
/// bersama angkanya sebelum pengguna memilih jumlah (task 7.2).
class _NutritionCard extends StatelessWidget {
  const _NutritionCard({
    required this.heading,
    required this.nutrition,
    required this.text,
  });

  final String heading;
  final NutritionProfile nutrition;
  final AppText text;

  @override
  Widget build(BuildContext context) {
    final secondaryParts = <String>[
      if (nutrition.fiberG != null)
        '${text.nutrientFiber} ${DiaryFormat.grams(nutrition.fiberG, text)}',
      if (nutrition.sugarG != null)
        '${text.nutrientSugar} ${DiaryFormat.grams(nutrition.sugarG, text)}',
      if (nutrition.sodiumMg != null)
        '${text.nutrientSodium} ${IdFormat.integer(nutrition.sodiumMg!)} '
            '${text.unitMilligram}',
    ];

    return MealoraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(heading, style: MealoraTypography.headline),
          const SizedBox(height: MealoraSpacing.sm),
          Row(
            children: <Widget>[
              Expanded(
                child: _MacroTile(
                  label: text.nutrientEnergy,
                  value: DiaryFormat.kcal(nutrition.energy, text),
                  background: MealoraColors.iconFieldAmber,
                  foreground: MealoraColors.amberText,
                ),
              ),
              const SizedBox(width: MealoraSpacing.sm),
              Expanded(
                child: _MacroTile(
                  label: text.nutrientProtein,
                  value: DiaryFormat.grams(nutrition.proteinG, text),
                  background: MealoraColors.iconFieldGreen,
                  foreground: MealoraColors.primaryDeep,
                ),
              ),
            ],
          ),
          const SizedBox(height: MealoraSpacing.sm),
          Row(
            children: <Widget>[
              Expanded(
                child: _MacroTile(
                  label: text.nutrientCarbohydrate,
                  value: DiaryFormat.grams(nutrition.carbohydrateG, text),
                  background: MealoraColors.iconFieldAmber,
                  foreground: MealoraColors.amberText,
                ),
              ),
              const SizedBox(width: MealoraSpacing.sm),
              Expanded(
                child: _MacroTile(
                  label: text.nutrientFat,
                  value: DiaryFormat.grams(nutrition.fatG, text),
                  background: MealoraColors.iconFieldCoral,
                  foreground: MealoraColors.coralText,
                ),
              ),
            ],
          ),
          if (secondaryParts.isNotEmpty) ...<Widget>[
            const SizedBox(height: MealoraSpacing.sm),
            Text(
              secondaryParts.join('  ·  '),
              style: MealoraTypography.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _MacroTile extends StatelessWidget {
  const _MacroTile({
    required this.label,
    required this.value,
    required this.background,
    required this.foreground,
  });

  final String label;
  final String value;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 58),
      padding: const EdgeInsets.symmetric(
        horizontal: MealoraSpacing.sm,
        vertical: MealoraSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(MealoraRadius.choiceCard),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label, style: MealoraTypography.caption),
          Text(
            value,
            style: MealoraTypography.bodyEmphasis.copyWith(color: foreground),
          ),
        ],
      ),
    );
  }
}

/// Pemilih jumlah untuk basis per sajian (task 7.3): dua pil "N sajian" /
/// "1 kemasan" (spec, "Satu kemasan berisi dua sajian") bila
/// `unitsPerPackage` diketahui, ditambah penghitung sajian saat "N sajian"
/// dipilih.
class _ServingQuantitySelector extends StatelessWidget {
  const _ServingQuantitySelector({
    required this.unitsPerPackage,
    required this.wholePackage,
    required this.servings,
    required this.onWholePackageToggled,
    required this.onServingsChanged,
    required this.text,
  });

  final double? unitsPerPackage;
  final bool wholePackage;
  final double servings;
  final ValueChanged<bool> onWholePackageToggled;
  final ValueChanged<double> onServingsChanged;
  final AppText text;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        if (unitsPerPackage != null)
          Container(
            padding: const EdgeInsets.all(MealoraSpacing.xxs),
            decoration: BoxDecoration(
              color: MealoraColors.glassCard,
              borderRadius: BorderRadius.circular(MealoraRadius.button),
              border: Border.all(color: MealoraColors.glassBorder),
            ),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: _SelectorPill(
                    label: text.packagedFoodReviewServingsOption(
                      IdFormat.decimal(servings),
                    ),
                    selected: !wholePackage,
                    onTap: () => onWholePackageToggled(false),
                  ),
                ),
                const SizedBox(width: MealoraSpacing.xxs),
                Expanded(
                  child: _SelectorPill(
                    label: text.packagedFoodReviewWholePackageOption(
                      IdFormat.decimal(unitsPerPackage!),
                    ),
                    selected: wholePackage,
                    onTap: () => onWholePackageToggled(true),
                  ),
                ),
              ],
            ),
          ),
        if (!wholePackage || unitsPerPackage == null) ...<Widget>[
          const SizedBox(height: MealoraSpacing.sm),
          _QuantityStepper(quantity: servings, onChanged: onServingsChanged),
        ],
      ],
    );
  }
}

class _SelectorPill extends StatelessWidget {
  const _SelectorPill({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        borderRadius: BorderRadius.circular(MealoraRadius.iconField),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 44),
          padding: const EdgeInsets.symmetric(vertical: MealoraSpacing.xxs),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: MealoraColors.ctaGradient,
                  )
                : null,
            borderRadius: BorderRadius.circular(MealoraRadius.iconField),
          ),
          child: Text(
            label,
            style: MealoraTypography.bodyEmphasis.copyWith(
              color: selected ? MealoraColors.onPrimary : MealoraColors.muted,
            ),
          ),
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({required this.quantity, required this.onChanged});

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
          _StepButton(
            icon: Icons.remove,
            semanticsLabel: text.quantityDecreaseSemantics,
            onTap: quantity > 0.5
                ? () => onChanged((quantity - 0.5).clamp(0.5, 99))
                : null,
          ),
          Text(
            quantity.toStringAsFixed(1).replaceAll('.', ','),
            style: MealoraTypography.headline,
          ),
          _StepButton(
            icon: Icons.add,
            semanticsLabel: text.quantityIncreaseSemantics,
            onTap: () => onChanged((quantity + 0.5).clamp(0.5, 99)),
          ),
        ],
      ),
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({
    required this.icon,
    required this.semanticsLabel,
    required this.onTap,
  });

  final IconData icon;
  final String semanticsLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: InkWell(
        borderRadius: BorderRadius.circular(MealoraRadius.compactIconField),
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: MealoraColors.iconFieldGreen,
            borderRadius: BorderRadius.circular(MealoraRadius.compactIconField),
          ),
          child: Icon(icon, color: MealoraColors.primary),
        ),
      ),
    );
  }
}

class _EstimateCard extends StatelessWidget {
  const _EstimateCard({required this.estimate, required this.text});

  final NutritionProfile? estimate;
  final AppText text;

  @override
  Widget build(BuildContext context) {
    return MealoraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(text.servingDetailEstimateLabel, style: MealoraTypography.label),
          const SizedBox(height: MealoraSpacing.xs),
          Text(
            DiaryFormat.kcal(estimate?.energy, text),
            style: MealoraTypography.headline.copyWith(
              color: MealoraColors.primary,
            ),
          ),
          const SizedBox(height: MealoraSpacing.xxs),
          Text(
            text.macroMacrosShort(
              DiaryFormat.grams(estimate?.proteinG, text),
              DiaryFormat.grams(estimate?.carbohydrateG, text),
              DiaryFormat.grams(estimate?.fatG, text),
            ),
            style: MealoraTypography.bodySmall,
          ),
        ],
      ),
    );
  }
}

/// Kolom koreksi empat zat gizi utama (task 7.4) — pola sama dengan
/// `CustomFoodScreen` (change 007): diisi kosong berarti tidak dikoreksi,
/// bukan 0.
class _CorrectionFields extends StatelessWidget {
  const _CorrectionFields({
    required this.energy,
    required this.protein,
    required this.carbohydrate,
    required this.fat,
    required this.text,
    required this.onChanged,
  });

  final TextEditingController energy;
  final TextEditingController protein;
  final TextEditingController carbohydrate;
  final TextEditingController fat;
  final AppText text;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: MealoraField(
                label: '${text.nutrientEnergy} (${text.unitKilocalorie})',
                controller: energy,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) => onChanged(),
              ),
            ),
            const SizedBox(width: MealoraSpacing.sm),
            Expanded(
              child: MealoraField(
                label: '${text.nutrientProtein} (${text.unitGram})',
                controller: protein,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) => onChanged(),
              ),
            ),
          ],
        ),
        const SizedBox(height: MealoraSpacing.sm),
        Row(
          children: <Widget>[
            Expanded(
              child: MealoraField(
                label: '${text.nutrientCarbohydrate} (${text.unitGram})',
                controller: carbohydrate,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) => onChanged(),
              ),
            ),
            const SizedBox(width: MealoraSpacing.sm),
            Expanded(
              child: MealoraField(
                label: '${text.nutrientFat} (${text.unitGram})',
                controller: fat,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                onChanged: (_) => onChanged(),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
