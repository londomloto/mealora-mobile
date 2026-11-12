import 'dart:async' show unawaited;
import 'dart:typed_data' show Uint8List;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart' show kIsWeb, visibleForTesting;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/domain/food/meal_time.dart';
import 'package:mealora/domain/food_photo_input/food_component_matcher.dart';
import 'package:mealora/domain/food_photo_input/food_component_recognition_provider.dart';
import 'package:mealora/domain/food_photo_input/photo_draft.dart';
import 'package:mealora/domain/food_photo_input/photo_draft_component_builder.dart';
import 'package:mealora/domain/image_ai_access/image_ai_settings.dart';
import 'package:mealora/features/diary/diary_controller.dart';
import 'package:mealora/features/diary/diary_providers.dart';
import 'package:mealora/features/diary/food_photo_draft_screen.dart';
import 'package:mealora/features/diary/food_photo_draft_storage.dart';
import 'package:mealora/features/diary/food_photo_review_screen.dart';
import 'package:mealora/features/diary/food_search_screen.dart';
import 'package:mealora/features/onboarding/onboarding_controller.dart'
    show profileRepositoryProvider;
import 'package:mealora/l10n/generated/app_localizations.dart';

/// `19 · Foto makanan & izin` (task 4.1-4.4, change 011): pratinjau kamera
/// dengan bingkai panduan, persetujuan unggah inline sebelum pengenalan
/// (pola yang sama dengan `NutritionLabelPhotoScreen`, change 010), dan
/// jalur manual tanpa mengambil maupun mengirim gambar (spec, "Jalur tanpa
/// pengenalan selalu tersedia").
class FoodPhotoScreen extends ConsumerStatefulWidget {
  const FoodPhotoScreen({
    this.date,
    @visibleForTesting this.debugSkipCameraInit = false,
    @visibleForTesting this.debugCapture,
    @visibleForTesting this.debugPickGallery,
    super.key,
  });

  final LocalDate? date;

  /// `true` hanya pada pengujian widget — melewati inisialisasi
  /// `CameraController` sungguhan (pola yang sama dengan
  /// `NutritionLabelPhotoScreen`, change 010).
  final bool debugSkipCameraInit;

  final Future<Uint8List> Function()? debugCapture;

  /// Pengganti `ImagePicker` untuk pengujian widget; `null` = batal pilih.
  final Future<Uint8List?> Function()? debugPickGallery;

  @override
  ConsumerState<FoodPhotoScreen> createState() => _FoodPhotoScreenState();
}

enum _Stage { initializing, ready, unavailable, submitting }

/// `true` = kamera full screen (rancangan `19b`); `false` = tata letak lama
/// berbingkai (rancangan `19`), yang masih dipertahankan di bawah.
const bool _useFullScreenCamera = true;

class _FoodPhotoScreenState extends ConsumerState<FoodPhotoScreen> {
  CameraController? _controller;
  _Stage _stage = _Stage.initializing;
  bool _consentChecked = false;

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
    } on Object {
      // Tidak ada kamera, izin ditolak, atau kegagalan platform lain —
      // diperlakukan sama: jalur manual, bukan layar gagal (task 4.4).
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
    final canCapture =
        (_stage == _Stage.ready) && (!needsConsentCheckbox || _consentChecked);

    if (_useFullScreenCamera && _stage != _Stage.unavailable) {
      return _fullScreenCamera(
        text,
        needsConsentCheckbox: needsConsentCheckbox,
        canCapture: canCapture,
      );
    }

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
                MealoraBackEyebrow(label: text.foodPhotoContextLabel),
                const SizedBox(height: MealoraSpacing.xs),
                Text(text.foodPhotoTitle, style: MealoraTypography.title),
                const SizedBox(height: MealoraSpacing.xxs),
                Text(text.foodPhotoSubtitle, style: MealoraTypography.subtitle),
                const SizedBox(height: MealoraSpacing.lg),
                ..._body(text, needsConsentCheckbox: needsConsentCheckbox),
                const SizedBox(height: MealoraSpacing.sm),
                Semantics(
                  button: true,
                  link: true,
                  label: text.foodPhotoManualLink,
                  child: Center(
                    child: InkWell(
                      onTap: _openManualSearch,
                      child: Text(
                        text.foodPhotoManualLink,
                        style: MealoraTypography.bodyEmphasis.copyWith(
                          color: MealoraColors.primaryDeep,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: MealoraSpacing.lg),
                MealoraPrimaryButton(
                  label: text.foodPhotoCaptureAction,
                  icon: Icons.camera_alt_outlined,
                  onPressed: canCapture ? () => unawaited(_capture()) : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Kamera memenuhi layar; header dan kontrol ditumpuk di atas pratinjau
  /// supaya pengguna leluasa membingkai foto.
  Widget _fullScreenCamera(
    AppText text, {
    required bool needsConsentCheckbox,
    required bool canCapture,
  }) {
    final ready = _controller?.value.isInitialized ?? false;
    const scrim = MealoraColors.cameraScrim;
    return Scaffold(
      backgroundColor: MealoraColors.ink,
      body: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (ready) _CoverCameraPreview(controller: _controller!),
          const Align(
            alignment: Alignment.topCenter,
            child: _Scrim(height: 190, color: scrim, fromTop: true),
          ),
          const Align(
            alignment: Alignment.bottomCenter,
            child: _Scrim(height: 324, color: scrim, fromTop: false),
          ),
          Align(
            alignment: const Alignment(0, -0.3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const _GuideCorners(width: 310, height: 300),
                const SizedBox(height: MealoraSpacing.sm),
                DecoratedBox(
                  decoration: BoxDecoration(
                    color: scrim.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(MealoraRadius.pill),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Text(
                      text.foodPhotoFrameCaption,
                      style: MealoraTypography.bodySmall.copyWith(
                        color: MealoraColors.onPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  MealoraSpacing.programHeroGutter,
                  MealoraSpacing.sm,
                  MealoraSpacing.programHeroGutter,
                  0,
                ),
                child: Row(
                  children: <Widget>[
                    Semantics(
                      button: true,
                      label: MaterialLocalizations.of(
                        context,
                      ).closeButtonTooltip,
                      child: InkWell(
                        onTap: () => Navigator.of(context).maybePop(),
                        borderRadius: BorderRadius.circular(
                          MealoraRadius.cameraControl,
                        ),
                        child: Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: scrim.withValues(alpha: 0.35),
                            borderRadius: BorderRadius.circular(
                              MealoraRadius.cameraControl,
                            ),
                            border: Border.all(
                              color: MealoraColors.photoHeroButtonBorder,
                            ),
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 18,
                            color: MealoraColors.onPrimary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: MealoraSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Text(
                            text.foodPhotoContextLabel,
                            style: MealoraTypography.bodySmall.copyWith(
                              color: MealoraColors.lime,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                          Text(
                            text.foodPhotoTitle,
                            style: MealoraTypography.cameraTitle,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  MealoraSpacing.md,
                  0,
                  MealoraSpacing.md,
                  MealoraSpacing.lg,
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: MealoraColors.surface.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(MealoraRadius.card),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(MealoraSpacing.md),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: <Widget>[
                        if (_stage == _Stage.submitting)
                          const Padding(
                            padding: EdgeInsets.only(bottom: MealoraSpacing.sm),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else if (needsConsentCheckbox)
                          _CompactConsentRow(
                            checked: _consentChecked,
                            onChanged: (value) =>
                                setState(() => _consentChecked = value),
                            text: text,
                          ),
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: MealoraPrimaryButton(
                                label: text.foodPhotoCaptureAction,
                                icon: Icons.camera_alt_outlined,
                                onPressed: canCapture
                                    ? () => unawaited(_capture())
                                    : null,
                              ),
                            ),
                            const SizedBox(width: MealoraSpacing.sm),
                            IconButton.filledTonal(
                              key: const ValueKey('food-photo-gallery'),
                              tooltip: text.foodPhotoGalleryAction,
                              iconSize: 24,
                              constraints: const BoxConstraints.tightFor(
                                width: 52,
                                height: 52,
                              ),
                              onPressed: canCapture
                                  ? () => unawaited(_pickFromGallery())
                                  : null,
                              icon: const Icon(Icons.photo_library_outlined),
                            ),
                          ],
                        ),
                        const SizedBox(height: MealoraSpacing.sm),
                        Semantics(
                          button: true,
                          link: true,
                          label: text.foodPhotoManualLink,
                          child: Center(
                            child: InkWell(
                              onTap: _openManualSearch,
                              child: Text(
                                text.foodPhotoManualLink,
                                style: MealoraTypography.bodyEmphasis.copyWith(
                                  color: MealoraColors.primaryDeep,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _body(AppText text, {required bool needsConsentCheckbox}) {
    switch (_stage) {
      case _Stage.unavailable:
        return <Widget>[
          MealoraEmptyState(
            icon: Icons.videocam_off_outlined,
            title: text.foodPhotoPermissionDeniedTitle,
            body: text.foodPhotoPermissionDeniedBody,
          ),
        ];
      case _Stage.initializing:
      case _Stage.submitting:
        return <Widget>[
          _PreviewFrame(
            controller: _controller,
            captionText: text.foodPhotoFrameCaption,
          ),
          const SizedBox(height: MealoraSpacing.lg),
          if (_stage == _Stage.submitting)
            const Center(child: CircularProgressIndicator())
          else
            _ConsentPanel(
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
            captionText: text.foodPhotoFrameCaption,
          ),
          const SizedBox(height: MealoraSpacing.lg),
          _ConsentPanel(
            visible: needsConsentCheckbox,
            checked: _consentChecked,
            onChanged: (value) => setState(() => _consentChecked = value),
            text: text,
          ),
        ];
    }
  }

  Future<void> _capture() async {
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

  /// Foto yang diambil sebelumnya (mis. di restoran, diunggah di rumah).
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
    setState(() => _stage = _Stage.submitting);

    final profile = await ref.read(profileRepositoryProvider).current();
    if (profile == null || !mounted) return;

    final clock = ref.read(clockProvider);
    final ids = ref.read(idGeneratorProvider);
    final draftId = ids.next();
    final sourceImagePath = await saveDraftPhoto(bytes, fileId: draftId);

    var draft = PhotoDraft(
      id: draftId,
      profileId: profile.id,
      localDate: widget.date ?? clock.today(),
      mealTime: MealTime.lunch,
      sourceImagePath: sourceImagePath,
      components: const <PhotoDraftComponent>[],
      createdAt: clock.nowUtc(),
    );
    await savePhotoDraft(ref, draft);
    if (!mounted) return;

    final provider = ref.read(foodComponentRecognitionProviderProvider);
    final outcome = await provider.recognizeComponents(bytes);
    if (!mounted) return;

    switch (outcome) {
      case FoodComponentRecognitionRead(:final recognition):
        final matcher = FoodComponentMatcher(ref.read(foodRepositoryProvider));
        final components = <PhotoDraftComponent>[];
        for (final recognized in recognition.components) {
          final match = await matcher.match(recognized.foodNameGuess);
          components.add(
            buildPhotoDraftComponent(
              ids: ids,
              recognized: recognized,
              match: match,
            ),
          );
        }
        draft = draft.withComponents(components);
        await savePhotoDraft(ref, draft);
        if (!mounted) return;
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => FoodPhotoReviewScreen(draft: draft),
          ),
        );
        if (!mounted) return;
        setState(() => _stage = _Stage.ready);
      case FoodComponentRecognitionServiceUnavailable():
        await Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => FoodPhotoDraftScreen(draft: draft),
          ),
        );
        if (!mounted) return;
        setState(() => _stage = _Stage.ready);
    }
  }

  void _openManualSearch() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => FoodSearchScreen(date: widget.date),
      ),
    );
  }
}

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

/// Panel persetujuan inline (rancangan `19`) — tampil hanya ketika
/// pengaturan privasi bernilai "tanya setiap kali" (Design D2/D3, change
/// 010, dipakai ulang apa adanya).
class _ConsentPanel extends StatelessWidget {
  const _ConsentPanel({
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
          '${text.foodPhotoConsentHeading}. ${text.foodPhotoConsentBody} '
          '${text.foodPhotoConsentCheckboxLabel}. '
          '${checked ? text.uploadConsentCheckedState : text.uploadConsentUncheckedState}',
      child: MealoraCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              text.foodPhotoConsentHeading,
              style: MealoraTypography.bodyEmphasis,
            ),
            const SizedBox(height: MealoraSpacing.xxs),
            Text(text.foodPhotoConsentBody, style: MealoraTypography.bodySmall),
            const SizedBox(height: MealoraSpacing.sm),
            InkWell(
              onTap: () => onChanged(!checked),
              child: Row(
                children: <Widget>[
                  ExcludeSemantics(
                    child: Checkbox(
                      value: checked,
                      onChanged: (value) => onChanged(value ?? false),
                    ),
                  ),
                  const SizedBox(width: MealoraSpacing.xs),
                  Expanded(
                    child: Text(
                      text.foodPhotoConsentCheckboxLabel,
                      style: MealoraTypography.bodySmall,
                    ),
                  ),
                ],
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

class _Scrim extends StatelessWidget {
  const _Scrim({
    required this.height,
    required this.color,
    required this.fromTop,
  });

  final double height;
  final Color color;
  final bool fromTop;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: fromTop ? Alignment.topCenter : Alignment.bottomCenter,
            end: fromTop ? Alignment.bottomCenter : Alignment.topCenter,
            colors: <Color>[
              color.withValues(alpha: fromTop ? 0.8 : 0.9),
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bingkai panduan berupa empat sudut lime (rancangan `19b`).
class _GuideCorners extends StatelessWidget {
  const _GuideCorners({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    const side = BorderSide(color: MealoraColors.lime, width: 3);
    const r = Radius.circular(14);
    Widget corner(Alignment a) {
      final top = a.y < 0;
      final left = a.x < 0;
      return Align(
        alignment: a,
        child: Container(
          width: 52,
          height: 52,
          decoration: BoxDecoration(
            border: Border(
              top: top ? side : BorderSide.none,
              bottom: top ? BorderSide.none : side,
              left: left ? side : BorderSide.none,
              right: left ? BorderSide.none : side,
            ),
            borderRadius: BorderRadius.only(
              topLeft: top && left ? r : Radius.zero,
              topRight: top && !left ? r : Radius.zero,
              bottomLeft: !top && left ? r : Radius.zero,
              bottomRight: !top && !left ? r : Radius.zero,
            ),
          ),
        ),
      );
    }

    return IgnorePointer(
      child: SizedBox(
        width: width,
        height: height,
        child: Stack(
          children: <Widget>[
            corner(Alignment.topLeft),
            corner(Alignment.topRight),
            corner(Alignment.bottomLeft),
            corner(Alignment.bottomRight),
          ],
        ),
      ),
    );
  }
}

/// Persetujuan unggah ringkas di panel kontrol bawah (rancangan `19b`).
class _CompactConsentRow extends StatelessWidget {
  const _CompactConsentRow({
    required this.checked,
    required this.onChanged,
    required this.text,
  });

  final bool checked;
  final ValueChanged<bool> onChanged;
  final AppText text;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label:
          '${text.foodPhotoConsentBody} ${text.foodPhotoConsentCheckboxLabel}. '
          '${checked ? text.uploadConsentCheckedState : text.uploadConsentUncheckedState}',
      child: InkWell(
        onTap: () => onChanged(!checked),
        child: Padding(
          padding: const EdgeInsets.only(bottom: MealoraSpacing.sm),
          child: Row(
            children: <Widget>[
              ExcludeSemantics(
                child: Checkbox(
                  value: checked,
                  onChanged: (value) => onChanged(value ?? false),
                ),
              ),
              const SizedBox(width: MealoraSpacing.xxs),
              Expanded(
                child: ExcludeSemantics(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        text.foodPhotoConsentCheckboxLabel,
                        style: MealoraTypography.bodyEmphasis,
                      ),
                      Text(
                        text.foodPhotoConsentBody,
                        style: MealoraTypography.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
