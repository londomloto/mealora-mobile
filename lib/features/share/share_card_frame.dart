import 'package:flutter/material.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';

/// Ukuran logis tetap kartu berbagi (change 014, Design D2): 9:16, dirender
/// dengan `pixelRatio` 3 menjadi 1080×1920 — tidak bergantung pada ukuran
/// layar perangkat.
abstract final class ShareCardSize {
  static const double width = 360;
  static const double height = 640;
  static const double pixelRatio = 3;

  /// Margin area aman: aplikasi tujuan (Story/Status) dapat memotong tepi
  /// atas dan bawah, jadi isi penting tetap di dalam margin ini (Design,
  /// Risks).
  static const double safeInset = 30;
}

/// Bingkai dasar semua kartu berbagi (task 1.4): ukuran 9:16 tetap, sudut
/// membulat, dan latar yang diberikan pemanggil. Watermark TIDAK menjadi
/// parameter opsional — setiap kartu menyusunnya sendiri lewat
/// [ShareWatermark] / [ShareWatermarkChip] dan uji widget memastikannya ada
/// (spec, "Watermark Mealora").
class ShareCardFrame extends StatelessWidget {
  const ShareCardFrame({
    required this.decoration,
    required this.child,
    super.key,
  });

  final BoxDecoration decoration;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: ShareCardSize.width,
      height: ShareCardSize.height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(MealoraRadius.shareCard),
        child: DecoratedBox(
          decoration: decoration,
          child: MediaQuery(
            // Kartu adalah gambar: skala teks perangkat tidak boleh mengubah
            // tata letak berkas yang dibagikan.
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.noScaling),
            child: child,
          ),
        ),
      ),
    );
  }
}

/// Watermark logo + nama Mealora di atas latar gelap/hijau (`59`).
class ShareWatermark extends StatelessWidget {
  const ShareWatermark({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      key: const ValueKey<String>('share-watermark'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        ClipRRect(
          borderRadius: BorderRadius.circular(MealoraRadius.track + 3),
          child: Image.asset(
            'assets/brand/mealora-app-icon-1024.png',
            width: 22,
            height: 22,
          ),
        ),
        const SizedBox(width: MealoraSpacing.xs),
        Text('Mealora', style: MealoraTypography.shareCardWordmark),
      ],
    );
  }
}

/// Watermark sebagai chip putih di atas foto (`62`).
class ShareWatermarkChip extends StatelessWidget {
  const ShareWatermarkChip({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const ValueKey<String>('share-watermark'),
      height: 34,
      padding: const EdgeInsets.symmetric(horizontal: MealoraSpacing.sm),
      decoration: BoxDecoration(
        color: MealoraColors.shareCardChip,
        borderRadius: BorderRadius.circular(MealoraRadius.pill),
        boxShadow: const <BoxShadow>[
          BoxShadow(
            color: MealoraColors.shadowGlass,
            offset: Offset(0, 4),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          ClipRRect(
            borderRadius: BorderRadius.circular(MealoraRadius.track + 2),
            child: Image.asset(
              'assets/brand/mealora-app-icon-1024.png',
              width: 18,
              height: 18,
            ),
          ),
          const SizedBox(width: 7),
          Text('Mealora', style: MealoraTypography.shareCardChipWordmark),
        ],
      ),
    );
  }
}
