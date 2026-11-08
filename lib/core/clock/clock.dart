/// Sumber waktu aplikasi.
///
/// Seluruh kode aplikasi membaca waktu lewat antarmuka ini, tidak pernah
/// langsung dari `DateTime.now()`, sehingga perilaku berwaktu dapat diuji
/// secara deterministik (lihat `test/unit/architecture/`).
///
/// Instan selalu UTC. Pengelompokan harian memakai [LocalDate] yang dihitung
/// sekali saat pencatatan, lalu disimpan apa adanya: berpindah zona waktu
/// setelah mencatat tidak boleh memindahkan catatan lama ke hari lain.
library;

/// Tanggal kalender lokal tanpa komponen waktu, dalam format ISO `YYYY-MM-DD`.
final class LocalDate implements Comparable<LocalDate> {
  const LocalDate(this.year, this.month, this.day);

  /// Membaca `YYYY-MM-DD`. Melempar [FormatException] bila bentuknya salah —
  /// ini kesalahan pemrograman, bukan jalur kegagalan pengguna.
  factory LocalDate.parse(String value) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
    if (match == null) {
      throw FormatException('Tanggal lokal harus berbentuk YYYY-MM-DD', value);
    }
    return LocalDate(
      int.parse(match.group(1)!),
      int.parse(match.group(2)!),
      int.parse(match.group(3)!),
    );
  }

  /// Tanggal kalender dari [instant] menurut zona waktu perangkat saat ini.
  factory LocalDate.fromLocalInstant(DateTime instant) {
    final local = instant.isUtc ? instant.toLocal() : instant;
    return LocalDate(local.year, local.month, local.day);
  }

  final int year;
  final int month;
  final int day;

  String get iso =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${day.toString().padLeft(2, '0')}';

  @override
  int compareTo(LocalDate other) => iso.compareTo(other.iso);

  @override
  bool operator ==(Object other) =>
      other is LocalDate &&
      other.year == year &&
      other.month == month &&
      other.day == day;

  @override
  int get hashCode => Object.hash(year, month, day);

  @override
  String toString() => iso;
}

/// Kontrak sumber waktu.
abstract interface class Clock {
  /// Instan saat ini dalam UTC.
  DateTime nowUtc();

  /// Pengenal zona waktu perangkat (IANA, mis. `Asia/Jakarta`).
  ///
  /// Bila platform tidak dapat memberikan pengenal IANA, implementasi
  /// mengembalikan pengenal terbaik yang tersedia — nilai ini disimpan apa
  /// adanya bersama record dan tidak pernah dipakai untuk menghitung ulang
  /// tanggal lokal record lama.
  String timeZoneId();

  /// Tanggal lokal saat ini menurut zona waktu perangkat.
  LocalDate today();

  /// Tanggal lokal dari [instantUtc] menurut zona waktu perangkat.
  LocalDate localDateOf(DateTime instantUtc);
}
