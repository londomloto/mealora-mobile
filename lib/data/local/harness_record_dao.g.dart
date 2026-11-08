// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'harness_record_dao.dart';

// ignore_for_file: type=lint
mixin _$HarnessRecordDaoMixin on DatabaseAccessor<AppDatabase> {
  $HarnessRecordsTable get harnessRecords => attachedDatabase.harnessRecords;
  $HarnessRecordNotesTable get harnessRecordNotes =>
      attachedDatabase.harnessRecordNotes;
  HarnessRecordDaoManager get managers => HarnessRecordDaoManager(this);
}

class HarnessRecordDaoManager {
  final _$HarnessRecordDaoMixin _db;
  HarnessRecordDaoManager(this._db);
  $$HarnessRecordsTableTableManager get harnessRecords =>
      $$HarnessRecordsTableTableManager(
        _db.attachedDatabase,
        _db.harnessRecords,
      );
  $$HarnessRecordNotesTableTableManager get harnessRecordNotes =>
      $$HarnessRecordNotesTableTableManager(
        _db.attachedDatabase,
        _db.harnessRecordNotes,
      );
}
