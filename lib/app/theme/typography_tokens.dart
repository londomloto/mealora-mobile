import 'package:flutter/material.dart';
import 'package:mealora/app/theme/color_tokens.dart';

/// Token tipografi Mealora.
///
/// Keluarga dan ukuran diambil dari `mealora-plans/docs/mealora.pen`:
/// Inter untuk seluruh antarmuka, Manrope hanya untuk wordmark.
///
/// Kedua berkas font adalah font variabel, sehingga berat dipilih lewat
/// [FontVariation] pada sumbu wght — bukan hanya [FontWeight].
abstract final class MealoraTypography {
  static const String fontFamily = 'Inter';
  static const String wordmarkFontFamily = 'Manrope';

  static const double regular = 400;
  static const double medium = 500;
  static const double semiBold = 600;
  static const double bold = 700;
  static const double extraBold = 800;

  /// Angka besar yang menjadi fokus layar (mis. kalori terkonsumsi).
  static TextStyle get display =>
      _inter(size: 50, weight: bold, color: MealoraColors.ink, height: 1.05);

  /// Judul layar.
  static TextStyle get title =>
      _inter(size: 31, weight: bold, color: MealoraColors.ink, height: 1.2);

  /// Judul bagian besar.
  static TextStyle get headline =>
      _inter(size: 21, weight: bold, color: MealoraColors.ink, height: 1.25);

  /// Judul bagian.
  static TextStyle get sectionTitle =>
      _inter(size: 19, weight: bold, color: MealoraColors.ink, height: 1.3);

  /// Teks pengantar di bawah judul.
  static TextStyle get subtitle => _inter(
    size: 16,
    weight: regular,
    color: MealoraColors.muted,
    height: 1.4,
  );

  /// Teks isi.
  static TextStyle get body =>
      _inter(size: 15, weight: regular, color: MealoraColors.ink, height: 1.45);

  /// Teks isi sekunder.
  static TextStyle get bodyMuted => _inter(
    size: 15,
    weight: regular,
    color: MealoraColors.muted,
    height: 1.45,
  );

  /// Teks isi kecil.
  static TextStyle get bodySmall => _inter(
    size: 13,
    weight: regular,
    color: MealoraColors.muted,
    height: 1.4,
  );

  /// Label kolom isian dan baris data.
  static TextStyle get label =>
      _inter(size: 12, weight: medium, color: MealoraColors.ink, height: 1.3);

  /// Keterangan kecil, catatan kaki, dan janji privasi.
  static TextStyle get caption => _inter(
    size: 11,
    weight: regular,
    color: MealoraColors.muted,
    height: 1.35,
  );

  /// Label tombol primer.
  static TextStyle get button =>
      _inter(size: 15, weight: bold, color: MealoraColors.onPrimary);

  /// Label tujuan navigasi.
  static TextStyle get navigationLabel =>
      _inter(size: 11, weight: medium, color: MealoraColors.muted, height: 1.2);

  /// Wordmark Mealora.
  static TextStyle get wordmark => const TextStyle(
    fontFamily: wordmarkFontFamily,
    fontSize: 43,
    letterSpacing: -2,
    color: MealoraColors.ink,
    fontWeight: FontWeight.w800,
    fontVariations: <FontVariation>[FontVariation('wght', extraBold)],
  );

  static TextStyle _inter({
    required double size,
    required double weight,
    required Color color,
    double? height,
    double letterSpacing = 0,
  }) {
    return TextStyle(
      fontFamily: fontFamily,
      fontSize: size,
      height: height,
      letterSpacing: letterSpacing,
      color: color,
      fontWeight: _weightOf(weight),
      fontVariations: <FontVariation>[FontVariation('wght', weight)],
    );
  }

  static FontWeight _weightOf(double weight) {
    return FontWeight.values.firstWhere(
      (candidate) => candidate.value == weight.round(),
      orElse: () => FontWeight.normal,
    );
  }
}
