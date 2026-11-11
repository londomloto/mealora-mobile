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
import 'package:mealora/features/diary/packaged_food_not_found_screen.dart';

import 'harness.dart';

/// Skala teks besar di seluruh layar barcode/produk kemasan (task 6.6/8.3)
/// — `BarcodeScanScreen` diverifikasi terpisah di perangkat Android (task
/// 8.5) karena bergantung pada kamera sungguhan; tiga layar lain di sini
/// tidak bergantung pada kamera, jadi diverifikasi langsung lewat
/// `flutter test` pada skala 2x.
void main() {
  Future<AppDatabase> seededDatabase() async {
    final db = createWidgetTestDatabase();
    await DriftProfileRepository(
      db,
      clock: createWidgetTestClock(),
    ).upsert(const UserProfile(id: 'profile-1'));
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
        client: _NeverCalledClient(),
      ),
    ),
  ];

  testWidgets('BarcodeManualEntryScreen tetap terbaca pada skala 2x', (
    tester,
  ) async {
    final db = await seededDatabase();
    addTearDown(db.close);

    await tester.pumpWidget(
      wrapForTest(
        const BarcodeManualEntryScreen(),
        database: db,
        overrides: overridesFor(db),
        textScale: 2,
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      find.byIcon(Icons.arrow_back),
      findsOneWidget,
      reason:
          'layar yang dibuka lewat push SHALL selalu punya jalan '
          'kembali yang terlihat, bukan hanya gestur OS/browser',
    );
  });

  testWidgets('PackagedFoodNotFoundScreen tetap terbaca pada skala 2x', (
    tester,
  ) async {
    final db = await seededDatabase();
    addTearDown(db.close);

    await tester.pumpWidget(
      wrapForTest(
        const PackagedFoodNotFoundScreen(barcode: '8991234567890'),
        database: db,
        overrides: overridesFor(db),
        textScale: 2,
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      find.byIcon(Icons.arrow_back),
      findsOneWidget,
      reason:
          'layar yang dibuka lewat push SHALL selalu punya jalan '
          'kembali yang terlihat, bukan hanya gestur OS/browser',
    );
  });

  testWidgets('PackagedFoodManualFillScreen tetap terbaca pada skala 2x', (
    tester,
  ) async {
    final db = await seededDatabase();
    addTearDown(db.close);

    await tester.pumpWidget(
      wrapForTest(
        const PackagedFoodManualFillScreen(barcode: '8991234567890'),
        database: db,
        overrides: overridesFor(db),
        textScale: 2,
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(
      find.byIcon(Icons.arrow_back),
      findsOneWidget,
      reason:
          'layar yang dibuka lewat push SHALL selalu punya jalan '
          'kembali yang terlihat, bukan hanya gestur OS/browser',
    );
  });
}

final class _NeverCalledClient implements ProductDataSourceClient {
  @override
  Future<RemoteProductLookup?> lookupByBarcode(String barcode) {
    throw StateError('tidak dipanggil pada uji ini');
  }
}
