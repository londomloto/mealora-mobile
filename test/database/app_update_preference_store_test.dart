import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/data/local/app_update_preference_store.dart';
import 'package:mealora/data/local/ui_preference_dao.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/domain/app_update/app_update.dart';

import 'test_database.dart';

/// change 017-app-update-check, task 2.4/2.5.
void main() {
  late AppDatabase db;
  late UiPreferenceDao dao;
  late AppUpdatePreferenceStore store;

  setUp(() {
    db = createTestDatabase();
    dao = UiPreferenceDao(db, clock: createTestClock());
    store = AppUpdatePreferenceStore(dao);
  });
  tearDown(() => db.close());

  test('kosong saat belum pernah disimpan', () async {
    expect(await store.readCachedConfig(), isNull);
    expect(await store.readDismissedVersion(), isNull);
    expect(await store.readLastSuccessAt(), isNull);
  });

  test('round-trip cache, versi ditunda, dan waktu sukses', () async {
    final config = AppVersionConfig.fromJson(<String, Object?>{
      'latestVersion': '1.2.0',
      'minSupportedVersion': '1.1.0',
      'releaseNotes': 'catatan',
      'storeUrl': <String, Object?>{'android': 'https://p', 'ios': ''},
    })!;
    await store.writeCachedConfig(config);
    await store.writeDismissedVersion(const AppVersion(1, 2, 0));
    final at = DateTime.utc(2026, 11, 12, 8);
    await store.writeLastSuccessAt(at);

    final cached = (await store.readCachedConfig())!;
    expect(cached.minSupportedVersion, const AppVersion(1, 1, 0));
    expect(cached.releaseNotes, 'catatan');
    expect(await store.readDismissedVersion(), const AppVersion(1, 2, 0));
    expect(await store.readLastSuccessAt(), at);
  });

  test('catatan rilis panjang dipotong; versi dan tautan tetap utuh', () async {
    const android =
        'https://play.google.com/store/apps/details?id=com.supernova.mealora';
    final config = AppVersionConfig.fromJson(<String, Object?>{
      'latestVersion': '1.10.0',
      'minSupportedVersion': '1.9.0',
      'releaseNotes': 'Perbaikan "penting" ✓ ' * 40,
      'storeUrl': <String, Object?>{'android': android, 'ios': ''},
    })!;
    await store.writeCachedConfig(config);

    final raw = await dao.read(UiPreferenceKeys.appConfigCache);
    expect(raw!.length, lessThanOrEqualTo(256));
    final cached = (await store.readCachedConfig())!;
    expect(cached.minSupportedVersion, const AppVersion(1, 9, 0));
    expect(cached.latestVersion, const AppVersion(1, 10, 0));
    expect(cached.androidStoreUrl, android);
    expect(cached.releaseNotes, endsWith('…'));
  });

  test('cache rusak dibaca sebagai kosong', () async {
    await dao.write(UiPreferenceKeys.appConfigCache, '{rusak');
    expect(await store.readCachedConfig(), isNull);
  });
}
