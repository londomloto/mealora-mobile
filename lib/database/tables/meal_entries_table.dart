import 'package:drift/drift.dart';
import 'package:mealora/database/tables/profiles_table.dart';
import 'package:mealora/database/tables/user_record_columns.dart';

/// Nilai `meal_time` yang sah — sama dengan `MealTime` di domain
/// (domain/food, change 007). Tetap, tidak dapat ditambah pengguna (Design
/// D6).
const List<String> kMealTimeValues = <String>[
  'breakfast',
  'lunch',
  'snack',
  'dinner',
];

/// Satu catatan makan: satu profil, satu tanggal lokal, satu waktu makan
/// (spec food-diary, "Empat waktu makan"; change 007).
@DataClassName('MealEntryRow')
class MealEntries extends Table with UserRecordColumns {
  TextColumn get profileId =>
      text().references(Profiles, #id, onDelete: KeyAction.restrict)();

  /// Tanggal lokal (`YYYY-MM-DD`) saat dicatat — tidak pernah dihitung ulang
  /// dari instan UTC pada waktu baca (spec, "Zona waktu berubah"), selaras
  /// `ProgramProgress.recordedLocalDate` (change 004).
  TextColumn get localDate => text().withLength(min: 10, max: 10)();

  TextColumn get mealTime => text()
      .withLength(min: 1, max: 16)
      // ignore: recursive_getters — idiom Drift untuk CHECK yang merujuk kolomnya sendiri.
      .check(mealTime.isIn(kMealTimeValues))();
}
