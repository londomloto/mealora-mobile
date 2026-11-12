import 'dart:ui' show BlurStyle, ImageFilter, MaskFilter;

import 'package:flutter/material.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/format/id_formatters.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// Baris eyebrow dengan tombol kembali (`Navigator.pop`), untuk layar yang
/// dibuka lewat `Navigator.push` dan memakai header eyebrow/judul/subjudul
/// alih-alih `AppBar` (mis. layar tinjau atau isian).
///
/// Layar seperti ini SHALL selalu menawarkan jalan kembali yang terlihat —
/// gestur kembali OS/browser tidak selalu ada (tidak ada sama sekali di
/// target web). Jangan dipakai pada ruang utama navigasi bawah (tidak
/// pernah di-push, tidak pernah perlu kembali).
class MealoraBackEyebrow extends StatelessWidget {
  const MealoraBackEyebrow({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    return Row(
      children: <Widget>[
        Semantics(
          button: true,
          label: text.backButtonSemantics,
          child: InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(MealoraRadius.pill),
            child: const Padding(
              padding: EdgeInsets.all(MealoraSpacing.xxs),
              child: Icon(Icons.arrow_back, color: MealoraColors.ink),
            ),
          ),
        ),
        Expanded(child: Text(label, style: MealoraTypography.eyebrow)),
      ],
    );
  }
}

/// Bidang hero bersama untuk tiga tab utama. Menyatukan tinggi, gradien,
/// radius, dan glow agar perpindahan Hari ini ↔ Program ↔ Riwayat tidak
/// terasa meloncat.
class MealoraMainHero extends StatelessWidget {
  const MealoraMainHero({required this.height, required this.child, super.key});

  final double height;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: MealoraColors.heroGradient,
          stops: MealoraColors.heroGradientStops,
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(MealoraRadius.programHeroBottom),
          bottomRight: Radius.circular(MealoraRadius.programHeroBottom),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: <Widget>[
          const Positioned.fill(
            child: CustomPaint(painter: _MealoraMainHeroGlowPainter()),
          ),
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _MealoraMainHeroGlowPainter extends CustomPainter {
  const _MealoraMainHeroGlowPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.width / 390;
    canvas.drawCircle(
      Offset(355 * scale, 55 * scale),
      125 * scale,
      Paint()
        ..color = MealoraColors.lime.withValues(alpha: 0.36)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 60 * scale),
    );
    canvas.drawOval(
      Rect.fromLTWH(-70 * scale, 90 * scale, 230 * scale, 200 * scale),
      Paint()
        ..color = MealoraColors.accent.withValues(alpha: 0.25)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 70 * scale),
    );
  }

  @override
  bool shouldRepaint(_MealoraMainHeroGlowPainter oldDelegate) => false;
}

/// Indikator pilihan lingkaran yang digambar langsung agar konsisten pada
/// web dan tidak bergantung pada ketersediaan glyph font ikon.
class MealoraCircleCheck extends StatelessWidget {
  const MealoraCircleCheck({required this.selected, this.size = 22, super.key});

  final bool selected;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _CircleCheckPainter(selected: selected)),
    );
  }
}

/// Checkbox persegi untuk pilihan yang dapat aktif lebih dari satu.
class MealoraSquareCheck extends StatelessWidget {
  const MealoraSquareCheck({required this.selected, this.size = 20, super.key});

  final bool selected;
  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(painter: _SquareCheckPainter(selected: selected)),
    );
  }
}

class _CircleCheckPainter extends CustomPainter {
  const _CircleCheckPainter({required this.selected});

  final bool selected;

  @override
  void paint(Canvas canvas, Size size) {
    final color = selected
        ? MealoraColors.primary
        : MealoraColors.selectionIdle;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, (size.shortestSide - 2) / 2, stroke);
    if (selected) {
      final check = Path()
        ..moveTo(size.width * 0.28, size.height * 0.52)
        ..lineTo(size.width * 0.44, size.height * 0.68)
        ..lineTo(size.width * 0.74, size.height * 0.34);
      canvas.drawPath(check, stroke);
    }
  }

  @override
  bool shouldRepaint(_CircleCheckPainter oldDelegate) =>
      oldDelegate.selected != selected;
}

class _SquareCheckPainter extends CustomPainter {
  const _SquareCheckPainter({required this.selected});

  final bool selected;

  @override
  void paint(Canvas canvas, Size size) {
    final color = selected
        ? MealoraColors.primary
        : MealoraColors.selectionIdle;
    final stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Offset.zero & size,
        Radius.circular(size.shortestSide * 0.18),
      ).deflate(1),
      stroke,
    );
    if (selected) {
      final check = Path()
        ..moveTo(size.width * 0.25, size.height * 0.52)
        ..lineTo(size.width * 0.43, size.height * 0.69)
        ..lineTo(size.width * 0.76, size.height * 0.32);
      canvas.drawPath(check, stroke);
    }
  }

  @override
  bool shouldRepaint(_SquareCheckPainter oldDelegate) =>
      oldDelegate.selected != selected;
}

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
    return SizedBox.expand(
      child: Stack(
        fit: StackFit.expand,
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
          Positioned.fill(child: child),
        ],
      ),
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
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: MealoraColors.ctaGradient,
              )
            : null,
        color: enabled ? null : MealoraColors.track,
        borderRadius: BorderRadius.circular(MealoraRadius.button),
        boxShadow: enabled
            ? const <BoxShadow>[
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

/// Tombol sekunder kaca (rancangan `.pen` layar 83/90 — "Tempel ulang",
/// "Foto", "Foto ulang", "Isi manual"): latar kaca, border hijau muda,
/// tinggi 56, label tebal warna ink, ikon abu.
class MealoraGlassButton extends StatelessWidget {
  const MealoraGlassButton({
    required this.label,
    required this.icon,
    required this.onPressed,
    super.key,
  });

  final String label;
  final IconData icon;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: MealoraIconSize.action),
      label: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(56),
        padding: const EdgeInsets.symmetric(horizontal: MealoraSpacing.sm),
        backgroundColor: MealoraColors.glassSoft,
        foregroundColor: MealoraColors.ink,
        iconColor: MealoraColors.muted,
        side: const BorderSide(color: MealoraColors.secondaryButtonBorder),
        textStyle: MealoraTypography.button.copyWith(
          color: MealoraColors.ink,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(MealoraRadius.button),
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
    this.radius = MealoraRadius.card,
    super.key,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: MealoraColors.shadowGlass,
            offset: Offset(0, 14),
            blurRadius: 34,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: double.infinity,
            padding: padding,
            decoration: BoxDecoration(
              color: MealoraColors.glassCard,
              borderRadius: BorderRadius.circular(radius),
              border: Border.all(color: MealoraColors.glassBorder),
            ),
            child: child,
          ),
        ),
      ),
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
    this.borderColor = MealoraColors.glassBorder,
    this.onTap,
    this.semanticsLabel,
    super.key,
  });

  final IconData icon;
  final String? title;
  final String body;
  final Color background;
  final Color foreground;
  final Color borderColor;

  /// Menjadikan kartu ini bisa diketuk (mis. usulan peninjauan target,
  /// change 008) — menampilkan panah afordansi dan membungkusnya dengan
  /// `Semantics(button: true)`. `null` berarti kartu murni informatif,
  /// seperti sebelumnya.
  final VoidCallback? onTap;

  /// Label pembaca layar saat [onTap] terisi — SHALL diisi bersama [onTap]
  /// supaya maksud ketukan terumumkan, bukan sekadar menyebut ikon/judul.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MealoraSpacing.md),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(MealoraRadius.chip),
        border: Border.all(color: borderColor),
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
          if (onTap != null) ...<Widget>[
            const SizedBox(width: MealoraSpacing.xs),
            const Icon(
              Icons.chevron_right,
              color: MealoraColors.affordance,
              size: MealoraIconSize.action,
            ),
          ],
        ],
      ),
    );

    if (onTap == null) {
      return card;
    }
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Material(
        color: MealoraColors.transparent,
        borderRadius: BorderRadius.circular(MealoraRadius.chip),
        child: InkWell(
          borderRadius: BorderRadius.circular(MealoraRadius.chip),
          onTap: onTap,
          child: card,
        ),
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
