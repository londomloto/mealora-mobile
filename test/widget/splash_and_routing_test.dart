import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/app/app.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/app/router.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/ids/sequential_id_generator.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/data/local/drift_profile_repository.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/domain/nutrition/activity_level.dart';
import 'package:mealora/domain/nutrition/biological_input.dart';
import 'package:mealora/domain/profile/user_profile.dart';
import 'package:mealora/domain/shared/units.dart';
import 'package:mealora/features/shell/app_shell.dart';
import 'package:mealora/features/splash/splash_screen.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

import 'harness.dart';

void main() {
  group('splash', () {
    testWidgets('menampilkan identitas Mealora dan janji penyimpanan lokal', (
      tester,
    ) async {
      await useDesignViewport(tester);
      await tester.pumpWidget(wrapForTest(const SplashScreen()));
      await tester.pump();

      expect(find.text('mealora'), findsOneWidget);
      expect(find.text('Diary makanan harianmu'), findsOneWidget);
      expect(
        find.text('Pribadi di perangkatmu · siap digunakan offline'),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('berpindah sendiri ke ruang utama tanpa interaksi pengguna', (
      tester,
    ) async {
      await useDesignViewport(tester);
      final database = createWidgetTestDatabase();
      addTearDown(database.close);
      await _seedCompleteProfile(database);

      await tester.pumpWidget(_bootstrapApp(databaseFactory: () => database));

      // Frame pertama: penyimpanan masih disiapkan, splash yang tampil.
      expect(find.byType(SplashScreen), findsOneWidget);

      // Tanpa satu pun interaksi pengguna, aplikasi berpindah sendiri.
      await tester.pumpAndSettle();

      expect(find.byType(SplashScreen), findsNothing);
      expect(find.byType(AppShell), findsOneWidget);
    });

    testWidgets('kegagalan penyimpanan memunculkan keadaan kesalahan, '
        'bukan splash yang menggantung', (tester) async {
      await useDesignViewport(tester);

      await tester.pumpWidget(
        _bootstrapApp(
          databaseFactory: () => throw StateError('penyimpanan tidak terbuka'),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(SplashScreen), findsNothing);
      expect(find.text('Penyimpanan di perangkat belum siap'), findsOneWidget);
      expect(find.text('Coba lagi'), findsOneWidget);
      expect(find.textContaining('storageUnavailable'), findsOneWidget);
    });
  });

  group('rute tidak dikenal', () {
    testWidgets('menampilkan keadaan yang dapat dibaca beserta jalan kembali', (
      tester,
    ) async {
      await useDesignViewport(tester);
      final database = createWidgetTestDatabase();
      addTearDown(database.close);
      await _seedCompleteProfile(database);

      await tester.pumpWidget(_bootstrapApp(databaseFactory: () => database));
      await tester.pumpAndSettle();

      final navigator = tester.state<NavigatorState>(find.byType(Navigator));
      unawaited(navigator.pushNamed('/rute-yang-tidak-ada'));
      await tester.pumpAndSettle();

      expect(find.byType(RouteNotFoundScreen), findsOneWidget);
      expect(find.text('Halaman tidak ditemukan'), findsOneWidget);

      await tester.tap(find.text('Kembali ke Hari ini'));
      await tester.pumpAndSettle();

      expect(find.byType(RouteNotFoundScreen), findsNothing);
      expect(find.byType(AppShell), findsOneWidget);
    });
  });

  group('lokalisasi', () {
    testWidgets('aplikasi berjalan pada locale Indonesia', (tester) async {
      await useDesignViewport(tester);
      await tester.pumpWidget(wrapForTest(const SplashScreen()));
      await tester.pump();

      final context = tester.element(find.byType(SplashScreen));
      expect(Localizations.localeOf(context).languageCode, 'id');
      expect(AppText.of(context).navToday, 'Hari ini');
    });
  });
}

Widget _bootstrapApp({required AppDatabase Function() databaseFactory}) {
  return ProviderScope(
    overrides: <Override>[
      clockProvider.overrideWithValue(createWidgetTestClock()),
      idGeneratorProvider.overrideWithValue(SequentialIdGenerator()),
      databaseFactoryProvider.overrideWithValue(databaseFactory),
      profileRepositoryAppOverride,
      programRepositoryAppOverride,
    ],
    child: const MealoraApp(),
  );
}

/// Profil lengkap sehingga gerbang onboarding (change 005,
/// `isOnboardingCompleteProvider`) mendarat di `AppShell` — uji ini
/// menguji peluncuran dan navigasi ruang utama, bukan alur onboarding.
Future<void> _seedCompleteProfile(AppDatabase database) {
  final repository = DriftProfileRepository(
    database,
    clock: createWidgetTestClock(),
  );
  return repository.upsert(
    UserProfile(
      id: 'widget-test-profile',
      birthDate: const LocalDate(1997, 5, 20),
      height: Length.cmValue(165, field: 'h').valueOrNull,
      currentWeight: Mass.kgValue(68.4, field: 'w').valueOrNull,
      biologicalInput: BiologicalInput.female,
      activityLevel: ActivityLevel.moderatelyActive,
      isOnboardingComplete: true,
    ),
  );
}
