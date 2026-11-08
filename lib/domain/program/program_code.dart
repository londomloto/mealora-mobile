/// Kode empat program yang ditawarkan Mealora (program-catalog spec).
///
/// Kode ini SHALL stabil dan SHALL TIDAK berubah setelah dirilis — change
/// 004 memakai kode yang sama persis untuk menyeed tabel katalog.
enum ProgramCode {
  weightLoss,
  weightGain,
  maintenance,
  healthyEating;

  /// Kode mesin yang disimpan (stabil, bukan untuk ditampilkan).
  String get stableCode => switch (this) {
    ProgramCode.weightLoss => 'weight_loss',
    ProgramCode.weightGain => 'weight_gain',
    ProgramCode.maintenance => 'maintenance',
    ProgramCode.healthyEating => 'healthy_eating',
  };
}
