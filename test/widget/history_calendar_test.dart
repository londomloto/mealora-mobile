import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/ids/sequential_id_generator.dart';
import 'package:mealora/data/local/drift_diary_repository.dart';
import 'package:mealora/data/local/drift_food_repository.dart';
import 'package:mealora/data/local/drift_profile_repository.dart';
import 'package:mealora/data/local/drift_program_repository.dart';
import 'package:mealora/data/local/drift_weight_repository.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/domain/food/food_category.dart';
import 'package:mealora/domain/food/food_repository.dart';
import 'package:mealora/domain/food/meal_time.dart';
import 'package:mealora/domain/food/nutrition_profile.dart';
import 'package:mealora/domain/profile/user_profile.dart';
import 'package:mealora/domain/shared/units.dart';
import 'package:mealora/features/history/history_screen.dart';

import 'harness.dart';

/// `18 · Riwayat harian` (change 008, task 5.1–5.10): kalender menandai hari
/// berisi catatan tanpa bergantung warna saja, tanggal masa depan tidak
/// bisa dipilih, ringkasan tanggal terpilih memakai ulang komponen `_Diary
/// Body`/`_UnknownDiaryBody` (bukan komponen kedua), dan hari tanpa catatan
/// dinyatakan "belum diketahui", bukan 0 kkal.
void main() {
  const profileId = 'profile-1';
  // FixedClock widget-test: 2026-11-08 (lihat harness.dart).
  const today = LocalDate(2026, 11, 8);
  const pastWithFood = LocalDate(2026, 11, 3);
  const pastWithWeight = LocalDate(2026, 11, 2);
  const pastEmpty = LocalDate(2026, 11, 1);

  Future<AppDatabase> seededDatabase() async {
    final db = createWidgetTestDatabase();
    await DriftProfileRepository(
      db,
      clock: createWidgetTestClock(),
    ).upsert(const UserProfile(id: profileId));

    final programRepository = DriftProgramRepository(
      db,
      clock: createWidgetTestClock(),
      ids: SequentialIdGenerator(),
    );
    final foodRepository = DriftFoodRepository(
      db,
      ids: SequentialIdGenerator(),
      clock: createWidgetTestClock(),
    );
    final diaryRepository = DriftDiaryRepository(
      db,
      clock: createWidgetTestClock(),
      ids: SequentialIdGenerator(),
      programRepository: programRepository,
    );
    final food = await foodRepository.createUserFood(
      name: 'Nasi uduk',
      category: FoodCategory.other,
      serving: const ServingSizeInput(
        label: '1 porsi',
        amount: 1,
        unit: 'porsi',
        nutrition: NutritionProfile(
          energy: Energy.zero,
          proteinG: 20,
          carbohydrateG: 40,
          fatG: 10,
        ),
      ),
    );
    final loaded = (await foodRepository.findById(food.id))!;
    await diaryRepository.addEntry(
      profileId: profileId,
      date: pastWithFood,
      mealTime: MealTime.breakfast,
      food: loaded,
      serving: loaded.defaultServing,
      quantity: 1,
    );

    await DriftWeightRepository(
      db,
      clock: createWidgetTestClock(),
      ids: SequentialIdGenerator(),
      diaryRepository: diaryRepository,
    ).addRecord(profileId: profileId, date: pastWithWeight, weightKg: 68.4);

    return db;
  }

  List<Override> overridesFor() => <Override>[
    profileRepositoryAppOverride,
    programRepositoryAppOverride,
    foodRepositoryAppOverride,
    diaryRepositoryAppOverride,
    weightRepositoryAppOverride,
  ];

  Finder dayCell(int day) =>
      find.ancestor(of: find.text('$day'), matching: find.byType(InkWell));

  testWidgets('hari tanpa catatan dinyatakan belum diketahui, bukan 0 kkal', (
    tester,
  ) async {
    final db = await seededDatabase();
    addTearDown(db.close);

    await tester.pumpWidget(
      wrapForTest(
        const HistoryCalendarScreen(),
        database: db,
        overrides: overridesFor(),
      ),
    );
    await tester.pumpAndSettle();

    // Hari ini (8 Nov) belum punya catatan apa pun di fixture ini.
    expect(find.text('Belum tercatat'), findsOneWidget);
    expect(find.text('Belum diketahui'), findsOneWidget);
  });

  testWidgets(
    'memilih tanggal berisi catatan makan menampilkan ringkasan nyata, '
    'bukan keadaan kosong',
    (tester) async {
      final db = await seededDatabase();
      addTearDown(db.close);

      await tester.pumpWidget(
        wrapForTest(
          const HistoryCalendarScreen(),
          database: db,
          overrides: overridesFor(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(dayCell(pastWithFood.day).first);
      await tester.pumpAndSettle();

      expect(find.text('Nasi uduk'), findsOneWidget);
      expect(find.text('Belum tercatat'), findsNothing);
    },
  );

  testWidgets(
    'memilih tanggal dengan catatan berat menampilkan baris berat tercatat',
    (tester) async {
      final db = await seededDatabase();
      addTearDown(db.close);

      await tester.pumpWidget(
        wrapForTest(
          const HistoryCalendarScreen(),
          database: db,
          overrides: overridesFor(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(dayCell(pastWithWeight.day).first);
      await tester.pumpAndSettle();

      expect(find.textContaining('68,4'), findsOneWidget);
    },
  );

  testWidgets('tanggal tanpa catatan tidak menampilkan baris berat', (
    tester,
  ) async {
    final db = await seededDatabase();
    addTearDown(db.close);

    await tester.pumpWidget(
      wrapForTest(
        const HistoryCalendarScreen(),
        database: db,
        overrides: overridesFor(),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(dayCell(pastEmpty.day).first);
    await tester.pumpAndSettle();

    expect(find.textContaining('68,4'), findsNothing);
  });

  testWidgets('tanggal masa depan tidak bisa dipilih', (tester) async {
    final db = await seededDatabase();
    addTearDown(db.close);

    await tester.pumpWidget(
      wrapForTest(
        const HistoryCalendarScreen(),
        database: db,
        overrides: overridesFor(),
      ),
    );
    await tester.pumpAndSettle();

    // 9 Nov 2026 ada di bulan yang sama dan berada sehari setelah "hari
    // ini" pada jam uji — mencoba menyentuhnya tidak boleh mengubah
    // tanggal terpilih (tetap menampilkan ringkasan 8 Nov).
    final future = dayCell(today.day + 1);
    expect(future, findsOneWidget);
    await tester.tap(future, warnIfMissed: false);
    await tester.pumpAndSettle();

    expect(find.textContaining('9 Nov'), findsNothing);
  });

  testWidgets(
    'setiap tanggal mengumumkan ada/tidaknya catatan dan keadaan terpilih '
    '(task 6.2)',
    (tester) async {
      final db = await seededDatabase();
      addTearDown(db.close);
      final handle = tester.ensureSemantics();

      await tester.pumpWidget(
        wrapForTest(
          const HistoryCalendarScreen(),
          database: db,
          overrides: overridesFor(),
        ),
      );
      await tester.pumpAndSettle();

      // Hari ini (8 Nov), belum ada catatan, dan sedang terpilih.
      expect(
        find.bySemanticsLabel('8 Nov 2026, belum ada catatan, terpilih'),
        findsOneWidget,
      );
      // 3 Nov sudah ada catatan makan.
      expect(find.bySemanticsLabel('3 Nov 2026, ada catatan'), findsOneWidget);
      // 9 Nov (besok) belum bisa dipilih.
      expect(
        find.bySemanticsLabel(
          '9 Nov 2026, belum ada catatan, belum bisa dipilih',
        ),
        findsOneWidget,
      );
      handle.dispose();
    },
  );

  testWidgets('tetap terbaca pada skala teks besar', (tester) async {
    final db = await seededDatabase();
    addTearDown(db.close);
    await useDesignViewport(tester);

    await tester.pumpWidget(
      wrapForTest(
        const HistoryCalendarScreen(),
        database: db,
        overrides: overridesFor(),
        textScale: 2,
      ),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
  });
}
