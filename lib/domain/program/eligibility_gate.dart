import 'package:mealora/domain/shared/reason_code.dart';

/// Hasil satu aturan kelayakan (Bagian 2.B/2.E) — bukan keluaran akhir
/// mesin, hanya langkah internal yang dapat diuji sendiri-sendiri.
sealed class EligibilityGate {
  const EligibilityGate();
}

/// Lolos aturan ini; lanjutkan ke aturan berikutnya.
final class EligibilityPass extends EligibilityGate {
  const EligibilityPass();
}

/// Lolos aturan ini, tetapi untuk Makan Sehat tanpa target energi/makro
/// (B3/B8) — mesin berhenti di sini, tidak ada nilai yang dihitung.
final class EligibilityPassWithoutTargets extends EligibilityGate {
  const EligibilityPassWithoutTargets();
}

/// Macam penolakan — menentukan varian `ProgramOutcome` yang dibentuk.
enum RejectionKind {
  needsUserCorrection,
  needsProfessionalReview,
  unsupportedProfile,
}

/// Gagal pada aturan ini; mesin berhenti, tidak ada nilai yang dihitung.
final class EligibilityRejected extends EligibilityGate {
  const EligibilityRejected({
    required this.kind,
    required this.reasonCode,
    this.details = const <String, Object?>{},
  });

  final RejectionKind kind;
  final ReasonCode reasonCode;
  final Map<String, Object?> details;
}
