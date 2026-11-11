import 'package:flutter/material.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/app/widgets/mealora_components.dart';

/// Satu baris tautan di kartu pengaturan (`33`, `66`).
class SettingsListItem {
  const SettingsListItem({
    required this.icon,
    required this.color,
    required this.background,
    required this.label,
    this.detail,
    this.onTap,
  });
  final IconData icon;
  final Color color;
  final Color background;
  final String label;

  /// Keterangan kecil di bawah label (mis. status Pengingat, `47`).
  final String? detail;
  final VoidCallback? onTap;
}

/// Kartu kaca berisi baris-baris tautan dengan pemisah tipis.
class SettingsListCard extends StatelessWidget {
  const SettingsListCard({required this.items, super.key});
  final List<SettingsListItem> items;

  @override
  Widget build(BuildContext context) {
    return MealoraCard(
      child: Column(
        children: <Widget>[
          for (var i = 0; i < items.length; i++) ...<Widget>[
            _SettingsRow(item: items[i]),
            if (i != items.length - 1)
              const Divider(height: 1, color: MealoraColors.line),
          ],
        ],
      ),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  const _SettingsRow({required this.item});
  final SettingsListItem item;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      child: ConstrainedBox(
        // Tinggi minimum, bukan tetap: baris berketerangan (`47`) tetap
        // terbaca pada skala teks besar.
        constraints: const BoxConstraints(minHeight: 58),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: MealoraSpacing.xs),
          child: Row(
            children: <Widget>[
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: item.background,
                  borderRadius: BorderRadius.circular(
                    MealoraRadius.compactIconField,
                  ),
                ),
                child: Icon(item.icon, color: item.color, size: 18),
              ),
              const SizedBox(width: MealoraSpacing.sm),
              Expanded(
                child: item.detail == null
                    ? Text(item.label, style: MealoraTypography.bodyEmphasis)
                    : Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            item.label,
                            style: MealoraTypography.bodyEmphasis,
                          ),
                          Text(item.detail!, style: MealoraTypography.caption),
                        ],
                      ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: MealoraColors.affordance,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
