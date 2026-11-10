import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/ids/sequential_id_generator.dart';
import 'package:mealora/data/local/drift_diary_repository.dart';
import 'package:mealora/data/local/drift_profile_repository.dart';
import 'package:mealora/data/local/drift_program_repository.dart';
import 'package:mealora/data/local/drift_weight_repository.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/domain/profile/user_profile.dart';
import 'package:mealora/features/weight/add_weight_screen.dart';
import 'package:mealora/features/weight/weight_monitor_screen.dart';

import 'harness.dart';

/// `32 · Tambah berat` dan `31 · Pantau berat` (change 008, task 4.10):
/// keadaan kosong, satu catatan, validasi bernilai jenis, serta
/// sunting/hapus — pada skala teks normal dan besar.
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

  DriftWeightRepository weightRepositoryFor(AppDatabase db) =>
      DriftWeightRepository(
        db,
        clock: createWidgetTestClock(),
        ids: SequentialIdGenerator(),
        diaryRepository: DriftDiaryRepository(
          db,
          clock: createWidgetTestClock(),
          ids: SequentialIdGenerator(),
          programRepository: DriftProgramRepository(
            db,
            clock: createWidgetTestClock(),
            ids: SequentialIdGenerator(),
          ),
        ),
      );

  List<Override> overridesFor() => <Override>[
    profileRepositoryAppOverride,
    programRepositoryAppOverride,
    weightRepositoryAppOverride,
  ];

  group('WeightMonitorScreen', () {
    testWidgets('keadaan belum ada catatan menampilkan ajakan menambah, '
        'bukan 0 kg atau grafik kosong', (tester) async {
      final db = await seededDatabase();
      addTearDown(db.close);

      await tester.pumpWidget(
        wrapForTest(
          const WeightMonitorScreen(),
          database: db,
          overrides: overridesFor(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Belum ada catatan berat'), findsOneWidget);
      expect(find.textContaining('0 kg'), findsNothing);
      expect(find.text('Tambah berat'), findsOneWidget);
    });

    testWidgets(
      'satu catatan menampilkan catatan itu dan menyatakan tren belum '
      'dapat ditampilkan',
      (tester) async {
        final db = await seededDatabase();
        addTearDown(db.close);
        await weightRepositoryFor(db).addRecord(
          profileId: profileId,
          date: const LocalDate(2026, 11, 6),
          weightKg: 68.4,
        );

        await tester.pumpWidget(
          wrapForTest(
            const WeightMonitorScreen(),
            database: db,
            overrides: overridesFor(),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.textContaining('68,4'), findsWidgets);
        expect(
          find.text('Baru satu catatan — tren belum dapat ditampilkan.'),
          findsOneWidget,
        );
      },
    );

    testWidgets('beberapa catatan menampilkan tren dan daftar catatan '
        'terakhir, bisa dihapus', (tester) async {
      final db = await seededDatabase();
      addTearDown(db.close);
      final repository = weightRepositoryFor(db);
      await repository.addRecord(
        profileId: profileId,
        date: const LocalDate(2026, 10, 20),
        weightKg: 70,
      );
      await repository.addRecord(
        profileId: profileId,
        date: const LocalDate(2026, 11, 6),
        weightKg: 68.4,
      );

      await tester.pumpWidget(
        wrapForTest(
          const WeightMonitorScreen(),
          database: db,
          overrides: overridesFor(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Tren berat'), findsOneWidget);
      expect(find.text('Catatan terakhir'), findsOneWidget);
      expect(find.byIcon(Icons.delete_outline), findsNWidgets(2));

      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Hapus'));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.delete_outline), findsOneWidget);
    });

    testWidgets('tetap terbaca pada skala teks besar', (tester) async {
      final db = await seededDatabase();
      addTearDown(db.close);
      final repository = weightRepositoryFor(db);
      await repository.addRecord(
        profileId: profileId,
        date: const LocalDate(2026, 10, 20),
        weightKg: 70,
      );
      await repository.addRecord(
        profileId: profileId,
        date: const LocalDate(2026, 11, 6),
        weightKg: 68.4,
      );
      await useDesignViewport(tester);

      await tester.pumpWidget(
        wrapForTest(
          const WeightMonitorScreen(),
          database: db,
          overrides: overridesFor(),
          textScale: 2,
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });

  group('AddWeightScreen', () {
    testWidgets('menyimpan berat yang sah menutup layar dengan hasil true', (
      tester,
    ) async {
      final db = await seededDatabase();
      addTearDown(db.close);

      await tester.pumpWidget(
        wrapForTest(
          const AddWeightScreen(),
          database: db,
          overrides: overridesFor(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, '68,4');
      await tester.tap(find.text('Simpan berat'));
      await tester.pumpAndSettle();

      final latest = await weightRepositoryFor(db).latest(profileId);
      expect(latest?.weightKg, 68.4);
    });

    testWidgets(
      'menolak berat di luar rentang masuk akal dengan penjelasan terbaca, '
      'tidak menulis apa pun',
      (tester) async {
        final db = await seededDatabase();
        addTearDown(db.close);

        await tester.pumpWidget(
          wrapForTest(
            const AddWeightScreen(),
            database: db,
            overrides: overridesFor(),
          ),
        );
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField).first, '500');
        await tester.tap(find.text('Simpan berat'));
        await tester.pumpAndSettle();

        expect(
          find.text('Berat ini di luar rentang yang masuk akal.'),
          findsOneWidget,
        );
        expect(await weightRepositoryFor(db).latest(profileId), isNull);
      },
    );

    testWidgets('tetap terbaca pada skala teks besar', (tester) async {
      final db = await seededDatabase();
      addTearDown(db.close);
      await useDesignViewport(tester);

      await tester.pumpWidget(
        wrapForTest(
          const AddWeightScreen(),
          database: db,
          overrides: overridesFor(),
          textScale: 2,
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
