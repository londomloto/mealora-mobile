import 'package:flutter/material.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/core/format/id_formatters.dart';
import 'package:mealora/domain/weight/weight_record.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// Jumlah jalur tren grafik: selalu tujuh, tetap (design.md D2 / Open
/// Questions, change 008) — bukan jendela kalender. Berbeda dari
/// `kWeightRecentRecordsWindowDays` di `weight_providers.dart`, yang
/// mengambil data lebih panjang untuk daftar "Catatan terakhir".
const int kWeightTrendWindowDays = 7;

/// Tren berat tujuh catatan terakhir (`31`, design D2/D3, change 008).
///
/// Selalu menggambar tujuh jalur (track) berukuran 16×72 sesuai rancangan
/// `31`, diisi dari kiri (terlama) sesuai urutan catatan yang ada. Jalur
/// berisi catatan diisi batang gradasi; bila catatan yang ada belum sampai
/// tujuh, jalur di sisi kanan dibiarkan kosong (netral, bukan batang
/// nol/dikarang) sampai catatan baru menambahnya. Label indeks adalah teks
/// visual saja; label pembaca layar memakai tanggal dan berat catatan
/// sebenarnya untuk jalur berisi, atau menyatakan belum ada catatan untuk
/// jalur kosong.
class WeightTrendChart extends StatelessWidget {
  const WeightTrendChart({required this.records, super.key});

  /// Terlama lebih dulu (selaras `recentWeightRecordsProvider`).
  final List<WeightRecord> records;

  static const double _trackWidth = 16;
  static const double _trackHeight = 72;
  static const double _slotWidth = 30;

  /// Lebar skala minimum (kg) yang dipetakan ke seluruh tinggi jalur.
  /// Tanpa ini, rentang nyata yang kecil (mis. naik-turun 1-2 kg sehari-hari)
  /// akan dipaksa mengisi 0%-100% tinggi jalur dan terlihat seperti
  /// perubahan drastis padahal cuma fluktuasi wajar.
  static const double _minDisplayRangeKg = 10;

  @override
  Widget build(BuildContext context) {
    final text = AppText.of(context);
    final recent = records.length <= kWeightTrendWindowDays
        ? records
        : records.sublist(records.length - kWeightTrendWindowDays);

    final values = recent.map((r) => r.weightKg).toList(growable: false);
    final minValue = values.reduce((a, b) => a < b ? a : b);
    final maxValue = values.reduce((a, b) => a > b ? a : b);
    final dataRange = maxValue - minValue;
    final displayRange = dataRange < _minDisplayRangeKg
        ? _minDisplayRangeKg
        : dataRange;
    // Rentang nyata dipusatkan di tengah skala tampilan, bukan menempel di
    // tepi bawah — supaya nilai terendah tidak selalu jatuh ke titik 0%.
    final anchorMin = (minValue + maxValue) / 2 - displayRange / 2;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        for (var i = 0; i < kWeightTrendWindowDays; i++)
          SizedBox(
            width: _slotWidth,
            child: Column(
              children: <Widget>[
                i < recent.length
                    ? _TrendBar(
                        weightKg: recent[i].weightKg,
                        anchorMin: anchorMin,
                        displayRange: displayRange,
                        trackWidth: _trackWidth,
                        trackHeight: _trackHeight,
                        semanticsLabel: text.weightEntrySemantics(
                          IdFormat.shortDate(recent[i].localDate),
                          IdFormat.time(recent[i].recordedAt),
                          IdFormat.decimal(recent[i].weightKg),
                        ),
                      )
                    : _TrendBar(
                        weightKg: null,
                        anchorMin: anchorMin,
                        displayRange: displayRange,
                        trackWidth: _trackWidth,
                        trackHeight: _trackHeight,
                        semanticsLabel: text.weightTrendEmptySlotSemantics,
                      ),
                const SizedBox(height: MealoraSpacing.xs),
                Text('${i + 1}', style: MealoraTypography.caption),
              ],
            ),
          ),
      ],
    );
  }
}

class _TrendBar extends StatelessWidget {
  const _TrendBar({
    required this.weightKg,
    required this.anchorMin,
    required this.displayRange,
    required this.trackWidth,
    required this.trackHeight,
    required this.semanticsLabel,
  });

  final double? weightKg;
  final double anchorMin;
  final double displayRange;
  final double trackWidth;
  final double trackHeight;
  final String semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final cornerRadius = trackWidth / 2;
    return Semantics(
      label: semanticsLabel,
      excludeSemantics: true,
      child: SizedBox(
        width: trackWidth,
        height: trackHeight,
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            Container(
              width: trackWidth,
              height: trackHeight,
              decoration: BoxDecoration(
                color: MealoraColors.track,
                borderRadius: BorderRadius.circular(cornerRadius),
              ),
            ),
            if (weightKg != null)
              Container(
                width: trackWidth,
                height:
                    trackHeight *
                    ((weightKg! - anchorMin) / displayRange).clamp(0.0, 1.0),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: MealoraColors.weightTrendGradient,
                  ),
                  borderRadius: BorderRadius.circular(cornerRadius),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
