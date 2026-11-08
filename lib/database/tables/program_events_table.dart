import 'package:drift/drift.dart';
import 'package:mealora/database/tables/user_programs_table.dart';
import 'package:mealora/database/tables/user_record_columns.dart';

/// Jenis peristiwa siklus hidup yang sah — sama dengan `ProgramEventType` di
/// domain (change 003).
const List<String> kProgramEventTypes = <String>[
  'activated',
  'paused',
  'resumed',
  'changed',
  'completed',
  'cancelled',
];

/// Jejak peristiwa siklus hidup program (assessment `program_events`,
/// Design D1, change 004) — tambah-saja, tidak pernah diubah atau dihapus
/// setelah ditulis.
///
/// Memungkinkan rentang jeda dan riwayat pergantian tetap dapat ditelusuri
/// setelah program dilanjutkan atau diganti (program-lifecycle spec,
/// change 003, Design D8).
///
/// Nama kelas baris diberi akhiran `Row` secara eksplisit — nama bawaan
/// Drift untuk tabel ini (`ProgramEvent`) bentrok dengan kelas domain
/// `ProgramEvent` (change 003).
@DataClassName('ProgramEventRow')
class ProgramEvents extends Table with AppendOnlyRecordColumns {
  TextColumn get userProgramId =>
      text().references(UserPrograms, #id, onDelete: KeyAction.restrict)();

  TextColumn get eventType => text()
      .withLength(min: 1, max: 16)
      // ignore: recursive_getters
      .check(eventType.isIn(kProgramEventTypes))();

  DateTimeColumn get occurredAt => dateTime()();

  TextColumn get fromStatus => text()
      .withLength(min: 1, max: 16)
      .nullable()
      // ignore: recursive_getters
      .check(fromStatus.isIn(kUserProgramStatuses) | fromStatus.isNull())();

  TextColumn get toStatus => text()
      .withLength(min: 1, max: 16)
      .nullable()
      // ignore: recursive_getters
      .check(toStatus.isIn(kUserProgramStatuses) | toStatus.isNull())();

  TextColumn get reasonCode => text().withLength(min: 1, max: 64).nullable()();

  TextColumn get metadataJson => text().withDefault(const Constant('{}'))();
}
