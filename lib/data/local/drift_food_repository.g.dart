// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift_food_repository.dart';

// ignore_for_file: type=lint
mixin _$DriftFoodRepositoryMixin on DatabaseAccessor<AppDatabase> {
  $FoodsTable get foods => attachedDatabase.foods;
  $FoodServingsTable get foodServings => attachedDatabase.foodServings;
  $NutritionValuesTable get nutritionValues => attachedDatabase.nutritionValues;
  $ProfilesTable get profiles => attachedDatabase.profiles;
  $MealEntriesTable get mealEntries => attachedDatabase.mealEntries;
  $MealEntryItemsTable get mealEntryItems => attachedDatabase.mealEntryItems;
  DriftFoodRepositoryManager get managers => DriftFoodRepositoryManager(this);
}

class DriftFoodRepositoryManager {
  final _$DriftFoodRepositoryMixin _db;
  DriftFoodRepositoryManager(this._db);
  $$FoodsTableTableManager get foods =>
      $$FoodsTableTableManager(_db.attachedDatabase, _db.foods);
  $$FoodServingsTableTableManager get foodServings =>
      $$FoodServingsTableTableManager(_db.attachedDatabase, _db.foodServings);
  $$NutritionValuesTableTableManager get nutritionValues =>
      $$NutritionValuesTableTableManager(
        _db.attachedDatabase,
        _db.nutritionValues,
      );
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db.attachedDatabase, _db.profiles);
  $$MealEntriesTableTableManager get mealEntries =>
      $$MealEntriesTableTableManager(_db.attachedDatabase, _db.mealEntries);
  $$MealEntryItemsTableTableManager get mealEntryItems =>
      $$MealEntryItemsTableTableManager(
        _db.attachedDatabase,
        _db.mealEntryItems,
      );
}
