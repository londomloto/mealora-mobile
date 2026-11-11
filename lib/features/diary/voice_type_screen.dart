import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/domain/voice_input/speech_recognizer.dart';
import 'package:mealora/features/diary/voice_input_shared.dart';
import 'package:mealora/features/diary/voice_transcript_screen.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// `45 · Suara tidak tersedia` dan jalur ketik kalimat (change 012, task
/// 3.2/3.4/4.6).
///
/// Layar ini tidak menyentuh mikrofon maupun pengenal ucapan sama sekali,
/// sehingga bekerja tanpa izin dan di perangkat yang tidak mendukung
/// pengenalan ucapan. [reason] `null` berarti pengguna memilih mengetik
/// sendiri, bukan karena suara gagal.
class VoiceTypeScreen extends ConsumerStatefulWidget {
  const VoiceTypeScreen({this.reason, this.date, super.key});

  final SpeechUnavailableReason? reason;
  final LocalDate? date;

  @override
  ConsumerState<VoiceTypeScreen> createState() => _VoiceTypeScreenState();
}

class _VoiceTypeScreenState extends ConsumerState<VoiceTypeScreen> {
  bool _busy = false;
  VoiceParseNotice? _notice;

  Future<void> _parse(String sentence) async {
    setState(() {
      _busy = true;
      _notice = null;
    });
    final notice = await submitVoiceSentence(
      context,
      ref,
      sentence,
      date: widget.date,
    );
    if (!mounted) return;
    setState(() {
      _busy = false;
      _notice = notice;
    });
  }

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final reason = widget.reason;
    final sentence = _controller.text.trim();

    return Scaffold(
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
                    children: <Widget>[
                      MealoraBackEyebrow(
                        label: reason == null
                            ? text.voiceTypeContextLabel
                            : text.voiceUnavailableContextLabel,
                      ),
                      const SizedBox(height: MealoraSpacing.xs),
                      Text(
                        reason == null
                            ? text.voiceTypeTitle
                            : text.voiceUnavailableTitle,
                        style: MealoraTypography.title,
                      ),
                      const SizedBox(height: MealoraSpacing.xxs),
                      Text(
                        reason == null
                            ? text.voiceTypeSubtitle
                            : text.voiceUnavailableSubtitle,
                        style: MealoraTypography.subtitle,
                      ),
                      const SizedBox(height: MealoraSpacing.lg),
                      if (reason != null) ...<Widget>[
                        MealoraNoteCard(
                          icon: Icons.mic_off_outlined,
                          title:
                              reason == SpeechUnavailableReason.permissionDenied
                              ? text.voicePermissionDeniedTitle
                              : text.voiceNotSupportedTitle,
                          body:
                              reason == SpeechUnavailableReason.permissionDenied
                              ? text.voicePermissionDeniedBody
                              : text.voiceNotSupportedBody,
                          background: MealoraColors.iconFieldAmber,
                        ),
                        const SizedBox(height: MealoraSpacing.lg),
                      ],
                      if (_notice case final notice?) ...<Widget>[
                        Semantics(
                          liveRegion: true,
                          child: MealoraNoteCard(
                            icon: Icons.error_outline,
                            title: notice.title,
                            body: notice.body,
                            background: MealoraColors.iconFieldCoral,
                          ),
                        ),
                        const SizedBox(height: MealoraSpacing.md),
                      ],
                      VoiceSentenceField(
                        controller: _controller,
                        label: text.voiceTypeFieldLabel,
                        hint: text.voiceTypeFieldHint,
                        helper: text.voiceTypeFieldHelper,
                      ),
                      const SizedBox(height: MealoraSpacing.md),
                      MealoraNoteCard(
                        icon: Icons.info_outline,
                        title: text.voiceTypeScopeTitle,
                        body: text.voiceTypeScopeBody,
                      ),
                      const SizedBox(height: MealoraSpacing.sm),
                      VoiceTextLink(
                        label: text.voiceCatalogLink,
                        onTap: () =>
                            openVoiceCatalogSearch(context, widget.date),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  MealoraSpacing.programHeroGutter,
                  0,
                  MealoraSpacing.programHeroGutter,
                  MealoraSpacing.lg,
                ),
                child: MealoraPrimaryButton(
                  label: _busy
                      ? text.voiceParsingInProgress
                      : text.voiceParseTypedAction,
                  onPressed: sentence.isEmpty || _busy
                      ? null
                      : () => unawaited(_parse(sentence)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
