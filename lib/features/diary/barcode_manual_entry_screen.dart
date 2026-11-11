import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/domain/packaged_food/barcode_format.dart';
import 'package:mealora/features/diary/packaged_food_not_found_screen.dart';
import 'package:mealora/features/diary/packaged_food_providers.dart';
import 'package:mealora/features/diary/packaged_food_review_screen.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// `21b · Masukkan barcode manual` (task 1.3/6.2, change 009) — satu-satunya
/// jalur barcode yang bekerja ketika izin kamera ditolak, kamera tidak ada,
/// atau kode pada kemasan sudah lecek (design.md D6). Jalur lanjutan
/// setelah pencarian SAMA dengan hasil pemindaian kamera: layar tinjau
/// (`04`) bila ditemukan, atau produk tidak ditemukan (`22`) bila tidak.
class BarcodeManualEntryScreen extends ConsumerStatefulWidget {
  const BarcodeManualEntryScreen({this.date, super.key});

  /// Tanggal yang akan dicatat — `null` berarti hari ini.
  final LocalDate? date;

  @override
  ConsumerState<BarcodeManualEntryScreen> createState() =>
      _BarcodeManualEntryScreenState();
}

class _BarcodeManualEntryScreenState
    extends ConsumerState<BarcodeManualEntryScreen> {
  final _barcode = TextEditingController();
  String? _error;
  bool _searching = false;

  @override
  void dispose() {
    _barcode.dispose();
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
                MealoraBackEyebrow(label: text.barcodeManualContextLabel),
                const SizedBox(height: MealoraSpacing.xs),
                Text(text.barcodeManualTitle, style: MealoraTypography.title),
                const SizedBox(height: MealoraSpacing.xxs),
                Text(
                  text.barcodeManualSubtitle,
                  style: MealoraTypography.subtitle,
                ),
                const SizedBox(height: MealoraSpacing.lg),
                MealoraField(
                  label: text.barcodeManualFieldLabel,
                  hint: text.barcodeManualFieldHint,
                  controller: _barcode,
                  keyboardType: TextInputType.number,
                  errorText: _error,
                  onChanged: (_) {
                    if (_error != null) {
                      setState(() => _error = null);
                    }
                  },
                ),
                const SizedBox(height: MealoraSpacing.xxs),
                Text(
                  text.barcodeManualHelper,
                  style: MealoraTypography.caption,
                ),
                const SizedBox(height: MealoraSpacing.lg),
                MealoraNoteCard(
                  icon: Icons.offline_bolt_outlined,
                  title: text.barcodeManualNoteTitle,
                  body: text.barcodeManualNoteBody,
                ),
                const SizedBox(height: MealoraSpacing.xl),
                MealoraPrimaryButton(
                  label: text.barcodeManualSearchAction,
                  onPressed: _searching ? null : _search,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _search() async {
    final raw = _barcode.text.trim();
    if (!isValidBarcodeFormat(raw)) {
      setState(() => _error = AppText.of(context).barcodeManualInvalidError);
      return;
    }

    setState(() {
      _error = null;
      _searching = true;
    });

    final product = await lookupPackagedFoodByBarcode(ref, raw);
    if (!mounted) {
      return;
    }

    if (product != null) {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (_) =>
              PackagedFoodReviewScreen(product: product, date: widget.date),
        ),
      );
      return;
    }
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) =>
            PackagedFoodNotFoundScreen(barcode: raw, date: widget.date),
      ),
    );
  }
}
