import 'dart:async' show unawaited;
import 'dart:typed_data' show Uint8List;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/domain/image_ai_access/label_service_failure.dart';
import 'package:mealora/domain/nutrition_import/nutrition_import.dart';
import 'package:mealora/domain/nutrition_import/nutrition_reading.dart';
import 'package:mealora/features/diary/custom_food_screen.dart';
import 'package:mealora/features/diary/label_extraction_failure_text.dart';
import 'package:mealora/features/diary/nutrition_import_review_screen.dart';
import 'package:mealora/features/diary/nutrition_label_review_screen.dart';
import 'package:mealora/features/diary/packaged_food_manual_fill_screen.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// `88 · Foto info gizi` (change 020, design D4; awalnya `23 · Foto label
/// kemasan`, change 010): satu layar untuk label kemasan, layar laptop, dan
/// artikel. Pratinjau kamera, ikon galeri, persetujuan unggah inline, dan
/// jalur manual yang selalu tersedia.
///
/// Satu tombol memotret lalu membaca bertingkat lewat
/// `NutritionReadingPipeline` (design D3): AI vision hanya dengan izin,
/// lalu teks hasil OCR di perangkat, lalu pembacaan offline.
class NutritionLabelPhotoScreen extends ConsumerStatefulWidget {
  const NutritionLabelPhotoScreen({
    this.barcode,
    this.date,
    this.returnToForm = false,
    @visibleForTesting this.debugSkipCameraInit = false,
    @visibleForTesting this.debugCapture,
    @visibleForTesting this.debugPickGallery,
    super.key,
  });

  /// `true` bila dibuka dari layar tempel di form Buat makanan (design D4,
  /// `ImportOrigin.customFoodForm`): hasil tinjau dikembalikan lewat
  /// `Navigator.pop` sebagai `NutritionImportResult`, bukan disimpan.
  final bool returnToForm;

  /// Pengganti pemilih galeri untuk pengujian widget; `null` (bawaan,
  /// SATU-SATUNYA jalur sungguhan) memakai photo picker sistem.
  final Future<Uint8List?> Function()? debugPickGallery;

  /// `null` ketika dibuka langsung dari layar pindai barcode tanpa
  /// memindai/mengetik barcode dulu (change 010) — produk yang dihasilkan
  /// tersimpan tanpa barcode dan hanya ditemukan lewat pencarian nama.
  final String? barcode;
  final LocalDate? date;

  /// `true` hanya pada pengujian widget (task 4.6) — melewati inisialisasi
  /// `CameraController` sungguhan, yang bergantung pada platform channel
  /// tak tersedia di lingkungan uji (pola yang sama dengan tidak adanya uji
  /// widget untuk `BarcodeScanScreen`, change 009). `false` (bawaan) SATU-
  /// SATUNYA jalur pada aplikasi sungguhan.
  final bool debugSkipCameraInit;

  /// Pengganti `_controller!.takePicture()` untuk pengujian widget —
  /// `null` (bawaan, SATU-SATUNYA jalur sungguhan) memotret dari kamera
  /// yang sungguh aktif.
  final Future<Uint8List> Function()? debugCapture;

  @override
  ConsumerState<NutritionLabelPhotoScreen> createState() =>
      _NutritionLabelPhotoScreenState();
}

enum _Stage {
  initializing,
  ready,
  unavailable,
  submitting,
  extractionFailed,
  noInfo,
}

class _NutritionLabelPhotoScreenState
    extends ConsumerState<NutritionLabelPhotoScreen> {
  CameraController? _controller;
  _Stage _stage = _Stage.initializing;

  LabelServiceFailureReason? _lastFailure;

  /// Foto terakhir yang berhasil diambil — dipertahankan melewati
  /// kegagalan layanan (spec image-ai-access, "Koneksi terputus saat
  /// pengiriman": draf dan gambar tetap ada) supaya "coba lagi" mengirim
  /// ulang foto yang SAMA, bukan memaksa pengguna memotret dari awal.
  Uint8List? _capturedBytes;

  @override
  void initState() {
    super.initState();
    if (widget.debugSkipCameraInit) {
      _stage = _Stage.ready;
      return;
    }
    unawaited(_initializeCamera());
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeCamera() async {
    if (kIsWeb) {
      // Sama seperti `BarcodeScanScreen` (change 009): target web tidak
      // mencoba kamera sungguhan sama sekali, langsung ke jalur manual.
      if (mounted) setState(() => _stage = _Stage.unavailable);
      return;
    }
    try {
      final cameras = await availableCameras();
      final camera = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _controller = controller;
        _stage = _Stage.ready;
      });
    } on CameraException {
      if (mounted) setState(() => _stage = _Stage.unavailable);
    } on Object {
      // Tidak ada kamera di perangkat, atau kegagalan platform lain —
      // diperlakukan sama: jalur manual, bukan layar gagal (task 6.5).
      if (mounted) setState(() => _stage = _Stage.unavailable);
    }
  }

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final canExtract = _stage == _Stage.ready;
    final showExtractButton =
        _stage == _Stage.initializing ||
        _stage == _Stage.ready ||
        _stage == _Stage.submitting;

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
                MealoraBackEyebrow(label: text.labelPhotoContextLabel),
                const SizedBox(height: MealoraSpacing.xs),
                Text(text.labelPhotoTitle, style: MealoraTypography.title),
                const SizedBox(height: MealoraSpacing.xxs),
                Text(
                  text.labelPhotoSubtitle,
                  style: MealoraTypography.subtitle,
                ),
                const SizedBox(height: MealoraSpacing.lg),
                ..._body(text),
                const SizedBox(height: MealoraSpacing.sm),
                Semantics(
                  button: true,
                  link: true,
                  label: text.labelPhotoManualLink,
                  child: Center(
                    child: InkWell(
                      onTap: _openManualFill,
                      child: ExcludeSemantics(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: MealoraSpacing.xs,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const Icon(
                                Icons.edit_outlined,
                                size: MealoraIconSize.inline,
                                color: MealoraColors.primaryDeep,
                              ),
                              const SizedBox(width: MealoraSpacing.xxs),
                              Text(
                                text.labelPhotoManualLink,
                                style: MealoraTypography.bodyEmphasis.copyWith(
                                  color: MealoraColors.primaryDeep,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                if (showExtractButton) ...<Widget>[
                  const SizedBox(height: MealoraSpacing.lg),
                  MealoraPrimaryButton(
                    label: text.labelPhotoExtractAction,
                    icon: Icons.document_scanner_outlined,
                    onPressed: canExtract ? () => unawaited(_extract()) : null,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _body(AppText text) {
    switch (_stage) {
      case _Stage.unavailable:
        return <Widget>[
          MealoraEmptyState(
            icon: Icons.videocam_off_outlined,
            title: text.labelPhotoPermissionDeniedTitle,
            body: text.labelPhotoPermissionDeniedBody,
          ),
        ];
      case _Stage.noInfo:
        return <Widget>[
          MealoraEmptyState(
            icon: Icons.search_off_outlined,
            title: text.labelPhotoNoInfoTitle,
            body: text.labelPhotoNoInfoBody,
          ),
          if (_capturedBytes != null) ...<Widget>[
            const SizedBox(height: MealoraSpacing.md),
            MealoraPrimaryButton(
              key: const ValueKey('label-photo-analyze'),
              label: text.analyzePhotoAction,
              icon: Icons.image_search_outlined,
              onPressed: () => unawaited(_analyzeCapturedPhoto()),
            ),
            const SizedBox(height: MealoraSpacing.xxs),
            Text(
              text.analyzePhotoUploadNote,
              textAlign: TextAlign.center,
              style: MealoraTypography.caption,
            ),
          ],
          const SizedBox(height: MealoraSpacing.sm),
          Row(
            children: <Widget>[
              Expanded(
                child: MealoraGlassButton(
                  key: const ValueKey('label-photo-retake'),
                  onPressed: () => setState(() => _stage = _Stage.ready),
                  icon: Icons.photo_camera_outlined,
                  label: text.labelPhotoRetakeAction,
                ),
              ),
              const SizedBox(width: MealoraSpacing.sm),
              Expanded(
                child: MealoraGlassButton(
                  onPressed: _openManualFill,
                  icon: Icons.edit_outlined,
                  label: text.labelPhotoManualLink,
                ),
              ),
            ],
          ),
        ];
      case _Stage.extractionFailed:
        final reason = _lastFailure;
        return <Widget>[
          MealoraEmptyState(
            icon: Icons.cloud_off_outlined,
            title: text.labelExtractionUnavailableTitle,
            body: reason == null
                ? text.labelExtractionDraftPreservedNote
                : '${labelExtractionFailureHeadline(text, reason)} '
                      '${text.labelExtractionDraftPreservedNote}',
          ),
          if (_capturedBytes != null) ...<Widget>[
            const SizedBox(height: MealoraSpacing.sm),
            Center(
              child: TextButton(
                onPressed: () => unawaited(_submit(_capturedBytes!)),
                child: Text(text.labelPhotoRetryAction),
              ),
            ),
          ],
        ];
      case _Stage.initializing:
      case _Stage.submitting:
        return <Widget>[
          _PreviewFrame(
            controller: _controller,
            captionText: text.labelPhotoFrameCaption,
            galleryLabel: text.labelPhotoGalleryAction,
            onGallery: _stage == _Stage.ready
                ? () => unawaited(_pickFromGallery())
                : null,
          ),
          const SizedBox(height: MealoraSpacing.lg),
          if (_stage == _Stage.submitting)
            const Center(child: CircularProgressIndicator())
          else
            MealoraNoteCard(
              icon: Icons.document_scanner_outlined,
              title: text.labelPhotoReadNoteTitle,
              body: text.labelPhotoReadNoteBody,
              borderColor: MealoraColors.glassSoft,
            ),
        ];
      case _Stage.ready:
        return <Widget>[
          _PreviewFrame(
            controller: _controller,
            captionText: text.labelPhotoFrameCaption,
            galleryLabel: text.labelPhotoGalleryAction,
            onGallery: _stage == _Stage.ready
                ? () => unawaited(_pickFromGallery())
                : null,
          ),
          const SizedBox(height: MealoraSpacing.lg),
          MealoraNoteCard(
            icon: Icons.document_scanner_outlined,
            title: text.labelPhotoReadNoteTitle,
            body: text.labelPhotoReadNoteBody,
            borderColor: MealoraColors.glassSoft,
          ),
        ];
    }
  }

  Future<void> _extract() async {
    final Uint8List bytes;
    try {
      bytes = widget.debugCapture != null
          ? await widget.debugCapture!()
          : await _controller!.takePicture().then((file) => file.readAsBytes());
    } on Object {
      if (!mounted) return;
      setState(() => _stage = _Stage.unavailable);
      return;
    }
    if (!mounted) return;
    await _submit(bytes);
  }

  Future<void> _pickFromGallery() async {
    final Uint8List? bytes;
    try {
      bytes = widget.debugPickGallery != null
          ? await widget.debugPickGallery!()
          : await ImagePicker()
                .pickImage(source: ImageSource.gallery)
                .then((file) => file?.readAsBytes());
    } on Object {
      return;
    }
    if (bytes == null || !mounted) return;
    await _submit(bytes);
  }

  Future<void> _submit(Uint8List bytes) async {
    setState(() {
      _stage = _Stage.submitting;
      _capturedBytes = bytes;
    });
    final outcome = await ref
        .read(nutritionReadingPipelineProvider)
        .readImage(bytes);
    if (!mounted) return;

    switch (outcome) {
      case NutritionReadSuccess(:final reading, :final tier)
          when reading.hasAnyNutrient:
        setState(() => _stage = _Stage.ready);
        await _route(reading, tier, bytes);
      case NutritionReadSuccess() || NutritionReadNoText():
        setState(() => _stage = _Stage.noInfo);
      case NutritionReadUnavailable(:final reason):
        setState(() {
          _stage = _Stage.extractionFailed;
          _lastFailure = reason;
        });
    }
  }

  /// "Analisis foto dengan AI" dari keadaan tidak ada info (layar 91):
  /// foto yang sama dikirim ke AI vision atas tindakan pengguna.
  Future<void> _analyzeCapturedPhoto() async {
    final bytes = _capturedBytes;
    if (bytes == null) return;
    setState(() => _stage = _Stage.submitting);
    final outcome = await ref
        .read(nutritionReadingPipelineProvider)
        .analyzePhoto(bytes);
    if (!mounted) return;
    switch (outcome) {
      case NutritionReadSuccess(:final reading, :final tier)
          when reading.hasAnyNutrient:
        setState(() => _stage = _Stage.ready);
        await _route(reading, tier, bytes);
      case NutritionReadSuccess() || NutritionReadNoText():
        setState(() => _stage = _Stage.noInfo);
      case NutritionReadUnavailable(:final reason):
        setState(() {
          _stage = _Stage.extractionFailed;
          _lastFailure = reason;
        });
    }
  }

  /// Tujuan hasil (spec "Tujuan hasil mengikuti konteks dan jenis sumber",
  /// design D4).
  Future<void> _route(
    NutritionReading reading,
    ReadingTier tier,
    Uint8List bytes,
  ) async {
    final navigator = Navigator.of(context);
    if (widget.returnToForm) {
      final result = await _review(reading, tier, bytes);
      if (result != null && mounted) navigator.pop(result);
      return;
    }

    var kind = widget.barcode != null
        ? NutritionSourceKind.packageLabel
        : reading.sourceKind;
    if (kind == NutritionSourceKind.unknown) {
      final chosen = await showNutritionSourceChoiceSheet(context);
      if (chosen == null || !mounted) return;
      kind = chosen;
    }

    if (kind == NutritionSourceKind.packageLabel) {
      await navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => NutritionLabelReviewScreen(
            photoBytes: bytes,
            extraction: reading.toLabelExtraction(
              forceNeedsCheck: tier == ReadingTier.offline,
            ),
            barcode: widget.barcode,
            date: widget.date,
          ),
        ),
      );
      return;
    }

    final result = await _review(reading, tier, bytes);
    if (result == null || !mounted) return;
    await navigator.push(
      MaterialPageRoute<void>(
        builder: (_) => CustomFoodScreen(date: widget.date, prefill: result),
      ),
    );
  }

  Future<NutritionImportResult?> _review(
    NutritionReading reading,
    ReadingTier tier,
    Uint8List bytes,
  ) => Navigator.of(context).push<NutritionImportResult>(
    MaterialPageRoute<NutritionImportResult>(
      builder: (_) => NutritionImportReviewScreen(
        reading: reading,
        tier: tier,
        analyzePhoto: () =>
            ref.read(nutritionReadingPipelineProvider).analyzePhoto(bytes),
      ),
    ),
  );

  void _openManualFill() {
    if (widget.returnToForm) {
      Navigator.of(context).pop();
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PackagedFoodManualFillScreen(
          barcode: widget.barcode,
          date: widget.date,
        ),
      ),
    );
  }
}

/// Pilihan jenis simpan saat sumber tidak dapat dipastikan (spec "Jenis
/// sumber ragu").
Future<NutritionSourceKind?> showNutritionSourceChoiceSheet(
  BuildContext context,
) {
  final text = AppText.of(context);
  return showModalBottomSheet<NutritionSourceKind>(
    context: context,
    backgroundColor: MealoraColors.sheetSurface,
    builder: (context) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(MealoraSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              text.nutritionSourceChoiceTitle,
              style: MealoraTypography.headline,
            ),
            const SizedBox(height: MealoraSpacing.xxs),
            Text(
              text.nutritionSourceChoiceBody,
              style: MealoraTypography.bodySmall,
            ),
            const SizedBox(height: MealoraSpacing.md),
            MealoraNoteCard(
              icon: Icons.inventory_2_outlined,
              title: text.nutritionSourceChoicePackaged,
              body: text.nutritionSourceChoicePackagedDescription,
              onTap: () =>
                  Navigator.of(context).pop(NutritionSourceKind.packageLabel),
            ),
            const SizedBox(height: MealoraSpacing.sm),
            MealoraNoteCard(
              icon: Icons.restaurant_outlined,
              title: text.nutritionSourceChoiceCustom,
              body: text.nutritionSourceChoiceCustomDescription,
              onTap: () =>
                  Navigator.of(context).pop(NutritionSourceKind.general),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Area pratinjau kamera dengan bingkai panduan (rancangan `23`) —
/// [controller] `null` berarti belum siap (sedang diinisialisasi, gagal,
/// atau pengujian widget yang melewati inisialisasi sungguhan): latar
/// gelap polos tetap tampil dengan bingkai yang sama, tanpa video.
class _PreviewFrame extends StatelessWidget {
  const _PreviewFrame({
    required this.controller,
    required this.captionText,
    required this.galleryLabel,
    required this.onGallery,
  });

  final CameraController? controller;
  final String captionText;
  final String galleryLabel;
  final VoidCallback? onGallery;

  @override
  Widget build(BuildContext context) {
    final ready = controller?.value.isInitialized ?? false;
    return ClipRRect(
      borderRadius: BorderRadius.circular(MealoraRadius.welcomeCard),
      child: Container(
        height: 280,
        color: MealoraColors.ink,
        child: Stack(
          fit: StackFit.expand,
          children: <Widget>[
            if (ready) _CoverCameraPreview(controller: controller!),
            Center(
              child: Container(
                width: 240,
                height: 170,
                decoration: BoxDecoration(
                  border: Border.all(color: MealoraColors.lime, width: 3),
                  borderRadius: BorderRadius.circular(MealoraRadius.chip),
                ),
                alignment: Alignment.bottomCenter,
                padding: const EdgeInsets.only(bottom: MealoraSpacing.sm),
                child: Text(
                  captionText,
                  textAlign: TextAlign.center,
                  style: MealoraTypography.bodySmall.copyWith(
                    color: MealoraColors.onPrimaryEyebrow,
                  ),
                ),
              ),
            ),
            Positioned(
              right: MealoraSpacing.sm,
              bottom: MealoraSpacing.sm,
              child: IconButton.filledTonal(
                key: const ValueKey('label-photo-gallery'),
                tooltip: galleryLabel,
                onPressed: onGallery,
                icon: const Icon(Icons.photo_library_outlined),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fills the frame with the camera feed at its native aspect ratio (crop,
/// not stretch), matching how the barcode scanner preview behaves.
class _CoverCameraPreview extends StatelessWidget {
  const _CoverCameraPreview({required this.controller});

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    final size = controller.value.previewSize;
    if (size == null) return CameraPreview(controller);
    // previewSize is reported in sensor (landscape) orientation; the app is
    // portrait, so swap width/height for layout.
    return FittedBox(
      fit: BoxFit.cover,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: size.height,
        height: size.width,
        child: CameraPreview(controller),
      ),
    );
  }
}
