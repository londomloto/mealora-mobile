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
}
