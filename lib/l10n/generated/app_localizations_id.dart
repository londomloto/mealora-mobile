// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Indonesian (`id`).
class AppTextId extends AppText {
  AppTextId([String locale = 'id']) : super(locale);

  @override
  String get appName => 'Mealora';

  @override
  String get appTagline => 'catat makanan sehatmu';

  @override
  String get splashPrivacyPromise =>
      'Pribadi di perangkatmu · siap digunakan offline';

  @override
  String get splashLoadingSemantics => 'Mealora sedang disiapkan';

  @override
  String get splashLogoSemantics => 'Logo Mealora';

  @override
  String get storageErrorTitle => 'Penyimpanan di perangkat belum siap';

  @override
  String get storageErrorBody =>
      'Mealora tidak bisa membuka penyimpanan di perangkat ini, jadi catatanmu belum bisa dibaca atau ditulis. Data yang sudah ada tidak diubah.';

  @override
  String get storageErrorReasonLabel => 'Kode kegagalan';

  @override
  String get retry => 'Coba lagi';

  @override
  String get navToday => 'Hari ini';

  @override
  String get navProgram => 'Program';

  @override
  String get navHistory => 'Riwayat';

  @override
  String get navProfile => 'Profil';

  @override
  String navSelectedSemantics(String destination) {
    return '$destination, sedang dibuka';
  }

  @override
  String navUnselectedSemantics(String destination) {
    return '$destination';
  }

  @override
  String get navRecordSemantics => 'Catat makanan';

  @override
  String get recordUnavailable =>
      'Pencatatan makanan belum tersedia. Bagian ini menyusul pada tahap berikutnya.';

  @override
  String get emptyStateBadge => 'Belum ada data';

  @override
  String get todaySubtitle => 'Ringkasan energi dan makronutrienmu hari ini.';

  @override
  String get programSubtitle =>
      'Program yang sedang kamu jalani beserta targetnya.';

  @override
  String get historySubtitle =>
      'Catatan harianmu pada tanggal-tanggal sebelumnya.';

  @override
  String get profileSubtitle =>
      'Profil lokal, satuan, dan kendali atas datamu.';

  @override
  String get todayEmptyTitle => 'Belum ada catatan hari ini';

  @override
  String get todayEmptyBody =>
      'Di sini nanti muncul energi dan makronutrien yang sudah kamu catat hari ini, dikelompokkan per waktu makan. Pencatatan makanan masuk pada tahap berikutnya.';

  @override
  String get programEmptyTitle => 'Belum ada program';

  @override
  String get programEmptyBody =>
      'Di sini nanti muncul program yang sedang kamu jalani beserta target hariannya dan perkembanganmu. Pemilihan program masuk pada tahap berikutnya.';

  @override
  String get historyEmptyTitle => 'Belum ada riwayat';

  @override
  String get historyEmptyBody =>
      'Di sini nanti muncul catatan harianmu pada tanggal-tanggal sebelumnya, lengkap dengan ringkasan energi dan makronutrien.';

  @override
  String get profileEmptyTitle => 'Belum ada profil';

  @override
  String get profileEmptyBody =>
      'Di sini nanti muncul profil lokalmu, satuan dan bahasa, serta kendali atas data yang tersimpan di perangkat.';

  @override
  String get routeNotFoundTitle => 'Halaman tidak ditemukan';

  @override
  String get routeNotFoundBody =>
      'Alamat yang diminta tidak dikenali Mealora. Kamu bisa kembali ke ruang utama dan melanjutkan dari sana.';

  @override
  String get routeNotFoundAction => 'Kembali ke Hari ini';

  @override
  String get unitKilogram => 'kg';

  @override
  String get unitCentimeter => 'cm';

  @override
  String get unitKilocalorie => 'kkal';

  @override
  String get unitGram => 'g';

  @override
  String valueWithUnit(String value, String unit) {
    return '$value $unit';
  }

  @override
  String onboardingStepLabel(int step, int total) {
    return 'LANGKAH $step / $total';
  }

  @override
  String get onboardingWelcomeEyebrow => 'Diary makanan harianmu';

  @override
  String get onboardingWelcomeHeading =>
      'Kenali makananmu.\nNikmati prosesnya.';

  @override
  String get onboardingWelcomeDescription =>
      'Catat makanan, pahami kebutuhan harian, dan ikuti programmu—tanpa akun dan tetap bisa offline.';

  @override
  String get onboardingWelcomeAction => 'Mulai perjalanan';

  @override
  String get onboardingWelcomePrivacy =>
      'Data pribadimu tersimpan di perangkat ini.';

  @override
  String get onboardingWelcomeHeroSemantics => 'Ilustrasi makanan Indonesia';

  @override
  String get onboardingWelcomePromiseLogTitle => 'Catat cepat';

  @override
  String get onboardingWelcomePromiseLogDetail =>
      'Foto, suara, barcode, atau manual';

  @override
  String get onboardingWelcomePromiseFairTitle => 'Program yang jujur';

  @override
  String get onboardingWelcomePromiseFairDetail =>
      'Target perkiraan, bukan janji instan';

  @override
  String get onboardingWelcomePromisePrivacyTitle => 'Privasi dulu';

  @override
  String get onboardingWelcomePromisePrivacyDetail =>
      'Data tersimpan di perangkatmu';

  @override
  String get onboardingProfileTitle => 'Kenalan dulu, yuk';

  @override
  String get onboardingProfileSubtitle =>
      'Informasi ini membantu membuat estimasi energi.';

  @override
  String get onboardingNicknameLabel => 'Nama panggilan (opsional)';

  @override
  String get onboardingNicknameHint => 'mis. Naya';

  @override
  String get onboardingBirthDateLabel => 'Tanggal lahir';

  @override
  String get onboardingBirthDateHint => 'HH-BB-TTTT';

  @override
  String get onboardingHeightLabel => 'Tinggi badan';

  @override
  String get onboardingHeightHint => 'mis. 165';

  @override
  String get onboardingWeightLabel => 'Berat saat ini';

  @override
  String get onboardingWeightHint => 'mis. 68,4';

  @override
  String get onboardingBiologicalInputLabel => 'Input untuk persamaan energi';

  @override
  String get onboardingBiologicalInputDisclosure =>
      'Digunakan hanya untuk persamaan estimasi energi, bukan identitas gender.';

  @override
  String get onboardingBiologicalInputFemale => 'Perempuan';

  @override
  String get onboardingBiologicalInputMale => 'Laki-laki';

  @override
  String get onboardingContinueAction => 'Lanjutkan';

  @override
  String get onboardingRequiredBirthDate => 'Tanggal lahir belum diisi.';

  @override
  String get onboardingRequiredHeight => 'Tinggi badan belum diisi.';

  @override
  String get onboardingRequiredWeight => 'Berat badan belum diisi.';

  @override
  String get onboardingRequiredBiologicalInput => 'Pilih salah satu dulu.';

  @override
  String get onboardingBackSemantics => 'Kembali ke langkah sebelumnya';

  @override
  String get onboardingActivityTitle => 'Seberapa aktif harimu?';

  @override
  String get onboardingActivitySubtitle =>
      'Pilih yang paling mendekati rutinitas biasa.';

  @override
  String get onboardingActivitySedentaryTitle => 'Lebih banyak duduk';

  @override
  String get onboardingActivitySedentaryDetail =>
      'Aktivitas fisik sehari-hari ringan';

  @override
  String get onboardingActivityModerateTitle => 'Cukup bergerak';

  @override
  String get onboardingActivityModerateDetail =>
      'Berjalan atau bergerak secara rutin';

  @override
  String get onboardingActivityVeryTitle => 'Sangat aktif';

  @override
  String get onboardingActivityVeryDetail => 'Sering beraktivitas fisik intens';

  @override
  String get onboardingActivityNote =>
      'Faktor aktivitas memengaruhi estimasi. Pilih dengan jujur; kamu bisa mengubahnya nanti.';

  @override
  String get onboardingProgramSelectTitle => 'Pilih arahmu';

  @override
  String get onboardingProgramSelectSubtitle =>
      'Empat program. Kamu bisa menggantinya nanti.';

  @override
  String get onboardingProgramHealthyName => 'Makan Sehat';

  @override
  String get onboardingProgramHealthyDescription =>
      'Fokus pada kebiasaan makan';

  @override
  String get onboardingProgramWeightLossName => 'Turun Berat';

  @override
  String get onboardingProgramWeightLossDescription =>
      'Target berat dengan kebijakan aman';

  @override
  String get onboardingProgramWeightGainName => 'Naik Berat';

  @override
  String get onboardingProgramWeightGainDescription =>
      'Target berat dengan kebijakan aman';

  @override
  String get onboardingProgramMaintenanceName => 'Pertahankan';

  @override
  String get onboardingProgramMaintenanceDescription => 'Menjaga keseimbangan';

  @override
  String get onboardingProgramTerms =>
      'Program yang mengubah berat punya batas usia dan kondisi tertentu.';

  @override
  String onboardingProgramDetailFocusTitle(String program) {
    return 'Fokus $program';
  }

  @override
  String onboardingProgramDetailGenericTitle(String program) {
    return 'Detail $program';
  }

  @override
  String get onboardingProgramDetailFocusSubtitle =>
      'Mulai dari hal-hal yang bisa kamu lakukan.';

  @override
  String get onboardingProgramDetailGenericSubtitle =>
      'Tinjau sebelum melanjutkan ke perkiraan target.';

  @override
  String get onboardingProgramClarificationNoTarget =>
      'Tanpa target berat wajib';

  @override
  String get onboardingProgramClarificationHasTarget =>
      'Berat tujuan diatur di langkah berikutnya';

  @override
  String get onboardingFocusHeading => 'Apa yang ingin kamu perhatikan?';

  @override
  String get onboardingFocusConsistentLogging => 'Konsisten mencatat makanan';

  @override
  String get onboardingFocusMacros => 'Memahami protein & makro';

  @override
  String get onboardingFocusPortions => 'Mengenal porsi makan';

  @override
  String get onboardingAcknowledgeText =>
      'Saya paham bahwa target dan data makanan adalah perkiraan, bukan nasihat medis.';

  @override
  String get onboardingAcknowledgeRequired =>
      'Beri pengakuan ini dulu untuk melihat pratinjau.';

  @override
  String get onboardingPreviewAction => 'Lihat perkiraan target';

  @override
  String onboardingTargetWeightContext(String program) {
    return 'PROGRAM · $program';
  }

  @override
  String get onboardingTargetWeightTitle => 'Atur target berat';

  @override
  String get onboardingTargetWeightSubtitle =>
      'Laju perubahan berat dibatasi agar tetap aman.';

  @override
  String get onboardingTargetWeightLossNote =>
      'Bukan target cepat atau janji hasil.';

  @override
  String get onboardingTargetWeightGainNote =>
      'Bukan target cepat atau janji hasil.';

  @override
  String get onboardingStartingWeightLabel => 'Berat awal';

  @override
  String get onboardingGoalWeightLabel => 'Berat tujuan';

  @override
  String get onboardingGoalWeightHint => 'mis. 62,0';

  @override
  String get onboardingTargetDateLabel => 'Tanggal tujuan (opsional)';

  @override
  String get onboardingTargetDateHint => 'Pilih tanggal (opsional)';

  @override
  String get onboardingTargetDateHeading => 'Tanggal tujuan tidak wajib';

  @override
  String get onboardingTargetDateExplanation =>
      'Tanggal tidak pernah mengesampingkan aturan keselamatan.';

  @override
  String get onboardingWeightGateNote =>
      'Sebagian kondisi membuat target otomatis tidak dibuat. Kamu akan diberi tahu alasannya.';

  @override
  String get onboardingReviewEligibilityAction => 'Tinjau kelayakan';

  @override
  String get onboardingRequiredTargetWeight => 'Berat tujuan belum diisi.';

  @override
  String get reviewStepLabel => 'LANGKAH 5 / 5';

  @override
  String get reviewTitle => 'Tinjau targetmu';

  @override
  String get reviewSubtitle => 'Periksa semua detail sebelum program dimulai.';

  @override
  String get reviewTargetLabel => 'ESTIMASI TARGET HARIAN';

  @override
  String get reviewTargetDisclaimer =>
      'Perkiraan dari rumus, bukan hasil pengukuran.';

  @override
  String get reviewBasisHeading => 'Dasar perkiraan';

  @override
  String get reviewBasisProfileLabel => 'Profil';

  @override
  String get reviewBasisProfileValue => 'Usia, tinggi, berat';

  @override
  String get reviewBasisActivityLabel => 'Aktivitas';

  @override
  String get reviewBasisEquationLabel => 'Persamaan';

  @override
  String get reviewVersionHeading => 'Tinjau sebelum menyetujui';

  @override
  String get reviewVersionDetail =>
      'Mealora menampilkan versi kalkulator dan kebijakan, asumsi yang dipakai, serta alasan setiap batasan.';

  @override
  String reviewVersionLine(String calculatorVersion, String policyVersion) {
    return 'Kalkulator $calculatorVersion · Kebijakan $policyVersion';
  }

  @override
  String get reviewNoActiveProgramNote =>
      'Tidak ada program aktif sebelum kamu menyetujui.';

  @override
  String get reviewApproveAction => 'Setujui & mulai program';

  @override
  String get reviewNoEnergyTargetNote =>
      'Programmu berfokus pada kebiasaan makan, tanpa angka target energi.';

  @override
  String get reviewAssumptionEstimateNotMeasurement =>
      'Seluruh angka adalah perkiraan dari rumus, bukan hasil pengukuran atau jaminan.';

  @override
  String get reviewWarningFloorApplied =>
      'Target dinaikkan ke batas asupan aman terendah.';

  @override
  String get reviewWarningRelativePaceCapApplied =>
      'Laju perubahan berat dibatasi menurut persentase berat badanmu.';

  @override
  String get reviewWarningCarbohydrateBelowRecommendedRange =>
      'Proporsi karbohidrat berada di bawah rentang yang dianjurkan setelah penyesuaian.';

  @override
  String get reviewChangedContextLabel => 'DATA DIPERBARUI';

  @override
  String get reviewChangedTitle => 'Masukanmu berubah';

  @override
  String get reviewChangedSubtitle =>
      'Sejak pratinjau terakhir, beberapa datamu berubah. Pratinjau di bawah ini sudah memakai nilai terbaru.';

  @override
  String get reviewChangedHeading => 'Apa yang berubah';

  @override
  String get reviewChangedFieldWeight => 'Berat badan';

  @override
  String reviewChangedValue(String oldValue, String newValue) {
    return '$oldValue → $newValue';
  }

  @override
  String get reviewChangedTargetLabel => 'ESTIMASI TARGET HARIAN · DIPERBARUI';

  @override
  String get reviewChangedNoteHeading => 'Tinjau sekali lagi';

  @override
  String get reviewChangedNoteDetail =>
      'Mealora memakai data terbarumu untuk pratinjau ini. Tidak ada yang salah dengan isianmu sebelumnya.';

  @override
  String get reviewChangedConfirmation =>
      'Program tersimpan tidak berubah sampai kamu menyetujui ulang.';

  @override
  String get reviewChangedAction => 'Tinjau & setujui ulang';

  @override
  String get rejectionContextLabel => 'STATUS · TARGET TIDAK DIBUAT';

  @override
  String get rejectionTitle => 'Target tidak dibuat';

  @override
  String get rejectionSubtitle =>
      'Kami tidak membuat target untuk kondisi ini.';

  @override
  String get rejectionNoChangeNote =>
      'Data dan program sebelumnya tidak berubah.';

  @override
  String get rejectionAlternativeHeading => 'Coba Makan Sehat';

  @override
  String get rejectionAlternativeDetail =>
      'Catat makanan dan pahami kebiasaan tanpa target perubahan berat.';

  @override
  String get rejectionAlternativeAction => 'Lihat program lain';

  @override
  String get rejectionBackToProgramAction => 'Pilih program lagi';

  @override
  String get rejectionChangeInputAction => 'Ubah masukan';

  @override
  String get rejectionAgeBelowMinimumHeading =>
      'Belum bisa membuat target otomatis';

  @override
  String get rejectionAgeBelowMinimumExplanation =>
      'Mealora membuat target otomatis untuk rentang usia dewasa. Usia yang kamu isi berada di luar rentang itu.';

  @override
  String get rejectionAgeAboveSupportedHeading =>
      'Belum bisa membuat target otomatis';

  @override
  String get rejectionAgeAboveSupportedExplanation =>
      'Mealora membuat target otomatis untuk rentang usia yang didukung kalkulatornya saat ini. Usia yang kamu isi berada di luar rentang itu.';

  @override
  String get rejectionPregnancyOrLactationHeading =>
      'Belum bisa membuat target otomatis';

  @override
  String get rejectionPregnancyOrLactationExplanation =>
      'Perkiraan kebutuhan energi berbeda pada masa kehamilan atau menyusui, dan kalkulator ini belum mendukungnya.';

  @override
  String get rejectionUnderweightBmiHeading =>
      'Belum bisa membuat target otomatis';

  @override
  String get rejectionUnderweightBmiExplanation =>
      'Kombinasi tinggi dan berat yang kamu isi berada di luar rentang yang bisa dihitung kalkulator ini secara otomatis.';

  @override
  String get rejectionBmiAboveSupportedHeading =>
      'Belum bisa membuat target otomatis';

  @override
  String get rejectionBmiAboveSupportedExplanation =>
      'Kombinasi tinggi dan berat yang kamu isi berada di luar rentang yang bisa dihitung kalkulator ini secara otomatis.';

  @override
  String get rejectionDeclaredMedicalConditionHeading =>
      'Belum bisa membuat target otomatis';

  @override
  String get rejectionDeclaredMedicalConditionExplanation =>
      'Kamu menandai satu atau lebih kondisi yang membuat target perubahan berat perlu disesuaikan oleh tenaga kesehatan, bukan dihitung otomatis.';

  @override
  String get rejectionRapidUnintendedWeightChangeHeading =>
      'Belum bisa membuat target otomatis';

  @override
  String get rejectionRapidUnintendedWeightChangeExplanation =>
      'Kamu melaporkan perubahan berat yang cukup besar dalam waktu singkat belakangan ini. Kalkulator ini perlu masukan tambahan dari tenaga kesehatan sebelum menghitung target baru.';

  @override
  String get rejectionTargetBelowMinimumEnergyHeading =>
      'Belum bisa membuat target otomatis';

  @override
  String get rejectionTargetBelowMinimumEnergyExplanation =>
      'Permintaanmu membuat perkiraan asupan energi harian turun lebih rendah dari batas aman yang dipakai kalkulator ini.';

  @override
  String get rejectionRequestedPaceTooFastHeading =>
      'Tanggal ini butuh laju yang terlalu cepat';

  @override
  String rejectionRequestedPaceTooFastExplanation(String earliestSafeDate) {
    return 'Perubahan berat yang kamu minta dalam rentang waktu ini lebih cepat dari batas aman yang dipakai kalkulator ini. Tanggal paling awal yang memenuhi batas: $earliestSafeDate.';
  }

  @override
  String get rejectionRequestedPaceTooSlowHeading =>
      'Laju ini lebih lambat dari yang didukung';

  @override
  String get rejectionRequestedPaceTooSlowExplanation =>
      'Perubahan berat yang kamu minta dalam rentang waktu ini lebih lambat dari laju minimum yang dipakai kalkulator ini.';

  @override
  String get rejectionTargetWeightOutOfRangeHeading =>
      'Berat tujuan ini di luar jangkauan kalkulator';

  @override
  String get rejectionTargetWeightOutOfRangeExplanation =>
      'Berat tujuan yang kamu isi berada di luar rentang yang bisa dihitung kalkulator ini secara otomatis dari berat saat ini.';

  @override
  String get rejectionMissingValidatedPolicyHeading =>
      'Target otomatis tidak tersedia';

  @override
  String get rejectionMissingValidatedPolicyExplanation =>
      'Mealora tidak bisa menghitung target otomatis saat ini.';

  @override
  String get rejectionMissingRequiredInputHeading =>
      'Masih ada isian yang perlu dilengkapi';

  @override
  String get rejectionMissingRequiredInputExplanation =>
      'Satu atau lebih isian wajib pada langkah sebelumnya belum lengkap.';

  @override
  String get noProgramContextLabel => 'PROGRAM SAYA';

  @override
  String get noProgramTitle => 'Pilih programmu';

  @override
  String get noProgramSubtitle => 'Catatan lamamu tetap ada dan bisa dibuka.';

  @override
  String get noProgramHeading => 'Belum ada program aktif';

  @override
  String get noProgramDescription =>
      'Pilih satu dari empat program. Kamu akan meninjau input, asumsi, dan target sebelum menyetujui.';

  @override
  String get noProgramHistoryHeading => 'Data sebelumnya aman';

  @override
  String get noProgramHistoryExplanation =>
      'Catatan makanan dan berat lama tetap ada meski kamu belum memilih program.';

  @override
  String get noProgramAction => 'Pilih program';

  @override
  String todayProgramChipSemantics(String program) {
    return 'Program aktif: $program';
  }

  @override
  String get todayDailyTargetLabel => 'Target energi hari ini';

  @override
  String get todayConsumedUnknown => 'Belum diketahui';

  @override
  String get todayConsumedLabel => 'Dikonsumsi';
}
