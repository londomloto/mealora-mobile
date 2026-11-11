import 'package:mealora/domain/food_photo_input/photo_draft.dart';

/// Kontrak penyimpanan draf foto makanan (change 011, Design D6) —
/// diimplementasikan oleh Drift. Draf disimpan SEJAK SEBELUM pengiriman foto
/// (task 3.1) supaya kegagalan layanan, kehilangan koneksi, atau penutupan
/// aplikasi tidak pernah menghapus pekerjaan pengguna (task 3.2/3.4).
abstract interface class PhotoDraftRepository {
  /// Draf terbaru milik [profileId] yang belum dibuang — `null` bila tidak
  /// ada (dipakai memulihkan draf setelah aplikasi ditutup di tengah
  /// peninjauan).
  Future<PhotoDraft?> current(String profileId);

  /// Menyimpan [draft] (baru, atau pembaruan atas draf dengan `id` yang
  /// sama) — dipanggil pada setiap perubahan supaya draf selalu mutakhir.
  Future<void> save(PhotoDraft draft);

  /// Membuang draf setelah dicatat ke buku harian atau dibatalkan pengguna.
  /// Tidak melempar bila draf sudah tidak ada (idempoten).
  Future<void> discard(String draftId);
}
