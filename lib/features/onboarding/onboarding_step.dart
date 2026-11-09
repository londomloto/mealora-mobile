/// Tahap alur onboarding (Design D1/D9, change 005).
///
/// Urutan mengikuti rancangan, bukan urutan teknis (Design D1): sambutan,
/// profil, aktivitas, pilih program, detail program, target berat (hanya
/// Turun Berat/Naik Berat), tinjau target.
///
/// `programSelect` dan seterusnya dibangun bersama layarnya masing-masing
/// (change ini, Tahap 2) — tercantum di sini sekarang karena indikator
/// "langkah keberapa dari berapa" (task 3.4) perlu tahu bentuk alur penuh
/// sejak awal, bukan supaya `OnboardingDraft` membawa data yang belum
/// dipakai.
enum OnboardingStep {
  welcome,
  profileBasics,
  activity,
  programSelect,
  programDetail,
  targetWeight,

  /// `12 · Tinjau target` (task 5.1) — juga menampilkan `26 · Target tidak
  /// dibuat` (task 6.1) sebagai keadaan internal ketika
  /// `OnboardingDraft.lastOutcome` bukan `Approved` (lihat
  /// `review_screen.dart`), bukan langkah tersendiri: keduanya dicapai dari
  /// percobaan menyetujui yang sama, bukan dilalui maju-mundur seperti
  /// langkah lain.
  review,
}

/// Indikator "langkah keberapa dari berapa" (task 3.4, FRS 3.3.7).
///
/// Rancangan `docs/mealora.pen` menunjukkan tepat lima langkah bernomor —
/// `08` s.d. `12` tampil sebagai "LANGKAH 1/5" s.d. "LANGKAH 5/5" — tidak
/// berubah menurut program yang dipilih. `welcome` (`07`) tidak menampilkan
/// indikator sama sekali, dan `targetWeight` (`25`) memakai label konteks
/// berbeda ("PROGRAM · TURUN BERAT", bukan "LANGKAH n/5") karena ia adalah
/// kelanjutan langkah 4, bukan langkah tersendiri.
extension OnboardingStepDisplay on OnboardingStep {
  static const List<OnboardingStep> _numbered = <OnboardingStep>[
    OnboardingStep.profileBasics,
    OnboardingStep.activity,
    OnboardingStep.programSelect,
    OnboardingStep.programDetail,
    OnboardingStep.review,
  ];

  /// `null` untuk `welcome` dan `targetWeight` — keduanya tidak tampil di
  /// indikator "LANGKAH n/5".
  int? get displayNumber {
    final index = _numbered.indexOf(this);
    return index == -1 ? null : index + 1;
  }

  static int get displayTotal => _numbered.length;
}
