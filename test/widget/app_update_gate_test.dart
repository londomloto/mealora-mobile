import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/domain/app_update/app_update.dart';
import 'package:mealora/features/app_update/app_update_controller.dart';
import 'package:mealora/features/app_update/app_update_gate.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'harness.dart';

final class _FakeSource implements AppConfigSource {
  AppVersionConfig? next;

  @override
  Future<AppVersionConfig?> fetch() async => next;
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

AppVersionConfig _config({String latest = '1.2.0', String min = '1.0.0'}) =>
    AppVersionConfig.fromJson(<String, Object?>{
      'latestVersion': latest,
      'minSupportedVersion': min,
      'releaseNotes': 'Perbaikan bug kecil',
      'storeUrl': <String, Object?>{'android': 'https://play.google.com/x'},
    })!;

/// change 017-app-update-check, task 4.1.
void main() {
  late _FakeSource source;
  late _MemoryStore store;

  setUp(() {
    source = _FakeSource();
    store = _MemoryStore();
    PackageInfo.setMockInitialValues(
      appName: 'Mealora',
      packageName: 'id.mealora',
      version: '1.1.0',
      buildNumber: '3',
      buildSignature: '',
    );
  });

  Future<ProviderContainer> pumpGate(WidgetTester tester) async {
    await useDesignViewport(tester);
    final service = AppUpdateService(
      source: source,
      store: store,
      clock: createWidgetTestClock(),
      installed: const AppVersion(1, 1, 0),
      platform: AppStorePlatform.android,
    );
    await tester.pumpWidget(
      wrapForTest(
        const AppUpdateGate(child: Scaffold(body: Text('ISI APP'))),
        overrides: <Override>[
          appUpdateServiceProvider.overrideWith((ref) async => service),
        ],
      ),
    );
    await tester.pumpAndSettle();
    return ProviderScope.containerOf(
      tester.element(find.byType(AppUpdateGate)),
    );
  }

  testWidgets('wajib update menutupi app dan tidak bisa ditutup dengan back', (
    tester,
  ) async {
    source.next = _config(min: '1.2.0');
    await pumpGate(tester);

    expect(find.text('Perbarui Mealora dulu'), findsOneWidget);
    expect(find.text('ISI APP'), findsNothing);
    expect(find.text('Versi 1.1.0 tidak didukung lagi'), findsOneWidget);
    expect(find.text('Perbaikan bug kecil'), findsOneWidget);
    expect(find.text('Update di Play Store'), findsOneWidget);

    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(find.text('Perbarui Mealora dulu'), findsOneWidget);
  });

  testWidgets('wajib dari cache saat offline', (tester) async {
    store.cached = _config(min: '1.2.0');
    await pumpGate(tester);
    expect(find.text('Perbarui Mealora dulu'), findsOneWidget);
  });

  testWidgets('konfigurasi baru mencabut wajib update', (tester) async {
    source.next = _config(min: '1.2.0');
    final container = await pumpGate(tester);
    expect(find.text('Perbarui Mealora dulu'), findsOneWidget);

    source.next = _config(min: '1.0.0', latest: '1.1.0');
    await container.read(appUpdateControllerProvider.notifier).check();
    await tester.pumpAndSettle();
    expect(find.text('Perbarui Mealora dulu'), findsNothing);
    expect(find.text('ISI APP'), findsOneWidget);
  });

  testWidgets('update tersedia: sheet tampil, Nanti menyimpan penundaan', (
    tester,
  ) async {
    source.next = _config();
    final container = await pumpGate(tester);

    expect(find.text('Versi baru tersedia'), findsOneWidget);
    expect(find.text('ISI APP'), findsOneWidget);
    await tester.tap(find.text('Nanti'));
    await tester.pumpAndSettle();
    expect(find.text('Versi baru tersedia'), findsNothing);
    expect(store.dismissed, const AppVersion(1, 2, 0));

    // Cek berikutnya untuk versi yang sama tidak menampilkan sheet lagi.
    await container.read(appUpdateControllerProvider.notifier).check();
    await tester.pumpAndSettle();
    expect(find.text('Versi baru tersedia'), findsNothing);
  });

  testWidgets('versi yang ditunda muncul lagi saat ada versi lebih baru', (
    tester,
  ) async {
    store.dismissed = const AppVersion(1, 2, 0);
    source.next = _config();
    final container = await pumpGate(tester);
    expect(find.text('Versi baru tersedia'), findsNothing);

    source.next = _config(latest: '1.3.0');
    await container.read(appUpdateControllerProvider.notifier).check();
    await tester.pumpAndSettle();
    expect(find.text('Versi baru tersedia'), findsOneWidget);
  });

  testWidgets('fail-open: tanpa konfigurasi app tampil normal', (tester) async {
    await pumpGate(tester);
    expect(find.text('ISI APP'), findsOneWidget);
    expect(find.text('Versi baru tersedia'), findsNothing);
    expect(find.text('Perbarui Mealora dulu'), findsNothing);
  });
}
