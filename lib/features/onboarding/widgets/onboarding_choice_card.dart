import 'package:flutter/material.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';

/// Kartu pilihan tunggal yang dapat dipilih (tingkat aktivitas `09`,
/// program `10`, masukan biologis `08`, fokus kebiasaan `11`).
///
/// Mengikuti kartu kaca ber-ubin ikon di `mealora-v2.pen`: ubin ikon
/// bertint warna (beda per pilihan), judul, keterangan, dan penanda pilihan
/// bulat di kanan. Keadaan terpilih ditandai lewat latar yang lebih padat,
/// warna penanda, DAN `Semantics.selected` — tidak pernah warna saja
/// (task 7.4, FRS 6.15).
class OnboardingChoiceCard extends StatelessWidget {
  const OnboardingChoiceCard({
    required this.title,
    required this.selected,
    required this.onTap,
    this.detail,
    this.leading = Icons.eco_outlined,
    this.leadingBackground = MealoraColors.softGreen,
    this.leadingForeground = MealoraColors.primary,
    super.key,
  });

  final String title;
  final String? detail;
  final IconData leading;
  final Color leadingBackground;
  final Color leadingForeground;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: detail == null ? title : '$title. $detail',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(MealoraRadius.card),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(MealoraSpacing.md),
          decoration: BoxDecoration(
            color: selected ? MealoraColors.glassSoft : MealoraColors.glassCard,
            borderRadius: BorderRadius.circular(MealoraRadius.card),
            border: Border.all(
              color: selected ? MealoraColors.primary : MealoraColors.glassBorder,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: leadingBackground,
                  borderRadius: BorderRadius.circular(MealoraRadius.iconField),
                ),
                child: Icon(leading, color: leadingForeground, size: MealoraIconSize.action),
              ),
              const SizedBox(width: MealoraSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(title, style: MealoraTypography.bodyEmphasis),
                    if (detail != null) ...<Widget>[
                      const SizedBox(height: MealoraSpacing.xxs),
                      Text(detail!, style: MealoraTypography.bodySmall),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: MealoraSpacing.sm),
              Icon(
                selected ? Icons.check_circle : Icons.circle_outlined,
                color: selected ? MealoraColors.primary : MealoraColors.affordance,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
