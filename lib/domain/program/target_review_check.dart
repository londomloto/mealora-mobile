import 'package:mealora/domain/program/nutrition_policy.dart';
import 'package:mealora/domain/shared/units.dart';

/// Pemeriksaan ambang hitung ulang target terhadap berat yang dipakai
/// target yang berlaku (change 008, design D5).
///
/// Berbeda dari `ProgramEngine.checkRapidWeightChange` (B9): fungsi itu
/// menolak AKTIVASI program dari perubahan berat yang DILAPORKAN pengguna
/// sendiri saat skrining (`needsProfessionalReview`). Fungsi ini TIDAK
/// menolak apa pun — ia hanya mengusulkan peninjauan target pada program
/// yang SUDAH berjalan, dari berat yang BENAR-BENAR tercatat (change 008).
/// Keduanya memakai ambang persentase yang sama dari kebijakan yang sama
/// (`np-1.0.0`), tetapi konsekuensinya berbeda — lihat design D5: "Usulan
/// ditampilkan di ruang Program, bukan sebagai gangguan di tengah
/// pencatatan berat".
abstract final class TargetReviewCheck {
  /// `true` bila [latestWeight] berbeda dari [baselineWeight] — berat yang
  /// dipakai menghitung target yang berlaku saat ini, yaitu
  /// `UserProgram.inputSnapshot.currentWeight` — melebihi
  /// `policy.eligibility.unintendedChangeThresholdPercent`.
  ///
  /// Mengembalikan `false` bila [baselineWeight] nol (pembagian tidak
  /// bermakna) — kasus yang seharusnya tidak pernah terjadi karena berat
  /// sudah divalidasi masuk akal sebelum tersimpan sebagai masukan program.
  static bool isRecommended({
    required Mass baselineWeight,
    required Mass latestWeight,
    required NutritionPolicy policy,
  }) {
    if (baselineWeight.kg == 0) {
      return false;
    }
    final percentChange =
        (latestWeight.kg - baselineWeight.kg).abs() / baselineWeight.kg * 100;
    return percentChange > policy.eligibility.unintendedChangeThresholdPercent;
  }
}
