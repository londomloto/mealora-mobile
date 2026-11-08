import 'package:drift/drift.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/database/tables/ui_preferences.dart';

part 'ui_preference_dao.g.dart';

/// Kunci preferensi antarmuka yang dikenal aplikasi.
abstract final class UiPreferenceKeys {
  /// Ruang navigasi yang terakhir dibuka pengguna.
  static const String selectedDestination = 'selected_destination';
}

/// Akses baca/tulis preferensi antarmuka lokal.
@DriftAccessor(tables: <Type>[UiPreferences])
class UiPreferenceDao extends DatabaseAccessor<AppDatabase>
    with _$UiPreferenceDaoMixin {
  UiPreferenceDao(super.db, {required Clock clock}) : _clock = clock;

  final Clock _clock;

  Future<String?> read(String key) async {
    final row = await (select(
      uiPreferences,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> write(String key, String value) async {
    await into(uiPreferences).insertOnConflictUpdate(
      UiPreferencesCompanion.insert(
        key: key,
        value: value,
        updatedAt: _clock.nowUtc(),
      ),
    );
  }
}
