import 'dart:async' show unawaited;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/features/share/share_service.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// `58 · Pratinjau bagikan` (task 1.5): kartu yang SAMA persis dengan yang
/// dirender ke PNG (Design D2), lalu tombol Bagikan membuka lembar berbagi
/// sistem. Berfungsi tanpa koneksi.
class SharePreviewScreen extends ConsumerStatefulWidget {
  const SharePreviewScreen({
    required this.card,
    required this.caption,
    super.key,
  });

  /// Kartu 360×640 (mis. `DailySummaryShareCard`, `MealShareCard`).
  final Widget card;
  final String caption;

  @override
  ConsumerState<SharePreviewScreen> createState() => _SharePreviewScreenState();
}

class _SharePreviewScreenState extends ConsumerState<SharePreviewScreen> {
  final GlobalKey _boundaryKey = GlobalKey();
  bool _sharing = false;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return Scaffold(
      backgroundColor: MealoraColors.background,
      body: MealoraBlobBackdrop(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              MealoraSpacing.screenGutter,
              MealoraSpacing.md,
              MealoraSpacing.screenGutter,
              MealoraSpacing.lg,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Expanded(
                      child: Text(
                        text.sharePreviewTitle,
                        style: MealoraTypography.title,
                      ),
                    ),
                    IconButton(
                      tooltip: text.sharePreviewCloseSemantics,
                      onPressed: () => Navigator.of(context).pop(),
                      style: IconButton.styleFrom(
                        backgroundColor: MealoraColors.glassStrong,
                        minimumSize: const Size.square(44),
                      ),
                      icon: const Icon(Icons.close, color: MealoraColors.ink),
                    ),
                  ],
                ),
                const SizedBox(height: MealoraSpacing.md),
                Expanded(
                  child: Center(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(
                          MealoraRadius.shareCard,
                        ),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                            color: MealoraColors.shadowShareCard,
                            offset: Offset(0, 14),
                            blurRadius: 34,
                          ),
                        ],
                      ),
                      child: FittedBox(
                        child: RepaintBoundary(
                          key: _boundaryKey,
                          child: widget.card,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: MealoraSpacing.sm),
                Text(
                  widget.caption,
                  textAlign: TextAlign.center,
                  style: MealoraTypography.caption,
                ),
                const SizedBox(height: MealoraSpacing.md),
                MealoraNoteCard(
                  icon: Icons.phone_android_outlined,
                  body: text.sharePreviewLocalNote,
                  background: MealoraColors.glassStrong,
                  foreground: MealoraColors.muted,
                ),
                const SizedBox(height: MealoraSpacing.md),
                MealoraPrimaryButton(
                  label: text.shareAction,
                  icon: Icons.ios_share,
                  onPressed: _sharing ? null : () => unawaited(_share()),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _share() async {
    final boundary =
        _boundaryKey.currentContext?.findRenderObject()
            as RenderRepaintBoundary?;
    if (boundary == null) return;
    setState(() => _sharing = true);
    try {
      await ref.read(shareCardServiceProvider).share(boundary);
    } on Object {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppText.of(context).shareFailedMessage)),
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }
}
