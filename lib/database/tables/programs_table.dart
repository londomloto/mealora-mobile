import 'package:drift/drift.dart';

/// Katalog program Mealora (assessment `programs`, Design D2, change 004).
///
/// Bukan tabel milik pengguna — mixin `UserRecordColumns` tidak dipakai di sini.
/// Baris punya pengenal tetap yang ditulis di kode seed, bukan dibangkitkan
/// saat pemasangan, supaya baris katalog sama persis di tiap perangkat.
/// Program yang ditarik ditandai [isAvailable] `false`, tidak pernah
/// dihapus, karena riwayat pengguna lama tetap menunjuk ke sini.
class Programs extends Table {
  TextColumn get id => text().withLength(min: 1, max: 64)();

  /// Kode mesin stabil (mis. `weight_loss`) — lihat `ProgramCode.stableCode`
  /// di domain.
  TextColumn get code => text().withLength(min: 1, max: 32).unique()();

  TextColumn get name => text().withLength(min: 1, max: 120)();
  TextColumn get description => text().withLength(min: 1, max: 500)();
  BoolColumn get requiresWeightTarget => boolean()();
  BoolColumn get isAvailable => boolean().withDefault(const Constant(true))();
  IntColumn get sortOrder => integer()();
  IntColumn get definitionVersion => integer()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}
