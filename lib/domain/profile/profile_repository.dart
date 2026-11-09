import 'package:mealora/domain/profile/user_profile.dart';

/// Kontrak penyimpanan profil — diimplementasikan oleh Drift
/// (`DriftProfileRepository`, lib/data/local) dan oleh tiruan dalam memori
/// di uji. Mengikuti bentuk `ProgramRepository` (domain/program, change
/// 003/004): domain tidak mengetahui bagaimana ini diimplementasikan.
///
/// MVP 1 menyimpan tepat satu profil per perangkat (FRS 2.3.1) — kontrak ini
/// tetap berbentuk baca/tulis per pengenal, bukan singleton tersirat, supaya
/// penambahan multi-profil di masa depan tidak menuntut perubahan bentuk.
abstract interface class ProfileRepository {
  /// Profil tunggal perangkat ini, atau `null` bila belum pernah dibuat
  /// (pemasangan pertama sebelum onboarding dimulai).
  Future<UserProfile?> current();

  Future<UserProfile?> findById(String id);

  /// Menyimpan [profile] baru atau memperbarui yang sudah ada.
  ///
  /// Dipanggil setiap langkah onboarding yang sah selesai diisi (Design D2,
  /// task 3.2) — bukan hanya saat onboarding selesai — sehingga menutup
  /// aplikasi di tengah jalan tidak menghilangkan isian.
  Future<void> upsert(UserProfile profile);
}
