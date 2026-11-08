import 'package:flutter/material.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// Tombol primer Mealora.
///
/// Lebar penuh, tinggi memenuhi ambang target sentuh, label dibaca pembaca
/// layar sebagai tombol.
class MealoraPrimaryButton extends StatelessWidget {
  const MealoraPrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Flexible(
            child: Text(
              label,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (icon != null) ...<Widget>[
            const SizedBox(width: MealoraSpacing.xs),
            Icon(icon, size: MealoraIconSize.action),
          ],
        ],
      ),
    );
  }
}

class MealoraChip extends StatelessWidget {
  const MealoraChip({
    required this.label,
    this.icon,
    this.background = MealoraColors.softGreen,
    this.foreground = MealoraColors.ink,
    super.key,
  });

  final String label;
  final IconData? icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: MealoraSpacing.sm,
        vertical: MealoraSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(MealoraRadius.chip),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Icon(icon, size: MealoraIconSize.inline, color: foreground),
            const SizedBox(width: MealoraSpacing.xxs),
          ],
          Flexible(
            child: Text(
              label,
              style: MealoraTypography.label.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu dasar: permukaan putih bertepi lembut.
class MealoraCard extends StatelessWidget {
  const MealoraCard({
    required this.child,
    this.padding = const EdgeInsets.all(MealoraSpacing.lg),
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: MealoraColors.surface,
        borderRadius: BorderRadius.circular(MealoraRadius.card),
        border: Border.all(color: MealoraColors.line),
      ),
      child: child,
    );
  }
}

/// Kolom isian berlabel.
class MealoraField extends StatelessWidget {
  const MealoraField({
    required this.label,
    this.hint,
    this.controller,
    this.keyboardType,
    this.enabled = true,
    super.key,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: MealoraTypography.label),
        const SizedBox(height: MealoraSpacing.xs),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          enabled: enabled,
          style: MealoraTypography.body,
          decoration: InputDecoration(hintText: hint),
        ),
      ],
    );
  }
}

/// Keadaan "belum ada data".
///
/// Menjelaskan apa yang akan muncul di ruang ini dan tindakan yang tersedia.
/// Tidak pernah menampilkan angka nol yang menyerupai hasil pengukuran, dan
/// keadaannya ditandai lewat ikon dan teks — bukan warna saja.
class MealoraEmptyState extends StatelessWidget {
  const MealoraEmptyState({
    required this.title,
    required this.body,
    this.icon = Icons.eco_outlined,
    this.action,
    super.key,
  });

  final String title;
  final String body;
  final IconData icon;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return MealoraCard(
      padding: const EdgeInsets.all(MealoraSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          MealoraChip(label: text.emptyStateBadge, icon: icon),
          const SizedBox(height: MealoraSpacing.md),
          Text(title, style: MealoraTypography.sectionTitle),
          const SizedBox(height: MealoraSpacing.xs),
          Text(body, style: MealoraTypography.bodySmall),
          if (action != null) ...<Widget>[
            const SizedBox(height: MealoraSpacing.lg),
            action!,
          ],
        ],
      ),
    );
  }
}

/// Keadaan kesalahan yang dapat dibaca pengguna, beserta tindakan lanjutan.
class MealoraErrorState extends StatelessWidget {
  const MealoraErrorState({
    required this.title,
    required this.body,
    this.detailLabel,
    this.detail,
    this.action,
    super.key,
  });

  final String title;
  final String body;
  final String? detailLabel;
  final String? detail;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    return MealoraCard(
      padding: const EdgeInsets.all(MealoraSpacing.xl),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.error_outline,
                color: MealoraColors.danger,
                size: MealoraIconSize.alert,
              ),
              const SizedBox(width: MealoraSpacing.xs),
              Expanded(
                child: Text(
                  title,
                  style: MealoraTypography.sectionTitle.copyWith(
                    color: MealoraColors.danger,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: MealoraSpacing.sm),
          Text(body, style: MealoraTypography.bodySmall),
          if (detail != null && detailLabel != null) ...<Widget>[
            const SizedBox(height: MealoraSpacing.sm),
            Text('$detailLabel: $detail', style: MealoraTypography.caption),
          ],
          if (action != null) ...<Widget>[
            const SizedBox(height: MealoraSpacing.lg),
            action!,
          ],
        ],
      ),
    );
  }
}
