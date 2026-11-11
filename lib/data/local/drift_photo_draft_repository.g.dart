// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift_photo_draft_repository.dart';

// ignore_for_file: type=lint
mixin _$DriftPhotoDraftRepositoryMixin on DatabaseAccessor<AppDatabase> {
  $ProfilesTable get profiles => attachedDatabase.profiles;
  $FoodPhotoDraftsTable get foodPhotoDrafts => attachedDatabase.foodPhotoDrafts;
  DriftPhotoDraftRepositoryManager get managers =>
      DriftPhotoDraftRepositoryManager(this);
}

class DriftPhotoDraftRepositoryManager {
  final _$DriftPhotoDraftRepositoryMixin _db;
  DriftPhotoDraftRepositoryManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
  $$FoodPhotoDraftsTableTableManager get foodPhotoDrafts =>
      $$FoodPhotoDraftsTableTableManager(
        _db.attachedDatabase,
        _db.foodPhotoDrafts,
      );
}
