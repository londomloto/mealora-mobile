/// Empat waktu makan tetap (spec food-diary, "Empat waktu makan"; Design D6,
/// change 007). Tidak dapat diubah atau ditambah pengguna pada MVP 1.
enum MealTime {
  breakfast,
  lunch,
  snack,
  dinner;

  /// Kode mesin yang disimpan — stabil, bukan untuk ditampilkan.
  String get stableCode => switch (this) {
    MealTime.breakfast => 'breakfast',
    MealTime.lunch => 'lunch',
    MealTime.snack => 'snack',
    MealTime.dinner => 'dinner',
  };

  static MealTime fromStableCode(String code) =>
      MealTime.values.firstWhere((m) => m.stableCode == code);
}
