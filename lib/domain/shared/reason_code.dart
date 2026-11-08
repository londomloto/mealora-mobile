/// Kode alasan tertutup untuk hasil program yang tidak disetujui.
///
/// Daftar ini sesuai persis dengan I1 di
/// `mealora-plans/docs/nutrition-policy-v1.md`. Tidak ada kalimat bebas di
/// domain: pemetaan kode ke kalimat pengguna berada di lapisan presentasi.
enum ReasonCode {
  ageBelowMinimum,
  ageAboveSupported,
  pregnancyOrLactation,
  underweightBmi,
  bmiAboveSupported,
  declaredMedicalCondition,
  rapidUnintendedWeightChange,
  targetBelowMinimumEnergy,
  requestedPaceTooFast,
  requestedPaceTooSlow,
  targetWeightOutOfRange,
  missingRequiredInput,
}
