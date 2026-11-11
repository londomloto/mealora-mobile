import 'package:drift/drift.dart';
import 'package:mealora/database/tables/profiles_table.dart';
import 'package:mealora/database/tables/user_record_columns.dart';

/// Draf foto makanan belum dicatat (change 011-food-photo-input, Design D6)
/// — bertahan melewati kegagalan layanan, kehilangan koneksi, dan
/// penutupan aplikasi (task 3.2), sampai pengguna mengonfirmasi atau
/// membatalkan peninjauan (baris dibuang lewat penghapusan lunak, konvensi
/// change 001).
///
/// [componentsJson] menyimpan daftar komponen UTUH sebagai JSON, bukan
/// tabel terpisah: isinya belum pernah menjadi data terverifikasi (Design
/// D8 — tidak ada perubahan skema buku harian) dan tidak pernah dikueri per
/// bidang, hanya dibaca/ditulis utuh oleh layar peninjauan dan koreksi.
@DataClassName('FoodPhotoDraftRow')
class FoodPhotoDrafts extends Table with UserRecordColumns {
  TextColumn get profileId =>
      text().references(Profiles, #id, onDelete: KeyAction.cascade)();

  /// `YYYY-MM-DD`, selaras `LocalDate.iso` (konvensi change 001/004).
  TextColumn get localDate => text().withLength(min: 10, max: 10)();
  TextColumn get mealTime => text().withLength(min: 1, max: 16)();

  /// Rujukan ke foto sumber di perangkat (`source_image_storage`, change
  /// 010) — `null` kecuali pengaturan retensi gambar mengizinkan
  /// penyimpanan.
  TextColumn get sourceImagePath =>
      text().withLength(min: 1, max: 512).nullable()();

  TextColumn get componentsJson => text()();
}
