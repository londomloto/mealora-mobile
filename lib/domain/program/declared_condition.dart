/// Kondisi atau pengobatan yang dinyatakan pengguna sendiri (B8). Mealora
/// tidak memverifikasinya — skrining bergantung sepenuhnya pada pernyataan
/// pengguna.
enum DeclaredCondition {
  diabetes,
  kidneyDisease,
  liverDisease,
  weightOrAppetiteAffectingMedication,

  /// Gangguan makan, kini atau di masa lalu — diperlakukan berbeda dari
  /// kondisi lain: Makan Sehat tetap aktif tanpa target (B8, U7).
  eatingDisorderCurrentOrPast,
}
