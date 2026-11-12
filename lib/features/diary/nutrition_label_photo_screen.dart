import 'dart:async' show unawaited;
import 'dart:typed_data' show Uint8List;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/domain/image_ai_access/image_ai_settings.dart';
import 'package:mealora/domain/image_ai_access/label_service_failure.dart';
import 'package:mealora/domain/image_ai_access/nutrition_label_provider.dart';
import 'package:mealora/features/diary/label_extraction_failure_text.dart';
import 'package:mealora/features/diary/nutrition_label_review_screen.dart';
import 'package:mealora/features/diary/packaged_food_manual_fill_screen.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// `23 · Foto label kemasan` (task 6.1-6.5, change 010): pratinjau kamera
/// dengan bingkai panduan, persetujuan unggah inline sebelum ekstraksi, dan
/// jalur manual tanpa unggah — selalu tersedia dari layar ini (spec,
/// "Pengguna memilih jalur manual").
///
/// Sesuai rancangan `23`: satu layar, satu tombol ("Ekstrak untuk
/// ditinjau") yang memotret DAN mengirim sekaligus — bukan dua langkah
/// terpisah (kamera lalu panel persetujuan modal).
class NutritionLabelPhotoScreen extends ConsumerStatefulWidget {
  const NutritionLabelPhotoScreen({
    this.barcode,
    this.date,
    @visibleForTesting this.debugSkipCameraInit = false,
    @visibleForTesting this.debugCapture,
    super.key,
  });

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

enum _Stage { initializing, ready, unavailable, submitting, extractionFailed }

class _NutritionLabelPhotoScreenState
    extends ConsumerState<NutritionLabelPhotoScreen> {
  CameraController? _controller;
  _Stage _stage = _Stage.initializing;
  bool _consentChecked = false;
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
    final consentPreferenceAsync = ref.watch(
      imageUploadConsentPreferenceProvider,
    );
    final consentPreference =
        consentPreferenceAsync.valueOrNull ??
        ImageUploadConsentPreference.askEachTime;
    final needsConsentCheckbox =
        consentPreference == ImageUploadConsentPreference.askEachTime;
    final canExtract =
        (_stage == _Stage.ready) && (!needsConsentCheckbox || _consentChecked);
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
                ..._body(text, needsConsentCheckbox: needsConsentCheckbox),
                const SizedBox(height: MealoraSpacing.sm),
                Semantics(
                  button: true,
                  link: true,
                  label: text.labelPhotoManualLink,
                  child: Center(
                    child: InkWell(
                      onTap: _openManualFill,
                      child: Text(
                        text.labelPhotoManualLink,
                        style: MealoraTypography.bodyEmphasis.copyWith(
                          color: MealoraColors.primaryDeep,
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

  List<Widget> _body(AppText text, {required bool needsConsentCheckbox}) {
    switch (_stage) {
      case _Stage.unavailable:
        return <Widget>[
          MealoraEmptyState(
            icon: Icons.videocam_off_outlined,
            title: text.labelPhotoPermissionDeniedTitle,
            body: text.labelPhotoPermissionDeniedBody,
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
          ),
          const SizedBox(height: MealoraSpacing.lg),
          if (_stage == _Stage.submitting)
            const Center(child: CircularProgressIndicator())
          else
            _ConsentRow(
              visible: needsConsentCheckbox,
              checked: _consentChecked,
              onChanged: (value) => setState(() => _consentChecked = value),
              text: text,
            ),
        ];
      case _Stage.ready:
        return <Widget>[
          _PreviewFrame(
            controller: _controller,
            captionText: text.labelPhotoFrameCaption,
          ),
          const SizedBox(height: MealoraSpacing.lg),
          _ConsentRow(
            visible: needsConsentCheckbox,
            checked: _consentChecked,
            onChanged: (value) => setState(() => _consentChecked = value),
            text: text,
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

  Future<void> _submit(Uint8List bytes) async {
    setState(() {
      _stage = _Stage.submitting;
      _capturedBytes = bytes;
    });
    final provider = ref.read(nutritionLabelProviderProvider);
    final outcome = await provider.extractLabel(bytes);
    if (!mounted) return;

    switch (outcome) {
      case LabelExtractionRead(:final extraction):
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => NutritionLabelReviewScreen(
              photoBytes: bytes,
              extraction: extraction,
              barcode: widget.barcode,
              date: widget.date,
            ),
          ),
        );
        if (!mounted) return;
        setState(() => _stage = _Stage.ready);
      case LabelExtractionServiceUnavailable(:final reason):
        setState(() {
          _stage = _Stage.extractionFailed;
          _lastFailure = reason;
        });
    }
  }

  void _openManualFill() {
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

/// Area pratinjau kamera dengan bingkai panduan (rancangan `23`) —
/// [controller] `null` berarti belum siap (sedang diinisialisasi, gagal,
/// atau pengujian widget yang melewati inisialisasi sungguhan): latar
/// gelap polos tetap tampil dengan bingkai yang sama, tanpa video.
class _PreviewFrame extends StatelessWidget {
  const _PreviewFrame({required this.controller, required this.captionText});

  final CameraController? controller;
  final String captionText;

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
          ],
        ),
      ),
    );
  }
}

/// Baris persetujuan inline (rancangan `23`, task 3.3/6.2) — tampil hanya
/// ketika pengaturan privasi bernilai "tanya setiap kali" (Design D3);
/// "selalu izinkan" menyembunyikannya sepenuhnya, sesuai Design D3: pilihan
/// tetap pengguna sendiri yang melewatkan penanyaan ini.
class _ConsentRow extends StatelessWidget {
  const _ConsentRow({
    required this.visible,
    required this.checked,
    required this.onChanged,
    required this.text,
  });

  final bool visible;
  final bool checked;
  final ValueChanged<bool> onChanged;
  final AppText text;

  @override
  Widget build(BuildContext context) {
    if (!visible) {
      return const SizedBox.shrink();
    }
    return Semantics(
      label:
          '${text.uploadConsentCheckboxLabel}. ${text.uploadConsentBody} '
          '${checked ? text.uploadConsentCheckedState : text.uploadConsentUncheckedState}',
      child: MealoraCard(
        child: InkWell(
          onTap: () => onChanged(!checked),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              ExcludeSemantics(
                child: Checkbox(
                  value: checked,
                  onChanged: (value) => onChanged(value ?? false),
                ),
              ),
              const SizedBox(width: MealoraSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      text.uploadConsentCheckboxLabel,
                      style: MealoraTypography.bodyEmphasis,
                    ),
                    const SizedBox(height: MealoraSpacing.xxs),
                    Text(
                      text.uploadConsentBody,
                      style: MealoraTypography.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
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
