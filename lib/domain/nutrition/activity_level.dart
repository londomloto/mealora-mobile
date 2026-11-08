/// Tingkat aktivitas fisik, dipakai sebagai pengali pengeluaran energi
/// harian (C3). Nilai pengali sendiri adalah data kebijakan yang dibaca
/// lewat `EnergyEquationPolicy`, bukan konstanta yang ditanam di sini.
enum ActivityLevel {
  /// "Lebih banyak duduk".
  sedentary,

  /// "Cukup bergerak".
  moderatelyActive,

  /// "Sangat aktif".
  veryActive,
}
