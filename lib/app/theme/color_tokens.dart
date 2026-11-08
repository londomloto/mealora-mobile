import 'dart:ui';

/// Token warna Mealora.
///
/// Sumber nilai: variabel dokumen desain `mealora-plans/docs/mealora.pen`
/// (background, primary, accent, peach, ink, muted, soft-green, line) beserta
/// warna pendukung yang dipakai di layar-layar dokumen itu.
///
/// Ini satu-satunya tempat nilai warna ditulis. Widget membaca warna lewat
/// tema atau lewat kelas ini, tidak pernah menulis nilai heksadesimal sendiri
/// — aturan ini ditegakkan oleh uji arsitektur.
abstract final class MealoraColors {
  /// Latar aplikasi.
  static const Color background = Color(0xFFF7FAF5);

  /// Permukaan kartu dan kolom isian.
  static const Color surface = Color(0xFFFFFFFF);

  /// Warna merek utama (hijau daun).
  static const Color primary = Color(0xFF258747);

  /// Varian primer yang sedikit lebih terang untuk teks aksen di atas putih.
  static const Color primaryBright = Color(0xFF288D48);

  /// Teks/ikon di atas [primary].
  static const Color onPrimary = Color(0xFFFFFFFF);

  /// Teks sekunder di atas [primary].
  static const Color onPrimaryMuted = Color(0xFFE2F2E6);

  /// Kuning aksen.
  static const Color accent = Color(0xFFF5D35C);

  /// Oranye hangat.
  static const Color peach = Color(0xFFFF8A50);

  /// Warna teks utama (tinta).
  static const Color ink = Color(0xFF203D2D);

  /// Warna teks sekunder.
  ///
  /// Dokumen desain memakai `#687D70`. Nilai itu hanya mencapai rasio kontras
  /// 4,19:1 di atas [background] dan 4,42:1 di atas [surface] — di bawah
  /// ambang 4,5:1 untuk teks biasa. Token digelapkan 5% menjadi `#63776A`
  /// (4,56:1 dan 4,80:1) agar memenuhi ambang tanpa mengubah rona merek.
  /// Uji kontras di `test/unit/theme_test.dart` menjaga nilai ini.
  static const Color muted = Color(0xFF63776A);

  /// Latar lembut untuk sorotan dan keadaan terpilih.
  static const Color softGreen = Color(0xFFDEF3DE);

  /// Garis pembatas dan tepi kartu.
  static const Color line = Color(0xFFDFE9DE);

  /// Latar bilah progres dan jalur netral.
  static const Color track = Color(0xFFE8F0E5);

  /// Permukaan navigasi kapsul mengambang (putih dengan sedikit transparansi).
  static const Color navigationSurface = Color(0xFFFFFFFF);

  /// Warna dasar bayangan.
  static const Color shadow = Color(0xFF194B32);

  /// Warna untuk keadaan kesalahan yang dapat dibaca pengguna.
  static const Color danger = Color(0xFFB3261E);
}
