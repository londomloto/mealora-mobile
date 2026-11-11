/// Pengaturan persetujuan unggah gambar (Design D3, D9, change 010) —
/// rancangan `35 · Privasi & data lokal`: bawaan [askEachTime] (spec,
/// "Pengaturan privasi menetapkan tanya setiap kali").
///
/// [alwaysAllow] adalah SATU-SATUNYA cara persetujuan satu gambar boleh
/// terbawa ke gambar berikutnya (spec, "Persetujuan diberikan untuk satu
/// gambar") — pengguna yang menetapkannya di sini secara eksplisit, bukan
/// bawaan aplikasi maupun akibat samping menekan "Izinkan" sekali.
enum ImageUploadConsentPreference {
  askEachTime,
  alwaysAllow;

  static const ImageUploadConsentPreference defaultValue =
      ImageUploadConsentPreference.askEachTime;

  String get stableCode => switch (this) {
    ImageUploadConsentPreference.askEachTime => 'ask_each_time',
    ImageUploadConsentPreference.alwaysAllow => 'always_allow',
  };

  static ImageUploadConsentPreference fromStableCode(String code) =>
      ImageUploadConsentPreference.values.firstWhere(
        (v) => v.stableCode == code,
        orElse: () => defaultValue,
      );
}

/// Pengaturan retensi foto label sumber (Design D9, change 010) — bawaan
/// [deleteAfterLogging] (rancangan `35`, "Simpan foto sumber: Hapus setelah
/// dicatat").
enum ImageRetentionPreference {
  deleteAfterLogging,
  keepOnDevice;

  static const ImageRetentionPreference defaultValue =
      ImageRetentionPreference.deleteAfterLogging;

  String get stableCode => switch (this) {
    ImageRetentionPreference.deleteAfterLogging => 'delete_after_logging',
    ImageRetentionPreference.keepOnDevice => 'keep_on_device',
  };

  static ImageRetentionPreference fromStableCode(String code) =>
      ImageRetentionPreference.values.firstWhere(
        (v) => v.stableCode == code,
        orElse: () => defaultValue,
      );
}
