import 'package:drift/drift.dart';

/// Preferensi antarmuka lokal.
///
/// Bukan record milik pengguna: isinya keadaan tampilan (mis. ruang navigasi
/// yang terakhir dibuka), bukan data gizi atau berat. Karena itu tabel ini
/// sengaja tidak memakai `UserRecordColumns` — tidak ada yang perlu
/// disinkronkan, dihapus lunak, atau diberi revisi.
class UiPreferences extends Table {
  TextColumn get key => text().withLength(min: 1, max: 64)();

  TextColumn get value => text().withLength(min: 1, max: 256)();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => <Column<Object>>{key};
}
