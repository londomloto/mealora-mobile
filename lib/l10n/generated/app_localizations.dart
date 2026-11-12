import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppText
/// returned by `AppText.of(context)`.
///
/// Applications need to include `AppText.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppText.localizationsDelegates,
///   supportedLocales: AppText.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppText.supportedLocales
/// property.
abstract class AppText {
  AppText(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppText of(BuildContext context) {
    return Localizations.of<AppText>(context, AppText)!;
  }

  static const LocalizationsDelegate<AppText> delegate = _AppTextDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('id')];

  /// Nama produk.
  ///
  /// In id, this message translates to:
  /// **'Mealora'**
  String get appName;

  /// Tagline pada splash.
  ///
  /// In id, this message translates to:
  /// **'Diary makanan harianmu'**
  String get appTagline;

  /// Label pembaca layar tombol kembali bersama (MealoraBackEyebrow) — dipakai layar yang dibuka lewat push dan tidak memakai AppBar.
  ///
  /// In id, this message translates to:
  /// **'Kembali'**
  String get backButtonSemantics;

  /// Janji penyimpanan lokal pada splash.
  ///
  /// In id, this message translates to:
  /// **'Pribadi di perangkatmu · siap digunakan offline'**
  String get splashPrivacyPromise;

  /// Label pembaca layar untuk indikator muat pada splash.
  ///
  /// In id, this message translates to:
  /// **'Mealora sedang disiapkan'**
  String get splashLoadingSemantics;

  /// Label pembaca layar untuk simbol merek.
  ///
  /// In id, this message translates to:
  /// **'Logo Mealora'**
  String get splashLogoSemantics;

  /// Judul keadaan gagal membuka penyimpanan lokal.
  ///
  /// In id, this message translates to:
  /// **'Penyimpanan di perangkat belum siap'**
  String get storageErrorTitle;

  /// Penjelasan keadaan gagal membuka penyimpanan lokal.
  ///
  /// In id, this message translates to:
  /// **'Mealora tidak bisa membuka penyimpanan di perangkat ini, jadi catatanmu belum bisa dibaca atau ditulis. Data yang sudah ada tidak diubah.'**
  String get storageErrorBody;

  /// Label untuk kode alasan teknis.
  ///
  /// In id, this message translates to:
  /// **'Kode kegagalan'**
  String get storageErrorReasonLabel;

  /// Tindakan mencoba ulang.
  ///
  /// In id, this message translates to:
  /// **'Coba lagi'**
  String get retry;

  /// No description provided for @navToday.
  ///
  /// In id, this message translates to:
  /// **'Hari ini'**
  String get navToday;

  /// No description provided for @navProgram.
  ///
  /// In id, this message translates to:
  /// **'Program'**
  String get navProgram;

  /// No description provided for @programPageTitle.
  ///
  /// In id, this message translates to:
  /// **'Program saya'**
  String get programPageTitle;

  /// No description provided for @programPageSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Ruang untuk bertumbuh, pelan-pelan'**
  String get programPageSubtitle;

  /// No description provided for @navHistory.
  ///
  /// In id, this message translates to:
  /// **'Riwayat'**
  String get navHistory;

  /// No description provided for @navProfile.
  ///
  /// In id, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// Label pembaca layar untuk tujuan navigasi yang sedang aktif.
  ///
  /// In id, this message translates to:
  /// **'{destination}, sedang dibuka'**
  String navSelectedSemantics(String destination);

  /// Label pembaca layar untuk tujuan navigasi yang tidak aktif.
  ///
  /// In id, this message translates to:
  /// **'{destination}'**
  String navUnselectedSemantics(String destination);

  /// Label pembaca layar untuk tombol Catat yang terangkat di tengah navigasi.
  ///
  /// In id, this message translates to:
  /// **'Catat makanan'**
  String get navRecordSemantics;

  /// Pesan saat tombol Catat ditekan sebelum pencatatan makanan dibangun.
  ///
  /// In id, this message translates to:
  /// **'Pencatatan makanan belum tersedia. Bagian ini menyusul pada tahap berikutnya.'**
  String get recordUnavailable;

  /// Penanda keadaan kosong, dipakai bersama ikon agar tidak bergantung warna saja.
  ///
  /// In id, this message translates to:
  /// **'Belum ada data'**
  String get emptyStateBadge;

  /// No description provided for @todaySubtitle.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan energi dan makronutrienmu hari ini.'**
  String get todaySubtitle;

  /// No description provided for @todayGreeting.
  ///
  /// In id, this message translates to:
  /// **'Hai, {name}!'**
  String todayGreeting(String name);

  /// No description provided for @todayDefaultName.
  ///
  /// In id, this message translates to:
  /// **'Teman'**
  String get todayDefaultName;

  /// No description provided for @programSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Program yang sedang kamu jalani beserta targetnya.'**
  String get programSubtitle;

  /// No description provided for @historySubtitle.
  ///
  /// In id, this message translates to:
  /// **'Catatan harianmu pada tanggal-tanggal sebelumnya.'**
  String get historySubtitle;

  /// No description provided for @historyContextLabel.
  ///
  /// In id, this message translates to:
  /// **'RIWAYAT'**
  String get historyContextLabel;

  /// No description provided for @historyTodayContextLabel.
  ///
  /// In id, this message translates to:
  /// **'HARI INI'**
  String get historyTodayContextLabel;

  /// No description provided for @historyDiaryTitle.
  ///
  /// In id, this message translates to:
  /// **'Buku harian'**
  String get historyDiaryTitle;

  /// No description provided for @historyLocalNote.
  ///
  /// In id, this message translates to:
  /// **'catatan di perangkat'**
  String get historyLocalNote;

  /// No description provided for @historyRecordedTodayLabel.
  ///
  /// In id, this message translates to:
  /// **'TERCATAT HARI INI'**
  String get historyRecordedTodayLabel;

  /// No description provided for @historyOpenCalendarLabel.
  ///
  /// In id, this message translates to:
  /// **'Buka kalender riwayat'**
  String get historyOpenCalendarLabel;

  /// No description provided for @historyPageTitle.
  ///
  /// In id, this message translates to:
  /// **'Lihat perjalananmu'**
  String get historyPageTitle;

  /// No description provided for @historyPageSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Catatan harian, tanpa hari yang ‘gagal’.'**
  String get historyPageSubtitle;

  /// No description provided for @profileSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Profil lokal, satuan, dan kendali atas datamu.'**
  String get profileSubtitle;

  /// No description provided for @profileContextLabel.
  ///
  /// In id, this message translates to:
  /// **'PROFIL'**
  String get profileContextLabel;

  /// No description provided for @profilePageTitle.
  ///
  /// In id, this message translates to:
  /// **'Hai, {name}'**
  String profilePageTitle(String name);

  /// No description provided for @profilePageSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan untuk perjalananmu.'**
  String get profilePageSubtitle;

  /// No description provided for @profileLocalDetail.
  ///
  /// In id, this message translates to:
  /// **'Profil lokal · tanpa akun'**
  String get profileLocalDetail;

  /// No description provided for @todayEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Hari ini belum tercatat'**
  String get todayEmptyTitle;

  /// No description provided for @todayEmptyBody.
  ///
  /// In id, this message translates to:
  /// **'Kalori dan makro ditampilkan sebagai \"belum diketahui\", bukan 0 kkal atau target yang gagal.'**
  String get todayEmptyBody;

  /// No description provided for @todayNoProgramTargetNote.
  ///
  /// In id, this message translates to:
  /// **'Belum ada program aktif, jadi belum ada target pembanding.'**
  String get todayNoProgramTargetNote;

  /// Pernyataan netral saat konsumsi melampaui target (D11) — bukan peringatan.
  ///
  /// In id, this message translates to:
  /// **'{kcal} kkal lebih dari perkiraan'**
  String todayExcessOverTarget(String kcal);

  /// No description provided for @todayMealNotLogged.
  ///
  /// In id, this message translates to:
  /// **'Belum dicatat'**
  String get todayMealNotLogged;

  /// No description provided for @todayLogFoodAction.
  ///
  /// In id, this message translates to:
  /// **'Catat makanan'**
  String get todayLogFoodAction;

  /// No description provided for @todayMealsHeading.
  ///
  /// In id, this message translates to:
  /// **'Makanan hari ini'**
  String get todayMealsHeading;

  /// No description provided for @todayMealsCountFormat.
  ///
  /// In id, this message translates to:
  /// **'{count} waktu makan tercatat'**
  String todayMealsCountFormat(int count);

  /// No description provided for @programEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada program'**
  String get programEmptyTitle;

  /// No description provided for @programEmptyBody.
  ///
  /// In id, this message translates to:
  /// **'Di sini nanti muncul program yang sedang kamu jalani beserta target hariannya dan perkembanganmu. Pemilihan program masuk pada tahap berikutnya.'**
  String get programEmptyBody;

  /// No description provided for @historyEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada riwayat'**
  String get historyEmptyTitle;

  /// No description provided for @historyEmptyBody.
  ///
  /// In id, this message translates to:
  /// **'Di sini nanti muncul catatan harianmu pada tanggal-tanggal sebelumnya, lengkap dengan ringkasan energi dan makronutrien.'**
  String get historyEmptyBody;

  /// No description provided for @historyEnergyRecordedLabel.
  ///
  /// In id, this message translates to:
  /// **'ENERGI TERCATAT'**
  String get historyEnergyRecordedLabel;

  /// No description provided for @historyWeightRecordedLabel.
  ///
  /// In id, this message translates to:
  /// **'Berat tercatat tanggal ini'**
  String get historyWeightRecordedLabel;

  /// No description provided for @historyPreviousMonthSemantics.
  ///
  /// In id, this message translates to:
  /// **'Bulan sebelumnya'**
  String get historyPreviousMonthSemantics;

  /// No description provided for @historyNextMonthSemantics.
  ///
  /// In id, this message translates to:
  /// **'Bulan berikutnya'**
  String get historyNextMonthSemantics;

  /// No description provided for @historyDayHasRecordSemantics.
  ///
  /// In id, this message translates to:
  /// **'{date}, ada catatan'**
  String historyDayHasRecordSemantics(String date);

  /// No description provided for @historyDayNoRecordSemantics.
  ///
  /// In id, this message translates to:
  /// **'{date}, belum ada catatan'**
  String historyDayNoRecordSemantics(String date);

  /// No description provided for @historyDaySelectedSuffix.
  ///
  /// In id, this message translates to:
  /// **', terpilih'**
  String get historyDaySelectedSuffix;

  /// No description provided for @historyDayFutureSuffix.
  ///
  /// In id, this message translates to:
  /// **', belum bisa dipilih'**
  String get historyDayFutureSuffix;

  /// No description provided for @routeNotFoundTitle.
  ///
  /// In id, this message translates to:
  /// **'Halaman tidak ditemukan'**
  String get routeNotFoundTitle;

  /// No description provided for @routeNotFoundBody.
  ///
  /// In id, this message translates to:
  /// **'Alamat yang diminta tidak dikenali Mealora. Kamu bisa kembali ke ruang utama dan melanjutkan dari sana.'**
  String get routeNotFoundBody;

  /// No description provided for @routeNotFoundAction.
  ///
  /// In id, this message translates to:
  /// **'Kembali ke Hari ini'**
  String get routeNotFoundAction;

  /// No description provided for @unitKilogram.
  ///
  /// In id, this message translates to:
  /// **'kg'**
  String get unitKilogram;

  /// No description provided for @unitCentimeter.
  ///
  /// In id, this message translates to:
  /// **'cm'**
  String get unitCentimeter;

  /// No description provided for @unitKilocalorie.
  ///
  /// In id, this message translates to:
  /// **'kkal'**
  String get unitKilocalorie;

  /// No description provided for @unitGram.
  ///
  /// In id, this message translates to:
  /// **'g'**
  String get unitGram;

  /// No description provided for @unitMilligram.
  ///
  /// In id, this message translates to:
  /// **'mg'**
  String get unitMilligram;

  /// Nilai beserta satuannya, dirangkai sebagai satu kalimat utuh agar satuan dapat diganti belakangan.
  ///
  /// In id, this message translates to:
  /// **'{value} {unit}'**
  String valueWithUnit(String value, String unit);

  /// Indikator langkah onboarding (task 3.4, FRS 3.3.7), mis. 'LANGKAH 1 / 5'.
  ///
  /// In id, this message translates to:
  /// **'LANGKAH {step} / {total}'**
  String onboardingStepLabel(int step, int total);

  /// No description provided for @onboardingWelcomeEyebrow.
  ///
  /// In id, this message translates to:
  /// **'Diary makanan harianmu'**
  String get onboardingWelcomeEyebrow;

  /// No description provided for @onboardingWelcomeHeading.
  ///
  /// In id, this message translates to:
  /// **'Kenali makananmu.\nNikmati prosesnya.'**
  String get onboardingWelcomeHeading;

  /// No description provided for @onboardingWelcomeDescription.
  ///
  /// In id, this message translates to:
  /// **'Catat makanan, pahami kebutuhan harian, dan ikuti programmu—tanpa akun dan tetap bisa offline.'**
  String get onboardingWelcomeDescription;

  /// No description provided for @onboardingWelcomeAction.
  ///
  /// In id, this message translates to:
  /// **'Mulai perjalanan'**
  String get onboardingWelcomeAction;

  /// No description provided for @onboardingWelcomePrivacy.
  ///
  /// In id, this message translates to:
  /// **'Data pribadimu tersimpan di perangkat ini.'**
  String get onboardingWelcomePrivacy;

  /// No description provided for @onboardingWelcomeHeroSemantics.
  ///
  /// In id, this message translates to:
  /// **'Ilustrasi makanan Indonesia'**
  String get onboardingWelcomeHeroSemantics;

  /// No description provided for @onboardingWelcomePromiseLogTitle.
  ///
  /// In id, this message translates to:
  /// **'Catat cepat'**
  String get onboardingWelcomePromiseLogTitle;

  /// No description provided for @onboardingWelcomePromiseLogDetail.
  ///
  /// In id, this message translates to:
  /// **'Foto, suara, barcode, atau manual'**
  String get onboardingWelcomePromiseLogDetail;

  /// No description provided for @onboardingWelcomePromiseFairTitle.
  ///
  /// In id, this message translates to:
  /// **'Program yang jujur'**
  String get onboardingWelcomePromiseFairTitle;

  /// No description provided for @onboardingWelcomePromiseFairDetail.
  ///
  /// In id, this message translates to:
  /// **'Target perkiraan, bukan janji instan'**
  String get onboardingWelcomePromiseFairDetail;

  /// No description provided for @onboardingWelcomePromisePrivacyTitle.
  ///
  /// In id, this message translates to:
  /// **'Privasi dulu'**
  String get onboardingWelcomePromisePrivacyTitle;

  /// No description provided for @onboardingWelcomePromisePrivacyDetail.
  ///
  /// In id, this message translates to:
  /// **'Data tersimpan di perangkatmu'**
  String get onboardingWelcomePromisePrivacyDetail;

  /// No description provided for @onboardingProfileTitle.
  ///
  /// In id, this message translates to:
  /// **'Kenalan dulu, yuk'**
  String get onboardingProfileTitle;

  /// No description provided for @onboardingProfileSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Informasi ini membantu membuat estimasi energi.'**
  String get onboardingProfileSubtitle;

  /// No description provided for @onboardingNicknameLabel.
  ///
  /// In id, this message translates to:
  /// **'Nama panggilan (opsional)'**
  String get onboardingNicknameLabel;

  /// No description provided for @onboardingNicknameHint.
  ///
  /// In id, this message translates to:
  /// **'mis. Naya'**
  String get onboardingNicknameHint;

  /// No description provided for @onboardingBirthDateLabel.
  ///
  /// In id, this message translates to:
  /// **'Tanggal lahir'**
  String get onboardingBirthDateLabel;

  /// No description provided for @onboardingBirthDateHint.
  ///
  /// In id, this message translates to:
  /// **'HH-BB-TTTT'**
  String get onboardingBirthDateHint;

  /// No description provided for @onboardingHeightLabel.
  ///
  /// In id, this message translates to:
  /// **'Tinggi badan'**
  String get onboardingHeightLabel;

  /// No description provided for @onboardingHeightHint.
  ///
  /// In id, this message translates to:
  /// **'mis. 165'**
  String get onboardingHeightHint;

  /// No description provided for @onboardingWeightLabel.
  ///
  /// In id, this message translates to:
  /// **'Berat saat ini'**
  String get onboardingWeightLabel;

  /// No description provided for @onboardingWeightHint.
  ///
  /// In id, this message translates to:
  /// **'mis. 68,4'**
  String get onboardingWeightHint;

  /// No description provided for @onboardingBiologicalInputLabel.
  ///
  /// In id, this message translates to:
  /// **'Input untuk persamaan energi'**
  String get onboardingBiologicalInputLabel;

  /// No description provided for @onboardingBiologicalInputDisclosure.
  ///
  /// In id, this message translates to:
  /// **'Digunakan hanya untuk persamaan estimasi energi, bukan identitas gender.'**
  String get onboardingBiologicalInputDisclosure;

  /// No description provided for @onboardingBiologicalInputHint.
  ///
  /// In id, this message translates to:
  /// **'Pilih salah satu'**
  String get onboardingBiologicalInputHint;

  /// No description provided for @onboardingBiologicalInputFemale.
  ///
  /// In id, this message translates to:
  /// **'Perempuan'**
  String get onboardingBiologicalInputFemale;

  /// No description provided for @onboardingBiologicalInputMale.
  ///
  /// In id, this message translates to:
  /// **'Laki-laki'**
  String get onboardingBiologicalInputMale;

  /// No description provided for @onboardingContinueAction.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan'**
  String get onboardingContinueAction;

  /// No description provided for @onboardingRequiredBirthDate.
  ///
  /// In id, this message translates to:
  /// **'Tanggal lahir belum diisi.'**
  String get onboardingRequiredBirthDate;

  /// No description provided for @onboardingRequiredHeight.
  ///
  /// In id, this message translates to:
  /// **'Tinggi badan belum diisi.'**
  String get onboardingRequiredHeight;

  /// No description provided for @onboardingRequiredWeight.
  ///
  /// In id, this message translates to:
  /// **'Berat badan belum diisi.'**
  String get onboardingRequiredWeight;

  /// No description provided for @onboardingRequiredBiologicalInput.
  ///
  /// In id, this message translates to:
  /// **'Pilih salah satu dulu.'**
  String get onboardingRequiredBiologicalInput;

  /// No description provided for @onboardingBackSemantics.
  ///
  /// In id, this message translates to:
  /// **'Kembali ke langkah sebelumnya'**
  String get onboardingBackSemantics;

  /// No description provided for @onboardingActivityTitle.
  ///
  /// In id, this message translates to:
  /// **'Seberapa aktif harimu?'**
  String get onboardingActivityTitle;

  /// No description provided for @onboardingActivitySubtitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih yang paling mendekati rutinitas biasa.'**
  String get onboardingActivitySubtitle;

  /// No description provided for @onboardingActivitySedentaryTitle.
  ///
  /// In id, this message translates to:
  /// **'Lebih banyak duduk'**
  String get onboardingActivitySedentaryTitle;

  /// No description provided for @onboardingActivitySedentaryDetail.
  ///
  /// In id, this message translates to:
  /// **'Aktivitas fisik sehari-hari ringan'**
  String get onboardingActivitySedentaryDetail;

  /// No description provided for @onboardingActivityModerateTitle.
  ///
  /// In id, this message translates to:
  /// **'Cukup bergerak'**
  String get onboardingActivityModerateTitle;

  /// No description provided for @onboardingActivityModerateDetail.
  ///
  /// In id, this message translates to:
  /// **'Berjalan atau bergerak secara rutin'**
  String get onboardingActivityModerateDetail;

  /// No description provided for @onboardingActivityVeryTitle.
  ///
  /// In id, this message translates to:
  /// **'Sangat aktif'**
  String get onboardingActivityVeryTitle;

  /// No description provided for @onboardingActivityVeryDetail.
  ///
  /// In id, this message translates to:
  /// **'Sering beraktivitas fisik intens'**
  String get onboardingActivityVeryDetail;

  /// No description provided for @onboardingActivityNote.
  ///
  /// In id, this message translates to:
  /// **'Faktor aktivitas memengaruhi estimasi. Pilih dengan jujur; kamu bisa mengubahnya nanti.'**
  String get onboardingActivityNote;

  /// No description provided for @onboardingProgramSelectTitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih arahmu'**
  String get onboardingProgramSelectTitle;

  /// No description provided for @onboardingProgramSelectSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Empat program. Kamu bisa menggantinya nanti.'**
  String get onboardingProgramSelectSubtitle;

  /// No description provided for @onboardingProgramHealthyName.
  ///
  /// In id, this message translates to:
  /// **'Makan Sehat'**
  String get onboardingProgramHealthyName;

  /// No description provided for @onboardingProgramHealthyDescription.
  ///
  /// In id, this message translates to:
  /// **'Fokus pada kebiasaan makan'**
  String get onboardingProgramHealthyDescription;

  /// No description provided for @onboardingProgramWeightLossName.
  ///
  /// In id, this message translates to:
  /// **'Turun Berat'**
  String get onboardingProgramWeightLossName;

  /// No description provided for @onboardingProgramWeightLossDescription.
  ///
  /// In id, this message translates to:
  /// **'Target berat dengan kebijakan aman'**
  String get onboardingProgramWeightLossDescription;

  /// No description provided for @onboardingProgramWeightGainName.
  ///
  /// In id, this message translates to:
  /// **'Naik Berat'**
  String get onboardingProgramWeightGainName;

  /// No description provided for @onboardingProgramWeightGainDescription.
  ///
  /// In id, this message translates to:
  /// **'Target berat dengan kebijakan aman'**
  String get onboardingProgramWeightGainDescription;

  /// No description provided for @onboardingProgramMaintenanceName.
  ///
  /// In id, this message translates to:
  /// **'Pertahankan'**
  String get onboardingProgramMaintenanceName;

  /// No description provided for @onboardingProgramMaintenanceDescription.
  ///
  /// In id, this message translates to:
  /// **'Menjaga keseimbangan'**
  String get onboardingProgramMaintenanceDescription;

  /// No description provided for @onboardingProgramTerms.
  ///
  /// In id, this message translates to:
  /// **'Program yang mengubah berat punya batas usia dan kondisi tertentu.'**
  String get onboardingProgramTerms;

  /// Judul layar detail program untuk Makan Sehat.
  ///
  /// In id, this message translates to:
  /// **'Fokus {program}'**
  String onboardingProgramDetailFocusTitle(String program);

  /// Judul layar detail program untuk program selain Makan Sehat.
  ///
  /// In id, this message translates to:
  /// **'Detail {program}'**
  String onboardingProgramDetailGenericTitle(String program);

  /// No description provided for @onboardingProgramDetailFocusSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Mulai dari hal-hal yang bisa kamu lakukan.'**
  String get onboardingProgramDetailFocusSubtitle;

  /// No description provided for @onboardingProgramDetailGenericSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Tinjau sebelum melanjutkan ke perkiraan target.'**
  String get onboardingProgramDetailGenericSubtitle;

  /// No description provided for @onboardingProgramClarificationNoTarget.
  ///
  /// In id, this message translates to:
  /// **'Tanpa target berat wajib'**
  String get onboardingProgramClarificationNoTarget;

  /// No description provided for @onboardingProgramClarificationHasTarget.
  ///
  /// In id, this message translates to:
  /// **'Berat tujuan diatur di langkah berikutnya'**
  String get onboardingProgramClarificationHasTarget;

  /// No description provided for @onboardingFocusHeading.
  ///
  /// In id, this message translates to:
  /// **'Apa yang ingin kamu perhatikan?'**
  String get onboardingFocusHeading;

  /// No description provided for @onboardingFocusConsistentLogging.
  ///
  /// In id, this message translates to:
  /// **'Konsisten mencatat makanan'**
  String get onboardingFocusConsistentLogging;

  /// No description provided for @onboardingFocusMacros.
  ///
  /// In id, this message translates to:
  /// **'Memahami protein & makro'**
  String get onboardingFocusMacros;

  /// No description provided for @onboardingFocusPortions.
  ///
  /// In id, this message translates to:
  /// **'Mengenal porsi makan'**
  String get onboardingFocusPortions;

  /// No description provided for @onboardingAcknowledgeText.
  ///
  /// In id, this message translates to:
  /// **'Saya paham bahwa target dan data makanan adalah perkiraan, bukan nasihat medis.'**
  String get onboardingAcknowledgeText;

  /// No description provided for @onboardingAcknowledgeRequired.
  ///
  /// In id, this message translates to:
  /// **'Beri pengakuan ini dulu untuk melihat pratinjau.'**
  String get onboardingAcknowledgeRequired;

  /// No description provided for @onboardingPreviewAction.
  ///
  /// In id, this message translates to:
  /// **'Lihat perkiraan target'**
  String get onboardingPreviewAction;

  /// Label konteks layar target berat, mis. 'PROGRAM · TURUN BERAT'.
  ///
  /// In id, this message translates to:
  /// **'PROGRAM · {program}'**
  String onboardingTargetWeightContext(String program);

  /// No description provided for @onboardingTargetWeightTitle.
  ///
  /// In id, this message translates to:
  /// **'Atur target berat'**
  String get onboardingTargetWeightTitle;

  /// No description provided for @onboardingTargetWeightSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Laju perubahan berat dibatasi agar tetap aman.'**
  String get onboardingTargetWeightSubtitle;

  /// No description provided for @onboardingTargetWeightLossNote.
  ///
  /// In id, this message translates to:
  /// **'Bukan target cepat atau janji hasil.'**
  String get onboardingTargetWeightLossNote;

  /// No description provided for @onboardingTargetWeightGainNote.
  ///
  /// In id, this message translates to:
  /// **'Bukan target cepat atau janji hasil.'**
  String get onboardingTargetWeightGainNote;

  /// No description provided for @onboardingStartingWeightLabel.
  ///
  /// In id, this message translates to:
  /// **'Berat awal'**
  String get onboardingStartingWeightLabel;

  /// No description provided for @onboardingGoalWeightLabel.
  ///
  /// In id, this message translates to:
  /// **'Berat tujuan'**
  String get onboardingGoalWeightLabel;

  /// No description provided for @onboardingGoalWeightHint.
  ///
  /// In id, this message translates to:
  /// **'mis. 62,0'**
  String get onboardingGoalWeightHint;

  /// No description provided for @onboardingTargetDateLabel.
  ///
  /// In id, this message translates to:
  /// **'Tanggal tujuan (opsional)'**
  String get onboardingTargetDateLabel;

  /// No description provided for @onboardingTargetDateHint.
  ///
  /// In id, this message translates to:
  /// **'Pilih tanggal (opsional)'**
  String get onboardingTargetDateHint;

  /// No description provided for @onboardingTargetDateHeading.
  ///
  /// In id, this message translates to:
  /// **'Tanggal tujuan tidak wajib'**
  String get onboardingTargetDateHeading;

  /// No description provided for @onboardingTargetDateExplanation.
  ///
  /// In id, this message translates to:
  /// **'Tanggal tidak pernah mengesampingkan aturan keselamatan.'**
  String get onboardingTargetDateExplanation;

  /// No description provided for @onboardingWeightGateNote.
  ///
  /// In id, this message translates to:
  /// **'Sebagian kondisi membuat target otomatis tidak dibuat. Kamu akan diberi tahu alasannya.'**
  String get onboardingWeightGateNote;

  /// No description provided for @onboardingReviewEligibilityAction.
  ///
  /// In id, this message translates to:
  /// **'Tinjau kelayakan'**
  String get onboardingReviewEligibilityAction;

  /// No description provided for @onboardingRequiredTargetWeight.
  ///
  /// In id, this message translates to:
  /// **'Berat tujuan belum diisi.'**
  String get onboardingRequiredTargetWeight;

  /// No description provided for @reviewStepLabel.
  ///
  /// In id, this message translates to:
  /// **'LANGKAH 5 / 5'**
  String get reviewStepLabel;

  /// No description provided for @reviewTitle.
  ///
  /// In id, this message translates to:
  /// **'Tinjau targetmu'**
  String get reviewTitle;

  /// No description provided for @reviewSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Periksa semua detail sebelum program dimulai.'**
  String get reviewSubtitle;

  /// No description provided for @reviewTargetLabel.
  ///
  /// In id, this message translates to:
  /// **'ESTIMASI TARGET HARIAN'**
  String get reviewTargetLabel;

  /// No description provided for @reviewTargetDisclaimer.
  ///
  /// In id, this message translates to:
  /// **'Perkiraan dari rumus, bukan hasil pengukuran.'**
  String get reviewTargetDisclaimer;

  /// No description provided for @reviewBasisHeading.
  ///
  /// In id, this message translates to:
  /// **'Dasar perkiraan'**
  String get reviewBasisHeading;

  /// No description provided for @reviewBasisProfileLabel.
  ///
  /// In id, this message translates to:
  /// **'Profil'**
  String get reviewBasisProfileLabel;

  /// No description provided for @reviewBasisProfileValue.
  ///
  /// In id, this message translates to:
  /// **'Usia, tinggi, berat'**
  String get reviewBasisProfileValue;

  /// No description provided for @reviewBasisActivityLabel.
  ///
  /// In id, this message translates to:
  /// **'Aktivitas'**
  String get reviewBasisActivityLabel;

  /// No description provided for @reviewBasisEquationLabel.
  ///
  /// In id, this message translates to:
  /// **'Persamaan'**
  String get reviewBasisEquationLabel;

  /// No description provided for @reviewVersionHeading.
  ///
  /// In id, this message translates to:
  /// **'Tinjau sebelum menyetujui'**
  String get reviewVersionHeading;

  /// No description provided for @reviewVersionDetail.
  ///
  /// In id, this message translates to:
  /// **'Mealora menampilkan versi kalkulator dan kebijakan, asumsi yang dipakai, serta alasan setiap batasan.'**
  String get reviewVersionDetail;

  /// Baris versi kalkulator dan kebijakan pada pratinjau (FRS 4.3.1).
  ///
  /// In id, this message translates to:
  /// **'Kalkulator {calculatorVersion} · Kebijakan {policyVersion}'**
  String reviewVersionLine(String calculatorVersion, String policyVersion);

  /// No description provided for @reviewNoActiveProgramNote.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada program aktif sebelum kamu menyetujui.'**
  String get reviewNoActiveProgramNote;

  /// No description provided for @reviewApproveAction.
  ///
  /// In id, this message translates to:
  /// **'Setujui & mulai program'**
  String get reviewApproveAction;

  /// No description provided for @reviewNoEnergyTargetNote.
  ///
  /// In id, this message translates to:
  /// **'Programmu berfokus pada kebiasaan makan, tanpa angka target energi.'**
  String get reviewNoEnergyTargetNote;

  /// No description provided for @reviewAssumptionEstimateNotMeasurement.
  ///
  /// In id, this message translates to:
  /// **'Seluruh angka adalah perkiraan dari rumus, bukan hasil pengukuran atau jaminan.'**
  String get reviewAssumptionEstimateNotMeasurement;

  /// No description provided for @reviewWarningFloorApplied.
  ///
  /// In id, this message translates to:
  /// **'Target dinaikkan ke batas asupan aman terendah.'**
  String get reviewWarningFloorApplied;

  /// No description provided for @reviewWarningRelativePaceCapApplied.
  ///
  /// In id, this message translates to:
  /// **'Laju perubahan berat dibatasi menurut persentase berat badanmu.'**
  String get reviewWarningRelativePaceCapApplied;

  /// No description provided for @reviewWarningCarbohydrateBelowRecommendedRange.
  ///
  /// In id, this message translates to:
  /// **'Proporsi karbohidrat berada di bawah rentang yang dianjurkan setelah penyesuaian.'**
  String get reviewWarningCarbohydrateBelowRecommendedRange;

  /// No description provided for @reviewChangedContextLabel.
  ///
  /// In id, this message translates to:
  /// **'DATA DIPERBARUI'**
  String get reviewChangedContextLabel;

  /// No description provided for @reviewChangedTitle.
  ///
  /// In id, this message translates to:
  /// **'Masukanmu berubah'**
  String get reviewChangedTitle;

  /// No description provided for @reviewChangedSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Sejak pratinjau terakhir, beberapa datamu berubah. Pratinjau di bawah ini sudah memakai nilai terbaru.'**
  String get reviewChangedSubtitle;

  /// No description provided for @reviewChangedHeading.
  ///
  /// In id, this message translates to:
  /// **'Apa yang berubah'**
  String get reviewChangedHeading;

  /// No description provided for @reviewChangedFieldWeight.
  ///
  /// In id, this message translates to:
  /// **'Berat badan'**
  String get reviewChangedFieldWeight;

  /// Nilai lama dan baru pada layar masukan berubah sejak pratinjau (Design D5).
  ///
  /// In id, this message translates to:
  /// **'{oldValue} → {newValue}'**
  String reviewChangedValue(String oldValue, String newValue);

  /// No description provided for @reviewChangedTargetLabel.
  ///
  /// In id, this message translates to:
  /// **'ESTIMASI TARGET HARIAN · DIPERBARUI'**
  String get reviewChangedTargetLabel;

  /// No description provided for @reviewChangedNoteHeading.
  ///
  /// In id, this message translates to:
  /// **'Tinjau sekali lagi'**
  String get reviewChangedNoteHeading;

  /// No description provided for @reviewChangedNoteDetail.
  ///
  /// In id, this message translates to:
  /// **'Mealora memakai data terbarumu untuk pratinjau ini. Tidak ada yang salah dengan isianmu sebelumnya.'**
  String get reviewChangedNoteDetail;

  /// No description provided for @reviewChangedConfirmation.
  ///
  /// In id, this message translates to:
  /// **'Program tersimpan tidak berubah sampai kamu menyetujui ulang.'**
  String get reviewChangedConfirmation;

  /// No description provided for @reviewChangedAction.
  ///
  /// In id, this message translates to:
  /// **'Tinjau & setujui ulang'**
  String get reviewChangedAction;

  /// No description provided for @rejectionContextLabel.
  ///
  /// In id, this message translates to:
  /// **'STATUS · TARGET TIDAK DIBUAT'**
  String get rejectionContextLabel;

  /// No description provided for @rejectionTitle.
  ///
  /// In id, this message translates to:
  /// **'Target tidak dibuat'**
  String get rejectionTitle;

  /// No description provided for @rejectionSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Kami tidak membuat target untuk kondisi ini.'**
  String get rejectionSubtitle;

  /// No description provided for @rejectionNoChangeNote.
  ///
  /// In id, this message translates to:
  /// **'Data dan program sebelumnya tidak berubah.'**
  String get rejectionNoChangeNote;

  /// No description provided for @rejectionAlternativeHeading.
  ///
  /// In id, this message translates to:
  /// **'Coba Makan Sehat'**
  String get rejectionAlternativeHeading;

  /// No description provided for @rejectionAlternativeDetail.
  ///
  /// In id, this message translates to:
  /// **'Catat makanan dan pahami kebiasaan tanpa target perubahan berat.'**
  String get rejectionAlternativeDetail;

  /// No description provided for @rejectionAlternativeAction.
  ///
  /// In id, this message translates to:
  /// **'Lihat program lain'**
  String get rejectionAlternativeAction;

  /// No description provided for @rejectionBackToProgramAction.
  ///
  /// In id, this message translates to:
  /// **'Pilih program lagi'**
  String get rejectionBackToProgramAction;

  /// No description provided for @rejectionChangeInputAction.
  ///
  /// In id, this message translates to:
  /// **'Ubah masukan'**
  String get rejectionChangeInputAction;

  /// No description provided for @rejectionAgeBelowMinimumHeading.
  ///
  /// In id, this message translates to:
  /// **'Belum bisa membuat target otomatis'**
  String get rejectionAgeBelowMinimumHeading;

  /// No description provided for @rejectionAgeBelowMinimumExplanation.
  ///
  /// In id, this message translates to:
  /// **'Mealora membuat target otomatis untuk rentang usia dewasa. Usia yang kamu isi berada di luar rentang itu.'**
  String get rejectionAgeBelowMinimumExplanation;

  /// No description provided for @rejectionAgeAboveSupportedHeading.
  ///
  /// In id, this message translates to:
  /// **'Belum bisa membuat target otomatis'**
  String get rejectionAgeAboveSupportedHeading;

  /// No description provided for @rejectionAgeAboveSupportedExplanation.
  ///
  /// In id, this message translates to:
  /// **'Mealora membuat target otomatis untuk rentang usia yang didukung kalkulatornya saat ini. Usia yang kamu isi berada di luar rentang itu.'**
  String get rejectionAgeAboveSupportedExplanation;

  /// No description provided for @rejectionPregnancyOrLactationHeading.
  ///
  /// In id, this message translates to:
  /// **'Belum bisa membuat target otomatis'**
  String get rejectionPregnancyOrLactationHeading;

  /// No description provided for @rejectionPregnancyOrLactationExplanation.
  ///
  /// In id, this message translates to:
  /// **'Perkiraan kebutuhan energi berbeda pada masa kehamilan atau menyusui, dan kalkulator ini belum mendukungnya.'**
  String get rejectionPregnancyOrLactationExplanation;

  /// No description provided for @rejectionUnderweightBmiHeading.
  ///
  /// In id, this message translates to:
  /// **'Belum bisa membuat target otomatis'**
  String get rejectionUnderweightBmiHeading;

  /// No description provided for @rejectionUnderweightBmiExplanation.
  ///
  /// In id, this message translates to:
  /// **'Kombinasi tinggi dan berat yang kamu isi berada di luar rentang yang bisa dihitung kalkulator ini secara otomatis.'**
  String get rejectionUnderweightBmiExplanation;

  /// No description provided for @rejectionBmiAboveSupportedHeading.
  ///
  /// In id, this message translates to:
  /// **'Belum bisa membuat target otomatis'**
  String get rejectionBmiAboveSupportedHeading;

  /// No description provided for @rejectionBmiAboveSupportedExplanation.
  ///
  /// In id, this message translates to:
  /// **'Kombinasi tinggi dan berat yang kamu isi berada di luar rentang yang bisa dihitung kalkulator ini secara otomatis.'**
  String get rejectionBmiAboveSupportedExplanation;

  /// No description provided for @rejectionDeclaredMedicalConditionHeading.
  ///
  /// In id, this message translates to:
  /// **'Belum bisa membuat target otomatis'**
  String get rejectionDeclaredMedicalConditionHeading;

  /// No description provided for @rejectionDeclaredMedicalConditionExplanation.
  ///
  /// In id, this message translates to:
  /// **'Kamu menandai satu atau lebih kondisi yang membuat target perubahan berat perlu disesuaikan oleh tenaga kesehatan, bukan dihitung otomatis.'**
  String get rejectionDeclaredMedicalConditionExplanation;

  /// No description provided for @rejectionRapidUnintendedWeightChangeHeading.
  ///
  /// In id, this message translates to:
  /// **'Belum bisa membuat target otomatis'**
  String get rejectionRapidUnintendedWeightChangeHeading;

  /// No description provided for @rejectionRapidUnintendedWeightChangeExplanation.
  ///
  /// In id, this message translates to:
  /// **'Kamu melaporkan perubahan berat yang cukup besar dalam waktu singkat belakangan ini. Kalkulator ini perlu masukan tambahan dari tenaga kesehatan sebelum menghitung target baru.'**
  String get rejectionRapidUnintendedWeightChangeExplanation;

  /// No description provided for @rejectionTargetBelowMinimumEnergyHeading.
  ///
  /// In id, this message translates to:
  /// **'Belum bisa membuat target otomatis'**
  String get rejectionTargetBelowMinimumEnergyHeading;

  /// No description provided for @rejectionTargetBelowMinimumEnergyExplanation.
  ///
  /// In id, this message translates to:
  /// **'Permintaanmu membuat perkiraan asupan energi harian turun lebih rendah dari batas aman yang dipakai kalkulator ini.'**
  String get rejectionTargetBelowMinimumEnergyExplanation;

  /// No description provided for @rejectionRequestedPaceTooFastHeading.
  ///
  /// In id, this message translates to:
  /// **'Tanggal ini butuh laju yang terlalu cepat'**
  String get rejectionRequestedPaceTooFastHeading;

  /// Penjelasan requestedPaceTooFast dengan tanggal paling awal yang aman (FRS 5.3.5).
  ///
  /// In id, this message translates to:
  /// **'Perubahan berat yang kamu minta dalam rentang waktu ini lebih cepat dari batas aman yang dipakai kalkulator ini. Tanggal paling awal yang memenuhi batas: {earliestSafeDate}.'**
  String rejectionRequestedPaceTooFastExplanation(String earliestSafeDate);

  /// No description provided for @rejectionRequestedPaceTooSlowHeading.
  ///
  /// In id, this message translates to:
  /// **'Laju ini lebih lambat dari yang didukung'**
  String get rejectionRequestedPaceTooSlowHeading;

  /// No description provided for @rejectionRequestedPaceTooSlowExplanation.
  ///
  /// In id, this message translates to:
  /// **'Perubahan berat yang kamu minta dalam rentang waktu ini lebih lambat dari laju minimum yang dipakai kalkulator ini.'**
  String get rejectionRequestedPaceTooSlowExplanation;

  /// No description provided for @rejectionTargetWeightOutOfRangeHeading.
  ///
  /// In id, this message translates to:
  /// **'Berat tujuan ini di luar jangkauan kalkulator'**
  String get rejectionTargetWeightOutOfRangeHeading;

  /// No description provided for @rejectionTargetWeightOutOfRangeExplanation.
  ///
  /// In id, this message translates to:
  /// **'Berat tujuan yang kamu isi berada di luar rentang yang bisa dihitung kalkulator ini secara otomatis dari berat saat ini.'**
  String get rejectionTargetWeightOutOfRangeExplanation;

  /// No description provided for @rejectionMissingValidatedPolicyHeading.
  ///
  /// In id, this message translates to:
  /// **'Target otomatis tidak tersedia'**
  String get rejectionMissingValidatedPolicyHeading;

  /// No description provided for @rejectionMissingValidatedPolicyExplanation.
  ///
  /// In id, this message translates to:
  /// **'Mealora tidak bisa menghitung target otomatis saat ini.'**
  String get rejectionMissingValidatedPolicyExplanation;

  /// No description provided for @rejectionMissingRequiredInputHeading.
  ///
  /// In id, this message translates to:
  /// **'Masih ada isian yang perlu dilengkapi'**
  String get rejectionMissingRequiredInputHeading;

  /// No description provided for @rejectionMissingRequiredInputExplanation.
  ///
  /// In id, this message translates to:
  /// **'Satu atau lebih isian wajib pada langkah sebelumnya belum lengkap.'**
  String get rejectionMissingRequiredInputExplanation;

  /// No description provided for @noProgramContextLabel.
  ///
  /// In id, this message translates to:
  /// **'PROGRAM SAYA'**
  String get noProgramContextLabel;

  /// No description provided for @noProgramTitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih programmu'**
  String get noProgramTitle;

  /// No description provided for @noProgramSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Catatan lamamu tetap ada dan bisa dibuka.'**
  String get noProgramSubtitle;

  /// No description provided for @noProgramHeading.
  ///
  /// In id, this message translates to:
  /// **'Belum ada program aktif'**
  String get noProgramHeading;

  /// No description provided for @noProgramDescription.
  ///
  /// In id, this message translates to:
  /// **'Pilih satu dari empat program. Kamu akan meninjau input, asumsi, dan target sebelum menyetujui.'**
  String get noProgramDescription;

  /// No description provided for @noProgramHistoryHeading.
  ///
  /// In id, this message translates to:
  /// **'Data sebelumnya aman'**
  String get noProgramHistoryHeading;

  /// No description provided for @noProgramHistoryExplanation.
  ///
  /// In id, this message translates to:
  /// **'Catatan makanan dan berat lama tetap ada meski kamu belum memilih program.'**
  String get noProgramHistoryExplanation;

  /// No description provided for @noProgramAction.
  ///
  /// In id, this message translates to:
  /// **'Pilih program'**
  String get noProgramAction;

  /// Label pembaca layar untuk chip program aktif di ruang Hari ini.
  ///
  /// In id, this message translates to:
  /// **'Program aktif: {program}'**
  String todayProgramChipSemantics(String program);

  /// No description provided for @todayProgramActiveLabel.
  ///
  /// In id, this message translates to:
  /// **'Program aktif'**
  String get todayProgramActiveLabel;

  /// No description provided for @todayDailyTargetLabel.
  ///
  /// In id, this message translates to:
  /// **'Target energi hari ini'**
  String get todayDailyTargetLabel;

  /// No description provided for @todayConsumedUnknown.
  ///
  /// In id, this message translates to:
  /// **'Belum diketahui'**
  String get todayConsumedUnknown;

  /// No description provided for @todayConsumedLabel.
  ///
  /// In id, this message translates to:
  /// **'Dikonsumsi'**
  String get todayConsumedLabel;

  /// No description provided for @todayEstimateLabel.
  ///
  /// In id, this message translates to:
  /// **'Perkiraan hari ini'**
  String get todayEstimateLabel;

  /// No description provided for @todayRemainingLabel.
  ///
  /// In id, this message translates to:
  /// **'Sisa perkiraan'**
  String get todayRemainingLabel;

  /// No description provided for @todayLoggedLabel.
  ///
  /// In id, this message translates to:
  /// **'Tercatat'**
  String get todayLoggedLabel;

  /// No description provided for @todayActivityLabel.
  ///
  /// In id, this message translates to:
  /// **'Aktivitas'**
  String get todayActivityLabel;

  /// No description provided for @todayActivityLight.
  ///
  /// In id, this message translates to:
  /// **'ringan'**
  String get todayActivityLight;

  /// No description provided for @todayActivityModerate.
  ///
  /// In id, this message translates to:
  /// **'sedang'**
  String get todayActivityModerate;

  /// No description provided for @todayActivityHigh.
  ///
  /// In id, this message translates to:
  /// **'tinggi'**
  String get todayActivityHigh;

  /// No description provided for @profileIncompleteTitle.
  ///
  /// In id, this message translates to:
  /// **'Lengkapi profil dulu'**
  String get profileIncompleteTitle;

  /// No description provided for @profileIncompleteBody.
  ///
  /// In id, this message translates to:
  /// **'Beberapa data profil belum lengkap, jadi target program belum bisa dijelaskan di sini.'**
  String get profileIncompleteBody;

  /// No description provided for @profileIncompleteAction.
  ///
  /// In id, this message translates to:
  /// **'Lengkapi profil'**
  String get profileIncompleteAction;

  /// No description provided for @pausedExplanationTitle.
  ///
  /// In id, this message translates to:
  /// **'Catat makanan seperti biasa'**
  String get pausedExplanationTitle;

  /// No description provided for @pausedExplanationBody.
  ///
  /// In id, this message translates to:
  /// **'Buku harian dan berat badan tetap tersedia saat program dijeda.'**
  String get pausedExplanationBody;

  /// No description provided for @programControlsHeading.
  ///
  /// In id, this message translates to:
  /// **'Kendali program'**
  String get programControlsHeading;

  /// No description provided for @programControlsPausedHeading.
  ///
  /// In id, this message translates to:
  /// **'Apa yang ingin kamu lakukan?'**
  String get programControlsPausedHeading;

  /// No description provided for @programResumeAction.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan program'**
  String get programResumeAction;

  /// No description provided for @programChangeAction.
  ///
  /// In id, this message translates to:
  /// **'Ganti'**
  String get programChangeAction;

  /// No description provided for @programCompleteAction.
  ///
  /// In id, this message translates to:
  /// **'Selesaikan program'**
  String get programCompleteAction;

  /// No description provided for @programPauseAction.
  ///
  /// In id, this message translates to:
  /// **'Jeda'**
  String get programPauseAction;

  /// No description provided for @programHistoryAction.
  ///
  /// In id, this message translates to:
  /// **'Riwayat'**
  String get programHistoryAction;

  /// No description provided for @programPausedEyebrow.
  ///
  /// In id, this message translates to:
  /// **'PROGRAM DIJEDA'**
  String get programPausedEyebrow;

  /// No description provided for @programActiveEyebrow.
  ///
  /// In id, this message translates to:
  /// **'PROGRAM AKTIF'**
  String get programActiveEyebrow;

  /// No description provided for @programPausedStatus.
  ///
  /// In id, this message translates to:
  /// **'Dijeda'**
  String get programPausedStatus;

  /// No description provided for @programActiveStatus.
  ///
  /// In id, this message translates to:
  /// **'Berjalan'**
  String get programActiveStatus;

  /// No description provided for @pausedDaysNotCountedExplanation.
  ///
  /// In id, this message translates to:
  /// **'Hari jeda tidak dihitung sebagai hari aktif.'**
  String get pausedDaysNotCountedExplanation;

  /// Keterangan tanggal mulai jeda pada ruang Program.
  ///
  /// In id, this message translates to:
  /// **'Dijeda sejak {date}'**
  String pausedSinceLabel(String date);

  /// No description provided for @programTargetLabel.
  ///
  /// In id, this message translates to:
  /// **'Target harian · perkiraan'**
  String get programTargetLabel;

  /// No description provided for @programHowCalculatedAction.
  ///
  /// In id, this message translates to:
  /// **'Bagaimana dihitung'**
  String get programHowCalculatedAction;

  /// Tanggal perhitungan terakhir target yang berlaku.
  ///
  /// In id, this message translates to:
  /// **'Dihitung terakhir {date}'**
  String programLastCalculatedLabel(String date);

  /// No description provided for @programLatestWeightLabel.
  ///
  /// In id, this message translates to:
  /// **'Berat terbaru'**
  String get programLatestWeightLabel;

  /// No description provided for @programNoWeightRecordedYet.
  ///
  /// In id, this message translates to:
  /// **'Belum ada catatan berat'**
  String get programNoWeightRecordedYet;

  /// No description provided for @programTargetReviewTitle.
  ///
  /// In id, this message translates to:
  /// **'Tinjau target program'**
  String get programTargetReviewTitle;

  /// No description provided for @programTargetReviewBody.
  ///
  /// In id, this message translates to:
  /// **'Berat terbaru beda cukup jauh dari yang dipakai menghitung target sekarang. Target lama tetap berlaku sampai kamu meninjau dan menyetujui yang baru.'**
  String get programTargetReviewBody;

  /// No description provided for @programTargetReviewSemantics.
  ///
  /// In id, this message translates to:
  /// **'Tinjau target program karena berat terbaru berubah signifikan'**
  String get programTargetReviewSemantics;

  /// No description provided for @programConsistencyHeading.
  ///
  /// In id, this message translates to:
  /// **'Kebiasaan minggu ini'**
  String get programConsistencyHeading;

  /// No description provided for @programConsistencySubheading.
  ///
  /// In id, this message translates to:
  /// **'Catatan makan, bukan nilai dirimu'**
  String get programConsistencySubheading;

  /// Jumlah hari dalam 7 hari terakhir yang punya catatan makan.
  ///
  /// In id, this message translates to:
  /// **'{count} dari 7 hari tercatat'**
  String programConsistencyFooter(int count);

  /// Label pembaca layar satu batang kebiasaan harian — {filled} bisa 0 sampai {total}.
  ///
  /// In id, this message translates to:
  /// **'{date}, {filled} dari {total} waktu makan tercatat'**
  String programConsistencyDaySegmentSemantics(
    String date,
    int filled,
    int total,
  );

  /// No description provided for @programConsistencyDayEmptySemantics.
  ///
  /// In id, this message translates to:
  /// **'{date}, belum ada catatan'**
  String programConsistencyDayEmptySemantics(String date);

  /// No description provided for @howCalculatedBackSemantics.
  ///
  /// In id, this message translates to:
  /// **'Kembali'**
  String get howCalculatedBackSemantics;

  /// No description provided for @howCalculatedContextLabel.
  ///
  /// In id, this message translates to:
  /// **'PROGRAM SAYA · BAGAIMANA DIHITUNG'**
  String get howCalculatedContextLabel;

  /// No description provided for @howCalculatedTitle.
  ///
  /// In id, this message translates to:
  /// **'Bagaimana target dihitung'**
  String get howCalculatedTitle;

  /// Subjudul layar Bagaimana Dihitung dengan tanggal perhitungan terakhir.
  ///
  /// In id, this message translates to:
  /// **'Dihitung terakhir {date}'**
  String howCalculatedSubtitle(String date);

  /// No description provided for @howCalculatedTargetEyebrow.
  ///
  /// In id, this message translates to:
  /// **'TARGET YANG BERLAKU · PERKIRAAN'**
  String get howCalculatedTargetEyebrow;

  /// No description provided for @howCalculatedTargetCaption.
  ///
  /// In id, this message translates to:
  /// **'Perkiraan dari rumus; berubah hanya saat revisi disetujui.'**
  String get howCalculatedTargetCaption;

  /// No description provided for @howCalculatedInputsHeading.
  ///
  /// In id, this message translates to:
  /// **'Masukan yang dipakai'**
  String get howCalculatedInputsHeading;

  /// No description provided for @howCalculatedHeightLabel.
  ///
  /// In id, this message translates to:
  /// **'Tinggi badan'**
  String get howCalculatedHeightLabel;

  /// No description provided for @howCalculatedWeightLabel.
  ///
  /// In id, this message translates to:
  /// **'Berat saat dihitung'**
  String get howCalculatedWeightLabel;

  /// No description provided for @howCalculatedLastCalculatedLabel.
  ///
  /// In id, this message translates to:
  /// **'Tanggal perhitungan terakhir'**
  String get howCalculatedLastCalculatedLabel;

  /// No description provided for @howCalculatedAssumptionsHeading.
  ///
  /// In id, this message translates to:
  /// **'Asumsi'**
  String get howCalculatedAssumptionsHeading;

  /// No description provided for @howCalculatedActivityFactorLabel.
  ///
  /// In id, this message translates to:
  /// **'Faktor aktivitas'**
  String get howCalculatedActivityFactorLabel;

  /// No description provided for @howCalculatedRoundingLabel.
  ///
  /// In id, this message translates to:
  /// **'Pembulatan'**
  String get howCalculatedRoundingLabel;

  /// No description provided for @howCalculatedRoundingValue.
  ///
  /// In id, this message translates to:
  /// **'Ke kelipatan 10 kkal terdekat'**
  String get howCalculatedRoundingValue;

  /// No description provided for @howCalculatedWarningsHeading.
  ///
  /// In id, this message translates to:
  /// **'Peringatan'**
  String get howCalculatedWarningsHeading;

  /// No description provided for @howCalculatedWarningFloorTitle.
  ///
  /// In id, this message translates to:
  /// **'Batas bawah energi diterapkan'**
  String get howCalculatedWarningFloorTitle;

  /// No description provided for @howCalculatedWarningPaceCapTitle.
  ///
  /// In id, this message translates to:
  /// **'Laju perubahan berat dibatasi'**
  String get howCalculatedWarningPaceCapTitle;

  /// No description provided for @howCalculatedWarningCarbTitle.
  ///
  /// In id, this message translates to:
  /// **'Proporsi karbohidrat disesuaikan'**
  String get howCalculatedWarningCarbTitle;

  /// No description provided for @howCalculatedReadOnlyNote.
  ///
  /// In id, this message translates to:
  /// **'Nilai di layar ini dibaca dari target yang tersimpan, bukan dihitung ulang.'**
  String get howCalculatedReadOnlyNote;

  /// No description provided for @completeContextLabel.
  ///
  /// In id, this message translates to:
  /// **'PROGRAM SAYA'**
  String get completeContextLabel;

  /// No description provided for @completeTitle.
  ///
  /// In id, this message translates to:
  /// **'Selesaikan program?'**
  String get completeTitle;

  /// No description provided for @completeSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Keputusan ini tidak menghapus perjalananmu.'**
  String get completeSubtitle;

  /// No description provided for @completeProgramEyebrow.
  ///
  /// In id, this message translates to:
  /// **'PROGRAM AKTIF'**
  String get completeProgramEyebrow;

  /// No description provided for @completeReasonHeading.
  ///
  /// In id, this message translates to:
  /// **'Alasan selesai'**
  String get completeReasonHeading;

  /// No description provided for @completeReasonPlaceholder.
  ///
  /// In id, this message translates to:
  /// **'Pilih alasan'**
  String get completeReasonPlaceholder;

  /// No description provided for @completeSnapshotTitle.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan akhir disimpan'**
  String get completeSnapshotTitle;

  /// No description provided for @completeSnapshotBody.
  ///
  /// In id, this message translates to:
  /// **'Hari aktif dan catatan yang tersedia diarsipkan tanpa mengubah log makan.'**
  String get completeSnapshotBody;

  /// No description provided for @completeFinalityNote.
  ///
  /// In id, this message translates to:
  /// **'Program yang selesai tidak dapat dilanjutkan. Kamu bisa memulai program baru.'**
  String get completeFinalityNote;

  /// No description provided for @completeCancelAction.
  ///
  /// In id, this message translates to:
  /// **'Batal, tetap di program ini'**
  String get completeCancelAction;

  /// No description provided for @completeConfirmAction.
  ///
  /// In id, this message translates to:
  /// **'Ya, selesaikan program'**
  String get completeConfirmAction;

  /// No description provided for @completeReasonGoalReached.
  ///
  /// In id, this message translates to:
  /// **'Saya sudah mencapai tujuan'**
  String get completeReasonGoalReached;

  /// No description provided for @completeReasonSwitchingProgram.
  ///
  /// In id, this message translates to:
  /// **'Saya ingin mencoba program lain'**
  String get completeReasonSwitchingProgram;

  /// No description provided for @completeReasonTakingABreak.
  ///
  /// In id, this message translates to:
  /// **'Saya ingin berhenti sementara'**
  String get completeReasonTakingABreak;

  /// No description provided for @completeReasonOther.
  ///
  /// In id, this message translates to:
  /// **'Alasan lain'**
  String get completeReasonOther;

  /// No description provided for @historyProgramContextLabel.
  ///
  /// In id, this message translates to:
  /// **'PROGRAM SAYA'**
  String get historyProgramContextLabel;

  /// No description provided for @historyProgramTitle.
  ///
  /// In id, this message translates to:
  /// **'Riwayat program'**
  String get historyProgramTitle;

  /// No description provided for @historyProgramSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Target lama tetap dapat dijelaskan.'**
  String get historyProgramSubtitle;

  /// No description provided for @historyProgramErrorTitle.
  ///
  /// In id, this message translates to:
  /// **'Riwayat tidak bisa dimuat'**
  String get historyProgramErrorTitle;

  /// No description provided for @historyProgramErrorBody.
  ///
  /// In id, this message translates to:
  /// **'Terjadi kendala saat membaca riwayat program. Catatanmu tidak berubah.'**
  String get historyProgramErrorBody;

  /// No description provided for @historyProgramEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada riwayat'**
  String get historyProgramEmptyTitle;

  /// No description provided for @historyProgramEmptyBody.
  ///
  /// In id, this message translates to:
  /// **'Program yang pernah kamu jalani akan muncul di sini.'**
  String get historyProgramEmptyBody;

  /// No description provided for @historyProgramNoteTitle.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada catatan yang hilang'**
  String get historyProgramNoteTitle;

  /// No description provided for @historyProgramNoteBody.
  ///
  /// In id, this message translates to:
  /// **'Riwayat program tidak mengubah catatan makanan dan berat yang pernah kamu simpan.'**
  String get historyProgramNoteBody;

  /// No description provided for @historyProgramEntryExtra.
  ///
  /// In id, this message translates to:
  /// **'Lihat target, input, dan alasan perubahan'**
  String get historyProgramEntryExtra;

  /// Rentang tanggal entri riwayat yang masih berjalan.
  ///
  /// In id, this message translates to:
  /// **'Aktif · sejak {start}'**
  String historyProgramRangeRunning(String start);

  /// Rentang tanggal entri riwayat yang sudah berakhir.
  ///
  /// In id, this message translates to:
  /// **'{start} – {end}'**
  String historyProgramRangeEnded(String start, String end);

  /// No description provided for @historyProgramStateDraft.
  ///
  /// In id, this message translates to:
  /// **'Draf'**
  String get historyProgramStateDraft;

  /// No description provided for @historyProgramStateActive.
  ///
  /// In id, this message translates to:
  /// **'Aktif'**
  String get historyProgramStateActive;

  /// No description provided for @historyProgramStatePaused.
  ///
  /// In id, this message translates to:
  /// **'Dijeda'**
  String get historyProgramStatePaused;

  /// No description provided for @historyProgramStateCompleted.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get historyProgramStateCompleted;

  /// No description provided for @historyProgramStateChanged.
  ///
  /// In id, this message translates to:
  /// **'Diganti'**
  String get historyProgramStateChanged;

  /// No description provided for @historyProgramStateCancelled.
  ///
  /// In id, this message translates to:
  /// **'Dibatalkan'**
  String get historyProgramStateCancelled;

  /// No description provided for @historyDetailContextLabel.
  ///
  /// In id, this message translates to:
  /// **'RIWAYAT'**
  String get historyDetailContextLabel;

  /// No description provided for @historyDetailTargetEyebrow.
  ///
  /// In id, this message translates to:
  /// **'TARGET YANG DISETUJUI SAAT ITU'**
  String get historyDetailTargetEyebrow;

  /// No description provided for @historyDetailTargetCaption.
  ///
  /// In id, this message translates to:
  /// **'Perkiraan · tidak berubah karena target baru.'**
  String get historyDetailTargetCaption;

  /// No description provided for @historyDetailFactsHeading.
  ///
  /// In id, this message translates to:
  /// **'Rincian program'**
  String get historyDetailFactsHeading;

  /// No description provided for @historyDetailStatusLabel.
  ///
  /// In id, this message translates to:
  /// **'Status'**
  String get historyDetailStatusLabel;

  /// No description provided for @historyDetailStartingWeightLabel.
  ///
  /// In id, this message translates to:
  /// **'Berat awal'**
  String get historyDetailStartingWeightLabel;

  /// No description provided for @historyDetailLatestWeightLabel.
  ///
  /// In id, this message translates to:
  /// **'Berat terbaru'**
  String get historyDetailLatestWeightLabel;

  /// No description provided for @historyDetailNoDataOnLastDay.
  ///
  /// In id, this message translates to:
  /// **'Belum ada data di hari terakhir'**
  String get historyDetailNoDataOnLastDay;

  /// No description provided for @historyDetailTargetWeightLabel.
  ///
  /// In id, this message translates to:
  /// **'Target berat'**
  String get historyDetailTargetWeightLabel;

  /// No description provided for @historyDetailTargetWeightNotRequired.
  ///
  /// In id, this message translates to:
  /// **'Tidak diwajibkan'**
  String get historyDetailTargetWeightNotRequired;

  /// No description provided for @historyDetailEndReasonLabel.
  ///
  /// In id, this message translates to:
  /// **'Alasan selesai'**
  String get historyDetailEndReasonLabel;

  /// No description provided for @historyDetailEndReasonChanged.
  ///
  /// In id, this message translates to:
  /// **'Diganti dengan program baru'**
  String get historyDetailEndReasonChanged;

  /// No description provided for @historyDetailEndReasonNotEnded.
  ///
  /// In id, this message translates to:
  /// **'Belum berakhir'**
  String get historyDetailEndReasonNotEnded;

  /// No description provided for @historyDetailEndReasonUnknown.
  ///
  /// In id, this message translates to:
  /// **'Tidak tercatat'**
  String get historyDetailEndReasonUnknown;

  /// No description provided for @historyDetailNote.
  ///
  /// In id, this message translates to:
  /// **'Input, target, dan versi asli disimpan untuk penjelasan riwayat.'**
  String get historyDetailNote;

  /// No description provided for @revisionComparisonHeading.
  ///
  /// In id, this message translates to:
  /// **'Dibandingkan dengan target sekarang'**
  String get revisionComparisonHeading;

  /// No description provided for @revisionComparisonCurrentLabel.
  ///
  /// In id, this message translates to:
  /// **'Target sekarang'**
  String get revisionComparisonCurrentLabel;

  /// No description provided for @revisionComparisonNewLabel.
  ///
  /// In id, this message translates to:
  /// **'Target baru'**
  String get revisionComparisonNewLabel;

  /// No description provided for @revisionCancelNoteChange.
  ///
  /// In id, this message translates to:
  /// **'Batal? Program aktif tidak berubah.'**
  String get revisionCancelNoteChange;

  /// No description provided for @revisionCancelNoteProfile.
  ///
  /// In id, this message translates to:
  /// **'Belum disetujui? Target yang berjalan tetap berlaku.'**
  String get revisionCancelNoteProfile;

  /// No description provided for @revisionFailedMessage.
  ///
  /// In id, this message translates to:
  /// **'Perubahan belum bisa disimpan. Programmu yang berjalan tidak berubah.'**
  String get revisionFailedMessage;

  /// No description provided for @revisionRejectedContextLabel.
  ///
  /// In id, this message translates to:
  /// **'STATUS · TARGET TIDAK DIBUAT'**
  String get revisionRejectedContextLabel;

  /// No description provided for @revisionRejectedTitle.
  ///
  /// In id, this message translates to:
  /// **'Target tidak dibuat'**
  String get revisionRejectedTitle;

  /// No description provided for @revisionRejectedNoChangeNote.
  ///
  /// In id, this message translates to:
  /// **'Program dan target yang berjalan tidak berubah.'**
  String get revisionRejectedNoChangeNote;

  /// No description provided for @changeContextLabel.
  ///
  /// In id, this message translates to:
  /// **'GANTI PROGRAM'**
  String get changeContextLabel;

  /// No description provided for @changeTitle.
  ///
  /// In id, this message translates to:
  /// **'Sebelum kamu berganti'**
  String get changeTitle;

  /// No description provided for @changeSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Program saat ini akan dipindahkan ke riwayat.'**
  String get changeSubtitle;

  /// No description provided for @changeCurrentProgramEyebrow.
  ///
  /// In id, this message translates to:
  /// **'PROGRAM SEKARANG'**
  String get changeCurrentProgramEyebrow;

  /// No description provided for @changeReplacementEyebrow.
  ///
  /// In id, this message translates to:
  /// **'PROGRAM BARU · PRATINJAU'**
  String get changeReplacementEyebrow;

  /// No description provided for @changeReplacementDescription.
  ///
  /// In id, this message translates to:
  /// **'Nilai dan asumsi target ditinjau sebelum disetujui.'**
  String get changeReplacementDescription;

  /// No description provided for @changeHistoryNoteTitle.
  ///
  /// In id, this message translates to:
  /// **'Riwayatmu tetap utuh'**
  String get changeHistoryNoteTitle;

  /// No description provided for @changeHistoryNoteBody.
  ///
  /// In id, this message translates to:
  /// **'Catatan makanan, berat, dan target lama tidak dihapus atau ditulis ulang.'**
  String get changeHistoryNoteBody;

  /// No description provided for @changeCancelFootnote.
  ///
  /// In id, this message translates to:
  /// **'Batal? Program aktif tidak berubah.'**
  String get changeCancelFootnote;

  /// No description provided for @changeReviewAction.
  ///
  /// In id, this message translates to:
  /// **'Tinjau target pengganti'**
  String get changeReviewAction;

  /// No description provided for @changePickReplacementTitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih program pengganti'**
  String get changePickReplacementTitle;

  /// No description provided for @changePickReplacementSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Kamu bisa menggantinya lagi nanti.'**
  String get changePickReplacementSubtitle;

  /// No description provided for @changeHabitFocusHeading.
  ///
  /// In id, this message translates to:
  /// **'Fokus kebiasaan'**
  String get changeHabitFocusHeading;

  /// No description provided for @changeReviewReplacementAction.
  ///
  /// In id, this message translates to:
  /// **'Tinjau target pengganti'**
  String get changeReviewReplacementAction;

  /// No description provided for @editProfileContextLabel.
  ///
  /// In id, this message translates to:
  /// **'PROFIL'**
  String get editProfileContextLabel;

  /// No description provided for @editProfileTitle.
  ///
  /// In id, this message translates to:
  /// **'Ubah data profil'**
  String get editProfileTitle;

  /// No description provided for @editProfileSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Perubahan tidak menulis ulang target lama.'**
  String get editProfileSubtitle;

  /// No description provided for @editProfileHeightLabel.
  ///
  /// In id, this message translates to:
  /// **'Tinggi badan'**
  String get editProfileHeightLabel;

  /// No description provided for @editProfileWeightLabel.
  ///
  /// In id, this message translates to:
  /// **'Berat saat ini'**
  String get editProfileWeightLabel;

  /// No description provided for @editProfileActivityLabel.
  ///
  /// In id, this message translates to:
  /// **'Aktivitas'**
  String get editProfileActivityLabel;

  /// No description provided for @editProfileUnitsLabel.
  ///
  /// In id, this message translates to:
  /// **'Satuan'**
  String get editProfileUnitsLabel;

  /// No description provided for @editProfileUnitsValue.
  ///
  /// In id, this message translates to:
  /// **'Metrik · kg, cm'**
  String get editProfileUnitsValue;

  /// No description provided for @editProfileReviewNoteTitle.
  ///
  /// In id, this message translates to:
  /// **'Target perlu ditinjau ulang'**
  String get editProfileReviewNoteTitle;

  /// No description provided for @editProfileReviewNoteBody.
  ///
  /// In id, this message translates to:
  /// **'Profil baru tidak langsung mengubah target aktif. Tinjau perkiraan baru dan setujui revisinya.'**
  String get editProfileReviewNoteBody;

  /// No description provided for @editProfileDialogCancelAction.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get editProfileDialogCancelAction;

  /// No description provided for @editProfileDialogSaveAction.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get editProfileDialogSaveAction;

  /// No description provided for @editProfileReviewAction.
  ///
  /// In id, this message translates to:
  /// **'Tinjau target baru'**
  String get editProfileReviewAction;

  /// No description provided for @profileSettingsHeading.
  ///
  /// In id, this message translates to:
  /// **'Akun & program'**
  String get profileSettingsHeading;

  /// No description provided for @profileEditAction.
  ///
  /// In id, this message translates to:
  /// **'Ubah profil'**
  String get profileEditAction;

  /// No description provided for @profileUnitsLanguageAction.
  ///
  /// In id, this message translates to:
  /// **'Bahasa & tampilan'**
  String get profileUnitsLanguageAction;

  /// No description provided for @profilePrivacyAction.
  ///
  /// In id, this message translates to:
  /// **'Privasi & data lokal'**
  String get profilePrivacyAction;

  /// No description provided for @profileAboutAction.
  ///
  /// In id, this message translates to:
  /// **'Tentang Mealora'**
  String get profileAboutAction;

  /// No description provided for @mealTimeBreakfast.
  ///
  /// In id, this message translates to:
  /// **'Sarapan'**
  String get mealTimeBreakfast;

  /// No description provided for @mealTimeLunch.
  ///
  /// In id, this message translates to:
  /// **'Makan siang'**
  String get mealTimeLunch;

  /// No description provided for @mealTimeSnack.
  ///
  /// In id, this message translates to:
  /// **'Camilan'**
  String get mealTimeSnack;

  /// No description provided for @mealTimeDinner.
  ///
  /// In id, this message translates to:
  /// **'Makan malam'**
  String get mealTimeDinner;

  /// No description provided for @nutrientEnergy.
  ///
  /// In id, this message translates to:
  /// **'Energi'**
  String get nutrientEnergy;

  /// No description provided for @nutrientProtein.
  ///
  /// In id, this message translates to:
  /// **'Protein'**
  String get nutrientProtein;

  /// No description provided for @nutrientCarbohydrate.
  ///
  /// In id, this message translates to:
  /// **'Karbohidrat'**
  String get nutrientCarbohydrate;

  /// No description provided for @nutrientFiber.
  ///
  /// In id, this message translates to:
  /// **'Serat'**
  String get nutrientFiber;

  /// No description provided for @nutrientSugar.
  ///
  /// In id, this message translates to:
  /// **'Gula'**
  String get nutrientSugar;

  /// No description provided for @nutrientSodium.
  ///
  /// In id, this message translates to:
  /// **'Natrium'**
  String get nutrientSodium;

  /// No description provided for @nutrientFat.
  ///
  /// In id, this message translates to:
  /// **'Lemak'**
  String get nutrientFat;

  /// Ringkasan tiga makro pada kartu perkiraan.
  ///
  /// In id, this message translates to:
  /// **'P {protein} · K {carb} · L {fat}'**
  String macroMacrosShort(String protein, String carb, String fat);

  /// No description provided for @nutrientValueUnknown.
  ///
  /// In id, this message translates to:
  /// **'–'**
  String get nutrientValueUnknown;

  /// No description provided for @addFoodSheetTitle.
  ///
  /// In id, this message translates to:
  /// **'Catat makanan'**
  String get addFoodSheetTitle;

  /// No description provided for @addFoodSheetSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih cara yang paling nyaman untukmu'**
  String get addFoodSheetSubtitle;

  /// No description provided for @addFoodSearchTitle.
  ///
  /// In id, this message translates to:
  /// **'Cari / input manual'**
  String get addFoodSearchTitle;

  /// No description provided for @addFoodSearchDescription.
  ///
  /// In id, this message translates to:
  /// **'Selalu bisa, bahkan tanpa internet'**
  String get addFoodSearchDescription;

  /// No description provided for @addFoodVoiceTitle.
  ///
  /// In id, this message translates to:
  /// **'Catat dengan suara'**
  String get addFoodVoiceTitle;

  /// No description provided for @addFoodVoiceDescription.
  ///
  /// In id, this message translates to:
  /// **'Sebutkan saja yang kamu makan'**
  String get addFoodVoiceDescription;

  /// No description provided for @addFoodPhotoTitle.
  ///
  /// In id, this message translates to:
  /// **'Foto makanan'**
  String get addFoodPhotoTitle;

  /// No description provided for @addFoodPhotoDescription.
  ///
  /// In id, this message translates to:
  /// **'Dapatkan saran dari fotomu'**
  String get addFoodPhotoDescription;

  /// No description provided for @addFoodBarcodeTitle.
  ///
  /// In id, this message translates to:
  /// **'Scan barcode'**
  String get addFoodBarcodeTitle;

  /// No description provided for @addFoodBarcodeDescription.
  ///
  /// In id, this message translates to:
  /// **'Cari produk kemasan dengan cepat'**
  String get addFoodBarcodeDescription;

  /// No description provided for @addFoodPrivacyLine1.
  ///
  /// In id, this message translates to:
  /// **'Foto hanya diunggah dengan izinmu.'**
  String get addFoodPrivacyLine1;

  /// No description provided for @addFoodPrivacyLine2.
  ///
  /// In id, this message translates to:
  /// **'Suara & input manual jalan tanpa internet.'**
  String get addFoodPrivacyLine2;

  /// No description provided for @addFoodPathUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Jalur ini belum tersedia. Pakai pencarian atau buat makanan sendiri dulu, ya.'**
  String get addFoodPathUnavailable;

  /// No description provided for @foodSearchContextLabel.
  ///
  /// In id, this message translates to:
  /// **'CATAT MAKANAN'**
  String get foodSearchContextLabel;

  /// No description provided for @foodSearchTitle.
  ///
  /// In id, this message translates to:
  /// **'Cari makanan'**
  String get foodSearchTitle;

  /// No description provided for @foodSearchSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Katalog lokal · tersedia tanpa internet'**
  String get foodSearchSubtitle;

  /// No description provided for @foodSearchHint.
  ///
  /// In id, this message translates to:
  /// **'Cari nama makanan…'**
  String get foodSearchHint;

  /// No description provided for @foodSearchClearSemantics.
  ///
  /// In id, this message translates to:
  /// **'Hapus pencarian'**
  String get foodSearchClearSemantics;

  /// No description provided for @foodSearchRecentHeading.
  ///
  /// In id, this message translates to:
  /// **'Terakhir dicatat'**
  String get foodSearchRecentHeading;

  /// No description provided for @foodSearchResultsHeading.
  ///
  /// In id, this message translates to:
  /// **'Hasil \"{query}\"'**
  String foodSearchResultsHeading(String query);

  /// No description provided for @foodSearchNoResultsTitle.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada hasil'**
  String get foodSearchNoResultsTitle;

  /// No description provided for @foodSearchNoResultsBody.
  ///
  /// In id, this message translates to:
  /// **'Makanan ini belum ada di katalog. Kamu bisa membuatnya sendiri.'**
  String get foodSearchNoResultsBody;

  /// No description provided for @foodSearchCreateLink.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada?  + Buat makanan sendiri'**
  String get foodSearchCreateLink;

  /// No description provided for @foodSearchFavoritesLabel.
  ///
  /// In id, this message translates to:
  /// **'Favorit'**
  String get foodSearchFavoritesLabel;

  /// No description provided for @foodSearchFavoritesUnavailable.
  ///
  /// In id, this message translates to:
  /// **'Favorit belum tersedia pada versi ini.'**
  String get foodSearchFavoritesUnavailable;

  /// No description provided for @foodSearchCatalogDataLabel.
  ///
  /// In id, this message translates to:
  /// **'data katalog'**
  String get foodSearchCatalogDataLabel;

  /// No description provided for @foodSearchCustomDataLabel.
  ///
  /// In id, this message translates to:
  /// **'buatan sendiri'**
  String get foodSearchCustomDataLabel;

  /// No description provided for @foodSearchApproxPerServing.
  ///
  /// In id, this message translates to:
  /// **'± {kcal} / {serving}'**
  String foodSearchApproxPerServing(String kcal, String serving);

  /// No description provided for @servingDetailContextLabel.
  ///
  /// In id, this message translates to:
  /// **'TAMBAH KE BUKU HARIAN'**
  String get servingDetailContextLabel;

  /// No description provided for @servingDetailSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih sajian, jumlah, dan waktu makan.'**
  String get servingDetailSubtitle;

  /// No description provided for @servingDetailSourceCatalog.
  ///
  /// In id, this message translates to:
  /// **'Katalog lokal'**
  String get servingDetailSourceCatalog;

  /// No description provided for @servingDetailSourceCustom.
  ///
  /// In id, this message translates to:
  /// **'Buatan sendiri'**
  String get servingDetailSourceCustom;

  /// No description provided for @servingDetailServingLabel.
  ///
  /// In id, this message translates to:
  /// **'Sajian'**
  String get servingDetailServingLabel;

  /// No description provided for @servingDetailQuantityLabel.
  ///
  /// In id, this message translates to:
  /// **'Jumlah sajian'**
  String get servingDetailQuantityLabel;

  /// No description provided for @servingDetailMealTimeLabel.
  ///
  /// In id, this message translates to:
  /// **'Waktu makan'**
  String get servingDetailMealTimeLabel;

  /// No description provided for @servingDetailEstimateLabel.
  ///
  /// In id, this message translates to:
  /// **'PERKIRAAN'**
  String get servingDetailEstimateLabel;

  /// No description provided for @servingDetailAddAction.
  ///
  /// In id, this message translates to:
  /// **'Tambahkan ke {mealTime}'**
  String servingDetailAddAction(String mealTime);

  /// No description provided for @servingPickerTitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih sajian'**
  String get servingPickerTitle;

  /// No description provided for @mealTimePickerTitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih waktu makan'**
  String get mealTimePickerTitle;

  /// No description provided for @servingEstimateBadge.
  ///
  /// In id, this message translates to:
  /// **'perkiraan'**
  String get servingEstimateBadge;

  /// No description provided for @servingEstimateSemantics.
  ///
  /// In id, this message translates to:
  /// **'Berat takaran ini perkiraan'**
  String get servingEstimateSemantics;

  /// No description provided for @servingPickerSubtitle.
  ///
  /// In id, this message translates to:
  /// **'{food} · berat setiap takaran ditampilkan'**
  String servingPickerSubtitle(String food);

  /// No description provided for @servingPickerDefaultTag.
  ///
  /// In id, this message translates to:
  /// **'Bawaan'**
  String get servingPickerDefaultTag;

  /// No description provided for @servingPickerDirectWeight.
  ///
  /// In id, this message translates to:
  /// **'berat langsung'**
  String get servingPickerDirectWeight;

  /// No description provided for @servingPickerApproxWeight.
  ///
  /// In id, this message translates to:
  /// **'≈ {weight}'**
  String servingPickerApproxWeight(String weight);

  /// No description provided for @servingPickerDerivedNote.
  ///
  /// In id, this message translates to:
  /// **'dihitung dari data terukur'**
  String get servingPickerDerivedNote;

  /// No description provided for @servingPickerWeightEntry.
  ///
  /// In id, this message translates to:
  /// **'Masukkan berat sendiri ({unit})'**
  String servingPickerWeightEntry(String unit);

  /// No description provided for @servingPickerEstimateHint.
  ///
  /// In id, this message translates to:
  /// **'\"Perkiraan\" berarti berat takaran diperkirakan dari ukuran umum, belum dari penimbangan resmi. Nilai gizi per 100 g tetap dari TKPI.'**
  String get servingPickerEstimateHint;

  /// No description provided for @servingDetailWeightServing.
  ///
  /// In id, this message translates to:
  /// **'Berat sendiri ({unit})'**
  String servingDetailWeightServing(String unit);

  /// No description provided for @servingDetailWeightLabel.
  ///
  /// In id, this message translates to:
  /// **'Berat yang dimakan'**
  String get servingDetailWeightLabel;

  /// No description provided for @servingDetailUseServingAction.
  ///
  /// In id, this message translates to:
  /// **'Pakai takaran'**
  String get servingDetailUseServingAction;

  /// No description provided for @servingDetailWeightInvalid.
  ///
  /// In id, this message translates to:
  /// **'Berat harus lebih dari 0 {unit}. Catatan belum disimpan.'**
  String servingDetailWeightInvalid(String unit);

  /// No description provided for @quantityDecreaseSemantics.
  ///
  /// In id, this message translates to:
  /// **'Kurangi jumlah'**
  String get quantityDecreaseSemantics;

  /// No description provided for @quantityIncreaseSemantics.
  ///
  /// In id, this message translates to:
  /// **'Tambah jumlah'**
  String get quantityIncreaseSemantics;

  /// No description provided for @customFoodContextLabel.
  ///
  /// In id, this message translates to:
  /// **'KATALOG PRIBADI'**
  String get customFoodContextLabel;

  /// No description provided for @customFoodTitle.
  ///
  /// In id, this message translates to:
  /// **'Buat makanan'**
  String get customFoodTitle;

  /// No description provided for @customFoodSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Masukkan nilai dari sumber yang kamu percaya.'**
  String get customFoodSubtitle;

  /// No description provided for @customFoodNameLabel.
  ///
  /// In id, this message translates to:
  /// **'Nama makanan'**
  String get customFoodNameLabel;

  /// No description provided for @customFoodNameHint.
  ///
  /// In id, this message translates to:
  /// **'mis. Tumis buncis rumahan'**
  String get customFoodNameHint;

  /// No description provided for @customFoodServingLabel.
  ///
  /// In id, this message translates to:
  /// **'Ukuran sajian'**
  String get customFoodServingLabel;

  /// No description provided for @customFoodServingHint.
  ///
  /// In id, this message translates to:
  /// **'mis. 1 porsi · 180 g'**
  String get customFoodServingHint;

  /// No description provided for @customFoodNutritionHeading.
  ///
  /// In id, this message translates to:
  /// **'Nutrisi per sajian'**
  String get customFoodNutritionHeading;

  /// No description provided for @customFoodNote.
  ///
  /// In id, this message translates to:
  /// **'Periksa nilai dan satuannya. Angka yang belum diketahui jangan diisi nol.'**
  String get customFoodNote;

  /// No description provided for @customFoodSaveAction.
  ///
  /// In id, this message translates to:
  /// **'Simpan makanan'**
  String get customFoodSaveAction;

  /// No description provided for @customFoodNameRequiredError.
  ///
  /// In id, this message translates to:
  /// **'Nama makanan tidak boleh kosong.'**
  String get customFoodNameRequiredError;

  /// No description provided for @customFoodServingRequiredError.
  ///
  /// In id, this message translates to:
  /// **'Ukuran sajian tidak boleh kosong.'**
  String get customFoodServingRequiredError;

  /// No description provided for @customFoodNegativeValueError.
  ///
  /// In id, this message translates to:
  /// **'Nilai gizi tidak boleh negatif.'**
  String get customFoodNegativeValueError;

  /// No description provided for @barcodeScanContextLabel.
  ///
  /// In id, this message translates to:
  /// **'PRODUK KEMASAN'**
  String get barcodeScanContextLabel;

  /// No description provided for @barcodeScanTitle.
  ///
  /// In id, this message translates to:
  /// **'Pindai barcode'**
  String get barcodeScanTitle;

  /// No description provided for @barcodeScanSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Arahkan kode pada kemasan ke bingkai.'**
  String get barcodeScanSubtitle;

  /// No description provided for @barcodeScanHint.
  ///
  /// In id, this message translates to:
  /// **'Posisikan barcode di tengah'**
  String get barcodeScanHint;

  /// No description provided for @barcodeScanNoteTitle.
  ///
  /// In id, this message translates to:
  /// **'Produk tersimpan bisa dicari offline'**
  String get barcodeScanNoteTitle;

  /// No description provided for @barcodeScanNoteBody.
  ///
  /// In id, this message translates to:
  /// **'Barcode bukan sumber nilai nutrisi.'**
  String get barcodeScanNoteBody;

  /// No description provided for @barcodeScanAlternativesHeading.
  ///
  /// In id, this message translates to:
  /// **'Tidak bisa memindai?'**
  String get barcodeScanAlternativesHeading;

  /// No description provided for @barcodeScanManualLink.
  ///
  /// In id, this message translates to:
  /// **'Masukkan barcode manual'**
  String get barcodeScanManualLink;

  /// No description provided for @barcodeScanManualDescription.
  ///
  /// In id, this message translates to:
  /// **'Ketik nomor yang tertera di kemasan'**
  String get barcodeScanManualDescription;

  /// No description provided for @barcodeScanPhotoLabelLink.
  ///
  /// In id, this message translates to:
  /// **'Foto Info Gizi'**
  String get barcodeScanPhotoLabelLink;

  /// No description provided for @barcodeScanPhotoLabelDescription.
  ///
  /// In id, this message translates to:
  /// **'Baca nilai nutrisi dari foto label'**
  String get barcodeScanPhotoLabelDescription;

  /// No description provided for @barcodeScanUseCamera.
  ///
  /// In id, this message translates to:
  /// **'Gunakan kamera'**
  String get barcodeScanUseCamera;

  /// No description provided for @barcodeScanSlowHint.
  ///
  /// In id, this message translates to:
  /// **'Kode belum terbaca? Ketik nomor secara manual.'**
  String get barcodeScanSlowHint;

  /// No description provided for @barcodeScanPermissionDeniedTitle.
  ///
  /// In id, this message translates to:
  /// **'Izin kamera ditolak'**
  String get barcodeScanPermissionDeniedTitle;

  /// No description provided for @barcodeScanPermissionDeniedBody.
  ///
  /// In id, this message translates to:
  /// **'Mealora memakai kamera hanya untuk memindai barcode kemasan. Kamu tetap bisa mencatat produk tanpa kamera.'**
  String get barcodeScanPermissionDeniedBody;

  /// No description provided for @barcodeScanUnavailableTitle.
  ///
  /// In id, this message translates to:
  /// **'Pemindaian tidak tersedia'**
  String get barcodeScanUnavailableTitle;

  /// No description provided for @barcodeScanUnavailableBody.
  ///
  /// In id, this message translates to:
  /// **'Lingkungan ini tidak mendukung kamera. Masukkan nomor barcode secara manual, atau cari di katalog.'**
  String get barcodeScanUnavailableBody;

  /// No description provided for @barcodeScanManualAction.
  ///
  /// In id, this message translates to:
  /// **'Masukkan nomor manual'**
  String get barcodeScanManualAction;

  /// No description provided for @barcodeScanSearchCatalogAction.
  ///
  /// In id, this message translates to:
  /// **'Cari di katalog'**
  String get barcodeScanSearchCatalogAction;

  /// No description provided for @barcodeScanLookupInProgress.
  ///
  /// In id, this message translates to:
  /// **'Mencari produk…'**
  String get barcodeScanLookupInProgress;

  /// No description provided for @barcodeManualContextLabel.
  ///
  /// In id, this message translates to:
  /// **'MASUKKAN MANUAL'**
  String get barcodeManualContextLabel;

  /// No description provided for @barcodeManualTitle.
  ///
  /// In id, this message translates to:
  /// **'Masukkan nomor barcode'**
  String get barcodeManualTitle;

  /// No description provided for @barcodeManualSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Ketik nomor yang tertera di kemasan.'**
  String get barcodeManualSubtitle;

  /// No description provided for @barcodeManualFieldLabel.
  ///
  /// In id, this message translates to:
  /// **'NOMOR BARCODE'**
  String get barcodeManualFieldLabel;

  /// No description provided for @barcodeManualFieldHint.
  ///
  /// In id, this message translates to:
  /// **'mis. 8991234567890'**
  String get barcodeManualFieldHint;

  /// No description provided for @barcodeManualHelper.
  ///
  /// In id, this message translates to:
  /// **'8–14 digit, sesuai EAN/UPC pada kemasan'**
  String get barcodeManualHelper;

  /// No description provided for @barcodeManualInvalidError.
  ///
  /// In id, this message translates to:
  /// **'Nomor harus 8–14 digit angka — periksa kembali kemasan.'**
  String get barcodeManualInvalidError;

  /// No description provided for @barcodeManualNoteTitle.
  ///
  /// In id, this message translates to:
  /// **'Tersedia tanpa kamera dan tanpa koneksi'**
  String get barcodeManualNoteTitle;

  /// No description provided for @barcodeManualNoteBody.
  ///
  /// In id, this message translates to:
  /// **'Pencarian produk tersimpan tetap bekerja di mode pesawat.'**
  String get barcodeManualNoteBody;

  /// No description provided for @barcodeManualSearchAction.
  ///
  /// In id, this message translates to:
  /// **'Cari produk'**
  String get barcodeManualSearchAction;

  /// No description provided for @packagedFoodNotFoundContextLabel.
  ///
  /// In id, this message translates to:
  /// **'HASIL PEMINDAIAN'**
  String get packagedFoodNotFoundContextLabel;

  /// No description provided for @packagedFoodNotFoundTitle.
  ///
  /// In id, this message translates to:
  /// **'Produk belum ditemukan'**
  String get packagedFoodNotFoundTitle;

  /// No description provided for @packagedFoodNotFoundSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Barcode: {barcode}'**
  String packagedFoodNotFoundSubtitle(String barcode);

  /// No description provided for @packagedFoodNotFoundHeading.
  ///
  /// In id, this message translates to:
  /// **'Belum ada di katalog lokal'**
  String get packagedFoodNotFoundHeading;

  /// No description provided for @packagedFoodNotFoundBody.
  ///
  /// In id, this message translates to:
  /// **'Kamu tetap bisa mencatatnya. Foto label gizi untuk mengekstrak data, atau isi nilai dari kemasan secara manual.'**
  String get packagedFoodNotFoundBody;

  /// No description provided for @packagedFoodNotFoundManualTitle.
  ///
  /// In id, this message translates to:
  /// **'Isi nilai secara manual'**
  String get packagedFoodNotFoundManualTitle;

  /// No description provided for @packagedFoodNotFoundManualDescription.
  ///
  /// In id, this message translates to:
  /// **'Tersedia sepenuhnya offline'**
  String get packagedFoodNotFoundManualDescription;

  /// No description provided for @packagedFoodNotFoundPhotoTitle.
  ///
  /// In id, this message translates to:
  /// **'Foto label gizi'**
  String get packagedFoodNotFoundPhotoTitle;

  /// No description provided for @packagedFoodNotFoundPhotoDescription.
  ///
  /// In id, this message translates to:
  /// **'Butuh internet dan izin unggah'**
  String get packagedFoodNotFoundPhotoDescription;

  /// No description provided for @packagedFoodFillContextLabel.
  ///
  /// In id, this message translates to:
  /// **'TANPA INTERNET'**
  String get packagedFoodFillContextLabel;

  /// No description provided for @packagedFoodFillTitle.
  ///
  /// In id, this message translates to:
  /// **'Isi label secara manual'**
  String get packagedFoodFillTitle;

  /// No description provided for @packagedFoodFillSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Salin nilai dari kemasan, lalu periksa satuan.'**
  String get packagedFoodFillSubtitle;

  /// No description provided for @packagedFoodFillBasisLabel.
  ///
  /// In id, this message translates to:
  /// **'DASAR NILAI PADA KEMASAN'**
  String get packagedFoodFillBasisLabel;

  /// No description provided for @packagedFoodFillBasisPerServing.
  ///
  /// In id, this message translates to:
  /// **'Per sajian'**
  String get packagedFoodFillBasisPerServing;

  /// No description provided for @packagedFoodFillBasisPer100g.
  ///
  /// In id, this message translates to:
  /// **'Per 100 g'**
  String get packagedFoodFillBasisPer100g;

  /// No description provided for @packagedFoodFillNameLabel.
  ///
  /// In id, this message translates to:
  /// **'Nama produk'**
  String get packagedFoodFillNameLabel;

  /// No description provided for @packagedFoodFillNameHint.
  ///
  /// In id, this message translates to:
  /// **'mis. Keripik Singkong Renyah'**
  String get packagedFoodFillNameHint;

  /// No description provided for @packagedFoodFillBrandLabel.
  ///
  /// In id, this message translates to:
  /// **'Merek (opsional)'**
  String get packagedFoodFillBrandLabel;

  /// No description provided for @packagedFoodFillBrandHint.
  ///
  /// In id, this message translates to:
  /// **'mis. MerekA'**
  String get packagedFoodFillBrandHint;

  /// No description provided for @packagedFoodFillPackageSizeLabel.
  ///
  /// In id, this message translates to:
  /// **'Ukuran kemasan (opsional)'**
  String get packagedFoodFillPackageSizeLabel;

  /// No description provided for @packagedFoodFillPackageSizeHint.
  ///
  /// In id, this message translates to:
  /// **'mis. 60 g'**
  String get packagedFoodFillPackageSizeHint;

  /// No description provided for @packagedFoodFillUnitsPerPackageLabel.
  ///
  /// In id, this message translates to:
  /// **'Sajian per kemasan (opsional)'**
  String get packagedFoodFillUnitsPerPackageLabel;

  /// No description provided for @packagedFoodFillUnitsPerPackageHint.
  ///
  /// In id, this message translates to:
  /// **'mis. 2'**
  String get packagedFoodFillUnitsPerPackageHint;

  /// No description provided for @packagedFoodFillContinueAction.
  ///
  /// In id, this message translates to:
  /// **'Tinjau sebelum mencatat'**
  String get packagedFoodFillContinueAction;

  /// No description provided for @packagedFoodFillNameRequiredError.
  ///
  /// In id, this message translates to:
  /// **'Nama produk tidak boleh kosong.'**
  String get packagedFoodFillNameRequiredError;

  /// No description provided for @packagedFoodFillInvalidNumberError.
  ///
  /// In id, this message translates to:
  /// **'Bukan angka yang sah.'**
  String get packagedFoodFillInvalidNumberError;

  /// No description provided for @packagedFoodReviewContextLabel.
  ///
  /// In id, this message translates to:
  /// **'TINJAU PRODUK'**
  String get packagedFoodReviewContextLabel;

  /// No description provided for @packagedFoodReviewTitle.
  ///
  /// In id, this message translates to:
  /// **'Tinjau produk'**
  String get packagedFoodReviewTitle;

  /// No description provided for @packagedFoodReviewSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Cocokkan dengan kemasan di tanganmu'**
  String get packagedFoodReviewSubtitle;

  /// No description provided for @packagedFoodReviewSourceOpenFoodFacts.
  ///
  /// In id, this message translates to:
  /// **'Open Food Facts · barcode'**
  String get packagedFoodReviewSourceOpenFoodFacts;

  /// No description provided for @packagedFoodReviewSourceManual.
  ///
  /// In id, this message translates to:
  /// **'Diisi manual'**
  String get packagedFoodReviewSourceManual;

  /// No description provided for @packagedFoodReviewNutritionHeadingPerServing.
  ///
  /// In id, this message translates to:
  /// **'Nutrisi per 1 sajian'**
  String get packagedFoodReviewNutritionHeadingPerServing;

  /// No description provided for @packagedFoodReviewNutritionHeadingPer100g.
  ///
  /// In id, this message translates to:
  /// **'Nutrisi per 100 g'**
  String get packagedFoodReviewNutritionHeadingPer100g;

  /// No description provided for @packagedFoodReviewServingsOption.
  ///
  /// In id, this message translates to:
  /// **'{count} sajian'**
  String packagedFoodReviewServingsOption(String count);

  /// No description provided for @packagedFoodReviewWholePackageOption.
  ///
  /// In id, this message translates to:
  /// **'1 kemasan · {units} sajian'**
  String packagedFoodReviewWholePackageOption(String units);

  /// No description provided for @packagedFoodReviewGramsLabel.
  ///
  /// In id, this message translates to:
  /// **'Gram yang dimakan'**
  String get packagedFoodReviewGramsLabel;

  /// No description provided for @packagedFoodReviewQuantityHeading.
  ///
  /// In id, this message translates to:
  /// **'Jumlah yang dimakan'**
  String get packagedFoodReviewQuantityHeading;

  /// No description provided for @packagedFoodReviewCorrectionLink.
  ///
  /// In id, this message translates to:
  /// **'Beda dengan kemasanmu?  Koreksi nilai'**
  String get packagedFoodReviewCorrectionLink;

  /// No description provided for @packagedFoodReviewCorrectedBadge.
  ///
  /// In id, this message translates to:
  /// **'Dikoreksi'**
  String get packagedFoodReviewCorrectedBadge;

  /// No description provided for @packagedFoodReviewVerifiedOn.
  ///
  /// In id, this message translates to:
  /// **'Diverifikasi {date}'**
  String packagedFoodReviewVerifiedOn(String date);

  /// No description provided for @packagedFoodReviewConfirmAction.
  ///
  /// In id, this message translates to:
  /// **'Catat · {kcal}'**
  String packagedFoodReviewConfirmAction(String kcal);

  /// No description provided for @diaryEyebrowToday.
  ///
  /// In id, this message translates to:
  /// **'HARI INI'**
  String get diaryEyebrowToday;

  /// No description provided for @diaryTitle.
  ///
  /// In id, this message translates to:
  /// **'Buku harian'**
  String get diaryTitle;

  /// No description provided for @diaryLocalNote.
  ///
  /// In id, this message translates to:
  /// **'catatan di perangkat'**
  String get diaryLocalNote;

  /// No description provided for @diaryRecordedTodayLabel.
  ///
  /// In id, this message translates to:
  /// **'TERCATAT HARI INI'**
  String get diaryRecordedTodayLabel;

  /// No description provided for @diaryTargetLabel.
  ///
  /// In id, this message translates to:
  /// **'Target perkiraan {kcal} kkal'**
  String diaryTargetLabel(String kcal);

  /// No description provided for @diaryTargetPercentCaption.
  ///
  /// In id, this message translates to:
  /// **'target'**
  String get diaryTargetPercentCaption;

  /// No description provided for @diaryPreviousDaySemantics.
  ///
  /// In id, this message translates to:
  /// **'Hari sebelumnya'**
  String get diaryPreviousDaySemantics;

  /// No description provided for @diaryNextDaySemantics.
  ///
  /// In id, this message translates to:
  /// **'Hari berikutnya'**
  String get diaryNextDaySemantics;

  /// No description provided for @diaryUnknownHeading.
  ///
  /// In id, this message translates to:
  /// **'Belum tercatat'**
  String get diaryUnknownHeading;

  /// No description provided for @diaryUnknownBody.
  ///
  /// In id, this message translates to:
  /// **'Kalori dan makro ditampilkan sebagai \"belum diketahui\", bukan 0 kkal atau target yang gagal.'**
  String get diaryUnknownBody;

  /// No description provided for @diaryUnknownConsumptionLabel.
  ///
  /// In id, this message translates to:
  /// **'Konsumsi'**
  String get diaryUnknownConsumptionLabel;

  /// No description provided for @diaryUnknownConsumptionValue.
  ///
  /// In id, this message translates to:
  /// **'Belum diketahui'**
  String get diaryUnknownConsumptionValue;

  /// No description provided for @diaryUnknownMacrosNote.
  ///
  /// In id, this message translates to:
  /// **'Protein, karbo, lemak · belum diketahui'**
  String get diaryUnknownMacrosNote;

  /// No description provided for @diaryEntryMenuSemantics.
  ///
  /// In id, this message translates to:
  /// **'Opsi catatan {food}'**
  String diaryEntryMenuSemantics(String food);

  /// No description provided for @editEntryContextFormat.
  ///
  /// In id, this message translates to:
  /// **'{mealTime} · {date}'**
  String editEntryContextFormat(String mealTime, String date);

  /// No description provided for @editEntryTitle.
  ///
  /// In id, this message translates to:
  /// **'Ubah catatan'**
  String get editEntryTitle;

  /// No description provided for @editEntrySubtitle.
  ///
  /// In id, this message translates to:
  /// **'Perubahan hanya berlaku untuk catatan ini.'**
  String get editEntrySubtitle;

  /// No description provided for @editEntrySnapshotDetail.
  ///
  /// In id, this message translates to:
  /// **'Sajian saat dicatat · {serving}'**
  String editEntrySnapshotDetail(String serving);

  /// No description provided for @editEntryQuantityLabel.
  ///
  /// In id, this message translates to:
  /// **'Jumlah yang dimakan'**
  String get editEntryQuantityLabel;

  /// No description provided for @editEntryUpdatedEstimateLabel.
  ///
  /// In id, this message translates to:
  /// **'Perkiraan setelah diubah'**
  String get editEntryUpdatedEstimateLabel;

  /// No description provided for @editEntryDeleteAction.
  ///
  /// In id, this message translates to:
  /// **'Hapus catatan ini'**
  String get editEntryDeleteAction;

  /// No description provided for @editEntrySaveAction.
  ///
  /// In id, this message translates to:
  /// **'Simpan perubahan'**
  String get editEntrySaveAction;

  /// No description provided for @editEntryDeleteConfirmTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus catatan ini?'**
  String get editEntryDeleteConfirmTitle;

  /// No description provided for @editEntryDeleteConfirmBody.
  ///
  /// In id, this message translates to:
  /// **'Catatan ini akan hilang dari buku harian dan ringkasan harian akan menyesuaikan.'**
  String get editEntryDeleteConfirmBody;

  /// No description provided for @editEntryDeleteConfirmAction.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get editEntryDeleteConfirmAction;

  /// No description provided for @editEntryDeleteCancelAction.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get editEntryDeleteCancelAction;

  /// No description provided for @weightAddTitle.
  ///
  /// In id, this message translates to:
  /// **'Tambah berat'**
  String get weightAddTitle;

  /// No description provided for @weightEditTitle.
  ///
  /// In id, this message translates to:
  /// **'Ubah catatan berat'**
  String get weightEditTitle;

  /// No description provided for @weightAddSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Catat kapan pun, berat selalu terpantau.'**
  String get weightAddSubtitle;

  /// No description provided for @weightValueLabel.
  ///
  /// In id, this message translates to:
  /// **'Berat badan'**
  String get weightValueLabel;

  /// No description provided for @weightUnitKg.
  ///
  /// In id, this message translates to:
  /// **'kg'**
  String get weightUnitKg;

  /// No description provided for @weightDateLabel.
  ///
  /// In id, this message translates to:
  /// **'Tanggal catatan'**
  String get weightDateLabel;

  /// No description provided for @weightDateHint.
  ///
  /// In id, this message translates to:
  /// **'Pilih tanggal'**
  String get weightDateHint;

  /// No description provided for @weightNoteLabel.
  ///
  /// In id, this message translates to:
  /// **'Catatan (opsional)'**
  String get weightNoteLabel;

  /// No description provided for @weightNoteHint.
  ///
  /// In id, this message translates to:
  /// **'Mis. setelah bangun pagi'**
  String get weightNoteHint;

  /// No description provided for @weightLocalOnlyNote.
  ///
  /// In id, this message translates to:
  /// **'Catatan berat hanya tersimpan di perangkat ini.'**
  String get weightLocalOnlyNote;

  /// No description provided for @weightSaveAction.
  ///
  /// In id, this message translates to:
  /// **'Simpan berat'**
  String get weightSaveAction;

  /// No description provided for @weightInvalidNumberError.
  ///
  /// In id, this message translates to:
  /// **'Masukkan angka berat yang sah.'**
  String get weightInvalidNumberError;

  /// No description provided for @weightOutOfRangeError.
  ///
  /// In id, this message translates to:
  /// **'Berat ini di luar rentang yang masuk akal.'**
  String get weightOutOfRangeError;

  /// No description provided for @weightFutureDateError.
  ///
  /// In id, this message translates to:
  /// **'Tanggal catatan tidak boleh di masa depan.'**
  String get weightFutureDateError;

  /// No description provided for @weightMonitorTitle.
  ///
  /// In id, this message translates to:
  /// **'Catatan berat'**
  String get weightMonitorTitle;

  /// No description provided for @weightMonitorSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Lihat arah perubahan, bukan nilai mutlak.'**
  String get weightMonitorSubtitle;

  /// No description provided for @weightMonitorEyebrow.
  ///
  /// In id, this message translates to:
  /// **'CATAT BERAT'**
  String get weightMonitorEyebrow;

  /// No description provided for @weightLatestLabel.
  ///
  /// In id, this message translates to:
  /// **'TERBARU · {date}'**
  String weightLatestLabel(String date);

  /// No description provided for @weightLatestSemantics.
  ///
  /// In id, this message translates to:
  /// **'Berat terbaru {weight} kilogram, tercatat {date}'**
  String weightLatestSemantics(String weight, String date);

  /// No description provided for @weightVsProgramStart.
  ///
  /// In id, this message translates to:
  /// **'Awal program {weight} kg · {direction} {delta} kg'**
  String weightVsProgramStart(String weight, String direction, String delta);

  /// No description provided for @weightDirectionDown.
  ///
  /// In id, this message translates to:
  /// **'penurunan'**
  String get weightDirectionDown;

  /// No description provided for @weightDirectionUp.
  ///
  /// In id, this message translates to:
  /// **'kenaikan'**
  String get weightDirectionUp;

  /// No description provided for @weightDirectionFlat.
  ///
  /// In id, this message translates to:
  /// **'tidak berubah'**
  String get weightDirectionFlat;

  /// No description provided for @weightTrendHeading.
  ///
  /// In id, this message translates to:
  /// **'Tren berat'**
  String get weightTrendHeading;

  /// No description provided for @weightTrendSubheading.
  ///
  /// In id, this message translates to:
  /// **'7 catatan terakhir'**
  String get weightTrendSubheading;

  /// No description provided for @weightTrendSingleRecordNote.
  ///
  /// In id, this message translates to:
  /// **'Baru satu catatan — tren belum dapat ditampilkan.'**
  String get weightTrendSingleRecordNote;

  /// No description provided for @weightTrendEmptySlotSemantics.
  ///
  /// In id, this message translates to:
  /// **'Belum ada catatan'**
  String get weightTrendEmptySlotSemantics;

  /// No description provided for @weightRecentRecordsHeading.
  ///
  /// In id, this message translates to:
  /// **'Catatan terakhir'**
  String get weightRecentRecordsHeading;

  /// No description provided for @weightEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada catatan berat'**
  String get weightEmptyTitle;

  /// No description provided for @weightEmptyBody.
  ///
  /// In id, this message translates to:
  /// **'Catat berat badanmu kapan saja. Hanya tersimpan di perangkat ini.'**
  String get weightEmptyBody;

  /// No description provided for @weightEmptyAction.
  ///
  /// In id, this message translates to:
  /// **'Tambah berat'**
  String get weightEmptyAction;

  /// No description provided for @weightAddActionSemantics.
  ///
  /// In id, this message translates to:
  /// **'Tambah catatan berat'**
  String get weightAddActionSemantics;

  /// No description provided for @weightEntrySemantics.
  ///
  /// In id, this message translates to:
  /// **'{date} pukul {time}, {weight} kilogram'**
  String weightEntrySemantics(String date, String time, String weight);

  /// No description provided for @weightEditEntryAction.
  ///
  /// In id, this message translates to:
  /// **'Sunting'**
  String get weightEditEntryAction;

  /// No description provided for @weightDeleteEntryAction.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get weightDeleteEntryAction;

  /// No description provided for @weightDeleteConfirmTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus catatan berat ini?'**
  String get weightDeleteConfirmTitle;

  /// No description provided for @weightDeleteConfirmBody.
  ///
  /// In id, this message translates to:
  /// **'Catatan ini akan hilang dari tren dan daftar catatan terakhir.'**
  String get weightDeleteConfirmBody;

  /// No description provided for @weightDeleteConfirmAction.
  ///
  /// In id, this message translates to:
  /// **'Hapus'**
  String get weightDeleteConfirmAction;

  /// No description provided for @weightDeleteCancelAction.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get weightDeleteCancelAction;

  /// No description provided for @labelExtractionUnavailableTitle.
  ///
  /// In id, this message translates to:
  /// **'Pembacaan otomatis belum bisa dilakukan'**
  String get labelExtractionUnavailableTitle;

  /// No description provided for @labelExtractionReasonOffline.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada koneksi internet saat ini.'**
  String get labelExtractionReasonOffline;

  /// No description provided for @labelExtractionReasonTimeout.
  ///
  /// In id, this message translates to:
  /// **'Layanan pembacaan tidak merespons.'**
  String get labelExtractionReasonTimeout;

  /// No description provided for @labelExtractionReasonQuotaExceeded.
  ///
  /// In id, this message translates to:
  /// **'Layanan pembacaan sedang tidak tersedia.'**
  String get labelExtractionReasonQuotaExceeded;

  /// No description provided for @labelExtractionReasonRefused.
  ///
  /// In id, this message translates to:
  /// **'Layanan tidak bisa membaca foto ini.'**
  String get labelExtractionReasonRefused;

  /// No description provided for @labelExtractionDraftPreservedNote.
  ///
  /// In id, this message translates to:
  /// **'Foto dan nilai yang sudah kamu isi tetap tersimpan.'**
  String get labelExtractionDraftPreservedNote;

  /// No description provided for @privacySettingsContextLabel.
  ///
  /// In id, this message translates to:
  /// **'PRIVASI'**
  String get privacySettingsContextLabel;

  /// No description provided for @privacySettingsTitle.
  ///
  /// In id, this message translates to:
  /// **'Privasi & data lokal'**
  String get privacySettingsTitle;

  /// No description provided for @privacySettingsSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Atur bagaimana foto label diperlakukan saat Mealora membacanya.'**
  String get privacySettingsSubtitle;

  /// No description provided for @privacySettingsUploadHeading.
  ///
  /// In id, this message translates to:
  /// **'Izin unggah foto label'**
  String get privacySettingsUploadHeading;

  /// No description provided for @privacySettingsUploadAskEachTimeTitle.
  ///
  /// In id, this message translates to:
  /// **'Tanya setiap kali'**
  String get privacySettingsUploadAskEachTimeTitle;

  /// No description provided for @privacySettingsUploadAskEachTimeDetail.
  ///
  /// In id, this message translates to:
  /// **'Mealora meminta persetujuan setiap kali akan mengirim foto.'**
  String get privacySettingsUploadAskEachTimeDetail;

  /// No description provided for @privacySettingsUploadAlwaysAllowTitle.
  ///
  /// In id, this message translates to:
  /// **'Selalu izinkan'**
  String get privacySettingsUploadAlwaysAllowTitle;

  /// No description provided for @privacySettingsUploadAlwaysAllowDetail.
  ///
  /// In id, this message translates to:
  /// **'Foto langsung dikirim tanpa ditanya lagi setiap kali.'**
  String get privacySettingsUploadAlwaysAllowDetail;

  /// No description provided for @privacySettingsRetentionHeading.
  ///
  /// In id, this message translates to:
  /// **'Foto sumber setelah dicatat'**
  String get privacySettingsRetentionHeading;

  /// No description provided for @privacySettingsRetentionDeleteTitle.
  ///
  /// In id, this message translates to:
  /// **'Hapus setelah dicatat'**
  String get privacySettingsRetentionDeleteTitle;

  /// No description provided for @privacySettingsRetentionDeleteDetail.
  ///
  /// In id, this message translates to:
  /// **'Foto dihapus dari perangkat begitu catatan dibuat.'**
  String get privacySettingsRetentionDeleteDetail;

  /// No description provided for @privacySettingsRetentionKeepTitle.
  ///
  /// In id, this message translates to:
  /// **'Simpan di perangkat'**
  String get privacySettingsRetentionKeepTitle;

  /// No description provided for @privacySettingsRetentionKeepDetail.
  ///
  /// In id, this message translates to:
  /// **'Foto tetap tersimpan di perangkat ini agar bisa diperiksa lagi.'**
  String get privacySettingsRetentionKeepDetail;

  /// No description provided for @privacySettingsNote.
  ///
  /// In id, this message translates to:
  /// **'Foto hanya dikirim ke layanan pembacaan label saat kamu setuju, dan tidak pernah disimpan di luar perangkat ini.'**
  String get privacySettingsNote;

  /// No description provided for @displaySettingsContextLabel.
  ///
  /// In id, this message translates to:
  /// **'PROFIL'**
  String get displaySettingsContextLabel;

  /// No description provided for @displaySettingsTitle.
  ///
  /// In id, this message translates to:
  /// **'Bahasa & tampilan'**
  String get displaySettingsTitle;

  /// No description provided for @displaySettingsSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Atur bahasa aplikasi dan awal minggu.'**
  String get displaySettingsSubtitle;

  /// No description provided for @displaySettingsLanguageHeading.
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get displaySettingsLanguageHeading;

  /// No description provided for @displaySettingsLanguageIndonesian.
  ///
  /// In id, this message translates to:
  /// **'Bahasa Indonesia'**
  String get displaySettingsLanguageIndonesian;

  /// No description provided for @displaySettingsLanguageCurrent.
  ///
  /// In id, this message translates to:
  /// **'Dipakai sekarang'**
  String get displaySettingsLanguageCurrent;

  /// No description provided for @displaySettingsLanguageEnglish.
  ///
  /// In id, this message translates to:
  /// **'English'**
  String get displaySettingsLanguageEnglish;

  /// No description provided for @displaySettingsLanguageComingSoon.
  ///
  /// In id, this message translates to:
  /// **'Segera hadir'**
  String get displaySettingsLanguageComingSoon;

  /// No description provided for @displaySettingsLanguageComingSoonChip.
  ///
  /// In id, this message translates to:
  /// **'Segera'**
  String get displaySettingsLanguageComingSoonChip;

  /// No description provided for @displaySettingsCalendarHeading.
  ///
  /// In id, this message translates to:
  /// **'Kalender'**
  String get displaySettingsCalendarHeading;

  /// No description provided for @displaySettingsWeekStartLabel.
  ///
  /// In id, this message translates to:
  /// **'Awal minggu'**
  String get displaySettingsWeekStartLabel;

  /// No description provided for @displaySettingsWeekStartDetail.
  ///
  /// In id, this message translates to:
  /// **'untuk ringkasan mingguan'**
  String get displaySettingsWeekStartDetail;

  /// No description provided for @displaySettingsWeekStartMonday.
  ///
  /// In id, this message translates to:
  /// **'Senin'**
  String get displaySettingsWeekStartMonday;

  /// No description provided for @displaySettingsWeekStartSunday.
  ///
  /// In id, this message translates to:
  /// **'Minggu'**
  String get displaySettingsWeekStartSunday;

  /// No description provided for @displaySettingsNote.
  ///
  /// In id, this message translates to:
  /// **'Awal minggu mengatur ringkasan mingguan di Riwayat dan Program. Catatan lamamu tetap utuh.'**
  String get displaySettingsNote;

  /// No description provided for @aboutContextLabel.
  ///
  /// In id, this message translates to:
  /// **'PROFIL'**
  String get aboutContextLabel;

  /// No description provided for @aboutTitle.
  ///
  /// In id, this message translates to:
  /// **'Tentang Mealora'**
  String get aboutTitle;

  /// No description provided for @aboutSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Versi aplikasi dan informasi penting.'**
  String get aboutSubtitle;

  /// No description provided for @aboutAppName.
  ///
  /// In id, this message translates to:
  /// **'Mealora'**
  String get aboutAppName;

  /// No description provided for @aboutVersion.
  ///
  /// In id, this message translates to:
  /// **'Versi {version} · build {build}'**
  String aboutVersion(String version, String build);

  /// No description provided for @aboutLicensesAction.
  ///
  /// In id, this message translates to:
  /// **'Lisensi sumber terbuka'**
  String get aboutLicensesAction;

  /// No description provided for @aboutDisclaimer.
  ///
  /// In id, this message translates to:
  /// **'Mealora membantu mencatat makan dan memperkirakan gizi. Angkanya perkiraan, bukan nasihat kesehatan. Untuk kebutuhan khusus, bicarakan dengan tenaga kesehatan.'**
  String get aboutDisclaimer;

  /// No description provided for @aboutFooter.
  ///
  /// In id, this message translates to:
  /// **'Dibuat di Indonesia · © {year} Mealora'**
  String aboutFooter(String year);

  /// No description provided for @uploadConsentBody.
  ///
  /// In id, this message translates to:
  /// **'Ekstraksi memerlukan internet. Kamu tetap dapat mengetik nilainya sendiri saat offline.'**
  String get uploadConsentBody;

  /// No description provided for @uploadConsentCheckboxLabel.
  ///
  /// In id, this message translates to:
  /// **'Izinkan unggah foto label ini'**
  String get uploadConsentCheckboxLabel;

  /// No description provided for @uploadConsentCheckedState.
  ///
  /// In id, this message translates to:
  /// **'Dicentang'**
  String get uploadConsentCheckedState;

  /// No description provided for @uploadConsentUncheckedState.
  ///
  /// In id, this message translates to:
  /// **'Belum dicentang'**
  String get uploadConsentUncheckedState;

  /// No description provided for @labelPhotoContextLabel.
  ///
  /// In id, this message translates to:
  /// **'INFORMASI NILAI GIZI'**
  String get labelPhotoContextLabel;

  /// No description provided for @labelPhotoTitle.
  ///
  /// In id, this message translates to:
  /// **'Foto label kemasan'**
  String get labelPhotoTitle;

  /// No description provided for @labelPhotoSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Pastikan teks dan satuan terlihat jelas.'**
  String get labelPhotoSubtitle;

  /// No description provided for @labelPhotoFrameCaption.
  ///
  /// In id, this message translates to:
  /// **'Informasi Nilai Gizi harus terbaca penuh'**
  String get labelPhotoFrameCaption;

  /// No description provided for @labelPhotoExtractAction.
  ///
  /// In id, this message translates to:
  /// **'Ekstrak untuk ditinjau'**
  String get labelPhotoExtractAction;

  /// No description provided for @labelPhotoRetryAction.
  ///
  /// In id, this message translates to:
  /// **'Coba lagi dengan foto ini'**
  String get labelPhotoRetryAction;

  /// No description provided for @labelPhotoManualLink.
  ///
  /// In id, this message translates to:
  /// **'Isi label secara manual tanpa unggah'**
  String get labelPhotoManualLink;

  /// No description provided for @labelPhotoPermissionDeniedTitle.
  ///
  /// In id, this message translates to:
  /// **'Kamera tidak dapat diakses'**
  String get labelPhotoPermissionDeniedTitle;

  /// No description provided for @labelPhotoPermissionDeniedBody.
  ///
  /// In id, this message translates to:
  /// **'Izin kamera ditolak atau tidak tersedia. Kamu tetap bisa mengisi nilai label secara manual.'**
  String get labelPhotoPermissionDeniedBody;

  /// No description provided for @labelReviewContextLabel.
  ///
  /// In id, this message translates to:
  /// **'TINJAU HASIL BACAAN'**
  String get labelReviewContextLabel;

  /// No description provided for @labelReviewTitle.
  ///
  /// In id, this message translates to:
  /// **'Periksa nilai yang terbaca'**
  String get labelReviewTitle;

  /// No description provided for @labelReviewSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Ini bacaan yang perlu diperiksa, bukan data terverifikasi. Bandingkan dengan fotonya.'**
  String get labelReviewSubtitle;

  /// No description provided for @labelReviewNameLabel.
  ///
  /// In id, this message translates to:
  /// **'NAMA PRODUK'**
  String get labelReviewNameLabel;

  /// No description provided for @labelReviewNameHint.
  ///
  /// In id, this message translates to:
  /// **'mis. Keripik Singkong Renyah'**
  String get labelReviewNameHint;

  /// No description provided for @labelReviewBasisLabel.
  ///
  /// In id, this message translates to:
  /// **'DASAR NILAI PADA KEMASAN'**
  String get labelReviewBasisLabel;

  /// No description provided for @labelReviewBasisUnreadNote.
  ///
  /// In id, this message translates to:
  /// **'Basis tidak terbaca dari foto — pilih sendiri sebelum lanjut.'**
  String get labelReviewBasisUnreadNote;

  /// No description provided for @labelReviewPackageArithmeticNote.
  ///
  /// In id, this message translates to:
  /// **'1 kemasan = {multiplier}× nilai per sajian ({servingSize}).'**
  String labelReviewPackageArithmeticNote(
    String multiplier,
    String servingSize,
  );

  /// No description provided for @labelReviewConfidenceConfident.
  ///
  /// In id, this message translates to:
  /// **'Terbaca yakin'**
  String get labelReviewConfidenceConfident;

  /// No description provided for @labelReviewConfidenceNeedsCheck.
  ///
  /// In id, this message translates to:
  /// **'Perlu diperiksa'**
  String get labelReviewConfidenceNeedsCheck;

  /// No description provided for @labelReviewConfidenceUnread.
  ///
  /// In id, this message translates to:
  /// **'Tidak terbaca'**
  String get labelReviewConfidenceUnread;

  /// No description provided for @labelReviewMarkAbsentAction.
  ///
  /// In id, this message translates to:
  /// **'Tidak tercantum di kemasan'**
  String get labelReviewMarkAbsentAction;

  /// No description provided for @labelReviewValueMarkedAbsent.
  ///
  /// In id, this message translates to:
  /// **'Ditandai tidak tercantum di kemasan'**
  String get labelReviewValueMarkedAbsent;

  /// No description provided for @labelReviewPendingValuesNote.
  ///
  /// In id, this message translates to:
  /// **'Lengkapi dulu: {fields}.'**
  String labelReviewPendingValuesNote(String fields);

  /// No description provided for @labelReviewConfirmAction.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi nilai'**
  String get labelReviewConfirmAction;

  /// No description provided for @labelReviewCancelAction.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get labelReviewCancelAction;

  /// No description provided for @labelReviewCancelConfirmTitle.
  ///
  /// In id, this message translates to:
  /// **'Batalkan peninjauan ini?'**
  String get labelReviewCancelConfirmTitle;

  /// No description provided for @labelReviewCancelConfirmBody.
  ///
  /// In id, this message translates to:
  /// **'Foto dan nilai yang sudah dibaca tidak akan disimpan sebagai produk.'**
  String get labelReviewCancelConfirmBody;

  /// No description provided for @labelReviewCancelConfirmAction.
  ///
  /// In id, this message translates to:
  /// **'Ya, batalkan'**
  String get labelReviewCancelConfirmAction;

  /// No description provided for @labelReviewCancelKeepReviewingAction.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan meninjau'**
  String get labelReviewCancelKeepReviewingAction;

  /// No description provided for @foodPhotoContextLabel.
  ///
  /// In id, this message translates to:
  /// **'FOTO MAKANAN'**
  String get foodPhotoContextLabel;

  /// No description provided for @foodPhotoTitle.
  ///
  /// In id, this message translates to:
  /// **'Ambil foto makanan'**
  String get foodPhotoTitle;

  /// No description provided for @foodPhotoSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Saran dari foto selalu perlu diperiksa.'**
  String get foodPhotoSubtitle;

  /// No description provided for @foodPhotoFrameCaption.
  ///
  /// In id, this message translates to:
  /// **'Arahkan ke piringmu'**
  String get foodPhotoFrameCaption;

  /// No description provided for @foodPhotoConsentHeading.
  ///
  /// In id, this message translates to:
  /// **'Sebelum dianalisis'**
  String get foodPhotoConsentHeading;

  /// No description provided for @foodPhotoConsentBody.
  ///
  /// In id, this message translates to:
  /// **'Analisis AI memerlukan internet. Foto hanya diunggah jika kamu mengizinkan. Catatan tetap tersimpan lokal.'**
  String get foodPhotoConsentBody;

  /// No description provided for @foodPhotoConsentCheckboxLabel.
  ///
  /// In id, this message translates to:
  /// **'Saya izinkan unggah foto ini'**
  String get foodPhotoConsentCheckboxLabel;

  /// No description provided for @foodPhotoCaptureAction.
  ///
  /// In id, this message translates to:
  /// **'Ambil foto & lanjutkan'**
  String get foodPhotoCaptureAction;

  /// No description provided for @foodPhotoManualLink.
  ///
  /// In id, this message translates to:
  /// **'Tanpa internet? Pilih makanan secara manual'**
  String get foodPhotoManualLink;

  /// No description provided for @foodPhotoPermissionDeniedTitle.
  ///
  /// In id, this message translates to:
  /// **'Kamera tidak dapat diakses'**
  String get foodPhotoPermissionDeniedTitle;

  /// No description provided for @foodPhotoPermissionDeniedBody.
  ///
  /// In id, this message translates to:
  /// **'Izin kamera ditolak atau tidak tersedia. Kamu tetap bisa memilih makanan secara manual.'**
  String get foodPhotoPermissionDeniedBody;

  /// No description provided for @foodPhotoDraftContextLabel.
  ///
  /// In id, this message translates to:
  /// **'FOTO MAKANAN'**
  String get foodPhotoDraftContextLabel;

  /// No description provided for @foodPhotoDraftSavedTitle.
  ///
  /// In id, this message translates to:
  /// **'Foto tersimpan sebagai draf'**
  String get foodPhotoDraftSavedTitle;

  /// No description provided for @foodPhotoDraftSavedBody.
  ///
  /// In id, this message translates to:
  /// **'Belum ada catatan makan yang dibuat.'**
  String get foodPhotoDraftSavedBody;

  /// No description provided for @foodPhotoDraftBadge.
  ///
  /// In id, this message translates to:
  /// **'Draf foto · tersimpan di perangkat'**
  String get foodPhotoDraftBadge;

  /// No description provided for @foodPhotoDraftUnavailableTitle.
  ///
  /// In id, this message translates to:
  /// **'Analisis foto belum tersedia'**
  String get foodPhotoDraftUnavailableTitle;

  /// No description provided for @foodPhotoDraftUnavailableBody.
  ///
  /// In id, this message translates to:
  /// **'Koneksi atau kuota layanan bermasalah. Draf fotomu tidak hilang.'**
  String get foodPhotoDraftUnavailableBody;

  /// No description provided for @foodPhotoDraftManualHeading.
  ///
  /// In id, this message translates to:
  /// **'Lanjut tanpa AI'**
  String get foodPhotoDraftManualHeading;

  /// No description provided for @foodPhotoDraftManualDescription.
  ///
  /// In id, this message translates to:
  /// **'Cari makanan di katalog, tambah bahan, lalu atur porsinya sendiri.'**
  String get foodPhotoDraftManualDescription;

  /// No description provided for @foodPhotoDraftManualAction.
  ///
  /// In id, this message translates to:
  /// **'Pilih makanan manual'**
  String get foodPhotoDraftManualAction;

  /// No description provided for @foodPhotoReviewContextLabel.
  ///
  /// In id, this message translates to:
  /// **'TINJAU FOTO MAKANAN'**
  String get foodPhotoReviewContextLabel;

  /// No description provided for @foodPhotoReviewBadge.
  ///
  /// In id, this message translates to:
  /// **'Saran foto · porsi perlu dicek'**
  String get foodPhotoReviewBadge;

  /// No description provided for @foodPhotoReviewBadgeNote.
  ///
  /// In id, this message translates to:
  /// **'Nutrisi dari padanan katalog; periksa bahan.'**
  String get foodPhotoReviewBadgeNote;

  /// No description provided for @foodPhotoReviewTitle.
  ///
  /// In id, this message translates to:
  /// **'Tinjau foto makanan'**
  String get foodPhotoReviewTitle;

  /// No description provided for @foodPhotoReviewSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Periksa perkiraan sebelum dicatat'**
  String get foodPhotoReviewSubtitle;

  /// No description provided for @foodPhotoReviewEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Isi piringmu'**
  String get foodPhotoReviewEmptyTitle;

  /// No description provided for @foodPhotoReviewComponentCount.
  ///
  /// In id, this message translates to:
  /// **'{count, plural, =0{Tidak ada bahan} =1{1 bahan} other{{count} bahan}}'**
  String foodPhotoReviewComponentCount(int count);

  /// No description provided for @foodPhotoReviewEditAction.
  ///
  /// In id, this message translates to:
  /// **'Ubah'**
  String get foodPhotoReviewEditAction;

  /// No description provided for @foodPhotoReviewNoMatchLabel.
  ///
  /// In id, this message translates to:
  /// **'Belum ada padanan — pilih atau buat makanan'**
  String get foodPhotoReviewNoMatchLabel;

  /// No description provided for @foodPhotoReviewTotalSummary.
  ///
  /// In id, this message translates to:
  /// **'· {kcal} kkal  ·  P {protein} g  ·  K {carbohydrate} g  ·  L {fat} g'**
  String foodPhotoReviewTotalSummary(
    String kcal,
    String protein,
    String carbohydrate,
    String fat,
  );

  /// No description provided for @foodPhotoReviewConfirmAction.
  ///
  /// In id, this message translates to:
  /// **'Konfirmasi & catat'**
  String get foodPhotoReviewConfirmAction;

  /// No description provided for @foodPhotoReviewCancelConfirmTitle.
  ///
  /// In id, this message translates to:
  /// **'Batalkan peninjauan ini?'**
  String get foodPhotoReviewCancelConfirmTitle;

  /// No description provided for @foodPhotoReviewCancelConfirmBody.
  ///
  /// In id, this message translates to:
  /// **'Belum ada catatan yang dibuat. Draf fotonya akan dibuang sesuai pengaturan privasi.'**
  String get foodPhotoReviewCancelConfirmBody;

  /// No description provided for @foodPhotoReviewCancelConfirmAction.
  ///
  /// In id, this message translates to:
  /// **'Ya, batalkan'**
  String get foodPhotoReviewCancelConfirmAction;

  /// No description provided for @foodPhotoReviewCancelKeepReviewingAction.
  ///
  /// In id, this message translates to:
  /// **'Lanjutkan meninjau'**
  String get foodPhotoReviewCancelKeepReviewingAction;

  /// No description provided for @foodComponentCorrectionBadge.
  ///
  /// In id, this message translates to:
  /// **'DRAF FOTO MAKANAN'**
  String get foodComponentCorrectionBadge;

  /// No description provided for @foodComponentCorrectionTitle.
  ///
  /// In id, this message translates to:
  /// **'Ubah komponen'**
  String get foodComponentCorrectionTitle;

  /// No description provided for @foodComponentCorrectionSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Setiap bahan dan porsi bisa kamu koreksi.'**
  String get foodComponentCorrectionSubtitle;

  /// No description provided for @foodComponentCorrectionHeading.
  ///
  /// In id, this message translates to:
  /// **'Bahan yang dikenali'**
  String get foodComponentCorrectionHeading;

  /// No description provided for @foodComponentCorrectionRemoveAction.
  ///
  /// In id, this message translates to:
  /// **'Hapus bahan'**
  String get foodComponentCorrectionRemoveAction;

  /// No description provided for @foodComponentCorrectionAddAction.
  ///
  /// In id, this message translates to:
  /// **'Tambah bahan, minyak, atau saus'**
  String get foodComponentCorrectionAddAction;

  /// No description provided for @foodComponentCorrectionConfirmAction.
  ///
  /// In id, this message translates to:
  /// **'Tinjau total baru'**
  String get foodComponentCorrectionConfirmAction;

  /// No description provided for @foodComponentMatchOk.
  ///
  /// In id, this message translates to:
  /// **'cocok dengan katalog'**
  String get foodComponentMatchOk;

  /// No description provided for @foodComponentMatchMissing.
  ///
  /// In id, this message translates to:
  /// **'belum ada padanan'**
  String get foodComponentMatchMissing;

  /// No description provided for @foodComponentPortionNeedsCheck.
  ///
  /// In id, this message translates to:
  /// **'porsi perlu dicek'**
  String get foodComponentPortionNeedsCheck;

  /// No description provided for @foodComponentCookingMethodNeedsCheck.
  ///
  /// In id, this message translates to:
  /// **'metode masak perlu dicek'**
  String get foodComponentCookingMethodNeedsCheck;

  /// No description provided for @foodComponentEditorFoodLabel.
  ///
  /// In id, this message translates to:
  /// **'MAKANAN'**
  String get foodComponentEditorFoodLabel;

  /// No description provided for @foodComponentEditorFoodChangeAction.
  ///
  /// In id, this message translates to:
  /// **'Ganti makanan'**
  String get foodComponentEditorFoodChangeAction;

  /// No description provided for @foodComponentEditorQuantityLabel.
  ///
  /// In id, this message translates to:
  /// **'JUMLAH TAKARAN'**
  String get foodComponentEditorQuantityLabel;

  /// No description provided for @foodComponentEditorServingLabel.
  ///
  /// In id, this message translates to:
  /// **'TAKARAN'**
  String get foodComponentEditorServingLabel;

  /// No description provided for @foodComponentEditorCookingMethodLabel.
  ///
  /// In id, this message translates to:
  /// **'METODE MASAK (OPSIONAL)'**
  String get foodComponentEditorCookingMethodLabel;

  /// No description provided for @foodComponentEditorCookingMethodHint.
  ///
  /// In id, this message translates to:
  /// **'mis. digoreng, dikukus, dibakar'**
  String get foodComponentEditorCookingMethodHint;

  /// No description provided for @foodComponentEditorSaveAction.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get foodComponentEditorSaveAction;

  /// No description provided for @foodComponentPickerTitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih makanan'**
  String get foodComponentPickerTitle;

  /// No description provided for @foodComponentPickerHint.
  ///
  /// In id, this message translates to:
  /// **'Cari di katalog'**
  String get foodComponentPickerHint;

  /// No description provided for @foodComponentPickerCreateLink.
  ///
  /// In id, this message translates to:
  /// **'Buat makanan baru'**
  String get foodComponentPickerCreateLink;

  /// No description provided for @foodComponentPickerNoResultsTitle.
  ///
  /// In id, this message translates to:
  /// **'Tidak ditemukan'**
  String get foodComponentPickerNoResultsTitle;

  /// No description provided for @foodComponentPickerNoResultsBody.
  ///
  /// In id, this message translates to:
  /// **'Coba kata kunci lain, atau buat makanan baru.'**
  String get foodComponentPickerNoResultsBody;

  /// No description provided for @todayPendingDraftTitle.
  ///
  /// In id, this message translates to:
  /// **'Draf foto makanan menunggu'**
  String get todayPendingDraftTitle;

  /// No description provided for @todayPendingDraftBody.
  ///
  /// In id, this message translates to:
  /// **'Belum ada catatan yang dibuat. Ketuk untuk melanjutkan peninjauan.'**
  String get todayPendingDraftBody;

  /// No description provided for @todayPendingDraftSemantics.
  ///
  /// In id, this message translates to:
  /// **'Draf foto makanan menunggu. Belum ada catatan yang dibuat. Ketuk untuk melanjutkan peninjauan.'**
  String get todayPendingDraftSemantics;

  /// No description provided for @voiceRecordContextLabel.
  ///
  /// In id, this message translates to:
  /// **'CATAT DENGAN SUARA'**
  String get voiceRecordContextLabel;

  /// No description provided for @voiceRecordTitle.
  ///
  /// In id, this message translates to:
  /// **'Sebutkan makananmu'**
  String get voiceRecordTitle;

  /// No description provided for @voiceRecordSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Satu kalimat cukup. Hasilnya kamu periksa dulu sebelum dicatat.'**
  String get voiceRecordSubtitle;

  /// No description provided for @voiceRecordExampleTitle.
  ///
  /// In id, this message translates to:
  /// **'Contoh ucapan'**
  String get voiceRecordExampleTitle;

  /// No description provided for @voiceRecordExampleQuote.
  ///
  /// In id, this message translates to:
  /// **'“Tadi makan nasi 150 gram, ayam bakar satu potong, sama tempe dua.”'**
  String get voiceRecordExampleQuote;

  /// No description provided for @voiceRecordExampleHint.
  ///
  /// In id, this message translates to:
  /// **'Sebut jumlahnya kalau ingat. Kalau tidak, nanti kamu isi sendiri.'**
  String get voiceRecordExampleHint;

  /// No description provided for @voiceRecordMicHint.
  ///
  /// In id, this message translates to:
  /// **'Ketuk untuk mulai bicara'**
  String get voiceRecordMicHint;

  /// No description provided for @voiceScopeTitle.
  ///
  /// In id, this message translates to:
  /// **'Suara hanya untuk mencatat makanan'**
  String get voiceScopeTitle;

  /// No description provided for @voiceScopeBody.
  ///
  /// In id, this message translates to:
  /// **'Berat badan, program, dan pengaturan tetap diisi seperti biasa. Rekaman dihapus setelah jadi teks.'**
  String get voiceScopeBody;

  /// No description provided for @voiceTypeInsteadLink.
  ///
  /// In id, this message translates to:
  /// **'Tidak bisa bicara? Ketik kalimatnya saja'**
  String get voiceTypeInsteadLink;

  /// No description provided for @voiceRecordStartAction.
  ///
  /// In id, this message translates to:
  /// **'Mulai merekam'**
  String get voiceRecordStartAction;

  /// No description provided for @voicePermissionExplanation.
  ///
  /// In id, this message translates to:
  /// **'Mealora meminta izin mikrofon hanya untuk mengubah ucapanmu menjadi teks di perangkat ini.'**
  String get voicePermissionExplanation;

  /// No description provided for @voicePreparing.
  ///
  /// In id, this message translates to:
  /// **'Menyiapkan mikrofon…'**
  String get voicePreparing;

  /// No description provided for @voiceListeningContextLabel.
  ///
  /// In id, this message translates to:
  /// **'SEDANG MEREKAM'**
  String get voiceListeningContextLabel;

  /// No description provided for @voiceListeningTitle.
  ///
  /// In id, this message translates to:
  /// **'Mendengarkan…'**
  String get voiceListeningTitle;

  /// No description provided for @voiceListeningSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Selesai bicara? Ketuk Selesai. Kamu tetap bisa membatalkan.'**
  String get voiceListeningSubtitle;

  /// No description provided for @voiceListeningBadge.
  ///
  /// In id, this message translates to:
  /// **'Merekam · {elapsed}'**
  String voiceListeningBadge(String elapsed);

  /// No description provided for @voiceListeningMicActive.
  ///
  /// In id, this message translates to:
  /// **'Mikrofon aktif'**
  String get voiceListeningMicActive;

  /// No description provided for @voiceListeningSemantics.
  ///
  /// In id, this message translates to:
  /// **'Sedang merekam, mikrofon aktif. Ketuk Selesai untuk berhenti.'**
  String get voiceListeningSemantics;

  /// No description provided for @voiceListeningPartialLabel.
  ///
  /// In id, this message translates to:
  /// **'TERDENGAR SEJAUH INI'**
  String get voiceListeningPartialLabel;

  /// No description provided for @voiceListeningPartialHint.
  ///
  /// In id, this message translates to:
  /// **'Teks masih sementara dan bisa kamu perbaiki nanti.'**
  String get voiceListeningPartialHint;

  /// No description provided for @voiceOnDeviceTitle.
  ///
  /// In id, this message translates to:
  /// **'Suara diproses di perangkat ini'**
  String get voiceOnDeviceTitle;

  /// No description provided for @voiceOnDeviceBody.
  ///
  /// In id, this message translates to:
  /// **'Rekamanmu tidak diunggah ke mana pun.'**
  String get voiceOnDeviceBody;

  /// No description provided for @voiceCancelAction.
  ///
  /// In id, this message translates to:
  /// **'Batalkan — tidak ada yang dicatat'**
  String get voiceCancelAction;

  /// No description provided for @voiceStopAction.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get voiceStopAction;

  /// No description provided for @voiceEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada yang terdengar'**
  String get voiceEmptyTitle;

  /// No description provided for @voiceEmptyBody.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada yang dicatat. Coba rekam ulang, atau ketik kalimatnya.'**
  String get voiceEmptyBody;

  /// No description provided for @voiceFailedTitle.
  ///
  /// In id, this message translates to:
  /// **'Pengenalan suara terhenti'**
  String get voiceFailedTitle;

  /// No description provided for @voiceFailedBody.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada yang dicatat. Coba rekam ulang, atau ketik kalimatnya.'**
  String get voiceFailedBody;

  /// No description provided for @voiceReviewContextLabel.
  ///
  /// In id, this message translates to:
  /// **'PERIKSA TEKS'**
  String get voiceReviewContextLabel;

  /// No description provided for @voiceReviewTitle.
  ///
  /// In id, this message translates to:
  /// **'Sudah benar?'**
  String get voiceReviewTitle;

  /// No description provided for @voiceReviewSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Hasil pengenalan bisa keliru. Perbaiki dulu sebelum diurai.'**
  String get voiceReviewSubtitle;

  /// No description provided for @voiceReviewFieldLabel.
  ///
  /// In id, this message translates to:
  /// **'TEKS YANG TERDENGAR'**
  String get voiceReviewFieldLabel;

  /// No description provided for @voiceReviewFieldHint.
  ///
  /// In id, this message translates to:
  /// **'Ketuk untuk memperbaiki kata yang salah'**
  String get voiceReviewFieldHint;

  /// No description provided for @voiceRecordingDeletedTitle.
  ///
  /// In id, this message translates to:
  /// **'Rekaman suara sudah dihapus'**
  String get voiceRecordingDeletedTitle;

  /// No description provided for @voiceRecordingDeletedBody.
  ///
  /// In id, this message translates to:
  /// **'Yang tersisa hanya teks di atas.'**
  String get voiceRecordingDeletedBody;

  /// No description provided for @voiceParseNeedsInternetTitle.
  ///
  /// In id, this message translates to:
  /// **'Mengurai butuh internet'**
  String get voiceParseNeedsInternetTitle;

  /// No description provided for @voiceParseNeedsInternetBody.
  ///
  /// In id, this message translates to:
  /// **'Yang dikirim hanya teks ini, bukan rekaman suaramu. Tanpa internet, cari di katalog.'**
  String get voiceParseNeedsInternetBody;

  /// No description provided for @voiceRerecordAction.
  ///
  /// In id, this message translates to:
  /// **'Rekam ulang'**
  String get voiceRerecordAction;

  /// No description provided for @voiceCatalogLink.
  ///
  /// In id, this message translates to:
  /// **'Tanpa internet? Cari di katalog'**
  String get voiceCatalogLink;

  /// No description provided for @voiceParseAction.
  ///
  /// In id, this message translates to:
  /// **'Urai jadi daftar makanan'**
  String get voiceParseAction;

  /// No description provided for @voiceUnavailableContextLabel.
  ///
  /// In id, this message translates to:
  /// **'SUARA TIDAK TERSEDIA'**
  String get voiceUnavailableContextLabel;

  /// No description provided for @voiceUnavailableTitle.
  ///
  /// In id, this message translates to:
  /// **'Mikrofon belum aktif'**
  String get voiceUnavailableTitle;

  /// No description provided for @voiceUnavailableSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Kamu tetap bisa mencatat dengan mengetik kalimatnya.'**
  String get voiceUnavailableSubtitle;

  /// No description provided for @voicePermissionDeniedTitle.
  ///
  /// In id, this message translates to:
  /// **'Izin mikrofon belum diberikan'**
  String get voicePermissionDeniedTitle;

  /// No description provided for @voicePermissionDeniedBody.
  ///
  /// In id, this message translates to:
  /// **'Kamu bisa memberi izin lewat pengaturan perangkat, atau ketik kalimatnya di bawah.'**
  String get voicePermissionDeniedBody;

  /// No description provided for @voiceNotSupportedTitle.
  ///
  /// In id, this message translates to:
  /// **'Pengenalan suara belum didukung'**
  String get voiceNotSupportedTitle;

  /// No description provided for @voiceNotSupportedBody.
  ///
  /// In id, this message translates to:
  /// **'Perangkat ini belum mendukung pengenalan suara bahasa Indonesia di perangkat. Rekaman tidak dikirim ke mana pun.'**
  String get voiceNotSupportedBody;

  /// No description provided for @voiceTypeFieldLabel.
  ///
  /// In id, this message translates to:
  /// **'Ketik kalimatnya'**
  String get voiceTypeFieldLabel;

  /// No description provided for @voiceTypeFieldHint.
  ///
  /// In id, this message translates to:
  /// **'nasi 150 gram, ayam bakar satu potong, tempe dua'**
  String get voiceTypeFieldHint;

  /// No description provided for @voiceTypeFieldHelper.
  ///
  /// In id, this message translates to:
  /// **'Sebut jumlahnya bila ingat'**
  String get voiceTypeFieldHelper;

  /// No description provided for @voiceTypeScopeTitle.
  ///
  /// In id, this message translates to:
  /// **'Hanya untuk mencatat makanan'**
  String get voiceTypeScopeTitle;

  /// No description provided for @voiceTypeScopeBody.
  ///
  /// In id, this message translates to:
  /// **'Kalimat di luar makanan tidak dijalankan. Berat badan dan program tetap diisi di layarnya sendiri.'**
  String get voiceTypeScopeBody;

  /// No description provided for @voiceTypeContextLabel.
  ///
  /// In id, this message translates to:
  /// **'KETIK KALIMAT'**
  String get voiceTypeContextLabel;

  /// No description provided for @voiceTypeTitle.
  ///
  /// In id, this message translates to:
  /// **'Tulis yang kamu makan'**
  String get voiceTypeTitle;

  /// No description provided for @voiceTypeSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Satu kalimat cukup. Hasilnya kamu periksa dulu sebelum dicatat.'**
  String get voiceTypeSubtitle;

  /// No description provided for @voiceParseTypedAction.
  ///
  /// In id, this message translates to:
  /// **'Urai kalimat ini'**
  String get voiceParseTypedAction;

  /// No description provided for @voiceParsingInProgress.
  ///
  /// In id, this message translates to:
  /// **'Mengurai kalimat…'**
  String get voiceParsingInProgress;

  /// No description provided for @voiceParseUnavailableTitle.
  ///
  /// In id, this message translates to:
  /// **'Kalimat belum bisa diurai'**
  String get voiceParseUnavailableTitle;

  /// No description provided for @voiceParseUnavailableOffline.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada koneksi. Teksmu tetap di sini — coba lagi nanti, atau cari di katalog.'**
  String get voiceParseUnavailableOffline;

  /// No description provided for @voiceParseUnavailableTimeout.
  ///
  /// In id, this message translates to:
  /// **'Penguraian terlalu lama. Teksmu tetap di sini — coba lagi, atau cari di katalog.'**
  String get voiceParseUnavailableTimeout;

  /// No description provided for @voiceParseUnavailableQuota.
  ///
  /// In id, this message translates to:
  /// **'Layanan penguraian sedang penuh. Teksmu tetap di sini — coba lagi nanti, atau cari di katalog.'**
  String get voiceParseUnavailableQuota;

  /// No description provided for @voiceParseUnavailableRefused.
  ///
  /// In id, this message translates to:
  /// **'Layanan penguraian sedang tidak tersedia. Teksmu tetap di sini — coba lagi nanti, atau cari di katalog.'**
  String get voiceParseUnavailableRefused;

  /// No description provided for @voiceParsedIgnoredPartShort.
  ///
  /// In id, this message translates to:
  /// **'Bagian di luar makanan diabaikan, tidak dijalankan.'**
  String get voiceParsedIgnoredPartShort;

  /// No description provided for @voiceScopeRejectedTitle.
  ///
  /// In id, this message translates to:
  /// **'Suara hanya untuk mencatat makanan'**
  String get voiceScopeRejectedTitle;

  /// No description provided for @voiceScopeRejectedBody.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada yang dijalankan atau diubah. {where}'**
  String voiceScopeRejectedBody(String where);

  /// No description provided for @voiceScopeWhereWeight.
  ///
  /// In id, this message translates to:
  /// **'Berat badan dicatat di ruang Program.'**
  String get voiceScopeWhereWeight;

  /// No description provided for @voiceScopeWhereProgram.
  ///
  /// In id, this message translates to:
  /// **'Program diatur di ruang Program.'**
  String get voiceScopeWhereProgram;

  /// No description provided for @voiceScopeWhereProfile.
  ///
  /// In id, this message translates to:
  /// **'Profil dan pengaturan ada di ruang Profil.'**
  String get voiceScopeWhereProfile;

  /// No description provided for @voiceScopeWhereDiary.
  ///
  /// In id, this message translates to:
  /// **'Catatan makan diubah atau dihapus dari Hari ini atau Riwayat.'**
  String get voiceScopeWhereDiary;

  /// No description provided for @voiceScopeWhereToday.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan kalori ada di Hari ini.'**
  String get voiceScopeWhereToday;

  /// No description provided for @voiceScopeWhereOther.
  ///
  /// In id, this message translates to:
  /// **'Kalimat itu tidak bisa dijalankan dari sini.'**
  String get voiceScopeWhereOther;

  /// No description provided for @voiceReviewComponentsContextLabel.
  ///
  /// In id, this message translates to:
  /// **'TINJAU HASIL SUARA'**
  String get voiceReviewComponentsContextLabel;

  /// No description provided for @voiceReviewComponentsTitle.
  ///
  /// In id, this message translates to:
  /// **'Tinjau daftar makanan'**
  String get voiceReviewComponentsTitle;

  /// No description provided for @voiceReviewBadge.
  ///
  /// In id, this message translates to:
  /// **'Perkiraan dari kalimat · periksa dulu'**
  String get voiceReviewBadge;

  /// No description provided for @voiceReviewBadgeNote.
  ///
  /// In id, this message translates to:
  /// **'Nilai gizi dari padanan katalog. Tetapkan jumlah yang belum ditentukan sebelum dicatat.'**
  String get voiceReviewBadgeNote;

  /// No description provided for @voiceReviewOnDeviceBadge.
  ///
  /// In id, this message translates to:
  /// **'Diurai tanpa koneksi · periksa lebih teliti'**
  String get voiceReviewOnDeviceBadge;

  /// No description provided for @voiceReviewOnDeviceBadgeNote.
  ///
  /// In id, this message translates to:
  /// **'Kalimat diurai di perangkat ini dengan aturan sederhana. Periksa setiap makanan dan jumlahnya.'**
  String get voiceReviewOnDeviceBadgeNote;

  /// No description provided for @voiceReviewCancelConfirmBody.
  ///
  /// In id, this message translates to:
  /// **'Belum ada catatan yang dibuat. Daftar dari kalimat ini akan dibuang.'**
  String get voiceReviewCancelConfirmBody;

  /// No description provided for @voiceComponentCorrectionBadge.
  ///
  /// In id, this message translates to:
  /// **'DAFTAR DARI KALIMAT'**
  String get voiceComponentCorrectionBadge;

  /// No description provided for @voiceQuantityUndetermined.
  ///
  /// In id, this message translates to:
  /// **'jumlah belum ditentukan'**
  String get voiceQuantityUndetermined;

  /// No description provided for @voiceQuantityUndeterminedWithUnit.
  ///
  /// In id, this message translates to:
  /// **'jumlah belum ditentukan · disebut \"{unit}\"'**
  String voiceQuantityUndeterminedWithUnit(String unit);

  /// No description provided for @voiceParseNothingFoundTitle.
  ///
  /// In id, this message translates to:
  /// **'Tidak ada makanan yang dikenali'**
  String get voiceParseNothingFoundTitle;

  /// No description provided for @voiceParseNothingFoundBody.
  ///
  /// In id, this message translates to:
  /// **'Perbaiki kalimatnya, atau cari makanannya di katalog. Tidak ada yang dicatat.'**
  String get voiceParseNothingFoundBody;

  /// No description provided for @profileRemindersAction.
  ///
  /// In id, this message translates to:
  /// **'Pengingat'**
  String get profileRemindersAction;

  /// No description provided for @profileRemindersOff.
  ///
  /// In id, this message translates to:
  /// **'Mati'**
  String get profileRemindersOff;

  /// No description provided for @profileRemindersOnCount.
  ///
  /// In id, this message translates to:
  /// **'{count} menyala'**
  String profileRemindersOnCount(int count);

  /// No description provided for @remindersContextLabel.
  ///
  /// In id, this message translates to:
  /// **'PENGINGAT'**
  String get remindersContextLabel;

  /// No description provided for @remindersTitle.
  ///
  /// In id, this message translates to:
  /// **'Pengingat'**
  String get remindersTitle;

  /// No description provided for @remindersSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi muncul di HP ini saja. Waktunya bisa bergeser beberapa menit.'**
  String get remindersSubtitle;

  /// No description provided for @remindersMealsHeading.
  ///
  /// In id, this message translates to:
  /// **'Jam makan'**
  String get remindersMealsHeading;

  /// No description provided for @remindersBreakfast.
  ///
  /// In id, this message translates to:
  /// **'Sarapan'**
  String get remindersBreakfast;

  /// No description provided for @remindersLunch.
  ///
  /// In id, this message translates to:
  /// **'Makan siang'**
  String get remindersLunch;

  /// No description provided for @remindersSnack.
  ///
  /// In id, this message translates to:
  /// **'Camilan'**
  String get remindersSnack;

  /// No description provided for @remindersDinner.
  ///
  /// In id, this message translates to:
  /// **'Makan malam'**
  String get remindersDinner;

  /// No description provided for @remindersWeighHeading.
  ///
  /// In id, this message translates to:
  /// **'Timbang berat'**
  String get remindersWeighHeading;

  /// No description provided for @remindersWeighLabel.
  ///
  /// In id, this message translates to:
  /// **'Timbang berat'**
  String get remindersWeighLabel;

  /// No description provided for @remindersWeighDetail.
  ///
  /// In id, this message translates to:
  /// **'Seminggu sekali'**
  String get remindersWeighDetail;

  /// No description provided for @remindersWeighTimeLabel.
  ///
  /// In id, this message translates to:
  /// **'Jam'**
  String get remindersWeighTimeLabel;

  /// No description provided for @remindersWeekdayShortMon.
  ///
  /// In id, this message translates to:
  /// **'S'**
  String get remindersWeekdayShortMon;

  /// No description provided for @remindersWeekdayShortTue.
  ///
  /// In id, this message translates to:
  /// **'S'**
  String get remindersWeekdayShortTue;

  /// No description provided for @remindersWeekdayShortWed.
  ///
  /// In id, this message translates to:
  /// **'R'**
  String get remindersWeekdayShortWed;

  /// No description provided for @remindersWeekdayShortThu.
  ///
  /// In id, this message translates to:
  /// **'K'**
  String get remindersWeekdayShortThu;

  /// No description provided for @remindersWeekdayShortFri.
  ///
  /// In id, this message translates to:
  /// **'J'**
  String get remindersWeekdayShortFri;

  /// No description provided for @remindersWeekdayShortSat.
  ///
  /// In id, this message translates to:
  /// **'S'**
  String get remindersWeekdayShortSat;

  /// No description provided for @remindersWeekdayShortSun.
  ///
  /// In id, this message translates to:
  /// **'M'**
  String get remindersWeekdayShortSun;

  /// No description provided for @remindersWeekdayMon.
  ///
  /// In id, this message translates to:
  /// **'Senin'**
  String get remindersWeekdayMon;

  /// No description provided for @remindersWeekdayTue.
  ///
  /// In id, this message translates to:
  /// **'Selasa'**
  String get remindersWeekdayTue;

  /// No description provided for @remindersWeekdayWed.
  ///
  /// In id, this message translates to:
  /// **'Rabu'**
  String get remindersWeekdayWed;

  /// No description provided for @remindersWeekdayThu.
  ///
  /// In id, this message translates to:
  /// **'Kamis'**
  String get remindersWeekdayThu;

  /// No description provided for @remindersWeekdayFri.
  ///
  /// In id, this message translates to:
  /// **'Jumat'**
  String get remindersWeekdayFri;

  /// No description provided for @remindersWeekdaySat.
  ///
  /// In id, this message translates to:
  /// **'Sabtu'**
  String get remindersWeekdaySat;

  /// No description provided for @remindersWeekdaySun.
  ///
  /// In id, this message translates to:
  /// **'Minggu'**
  String get remindersWeekdaySun;

  /// No description provided for @remindersBedtimeHeading.
  ///
  /// In id, this message translates to:
  /// **'Jam tidur'**
  String get remindersBedtimeHeading;

  /// No description provided for @remindersBedtimeLabel.
  ///
  /// In id, this message translates to:
  /// **'Jam tidur'**
  String get remindersBedtimeLabel;

  /// No description provided for @remindersBedtimeNote.
  ///
  /// In id, this message translates to:
  /// **'Dipakai untuk mengingatkan saat kamu mencatat makan menjelang tidur.'**
  String get remindersBedtimeNote;

  /// No description provided for @remindersBlockedBody.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi diblokir. Pengingat tidak bisa muncul sampai kamu mengizinkannya.'**
  String get remindersBlockedBody;

  /// No description provided for @remindersBlockedAction.
  ///
  /// In id, this message translates to:
  /// **'Buka pengaturan'**
  String get remindersBlockedAction;

  /// No description provided for @remindersToggleSemantics.
  ///
  /// In id, this message translates to:
  /// **'Pengingat {name}'**
  String remindersToggleSemantics(String name);

  /// No description provided for @remindersTimeSemantics.
  ///
  /// In id, this message translates to:
  /// **'Ubah jam {name}, sekarang {time}'**
  String remindersTimeSemantics(String name, String time);

  /// No description provided for @remindersTimePickerTitle.
  ///
  /// In id, this message translates to:
  /// **'Pilih jam'**
  String get remindersTimePickerTitle;

  /// No description provided for @remindersTimePickerDaily.
  ///
  /// In id, this message translates to:
  /// **'{name} · pengingat harian'**
  String remindersTimePickerDaily(String name);

  /// No description provided for @remindersTimePickerWeekly.
  ///
  /// In id, this message translates to:
  /// **'Timbang berat · pengingat mingguan'**
  String get remindersTimePickerWeekly;

  /// No description provided for @remindersTimePickerBedtime.
  ///
  /// In id, this message translates to:
  /// **'Jam tidur · untuk peringatan makan larut'**
  String get remindersTimePickerBedtime;

  /// No description provided for @remindersTimePickerNote.
  ///
  /// In id, this message translates to:
  /// **'Waktu notifikasi bisa bergeser beberapa menit mengikuti penghematan baterai.'**
  String get remindersTimePickerNote;

  /// No description provided for @remindersTimePickerCancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get remindersTimePickerCancel;

  /// No description provided for @remindersTimePickerSave.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get remindersTimePickerSave;

  /// No description provided for @remindersPermissionTitle.
  ///
  /// In id, this message translates to:
  /// **'Izinkan notifikasi?'**
  String get remindersPermissionTitle;

  /// No description provided for @remindersPermissionBody.
  ///
  /// In id, this message translates to:
  /// **'Mealora butuh izin agar pengingat bisa muncul. Kamu bisa mematikannya kapan saja.'**
  String get remindersPermissionBody;

  /// No description provided for @remindersPermissionLocalNote.
  ///
  /// In id, this message translates to:
  /// **'Pengingat dibuat di HP ini. Tidak ada data yang dikirim.'**
  String get remindersPermissionLocalNote;

  /// No description provided for @remindersPermissionLater.
  ///
  /// In id, this message translates to:
  /// **'Nanti'**
  String get remindersPermissionLater;

  /// No description provided for @remindersPermissionContinue.
  ///
  /// In id, this message translates to:
  /// **'Lanjut'**
  String get remindersPermissionContinue;

  /// No description provided for @reminderChannelName.
  ///
  /// In id, this message translates to:
  /// **'Pengingat'**
  String get reminderChannelName;

  /// No description provided for @reminderChannelDescription.
  ///
  /// In id, this message translates to:
  /// **'Pengingat jam makan dan timbang berat'**
  String get reminderChannelDescription;

  /// No description provided for @reminderBreakfastTitle.
  ///
  /// In id, this message translates to:
  /// **'Waktunya sarapan'**
  String get reminderBreakfastTitle;

  /// No description provided for @reminderBreakfastBody.
  ///
  /// In id, this message translates to:
  /// **'Jangan lupa catat sarapanmu di Mealora.'**
  String get reminderBreakfastBody;

  /// No description provided for @reminderLunchTitle.
  ///
  /// In id, this message translates to:
  /// **'Waktunya makan siang'**
  String get reminderLunchTitle;

  /// No description provided for @reminderLunchBody.
  ///
  /// In id, this message translates to:
  /// **'Jangan lupa catat makan siangmu di Mealora.'**
  String get reminderLunchBody;

  /// No description provided for @reminderSnackTitle.
  ///
  /// In id, this message translates to:
  /// **'Waktunya camilan'**
  String get reminderSnackTitle;

  /// No description provided for @reminderSnackBody.
  ///
  /// In id, this message translates to:
  /// **'Jangan lupa catat camilanmu di Mealora.'**
  String get reminderSnackBody;

  /// No description provided for @reminderDinnerTitle.
  ///
  /// In id, this message translates to:
  /// **'Waktunya makan malam'**
  String get reminderDinnerTitle;

  /// No description provided for @reminderDinnerBody.
  ///
  /// In id, this message translates to:
  /// **'Jangan lupa catat makan malammu di Mealora.'**
  String get reminderDinnerBody;

  /// No description provided for @reminderWeighTitle.
  ///
  /// In id, this message translates to:
  /// **'Waktunya timbang'**
  String get reminderWeighTitle;

  /// No description provided for @reminderWeighBody.
  ///
  /// In id, this message translates to:
  /// **'Catat berat badanmu minggu ini.'**
  String get reminderWeighBody;

  /// No description provided for @lateMealNoticeTitle.
  ///
  /// In id, this message translates to:
  /// **'Sudah dekat jam tidur.'**
  String get lateMealNoticeTitle;

  /// No description provided for @lateMealNoticeBody.
  ///
  /// In id, this message translates to:
  /// **'Makan berat menjelang tidur bisa membuat tidur kurang nyenyak. Pilih porsi ringan kalau masih lapar.'**
  String get lateMealNoticeBody;

  /// No description provided for @shareAction.
  ///
  /// In id, this message translates to:
  /// **'Bagikan'**
  String get shareAction;

  /// No description provided for @sharePreviewTitle.
  ///
  /// In id, this message translates to:
  /// **'Bagikan'**
  String get sharePreviewTitle;

  /// No description provided for @sharePreviewCloseSemantics.
  ///
  /// In id, this message translates to:
  /// **'Tutup'**
  String get sharePreviewCloseSemantics;

  /// No description provided for @sharePreviewLocalNote.
  ///
  /// In id, this message translates to:
  /// **'Gambar dibuat di HP kamu. Mealora tidak mengunggah apa pun.'**
  String get sharePreviewLocalNote;

  /// No description provided for @shareFailedMessage.
  ///
  /// In id, this message translates to:
  /// **'Kartu belum bisa dibagikan. Coba lagi.'**
  String get shareFailedMessage;

  /// No description provided for @shareSummarySemantics.
  ///
  /// In id, this message translates to:
  /// **'Bagikan ringkasan hari ini'**
  String get shareSummarySemantics;

  /// No description provided for @shareSummaryDisabledReason.
  ///
  /// In id, this message translates to:
  /// **'Catat makanan dulu untuk membagikan ringkasan.'**
  String get shareSummaryDisabledReason;

  /// No description provided for @shareSummaryPreviewCaption.
  ///
  /// In id, this message translates to:
  /// **'Ringkasan harian · kalori & makro hari ini'**
  String get shareSummaryPreviewCaption;

  /// No description provided for @shareMealPreviewCaption.
  ///
  /// In id, this message translates to:
  /// **'Kartu makanan · foto & estimasi kalori'**
  String get shareMealPreviewCaption;

  /// No description provided for @shareCardOfTarget.
  ///
  /// In id, this message translates to:
  /// **'dari {target} kkal'**
  String shareCardOfTarget(String target);

  /// No description provided for @shareCardPercentOfTarget.
  ///
  /// In id, this message translates to:
  /// **'{percent}% dari target'**
  String shareCardPercentOfTarget(int percent);

  /// No description provided for @shareCardMacroLine.
  ///
  /// In id, this message translates to:
  /// **'Protein {protein} g · Karbo {carbohydrate} g · Lemak {fat} g'**
  String shareCardMacroLine(String protein, String carbohydrate, String fat);

  /// No description provided for @shareCardMoreItems.
  ///
  /// In id, this message translates to:
  /// **'+{count} lainnya'**
  String shareCardMoreItems(int count);

  /// No description provided for @shareCardTotalLabel.
  ///
  /// In id, this message translates to:
  /// **'Estimasi total kalori'**
  String get shareCardTotalLabel;

  /// No description provided for @foodPhotoSavedTitle.
  ///
  /// In id, this message translates to:
  /// **'Tersimpan!'**
  String get foodPhotoSavedTitle;

  /// No description provided for @foodPhotoSavedSubtitle.
  ///
  /// In id, this message translates to:
  /// **'{mealTime} · {count} item · {kcal} kkal'**
  String foodPhotoSavedSubtitle(String mealTime, int count, String kcal);

  /// No description provided for @foodPhotoSavedThumbCaption.
  ///
  /// In id, this message translates to:
  /// **'Pratinjau kartu yang akan dibagikan'**
  String get foodPhotoSavedThumbCaption;

  /// No description provided for @foodPhotoSavedDoneAction.
  ///
  /// In id, this message translates to:
  /// **'Selesai'**
  String get foodPhotoSavedDoneAction;
}

class _AppTextDelegate extends LocalizationsDelegate<AppText> {
  const _AppTextDelegate();

  @override
  Future<AppText> load(Locale locale) {
    return SynchronousFuture<AppText>(lookupAppText(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['id'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppTextDelegate old) => false;
}

AppText lookupAppText(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'id':
      return AppTextId();
  }

  throw FlutterError(
    'AppText.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
