// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'drift_packaged_food_repository.dart';

// ignore_for_file: type=lint
mixin _$DriftPackagedFoodRepositoryMixin on DatabaseAccessor<AppDatabase> {
  $FoodsTable get foods => attachedDatabase.foods;
  $FoodServingsTable get foodServings => attachedDatabase.foodServings;
  $NutritionValuesTable get nutritionValues => attachedDatabase.nutritionValues;
  $PackagedFoodPropertiesTable get packagedFoodProperties =>
      attachedDatabase.packagedFoodProperties;
  DriftPackagedFoodRepositoryManager get managers =>
      DriftPackagedFoodRepositoryManager(this);
}

class DriftPackagedFoodRepositoryManager {
  final _$DriftPackagedFoodRepositoryMixin _db;
  DriftPackagedFoodRepositoryManager(this._db);
  $$FoodsTableTableManager get foods =>
      $$FoodsTableTableManager(_db.attachedDatabase, _db.foods);
  $$FoodServingsTableTableManager get foodServings =>
      $$FoodServingsTableTableManager(_db.attachedDatabase, _db.foodServings);
  $$NutritionValuesTableTableManager get nutritionValues =>
      $$NutritionValuesTableTableManager(
        _db.attachedDatabase,
        _db.nutritionValues,
      );
  $$PackagedFoodPropertiesTableTableManager get packagedFoodProperties =>
      $$PackagedFoodPropertiesTableTableManager(
        _db.attachedDatabase,
        _db.packagedFoodProperties,
      );
}
