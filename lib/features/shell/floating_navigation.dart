import 'package:flutter/material.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/features/shell/destinations.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// Navigasi kapsul mengambang untuk empat ruang utama, dengan tombol Catat
/// yang terangkat di tengah.
///
/// Mengikuti `Component · floating navigation` di `docs/mealora.pen`: kapsul
/// putih berbayang, dua tujuan di kiri, dua di kanan, dan lingkaran hijau
/// bertepi putih yang menyembul di atas kapsul.
///
/// Ruang aktif ditandai tiga cara sekaligus — bentuk ikon berubah, label
/// menebal, dan latar kapsul lembut muncul — sehingga tidak bergantung pada
/// perbedaan warna saja.
class FloatingNavigation extends StatelessWidget {
  const FloatingNavigation({
    required this.selected,
    required this.onSelected,
    required this.onRecord,
    super.key,
  });

  final MealoraDestination selected;
  final ValueChanged<MealoraDestination> onSelected;

  /// Ditekan saat pengguna memilih tombol Catat.
  final VoidCallback onRecord;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);

    final leading = MealoraDestination.values.take(2);
    final trailing = MealoraDestination.values.skip(2);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          MealoraSpacing.lg,
          0,
          MealoraSpacing.lg,
          MealoraSpacing.md,
        ),
        child: Stack(
          alignment: Alignment.topCenter,
          clipBehavior: Clip.none,
          children: <Widget>[
            Padding(
              // Memberi ruang bagi bagian tombol Catat yang menyembul ke atas.
              padding: const EdgeInsets.only(top: MealoraSpacing.lg),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: MealoraColors.navigationSurface,
                  borderRadius: BorderRadius.circular(MealoraRadius.pill),
                  border: Border.all(color: MealoraColors.line),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: MealoraColors.shadow.withValues(alpha: 0.13),
                      offset: const Offset(0, 8),
                      blurRadius: 24,
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(MealoraSpacing.xxs),
                  child: Row(
                    children: <Widget>[
                      for (final destination in leading)
                        Expanded(child: _slot(text, destination)),
                      // Celah tempat tombol Catat duduk.
                      const SizedBox(width: MealoraTouch.raisedAction),
                      for (final destination in trailing)
                        Expanded(child: _slot(text, destination)),
                    ],
                  ),
                ),
              ),
            ),
            _RecordButton(
              semanticsLabel: text.navRecordSemantics,
              onTap: onRecord,
            ),
          ],
        ),
      ),
    );
  }

  Widget _slot(AppText text, MealoraDestination destination) {
    final label = destination.label(text);
    return _NavigationSlot(
      destination: destination,
      label: label,
      isSelected: destination == selected,
      semanticsLabel: destination == selected
          ? text.navSelectedSemantics(label)
          : text.navUnselectedSemantics(label),
      onTap: () => onSelected(destination),
    );
  }
}

/// Tombol Catat yang terangkat di tengah kapsul.
///
/// Diameternya sudah memenuhi ambang target sentuh, dan tepinya putih supaya
/// tetap terbaca di atas kapsul maupun di atas latar layar.
class _RecordButton extends StatelessWidget {
  const _RecordButton({required this.semanticsLabel, required this.onTap});

  final String semanticsLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticsLabel,
      container: true,
      excludeSemantics: true,
      onTap: onTap,
      child: Container(
        width: MealoraTouch.raisedAction,
        height: MealoraTouch.raisedAction,
        decoration: BoxDecoration(
          color: MealoraColors.primary,
          shape: BoxShape.circle,
          border: Border.all(
            color: MealoraColors.onPrimary,
            width: MealoraSpacing.xxs,
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: MealoraColors.shadow.withValues(alpha: 0.25),
              offset: const Offset(0, 6),
              blurRadius: 16,
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onTap,
            customBorder: const CircleBorder(),
            child: const Icon(
              Icons.add_rounded,
              size: MealoraIconSize.raisedAction,
              color: MealoraColors.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigationSlot extends StatelessWidget {
  const _NavigationSlot({
    required this.destination,
    required this.label,
    required this.isSelected,
    required this.semanticsLabel,
    required this.onTap,
  });

  final MealoraDestination destination;
  final String label;
  final bool isSelected;
  final String semanticsLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final foreground = isSelected ? MealoraColors.primary : MealoraColors.muted;

    return Semantics(
      button: true,
      selected: isSelected,
      label: semanticsLabel,
      container: true,
      excludeSemantics: true,
      onTap: onTap,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(MealoraRadius.pill),
        child: Container(
          constraints: const BoxConstraints(minHeight: MealoraTouch.minTarget),
          padding: const EdgeInsets.symmetric(
            vertical: MealoraSpacing.xs,
            horizontal: MealoraSpacing.xxs,
          ),
          decoration: BoxDecoration(
            color: isSelected ? MealoraColors.softGreen : null,
            borderRadius: BorderRadius.circular(MealoraRadius.pill),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                isSelected ? destination.selectedIcon : destination.icon,
                size: MealoraIconSize.navigation,
                color: foreground,
              ),
              const SizedBox(height: MealoraSpacing.xxs / 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: MealoraTypography.navigationLabel.copyWith(
                  color: isSelected ? MealoraColors.ink : MealoraColors.muted,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontVariations: <FontVariation>[
                    FontVariation(
                      'wght',
                      isSelected
                          ? MealoraTypography.bold
                          : MealoraTypography.regular,
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
