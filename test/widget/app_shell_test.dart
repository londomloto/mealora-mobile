import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/app/theme/spacing_tokens.dart';
import 'package:mealora/data/local/ui_preference_dao.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/features/shell/app_shell.dart';
import 'package:mealora/features/shell/destinations.dart';
import 'package:mealora/features/shell/floating_navigation.dart';

import 'harness.dart';

void main() {
  late AppDatabase database;

  setUp(() => database = createWidgetTestDatabase());
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
      wrapForTest(const AppShell(), database: database, textScale: textScale),
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

    expect(find.text('Belum ada catatan hari ini'), findsOneWidget);
    expect(find.text('Belum ada data'), findsOneWidget);
  });

  shellTest('berpindah antar empat ruang utama', (tester) async {
    await pumpShell(tester);

    await openSpace(tester, 'Program');
    expect(find.text('Belum ada program'), findsOneWidget);

    await openSpace(tester, 'Riwayat');
    expect(find.text('Belum ada riwayat'), findsOneWidget);

    await openSpace(tester, 'Profil');
    expect(find.text('Ubah profil'), findsOneWidget);

    await openSpace(tester, 'Hari ini');
    expect(find.text('Belum ada catatan hari ini'), findsOneWidget);
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
    expect(find.text('Belum ada riwayat'), findsOneWidget);

    final stored = await UiPreferenceDao(
      database,
      clock: createWidgetTestClock(),
    ).read(UiPreferenceKeys.selectedDestination);
    expect(stored, MealoraDestination.history.storageKey);

    // Peluncuran berikutnya membaca penyimpanan lokal yang sama.
    await tester.pumpWidget(const SizedBox.shrink());
    await pumpShell(tester);

    expect(find.text('Belum ada riwayat'), findsOneWidget);
    expect(find.bySemanticsLabel('Riwayat, sedang dibuka'), findsOneWidget);
  });

  shellTest('tombol Catat tampil di tengah navigasi dan berlabel', (
    tester,
  ) async {
    await pumpShell(tester);

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

  shellTest('tombol Catat menjelaskan bahwa pencatatan belum tersedia '
      'dan tidak mengubah ruang aktif', (tester) async {
    await pumpShell(tester);

    await tester.tap(find.bySemanticsLabel('Catat makanan'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(
      find.text(
        'Pencatatan makanan belum tersedia. Bagian ini menyusul pada '
        'tahap berikutnya.',
      ),
      findsOneWidget,
    );
    expect(find.bySemanticsLabel('Hari ini, sedang dibuka'), findsOneWidget);
    expect(find.text('Belum ada catatan hari ini'), findsOneWidget);
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
