import 'package:flutter/material.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/format/id_formatters.dart';
import 'package:mealora/domain/food/partial_nutrition_total.dart';
import 'package:mealora/features/share/share_card_frame.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// Data kartu ringkasan harian — sengaja HANYA berisi angka gizi hari itu.
/// Tidak ada berat, profil, maupun program (spec, "Kartu tidak memuat data
/// sensitif").
final class DailySummaryShareData {
  const DailySummaryShareData({
    required this.date,
    required this.consumedKcal,
    required this.targetKcal,
    required this.proteinG,
    required this.carbohydrateG,
    required this.fatG,
  });

  final LocalDate date;

  /// Energi hari itu (change 021, design D1): catatan berenergi kosong
  /// dihitung belum diketahui, bukan nol.
  final PartialSum consumedKcal;

  /// `null` bila program tidak menampilkan target energi — kartu lalu tidak
  /// menampilkan "dari … kkal" maupun persentase.
  final double? targetKcal;

  /// Makro hari itu, parsial seperti [consumedKcal] (change 021).
  final PartialSum proteinG;
  final PartialSum carbohydrateG;
  final PartialSum fatG;

  /// Dibulatkan ke bilangan bulat dan boleh melebihi 100% (Design D5).
  /// `null` bila energi belum lengkap — persentase yang salah lebih buruk
  /// daripada tanpa persentase (change 021).
  int? get percentOfTarget {
    final target = targetKcal;
    if (target == null || target <= 0 || !consumedKcal.isComplete) return null;
    return (consumedKcal.known / target * 100).round();
  }
}

/// `59 · Kartu Ringkasan Harian` (task 2.1).
class DailySummaryShareCard extends StatelessWidget {
  const DailySummaryShareCard({required this.data, super.key});

  final DailySummaryShareData data;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final target = data.targetKcal;
    final percent = data.percentOfTarget;
    final ratio = target == null || target <= 0
        ? null
        : (data.consumedKcal.known / target).clamp(0, 1).toDouble();
    String grams(PartialSum v) => v.isUnknown
        ? text.nutrientValueUnknown
        : '${v.isComplete ? '' : '≥\u00A0'}${IdFormat.integer(v.known)}';

    return ShareCardFrame(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: MealoraColors.shareCardGradient,
          stops: <double>[0, 0.5, 1],
        ),
      ),
      child: Stack(
        children: <Widget>[
          const Positioned(
            left: 210,
            top: -80,
            child: MealoraShareBlob(color: MealoraColors.lime),
          ),
          const Positioned(
            left: -100,
            top: 360,
            child: MealoraShareBlob(color: MealoraColors.mint),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              ShareCardSize.safeInset,
              104,
              ShareCardSize.safeInset,
              84,
            ),
            child: Column(
              children: <Widget>[
                Text(
                  IdFormat.longDate(data.date).toUpperCase(),
                  textAlign: TextAlign.center,
                  style: MealoraTypography.shareCardDate,
                ),
                const SizedBox(height: 38),
                SizedBox.square(
                  dimension: 230,
                  child: CustomPaint(
                    painter: _ShareRingPainter(ratio: ratio),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          FittedBox(
                            child: Text(
                              data.consumedKcal.isUnknown
                                  ? text.nutrientValueUnknown
                                  : IdFormat.integer(data.consumedKcal.known),
                              style: MealoraTypography.shareCardRingValue,
                            ),
                          ),
                          if (!data.consumedKcal.isComplete &&
                              !data.consumedKcal.isUnknown)
                            Text(
                              text.nutritionPartialSuffix(
                                data.consumedKcal.unknownCount,
                              ),
                              style: MealoraTypography.shareCardRingUnit,
                            ),
                          Text(
                            target == null
                                ? text.unitKilocalorie
                                : text.shareCardOfTarget(
                                    IdFormat.integer(target),
                                  ),
                            style: MealoraTypography.shareCardRingUnit,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 38),
                if (percent != null)
                  Text(
                    text.shareCardPercentOfTarget(percent),
                    style: MealoraTypography.shareCardTarget,
                  ),
                const SizedBox(height: MealoraSpacing.xs),
                Text(
                  text.shareCardMacroLine(
                    grams(data.proteinG),
                    grams(data.carbohydrateG),
                    grams(data.fatG),
                  ),
                  textAlign: TextAlign.center,
                  style: MealoraTypography.shareCardMacro,
                ),
                const Spacer(),
                const ShareWatermark(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Gumpalan cahaya buram di kartu (`Blob lime`/`Blob mint`, opasitas 26%).
class MealoraShareBlob extends StatelessWidget {
  const MealoraShareBlob({required this.color, super.key});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: 260,
        height: 260,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: <Color>[
              color.withValues(alpha: 0.26),
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShareRingPainter extends CustomPainter {
  const _ShareRingPainter({required this.ratio});

  final double? ratio;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 16.0;
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - stroke / 2;
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = MealoraColors.shareCardTrack
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke,
    );
    if (ratio != null && ratio! > 0) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -1.5708,
        6.28319 * ratio!,
        false,
        Paint()
          ..color = MealoraColors.lime
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeWidth = stroke,
      );
    }
  }

  @override
  bool shouldRepaint(_ShareRingPainter oldDelegate) =>
      oldDelegate.ratio != ratio;
}
