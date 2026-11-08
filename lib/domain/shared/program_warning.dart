/// Kode peringatan tertutup yang menyertai hasil `approved` tanpa mengubah
/// keadaan hasil itu sendiri. Sama seperti `ReasonCode`, ini kode — bukan
/// kalimat bebas; pemetaan ke teks ada di lapisan presentasi.
enum ProgramWarning {
  /// Target dinaikkan oleh lantai energi istirahat/absolut (D5).
  floorApplied,

  /// Laju perubahan berat dibatasi oleh batas relatif (E2).
  relativePaceCapApplied,

  /// Proporsi karbohidrat tetap di bawah 45% energi setelah penyesuaian
  /// (F12).
  carbohydrateBelowRecommendedRange,
}
