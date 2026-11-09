// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift_profile_repository.dart';

// ignore_for_file: type=lint
mixin _$DriftProfileRepositoryMixin on DatabaseAccessor<AppDatabase> {
  $ProfilesTable get profiles => attachedDatabase.profiles;
  DriftProfileRepositoryManager get managers =>
      DriftProfileRepositoryManager(this);
}

class DriftProfileRepositoryManager {
  final _$DriftProfileRepositoryMixin _db;
  DriftProfileRepositoryManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
}
