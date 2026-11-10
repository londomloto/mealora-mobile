import 'package:drift/drift.dart';
import 'package:mealora/database/tables/food_servings_table.dart';
import 'package:mealora/database/tables/foods_table.dart';
import 'package:mealora/database/tables/meal_entries_table.dart';
import 'package:mealora/database/tables/user_record_columns.dart';

/// Butir catatan: makanan yang dicatat pada sebuah `MealEntry`, beserta
/// potret nilai gizi PER TAKARAN pada saat pencatatan (Design D1, change
/// 007). MVP 1 selalu membuat tepat satu butir per catatan lewat UI, tetapi
/// relasi tetap satu-ke-banyak agar change berikutnya dapat menambah lebih
/// dari satu makanan per catatan tanpa migrasi baru.
///
/// [foodId]/[servingId] tetap disimpan untuk penelusuran, tetapi kolom
/// potret ([foodNameSnapshot], [servingLabelSnapshot], dan nilai gizi) SHALL
/// TIDAK berubah ketika katalog diperbarui, makanan buatan pengguna
/// disunting, atau makanan dihapus (spec food-diary, "Nilai gizi dibekukan
/// pada saat pencatatan") — hanya menyunting catatan ITU SENDIRI mengubah
/// potretnya.
///
/// Hanya energi, protein, karbohidrat, dan lemak yang dipotret (task 2.5) —
/// serat/gula/natrium tetap atribut katalog, tidak dilacak per catatan.
@DataClassName('MealEntryItemRow')
class MealEntryItems extends Table with UserRecordColumns {
  TextColumn get mealEntryId =>
      text().references(MealEntries, #id, onDelete: KeyAction.cascade)();

  TextColumn get foodId =>
      text().references(Foods, #id, onDelete: KeyAction.restrict)();

  TextColumn get servingId =>
      text().references(FoodServings, #id, onDelete: KeyAction.restrict)();

  /// Jumlah takaran. SHALL lebih besar dari nol (spec, "Jumlah tidak sah") —
  /// ditegakkan juga lapisan domain (`ValueRules.positiveAmount`) sebelum
  /// nilai ini sempat ditulis; `CHECK` ini lapis kedua di tingkat basis data.
  RealColumn get quantity =>
      // ignore: recursive_getters — idiom Drift untuk CHECK yang merujuk kolomnya sendiri.
      real().check(quantity.isBiggerThanValue(0))();

  TextColumn get foodNameSnapshot => text().withLength(min: 1, max: 120)();
  TextColumn get servingLabelSnapshot => text().withLength(min: 1, max: 80)();

  RealColumn get energyKcalSnapshot => real().nullable()();
  RealColumn get proteinGSnapshot => real().nullable()();
  RealColumn get carbohydrateGSnapshot => real().nullable()();
  RealColumn get fatGSnapshot => real().nullable()();
}
