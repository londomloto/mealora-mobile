import 'dart:convert';

import 'package:mealora/data/local/ui_preference_dao.dart';
import 'package:mealora/domain/app_update/app_update.dart';

/// [AppUpdateStore] di atas `ui_preferences` (change 017, design D5). Data
/// rusak dibaca sebagai "tidak ada" agar cek update tetap fail-open.
final class AppUpdatePreferenceStore implements AppUpdateStore {
  AppUpdatePreferenceStore(this._dao);

  final UiPreferenceDao _dao;

  @override
  Future<AppVersionConfig?> readCachedConfig() async {
    final raw = await _dao.read(UiPreferenceKeys.appConfigCache);
    if (raw == null) return null;
    try {
      return AppVersionConfig.fromJson(jsonDecode(raw));
    } on FormatException {
      return null;
    }
  }

  /// Batas kolom `ui_preferences.value`.
  static const int maxValueLength = 256;

  /// Catatan rilis dipotong agar muat di [maxValueLength]; versi dan tautan
  /// toko (yang menentukan wajib update saat offline) selalu utuh. Bila itu
  /// pun tidak muat, cache tidak ditulis (fail-open).
  @override
  Future<void> writeCachedConfig(AppVersionConfig config) async {
    final encoded = _encodeWithinLimit(config);
    if (encoded == null) return;
    await _dao.write(UiPreferenceKeys.appConfigCache, encoded);
  }

  static String? _encodeWithinLimit(AppVersionConfig config) {
    String encode(String notes) =>
        jsonEncode(config.toJson()..['releaseNotes'] = notes);
    final full = encode(config.releaseNotes);
    if (full.length <= maxValueLength) return full;

    final notes = config.releaseNotes.runes.toList();
    String truncated(int keep) {
      final cut = String.fromCharCodes(notes.take(keep)).trimRight();
      return encode(cut.isEmpty ? '' : '$cut…');
    }

    // Jumlah karakter catatan terbanyak yang masih muat (pencarian biner,
    // karena escape JSON membuat panjang tidak linear).
    var low = 0;
    var high = notes.length;
    while (low < high) {
      final mid = (low + high + 1) ~/ 2;
      if (truncated(mid).length <= maxValueLength) {
        low = mid;
      } else {
        high = mid - 1;
      }
    }
    final encoded = truncated(low);
    return encoded.length <= maxValueLength ? encoded : null;
  }

  @override
  Future<AppVersion?> readDismissedVersion() async => AppVersion.tryParse(
    await _dao.read(UiPreferenceKeys.appUpdateDismissedVersion),
  );

  @override
  Future<void> writeDismissedVersion(AppVersion version) =>
      _dao.write(UiPreferenceKeys.appUpdateDismissedVersion, '$version');

  @override
  Future<DateTime?> readLastSuccessAt() async {
    final raw = await _dao.read(UiPreferenceKeys.appConfigLastSuccessAt);
    return raw == null ? null : DateTime.tryParse(raw)?.toUtc();
  }

  @override
  Future<void> writeLastSuccessAt(DateTime instantUtc) => _dao.write(
    UiPreferenceKeys.appConfigLastSuccessAt,
    instantUtc.toUtc().toIso8601String(),
  );
}
