import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/errors/failure.dart';
import 'package:mealora/core/errors/result.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/core/validation/value_rules.dart';
import 'package:mealora/domain/food/food.dart';
import 'package:mealora/domain/food/food_category.dart';
import 'package:mealora/domain/food/nutrition_profile.dart';
import 'package:mealora/domain/food/serving_size.dart';
import 'package:mealora/domain/packaged_food/packaged_food.dart';
import 'package:mealora/domain/packaged_food/packaged_food_provenance.dart';
import 'package:mealora/domain/packaged_food/serving_basis.dart';
import 'package:mealora/domain/shared/units.dart';
import 'package:mealora/features/diary/option_sheet.dart';
import 'package:mealora/features/diary/packaged_food_review_screen.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// `37 · Isi label manual offline` (task 6.2/6.3 jalur lanjutan, change
/// 009): mengisi nilai label secara manual ketika produk tidak ditemukan,
/// tersedia sepenuhnya luring (spec, "Produk tidak ditemukan menawarkan
/// jalur lanjutan").
///
/// Hanya empat zat gizi utama yang diisi — sama seperti `15 · Makanan
/// buatan sendiri` (change 007, `CustomFoodScreen`): serat/gula/natrium
/// tetap boleh kosong, bukan dikarang nol.
class PackagedFoodManualFillScreen extends ConsumerStatefulWidget {
  const PackagedFoodManualFillScreen({this.barcode, this.date, super.key});

  /// `null` ketika dibuka langsung dari layar pindai atau layar foto label
  /// tanpa barcode (change 010) — produk tersimpan tanpa barcode, hanya
  /// ditemukan kembali lewat pencarian nama.
  final String? barcode;
  final LocalDate? date;

  @override
  ConsumerState<PackagedFoodManualFillScreen> createState() =>
      _PackagedFoodManualFillScreenState();
}

class _PackagedFoodManualFillScreenState
    extends ConsumerState<PackagedFoodManualFillScreen> {
  final _name = TextEditingController();
  final _brand = TextEditingController();
  final _packageSize = TextEditingController();
  final _servingGrams = TextEditingController();
  final _unitsPerPackage = TextEditingController();
  final _energy = TextEditingController();
  final _protein = TextEditingController();
  final _carbohydrate = TextEditingController();
  final _fat = TextEditingController();

  ServingBasis _basis = ServingBasis.perServing;
  String? _error;

  @override
  void dispose() {
    _name.dispose();
    _brand.dispose();
    _packageSize.dispose();
    _servingGrams.dispose();
    _unitsPerPackage.dispose();
    _energy.dispose();
    _protein.dispose();
    _carbohydrate.dispose();
    _fat.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);

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
                MealoraBackEyebrow(label: text.packagedFoodFillContextLabel),
                const SizedBox(height: MealoraSpacing.xs),
                Text(
                  text.packagedFoodFillTitle,
                  style: MealoraTypography.title,
                ),
                const SizedBox(height: MealoraSpacing.xxs),
                Text(
                  text.packagedFoodFillSubtitle,
                  style: MealoraTypography.subtitle,
                ),
                const SizedBox(height: MealoraSpacing.lg),
                _BasisField(
                  label: text.packagedFoodFillBasisLabel,
                  value: _basisLabel(_basis, text),
                  onTap: _pickBasis,
                ),
                const SizedBox(height: MealoraSpacing.md),
                MealoraField(
                  label: text.packagedFoodFillNameLabel,
                  hint: text.packagedFoodFillNameHint,
                  controller: _name,
                ),
                const SizedBox(height: MealoraSpacing.md),
                MealoraField(
                  label: text.packagedFoodFillBrandLabel,
                  hint: text.packagedFoodFillBrandHint,
                  controller: _brand,
                ),
                const SizedBox(height: MealoraSpacing.md),
                MealoraField(
                  label: text.packagedFoodFillPackageSizeLabel,
                  hint: text.packagedFoodFillPackageSizeHint,
                  controller: _packageSize,
                ),
                if (_basis == ServingBasis.perServing) ...<Widget>[
                  const SizedBox(height: MealoraSpacing.md),
                  MealoraField(
                    label: text.customFoodServingLabel,
                    hint: text.customFoodServingHint,
                    controller: _servingGrams,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: MealoraSpacing.md),
                  MealoraField(
                    label: text.packagedFoodFillUnitsPerPackageLabel,
                    hint: text.packagedFoodFillUnitsPerPackageHint,
                    controller: _unitsPerPackage,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  if (_packageArithmeticNote(text)
                      case final note?) ...<Widget>[
                    const SizedBox(height: MealoraSpacing.xs),
                    Text(note, style: MealoraTypography.caption),
                  ],
                ],
                const SizedBox(height: MealoraSpacing.lg),
                Text(
                  _basis == ServingBasis.perServing
                      ? text.customFoodNutritionHeading
                      : text.packagedFoodReviewNutritionHeadingPer100g,
                  style: MealoraTypography.headline,
                ),
                const SizedBox(height: MealoraSpacing.sm),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _NutrientField(
                        label: text.nutrientEnergy,
                        unit: text.unitKilocalorie,
                        controller: _energy,
                        accent: MealoraColors.amberText,
                        background: MealoraColors.iconFieldAmber,
                      ),
                    ),
                    const SizedBox(width: MealoraSpacing.sm),
                    Expanded(
                      child: _NutrientField(
                        label: text.nutrientProtein,
                        unit: text.unitGram,
                        controller: _protein,
                        accent: MealoraColors.primary,
                        background: MealoraColors.iconFieldGreen,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: MealoraSpacing.sm),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _NutrientField(
                        label: text.nutrientCarbohydrate,
                        unit: text.unitGram,
                        controller: _carbohydrate,
                        accent: MealoraColors.amberText,
                        background: MealoraColors.iconFieldAmber,
                      ),
                    ),
                    const SizedBox(width: MealoraSpacing.sm),
                    Expanded(
                      child: _NutrientField(
                        label: text.nutrientFat,
                        unit: text.unitGram,
                        controller: _fat,
                        accent: MealoraColors.coralText,
                        background: MealoraColors.iconFieldCoral,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: MealoraSpacing.lg),
                MealoraNoteCard(
                  icon: Icons.info_outline,
                  body: text.customFoodNote,
                  borderColor: MealoraColors.glassSoft,
                ),
                if (_error != null) ...<Widget>[
                  const SizedBox(height: MealoraSpacing.sm),
                  Semantics(
                    liveRegion: true,
                    child: Text(
                      _error!,
                      style: MealoraTypography.caption.copyWith(
                        color: MealoraColors.danger,
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: MealoraSpacing.xl),
                MealoraPrimaryButton(
                  label: text.packagedFoodFillContinueAction,
                  onPressed: () => unawaited(_continue(text)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _basisLabel(ServingBasis basis, AppText text) => switch (basis) {
    ServingBasis.perServing => text.packagedFoodFillBasisPerServing,
    ServingBasis.perHundredGrams => text.packagedFoodFillBasisPer100g,
  };

  /// Pengingat aritmetika kemasan (task 8.2, spec "Pengingat aritmetika
  /// kemasan") — `null` sampai ukuran sajian DAN jumlah sajian per kemasan
  /// sama-sama terisi, persis syarat yang sama dengan layar tinjau
  /// ekstraksi (`24`), memakai string bersama.
  String? _packageArithmeticNote(AppText text) {
    final servingGrams = double.tryParse(
      _servingGrams.text.trim().replaceAll(',', '.'),
    );
    final unitsPerPackage = double.tryParse(
      _unitsPerPackage.text.trim().replaceAll(',', '.'),
    );
    if (servingGrams == null || unitsPerPackage == null) {
      return null;
    }
    return text.labelReviewPackageArithmeticNote(
      IdFormatHelpers.trimTrailingZero(unitsPerPackage),
      '${IdFormatHelpers.trimTrailingZero(servingGrams)} ${text.unitGram}',
    );
  }

  Future<void> _pickBasis() async {
    final picked = await showModalBottomSheet<ServingBasis>(
      context: context,
      builder: (context) => OptionSheet<ServingBasis>(
        title: AppText.of(context).packagedFoodFillBasisLabel,
        options: ServingBasis.values,
        labelOf: (b) => _basisLabel(b, AppText.of(context)),
        selected: _basis,
      ),
    );
    if (picked != null) {
      setState(() => _basis = picked);
    }
  }

  Future<void> _continue(AppText text) async {
    final name = ValueRules.requiredText(_name.text, field: 'name');
    final servingGrams = _basis == ServingBasis.perServing
        ? _parsePositive(_servingGrams.text, field: 'servingGrams')
        : const Ok<double?>(null);
    final unitsPerPackage = _basis == ServingBasis.perServing
        ? _parsePositive(_unitsPerPackage.text, field: 'unitsPerPackage')
        : const Ok<double?>(null);
    final energy = _parseNutrient(_energy.text, field: 'energy');
    final protein = _parseNutrient(_protein.text, field: 'protein');
    final carbohydrate = _parseNutrient(
      _carbohydrate.text,
      field: 'carbohydrate',
    );
    final fat = _parseNutrient(_fat.text, field: 'fat');

    final failure = <Result<Object?>>[
      name,
      servingGrams,
      unitsPerPackage,
      energy,
      protein,
      carbohydrate,
      fat,
    ].whereType<Err<Object?>>().firstOrNull;

    if (failure != null) {
      setState(() => _error = _messageFor(failure.failure, text));
      return;
    }
    setState(() => _error = null);

    final isPerServing = _basis == ServingBasis.perServing;
    final energyValue = energy.valueOrNull;
    final nutrition = NutritionProfile(
      energy: energyValue == null
          ? null
          : Energy.kcalValue(energyValue, field: 'energy').valueOrNull,
      proteinG: protein.valueOrNull,
      carbohydrateG: carbohydrate.valueOrNull,
      fatG: fat.valueOrNull,
    );

    final gramsPerServing = servingGrams.valueOrNull;
    final product = PackagedFood(
      food: Food(
        id: 'pending-manual-food',
        name: name.valueOrNull!,
        brand: _brand.text.trim().isEmpty ? null : _brand.text.trim(),
        category: FoodCategory.other,
        isUserCreated: true,
        servings: <ServingSize>[
          ServingSize(
            id: 'pending-manual-serving',
            label: isPerServing
                ? (gramsPerServing == null
                      ? '1 sajian'
                      : '${IdFormatHelpers.trimTrailingZero(gramsPerServing)} g · 1 sajian')
                : '100 g',
            amount: isPerServing ? 1 : 100,
            unit: isPerServing ? 'sajian' : 'g',
            gramEquivalent: isPerServing ? gramsPerServing : 100,
            isDefault: true,
            nutrition: nutrition,
          ),
        ],
      ),
      barcode: widget.barcode,
      packageSize: _packageSize.text.trim().isEmpty
          ? null
          : _packageSize.text.trim(),
      unitsPerPackage: unitsPerPackage.valueOrNull,
      servingBasis: _basis,
      provenance: PackagedFoodProvenance(
        sourceType: 'user_manual',
        verifiedAt: ref.read(clockProvider).nowUtc(),
        userCorrected: false,
      ),
    );

    if (!mounted) {
      return;
    }
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) =>
            PackagedFoodReviewScreen(product: product, date: widget.date),
      ),
    );
  }

  Result<double?> _parsePositive(String raw, {required String field}) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return const Ok<double?>(null);
    }
    final parsed = double.tryParse(trimmed.replaceAll(',', '.'));
    if (parsed == null) {
      return Err<double?>(
        Failure(FailureCode.invalidValue, field: field, detail: 'bukan angka'),
      );
    }
    final checked = ValueRules.positiveAmount(parsed, field: field);
    return checked.map<double?>((v) => v);
  }

  Result<double?> _parseNutrient(String raw, {required String field}) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return const Ok<double?>(null);
    }
    final parsed = double.tryParse(trimmed.replaceAll(',', '.'));
    if (parsed == null) {
      return Err<double?>(
        Failure(FailureCode.invalidValue, field: field, detail: 'bukan angka'),
      );
    }
    return ValueRules.nutrientValue(parsed, field: field);
  }

  String _messageFor(Failure failure, AppText text) {
    if (failure.field == 'name') {
      return text.packagedFoodFillNameRequiredError;
    }
    return text.packagedFoodFillInvalidNumberError;
  }
}

/// Pembantu format kecil khusus berkas ini: menghindari `.0` pada label
/// gram bulat (mis. "30 g", bukan "30.0 g") tanpa menambah ketergantungan
/// pada `IdFormat` locale untuk nilai yang sumbernya input pengguna sendiri.
abstract final class IdFormatHelpers {
  static String trimTrailingZero(double value) => value == value.roundToDouble()
      ? value.toStringAsFixed(0)
      : value.toString();
}

class _BasisField extends StatelessWidget {
  const _BasisField({
    required this.label,
    required this.value,
    required this.onTap,
  });

  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(left: 2),
          child: Text(label, style: MealoraTypography.label),
        ),
        const SizedBox(height: MealoraSpacing.xxs),
        Semantics(
          button: true,
          label: '$label. $value',
          child: InkWell(
            borderRadius: BorderRadius.circular(MealoraRadius.button),
            onTap: onTap,
            child: MealoraCard(
              radius: MealoraRadius.button,
              padding: const EdgeInsets.symmetric(
                horizontal: MealoraSpacing.md,
                vertical: MealoraSpacing.md,
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(value, style: MealoraTypography.bodyEmphasis),
                  ),
                  const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: MealoraColors.affordance,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NutrientField extends StatelessWidget {
  const _NutrientField({
    required this.label,
    required this.unit,
    required this.controller,
    required this.accent,
    required this.background,
  });

  final String label;
  final String unit;
  final TextEditingController controller;
  final Color accent;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return MealoraCard(
      radius: MealoraRadius.choiceCard,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(label, style: MealoraTypography.label),
          const SizedBox(height: 3),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (context, value, _) {
              final inputWidth = (value.text.length * 12.0 + 8)
                  .clamp(24.0, 72.0)
                  .toDouble();
              return Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: <Widget>[
                  SizedBox(
                    width: inputWidth,
                    child: TextField(
                      controller: controller,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      style: MealoraTypography.nutrientFieldValue.copyWith(
                        color: accent,
                      ),
                      decoration: const InputDecoration(
                        filled: false,
                        fillColor: MealoraColors.transparent,
                        isDense: true,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        focusedErrorBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 2, left: 4),
                    child: Text(
                      unit,
                      style: MealoraTypography.bodySmall.copyWith(
                        color: accent,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 5),
          Container(
            width: 28,
            height: 4,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(MealoraRadius.track),
            ),
          ),
        ],
      ),
    );
  }
}
