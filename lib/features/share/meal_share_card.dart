import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/core/format/id_formatters.dart';
import 'package:mealora/features/share/share_card_frame.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// Satu komponen yang baru dicatat dari foto.
final class MealShareItem {
  const MealShareItem({
    required this.name,
    required this.portion,
    required this.kcal,
  });

  final String name;

  /// Porsi siap tampil, mis. `1 × piring`.
  final String portion;

  /// `null` bila energi komponen belum diketahui.
  final double? kcal;
}

/// Data kartu makanan (jalur foto saja, change 014).
final class MealShareData {
  const MealShareData({
    required this.mealTimeLabel,
    required this.items,
    required this.photoPath,
  });

  final String mealTimeLabel;
  final List<MealShareItem> items;

  /// `null` bila foto tidak lagi ada — kartu memakai latar pengganti.
  final String? photoPath;

  double get totalKcal =>
      items.fold<double>(0, (sum, item) => sum + (item.kcal ?? 0));
}

/// `62 · Kartu Makanan` (task 3.4): foto penuh, chip watermark + waktu
/// makan, dan panel mengambang berisi setiap komponen (nama, porsi, energi)
/// serta total.
class MealShareCard extends StatelessWidget {
  const MealShareCard({required this.data, super.key});

  /// Komponen maksimal yang ditampilkan agar panel tetap di area aman;
  /// sisanya diringkas menjadi "+N lainnya".
  static const int maxVisibleItems = 5;

  final MealShareData data;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final photo = data.photoPath;
    final visible = data.items.take(maxVisibleItems).toList();
    final hidden = data.items.length - visible.length;

    return ShareCardFrame(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: MealoraColors.shareCardPhotoFallback,
        ),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          if (photo != null)
            Image.file(
              File(photo),
              fit: BoxFit.cover,
              // Decode seukuran kartu (1080 px) supaya foto kamera besar
              // tidak memboroskan memori (Design, Risks).
              cacheWidth: (ShareCardSize.width * ShareCardSize.pixelRatio)
                  .round(),
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          const Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: 150,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  colors: <Color>[
                    MealoraColors.shareCardScrimClear,
                    MealoraColors.shareCardScrim,
                  ],
                ),
              ),
            ),
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 240,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: <Color>[
                    MealoraColors.shareCardScrimClear,
                    MealoraColors.shareCardScrim,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: MealoraSpacing.md,
            right: MealoraSpacing.md,
            top: 20,
            child: Row(
              children: <Widget>[
                const ShareWatermarkChip(),
                const Spacer(),
                Container(
                  height: 34,
                  padding: const EdgeInsets.symmetric(horizontal: 13),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: MealoraColors.shareCardDarkChip,
                    borderRadius: BorderRadius.circular(MealoraRadius.pill),
                    border: Border.all(
                      color: MealoraColors.shareCardDarkChipBorder,
                    ),
                  ),
                  child: Text(
                    data.mealTimeLabel,
                    style: MealoraTypography.shareCardChipLabel,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: MealoraSpacing.md,
            right: MealoraSpacing.md,
            bottom: MealoraSpacing.md,
            child: Container(
              padding: const EdgeInsets.all(MealoraSpacing.md),
              decoration: BoxDecoration(
                color: MealoraColors.surface,
                borderRadius: BorderRadius.circular(MealoraRadius.choiceCard),
                boxShadow: const <BoxShadow>[
                  BoxShadow(
                    color: MealoraColors.shadowShareCard,
                    offset: Offset(0, 14),
                    blurRadius: 34,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  for (var i = 0; i < visible.length; i++) ...<Widget>[
                    if (i > 0) const Divider(height: 13),
                    _ItemRow(item: visible[i], text: text),
                  ],
                  if (hidden > 0) ...<Widget>[
                    const SizedBox(height: MealoraSpacing.xxs),
                    Text(
                      text.shareCardMoreItems(hidden),
                      style: MealoraTypography.shareCardItemDetail,
                    ),
                  ],
                  const SizedBox(height: MealoraSpacing.sm),
                  Container(
                    height: 64,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: MealoraColors.shareCardField,
                      border: Border.all(color: MealoraColors.line),
                      borderRadius: BorderRadius.circular(MealoraRadius.chip),
                    ),
                    child: Row(
                      children: <Widget>[
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: MealoraColors.iconFieldAmber,
                            borderRadius: BorderRadius.circular(
                              MealoraRadius.compactIconField,
                            ),
                          ),
                          child: const Icon(
                            Icons.local_fire_department_outlined,
                            size: 20,
                            color: MealoraColors.accent,
                          ),
                        ),
                        const SizedBox(width: MealoraSpacing.sm),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Text(
                                text.shareCardTotalLabel,
                                style: MealoraTypography.shareCardTotalLabel,
                              ),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                alignment: Alignment.centerLeft,
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.baseline,
                                  textBaseline: TextBaseline.alphabetic,
                                  children: <Widget>[
                                    Text(
                                      '±${IdFormat.integer(data.totalKcal)}',
                                      style:
                                          MealoraTypography.shareCardTotalValue,
                                    ),
                                    const SizedBox(width: 5),
                                    Text(
                                      text.unitKilocalorie,
                                      style:
                                          MealoraTypography.shareCardTotalUnit,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ItemRow extends StatelessWidget {
  const _ItemRow({required this.item, required this.text});

  final MealShareItem item;
  final AppText text;

  @override
  Widget build(BuildContext context) {
    final kcal = item.kcal;
    return Row(
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                item.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: MealoraTypography.shareCardItemName,
              ),
              Text(
                item.portion,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: MealoraTypography.shareCardItemDetail,
              ),
            ],
          ),
        ),
        const SizedBox(width: MealoraSpacing.xs),
        Text(
          kcal == null
              ? text.nutrientValueUnknown
              : '±${IdFormat.integer(kcal)} ${text.unitKilocalorie}',
          style: MealoraTypography.shareCardItemKcal,
        ),
      ],
    );
  }
}
