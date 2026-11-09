import 'dart:ui' show ImageFilter;

import 'package:flutter/material.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/format/id_formatters.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// Latar dekoratif tiga "blob" blur (lime, mint, biru) di belakang layar
/// alur onboarding — sesuai pola yang berulang identik di setiap layar
/// langkah di `mealora-v2.pen` (`08`–`12b`, `25`, `26`, `36`).
///
/// Posisi dan opasitas murni dekoratif (disaring lewat blur berat), jadi
/// nilainya tetap sama persis di semua layar — tidak perlu token terpisah
/// per layar.
class MealoraBlobBackdrop extends StatelessWidget {
  const MealoraBlobBackdrop({required this.child, super.key});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        const Positioned(
          left: 230,
          top: -120,
          child: MealoraBlurBlob(
            color: MealoraColors.lime,
            opacity: 0.3,
            size: 300,
          ),
        ),
        const Positioned(
          left: -130,
          top: 420,
          child: MealoraBlurBlob(
            color: MealoraColors.mint,
            opacity: 0.2,
            size: 300,
          ),
        ),
        const Positioned(
          left: 180,
          top: 640,
          child: MealoraBlurBlob(
            color: MealoraColors.info,
            opacity: 0.14,
            width: 320,
            height: 300,
          ),
        ),
        child,
      ],
    );
  }
}

/// Lingkaran blur lunak tunggal — unit dasar dekorasi "blob" di latar layar
/// kaca (`mealora-v2.pen`). Dipakai langsung (lewat `Positioned`) oleh layar
/// bergradien penuh (splash, welcome) yang punya susunan blob sendiri, dan
/// lewat [MealoraBlobBackdrop] oleh layar alur onboarding.
class MealoraBlurBlob extends StatelessWidget {
  const MealoraBlurBlob({
    required this.color,
    required this.opacity,
    this.size,
    this.width,
    this.height,
    super.key,
  });

  final Color color;
  final double opacity;
  final double? size;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: ImageFiltered(
        imageFilter: ImageFilter.blur(sigmaX: 28, sigmaY: 28),
        child: Container(
          width: width ?? size,
          height: height ?? size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: opacity),
          ),
        ),
      ),
    );
  }
}

/// Tombol primer Mealora.
///
/// Lebar penuh, tinggi memenuhi ambang target sentuh, label dibaca pembaca
/// layar sebagai tombol. Permukaan memakai gradien hijau dan bayangan lunak
/// sesuai "Primary button" di dokumen desain v2; keadaan nonaktif luruh ke
/// permukaan netral datar.
class MealoraPrimaryButton extends StatelessWidget {
  const MealoraPrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon = Icons.arrow_forward,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: enabled
            ? const LinearGradient(
                begin: Alignment(-0.6, -1),
                end: Alignment(0.6, 1),
                colors: MealoraColors.ctaGradient,
              )
            : null,
        color: enabled ? null : MealoraColors.track,
        borderRadius: BorderRadius.circular(MealoraRadius.button),
        boxShadow: enabled
            ? const <BoxShadow>[
                BoxShadow(
                  color: MealoraColors.shadowButton,
                  offset: Offset(0, 10),
                  blurRadius: 24,
                ),
              ]
            : null,
      ),
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: MealoraColors.transparent,
          disabledBackgroundColor: MealoraColors.transparent,
          foregroundColor: MealoraColors.onPrimary,
          disabledForegroundColor: MealoraColors.muted,
          shadowColor: MealoraColors.transparent,
          elevation: 0,
          textStyle: MealoraTypography.button,
          minimumSize: const Size.fromHeight(58),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(MealoraRadius.button),
          ),
        ),
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
      ),
    );
  }
}

/// "Glass chip" — kapsul kaca buram dengan ikon dan label, dipakai untuk
/// status ringkas (mis. "Program aktif").
class MealoraChip extends StatelessWidget {
  const MealoraChip({
    required this.label,
    this.icon,
    this.background = MealoraColors.glassCard,
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
        horizontal: MealoraSpacing.md,
        vertical: MealoraSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(MealoraRadius.chip),
        border: Border.all(color: MealoraColors.glassBorder),
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
              style: MealoraTypography.chipLabel.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}

/// Kartu dasar: permukaan kaca buram (65% putih) bertepi lembut dan bayangan
/// hijau lunak, sesuai bahasa visual "glass surface" di dokumen desain v2.
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
        color: MealoraColors.glassCard,
        borderRadius: BorderRadius.circular(MealoraRadius.card),
        border: Border.all(color: MealoraColors.glassBorder),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: MealoraColors.shadowGlass,
            offset: Offset(0, 14),
            blurRadius: 34,
          ),
        ],
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
    this.errorText,
    this.onChanged,
    super.key,
  });

  final String label;
  final String? hint;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool enabled;

  /// Pesan kesalahan yang sudah siap tampil (mis. `Failure.detail` dari
  /// `ProfileValueRules`) — tampil di bawah isian dengan ikon, bukan warna
  /// saja (task 7.4).
  final String? errorText;

  final ValueChanged<String>? onChanged;

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
          onChanged: onChanged,
          style: MealoraTypography.body,
          decoration: InputDecoration(
            hintText: hint,
            enabledBorder: errorText == null
                ? null
                : OutlineInputBorder(
                    borderRadius: BorderRadius.circular(MealoraRadius.button),
                    borderSide: const BorderSide(color: MealoraColors.danger),
                  ),
            focusedBorder: errorText == null
                ? null
                : OutlineInputBorder(
                    borderRadius: BorderRadius.circular(MealoraRadius.button),
                    borderSide: const BorderSide(
                      color: MealoraColors.danger,
                      width: 2,
                    ),
                  ),
          ),
        ),
        if (errorText != null) ...<Widget>[
          const SizedBox(height: MealoraSpacing.xxs),
          Semantics(
            liveRegion: true,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Icon(
                  Icons.error_outline,
                  size: MealoraIconSize.inline,
                  color: MealoraColors.danger,
                ),
                const SizedBox(width: MealoraSpacing.xxs),
                Expanded(
                  child: Text(
                    errorText!,
                    style: MealoraTypography.caption.copyWith(
                      color: MealoraColors.danger,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Kolom pemilih tanggal berlabel — menampilkan nilai terformat dan membuka
/// pemilih tanggal bawaan saat disentuh. Tidak pernah membaca jam sistem
/// sendiri; [firstDate]/[lastDate] datang dari pemanggil (konvensi change
/// 001).
class MealoraDateField extends StatelessWidget {
  const MealoraDateField({
    required this.label,
    required this.hint,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
    this.value,
    this.errorText,
    this.initialDate,
    super.key,
  });

  final String label;
  final String hint;
  final DateTime? value;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime? initialDate;
  final String? errorText;
  final ValueChanged<DateTime> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(label, style: MealoraTypography.label),
        const SizedBox(height: MealoraSpacing.xs),
        Semantics(
          button: true,
          label: value == null ? '$label. $hint' : '$label. ${_format(value!)}',
          child: InkWell(
            borderRadius: BorderRadius.circular(MealoraRadius.button),
            onTap: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: initialDate ?? value ?? lastDate,
                firstDate: firstDate,
                lastDate: lastDate,
              );
              if (picked != null) {
                onChanged(picked);
              }
            },
            child: InputDecorator(
              decoration: InputDecoration(
                enabledBorder: errorText == null
                    ? null
                    : OutlineInputBorder(
                        borderRadius: BorderRadius.circular(
                          MealoraRadius.button,
                        ),
                        borderSide: const BorderSide(
                          color: MealoraColors.danger,
                        ),
                      ),
              ),
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Text(
                      value == null ? hint : _format(value!),
                      style: value == null
                          ? MealoraTypography.bodyMuted
                          : MealoraTypography.body,
                    ),
                  ),
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: MealoraIconSize.action,
                    color: MealoraColors.muted,
                  ),
                ],
              ),
            ),
          ),
        ),
        if (errorText != null) ...<Widget>[
          const SizedBox(height: MealoraSpacing.xxs),
          Semantics(
            liveRegion: true,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Icon(
                  Icons.error_outline,
                  size: MealoraIconSize.inline,
                  color: MealoraColors.danger,
                ),
                const SizedBox(width: MealoraSpacing.xxs),
                Expanded(
                  child: Text(
                    errorText!,
                    style: MealoraTypography.caption.copyWith(
                      color: MealoraColors.danger,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  String _format(DateTime date) =>
      IdFormat.shortDate(LocalDate(date.year, date.month, date.day));
}

/// Baris ikon bertitik + judul/keterangan — pola berulang "Icon field" +
/// teks di `mealora-v2.pen` (kartu pilihan, lencana program terpilih, baris
/// pengenalan).
class MealoraIconRow extends StatelessWidget {
  const MealoraIconRow({
    required this.icon,
    required this.title,
    this.detail,
    this.iconBackground = MealoraColors.softGreen,
    this.iconForeground = MealoraColors.primary,
    this.trailing,
    this.titleStyle,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? detail;
  final Color iconBackground;
  final Color iconForeground;
  final Widget? trailing;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: iconBackground,
            borderRadius: BorderRadius.circular(MealoraRadius.iconField),
          ),
          child: Icon(
            icon,
            color: iconForeground,
            size: MealoraIconSize.action,
          ),
        ),
        const SizedBox(width: MealoraSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(title, style: titleStyle ?? MealoraTypography.bodyEmphasis),
              if (detail != null) ...<Widget>[
                const SizedBox(height: MealoraSpacing.xxs),
                Text(detail!, style: MealoraTypography.bodySmall),
              ],
            ],
          ),
        ),
        if (trailing != null) ...<Widget>[
          const SizedBox(width: MealoraSpacing.sm),
          trailing!,
        ],
      ],
    );
  }
}

/// Kartu catatan kaca bertitik warna — pola "Note" berulang di hampir setiap
/// layar (`mealora-v2.pen`): ikon, judul opsional, dan isi, di atas
/// permukaan kaca bertint warna sesuai urgensi (netral/hijau/kuning/biru).
class MealoraNoteCard extends StatelessWidget {
  const MealoraNoteCard({
    required this.icon,
    required this.body,
    this.title,
    this.background = MealoraColors.glassSoft,
    this.foreground = MealoraColors.primary,
    super.key,
  });

  final IconData icon;
  final String? title;
  final String body;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MealoraSpacing.md),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(MealoraRadius.chip),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, color: foreground, size: MealoraIconSize.alert),
          const SizedBox(width: MealoraSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (title != null) ...<Widget>[
                  Text(title!, style: MealoraTypography.bodyEmphasis),
                  const SizedBox(height: MealoraSpacing.xxs),
                ],
                Text(body, style: MealoraTypography.bodySmall),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Ubin ikon besar dan bulat di tengah kartu "keadaan" (kosong/galat) —
/// sesuai "Icon field" pada "No current program state" di dokumen desain v2.
class _StateIconTile extends StatelessWidget {
  const _StateIconTile({
    required this.icon,
    required this.background,
    required this.foreground,
    this.size = 68,
  });

  final IconData icon;
  final Color background;
  final Color foreground;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(MealoraRadius.chip),
      ),
      child: Icon(icon, color: foreground, size: MealoraIconSize.alert),
    );
  }
}

/// Keadaan "belum ada data".
///
/// Menjelaskan apa yang akan muncul di ruang ini dan tindakan yang tersedia.
/// Tidak pernah menampilkan angka nol yang menyerupai hasil pengukuran, dan
/// keadaannya ditandai lewat ikon dan teks — bukan warna saja. Mengikuti
/// kartu kaca berisi ubin ikon dan teks tengah di "No current program state"
/// (`mealora-v2.pen`).
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
        children: <Widget>[
          _StateIconTile(
            icon: icon,
            background: MealoraColors.softGreen,
            foreground: MealoraColors.primary,
          ),
          const SizedBox(height: MealoraSpacing.md),
          Text(
            text.emptyStateBadge,
            textAlign: TextAlign.center,
            style: MealoraTypography.caption,
          ),
          const SizedBox(height: MealoraSpacing.xxs),
          Text(
            title,
            textAlign: TextAlign.center,
            style: MealoraTypography.headline,
          ),
          const SizedBox(height: MealoraSpacing.xs),
          Text(
            body,
            textAlign: TextAlign.center,
            style: MealoraTypography.bodySmall,
          ),
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              _StateIconTile(
                icon: Icons.error_outline,
                background: MealoraColors.danger.withValues(alpha: 0.12),
                foreground: MealoraColors.danger,
                size: 48,
              ),
              const SizedBox(width: MealoraSpacing.sm),
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
