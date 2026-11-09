import 'package:flutter/material.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';

/// Baris "label kiri, nilai kanan" dipisah pembatas tipis — pola berulang
/// "Masukan yang dipakai" / "Asumsi" / "Rincian program" di
/// `mealora-v2.pen` (`12`, `30`, `46`).
class FactRow extends StatelessWidget {
  const FactRow({required this.label, required this.value, super.key});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$label: $value',
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: MealoraSpacing.sm),
          child: Row(
            children: <Widget>[
              Expanded(child: Text(label, style: MealoraTypography.bodySmall)),
              const SizedBox(width: MealoraSpacing.sm),
              Flexible(
                child: Text(
                  value,
                  style: MealoraTypography.bodyEmphasis,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kartu kaca berisi beberapa [FactRow], dipisah pembatas tipis di antara
/// baris (bukan di akhir).
class FactsCard extends StatelessWidget {
  const FactsCard({required this.rows, super.key});

  final List<FactRow> rows;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      children.add(rows[i]);
      if (i != rows.length - 1) {
        children.add(const Divider(height: 1, color: MealoraColors.line));
      }
    }
    return MealoraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

/// Penanda keadaan program — ikon + label, tidak pernah warna saja (task
/// 2.5, 9.3, FRS 6.15).
class ProgramStatusChip extends StatelessWidget {
  const ProgramStatusChip({
    required this.label,
    required this.icon,
    this.background = MealoraColors.softGreen,
    this.foreground = MealoraColors.primary,
    super.key,
  });

  final String label;
  final IconData icon;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    // `MealoraChip` punya anak `Icon`+`Text` tanpa node semantik sendiri —
    // tanpa ini pembaca layar tetap membaca teksnya (digabung otomatis),
    // tapi tidak ada satu label eksplisit yang bisa diuji/diandalkan (task
    // 9.2). `excludeSemantics` mencegah anak-anaknya menambah node duplikat.
    return Semantics(
      label: label,
      excludeSemantics: true,
      child: MealoraChip(
        label: label,
        icon: icon,
        background: background,
        foreground: foreground,
      ),
    );
  }
}

/// Kartu hero gradien dengan eyebrow, nilai besar, dan keterangan —
/// dipakai oleh pratinjau target (onboarding), rincian "Bagaimana
/// dihitung" (`46`), dan detail program selesai (`30`).
class TargetHeroCard extends StatelessWidget {
  const TargetHeroCard({
    required this.eyebrow,
    required this.caption,
    this.value,
    this.unit,
    this.noValueNote,
    this.footer,
    super.key,
  });

  final String eyebrow;
  final String? value;
  final String? unit;
  final String caption;
  final String? noValueNote;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(MealoraSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment(0.34, -0.94),
          end: Alignment(-0.34, 0.94),
          colors: MealoraColors.heroGradient,
          stops: MealoraColors.heroGradientStops,
        ),
        borderRadius: BorderRadius.circular(MealoraRadius.cardLarge),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            eyebrow,
            style: MealoraTypography.label.copyWith(
              color: MealoraColors.onPrimary,
            ),
          ),
          const SizedBox(height: MealoraSpacing.sm),
          if (value != null)
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: <Widget>[
                Flexible(
                  child: Text(
                    value!,
                    style: MealoraTypography.display.copyWith(
                      color: MealoraColors.onPrimary,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (unit != null) ...<Widget>[
                  const SizedBox(width: MealoraSpacing.xs),
                  Text(
                    unit!,
                    style: MealoraTypography.body.copyWith(
                      color: MealoraColors.onPrimaryMuted,
                    ),
                  ),
                ],
              ],
            )
          else if (noValueNote != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: MealoraSpacing.sm),
              child: Text(
                noValueNote!,
                style: MealoraTypography.body.copyWith(
                  color: MealoraColors.onPrimary,
                ),
              ),
            ),
          const SizedBox(height: MealoraSpacing.sm),
          Text(
            caption,
            style: MealoraTypography.caption.copyWith(
              color: MealoraColors.onPrimaryMuted,
            ),
          ),
          if (footer != null) ...<Widget>[
            const SizedBox(height: MealoraSpacing.sm),
            footer!,
          ],
        ],
      ),
    );
  }
}

/// Baris kendali dengan ikon, label, dan chevron — dipisah pembatas tipis
/// antar baris (daftar kendali program dijeda `27`, riwayat `29`, baris
/// pengaturan `33`/`34`).
class ProgramControlTile extends StatelessWidget {
  const ProgramControlTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.detail,
    this.semanticsLabel,
    this.enabled = true,
    super.key,
  });

  final IconData icon;
  final String label;
  final String? detail;
  final VoidCallback? onTap;
  final String? semanticsLabel;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: enabled,
      label: semanticsLabel ?? (detail == null ? label : '$label. $detail'),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(MealoraRadius.card),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: MealoraSpacing.sm),
          child: Opacity(
            opacity: enabled ? 1 : 0.5,
            child: MealoraIconRow(
              icon: icon,
              title: label,
              detail: detail,
              trailing: const Icon(
                Icons.chevron_right,
                color: MealoraColors.affordance,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Daftar [ProgramControlTile] dipisah pembatas tipis, dibungkus satu kartu
/// kaca.
class ProgramControlList extends StatelessWidget {
  const ProgramControlList({required this.tiles, super.key});

  final List<ProgramControlTile> tiles;

  @override
  Widget build(BuildContext context) {
    final children = <Widget>[];
    for (var i = 0; i < tiles.length; i++) {
      children.add(tiles[i]);
      if (i != tiles.length - 1) {
        children.add(const Divider(height: 1, color: MealoraColors.line));
      }
    }
    return MealoraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }
}

/// Tiga tombol kendali berdampingan (keadaan aktif `05`: Jeda/Ganti/Riwayat).
class ProgramActionButton extends StatelessWidget {
  const ProgramActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Semantics(
        button: true,
        label: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(MealoraRadius.card),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: MealoraSpacing.md),
            decoration: BoxDecoration(
              color: MealoraColors.glassCard,
              borderRadius: BorderRadius.circular(MealoraRadius.card),
              border: Border.all(color: MealoraColors.glassBorder),
            ),
            child: Column(
              children: <Widget>[
                Icon(
                  icon,
                  color: MealoraColors.primary,
                  size: MealoraIconSize.alert,
                ),
                const SizedBox(height: MealoraSpacing.xxs),
                Text(
                  label,
                  style: MealoraTypography.bodyEmphasis,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
