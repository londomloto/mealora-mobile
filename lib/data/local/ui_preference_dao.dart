import 'package:drift/drift.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/database/tables/ui_preferences.dart';

part 'ui_preference_dao.g.dart';

/// Kunci preferensi antarmuka yang dikenal aplikasi.
abstract final class UiPreferenceKeys {
  /// Ruang navigasi yang terakhir dibuka pengguna.
  static const String selectedDestination = 'selected_destination';

  /// Pengaturan persetujuan unggah gambar (change 010, rancangan `35`) —
  /// nilai `ImageUploadConsentPreference.stableCode`.
  static const String imageUploadConsent = 'image_upload_consent';

  /// Pengaturan retensi foto label sumber (change 010, rancangan `35`) —
  /// nilai `ImageRetentionPreference.stableCode`.
  static const String imageRetention = 'image_retention';

  /// Awal minggu kalender & ringkasan mingguan (rancangan `65`) — nilai
  /// `WeekStart.stableCode`.
  static const String weekStart = 'week_start';

  /// Konfigurasi versi valid terakhir dari server, JSON (change 017).
  static const String appConfigCache = 'app_config_cache';

  /// Versi terbaru yang ditunda pengguna lewat "Nanti" (change 017).
  static const String appUpdateDismissedVersion =
      'app_update_dismissed_version';

  /// Instan UTC ISO-8601 pengecekan versi berhasil terakhir (change 017).
  static const String appConfigLastSuccessAt = 'app_config_last_success_at';
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
