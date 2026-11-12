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
  String get appTagline => 'Diary makanan harianmu';

  @override
  String get backButtonSemantics => 'Kembali';

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
  String get programPageTitle => 'Program saya';

  @override
  String get programPageSubtitle => 'Ruang untuk bertumbuh, pelan-pelan';

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
  String todayGreeting(String name) {
    return 'Hai, $name!';
  }

  @override
  String get todayDefaultName => 'Teman';

  @override
  String get programSubtitle =>
      'Program yang sedang kamu jalani beserta targetnya.';

  @override
  String get historySubtitle =>
      'Catatan harianmu pada tanggal-tanggal sebelumnya.';

  @override
  String get historyContextLabel => 'RIWAYAT';

  @override
  String get historyTodayContextLabel => 'HARI INI';

  @override
  String get historyDiaryTitle => 'Buku harian';

  @override
  String get historyLocalNote => 'catatan di perangkat';

  @override
  String get historyRecordedTodayLabel => 'TERCATAT HARI INI';

  @override
  String get historyOpenCalendarLabel => 'Buka kalender riwayat';

  @override
  String get historyPageTitle => 'Lihat perjalananmu';

  @override
  String get historyPageSubtitle => 'Catatan harian, tanpa hari yang ‘gagal’.';

  @override
  String get profileSubtitle =>
      'Profil lokal, satuan, dan kendali atas datamu.';

  @override
  String get profileContextLabel => 'PROFIL';

  @override
  String profilePageTitle(String name) {
    return 'Hai, $name';
  }

  @override
  String get profilePageSubtitle => 'Pengaturan untuk perjalananmu.';

  @override
  String get profileLocalDetail => 'Profil lokal · tanpa akun';

  @override
  String get todayEmptyTitle => 'Hari ini belum tercatat';

  @override
  String get todayEmptyBody =>
      'Kalori dan makro ditampilkan sebagai \"belum diketahui\", bukan 0 kkal atau target yang gagal.';

  @override
  String get todayNoProgramTargetNote =>
      'Belum ada program aktif, jadi belum ada target pembanding.';

  @override
  String todayExcessOverTarget(String kcal) {
    return '$kcal kkal lebih dari perkiraan';
  }

  @override
  String get todayMealNotLogged => 'Belum dicatat';

  @override
  String get todayLogFoodAction => 'Catat makanan';

  @override
  String get todayMealsHeading => 'Makanan hari ini';

  @override
  String todayMealsCountFormat(int count) {
    return '$count waktu makan tercatat';
  }

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
  String get historyEnergyRecordedLabel => 'ENERGI TERCATAT';

  @override
  String get historyWeightRecordedLabel => 'Berat tercatat tanggal ini';

  @override
  String get historyPreviousMonthSemantics => 'Bulan sebelumnya';

  @override
  String get historyNextMonthSemantics => 'Bulan berikutnya';

  @override
  String historyDayHasRecordSemantics(String date) {
    return '$date, ada catatan';
  }

  @override
  String historyDayNoRecordSemantics(String date) {
    return '$date, belum ada catatan';
  }

  @override
  String get historyDaySelectedSuffix => ', terpilih';

  @override
  String get historyDayFutureSuffix => ', belum bisa dipilih';

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
  String get unitMilligram => 'mg';

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
  String get onboardingBiologicalInputHint => 'Pilih salah satu';

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
  String get todayProgramActiveLabel => 'Program aktif';

  @override
  String get todayDailyTargetLabel => 'Target energi hari ini';

  @override
  String get todayConsumedUnknown => 'Belum diketahui';

  @override
  String get todayConsumedLabel => 'Dikonsumsi';

  @override
  String get todayEstimateLabel => 'Perkiraan hari ini';

  @override
  String get todayRemainingLabel => 'Sisa perkiraan';

  @override
  String get todayLoggedLabel => 'Tercatat';

  @override
  String get todayActivityLabel => 'Aktivitas';

  @override
  String get todayActivityLight => 'ringan';

  @override
  String get todayActivityModerate => 'sedang';

  @override
  String get todayActivityHigh => 'tinggi';

  @override
  String get profileIncompleteTitle => 'Lengkapi profil dulu';

  @override
  String get profileIncompleteBody =>
      'Beberapa data profil belum lengkap, jadi target program belum bisa dijelaskan di sini.';

  @override
  String get profileIncompleteAction => 'Lengkapi profil';

  @override
  String get pausedExplanationTitle => 'Catat makanan seperti biasa';

  @override
  String get pausedExplanationBody =>
      'Buku harian dan berat badan tetap tersedia saat program dijeda.';

  @override
  String get programControlsHeading => 'Kendali program';

  @override
  String get programControlsPausedHeading => 'Apa yang ingin kamu lakukan?';

  @override
  String get programResumeAction => 'Lanjutkan program';

  @override
  String get programChangeAction => 'Ganti';

  @override
  String get programCompleteAction => 'Selesaikan program';

  @override
  String get programPauseAction => 'Jeda';

  @override
  String get programHistoryAction => 'Riwayat';

  @override
  String get programPausedEyebrow => 'PROGRAM DIJEDA';

  @override
  String get programActiveEyebrow => 'PROGRAM AKTIF';

  @override
  String get programPausedStatus => 'Dijeda';

  @override
  String get programActiveStatus => 'Berjalan';

  @override
  String get pausedDaysNotCountedExplanation =>
      'Hari jeda tidak dihitung sebagai hari aktif.';

  @override
  String pausedSinceLabel(String date) {
    return 'Dijeda sejak $date';
  }

  @override
  String get programTargetLabel => 'Target harian · perkiraan';

  @override
  String get programHowCalculatedAction => 'Bagaimana dihitung';

  @override
  String programLastCalculatedLabel(String date) {
    return 'Dihitung terakhir $date';
  }

  @override
  String get programLatestWeightLabel => 'Berat terbaru';

  @override
  String get programNoWeightRecordedYet => 'Belum ada catatan berat';

  @override
  String get programTargetReviewTitle => 'Tinjau target program';

  @override
  String get programTargetReviewBody =>
      'Berat terbaru beda cukup jauh dari yang dipakai menghitung target sekarang. Target lama tetap berlaku sampai kamu meninjau dan menyetujui yang baru.';

  @override
  String get programTargetReviewSemantics =>
      'Tinjau target program karena berat terbaru berubah signifikan';

  @override
  String get programConsistencyHeading => 'Kebiasaan minggu ini';

  @override
  String get programConsistencySubheading =>
      'Catatan makan, bukan nilai dirimu';

  @override
  String programConsistencyFooter(int count) {
    return '$count dari 7 hari tercatat';
  }

  @override
  String programConsistencyDaySegmentSemantics(
    String date,
    int filled,
    int total,
  ) {
    return '$date, $filled dari $total waktu makan tercatat';
  }

  @override
  String programConsistencyDayEmptySemantics(String date) {
    return '$date, belum ada catatan';
  }

  @override
  String get howCalculatedBackSemantics => 'Kembali';

  @override
  String get howCalculatedContextLabel => 'PROGRAM SAYA · BAGAIMANA DIHITUNG';

  @override
  String get howCalculatedTitle => 'Bagaimana target dihitung';

  @override
  String howCalculatedSubtitle(String date) {
    return 'Dihitung terakhir $date';
  }

  @override
  String get howCalculatedTargetEyebrow => 'TARGET YANG BERLAKU · PERKIRAAN';

  @override
  String get howCalculatedTargetCaption =>
      'Perkiraan dari rumus; berubah hanya saat revisi disetujui.';

  @override
  String get howCalculatedInputsHeading => 'Masukan yang dipakai';

  @override
  String get howCalculatedHeightLabel => 'Tinggi badan';

  @override
  String get howCalculatedWeightLabel => 'Berat saat dihitung';

  @override
  String get howCalculatedLastCalculatedLabel => 'Tanggal perhitungan terakhir';

  @override
  String get howCalculatedAssumptionsHeading => 'Asumsi';

  @override
  String get howCalculatedActivityFactorLabel => 'Faktor aktivitas';

  @override
  String get howCalculatedRoundingLabel => 'Pembulatan';

  @override
  String get howCalculatedRoundingValue => 'Ke kelipatan 10 kkal terdekat';

  @override
  String get howCalculatedWarningsHeading => 'Peringatan';

  @override
  String get howCalculatedWarningFloorTitle => 'Batas bawah energi diterapkan';

  @override
  String get howCalculatedWarningPaceCapTitle =>
      'Laju perubahan berat dibatasi';

  @override
  String get howCalculatedWarningCarbTitle =>
      'Proporsi karbohidrat disesuaikan';

  @override
  String get howCalculatedReadOnlyNote =>
      'Nilai di layar ini dibaca dari target yang tersimpan, bukan dihitung ulang.';

  @override
  String get completeContextLabel => 'PROGRAM SAYA';

  @override
  String get completeTitle => 'Selesaikan program?';

  @override
  String get completeSubtitle => 'Keputusan ini tidak menghapus perjalananmu.';

  @override
  String get completeProgramEyebrow => 'PROGRAM AKTIF';

  @override
  String get completeReasonHeading => 'Alasan selesai';

  @override
  String get completeReasonPlaceholder => 'Pilih alasan';

  @override
  String get completeSnapshotTitle => 'Ringkasan akhir disimpan';

  @override
  String get completeSnapshotBody =>
      'Hari aktif dan catatan yang tersedia diarsipkan tanpa mengubah log makan.';

  @override
  String get completeFinalityNote =>
      'Program yang selesai tidak dapat dilanjutkan. Kamu bisa memulai program baru.';

  @override
  String get completeCancelAction => 'Batal, tetap di program ini';

  @override
  String get completeConfirmAction => 'Ya, selesaikan program';

  @override
  String get completeReasonGoalReached => 'Saya sudah mencapai tujuan';

  @override
  String get completeReasonSwitchingProgram =>
      'Saya ingin mencoba program lain';

  @override
  String get completeReasonTakingABreak => 'Saya ingin berhenti sementara';

  @override
  String get completeReasonOther => 'Alasan lain';

  @override
  String get historyProgramContextLabel => 'PROGRAM SAYA';

  @override
  String get historyProgramTitle => 'Riwayat program';

  @override
  String get historyProgramSubtitle => 'Target lama tetap dapat dijelaskan.';

  @override
  String get historyProgramErrorTitle => 'Riwayat tidak bisa dimuat';

  @override
  String get historyProgramErrorBody =>
      'Terjadi kendala saat membaca riwayat program. Catatanmu tidak berubah.';

  @override
  String get historyProgramEmptyTitle => 'Belum ada riwayat';

  @override
  String get historyProgramEmptyBody =>
      'Program yang pernah kamu jalani akan muncul di sini.';

  @override
  String get historyProgramNoteTitle => 'Tidak ada catatan yang hilang';

  @override
  String get historyProgramNoteBody =>
      'Riwayat program tidak mengubah catatan makanan dan berat yang pernah kamu simpan.';

  @override
  String get historyProgramEntryExtra =>
      'Lihat target, input, dan alasan perubahan';

  @override
  String historyProgramRangeRunning(String start) {
    return 'Aktif · sejak $start';
  }

  @override
  String historyProgramRangeEnded(String start, String end) {
    return '$start – $end';
  }

  @override
  String get historyProgramStateDraft => 'Draf';

  @override
  String get historyProgramStateActive => 'Aktif';

  @override
  String get historyProgramStatePaused => 'Dijeda';

  @override
  String get historyProgramStateCompleted => 'Selesai';

  @override
  String get historyProgramStateChanged => 'Diganti';

  @override
  String get historyProgramStateCancelled => 'Dibatalkan';

  @override
  String get historyDetailContextLabel => 'RIWAYAT';

  @override
  String get historyDetailTargetEyebrow => 'TARGET YANG DISETUJUI SAAT ITU';

  @override
  String get historyDetailTargetCaption =>
      'Perkiraan · tidak berubah karena target baru.';

  @override
  String get historyDetailFactsHeading => 'Rincian program';

  @override
  String get historyDetailStatusLabel => 'Status';

  @override
  String get historyDetailStartingWeightLabel => 'Berat awal';

  @override
  String get historyDetailLatestWeightLabel => 'Berat terbaru';

  @override
  String get historyDetailNoDataOnLastDay => 'Belum ada data di hari terakhir';

  @override
  String get historyDetailTargetWeightLabel => 'Target berat';

  @override
  String get historyDetailTargetWeightNotRequired => 'Tidak diwajibkan';

  @override
  String get historyDetailEndReasonLabel => 'Alasan selesai';

  @override
  String get historyDetailEndReasonChanged => 'Diganti dengan program baru';

  @override
  String get historyDetailEndReasonNotEnded => 'Belum berakhir';

  @override
  String get historyDetailEndReasonUnknown => 'Tidak tercatat';

  @override
  String get historyDetailNote =>
      'Input, target, dan versi asli disimpan untuk penjelasan riwayat.';

  @override
  String get revisionComparisonHeading => 'Dibandingkan dengan target sekarang';

  @override
  String get revisionComparisonCurrentLabel => 'Target sekarang';

  @override
  String get revisionComparisonNewLabel => 'Target baru';

  @override
  String get revisionCancelNoteChange => 'Batal? Program aktif tidak berubah.';

  @override
  String get revisionCancelNoteProfile =>
      'Belum disetujui? Target yang berjalan tetap berlaku.';

  @override
  String get revisionFailedMessage =>
      'Perubahan belum bisa disimpan. Programmu yang berjalan tidak berubah.';

  @override
  String get revisionRejectedContextLabel => 'STATUS · TARGET TIDAK DIBUAT';

  @override
  String get revisionRejectedTitle => 'Target tidak dibuat';

  @override
  String get revisionRejectedNoChangeNote =>
      'Program dan target yang berjalan tidak berubah.';

  @override
  String get changeContextLabel => 'GANTI PROGRAM';

  @override
  String get changeTitle => 'Sebelum kamu berganti';

  @override
  String get changeSubtitle => 'Program saat ini akan dipindahkan ke riwayat.';

  @override
  String get changeCurrentProgramEyebrow => 'PROGRAM SEKARANG';

  @override
  String get changeReplacementEyebrow => 'PROGRAM BARU · PRATINJAU';

  @override
  String get changeReplacementDescription =>
      'Nilai dan asumsi target ditinjau sebelum disetujui.';

  @override
  String get changeHistoryNoteTitle => 'Riwayatmu tetap utuh';

  @override
  String get changeHistoryNoteBody =>
      'Catatan makanan, berat, dan target lama tidak dihapus atau ditulis ulang.';

  @override
  String get changeCancelFootnote => 'Batal? Program aktif tidak berubah.';

  @override
  String get changeReviewAction => 'Tinjau target pengganti';

  @override
  String get changePickReplacementTitle => 'Pilih program pengganti';

  @override
  String get changePickReplacementSubtitle =>
      'Kamu bisa menggantinya lagi nanti.';

  @override
  String get changeHabitFocusHeading => 'Fokus kebiasaan';

  @override
  String get changeReviewReplacementAction => 'Tinjau target pengganti';

  @override
  String get editProfileContextLabel => 'PROFIL';

  @override
  String get editProfileTitle => 'Ubah data profil';

  @override
  String get editProfileSubtitle =>
      'Perubahan tidak menulis ulang target lama.';

  @override
  String get editProfileHeightLabel => 'Tinggi badan';

  @override
  String get editProfileWeightLabel => 'Berat saat ini';

  @override
  String get editProfileActivityLabel => 'Aktivitas';

  @override
  String get editProfileUnitsLabel => 'Satuan';

  @override
  String get editProfileUnitsValue => 'Metrik · kg, cm';

  @override
  String get editProfileReviewNoteTitle => 'Target perlu ditinjau ulang';

  @override
  String get editProfileReviewNoteBody =>
      'Profil baru tidak langsung mengubah target aktif. Tinjau perkiraan baru dan setujui revisinya.';

  @override
  String get editProfileDialogCancelAction => 'Batal';

  @override
  String get editProfileDialogSaveAction => 'Simpan';

  @override
  String get editProfileReviewAction => 'Tinjau target baru';

  @override
  String get profileSettingsHeading => 'Akun & program';

  @override
  String get profileEditAction => 'Ubah profil';

  @override
  String get profileUnitsLanguageAction => 'Bahasa & tampilan';

  @override
  String get profilePrivacyAction => 'Privasi & data lokal';

  @override
  String get profileAboutAction => 'Tentang Mealora';

  @override
  String get mealTimeBreakfast => 'Sarapan';

  @override
  String get mealTimeLunch => 'Makan siang';

  @override
  String get mealTimeSnack => 'Camilan';

  @override
  String get mealTimeDinner => 'Makan malam';

  @override
  String get nutrientEnergy => 'Energi';

  @override
  String get nutrientProtein => 'Protein';

  @override
  String get nutrientCarbohydrate => 'Karbohidrat';

  @override
  String get nutrientFiber => 'Serat';

  @override
  String get nutrientSugar => 'Gula';

  @override
  String get nutrientSodium => 'Natrium';

  @override
  String get nutrientFat => 'Lemak';

  @override
  String macroMacrosShort(String protein, String carb, String fat) {
    return 'P $protein · K $carb · L $fat';
  }

  @override
  String get nutrientValueUnknown => '–';

  @override
  String get addFoodSheetTitle => 'Catat makanan';

  @override
  String get addFoodSheetSubtitle => 'Pilih cara yang paling nyaman untukmu';

  @override
  String get addFoodSearchTitle => 'Cari / input manual';

  @override
  String get addFoodSearchDescription => 'Selalu bisa, bahkan tanpa internet';

  @override
  String get addFoodVoiceTitle => 'Catat dengan suara';

  @override
  String get addFoodVoiceDescription => 'Sebutkan saja yang kamu makan';

  @override
  String get addFoodPhotoTitle => 'Foto makanan';

  @override
  String get addFoodPhotoDescription => 'Dapatkan saran dari fotomu';

  @override
  String get addFoodBarcodeTitle => 'Scan barcode';

  @override
  String get addFoodBarcodeDescription => 'Cari produk kemasan dengan cepat';

  @override
  String get addFoodPrivacyLine1 => 'Foto hanya diunggah dengan izinmu.';

  @override
  String get addFoodPrivacyLine2 =>
      'Suara & input manual jalan tanpa internet.';

  @override
  String get addFoodPathUnavailable =>
      'Jalur ini belum tersedia. Pakai pencarian atau buat makanan sendiri dulu, ya.';

  @override
  String get foodSearchContextLabel => 'CATAT MAKANAN';

  @override
  String get foodSearchTitle => 'Cari makanan';

  @override
  String get foodSearchSubtitle => 'Katalog lokal · tersedia tanpa internet';

  @override
  String get foodSearchHint => 'Cari nama makanan…';

  @override
  String get foodSearchClearSemantics => 'Hapus pencarian';

  @override
  String get foodSearchRecentHeading => 'Terakhir dicatat';

  @override
  String foodSearchResultsHeading(String query) {
    return 'Hasil \"$query\"';
  }

  @override
  String get foodSearchNoResultsTitle => 'Tidak ada hasil';

  @override
  String get foodSearchNoResultsBody =>
      'Makanan ini belum ada di katalog. Kamu bisa membuatnya sendiri.';

  @override
  String get foodSearchCreateLink => 'Tidak ada?  + Buat makanan sendiri';

  @override
  String get foodSearchFavoritesLabel => 'Favorit';

  @override
  String get foodSearchFavoritesUnavailable =>
      'Favorit belum tersedia pada versi ini.';

  @override
  String get foodSearchCatalogDataLabel => 'data katalog';

  @override
  String get foodSearchCustomDataLabel => 'buatan sendiri';

  @override
  String foodSearchApproxPerServing(String kcal, String serving) {
    return '± $kcal / $serving';
  }

  @override
  String get servingDetailContextLabel => 'TAMBAH KE BUKU HARIAN';

  @override
  String get servingDetailSubtitle => 'Pilih sajian, jumlah, dan waktu makan.';

  @override
  String get servingDetailSourceCatalog => 'Katalog lokal';

  @override
  String get servingDetailSourceCustom => 'Buatan sendiri';

  @override
  String get servingDetailServingLabel => 'Sajian';

  @override
  String get servingDetailQuantityLabel => 'Jumlah sajian';

  @override
  String get servingDetailMealTimeLabel => 'Waktu makan';

  @override
  String get servingDetailEstimateLabel => 'PERKIRAAN';

  @override
  String servingDetailAddAction(String mealTime) {
    return 'Tambahkan ke $mealTime';
  }

  @override
  String get servingPickerTitle => 'Pilih sajian';

  @override
  String get mealTimePickerTitle => 'Pilih waktu makan';

  @override
  String get servingEstimateBadge => 'perkiraan';

  @override
  String get servingEstimateSemantics => 'Berat takaran ini perkiraan';

  @override
  String servingPickerSubtitle(String food) {
    return '$food · berat setiap takaran ditampilkan';
  }

  @override
  String get servingPickerDefaultTag => 'Bawaan';

  @override
  String get servingPickerDirectWeight => 'berat langsung';

  @override
  String servingPickerApproxWeight(String weight) {
    return '≈ $weight';
  }

  @override
  String get servingPickerDerivedNote => 'dihitung dari data terukur';

  @override
  String servingPickerWeightEntry(String unit) {
    return 'Masukkan berat sendiri ($unit)';
  }

  @override
  String get servingPickerEstimateHint =>
      '\"Perkiraan\" berarti berat takaran diperkirakan dari ukuran umum, belum dari penimbangan resmi. Nilai gizi per 100 g tetap dari TKPI.';

  @override
  String servingDetailWeightServing(String unit) {
    return 'Berat sendiri ($unit)';
  }

  @override
  String get servingDetailWeightLabel => 'Berat yang dimakan';

  @override
  String get servingDetailUseServingAction => 'Pakai takaran';

  @override
  String servingDetailWeightInvalid(String unit) {
    return 'Berat harus lebih dari 0 $unit. Catatan belum disimpan.';
  }

  @override
  String get quantityDecreaseSemantics => 'Kurangi jumlah';

  @override
  String get quantityIncreaseSemantics => 'Tambah jumlah';

  @override
  String get customFoodContextLabel => 'KATALOG PRIBADI';

  @override
  String get customFoodTitle => 'Buat makanan';

  @override
  String get customFoodSubtitle =>
      'Masukkan nilai dari sumber yang kamu percaya.';

  @override
  String get customFoodNameLabel => 'Nama makanan';

  @override
  String get customFoodNameHint => 'mis. Tumis buncis rumahan';

  @override
  String get customFoodServingLabel => 'Ukuran sajian';

  @override
  String get customFoodServingHint => 'mis. 1 porsi · 180 g';

  @override
  String get customFoodNutritionHeading => 'Nutrisi per sajian';

  @override
  String get customFoodNote =>
      'Periksa nilai dan satuannya. Angka yang belum diketahui jangan diisi nol.';

  @override
  String get customFoodSaveAction => 'Simpan makanan';

  @override
  String get customFoodNameRequiredError => 'Nama makanan tidak boleh kosong.';

  @override
  String get customFoodServingRequiredError =>
      'Ukuran sajian tidak boleh kosong.';

  @override
  String get customFoodNegativeValueError => 'Nilai gizi tidak boleh negatif.';

  @override
  String get barcodeScanContextLabel => 'PRODUK KEMASAN';

  @override
  String get barcodeScanTitle => 'Pindai barcode';

  @override
  String get barcodeScanSubtitle => 'Arahkan kode pada kemasan ke bingkai.';

  @override
  String get barcodeScanHint => 'Posisikan barcode di tengah';

  @override
  String get barcodeScanNoteTitle => 'Produk tersimpan bisa dicari offline';

  @override
  String get barcodeScanNoteBody => 'Barcode bukan sumber nilai nutrisi.';

  @override
  String get barcodeScanAlternativesHeading => 'Tidak bisa memindai?';

  @override
  String get barcodeScanManualLink => 'Masukkan barcode manual';

  @override
  String get barcodeScanManualDescription =>
      'Ketik nomor yang tertera di kemasan';

  @override
  String get barcodeScanPhotoLabelLink => 'Foto Info Gizi';

  @override
  String get barcodeScanPhotoLabelDescription =>
      'Baca nilai nutrisi dari foto label';

  @override
  String get barcodeScanUseCamera => 'Gunakan kamera';

  @override
  String get barcodeScanSlowHint =>
      'Kode belum terbaca? Ketik nomor secara manual.';

  @override
  String get barcodeScanPermissionDeniedTitle => 'Izin kamera ditolak';

  @override
  String get barcodeScanPermissionDeniedBody =>
      'Mealora memakai kamera hanya untuk memindai barcode kemasan. Kamu tetap bisa mencatat produk tanpa kamera.';

  @override
  String get barcodeScanUnavailableTitle => 'Pemindaian tidak tersedia';

  @override
  String get barcodeScanUnavailableBody =>
      'Lingkungan ini tidak mendukung kamera. Masukkan nomor barcode secara manual, atau cari di katalog.';

  @override
  String get barcodeScanManualAction => 'Masukkan nomor manual';

  @override
  String get barcodeScanSearchCatalogAction => 'Cari di katalog';

  @override
  String get barcodeScanLookupInProgress => 'Mencari produk…';

  @override
  String get barcodeManualContextLabel => 'MASUKKAN MANUAL';

  @override
  String get barcodeManualTitle => 'Masukkan nomor barcode';

  @override
  String get barcodeManualSubtitle => 'Ketik nomor yang tertera di kemasan.';

  @override
  String get barcodeManualFieldLabel => 'NOMOR BARCODE';

  @override
  String get barcodeManualFieldHint => 'mis. 8991234567890';

  @override
  String get barcodeManualHelper => '8–14 digit, sesuai EAN/UPC pada kemasan';

  @override
  String get barcodeManualInvalidError =>
      'Nomor harus 8–14 digit angka — periksa kembali kemasan.';

  @override
  String get barcodeManualNoteTitle =>
      'Tersedia tanpa kamera dan tanpa koneksi';

  @override
  String get barcodeManualNoteBody =>
      'Pencarian produk tersimpan tetap bekerja di mode pesawat.';

  @override
  String get barcodeManualSearchAction => 'Cari produk';

  @override
  String get packagedFoodNotFoundContextLabel => 'HASIL PEMINDAIAN';

  @override
  String get packagedFoodNotFoundTitle => 'Produk belum ditemukan';

  @override
  String packagedFoodNotFoundSubtitle(String barcode) {
    return 'Barcode: $barcode';
  }

  @override
  String get packagedFoodNotFoundHeading => 'Belum ada di katalog lokal';

  @override
  String get packagedFoodNotFoundBody =>
      'Kamu tetap bisa mencatatnya. Foto label gizi untuk mengekstrak data, atau isi nilai dari kemasan secara manual.';

  @override
  String get packagedFoodNotFoundManualTitle => 'Isi nilai secara manual';

  @override
  String get packagedFoodNotFoundManualDescription =>
      'Tersedia sepenuhnya offline';

  @override
  String get packagedFoodNotFoundPhotoTitle => 'Foto label gizi';

  @override
  String get packagedFoodNotFoundPhotoDescription =>
      'Butuh internet dan izin unggah';

  @override
  String get packagedFoodFillContextLabel => 'TANPA INTERNET';

  @override
  String get packagedFoodFillTitle => 'Isi label secara manual';

  @override
  String get packagedFoodFillSubtitle =>
      'Salin nilai dari kemasan, lalu periksa satuan.';

  @override
  String get packagedFoodFillBasisLabel => 'DASAR NILAI PADA KEMASAN';

  @override
  String get packagedFoodFillBasisPerServing => 'Per sajian';

  @override
  String get packagedFoodFillBasisPer100g => 'Per 100 g';

  @override
  String get packagedFoodFillNameLabel => 'Nama produk';

  @override
  String get packagedFoodFillNameHint => 'mis. Keripik Singkong Renyah';

  @override
  String get packagedFoodFillBrandLabel => 'Merek (opsional)';

  @override
  String get packagedFoodFillBrandHint => 'mis. MerekA';

  @override
  String get packagedFoodFillPackageSizeLabel => 'Ukuran kemasan (opsional)';

  @override
  String get packagedFoodFillPackageSizeHint => 'mis. 60 g';

  @override
  String get packagedFoodFillUnitsPerPackageLabel =>
      'Sajian per kemasan (opsional)';

  @override
  String get packagedFoodFillUnitsPerPackageHint => 'mis. 2';

  @override
  String get packagedFoodFillContinueAction => 'Tinjau sebelum mencatat';

  @override
  String get packagedFoodFillNameRequiredError =>
      'Nama produk tidak boleh kosong.';

  @override
  String get packagedFoodFillInvalidNumberError => 'Bukan angka yang sah.';

  @override
  String get packagedFoodReviewContextLabel => 'TINJAU PRODUK';

  @override
  String get packagedFoodReviewTitle => 'Tinjau produk';

  @override
  String get packagedFoodReviewSubtitle =>
      'Cocokkan dengan kemasan di tanganmu';

  @override
  String get packagedFoodReviewSourceOpenFoodFacts =>
      'Open Food Facts · barcode';

  @override
  String get packagedFoodReviewSourceManual => 'Diisi manual';

  @override
  String get packagedFoodReviewNutritionHeadingPerServing =>
      'Nutrisi per 1 sajian';

  @override
  String get packagedFoodReviewNutritionHeadingPer100g => 'Nutrisi per 100 g';

  @override
  String packagedFoodReviewServingsOption(String count) {
    return '$count sajian';
  }

  @override
  String packagedFoodReviewWholePackageOption(String units) {
    return '1 kemasan · $units sajian';
  }

  @override
  String get packagedFoodReviewGramsLabel => 'Gram yang dimakan';

  @override
  String get packagedFoodReviewQuantityHeading => 'Jumlah yang dimakan';

  @override
  String get packagedFoodReviewCorrectionLink =>
      'Beda dengan kemasanmu?  Koreksi nilai';

  @override
  String get packagedFoodReviewCorrectedBadge => 'Dikoreksi';

  @override
  String packagedFoodReviewVerifiedOn(String date) {
    return 'Diverifikasi $date';
  }

  @override
  String packagedFoodReviewConfirmAction(String kcal) {
    return 'Catat · $kcal';
  }

  @override
  String get diaryEyebrowToday => 'HARI INI';

  @override
  String get diaryTitle => 'Buku harian';

  @override
  String get diaryLocalNote => 'catatan di perangkat';

  @override
  String get diaryRecordedTodayLabel => 'TERCATAT HARI INI';

  @override
  String diaryTargetLabel(String kcal) {
    return 'Target perkiraan $kcal kkal';
  }

  @override
  String get diaryTargetPercentCaption => 'target';

  @override
  String get diaryPreviousDaySemantics => 'Hari sebelumnya';

  @override
  String get diaryNextDaySemantics => 'Hari berikutnya';

  @override
  String get diaryUnknownHeading => 'Belum tercatat';

  @override
  String get diaryUnknownBody =>
      'Kalori dan makro ditampilkan sebagai \"belum diketahui\", bukan 0 kkal atau target yang gagal.';

  @override
  String get diaryUnknownConsumptionLabel => 'Konsumsi';

  @override
  String get diaryUnknownConsumptionValue => 'Belum diketahui';

  @override
  String get diaryUnknownMacrosNote =>
      'Protein, karbo, lemak · belum diketahui';

  @override
  String diaryEntryMenuSemantics(String food) {
    return 'Opsi catatan $food';
  }

  @override
  String editEntryContextFormat(String mealTime, String date) {
    return '$mealTime · $date';
  }

  @override
  String get editEntryTitle => 'Ubah catatan';

  @override
  String get editEntrySubtitle => 'Perubahan hanya berlaku untuk catatan ini.';

  @override
  String editEntrySnapshotDetail(String serving) {
    return 'Sajian saat dicatat · $serving';
  }

  @override
  String get editEntryQuantityLabel => 'Jumlah yang dimakan';

  @override
  String get editEntryUpdatedEstimateLabel => 'Perkiraan setelah diubah';

  @override
  String get editEntryDeleteAction => 'Hapus catatan ini';

  @override
  String get editEntrySaveAction => 'Simpan perubahan';

  @override
  String get editEntryDeleteConfirmTitle => 'Hapus catatan ini?';

  @override
  String get editEntryDeleteConfirmBody =>
      'Catatan ini akan hilang dari buku harian dan ringkasan harian akan menyesuaikan.';

  @override
  String get editEntryDeleteConfirmAction => 'Hapus';

  @override
  String get editEntryDeleteCancelAction => 'Batal';

  @override
  String get weightAddTitle => 'Tambah berat';

  @override
  String get weightEditTitle => 'Ubah catatan berat';

  @override
  String get weightAddSubtitle => 'Catat kapan pun, berat selalu terpantau.';

  @override
  String get weightValueLabel => 'Berat badan';

  @override
  String get weightUnitKg => 'kg';

  @override
  String get weightDateLabel => 'Tanggal catatan';

  @override
  String get weightDateHint => 'Pilih tanggal';

  @override
  String get weightNoteLabel => 'Catatan (opsional)';

  @override
  String get weightNoteHint => 'Mis. setelah bangun pagi';

  @override
  String get weightLocalOnlyNote =>
      'Catatan berat hanya tersimpan di perangkat ini.';

  @override
  String get weightSaveAction => 'Simpan berat';

  @override
  String get weightInvalidNumberError => 'Masukkan angka berat yang sah.';

  @override
  String get weightOutOfRangeError =>
      'Berat ini di luar rentang yang masuk akal.';

  @override
  String get weightFutureDateError =>
      'Tanggal catatan tidak boleh di masa depan.';

  @override
  String get weightMonitorTitle => 'Catatan berat';

  @override
  String get weightMonitorSubtitle =>
      'Lihat arah perubahan, bukan nilai mutlak.';

  @override
  String get weightMonitorEyebrow => 'CATAT BERAT';

  @override
  String weightLatestLabel(String date) {
    return 'TERBARU · $date';
  }

  @override
  String weightLatestSemantics(String weight, String date) {
    return 'Berat terbaru $weight kilogram, tercatat $date';
  }

  @override
  String weightVsProgramStart(String weight, String direction, String delta) {
    return 'Awal program $weight kg · $direction $delta kg';
  }

  @override
  String get weightDirectionDown => 'penurunan';

  @override
  String get weightDirectionUp => 'kenaikan';

  @override
  String get weightDirectionFlat => 'tidak berubah';

  @override
  String get weightTrendHeading => 'Tren berat';

  @override
  String get weightTrendSubheading => '7 catatan terakhir';

  @override
  String get weightTrendSingleRecordNote =>
      'Baru satu catatan — tren belum dapat ditampilkan.';

  @override
  String get weightTrendEmptySlotSemantics => 'Belum ada catatan';

  @override
  String get weightRecentRecordsHeading => 'Catatan terakhir';

  @override
  String get weightEmptyTitle => 'Belum ada catatan berat';

  @override
  String get weightEmptyBody =>
      'Catat berat badanmu kapan saja. Hanya tersimpan di perangkat ini.';

  @override
  String get weightEmptyAction => 'Tambah berat';

  @override
  String get weightAddActionSemantics => 'Tambah catatan berat';

  @override
  String weightEntrySemantics(String date, String time, String weight) {
    return '$date pukul $time, $weight kilogram';
  }

  @override
  String get weightEditEntryAction => 'Sunting';

  @override
  String get weightDeleteEntryAction => 'Hapus';

  @override
  String get weightDeleteConfirmTitle => 'Hapus catatan berat ini?';

  @override
  String get weightDeleteConfirmBody =>
      'Catatan ini akan hilang dari tren dan daftar catatan terakhir.';

  @override
  String get weightDeleteConfirmAction => 'Hapus';

  @override
  String get weightDeleteCancelAction => 'Batal';

  @override
  String get labelExtractionUnavailableTitle =>
      'Pembacaan otomatis belum bisa dilakukan';

  @override
  String get labelExtractionReasonOffline =>
      'Tidak ada koneksi internet saat ini.';

  @override
  String get labelExtractionReasonTimeout =>
      'Layanan pembacaan tidak merespons.';

  @override
  String get labelExtractionReasonQuotaExceeded =>
      'Layanan pembacaan sedang tidak tersedia.';

  @override
  String get labelExtractionReasonRefused =>
      'Layanan tidak bisa membaca foto ini.';

  @override
  String get labelExtractionDraftPreservedNote =>
      'Foto dan nilai yang sudah kamu isi tetap tersimpan.';

  @override
  String get privacySettingsContextLabel => 'PRIVASI';

  @override
  String get privacySettingsTitle => 'Privasi & data lokal';

  @override
  String get privacySettingsSubtitle =>
      'Atur bagaimana foto label diperlakukan saat Mealora membacanya.';

  @override
  String get privacySettingsUploadHeading => 'Izin unggah foto label';

  @override
  String get privacySettingsUploadAskEachTimeTitle => 'Tanya setiap kali';

  @override
  String get privacySettingsUploadAskEachTimeDetail =>
      'Mealora meminta persetujuan setiap kali akan mengirim foto.';

  @override
  String get privacySettingsUploadAlwaysAllowTitle => 'Selalu izinkan';

  @override
  String get privacySettingsUploadAlwaysAllowDetail =>
      'Foto langsung dikirim tanpa ditanya lagi setiap kali.';

  @override
  String get privacySettingsRetentionHeading => 'Foto sumber setelah dicatat';

  @override
  String get privacySettingsRetentionDeleteTitle => 'Hapus setelah dicatat';

  @override
  String get privacySettingsRetentionDeleteDetail =>
      'Foto dihapus dari perangkat begitu catatan dibuat.';

  @override
  String get privacySettingsRetentionKeepTitle => 'Simpan di perangkat';

  @override
  String get privacySettingsRetentionKeepDetail =>
      'Foto tetap tersimpan di perangkat ini agar bisa diperiksa lagi.';

  @override
  String get privacySettingsNote =>
      'Foto hanya dikirim ke layanan pembacaan label saat kamu setuju, dan tidak pernah disimpan di luar perangkat ini.';

  @override
  String get displaySettingsContextLabel => 'PROFIL';

  @override
  String get displaySettingsTitle => 'Bahasa & tampilan';

  @override
  String get displaySettingsSubtitle => 'Atur bahasa aplikasi dan awal minggu.';

  @override
  String get displaySettingsLanguageHeading => 'Bahasa';

  @override
  String get displaySettingsLanguageIndonesian => 'Bahasa Indonesia';

  @override
  String get displaySettingsLanguageCurrent => 'Dipakai sekarang';

  @override
  String get displaySettingsLanguageEnglish => 'English';

  @override
  String get displaySettingsLanguageComingSoon => 'Segera hadir';

  @override
  String get displaySettingsLanguageComingSoonChip => 'Segera';

  @override
  String get displaySettingsCalendarHeading => 'Kalender';

  @override
  String get displaySettingsWeekStartLabel => 'Awal minggu';

  @override
  String get displaySettingsWeekStartDetail => 'untuk ringkasan mingguan';

  @override
  String get displaySettingsWeekStartMonday => 'Senin';

  @override
  String get displaySettingsWeekStartSunday => 'Minggu';

  @override
  String get displaySettingsNote =>
      'Awal minggu mengatur ringkasan mingguan di Riwayat dan Program. Catatan lamamu tetap utuh.';

  @override
  String get aboutContextLabel => 'PROFIL';

  @override
  String get aboutTitle => 'Tentang Mealora';

  @override
  String get aboutSubtitle => 'Versi aplikasi dan informasi penting.';

  @override
  String get aboutAppName => 'Mealora';

  @override
  String aboutVersion(String version, String build) {
    return 'Versi $version · build $build';
  }

  @override
  String get aboutLicensesAction => 'Lisensi sumber terbuka';

  @override
  String get aboutDisclaimer =>
      'Mealora membantu mencatat makan dan memperkirakan gizi. Angkanya perkiraan, bukan nasihat kesehatan. Untuk kebutuhan khusus, bicarakan dengan tenaga kesehatan.';

  @override
  String aboutFooter(String year) {
    return 'Dibuat di Indonesia · © $year Mealora';
  }

  @override
  String get uploadConsentBody =>
      'Ekstraksi memerlukan internet. Kamu tetap dapat mengetik nilainya sendiri saat offline.';

  @override
  String get uploadConsentCheckboxLabel => 'Izinkan unggah foto label ini';

  @override
  String get uploadConsentCheckedState => 'Dicentang';

  @override
  String get uploadConsentUncheckedState => 'Belum dicentang';

  @override
  String get labelPhotoContextLabel => 'INFORMASI NILAI GIZI';

  @override
  String get labelPhotoTitle => 'Foto label kemasan';

  @override
  String get labelPhotoSubtitle => 'Pastikan teks dan satuan terlihat jelas.';

  @override
  String get labelPhotoFrameCaption =>
      'Informasi Nilai Gizi harus terbaca penuh';

  @override
  String get labelPhotoExtractAction => 'Ekstrak untuk ditinjau';

  @override
  String get labelPhotoRetryAction => 'Coba lagi dengan foto ini';

  @override
  String get labelPhotoManualLink => 'Isi label secara manual tanpa unggah';

  @override
  String get labelPhotoPermissionDeniedTitle => 'Kamera tidak dapat diakses';

  @override
  String get labelPhotoPermissionDeniedBody =>
      'Izin kamera ditolak atau tidak tersedia. Kamu tetap bisa mengisi nilai label secara manual.';

  @override
  String get labelReviewContextLabel => 'TINJAU HASIL BACAAN';

  @override
  String get labelReviewTitle => 'Periksa nilai yang terbaca';

  @override
  String get labelReviewSubtitle =>
      'Ini bacaan yang perlu diperiksa, bukan data terverifikasi. Bandingkan dengan fotonya.';

  @override
  String get labelReviewNameLabel => 'NAMA PRODUK';

  @override
  String get labelReviewNameHint => 'mis. Keripik Singkong Renyah';

  @override
  String get labelReviewBasisLabel => 'DASAR NILAI PADA KEMASAN';

  @override
  String get labelReviewBasisUnreadNote =>
      'Basis tidak terbaca dari foto — pilih sendiri sebelum lanjut.';

  @override
  String labelReviewPackageArithmeticNote(
    String multiplier,
    String servingSize,
  ) {
    return '1 kemasan = $multiplier× nilai per sajian ($servingSize).';
  }

  @override
  String get labelReviewConfidenceConfident => 'Terbaca yakin';

  @override
  String get labelReviewConfidenceNeedsCheck => 'Perlu diperiksa';

  @override
  String get labelReviewConfidenceUnread => 'Tidak terbaca';

  @override
  String get labelReviewMarkAbsentAction => 'Tidak tercantum di kemasan';

  @override
  String get labelReviewValueMarkedAbsent =>
      'Ditandai tidak tercantum di kemasan';

  @override
  String labelReviewPendingValuesNote(String fields) {
    return 'Lengkapi dulu: $fields.';
  }

  @override
  String get labelReviewConfirmAction => 'Konfirmasi nilai';

  @override
  String get labelReviewCancelAction => 'Batal';

  @override
  String get labelReviewCancelConfirmTitle => 'Batalkan peninjauan ini?';

  @override
  String get labelReviewCancelConfirmBody =>
      'Foto dan nilai yang sudah dibaca tidak akan disimpan sebagai produk.';

  @override
  String get labelReviewCancelConfirmAction => 'Ya, batalkan';

  @override
  String get labelReviewCancelKeepReviewingAction => 'Lanjutkan meninjau';

  @override
  String get foodPhotoContextLabel => 'FOTO MAKANAN';

  @override
  String get foodPhotoTitle => 'Ambil foto makanan';

  @override
  String get foodPhotoSubtitle => 'Saran dari foto selalu perlu diperiksa.';

  @override
  String get foodPhotoFrameCaption => 'Arahkan ke piringmu';

  @override
  String get foodPhotoConsentHeading => 'Sebelum dianalisis';

  @override
  String get foodPhotoConsentBody =>
      'Analisis AI memerlukan internet. Foto hanya diunggah jika kamu mengizinkan. Catatan tetap tersimpan lokal.';

  @override
  String get foodPhotoConsentCheckboxLabel => 'Saya izinkan unggah foto ini';

  @override
  String get foodPhotoCaptureAction => 'Ambil foto & lanjutkan';

  @override
  String get foodPhotoManualLink =>
      'Tanpa internet? Pilih makanan secara manual';

  @override
  String get foodPhotoPermissionDeniedTitle => 'Kamera tidak dapat diakses';

  @override
  String get foodPhotoPermissionDeniedBody =>
      'Izin kamera ditolak atau tidak tersedia. Kamu tetap bisa memilih makanan secara manual.';

  @override
  String get foodPhotoDraftContextLabel => 'FOTO MAKANAN';

  @override
  String get foodPhotoDraftSavedTitle => 'Foto tersimpan sebagai draf';

  @override
  String get foodPhotoDraftSavedBody => 'Belum ada catatan makan yang dibuat.';

  @override
  String get foodPhotoDraftBadge => 'Draf foto · tersimpan di perangkat';

  @override
  String get foodPhotoDraftUnavailableTitle => 'Analisis foto belum tersedia';

  @override
  String get foodPhotoDraftUnavailableBody =>
      'Koneksi atau kuota layanan bermasalah. Draf fotomu tidak hilang.';

  @override
  String get foodPhotoDraftManualHeading => 'Lanjut tanpa AI';

  @override
  String get foodPhotoDraftManualDescription =>
      'Cari makanan di katalog, tambah bahan, lalu atur porsinya sendiri.';

  @override
  String get foodPhotoDraftManualAction => 'Pilih makanan manual';

  @override
  String get foodPhotoReviewContextLabel => 'TINJAU FOTO MAKANAN';

  @override
  String get foodPhotoReviewBadge => 'Saran foto · porsi perlu dicek';

  @override
  String get foodPhotoReviewBadgeNote =>
      'Nutrisi dari padanan katalog; periksa bahan.';

  @override
  String get foodPhotoReviewTitle => 'Tinjau foto makanan';

  @override
  String get foodPhotoReviewSubtitle => 'Periksa perkiraan sebelum dicatat';

  @override
  String get foodPhotoReviewEmptyTitle => 'Isi piringmu';

  @override
  String foodPhotoReviewComponentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bahan',
      one: '1 bahan',
      zero: 'Tidak ada bahan',
    );
    return '$_temp0';
  }

  @override
  String get foodPhotoReviewEditAction => 'Ubah';

  @override
  String get foodPhotoReviewNoMatchLabel =>
      'Belum ada padanan — pilih atau buat makanan';

  @override
  String foodPhotoReviewTotalSummary(
    String kcal,
    String protein,
    String carbohydrate,
    String fat,
  ) {
    return '· $kcal kkal  ·  P $protein g  ·  K $carbohydrate g  ·  L $fat g';
  }

  @override
  String get foodPhotoReviewConfirmAction => 'Konfirmasi & catat';

  @override
  String get foodPhotoReviewCancelConfirmTitle => 'Batalkan peninjauan ini?';

  @override
  String get foodPhotoReviewCancelConfirmBody =>
      'Belum ada catatan yang dibuat. Draf fotonya akan dibuang sesuai pengaturan privasi.';

  @override
  String get foodPhotoReviewCancelConfirmAction => 'Ya, batalkan';

  @override
  String get foodPhotoReviewCancelKeepReviewingAction => 'Lanjutkan meninjau';

  @override
  String get foodComponentCorrectionBadge => 'DRAF FOTO MAKANAN';

  @override
  String get foodComponentCorrectionTitle => 'Ubah komponen';

  @override
  String get foodComponentCorrectionSubtitle =>
      'Setiap bahan dan porsi bisa kamu koreksi.';

  @override
  String get foodComponentCorrectionHeading => 'Bahan yang dikenali';

  @override
  String get foodComponentCorrectionRemoveAction => 'Hapus bahan';

  @override
  String get foodComponentCorrectionAddAction =>
      'Tambah bahan, minyak, atau saus';

  @override
  String get foodComponentCorrectionConfirmAction => 'Tinjau total baru';

  @override
  String get foodComponentMatchOk => 'cocok dengan katalog';

  @override
  String get foodComponentMatchMissing => 'belum ada padanan';

  @override
  String get foodComponentPortionNeedsCheck => 'porsi perlu dicek';

  @override
  String get foodComponentCookingMethodNeedsCheck => 'metode masak perlu dicek';

  @override
  String get foodComponentEditorFoodLabel => 'MAKANAN';

  @override
  String get foodComponentEditorFoodChangeAction => 'Ganti makanan';

  @override
  String get foodComponentEditorQuantityLabel => 'JUMLAH TAKARAN';

  @override
  String get foodComponentEditorServingLabel => 'TAKARAN';

  @override
  String get foodComponentEditorCookingMethodLabel => 'METODE MASAK (OPSIONAL)';

  @override
  String get foodComponentEditorCookingMethodHint =>
      'mis. digoreng, dikukus, dibakar';

  @override
  String get foodComponentEditorSaveAction => 'Simpan';

  @override
  String get foodComponentPickerTitle => 'Pilih makanan';

  @override
  String get foodComponentPickerHint => 'Cari di katalog';

  @override
  String get foodComponentPickerCreateLink => 'Buat makanan baru';

  @override
  String get foodComponentPickerNoResultsTitle => 'Tidak ditemukan';

  @override
  String get foodComponentPickerNoResultsBody =>
      'Coba kata kunci lain, atau buat makanan baru.';

  @override
  String get todayPendingDraftTitle => 'Draf foto makanan menunggu';

  @override
  String get todayPendingDraftBody =>
      'Belum ada catatan yang dibuat. Ketuk untuk melanjutkan peninjauan.';

  @override
  String get todayPendingDraftSemantics =>
      'Draf foto makanan menunggu. Belum ada catatan yang dibuat. Ketuk untuk melanjutkan peninjauan.';

  @override
  String get voiceRecordContextLabel => 'CATAT DENGAN SUARA';

  @override
  String get voiceRecordTitle => 'Sebutkan makananmu';

  @override
  String get voiceRecordSubtitle =>
      'Satu kalimat cukup. Hasilnya kamu periksa dulu sebelum dicatat.';

  @override
  String get voiceRecordExampleTitle => 'Contoh ucapan';

  @override
  String get voiceRecordExampleQuote =>
      '“Tadi makan nasi 150 gram, ayam bakar satu potong, sama tempe dua.”';

  @override
  String get voiceRecordExampleHint =>
      'Sebut jumlahnya kalau ingat. Kalau tidak, nanti kamu isi sendiri.';

  @override
  String get voiceRecordMicHint => 'Ketuk untuk mulai bicara';

  @override
  String get voiceScopeTitle => 'Suara hanya untuk mencatat makanan';

  @override
  String get voiceScopeBody =>
      'Berat badan, program, dan pengaturan tetap diisi seperti biasa. Rekaman dihapus setelah jadi teks.';

  @override
  String get voiceTypeInsteadLink => 'Tidak bisa bicara? Ketik kalimatnya saja';

  @override
  String get voiceRecordStartAction => 'Mulai merekam';

  @override
  String get voicePermissionExplanation =>
      'Mealora meminta izin mikrofon hanya untuk mengubah ucapanmu menjadi teks di perangkat ini.';

  @override
  String get voicePreparing => 'Menyiapkan mikrofon…';

  @override
  String get voiceListeningContextLabel => 'SEDANG MEREKAM';

  @override
  String get voiceListeningTitle => 'Mendengarkan…';

  @override
  String get voiceListeningSubtitle =>
      'Selesai bicara? Ketuk Selesai. Kamu tetap bisa membatalkan.';

  @override
  String voiceListeningBadge(String elapsed) {
    return 'Merekam · $elapsed';
  }

  @override
  String get voiceListeningMicActive => 'Mikrofon aktif';

  @override
  String get voiceListeningSemantics =>
      'Sedang merekam, mikrofon aktif. Ketuk Selesai untuk berhenti.';

  @override
  String get voiceListeningPartialLabel => 'TERDENGAR SEJAUH INI';

  @override
  String get voiceListeningPartialHint =>
      'Teks masih sementara dan bisa kamu perbaiki nanti.';

  @override
  String get voiceOnDeviceTitle => 'Suara diproses di perangkat ini';

  @override
  String get voiceOnDeviceBody => 'Rekamanmu tidak diunggah ke mana pun.';

  @override
  String get voiceCancelAction => 'Batalkan — tidak ada yang dicatat';

  @override
  String get voiceStopAction => 'Selesai';

  @override
  String get voiceEmptyTitle => 'Belum ada yang terdengar';

  @override
  String get voiceEmptyBody =>
      'Tidak ada yang dicatat. Coba rekam ulang, atau ketik kalimatnya.';

  @override
  String get voiceFailedTitle => 'Pengenalan suara terhenti';

  @override
  String get voiceFailedBody =>
      'Tidak ada yang dicatat. Coba rekam ulang, atau ketik kalimatnya.';

  @override
  String get voiceReviewContextLabel => 'PERIKSA TEKS';

  @override
  String get voiceReviewTitle => 'Sudah benar?';

  @override
  String get voiceReviewSubtitle =>
      'Hasil pengenalan bisa keliru. Perbaiki dulu sebelum diurai.';

  @override
  String get voiceReviewFieldLabel => 'TEKS YANG TERDENGAR';

  @override
  String get voiceReviewFieldHint => 'Ketuk untuk memperbaiki kata yang salah';

  @override
  String get voiceRecordingDeletedTitle => 'Rekaman suara sudah dihapus';

  @override
  String get voiceRecordingDeletedBody => 'Yang tersisa hanya teks di atas.';

  @override
  String get voiceParseNeedsInternetTitle => 'Mengurai butuh internet';

  @override
  String get voiceParseNeedsInternetBody =>
      'Yang dikirim hanya teks ini, bukan rekaman suaramu. Tanpa internet, cari di katalog.';

  @override
  String get voiceRerecordAction => 'Rekam ulang';

  @override
  String get voiceCatalogLink => 'Tanpa internet? Cari di katalog';

  @override
  String get voiceParseAction => 'Urai jadi daftar makanan';

  @override
  String get voiceUnavailableContextLabel => 'SUARA TIDAK TERSEDIA';

  @override
  String get voiceUnavailableTitle => 'Mikrofon belum aktif';

  @override
  String get voiceUnavailableSubtitle =>
      'Kamu tetap bisa mencatat dengan mengetik kalimatnya.';

  @override
  String get voicePermissionDeniedTitle => 'Izin mikrofon belum diberikan';

  @override
  String get voicePermissionDeniedBody =>
      'Kamu bisa memberi izin lewat pengaturan perangkat, atau ketik kalimatnya di bawah.';

  @override
  String get voiceNotSupportedTitle => 'Pengenalan suara belum didukung';

  @override
  String get voiceNotSupportedBody =>
      'Perangkat ini belum mendukung pengenalan suara bahasa Indonesia di perangkat. Rekaman tidak dikirim ke mana pun.';

  @override
  String get voiceTypeFieldLabel => 'Ketik kalimatnya';

  @override
  String get voiceTypeFieldHint =>
      'nasi 150 gram, ayam bakar satu potong, tempe dua';

  @override
  String get voiceTypeFieldHelper => 'Sebut jumlahnya bila ingat';

  @override
  String get voiceTypeScopeTitle => 'Hanya untuk mencatat makanan';

  @override
  String get voiceTypeScopeBody =>
      'Kalimat di luar makanan tidak dijalankan. Berat badan dan program tetap diisi di layarnya sendiri.';

  @override
  String get voiceTypeContextLabel => 'KETIK KALIMAT';

  @override
  String get voiceTypeTitle => 'Tulis yang kamu makan';

  @override
  String get voiceTypeSubtitle =>
      'Satu kalimat cukup. Hasilnya kamu periksa dulu sebelum dicatat.';

  @override
  String get voiceParseTypedAction => 'Urai kalimat ini';

  @override
  String get voiceParsingInProgress => 'Mengurai kalimat…';

  @override
  String get voiceParseUnavailableTitle => 'Kalimat belum bisa diurai';

  @override
  String get voiceParseUnavailableOffline =>
      'Tidak ada koneksi. Teksmu tetap di sini — coba lagi nanti, atau cari di katalog.';

  @override
  String get voiceParseUnavailableTimeout =>
      'Penguraian terlalu lama. Teksmu tetap di sini — coba lagi, atau cari di katalog.';

  @override
  String get voiceParseUnavailableQuota =>
      'Layanan penguraian sedang penuh. Teksmu tetap di sini — coba lagi nanti, atau cari di katalog.';

  @override
  String get voiceParseUnavailableRefused =>
      'Layanan penguraian sedang tidak tersedia. Teksmu tetap di sini — coba lagi nanti, atau cari di katalog.';

  @override
  String get voiceParsedIgnoredPartShort =>
      'Bagian di luar makanan diabaikan, tidak dijalankan.';

  @override
  String get voiceScopeRejectedTitle => 'Suara hanya untuk mencatat makanan';

  @override
  String voiceScopeRejectedBody(String where) {
    return 'Tidak ada yang dijalankan atau diubah. $where';
  }

  @override
  String get voiceScopeWhereWeight => 'Berat badan dicatat di ruang Program.';

  @override
  String get voiceScopeWhereProgram => 'Program diatur di ruang Program.';

  @override
  String get voiceScopeWhereProfile =>
      'Profil dan pengaturan ada di ruang Profil.';

  @override
  String get voiceScopeWhereDiary =>
      'Catatan makan diubah atau dihapus dari Hari ini atau Riwayat.';

  @override
  String get voiceScopeWhereToday => 'Ringkasan kalori ada di Hari ini.';

  @override
  String get voiceScopeWhereOther =>
      'Kalimat itu tidak bisa dijalankan dari sini.';

  @override
  String get voiceReviewComponentsContextLabel => 'TINJAU HASIL SUARA';

  @override
  String get voiceReviewComponentsTitle => 'Tinjau daftar makanan';

  @override
  String get voiceReviewBadge => 'Perkiraan dari kalimat · periksa dulu';

  @override
  String get voiceReviewBadgeNote =>
      'Nilai gizi dari padanan katalog. Tetapkan jumlah yang belum ditentukan sebelum dicatat.';

  @override
  String get voiceReviewOnDeviceBadge =>
      'Diurai tanpa koneksi · periksa lebih teliti';

  @override
  String get voiceReviewOnDeviceBadgeNote =>
      'Kalimat diurai di perangkat ini dengan aturan sederhana. Periksa setiap makanan dan jumlahnya.';

  @override
  String get voiceReviewCancelConfirmBody =>
      'Belum ada catatan yang dibuat. Daftar dari kalimat ini akan dibuang.';

  @override
  String get voiceComponentCorrectionBadge => 'DAFTAR DARI KALIMAT';

  @override
  String get voiceQuantityUndetermined => 'jumlah belum ditentukan';

  @override
  String voiceQuantityUndeterminedWithUnit(String unit) {
    return 'jumlah belum ditentukan · disebut \"$unit\"';
  }

  @override
  String get voiceParseNothingFoundTitle => 'Tidak ada makanan yang dikenali';

  @override
  String get voiceParseNothingFoundBody =>
      'Perbaiki kalimatnya, atau cari makanannya di katalog. Tidak ada yang dicatat.';

  @override
  String get profileRemindersAction => 'Pengingat';

  @override
  String get profileRemindersOff => 'Mati';

  @override
  String profileRemindersOnCount(int count) {
    return '$count menyala';
  }

  @override
  String get remindersContextLabel => 'PENGINGAT';

  @override
  String get remindersTitle => 'Pengingat';

  @override
  String get remindersSubtitle =>
      'Notifikasi muncul di HP ini saja. Waktunya bisa bergeser beberapa menit.';

  @override
  String get remindersMealsHeading => 'Jam makan';

  @override
  String get remindersBreakfast => 'Sarapan';

  @override
  String get remindersLunch => 'Makan siang';

  @override
  String get remindersSnack => 'Camilan';

  @override
  String get remindersDinner => 'Makan malam';

  @override
  String get remindersWeighHeading => 'Timbang berat';

  @override
  String get remindersWeighLabel => 'Timbang berat';

  @override
  String get remindersWeighDetail => 'Seminggu sekali';

  @override
  String get remindersWeighTimeLabel => 'Jam';

  @override
  String get remindersWeekdayShortMon => 'S';

  @override
  String get remindersWeekdayShortTue => 'S';

  @override
  String get remindersWeekdayShortWed => 'R';

  @override
  String get remindersWeekdayShortThu => 'K';

  @override
  String get remindersWeekdayShortFri => 'J';

  @override
  String get remindersWeekdayShortSat => 'S';

  @override
  String get remindersWeekdayShortSun => 'M';

  @override
  String get remindersWeekdayMon => 'Senin';

  @override
  String get remindersWeekdayTue => 'Selasa';

  @override
  String get remindersWeekdayWed => 'Rabu';

  @override
  String get remindersWeekdayThu => 'Kamis';

  @override
  String get remindersWeekdayFri => 'Jumat';

  @override
  String get remindersWeekdaySat => 'Sabtu';

  @override
  String get remindersWeekdaySun => 'Minggu';

  @override
  String get remindersBedtimeHeading => 'Jam tidur';

  @override
  String get remindersBedtimeLabel => 'Jam tidur';

  @override
  String get remindersBedtimeNote =>
      'Dipakai untuk mengingatkan saat kamu mencatat makan menjelang tidur.';

  @override
  String get remindersBlockedBody =>
      'Notifikasi diblokir. Pengingat tidak bisa muncul sampai kamu mengizinkannya.';

  @override
  String get remindersBlockedAction => 'Buka pengaturan';

  @override
  String remindersToggleSemantics(String name) {
    return 'Pengingat $name';
  }

  @override
  String remindersTimeSemantics(String name, String time) {
    return 'Ubah jam $name, sekarang $time';
  }

  @override
  String get remindersTimePickerTitle => 'Pilih jam';

  @override
  String remindersTimePickerDaily(String name) {
    return '$name · pengingat harian';
  }

  @override
  String get remindersTimePickerWeekly => 'Timbang berat · pengingat mingguan';

  @override
  String get remindersTimePickerBedtime =>
      'Jam tidur · untuk peringatan makan larut';

  @override
  String get remindersTimePickerNote =>
      'Waktu notifikasi bisa bergeser beberapa menit mengikuti penghematan baterai.';

  @override
  String get remindersTimePickerCancel => 'Batal';

  @override
  String get remindersTimePickerSave => 'Simpan';

  @override
  String get remindersPermissionTitle => 'Izinkan notifikasi?';

  @override
  String get remindersPermissionBody =>
      'Mealora butuh izin agar pengingat bisa muncul. Kamu bisa mematikannya kapan saja.';

  @override
  String get remindersPermissionLocalNote =>
      'Pengingat dibuat di HP ini. Tidak ada data yang dikirim.';

  @override
  String get remindersPermissionLater => 'Nanti';

  @override
  String get remindersPermissionContinue => 'Lanjut';

  @override
  String get reminderChannelName => 'Pengingat';

  @override
  String get reminderChannelDescription =>
      'Pengingat jam makan dan timbang berat';

  @override
  String get reminderBreakfastTitle => 'Waktunya sarapan';

  @override
  String get reminderBreakfastBody => 'Jangan lupa catat sarapanmu di Mealora.';

  @override
  String get reminderLunchTitle => 'Waktunya makan siang';

  @override
  String get reminderLunchBody => 'Jangan lupa catat makan siangmu di Mealora.';

  @override
  String get reminderSnackTitle => 'Waktunya camilan';

  @override
  String get reminderSnackBody => 'Jangan lupa catat camilanmu di Mealora.';

  @override
  String get reminderDinnerTitle => 'Waktunya makan malam';

  @override
  String get reminderDinnerBody =>
      'Jangan lupa catat makan malammu di Mealora.';

  @override
  String get reminderWeighTitle => 'Waktunya timbang';

  @override
  String get reminderWeighBody => 'Catat berat badanmu minggu ini.';

  @override
  String get lateMealNoticeTitle => 'Sudah dekat jam tidur.';

  @override
  String get lateMealNoticeBody =>
      'Makan berat menjelang tidur bisa membuat tidur kurang nyenyak. Pilih porsi ringan kalau masih lapar.';

  @override
  String get shareAction => 'Bagikan';

  @override
  String get sharePreviewTitle => 'Bagikan';

  @override
  String get sharePreviewCloseSemantics => 'Tutup';

  @override
  String get sharePreviewLocalNote =>
      'Gambar dibuat di HP kamu. Mealora tidak mengunggah apa pun.';

  @override
  String get shareFailedMessage => 'Kartu belum bisa dibagikan. Coba lagi.';

  @override
  String get shareSummarySemantics => 'Bagikan ringkasan hari ini';

  @override
  String get shareSummaryDisabledReason =>
      'Catat makanan dulu untuk membagikan ringkasan.';

  @override
  String get shareSummaryPreviewCaption =>
      'Ringkasan harian · kalori & makro hari ini';

  @override
  String get shareMealPreviewCaption =>
      'Kartu makanan · foto & estimasi kalori';

  @override
  String shareCardOfTarget(String target) {
    return 'dari $target kkal';
  }

  @override
  String shareCardPercentOfTarget(int percent) {
    return '$percent% dari target';
  }

  @override
  String shareCardMacroLine(String protein, String carbohydrate, String fat) {
    return 'Protein $protein g · Karbo $carbohydrate g · Lemak $fat g';
  }

  @override
  String shareCardMoreItems(int count) {
    return '+$count lainnya';
  }

  @override
  String get shareCardTotalLabel => 'Estimasi total kalori';

  @override
  String get foodPhotoSavedTitle => 'Tersimpan!';

  @override
  String foodPhotoSavedSubtitle(String mealTime, int count, String kcal) {
    return '$mealTime · $count item · $kcal kkal';
  }

  @override
  String get foodPhotoSavedThumbCaption =>
      'Pratinjau kartu yang akan dibagikan';

  @override
  String get foodPhotoSavedDoneAction => 'Selesai';

  @override
  String get customFoodEditTitle => 'Sunting makanan';

  @override
  String get customFoodEditContextLabel => 'SUNTING MAKANAN';

  @override
  String get customFoodEditAction => 'Sunting makanan';

  @override
  String get customFoodSaveChangesAction => 'Simpan perubahan';

  @override
  String get customFoodModeHeading => 'Cara mengisi gizi';

  @override
  String get customFoodModeManual => 'Isi manual';

  @override
  String get customFoodModeRecipe => 'Hitung dari bahan';

  @override
  String get customFoodManualHint =>
      'Tidak punya data gizinya? Pilih \"Hitung dari bahan\" — aplikasi menjumlahkan gizi dari bahan masakanmu.';

  @override
  String get foodFormReady => 'siap makan';

  @override
  String get foodFormRaw => 'mentah';

  @override
  String get foodFormDry => 'kering';

  @override
  String recipeIngredientsHeading(int count) {
    return 'Bahan ($count)';
  }

  @override
  String get recipeIngredientsEmpty =>
      'Belum ada bahan. Tambahkan bahan masakanmu satu per satu.';

  @override
  String get recipeAddIngredient => 'Tambah bahan';

  @override
  String recipeRemoveIngredient(String name) {
    return 'Hapus $name';
  }

  @override
  String get recipeIngredientNoData => 'tanpa data gizi';

  @override
  String recipeAmountGrams(String amount) {
    return '$amount g';
  }

  @override
  String recipeAmountServing(String amount, String serving) {
    return '$amount × $serving';
  }

  @override
  String get recipeYieldHeading => 'Hasil resep';

  @override
  String get recipeYieldServingsLabel => 'Jumlah porsi';

  @override
  String get recipeYieldGramsLabel => 'Berat jadi (g) · opsional';

  @override
  String get recipeYieldGramsHelper => 'Timbang setelah matang';

  @override
  String get recipeYieldServingsError => 'Jumlah porsi harus lebih dari 0.';

  @override
  String get recipeYieldGramsError =>
      'Berat jadi harus lebih dari 0 g, atau kosongkan.';

  @override
  String get recipeDecreaseServings => 'Kurangi porsi';

  @override
  String get recipeIncreaseServings => 'Tambah porsi';

  @override
  String get recipeOilReminder =>
      'Menggoreng? Tambahkan minyak yang terserap sebagai bahan agar energinya tidak terlalu rendah.';

  @override
  String get recipeNoIngredientsError =>
      'Tambahkan sekurang-kurangnya satu bahan.';

  @override
  String recipeIncompleteBanner(String names) {
    return 'Total belum lengkap: $names tidak punya sebagian data gizi, jadi totalnya bisa lebih tinggi.';
  }

  @override
  String get recipeIncompleteChip => 'tidak lengkap';

  @override
  String get recipeNutritionHeading => 'Nutrisi per sajian';

  @override
  String get recipeCorrectedNotice =>
      'Nilai dikoreksi manual, jadi hitungan dari bahan tidak lagi dipakai.';

  @override
  String get recipeRecalculateAction => 'Hitung ulang dari bahan';

  @override
  String get recipeRecalculateTitle => 'Hitung ulang dari bahan?';

  @override
  String get recipeRecalculateBody =>
      'Koreksimu akan ditimpa dengan hasil hitungan dari bahan saat ini.';

  @override
  String get recipeRecalculateConfirm => 'Hitung ulang';

  @override
  String get recipeRecalculateCancel => 'Biarkan koreksi';

  @override
  String get recipeBreakdownAction => 'Lihat rincian per bahan';

  @override
  String get recipeBreakdownTitle => 'Rincian gizi';

  @override
  String get recipeBreakdownSubtitle =>
      'Kontribusi tiap bahan terhadap total resep.';

  @override
  String get recipeBreakdownIngredientColumn => 'BAHAN';

  @override
  String get recipeBreakdownTotalRow => 'Total resep';

  @override
  String recipeBreakdownPerServing(String servings) {
    return 'Per sajian · 1 dari $servings porsi';
  }

  @override
  String recipeBreakdownPer100g(String grams, String kcal) {
    return 'Per 100 g hasil masakan ($grams g): $kcal kkal';
  }

  @override
  String get recipeBreakdownIncompleteMark =>
      '* belum termasuk bahan yang datanya tidak lengkap.';

  @override
  String get recipePickerTitle => 'Pilih bahan';

  @override
  String get recipePickerFallbackHeading => 'Tidak menemukan bahannya?';

  @override
  String get recipePickerCreateTitle => 'Buat bahan baru';

  @override
  String get recipePickerCreateBody =>
      'Isi gizi per 100 g dari label kemasan. Tersimpan dan bisa dipakai lagi.';

  @override
  String get recipePickerFreeTextTitle => 'Tambah tanpa data gizi';

  @override
  String get recipePickerFreeTextBody =>
      'Cukup nama dan jumlah. Total resep akan ditandai tidak lengkap.';

  @override
  String get recipePer100gHeading => 'Nilai gizi per 100 g';

  @override
  String get recipeFreeTextNameLabel => 'Nama bahan';

  @override
  String get recipeAmountModeGram => 'Gram';

  @override
  String recipeAmountModeServing(String serving) {
    return 'Takaran ($serving)';
  }

  @override
  String get recipeAmountModeMultiple => 'Jumlah (kali)';

  @override
  String get recipeAmountLabelGram => 'Berat (g)';

  @override
  String get recipeAmountLabelServing => 'Jumlah takaran';

  @override
  String get recipeAmountZeroError => 'Jumlah harus lebih dari 0.';

  @override
  String get recipeAmountGramRule =>
      'Gram hanya tersedia untuk bahan yang berat takarannya diketahui. Selain itu isi kelipatan takaran, mis. 0,5.';

  @override
  String get recipeAmountRawHint =>
      'Bentuk mentah — masukkan berat sebelum dimasak.';

  @override
  String get recipeAmountAddAction => 'Tambah ke resep';
}
