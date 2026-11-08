import 'package:drift/drift.dart';
import 'package:mealora/database/tables/user_record_columns.dart';

/// Pembantu bersama untuk konvensi record milik pengguna.
///
/// Dipakai setiap akses data supaya tidak ada kueri yang lupa menyaring
/// record terhapus dan tidak ada penulisan yang lupa menaikkan revisi.
abstract final class UserRecords {
  /// Penyaring baku: hanya record yang belum ditandai terhapus.
  static Expression<bool> active(GeneratedColumn<DateTime> deletedAt) =>
      deletedAt.isNull();

  /// Penyaring eksplisit untuk membaca record yang sudah terhapus.
  static Expression<bool> deleted(GeneratedColumn<DateTime> deletedAt) =>
      deletedAt.isNotNull();

  /// Keadaan sinkronisasi untuk record baru di MVP 1.
  static const String syncStatusOnWrite = kSyncStatusLocal;

  /// Nomor revisi record baru.
  static const int initialRevision = 1;
}
