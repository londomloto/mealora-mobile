/// Token jarak, radius, dan elevasi Mealora.
///
/// Skala jarak dan rentang radius mengikuti catatan sistem UI di
/// `mealora-plans/docs/mealora.pen`: ruang 8 / 12 / 16 / 24 / 32 px,
/// radius 14–26 px.
abstract final class MealoraSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;

  /// Jarak tepi layar ke konten.
  static const double screenGutter = 22;
}

/// Radius sudut.
abstract final class MealoraRadius {
  static const double track = 5;
  static const double chip = 16;
  static const double button = 18;
  static const double card = 20;
  static const double cardLarge = 25;
  static const double sheet = 32;

  /// Ubin simbol pada splash.
  static const double splashTile = 44;

  /// Radius kapsul penuh.
  static const double pill = 999;
}

/// Ukuran ikon.
abstract final class MealoraIconSize {
  static const double inline = 14;
  static const double action = 18;
  static const double alert = 22;
  static const double navigation = 22;
  static const double raisedAction = 28;
}

/// Ukuran area sentuh.
abstract final class MealoraTouch {
  /// Ukuran minimum area sentuh (Material: 48 dp).
  static const double minTarget = 48;

  /// Diameter tombol utama yang terangkat di navigasi
  /// (`Catat · raised center button` di docs/mealora.pen).
  static const double raisedAction = 60;
}

/// Elevasi/bayangan.
abstract final class MealoraElevation {
  static const double card = 0;
  static const double raised = 8;
  static const double navigation = 12;
}
