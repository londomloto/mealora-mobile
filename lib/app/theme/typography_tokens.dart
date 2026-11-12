import 'package:flutter/material.dart';
import 'package:mealora/app/theme/color_tokens.dart';

/// Token tipografi Mealora.
///
/// Keluarga dan ukuran diambil dari `mealora-plans/docs/mealora-v2.pen`:
/// Plus Jakarta Sans untuk seluruh antarmuka, termasuk wordmark.
///
/// Berkas font adalah font variabel, sehingga berat dipilih lewat
/// [FontVariation] pada sumbu wght — bukan hanya [FontWeight].
abstract final class MealoraTypography {
  static const String fontFamily = 'Plus Jakarta Sans';
  static const String wordmarkFontFamily = fontFamily;

  static const double regular = 400;
  static const double medium = 500;
  static const double semiBold = 600;
  static const double bold = 700;
  static const double extraBold = 800;

  /// Angka besar yang menjadi fokus layar (mis. kalori terkonsumsi, berat
  /// tersisa).
  static TextStyle get display =>
      _jakarta(size: 30, weight: bold, color: MealoraColors.ink, height: 1.1);

  /// Angka dan unit pada kartu estimasi target onboarding.
  static TextStyle get targetValue => _jakarta(
    size: 48,
    weight: bold,
    color: MealoraColors.onPrimary,
    height: 1,
  );
  static TextStyle get targetUnit => _jakarta(
    size: 14,
    weight: regular,
    color: MealoraColors.onPrimaryMuted,
    height: 1.3,
  );

  /// Judul layar (mis. onboarding, tinjau target).
  static TextStyle get title =>
      _jakarta(size: 27, weight: bold, color: MealoraColors.ink, height: 1.2);

  /// Judul bagian besar.
  static TextStyle get headline =>
      _jakarta(size: 24, weight: bold, color: MealoraColors.ink, height: 1.2);

  /// Judul bagian (mis. "Makanan hari ini").
  static TextStyle get sectionTitle =>
      _jakarta(size: 19, weight: bold, color: MealoraColors.ink, height: 1.3);

  /// Heading ringkas pada daftar review (16/bold di dokumen desain).
  static TextStyle get compactSectionTitle =>
      _jakarta(size: 16, weight: bold, color: MealoraColors.ink, height: 1.3);

  /// Pasangan label/nilai pada baris dasar perkiraan.
  static TextStyle get reviewLabel => _jakarta(
    size: 12,
    weight: regular,
    color: MealoraColors.muted,
    height: 1.35,
  );
  static TextStyle get reviewValue =>
      _jakarta(size: 12, weight: bold, color: MealoraColors.ink, height: 1.35);

  /// Teks pengantar di bawah judul.
  static TextStyle get subtitle => _jakarta(
    size: 13,
    weight: regular,
    color: MealoraColors.muted,
    height: 1.4,
  );

  /// Teks isi.
  static TextStyle get body => _jakarta(
    size: 15,
    weight: regular,
    color: MealoraColors.ink,
    height: 1.45,
  );

  /// Teks isi sekunder.
  static TextStyle get bodyMuted => _jakarta(
    size: 15,
    weight: regular,
    color: MealoraColors.muted,
    height: 1.45,
  );

  /// Teks isi kecil (catatan, keterangan tambahan).
  static TextStyle get bodySmall => _jakarta(
    size: 13,
    weight: regular,
    color: MealoraColors.muted,
    height: 1.4,
  );

  /// Nilai isian yang ditekankan (mis. nilai kolom formulir, nama baris
  /// daftar) — "Value" 15/600 di dokumen desain.
  static TextStyle get bodyEmphasis => _jakarta(
    size: 15,
    weight: semiBold,
    color: MealoraColors.ink,
    height: 1.3,
  );

  /// Label kapsul kaca (mis. "Program aktif") — 13/600 di dokumen desain.
  static TextStyle get chipLabel =>
      _jakarta(size: 13, weight: semiBold, color: MealoraColors.ink);

  /// Label kolom isian dan keterangan kecil di atas sebuah nilai.
  static TextStyle get label => _jakarta(
    size: 11,
    weight: regular,
    color: MealoraColors.muted,
    height: 1.3,
  );

  /// Label di atas field ringkas pada target berat.
  static TextStyle get compactFieldLabel => _jakarta(
    size: 12,
    weight: semiBold,
    color: MealoraColors.muted,
    height: 1.3,
  );

  /// Keterangan kecil, catatan kaki, dan janji privasi.
  static TextStyle get caption => _jakarta(
    size: 11,
    weight: regular,
    color: MealoraColors.muted,
    height: 1.35,
  );

  /// Label konteks huruf tebal kecil (mis. "Langkah 2 dari 6", "Program
  /// aktif") — "Step / context" / "Eyebrow" 10 bold di dokumen desain.
  static TextStyle get eyebrow => _jakarta(
    size: 10,
    weight: bold,
    color: MealoraColors.primary,
    height: 1.2,
    letterSpacing: 0.4,
  );

  /// Label tombol primer.
  static TextStyle get button =>
      _jakarta(size: 16, weight: bold, color: MealoraColors.onPrimary);

  /// Label tujuan navigasi.
  static TextStyle get navigationLabel => _jakarta(
    size: 10,
    weight: semiBold,
    color: MealoraColors.muted,
    height: 1.2,
  );

  /// Wordmark Mealora.
  static TextStyle get wordmark => _jakarta(
    size: 43,
    weight: extraBold,
    color: MealoraColors.onPrimary,
    letterSpacing: -1,
  );

  /// Nilai isian pada kolom nutrisi kustom (energi, protein, karbohidrat,
  /// lemak) — `_NutrientField`, lembar makanan kustom (change 007). Warna
  /// dasar ditimpa per nutrien oleh pemanggil lewat `copyWith(color: ...)`.
  static TextStyle get nutrientFieldValue =>
      _jakarta(size: 19, weight: bold, color: MealoraColors.ink, height: 1.1);

  /// Judul tanggal pada navigator hari di ruang Riwayat (`18 · Riwayat
  /// harian`) — ditampilkan di atas permukaan hero berwarna.
  static TextStyle get dateNavigatorTitle => _jakarta(
    size: 14,
    weight: bold,
    color: MealoraColors.onPrimary,
    height: 1.2,
  );

  /// Nilai zat gizi makro ringkas (mis. gram protein/karbohidrat/lemak) —
  /// `_MacroColumn`, ruang Hari ini.
  static TextStyle get macroValue =>
      _jakarta(size: 13, weight: bold, color: MealoraColors.ink, height: 1.2);

  /// Nilai besar di dalam cincin kalori — `_CalorieRing`, ruang Hari ini.
  static TextStyle get calorieRingValue =>
      _jakarta(size: 28, weight: bold, color: MealoraColors.ink, height: 1);

  // Kartu berbagi (change 014) — ukuran logis 360×640, rancangan `59`/`62`.

  static TextStyle get shareCardDate => _jakarta(
    size: 11,
    weight: bold,
    color: MealoraColors.shareCardMuted,
    letterSpacing: 1.6,
  );

  static TextStyle get shareCardRingValue => _jakarta(
    size: 62,
    weight: bold,
    color: MealoraColors.onPrimary,
    height: 1.1,
  );

  static TextStyle get shareCardRingUnit =>
      _jakarta(size: 14, weight: regular, color: MealoraColors.onPrimaryMuted);

  static TextStyle get shareCardTarget =>
      _jakarta(size: 17, weight: bold, color: MealoraColors.onPrimary);

  static TextStyle get shareCardMacro =>
      _jakarta(size: 12, weight: regular, color: MealoraColors.shareCardMuted);

  static TextStyle get shareCardWordmark =>
      _jakarta(size: 16, weight: bold, color: MealoraColors.onPrimary);

  static TextStyle get shareCardChipWordmark =>
      _jakarta(size: 13, weight: bold, color: MealoraColors.primary);

  static TextStyle get shareCardChipLabel =>
      _jakarta(size: 12, weight: bold, color: MealoraColors.onPrimary);

  static TextStyle get shareCardItemName =>
      _jakarta(size: 13, weight: semiBold, color: MealoraColors.ink);

  static TextStyle get shareCardItemDetail =>
      _jakarta(size: 11, weight: regular, color: MealoraColors.muted);

  static TextStyle get shareCardItemKcal =>
      _jakarta(size: 12, weight: bold, color: MealoraColors.muted);

  static TextStyle get shareCardTotalLabel =>
      _jakarta(size: 11, weight: regular, color: MealoraColors.muted);

  static TextStyle get shareCardTotalValue =>
      _jakarta(size: 24, weight: bold, color: MealoraColors.ink, height: 1.2);

  static TextStyle get shareCardTotalUnit =>
      _jakarta(size: 12, weight: semiBold, color: MealoraColors.muted);

  static TextStyle _jakarta({
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
