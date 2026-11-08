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
  /// **'catat makanan sehatmu'**
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

  /// No description provided for @profileSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Profil lokal, satuan, dan kendali atas datamu.'**
  String get profileSubtitle;

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

  /// No description provided for @profileEmptyTitle.
  ///
  /// In id, this message translates to:
  /// **'Belum ada profil'**
  String get profileEmptyTitle;

  /// No description provided for @profileEmptyBody.
  ///
  /// In id, this message translates to:
  /// **'Di sini nanti muncul profil lokalmu, satuan dan bahasa, serta kendali atas data yang tersimpan di perangkat.'**
  String get profileEmptyBody;

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
