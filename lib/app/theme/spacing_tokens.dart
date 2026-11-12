/// Token jarak, radius, dan elevasi Mealora.
///
/// Skala jarak dan rentang radius mengikuti catatan sistem UI di
/// `mealora-plans/docs/mealora-v2.pen`: ruang 8 / 12 / 16 / 22 / 32 px,
/// radius 16–30 px (kaca 22–26 px, tombol 20 px, dok navigasi 30 px).
abstract final class MealoraSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double inlineGap = 14;
  static const double md = 16;
  static const double lg = 22;
  static const double xl = 28;
  static const double xxl = 32;

  /// Jarak tepi layar ke konten.
  static const double screenGutter = 22;

  /// Geometri spesifik frame `05 · Program saya` pada kanvas 390 px — teks
  /// judul hero diindentasi 24 px, berbeda dari kartu kontennya yang
  /// memakai [MealoraSpacing.screenGutter] (22 px) seperti layar `01`/`16`.
  static const double programHeroGutter = 24;

  /// Geometri hero bersama tab utama (Hari ini, Program, Riwayat). Nilai
  /// 244 adalah tinggi desain 268 px setelah status bar 24 px ditangani
  /// SafeArea; kartu pertama menumpuk 36 px di atas batas bawahnya.
  static const double mainHeroHeight = 244;
  static const double mainHeroOverlap = 36;

  /// Geometri navigation dock pada kanvas acuan 390×844.
  static const double navigationHeight = 72;
  static const double navigationInset = 10;
  static const double navigationSlotHeight = 52;
  static const double navigationBlendHeight = 28;

  /// Ruang gulir agar konten terakhir dapat naik sepenuhnya di atas dock
  /// ketika `Scaffold.extendBody` aktif.
  static const double navigationContentClearance = 168;
}

/// Radius sudut.
abstract final class MealoraRadius {
  static const double track = 4;
  static const double badge = 8;
  static const double compactIconField = 12;
  static const double iconField = 14;
  static const double chip = 18;
  static const double button = 20;
  static const double choiceCard = 22;
  static const double card = 24;
  static const double cardLarge = 26;
  static const double welcomeCard = 28;
  static const double sheet = 32;

  /// Kartu berbagi 9:16 (change 014, rancangan `59`–`62`).
  static const double shareCard = 28;
  static const double programHeroBottom = 38;

  /// Ubin simbol pada splash.
  static const double splashTile = 38;

  /// Radius kapsul penuh / dok navigasi mengambang.
  static const double pill = 999;

  /// Radius dok navigasi (tidak sepenuhnya kapsul — 30 px tetap).
  static const double navigation = 30;

  /// Tombol bulat-kotak di atas pratinjau kamera (mis. tutup).
  static const double cameraControl = 16;

  /// Ubin ikon pada kartu pilihan onboarding.
  static const double choiceIcon = 16;

  /// Pegangan tarik lembar modal (mis. lembar tambah makanan — change 007).
  static const double sheetHandle = 3;
}

/// Ukuran ikon.
abstract final class MealoraIconSize {
  static const double inline = 14;
  static const double action = 18;
  static const double alert = 22;
  static const double navigation = 21;
  static const double raisedAction = 26;
}

/// Ukuran area sentuh.
abstract final class MealoraTouch {
  /// Ukuran minimum area sentuh (Material: 48 dp).
  static const double minTarget = 48;

  /// Diameter tombol utama yang terangkat di navigasi (`FAB · Catat` di
  /// docs/mealora-v2.pen).
  static const double raisedAction = 64;
}

/// Elevasi/bayangan.
abstract final class MealoraElevation {
  static const double card = 0;
  static const double raised = 8;
  static const double navigation = 12;
}
