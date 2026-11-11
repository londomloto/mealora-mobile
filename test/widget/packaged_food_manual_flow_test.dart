import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/core/ids/sequential_id_generator.dart';
import 'package:mealora/data/local/drift_packaged_food_repository.dart';
import 'package:mealora/data/local/drift_profile_repository.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/domain/packaged_food/product_data_source_client.dart';
import 'package:mealora/domain/profile/user_profile.dart';
import 'package:mealora/features/diary/barcode_manual_entry_screen.dart';
import 'package:mealora/features/diary/diary_controller.dart';
import 'package:mealora/features/diary/packaged_food_manual_fill_screen.dart';

import 'harness.dart';

/// Alur lintas layar lewat masukan barcode manual (change 009, tasks
/// 1.3/1.4/6.2-6.5): nomor tidak sah ditolak tanpa pencarian, barcode yang
/// tidak ditemukan mengarah ke pengisian manual yang tersedia luring, dan
/// produk hasil pengisian itu dapat ditinjau dan dicatat lewat jalur yang
/// sama dengan produk hasil pindaian.
void main() {
  const profileId = 'profile-1';

  Future<AppDatabase> seededDatabase() async {
    final db = createWidgetTestDatabase();
    await DriftProfileRepository(
      db,
      clock: createWidgetTestClock(),
    ).upsert(const UserProfile(id: profileId));
    return db;
  }

  List<Override> overridesFor(AppDatabase db) => <Override>[
    profileRepositoryAppOverride,
    foodRepositoryAppOverride,
    diaryRepositoryAppOverride,
    packagedFoodRepositoryProvider.overrideWith(
      (ref) => DriftPackagedFoodRepository(
        db,
        ids: SequentialIdGenerator(),
        clock: createWidgetTestClock(),
        client: _AlwaysNotFoundClient(),
      ),
    ),
  ];

  testWidgets(
    'nomor barcode tidak sah ditolak dengan penjelasan, tanpa pencarian '
    '(spec, "Nomor barcode tidak sah")',
    (tester) async {
      final db = await seededDatabase();
      addTearDown(db.close);
      await useDesignViewport(tester);

      await tester.pumpWidget(
        wrapForTest(
          const BarcodeManualEntryScreen(),
          database: db,
          overrides: overridesFor(db),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '123');
      await tester.tap(find.text('Cari produk'));
      await tester.pumpAndSettle();

      expect(
        find.text('Nomor harus 8–14 digit angka — periksa kembali kemasan.'),
        findsOneWidget,
      );
      // Masih di layar yang sama — tidak ada pencarian yang terjadi.
      expect(find.text('Masukkan nomor barcode'), findsOneWidget);
    },
  );

  testWidgets(
    'barcode yang sah tapi tidak ditemukan mengarah ke pengisian manual, '
    'yang produknya dapat ditinjau dan dicatat (tasks 6.3/6.5, 7.6)',
    (tester) async {
      final db = await seededDatabase();
      addTearDown(db.close);
      await useDesignViewport(tester);

      await tester.pumpWidget(
        wrapForTest(
          const BarcodeManualEntryScreen(),
          database: db,
          overrides: overridesFor(db),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField), '8991234567890');
      await tester.tap(find.text('Cari produk'));
      await tester.pumpAndSettle();

      expect(find.text('Produk belum ditemukan'), findsOneWidget);
      expect(find.textContaining('8991234567890'), findsWidgets);

      final manualFillEntry = find.text('Isi nilai secara manual');
      await tester.ensureVisible(manualFillEntry);
      await tester.tap(manualFillEntry);
      await tester.pumpAndSettle();

      expect(find.text('Isi label secara manual'), findsOneWidget);

      // Kolom pertama pada formulir ini adalah "Nama produk" (task 6.3
      // jalur lanjutan "Isi nilai secara manual").
      await tester.enterText(
        find.byType(TextField).first,
        'Keripik Buatan Sendiri',
      );

      final continueButton = find.text('Tinjau sebelum mencatat');
      await tester.ensureVisible(continueButton);
      await tester.tap(continueButton);
      await tester.pumpAndSettle();

      expect(find.text('Tinjau produk'), findsOneWidget);
      expect(find.text('Keripik Buatan Sendiri'), findsOneWidget);
      expect(find.text('Diisi manual'), findsOneWidget);

      final confirmButton = find.textContaining('Catat ·');
      await tester.ensureVisible(confirmButton);
      await tester.tap(confirmButton);
      await tester.pumpAndSettle();

      final entries = await db.select(db.mealEntries).get();
      expect(entries, hasLength(1));
      final packagedRows = await db.select(db.packagedFoodProperties).get();
      expect(packagedRows, hasLength(1));
      expect(packagedRows.single.sourceType, 'user_manual');
      expect(packagedRows.single.barcode, '8991234567890');
    },
  );

  testWidgets('mengisi ukuran sajian dan jumlah sajian per kemasan menampilkan '
      'pengingat aritmetika kemasan (task 8.2)', (tester) async {
    final db = await seededDatabase();
    addTearDown(db.close);
    await useDesignViewport(tester);

    await tester.pumpWidget(
      wrapForTest(
        const PackagedFoodManualFillScreen(barcode: '8991234567890'),
        database: db,
        overrides: overridesFor(db),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.textContaining('1 kemasan ='),
      findsNothing,
      reason: 'belum tampil sebelum kedua nilai terisi',
    );

    final servingField = find.widgetWithText(TextField, 'mis. 1 porsi · 180 g');
    await tester.enterText(servingField, '30');
    final unitsField = find.widgetWithText(TextField, 'mis. 2');
    await tester.enterText(unitsField, '2');
    await tester.pumpAndSettle();

    expect(
      find.textContaining('1 kemasan = 2× nilai per sajian (30 g).'),
      findsOneWidget,
    );
  });
}

final class _AlwaysNotFoundClient implements ProductDataSourceClient {
  @override
  Future<RemoteProductLookup?> lookupByBarcode(String barcode) async => null;
}
