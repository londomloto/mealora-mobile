import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/data/local/drift_profile_repository.dart';
import 'package:mealora/data/local/ui_preference_dao.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/domain/nutrition/activity_level.dart';
import 'package:mealora/domain/nutrition/biological_input.dart';
import 'package:mealora/domain/profile/user_profile.dart';
import 'package:mealora/domain/shared/units.dart';
import 'package:mealora/features/shell/app_shell.dart';
import 'package:mealora/features/shell/destinations.dart';
import 'package:mealora/features/shell/floating_navigation.dart';

import 'harness.dart';

void main() {
  late AppDatabase database;

  setUp(() async {
    database = createWidgetTestDatabase();
    // Profil lengkap tanpa program aktif — AppShell biasanya hanya dicapai
    // setelah onboarding (app/app.dart), jadi uji ini menyiapkannya langsung
    // supaya ruang Hari ini/Riwayat merender keadaan "belum ada catatan"
    // yang sesungguhnya (change 007), bukan ruang kosong karena profil
    // belum ada.
    await DriftProfileRepository(
      database,
      clock: createWidgetTestClock(),
    ).upsert(
      UserProfile(
        id: 'test-profile',
        birthDate: const LocalDate(1997, 5, 20),
        height: Length.cmValue(165, field: 'height').valueOrNull,
        currentWeight: Mass.kgValue(68, field: 'weight').valueOrNull,
        biologicalInput: BiologicalInput.female,
        activityLevel: ActivityLevel.moderatelyActive,
        isOnboardingComplete: true,
      ),
    );
  });
  tearDown(() => database.close());

  /// Uji dengan pembaca layar aktif.
  ///
  /// Handle semantics dilepas di dalam badan uji, bukan lewat `addTearDown`,
  /// karena verifikasi flutter_test berjalan sebelum tear-down.
  void shellTest(
    String description,
    Future<void> Function(WidgetTester tester) body,
  ) {
    testWidgets(description, (tester) async {
      final semantics = tester.ensureSemantics();
      try {
        await body(tester);
      } finally {
        semantics.dispose();
      }
    });
  }

  Future<void> pumpShell(WidgetTester tester, {double textScale = 1}) async {
    await useDesignViewport(tester);
    await tester.pumpWidget(
      wrapForTest(
        const AppShell(),
        database: database,
        textScale: textScale,
        overrides: <Override>[
          profileRepositoryAppOverride,
          programRepositoryAppOverride,
          foodRepositoryAppOverride,
          diaryRepositoryAppOverride,
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  Finder navItem(String label) => find.descendant(
    of: find.byType(FloatingNavigation),
    matching: find.text(label),
  );

  Finder navIcon(IconData icon) => find.descendant(
    of: find.byType(FloatingNavigation),
    matching: find.byIcon(icon),
  );

  Future<void> openSpace(WidgetTester tester, String label) async {
    await tester.tap(navItem(label));
    await tester.pumpAndSettle();
  }

  shellTest('membuka ruang Hari ini dengan keadaan belum ada data', (
    tester,
  ) async {
    await pumpShell(tester);

    expect(find.text('Hari ini belum tercatat'), findsNothing);
    expect(find.text('0'), findsOneWidget);
    expect(find.text('0 kkal'), findsOneWidget);
  });

  shellTest('berpindah antar empat ruang utama', (tester) async {
    await pumpShell(tester);

    await openSpace(tester, 'Program');
    expect(find.text('Belum ada program aktif'), findsOneWidget);

    await openSpace(tester, 'Riwayat');
    expect(find.text('Belum tercatat'), findsOneWidget);

    await openSpace(tester, 'Profil');
    expect(find.text('Ubah profil'), findsOneWidget);

    await openSpace(tester, 'Hari ini');
    expect(find.text('Hari ini belum tercatat'), findsNothing);
  });

  shellTest('penanda aktif tidak bergantung pada warna saja', (tester) async {
    await pumpShell(tester);

    // Diumumkan sebagai terpilih...
    expect(find.bySemanticsLabel('Hari ini, sedang dibuka'), findsOneWidget);
    // ...dan ikonnya berbeda bentuk dari ruang yang tidak aktif.
    expect(navIcon(MealoraDestination.today.selectedIcon), findsOneWidget);
    expect(navIcon(MealoraDestination.today.icon), findsNothing);
    expect(navIcon(MealoraDestination.program.icon), findsOneWidget);
    expect(navIcon(MealoraDestination.program.selectedIcon), findsNothing);

    await openSpace(tester, 'Program');

    expect(find.bySemanticsLabel('Program, sedang dibuka'), findsOneWidget);
    expect(navIcon(MealoraDestination.program.selectedIcon), findsOneWidget);
    expect(navIcon(MealoraDestination.today.icon), findsOneWidget);
  });

  shellTest('setiap tujuan navigasi punya label pembaca layar', (tester) async {
    await pumpShell(tester);

    expect(find.bySemanticsLabel('Hari ini, sedang dibuka'), findsOneWidget);
    for (final label in <String>['Program', 'Riwayat', 'Profil']) {
      expect(find.bySemanticsLabel(label), findsWidgets);
    }
  });

  shellTest('ruang terpilih tersimpan dan dipulihkan saat dibuka kembali', (
    tester,
  ) async {
    await pumpShell(tester);

    await openSpace(tester, 'Riwayat');
    expect(find.text('Belum tercatat'), findsOneWidget);

    final stored = await UiPreferenceDao(
      database,
      clock: createWidgetTestClock(),
    ).read(UiPreferenceKeys.selectedDestination);
    expect(stored, MealoraDestination.history.storageKey);

    // Peluncuran berikutnya membaca penyimpanan lokal yang sama.
    await tester.pumpWidget(const SizedBox.shrink());
    await pumpShell(tester);

    expect(find.text('Belum tercatat'), findsOneWidget);
    expect(find.bySemanticsLabel('Riwayat, sedang dibuka'), findsOneWidget);
  });

  shellTest('tombol Catat tampil di tengah navigasi dan berlabel', (
    tester,
  ) async {
    await pumpShell(tester);

    expect(
      find.descendant(
        of: find.byType(FloatingNavigation),
        matching: find.bySemanticsLabel('Catat makanan'),
      ),
      findsOneWidget,
    );
    // Screen 01 tidak menampilkan CTA kedua dengan aksi yang sama.
    expect(find.bySemanticsLabel('Catat makanan'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(FloatingNavigation),
        matching: find.byIcon(Icons.add_rounded),
      ),
      findsOneWidget,
    );

    // Target sentuhnya memenuhi ambang.
    final size = tester.getSize(find.byIcon(Icons.add_rounded).first);
    expect(size.width, greaterThan(0));
    final button = tester.getSize(
      find
          .ancestor(
            of: find.byIcon(Icons.add_rounded),
            matching: find.byType(Container),
          )
          .first,
    );
    expect(button.width, greaterThanOrEqualTo(MealoraTouch.minTarget));
    expect(button.height, greaterThanOrEqualTo(MealoraTouch.minTarget));
  });

  shellTest('tombol Catat membuka lembar pilihan pencatatan (02) '
      'dan tidak mengubah ruang aktif di belakangnya', (tester) async {
    await pumpShell(tester);

    await tester.tap(
      find.descendant(
        of: find.byType(FloatingNavigation),
        matching: find.bySemanticsLabel('Catat makanan'),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Cari / input manual'), findsOneWidget);
    expect(find.text('Scan barcode'), findsOneWidget);

    // Jalur yang belum tersedia (suara) tidak membuka layar yang gagal
    // (task 8.4) — barcode sendiri kini membuka `BarcodeScanScreen`
    // (change 009), diuji terpisah di `barcode_scan_screen_test.dart`.
    await tester.tap(find.text('Catat dengan suara'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    expect(
      find.text(
        'Jalur ini belum tersedia. Pakai pencarian atau buat makanan '
        'sendiri dulu, ya.',
      ),
      findsOneWidget,
    );

    await tester.tapAt(const Offset(10, 10));
    await tester.pumpAndSettle();
    expect(find.bySemanticsLabel('Hari ini, sedang dibuka'), findsOneWidget);
    expect(find.text('Hari ini belum tercatat'), findsNothing);
  });

  shellTest('seluruh ruang tetap terbaca pada skala teks besar', (
    tester,
  ) async {
    await pumpShell(tester, textScale: 2);
    expect(tester.takeException(), isNull);

    for (final label in <String>['Program', 'Riwayat', 'Profil', 'Hari ini']) {
      await openSpace(tester, label);
      expect(tester.takeException(), isNull);
    }
  });
}
