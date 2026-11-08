/// Kegagalan bertipe.
///
/// Operasi yang bisa gagal mengembalikan `Result` (lihat `result.dart`), bukan
/// melempar exception. Exception hanya dipakai untuk kesalahan pemrograman.
library;

/// Kode alasan kegagalan.
///
/// Kode bersifat stabil dan dapat dipetakan ke pesan pengguna oleh lapisan
/// tampilan. Change berikutnya menambah kode baru (mis. kebijakan program
/// yang belum tervalidasi) tanpa mengubah kode yang sudah ada.
enum FailureCode {
  /// Penyimpanan lokal tidak dapat dibuka pada perangkat ini.
  storageUnavailable,

  /// Migrasi skema gagal; data lama dibiarkan apa adanya.
  storageMigrationFailed,

  /// Nilai masukan tidak valid secara bentuk (bukan angka, kosong, dan sejenisnya).
  invalidValue,

  /// Nilai masukan berada di luar rentang yang masuk akal secara fisik.
  valueOutOfRange,

  /// Record yang diminta tidak ada atau sudah ditandai terhapus.
  recordNotFound,

  /// Kegagalan yang tidak dikenali; selalu disertai [Failure.detail].
  unexpected,
}

/// Kegagalan beserta kode alasan dan konteksnya.
final class Failure {
  const Failure(this.code, {this.field, this.detail});

  /// Kode alasan yang dipetakan ke pesan pengguna.
  final FailureCode code;

  /// Nama bidang yang menyebabkan kegagalan, bila kegagalan terkait masukan.
  final String? field;

  /// Keterangan teknis untuk pengembang. Tidak ditampilkan ke pengguna apa adanya.
  final String? detail;

  @override
  bool operator ==(Object other) =>
      other is Failure &&
      other.code == code &&
      other.field == field &&
      other.detail == detail;

  @override
  int get hashCode => Object.hash(code, field, detail);

  @override
  String toString() =>
      'Failure(${code.name}'
      '${field == null ? '' : ', field: $field'}'
      '${detail == null ? '' : ', detail: $detail'})';
}
