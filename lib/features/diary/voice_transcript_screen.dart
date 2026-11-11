import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/features/diary/voice_input_shared.dart';
import 'package:mealora/features/diary/voice_record_screen.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// `44 · Tinjau transkrip` (change 012, task 4.3-4.5): teks hasil
/// pengenalan dapat disunting sebelum diurai, dinyatakan bisa keliru, dan
/// menawarkan rekam ulang serta katalog. Tidak ada catatan yang dibuat di
/// layar ini.
class VoiceTranscriptScreen extends ConsumerStatefulWidget {
  const VoiceTranscriptScreen({required this.transcript, this.date, super.key});

  final String transcript;
  final LocalDate? date;

  @override
  ConsumerState<VoiceTranscriptScreen> createState() =>
      _VoiceTranscriptScreenState();
}

class _VoiceTranscriptScreenState extends ConsumerState<VoiceTranscriptScreen> {
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

  late final TextEditingController _controller = TextEditingController(
    text: widget.transcript,
  );

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

  void _rerecord() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => VoiceRecordScreen(date: widget.date),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
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
                      MealoraBackEyebrow(label: text.voiceReviewContextLabel),
                      const SizedBox(height: MealoraSpacing.xs),
                      Text(
                        text.voiceReviewTitle,
                        style: MealoraTypography.title,
                      ),
                      const SizedBox(height: MealoraSpacing.xxs),
                      Text(
                        text.voiceReviewSubtitle,
                        style: MealoraTypography.subtitle,
                      ),
                      const SizedBox(height: MealoraSpacing.lg),
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
                        label: text.voiceReviewFieldLabel,
                        helper: text.voiceReviewFieldHint,
                        icon: Icons.edit_outlined,
                        labelInside: true,
                      ),
                      const SizedBox(height: MealoraSpacing.md),
                      MealoraNoteCard(
                        icon: Icons.shield_outlined,
                        title: text.voiceRecordingDeletedTitle,
                        body: text.voiceRecordingDeletedBody,
                      ),
                      const SizedBox(height: MealoraSpacing.sm),
                      MealoraNoteCard(
                        icon: Icons.wifi,
                        title: text.voiceParseNeedsInternetTitle,
                        body: text.voiceParseNeedsInternetBody,
                        background: MealoraColors.iconFieldBlue,
                        foreground: MealoraColors.info,
                      ),
                      const SizedBox(height: MealoraSpacing.md),
                      OutlinedButton.icon(
                        onPressed: _rerecord,
                        icon: const Icon(Icons.replay),
                        label: Text(text.voiceRerecordAction),
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
                        ),
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
                      : text.voiceParseAction,
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

/// Kotak teks kalimat yang dapat disunting, dipakai `44` dan `45`.
///
/// Satu kartu saja, mengikuti `docs/mealora-v2.pen`: teks kalimat dan teks
/// bantu kecil di dalam kartu, tanpa kotak isian kedua. Pada `45` [label]
/// tampil sebagai judul di atas kartu; pada `44` ([labelInside]) sebagai
/// label kecil di dalam kartu bersama ikon sunting.
class VoiceSentenceField extends StatelessWidget {
  const VoiceSentenceField({
    required this.controller,
    required this.label,
    required this.helper,
    this.hint,
    this.icon,
    this.labelInside = false,
    super.key,
  });

  final TextEditingController controller;
  final String label;
  final String helper;
  final String? hint;
  final IconData? icon;
  final bool labelInside;

  @override
  Widget build(BuildContext context) {
    final field = Semantics(
      label: label,
      child: ConstrainedBox(
        // Target sentuh minimal 48 px meski padding isian dihapus.
        constraints: const BoxConstraints(minHeight: 48),
        child: TextField(
          controller: controller,
          minLines: 2,
          maxLines: 6,
          maxLength: 500,
          keyboardType: TextInputType.multiline,
          style: MealoraTypography.body.copyWith(
            fontSize: labelInside ? 16 : 15,
            height: 1.4,
          ),
          decoration: InputDecoration(
            isCollapsed: true,
            // Tema isian aplikasi punya padding sendiri; di sini teks harus
            // sejajar dengan teks bantu di bawahnya.
            contentPadding: EdgeInsets.zero,
            filled: false,
            hintText: hint,
            hintStyle: MealoraTypography.body.copyWith(
              color: MealoraColors.muted,
            ),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            counterText: '',
          ),
        ),
      ),
    );

    final card = MealoraCard(
      padding: const EdgeInsets.fromLTRB(
        MealoraSpacing.lg,
        MealoraSpacing.md,
        MealoraSpacing.lg,
        MealoraSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (labelInside) ...<Widget>[
            ExcludeSemantics(
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(label, style: MealoraTypography.eyebrow),
                  ),
                  if (icon != null)
                    Icon(icon, size: 18, color: MealoraColors.primary),
                ],
              ),
            ),
            const SizedBox(height: MealoraSpacing.sm),
          ],
          field,
          const SizedBox(height: MealoraSpacing.xs),
          Text(helper, style: MealoraTypography.caption),
        ],
      ),
    );

    if (labelInside) return card;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        Semantics(
          header: true,
          child: Text(label, style: MealoraTypography.sectionTitle),
        ),
        const SizedBox(height: MealoraSpacing.sm),
        card,
      ],
    );
  }
}
