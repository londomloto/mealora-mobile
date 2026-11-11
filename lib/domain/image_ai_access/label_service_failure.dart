/// Alasan layanan pembacaan label tidak tersedia (spec image-ai-access,
/// "Kegagalan layanan selalu bermuara ke jalur manual"; FRS §5).
///
/// Layar SHALL menerjemahkan setiap nilai menjadi bahasa yang dapat
/// dimengerti pengguna, tanpa istilah teknis dan tanpa kode kesalahan
/// (task 4.2) — nilai enum ini sendiri tidak pernah ditampilkan.
enum LabelServiceFailureReason {
  /// Tidak ada koneksi jaringan pada perangkat saat pengiriman dicoba.
  offline,

  /// Proksi atau penyedia model tidak merespons dalam batas waktu.
  timeout,

  /// Batas permintaan/biaya proksi terlampaui (spec, "Batas biaya dan
  /// permintaan ditetapkan") — SHALL dinyatakan sebagai "layanan sedang
  /// tidak tersedia", BUKAN sebagai kesalahan pengguna.
  quotaExceeded,

  /// Penyedia model mengembalikan kegagalan atau menolak permintaan di
  /// luar ketiga alasan di atas.
  refused,
}
