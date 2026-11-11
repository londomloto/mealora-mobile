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
  String get profileUnitsLanguageAction => 'Satuan & bahasa';

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
  String get barcodeScanManualLink => 'Masukkan nomor barcode secara manual';

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
      'Kamu tetap bisa mencatatnya. Isi nilai dari kemasan secara manual, atau foto label gizi.';

  @override
  String get packagedFoodNotFoundManualTitle => 'Isi nilai secara manual';

  @override
  String get packagedFoodNotFoundManualDescription =>
      'Tersedia sepenuhnya offline';

  @override
  String get packagedFoodNotFoundPhotoTitle => 'Foto label gizi';

  @override
  String get packagedFoodNotFoundPhotoDescription =>
      'Belum tersedia pada versi ini';

  @override
  String get packagedFoodPathUnavailable =>
      'Jalur ini belum tersedia pada versi aplikasi ini.';

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
}
