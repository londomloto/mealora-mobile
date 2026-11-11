import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/domain/voice_input/speech_recognizer.dart';
import 'package:mealora/features/diary/voice_input_shared.dart';
import 'package:mealora/features/diary/voice_transcript_screen.dart';
import 'package:mealora/features/diary/voice_type_screen.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// `42 · Rekam suara` dan `43 · Sedang merekam` (change 012, task 4.1/4.2).
///
/// Izin mikrofon baru diminta ketika pengguna menekan "Mulai merekam" —
/// bukan saat layar ini atau lembar 02 dibuka (task 3.1, 3.8). Izin ditolak
/// atau perangkat tidak mendukung bermuara ke `45 · Suara tidak tersedia`
/// dengan pengetikan kalimat, bukan layar gagal (task 3.2, 3.4).
class VoiceRecordScreen extends ConsumerStatefulWidget {
  const VoiceRecordScreen({this.date, super.key});

  final LocalDate? date;

  @override
  ConsumerState<VoiceRecordScreen> createState() => _VoiceRecordScreenState();
}

enum _Stage { ready, preparing, listening, empty, failed }

class _VoiceRecordScreenState extends ConsumerState<VoiceRecordScreen> {
  _Stage _stage = _Stage.ready;
  String _partial = '';
  StreamSubscription<SpeechSessionEvent>? _session;
  Timer? _ticker;
  final Stopwatch _elapsed = Stopwatch();

  // Disimpan sekali: `ref` tidak boleh dipakai di dispose().
  late final SpeechRecognizer _recognizer;

  @override
  void initState() {
    super.initState();
    _recognizer = ref.read(speechRecognizerProvider);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    final session = _session;
    if (session != null) {
      unawaited(session.cancel());
      unawaited(_recognizer.cancel());
    }
    super.dispose();
  }

  Future<void> _start() async {
    setState(() => _stage = _Stage.preparing);
    final availability = await _recognizer.prepare();
    if (!mounted) return;
    switch (availability) {
      case SpeechUnavailable(:final reason):
        _openTyping(reason);
      case SpeechAvailable():
        _listen();
    }
  }

  void _listen() {
    _partial = '';
    _elapsed
      ..reset()
      ..start();
    _ticker?.cancel();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
    setState(() => _stage = _Stage.listening);
    _announce(AppText.of(context).voiceListeningSemantics);
    _session = _recognizer.listen().listen(_onEvent);
  }

  void _onEvent(SpeechSessionEvent event) {
    if (!mounted) return;
    switch (event) {
      case SpeechPartialTranscript(:final text):
        setState(() => _partial = text);
      case SpeechFinalTranscript():
        _endSession();
        if (event.isEmpty) {
          setState(() => _stage = _Stage.empty);
        } else {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(
              builder: (_) => VoiceTranscriptScreen(
                transcript: event.text,
                date: widget.date,
              ),
            ),
          );
        }
      case SpeechSessionFailed(:final reason):
        _endSession();
        if (reason == SpeechUnavailableReason.failed) {
          setState(() => _stage = _Stage.failed);
        } else {
          _openTyping(reason);
        }
    }
  }

  void _endSession() {
    _ticker?.cancel();
    _elapsed.stop();
    _session = null;
  }

  Future<void> _stop() => _recognizer.stop();

  Future<void> _cancel() async {
    await _session?.cancel();
    _endSession();
    await _recognizer.cancel();
    if (mounted) Navigator.of(context).pop();
  }

  void _openTyping(SpeechUnavailableReason? reason) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => VoiceTypeScreen(reason: reason, date: widget.date),
      ),
    );
  }

  void _announce(String message) {
    final view = View.of(context);
    unawaited(
      SemanticsService.sendAnnouncement(
        view,
        message,
        Directionality.of(context),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final listening = _stage == _Stage.listening;

    return PopScope(
      canPop: !listening,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && listening) unawaited(_cancel());
      },
      child: Scaffold(
        backgroundColor: MealoraColors.background,
        body: MealoraBlobBackdrop(
          child: SafeArea(
            child: Column(
              children: <Widget>[
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(
                      MealoraSpacing.programHeroGutter,
                      MealoraSpacing.lg,
                      MealoraSpacing.programHeroGutter,
                      MealoraSpacing.lg,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: listening
                          ? _listeningBody(text)
                          : _readyBody(text),
                    ),
                  ),
                ),
                // Saat merekam, "Selesai" di bawah selalu terjangkau
                // (task 4.2). Sebelum merekam, satu-satunya kendali adalah
                // lingkaran mikrofon.
                if (listening)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      MealoraSpacing.programHeroGutter,
                      0,
                      MealoraSpacing.programHeroGutter,
                      MealoraSpacing.lg,
                    ),
                    child: MealoraPrimaryButton(
                      label: text.voiceStopAction,
                      icon: Icons.check,
                      onPressed: () => unawaited(_stop()),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _readyBody(AppText text) {
    return <Widget>[
      MealoraBackEyebrow(label: text.voiceRecordContextLabel),
      const SizedBox(height: MealoraSpacing.xs),
      Text(text.voiceRecordTitle, style: MealoraTypography.title),
      const SizedBox(height: MealoraSpacing.xxs),
      Text(text.voiceRecordSubtitle, style: MealoraTypography.subtitle),
      const SizedBox(height: MealoraSpacing.lg),
      if (_stage == _Stage.empty || _stage == _Stage.failed)
        MealoraEmptyState(
          icon: Icons.hearing_disabled_outlined,
          title: _stage == _Stage.empty
              ? text.voiceEmptyTitle
              : text.voiceFailedTitle,
          body: _stage == _Stage.empty
              ? text.voiceEmptyBody
              : text.voiceFailedBody,
        )
      else
        MealoraCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  const Icon(
                    Icons.format_quote_rounded,
                    color: MealoraColors.primary,
                  ),
                  const SizedBox(width: MealoraSpacing.xs),
                  Flexible(
                    child: Text(
                      text.voiceRecordExampleTitle,
                      style: MealoraTypography.bodyEmphasis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: MealoraSpacing.xs),
              Text(text.voiceRecordExampleQuote, style: MealoraTypography.body),
              const SizedBox(height: MealoraSpacing.xs),
              Text(
                text.voiceRecordExampleHint,
                style: MealoraTypography.caption,
              ),
            ],
          ),
        ),
      const SizedBox(height: MealoraSpacing.lg),
      _MicButton(
        busy: _stage == _Stage.preparing,
        caption: switch (_stage) {
          _Stage.preparing => text.voicePreparing,
          _Stage.ready => text.voiceRecordMicHint,
          _ => text.voiceRerecordAction,
        },
        semanticsLabel: _stage == _Stage.ready
            ? text.voiceRecordStartAction
            : text.voiceRerecordAction,
        onTap: _stage == _Stage.preparing ? null : () => unawaited(_start()),
      ),
      const SizedBox(height: MealoraSpacing.xs),
      Text(
        text.voicePermissionExplanation,
        textAlign: TextAlign.center,
        style: MealoraTypography.caption,
      ),
      const SizedBox(height: MealoraSpacing.lg),
      MealoraNoteCard(
        icon: Icons.info_outline,
        title: text.voiceScopeTitle,
        body: text.voiceScopeBody,
      ),
      const SizedBox(height: MealoraSpacing.sm),
      VoiceTextLink(
        label: text.voiceTypeInsteadLink,
        onTap: () => _openTyping(null),
      ),
    ];
  }

  List<Widget> _listeningBody(AppText text) {
    final seconds = _elapsed.elapsed.inSeconds;
    final elapsed =
        '${seconds ~/ 60}:${(seconds % 60).toString().padLeft(2, '0')}';
    return <Widget>[
      MealoraBackEyebrow(label: text.voiceListeningContextLabel),
      const SizedBox(height: MealoraSpacing.xs),
      Text(text.voiceListeningTitle, style: MealoraTypography.title),
      const SizedBox(height: MealoraSpacing.xxs),
      Text(text.voiceListeningSubtitle, style: MealoraTypography.subtitle),
      const SizedBox(height: MealoraSpacing.lg),
      _RecordingBadge(
        label: text.voiceListeningBadge(elapsed),
        detail: text.voiceListeningMicActive,
        semanticsLabel: text.voiceListeningSemantics,
      ),
      const SizedBox(height: MealoraSpacing.md),
      const _WaveBars(),
      const SizedBox(height: MealoraSpacing.md),
      MealoraCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              text.voiceListeningPartialLabel,
              style: MealoraTypography.eyebrow,
            ),
            const SizedBox(height: MealoraSpacing.xs),
            Semantics(
              liveRegion: true,
              child: Text(
                _partial.isEmpty ? '…' : _partial,
                style: MealoraTypography.body,
              ),
            ),
            const SizedBox(height: MealoraSpacing.xs),
            Text(
              text.voiceListeningPartialHint,
              style: MealoraTypography.caption,
            ),
          ],
        ),
      ),
      const SizedBox(height: MealoraSpacing.md),
      MealoraNoteCard(
        icon: Icons.shield_outlined,
        title: text.voiceOnDeviceTitle,
        body: text.voiceOnDeviceBody,
      ),
      const SizedBox(height: MealoraSpacing.sm),
      Semantics(
        button: true,
        label: text.voiceCancelAction,
        excludeSemantics: true,
        child: Center(
          child: TextButton(
            onPressed: () => unawaited(_cancel()),
            child: Text(
              text.voiceCancelAction,
              textAlign: TextAlign.center,
              style: MealoraTypography.bodyEmphasis.copyWith(
                color: MealoraColors.primaryDeep,
              ),
            ),
          ),
        ),
      ),
    ];
  }
}

/// Lingkaran mikrofon di `42` — satu-satunya kendali untuk mulai merekam.
class _MicButton extends StatelessWidget {
  const _MicButton({
    required this.busy,
    required this.caption,
    required this.semanticsLabel,
    this.onTap,
  });

  final bool busy;
  final String caption;
  final String semanticsLabel;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Semantics(
          button: true,
          enabled: onTap != null,
          label: semanticsLabel,
          excludeSemantics: true,
          // Sama dengan `docs/mealora-v2.pen` (42): halo hijau lembut, lalu
          // lingkaran bergradien CTA dengan bayangan tombol utama.
          child: SizedBox(
            width: 128,
            height: 128,
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                Container(
                  decoration: const BoxDecoration(
                    color: MealoraColors.softGreen,
                    shape: BoxShape.circle,
                  ),
                ),
                Container(
                  width: 96,
                  height: 96,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: MealoraColors.ctaGradient,
                    ),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: MealoraColors.shadowButtonCore,
                        offset: Offset(0, 5),
                        blurRadius: 12,
                      ),
                      BoxShadow(
                        color: MealoraColors.shadowButton,
                        offset: Offset(0, 10),
                        blurRadius: 24,
                      ),
                    ],
                  ),
                  child: Material(
                    color: MealoraColors.transparent,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onTap,
                      child: Center(
                        child: busy
                            ? const SizedBox(
                                width: 32,
                                height: 32,
                                child: CircularProgressIndicator(
                                  color: MealoraColors.onPrimary,
                                  strokeWidth: 3,
                                ),
                              )
                            : const Icon(
                                Icons.mic_none_rounded,
                                size: 38,
                                color: MealoraColors.onPrimary,
                              ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: MealoraSpacing.sm),
        ExcludeSemantics(
          child: Text(
            caption,
            textAlign: TextAlign.center,
            style: MealoraTypography.bodyEmphasis,
          ),
        ),
      ],
    );
  }
}

/// Penanda sedang merekam yang tidak bergantung pada warna saja (task 4.2):
/// label "Merekam · 0:04", ikon mikrofon, titik, dan bingkai tebal.
class _RecordingBadge extends StatelessWidget {
  const _RecordingBadge({
    required this.label,
    required this.detail,
    required this.semanticsLabel,
  });

  final String label;
  final String detail;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      label: semanticsLabel,
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(MealoraSpacing.md),
        decoration: BoxDecoration(
          color: MealoraColors.primary,
          borderRadius: BorderRadius.circular(MealoraRadius.card),
          border: Border.all(color: MealoraColors.primaryDeep, width: 2),
        ),
        child: Row(
          children: <Widget>[
            const Icon(Icons.mic, color: MealoraColors.surface),
            const SizedBox(width: MealoraSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    label,
                    style: MealoraTypography.bodyEmphasis.copyWith(
                      color: MealoraColors.surface,
                    ),
                  ),
                  Text(
                    detail,
                    style: MealoraTypography.caption.copyWith(
                      color: MealoraColors.surface,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: MealoraColors.danger,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WaveBars extends StatelessWidget {
  const _WaveBars();

  static const List<double> _heights = <double>[
    14,
    28,
    40,
    22,
    34,
    48,
    26,
    38,
    18,
    30,
    44,
    24,
    36,
    16,
    28,
    40,
    20,
    32,
  ];

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: SizedBox(
        height: 52,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            for (final h in _heights)
              Container(
                width: 5,
                height: h,
                decoration: BoxDecoration(
                  color: MealoraColors.primaryBright,
                  borderRadius: BorderRadius.circular(MealoraRadius.track),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
