import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/app/theme/app_theme.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';

/// Luminansi relatif menurut WCAG 2.x.
double _relativeLuminance(Color color) {
  double channel(double value) {
    return value <= 0.03928
        ? value / 12.92
        : math.pow((value + 0.055) / 1.055, 2.4).toDouble();
  }

  return 0.2126 * channel(color.r) +
      0.7152 * channel(color.g) +
      0.0722 * channel(color.b);
}

/// Rasio kontras antara dua warna buram.
double contrastRatio(Color foreground, Color background) {
  final first = _relativeLuminance(foreground);
  final second = _relativeLuminance(background);
  final lighter = math.max(first, second);
  final darker = math.min(first, second);
  return (lighter + 0.05) / (darker + 0.05);
}

void main() {
  group('kontras pasangan warna yang dipakai', () {
    // Ambang WCAG AA: 4.5:1 untuk teks biasa, 3:1 untuk teks besar dan
    // elemen antarmuka.
    const normalText = 4.5;
    const largeTextOrUi = 3.0;

    test('teks utama di atas latar aplikasi', () {
      expect(
        contrastRatio(MealoraColors.ink, MealoraColors.background),
        greaterThanOrEqualTo(normalText),
      );
    });

    test('teks sekunder di atas latar aplikasi — pasangan paling berisiko', () {
      expect(
        contrastRatio(MealoraColors.muted, MealoraColors.background),
        greaterThanOrEqualTo(normalText),
      );
    });

    test('teks sekunder di atas permukaan kartu', () {
      expect(
        contrastRatio(MealoraColors.muted, MealoraColors.surface),
        greaterThanOrEqualTo(normalText),
      );
    });

    test('teks utama di atas sorotan hijau lembut', () {
      expect(
        contrastRatio(MealoraColors.ink, MealoraColors.softGreen),
        greaterThanOrEqualTo(normalText),
      );
    });

    test('label tombol primer di atas warna merek', () {
      expect(
        contrastRatio(MealoraColors.onPrimary, MealoraColors.primary),
        greaterThanOrEqualTo(normalText),
      );
    });

    test('aksen merek di atas permukaan kartu memenuhi ambang elemen UI', () {
      expect(
        contrastRatio(MealoraColors.primary, MealoraColors.surface),
        greaterThanOrEqualTo(largeTextOrUi),
      );
      expect(
        contrastRatio(MealoraColors.primaryBright, MealoraColors.surface),
        greaterThanOrEqualTo(largeTextOrUi),
      );
    });

    test('teks kesalahan di atas permukaan kartu', () {
      expect(
        contrastRatio(MealoraColors.danger, MealoraColors.surface),
        greaterThanOrEqualTo(normalText),
      );
    });
  });

  group('token adalah satu-satunya sumber nilai gaya', () {
    test('tema membaca warna dari token', () {
      final theme = MealoraTheme.light();

      expect(theme.colorScheme.primary, MealoraColors.primary);
      expect(theme.scaffoldBackgroundColor, MealoraColors.background);
      expect(theme.colorScheme.onSurfaceVariant, MealoraColors.muted);
      expect(theme.dividerTheme.color, MealoraColors.line);
    });

    test('tema membaca tipografi dari token', () {
      final theme = MealoraTheme.light();

      expect(
        theme.textTheme.headlineLarge?.fontSize,
        MealoraTypography.title.fontSize,
      );
      expect(
        theme.textTheme.headlineLarge?.fontWeight,
        MealoraTypography.title.fontWeight,
      );
      expect(
        theme.textTheme.bodyLarge?.fontSize,
        MealoraTypography.body.fontSize,
      );
      expect(theme.textTheme.bodyLarge?.color, MealoraColors.ink);
      expect(
        theme.textTheme.labelSmall?.fontFamily,
        MealoraTypography.fontFamily,
      );
    });

    test('tema membaca radius dan target sentuh dari token', () {
      final theme = MealoraTheme.light();

      final buttonShape =
          theme.filledButtonTheme.style?.shape?.resolve(<WidgetState>{})
              as RoundedRectangleBorder?;
      expect(
        buttonShape?.borderRadius,
        BorderRadius.circular(MealoraRadius.button),
      );

      final minimumSize = theme.textButtonTheme.style?.minimumSize?.resolve(
        <WidgetState>{},
      );
      expect(minimumSize?.height, MealoraTouch.minTarget);
    });

    test('berat font dinyatakan sebagai sumbu variabel wght', () {
      expect(
        MealoraTypography.title.fontVariations,
        contains(const FontVariation('wght', MealoraTypography.bold)),
      );
      expect(
        MealoraTypography.body.fontVariations,
        contains(const FontVariation('wght', MealoraTypography.regular)),
      );
    });
  });
}
