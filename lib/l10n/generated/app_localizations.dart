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
  /// **'Belum ada catatan hari ini'**
  String get todayEmptyTitle;

  /// No description provided for @todayEmptyBody.
  ///
  /// In id, this message translates to:
  /// **'Di sini nanti muncul energi dan makronutrien yang sudah kamu catat hari ini, dikelompokkan per waktu makan. Pencatatan makanan masuk pada tahap berikutnya.'**
  String get todayEmptyBody;

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

  /// No description provided for @programConsistencyDayCompleteSemantics.
  ///
  /// In id, this message translates to:
  /// **'Hari ini, pencatatan lengkap'**
  String get programConsistencyDayCompleteSemantics;

  /// No description provided for @programConsistencyDayPartialSemantics.
  ///
  /// In id, this message translates to:
  /// **'Hari ini, pencatatan belum lengkap'**
  String get programConsistencyDayPartialSemantics;

  /// No description provided for @programConsistencyDayNoDataSemantics.
  ///
  /// In id, this message translates to:
  /// **'Hari ini, belum ada catatan'**
  String get programConsistencyDayNoDataSemantics;

  /// No description provided for @programWeightProgressUnknownTitle.
  ///
  /// In id, this message translates to:
  /// **'Kemajuan belum diketahui'**
  String get programWeightProgressUnknownTitle;

  /// No description provided for @programWeightProgressUnknownBody.
  ///
  /// In id, this message translates to:
  /// **'Pemantauan berat badan menyusul pada tahap berikutnya — belum ada angka kemajuan untuk ditampilkan di sini.'**
  String get programWeightProgressUnknownBody;

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
  /// **'Satuan & bahasa'**
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
