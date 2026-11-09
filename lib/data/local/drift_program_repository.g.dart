// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift_program_repository.dart';

// ignore_for_file: type=lint
mixin _$DriftProgramRepositoryMixin on DatabaseAccessor<AppDatabase> {
  $ProfilesTable get profiles => attachedDatabase.profiles;
  $ProgramsTable get programs => attachedDatabase.programs;
  $UserProgramsTable get userPrograms => attachedDatabase.userPrograms;
  $ProgramEventsTable get programEvents => attachedDatabase.programEvents;
  $ProgramProgressTable get programProgress => attachedDatabase.programProgress;
  DriftProgramRepositoryManager get managers =>
      DriftProgramRepositoryManager(this);
}

class DriftProgramRepositoryManager {
  final _$DriftProgramRepositoryMixin _db;
  DriftProgramRepositoryManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
  $$ProgramsTableTableManager get programs =>
      $$ProgramsTableTableManager(_db.attachedDatabase, _db.programs);
  $$UserProgramsTableTableManager get userPrograms =>
      $$UserProgramsTableTableManager(_db.attachedDatabase, _db.userPrograms);
  $$ProgramEventsTableTableManager get programEvents =>
      $$ProgramEventsTableTableManager(_db.attachedDatabase, _db.programEvents);
  $$ProgramProgressTableTableManager get programProgress =>
      $$ProgramProgressTableTableManager(
        _db.attachedDatabase,
        _db.programProgress,
      );
}
