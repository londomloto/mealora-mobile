/// Keyakinan sebuah nilai hasil pembacaan model (spec image-ai-access,
/// "Hasil model tidak pernah menjadi data terverifikasi"; spec
/// nutrition-label-extraction, "Nilai yang tidak terbaca tetap belum
/// diketahui").
///
/// Hanya tiga keadaan — sengaja dibatasi (design.md Risks, "Layar
/// peninjauan membengkak karena banyak keadaan per nilai"): [confident]
/// tampil siap dipakai, [needsCheck] dan [unread] SAMA-SAMA menahan
/// konfirmasi sampai pengguna memeriksa atau mengisi sendiri — bedanya
/// hanya nilai awal yang ditampilkan (tebakan model vs kosong), bukan
/// perlakuan penahanannya.
enum ReadingConfidence {
  /// Terbaca jelas dari foto — tetap dapat disunting (task 7.2), tetap
  /// SHALL TIDAK dianggap terverifikasi sampai pengguna mengonfirmasi
  /// layar peninjauan.
  confident,

  /// Terbaca tapi buram, satuannya ambigu, atau model ragu. Nilai yang
  /// dikembalikan model SHALL tetap ditampilkan sebagai usulan yang harus
  /// diperiksa, bukan dibuang.
  needsCheck,

  /// Tidak terlihat sama sekali pada foto. SHALL TIDAK pernah diisi nol
  /// atau tebakan (spec, "Nilai lemak tidak terbaca").
  unread;

  /// `true` untuk [needsCheck] dan [unread] — nilai awal yang BELUM
  /// dianggap diperiksa pengguna. Bukan keadaan akhir: layar peninjauan
  /// menandai sebuah nilai "sudah diperiksa" begitu pengguna menyunting
  /// atau menegaskannya (task 7.6), terlepas dari [ReadingConfidence] awal
  /// yang dikembalikan model.
  bool get needsUserAttention => this != ReadingConfidence.confident;
}
