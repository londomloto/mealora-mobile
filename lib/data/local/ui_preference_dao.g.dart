// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ui_preference_dao.dart';

// ignore_for_file: type=lint
mixin _$UiPreferenceDaoMixin on DatabaseAccessor<AppDatabase> {
  $UiPreferencesTable get uiPreferences => attachedDatabase.uiPreferences;
  UiPreferenceDaoManager get managers => UiPreferenceDaoManager(this);
}

class UiPreferenceDaoManager {
  final _$UiPreferenceDaoMixin _db;
  UiPreferenceDaoManager(this._db);
  $$UiPreferencesTableTableManager get uiPreferences =>
      $$UiPreferencesTableTableManager(_db.attachedDatabase, _db.uiPreferences);
}
