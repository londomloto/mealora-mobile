import 'package:drift/drift.dart';

/// Nilai `sync_status` yang berlaku di MVP 1.
///
/// Hanya `local` yang dipakai. Nilai lain menyusul bersama mesin sinkronisasi
/// di MVP 2; kolomnya sudah ada sekarang supaya penambahannya tidak menuntut
/// migrasi dan backfill di atas data pengguna sungguhan (design D6).
const String kSyncStatusLocal = 'local';

/// Kolom wajib untuk setiap tabel milik pengguna.
///
/// Mixin ini memastikan tidak ada tabel yang lupa salah satu kolom:
/// pengenal UUID, jejak waktu, penghapusan lunak, keadaan sinkronisasi, dan
/// nomor revisi.
mixin UserRecordColumns on Table {
  /// Pengenal unik global yang dibuat aplikasi, bukan nomor urut basis data.
  TextColumn get id => text().withLength(min: 1, max: 64)();

  /// Waktu pembuatan (UTC). Tidak pernah berubah setelah record dibuat.
  DateTimeColumn get createdAt => dateTime()();

  /// Waktu pembaruan terakhir (UTC).
  DateTimeColumn get updatedAt => dateTime()();

  /// Penanda terhapus (UTC). `null` berarti record aktif.
  DateTimeColumn get deletedAt => dateTime().nullable()();

  /// Keadaan sinkronisasi. Selalu [kSyncStatusLocal] di MVP 1.
  // Nilai baku ditulis harfiah di sini karena Drift menyalin ekspresi ini apa
  // adanya ke berkas hasil pembangkitan; harus sama dengan [kSyncStatusLocal],
  // dan uji basis data memastikan keduanya tidak menyimpang.
  TextColumn get syncStatus =>
      text().withLength(min: 1, max: 16).withDefault(const Constant('local'))();

  /// Nomor revisi; bertambah satu setiap kali record berubah.
  IntColumn get revision => integer().withDefault(const Constant(1))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

/// Kolom wajib untuk tabel milik pengguna yang bersifat tambah-saja
/// (append-only), seperti jejak peristiwa.
///
/// Berbeda dari [UserRecordColumns]: tidak ada `updated_at` atau
/// `deleted_at` karena baris tidak pernah diubah atau dihapus lunak setelah
/// ditulis (change 004, assessment `program_events`) — menambah kolom itu
/// hanya akan mengundang penulisan yang melanggar sifat tambah-saja-nya.
mixin AppendOnlyRecordColumns on Table {
  TextColumn get id => text().withLength(min: 1, max: 64)();

  DateTimeColumn get createdAt => dateTime()();

  TextColumn get syncStatus =>
      text().withLength(min: 1, max: 16).withDefault(const Constant('local'))();

  IntColumn get revision => integer().withDefault(const Constant(1))();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
