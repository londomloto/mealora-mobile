/// Pembangkit pengenal record.
///
/// Pengenal dibuat aplikasi (bukan basis data) agar unik lintas perangkat dan
/// siap untuk sinkronisasi di kemudian hari. Kode pemakai tidak pernah
/// memanggil pembangkit acak secara langsung; selalu lewat antarmuka ini.
library;

/// Kontrak pembangkit pengenal.
abstract interface class IdGenerator {
  /// Pengenal baru yang unik global.
  String next();
}
