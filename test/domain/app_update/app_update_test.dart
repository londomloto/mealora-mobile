import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/core/clock/fixed_clock.dart';
import 'package:mealora/domain/app_update/app_update.dart';

AppVersion v(String raw) => AppVersion.tryParse(raw)!;

AppVersionConfig config({
  String latest = '1.2.0',
  String min = '1.0.0',
  String android = 'https://play.google.com/store/apps/details?id=x',
  String ios = '',
}) => AppVersionConfig.fromJson(<String, Object?>{
  'latestVersion': latest,
  'minSupportedVersion': min,
  'releaseNotes': 'catatan',
  'storeUrl': <String, Object?>{'android': android, 'ios': ios},
})!;

AppUpdateStatus evaluate({
  String installed = '1.1.0',
  AppVersionConfig? fresh,
  AppVersionConfig? cached,
  String? dismissed,
  AppStorePlatform platform = AppStorePlatform.android,
}) => evaluateAppUpdate(
  installed: v(installed),
  platform: platform,
  fresh: fresh,
  cached: cached,
  dismissedVersion: dismissed == null ? null : v(dismissed),
);

final class _FakeSource implements AppConfigSource {
  AppVersionConfig? next;
  int calls = 0;

  @override
  Future<AppVersionConfig?> fetch() async {
    calls++;
    return next;
  }
}

final class _MemoryStore implements AppUpdateStore {
  AppVersionConfig? cached;
  AppVersion? dismissed;
  DateTime? lastSuccess;

  @override
  Future<AppVersionConfig?> readCachedConfig() async => cached;

  @override
  Future<void> writeCachedConfig(AppVersionConfig config) async =>
      cached = config;

  @override
  Future<AppVersion?> readDismissedVersion() async => dismissed;

  @override
  Future<void> writeDismissedVersion(AppVersion version) async =>
      dismissed = version;

  @override
  Future<DateTime?> readLastSuccessAt() async => lastSuccess;

  @override
  Future<void> writeLastSuccessAt(DateTime instantUtc) async =>
      lastSuccess = instantUtc;
}

/// change 017-app-update-check, task 2.2.
void main() {
  group('AppVersion', () {
    test('perbandingan numerik: 1.9.0 < 1.10.0', () {
      expect(v('1.9.0') < v('1.10.0'), isTrue);
    });

    test('nomor build dan suffix pra-rilis diabaikan', () {
      expect(v('1.2.0+15'), v('1.2.0'));
      expect(v('1.2.0-beta'), v('1.2.0'));
    });

    test('versi tidak valid menjadi null', () {
      for (final raw in <String?>[null, '', '1.2', 'a.b.c', '1.2.3.4']) {
        expect(AppVersion.tryParse(raw), isNull, reason: '$raw');
      }
    });
  });

  group('AppVersionConfig.fromJson', () {
    test('field hilang, versi rusak, atau min > latest menjadi null', () {
      expect(AppVersionConfig.fromJson(<String, Object?>{}), isNull);
      expect(AppVersionConfig.fromJson('x'), isNull);
      expect(
        AppVersionConfig.fromJson(<String, Object?>{
          'latestVersion': '1.0.0',
          'minSupportedVersion': '1.1.0',
          'storeUrl': <String, Object?>{},
        }),
        isNull,
      );
      expect(
        AppVersionConfig.fromJson(<String, Object?>{
          'latestVersion': '1.0',
          'minSupportedVersion': '1.0.0',
          'storeUrl': <String, Object?>{},
        }),
        isNull,
      );
    });

    test('round-trip toJson', () {
      final c = config();
      final back = AppVersionConfig.fromJson(c.toJson())!;
      expect(back.latestVersion, c.latestVersion);
      expect(back.androidStoreUrl, c.androidStoreUrl);
    });
  });

  group('evaluateAppUpdate', () {
    test('di bawah minimum: wajib', () {
      expect(
        evaluate(
          installed: '1.0.0',
          fresh: config(min: '1.1.0'),
        ),
        isA<AppUpdateForced>(),
      );
    });

    test('di bawah terbaru: opsional untuk versi terbaru', () {
      final status = evaluate(fresh: config());
      expect(status, isA<AppUpdateOptional>());
      expect((status as AppUpdateOptional).version, v('1.2.0'));
    });

    test('sudah terbaru (build berbeda): tidak ada', () {
      expect(
        evaluate(installed: '1.2.0', fresh: config()),
        isA<AppUpdateNone>(),
      );
    });

    test('versi yang ditunda tidak muncul lagi; versi lebih baru muncul', () {
      expect(
        evaluate(fresh: config(), dismissed: '1.2.0'),
        isA<AppUpdateNone>(),
      );
      expect(
        evaluate(
          fresh: config(latest: '1.3.0'),
          dismissed: '1.2.0',
        ),
        isA<AppUpdateOptional>(),
      );
    });

    test('wajib dari cache saat fetch gagal', () {
      expect(
        evaluate(
          installed: '1.0.0',
          cached: config(min: '1.1.0'),
        ),
        isA<AppUpdateForced>(),
      );
    });

    test('opsional tidak pernah dari cache', () {
      expect(evaluate(cached: config()), isA<AppUpdateNone>());
    });

    test('konfigurasi baru mencabut wajib dari cache', () {
      expect(
        evaluate(
          installed: '1.0.0',
          fresh: config(min: '1.0.0', latest: '1.0.0'),
          cached: config(min: '1.1.0'),
        ),
        isA<AppUpdateNone>(),
      );
    });

    test('tanpa tautan toko platform: tidak ada', () {
      expect(
        evaluate(
          installed: '1.0.0',
          fresh: config(min: '1.1.0'),
          platform: AppStorePlatform.ios,
        ),
        isA<AppUpdateNone>(),
      );
      expect(
        evaluate(
          installed: '1.0.0',
          fresh: config(min: '1.1.0', android: 'http://x'),
        ),
        isA<AppUpdateNone>(),
      );
    });

    test('tanpa konfigurasi sama sekali: tidak ada', () {
      expect(evaluate(), isA<AppUpdateNone>());
    });
  });

  group('AppUpdateService', () {
    late _FakeSource source;
    late _MemoryStore store;
    late FixedClock clock;
    late AppUpdateService service;

    setUp(() {
      source = _FakeSource();
      store = _MemoryStore();
      clock = FixedClock(
        instantUtc: DateTime.utc(2026, 11, 12, 8),
        timeZoneId: 'Asia/Jakarta',
        utcOffset: const Duration(hours: 7),
      );
      service = AppUpdateService(
        source: source,
        store: store,
        clock: clock,
        installed: v('1.0.0'),
        platform: AppStorePlatform.android,
      );
    });

    test('fetch berhasil menyimpan cache dan waktu sukses', () async {
      source.next = config(min: '1.1.0');
      expect(await service.refresh(), isA<AppUpdateForced>());
      expect(store.cached, isNotNull);
      expect(store.lastSuccess, clock.nowUtc());
    });

    test('fetch gagal tidak menimpa cache; wajib tetap berlaku', () async {
      store.cached = config(min: '1.1.0');
      expect(await service.refresh(), isA<AppUpdateForced>());
      expect(store.cached!.minSupportedVersion, v('1.1.0'));
      expect(store.lastSuccess, isNull);
    });

    test('cachedStatus hanya memberi wajib, tanpa jaringan', () async {
      store.cached = config(min: '1.1.0');
      expect(await service.cachedStatus(), isA<AppUpdateForced>());
      expect(source.calls, 0);
    });

    test('throttle resume 1 jam', () async {
      source.next = config();
      await service.refresh();
      clock.advance(const Duration(minutes: 59));
      expect(await service.refresh(throttled: true), isNull);
      expect(source.calls, 1);
      clock.advance(const Duration(minutes: 1));
      expect(await service.refresh(throttled: true), isNotNull);
      expect(source.calls, 2);
    });

    test('dismiss menyimpan versi', () async {
      await service.dismiss(v('1.2.0'));
      expect(store.dismissed, v('1.2.0'));
    });
  });
}
