// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift_diary_repository.dart';

// ignore_for_file: type=lint
mixin _$DriftDiaryRepositoryMixin on DatabaseAccessor<AppDatabase> {
  $ProfilesTable get profiles => attachedDatabase.profiles;
  $MealEntriesTable get mealEntries => attachedDatabase.mealEntries;
  $FoodsTable get foods => attachedDatabase.foods;
  $FoodServingsTable get foodServings => attachedDatabase.foodServings;
  $MealEntryItemsTable get mealEntryItems => attachedDatabase.mealEntryItems;
  $WeightRecordsTable get weightRecords => attachedDatabase.weightRecords;
  DriftDiaryRepositoryManager get managers => DriftDiaryRepositoryManager(this);
}

class DriftDiaryRepositoryManager {
  final _$DriftDiaryRepositoryMixin _db;
  DriftDiaryRepositoryManager(this._db);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
  $$MealEntriesTableTableManager get mealEntries =>
      $$MealEntriesTableTableManager(_db.attachedDatabase, _db.mealEntries);
  $$FoodsTableTableManager get foods =>
      $$FoodsTableTableManager(_db.attachedDatabase, _db.foods);
  $$FoodServingsTableTableManager get foodServings =>
      $$FoodServingsTableTableManager(_db.attachedDatabase, _db.foodServings);
  $$MealEntryItemsTableTableManager get mealEntryItems =>
      $$MealEntryItemsTableTableManager(
        _db.attachedDatabase,
        _db.mealEntryItems,
      );
  $$WeightRecordsTableTableManager get weightRecords =>
      $$WeightRecordsTableTableManager(_db.attachedDatabase, _db.weightRecords);
}
