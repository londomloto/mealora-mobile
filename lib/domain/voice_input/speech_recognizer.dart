/// Kenapa pengenalan ucapan tidak dapat dipakai (change 012, design D2/D9).
///
/// Ketiganya bermuara ke jalur yang sama di layar — pengetikan kalimat dan
/// pencarian katalog — tetapi dibedakan supaya layar dapat menyatakan
/// keadaannya dengan jujur (spec voice-food-input, "Izin mikrofon ditolak"
/// dan "Pengenalan tidak tersedia di perangkat").
enum SpeechUnavailableReason {
  /// Pengguna menolak izin mikrofon, sekarang atau sebelumnya.
  permissionDenied,

  /// Perangkat tidak menyediakan pengenalan ucapan di perangkat untuk bahasa
  /// Indonesia. Rekaman SHALL TIDAK dikirim ke layanan luar sebagai gantinya.
  notSupported,

  /// Layanan pengenalan di perangkat gagal karena alasan lain.
  failed,
}

/// Hasil [SpeechRecognizer.prepare].
sealed class SpeechAvailability {
  const SpeechAvailability();
}

final class SpeechAvailable extends SpeechAvailability {
  const SpeechAvailable();
}

final class SpeechUnavailable extends SpeechAvailability {
  const SpeechUnavailable(this.reason);

  final SpeechUnavailableReason reason;
}

/// Peristiwa selama satu sesi [SpeechRecognizer.listen].
sealed class SpeechSessionEvent {
  const SpeechSessionEvent();
}

/// Transkrip sementara saat pengguna masih berbicara (layar 43).
final class SpeechPartialTranscript extends SpeechSessionEvent {
  const SpeechPartialTranscript(this.text);

  final String text;
}

/// Transkrip akhir; sesi berakhir setelah peristiwa ini. Teksnya boleh
/// kosong — pemanggil SHALL menawarkan rekam ulang atau ketik tanpa membuat
/// catatan (task 3.6).
final class SpeechFinalTranscript extends SpeechSessionEvent {
  const SpeechFinalTranscript(this.text);

  final String text;

  bool get isEmpty => text.trim().isEmpty;
}

/// Sesi gagal; sesi berakhir setelah peristiwa ini.
final class SpeechSessionFailed extends SpeechSessionEvent {
  const SpeechSessionFailed(this.reason);

  final SpeechUnavailableReason reason;
}

/// Pengenal ucapan di perangkat (change 012, design D1/D2) — di balik
/// antarmuka supaya layar dan pengujian tidak bergantung pada plugin.
///
/// Kontrak privasi yang SHALL dipenuhi setiap implementasi:
/// - Izin mikrofon hanya diminta lewat [prepare], dan [prepare] hanya
///   dipanggil setelah pengguna memilih jalur suara (task 3.1, 3.8).
/// - Pengenalan berjalan di perangkat. Bila perangkat tidak sanggup,
///   hasilnya [SpeechUnavailableReason.notSupported] — rekaman tidak pernah
///   dikirim ke layanan luar sebagai cadangan (task 3.5).
/// - Tidak ada rekaman suara yang ditulis ke penyimpanan; yang keluar dari
///   antarmuka ini hanya teks (task 3.7).
///
/// Implementasi SHALL TIDAK melempar pengecualian ke pemanggil; seluruh
/// kegagalan dilaporkan lewat [SpeechUnavailable] atau [SpeechSessionFailed].
abstract interface class SpeechRecognizer {
  Future<SpeechAvailability> prepare();

  /// Memulai satu sesi. Stream berakhir setelah [SpeechFinalTranscript] atau
  /// [SpeechSessionFailed]. Hanya boleh dipanggil setelah [prepare] membalas
  /// [SpeechAvailable].
  Stream<SpeechSessionEvent> listen();

  /// Mengakhiri sesi dan meminta transkrip akhir.
  Future<void> stop();

  /// Membatalkan sesi tanpa transkrip akhir.
  Future<void> cancel();
}
