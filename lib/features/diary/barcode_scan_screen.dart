import 'dart:async';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/domain/packaged_food/barcode_format.dart';
import 'package:mealora/features/diary/barcode_manual_entry_screen.dart';
import 'package:mealora/features/diary/food_search_screen.dart';
import 'package:mealora/features/diary/packaged_food_not_found_screen.dart';
import 'package:mealora/features/diary/packaged_food_providers.dart';
import 'package:mealora/features/diary/packaged_food_review_screen.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// `21 · Pindai barcode` (task 6.1, change 009): bingkai pemindaian,
/// keterangan bahwa produk tersimpan dapat dicari luring, dan penegasan
/// bahwa barcode bukan sumber nilai gizi (spec, "Barcode adalah pengenal
/// produk, bukan sumber nilai gizi").
///
/// Izin kamera baru diminta setelah pengguna menekan "Gunakan kamera" pada
/// layar ini (Screen 21, Design D7, task 5.2), bukan saat layar dibuka.
class BarcodeScanScreen extends ConsumerStatefulWidget {
  const BarcodeScanScreen({this.date, super.key});

  /// Tanggal yang akan dicatat — `null` berarti hari ini (konvensi
  /// `logFoodEntry`, change 008).
  final LocalDate? date;

  @override
  ConsumerState<BarcodeScanScreen> createState() => _BarcodeScanScreenState();
}

class _BarcodeScanScreenState extends ConsumerState<BarcodeScanScreen> {
  MobileScannerController? _controller;
  bool _cameraRequested = false;
  bool _handled = false;
  bool _looking = false;
  bool _showSlowHint = false;
  Timer? _slowHintTimer;

  @override
  void dispose() {
    _slowHintTimer?.cancel();
    _controller?.dispose();
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
                MealoraBackEyebrow(label: text.barcodeScanContextLabel),
                const SizedBox(height: MealoraSpacing.xs),
                Text(text.barcodeScanTitle, style: MealoraTypography.title),
                const SizedBox(height: MealoraSpacing.xxs),
                Text(
                  text.barcodeScanSubtitle,
                  style: MealoraTypography.subtitle,
                ),
                const SizedBox(height: MealoraSpacing.lg),
                if (!_cameraRequested)
                  _ScannerPreview(hint: text.barcodeScanHint)
                else if (_controller == null)
                  _UnavailableState(
                    title: text.barcodeScanUnavailableTitle,
                    body: text.barcodeScanUnavailableBody,
                    onManualEntry: _openManualEntry,
                    onSearchCatalog: _openCatalogSearch,
                  )
                else
                  _ScannerViewport(
                    controller: _controller!,
                    hint: text.barcodeScanHint,
                    looking: _looking,
                    loadingLabel: text.barcodeScanLookupInProgress,
                    onDetect: _onDetect,
                    onPermissionDenied: () => setState(() {
                      _controller?.dispose();
                      _controller = null;
                    }),
                    buildUnavailable: (error) => _UnavailableFor(
                      error: error,
                      text: text,
                      onManualEntry: _openManualEntry,
                      onSearchCatalog: _openCatalogSearch,
                    ),
                  ),
                const SizedBox(height: MealoraSpacing.md),
                MealoraNoteCard(
                  icon: Icons.shield_outlined,
                  title: text.barcodeScanNoteTitle,
                  body: text.barcodeScanNoteBody,
                ),
                if (_showSlowHint) ...<Widget>[
                  const SizedBox(height: MealoraSpacing.sm),
                  MealoraNoteCard(
                    icon: Icons.keyboard_outlined,
                    body: text.barcodeScanSlowHint,
                    background: MealoraColors.iconFieldAmber,
                    foreground: MealoraColors.amberText,
                    onTap: _openManualEntry,
                    semanticsLabel: text.barcodeScanSlowHint,
                  ),
                ],
                const SizedBox(height: MealoraSpacing.md),
                Semantics(
                  button: true,
                  link: true,
                  label: text.barcodeScanManualLink,
                  child: InkWell(
                    onTap: _openManualEntry,
                    child: Text(
                      '${text.barcodeScanManualLink} →',
                      style: MealoraTypography.bodyEmphasis.copyWith(
                        color: MealoraColors.primaryDeep,
                      ),
                    ),
                  ),
                ),
                if (!_cameraRequested) ...<Widget>[
                  const SizedBox(height: MealoraSpacing.xl),
                  MealoraPrimaryButton(
                    label: text.barcodeScanUseCamera,
                    onPressed: _startCamera,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _startCamera() {
    if (_cameraRequested) {
      return;
    }
    if (kIsWeb) {
      setState(() => _cameraRequested = true);
      return;
    }
    setState(() {
      _cameraRequested = true;
      _controller = MobileScannerController(
        formats: const <BarcodeFormat>[
          BarcodeFormat.ean13,
          BarcodeFormat.ean8,
          BarcodeFormat.upcA,
          BarcodeFormat.upcE,
        ],
      );
    });
    _slowHintTimer = Timer(const Duration(seconds: 8), () {
      if (mounted && !_handled) {
        setState(() => _showSlowHint = true);
      }
    });
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_handled) {
      return;
    }
    final raw = capture.barcodes
        .map((b) => b.rawValue)
        .whereType<String>()
        .firstOrNull;
    if (raw == null || !isValidBarcodeFormat(raw)) {
      return;
    }
    _handled = true;
    _slowHintTimer?.cancel();
    await _lookupAndNavigate(raw);
  }

  Future<void> _lookupAndNavigate(String barcode) async {
    setState(() => _looking = true);
    final product = await lookupPackagedFoodByBarcode(ref, barcode);
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
            PackagedFoodNotFoundScreen(barcode: barcode, date: widget.date),
      ),
    );
  }

  void _openManualEntry() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BarcodeManualEntryScreen(date: widget.date),
      ),
    );
  }

  void _openCatalogSearch() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => FoodSearchScreen(date: widget.date),
      ),
    );
  }
}

class _ScannerViewport extends StatelessWidget {
  const _ScannerViewport({
    required this.controller,
    required this.hint,
    required this.looking,
    required this.loadingLabel,
    required this.onDetect,
    required this.onPermissionDenied,
    required this.buildUnavailable,
  });

  final MobileScannerController controller;
  final String hint;
  final bool looking;
  final String loadingLabel;
  final void Function(BarcodeCapture) onDetect;
  final VoidCallback onPermissionDenied;
  final Widget Function(MobileScannerException) buildUnavailable;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(MealoraRadius.welcomeCard),
      child: SizedBox(
        height: 260,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            MobileScanner(
              controller: controller,
              onDetect: looking ? (_) {} : onDetect,
              errorBuilder: (context, error) {
                if (error.errorCode ==
                    MobileScannerErrorCode.permissionDenied) {
                  // Jalur gagal (penolakan izin) diproses sekali, bukan
                  // diam-diam dicoba ulang setiap build (task 5.3).
                  WidgetsBinding.instance.addPostFrameCallback(
                    (_) => onPermissionDenied(),
                  );
                }
                return buildUnavailable(error);
              },
            ),
            const Positioned.fill(
              child: CustomPaint(painter: _ScannerScrimPainter()),
            ),
            _ScannerOverlay(hint: looking ? loadingLabel : hint, animate: true),
          ],
        ),
      ),
    );
  }
}

class _ScannerScrimPainter extends CustomPainter {
  const _ScannerScrimPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final outer = Path()..addRect(Offset.zero & size);
    final scanWindow = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(size.width / 2, (size.height / 2) + 6),
        width: 250,
        height: 120,
      ),
      const Radius.circular(MealoraRadius.chip),
    );
    final cutout = Path()..addRRect(scanWindow);
    final scrim = Path.combine(PathOperation.difference, outer, cutout);
    canvas.drawPath(scrim, Paint()..color = MealoraColors.barcodeScannerScrim);
  }

  @override
  bool shouldRepaint(covariant _ScannerScrimPainter oldDelegate) => false;
}

class _ScannerPreview extends StatelessWidget {
  const _ScannerPreview({required this.hint});

  final String hint;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 260,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: MealoraColors.barcodeScannerGradient,
        ),
        border: Border.all(color: MealoraColors.barcodeScannerBorder),
        borderRadius: BorderRadius.circular(MealoraRadius.welcomeCard),
      ),
      child: _ScannerOverlay(hint: hint),
    );
  }
}

class _ScannerOverlay extends StatefulWidget {
  const _ScannerOverlay({required this.hint, this.animate = false});

  final String hint;
  final bool animate;

  @override
  State<_ScannerOverlay> createState() => _ScannerOverlayState();
}

class _ScannerOverlayState extends State<_ScannerOverlay>
    with SingleTickerProviderStateMixin {
  late final AnimationController _scanController;

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    if (widget.animate) {
      _scanController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant _ScannerOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.animate == oldWidget.animate) {
      return;
    }
    if (widget.animate) {
      _scanController.repeat(reverse: true);
    } else {
      _scanController
        ..stop()
        ..value = 0.5;
    }
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Icon(
              Icons.document_scanner_outlined,
              size: 32,
              color: MealoraColors.lime,
            ),
            const SizedBox(height: MealoraSpacing.lg),
            Container(
              width: 250,
              height: 120,
              decoration: BoxDecoration(
                color: MealoraColors.barcodeScannerWindow,
                border: Border.all(color: MealoraColors.lime, width: 3),
                borderRadius: BorderRadius.circular(MealoraRadius.chip),
              ),
              padding: const EdgeInsets.symmetric(vertical: MealoraSpacing.sm),
              child: AnimatedBuilder(
                animation: _scanController,
                builder: (context, child) => Align(
                  alignment: Alignment(
                    0,
                    widget.animate
                        ? (Curves.easeInOut.transform(_scanController.value) *
                                  2) -
                              1
                        : 0,
                  ),
                  child: child,
                ),
                child: Container(
                  width: double.infinity,
                  height: 64,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: MealoraColors.barcodeScannerSweepGradient,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: MealoraSpacing.lg),
            Text(
              widget.hint,
              textAlign: TextAlign.center,
              style: MealoraTypography.bodySmall.copyWith(
                color: MealoraColors.onPrimaryEyebrow,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UnavailableFor extends StatelessWidget {
  const _UnavailableFor({
    required this.error,
    required this.text,
    required this.onManualEntry,
    required this.onSearchCatalog,
  });

  final MobileScannerException error;
  final AppText text;
  final VoidCallback onManualEntry;
  final VoidCallback onSearchCatalog;

  @override
  Widget build(BuildContext context) {
    final isPermissionDenied =
        error.errorCode == MobileScannerErrorCode.permissionDenied;
    return _UnavailableState(
      title: isPermissionDenied
          ? text.barcodeScanPermissionDeniedTitle
          : text.barcodeScanUnavailableTitle,
      body: isPermissionDenied
          ? text.barcodeScanPermissionDeniedBody
          : text.barcodeScanUnavailableBody,
      onManualEntry: onManualEntry,
      onSearchCatalog: onSearchCatalog,
    );
  }
}

/// Keadaan "pemindaian tidak tersedia" (izin ditolak, kamera tidak ada,
/// atau target web) — SHALL TIDAK pernah berupa layar gagal: selalu
/// menawarkan masukan manual dan pencarian katalog (spec, "Izin kamera
/// ditolak").
class _UnavailableState extends StatelessWidget {
  const _UnavailableState({
    required this.title,
    required this.body,
    required this.onManualEntry,
    required this.onSearchCatalog,
  });

  final String title;
  final String body;
  final VoidCallback onManualEntry;
  final VoidCallback onSearchCatalog;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return MealoraEmptyState(
      icon: Icons.videocam_off_outlined,
      title: title,
      body: body,
      action: Column(
        children: <Widget>[
          MealoraPrimaryButton(
            label: text.barcodeScanManualAction,
            icon: Icons.keyboard_outlined,
            onPressed: onManualEntry,
          ),
          const SizedBox(height: MealoraSpacing.sm),
          TextButton(
            onPressed: onSearchCatalog,
            child: Text(text.barcodeScanSearchCatalogAction),
          ),
        ],
      ),
    );
  }
}
