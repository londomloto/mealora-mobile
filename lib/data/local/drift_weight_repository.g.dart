// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift_weight_repository.dart';

// ignore_for_file: type=lint
mixin _$DriftWeightRepositoryMixin on DatabaseAccessor<AppDatabase> {
  $ProfilesTable get profiles => attachedDatabase.profiles;
  $WeightRecordsTable get weightRecords => attachedDatabase.weightRecords;
  DriftWeightRepositoryManager get managers =>
      DriftWeightRepositoryManager(this);
}

class DriftWeightRepositoryManager {
  final _$DriftWeightRepositoryMixin _db;
  DriftWeightRepositoryManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
  $$WeightRecordsTableTableManager get weightRecords =>
      $$WeightRecordsTableTableManager(_db.attachedDatabase, _db.weightRecords);
}
