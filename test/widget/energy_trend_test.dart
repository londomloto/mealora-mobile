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
import 'package:mealora/database/app_database.dart';
import 'package:mealora/domain/diary/energy_trend.dart';
import 'package:mealora/domain/food/food_category.dart';
import 'package:mealora/domain/food/food_repository.dart';
import 'package:mealora/domain/food/meal_time.dart';
import 'package:mealora/domain/food/nutrition_profile.dart';
import 'package:mealora/domain/preferences/week_start.dart';
import 'package:mealora/domain/profile/user_profile.dart';
import 'package:mealora/domain/shared/units.dart';
import 'package:mealora/features/energy/energy_monitor_screen.dart';
import 'package:mealora/features/energy/widgets/energy_line_chart.dart';
import 'package:mealora/features/energy/widgets/energy_week_card.dart';
import 'package:mealora/features/history/history_screen.dart';

import 'harness.dart';

/// Pantauan energi (change 018): kartu minggu berjalan, layar pantauan,
/// pemilih rentang, dan navigasi ke Riwayat. Jam uji: Minggu 8 Nov 2026.
void main() {
  const profileId = 'profile-1';

  /// 3 Nov: 500 kkal; 5 Nov: 1.000 kkal (dua waktu makan); 8 Nov: 500 kkal.
  Future<AppDatabase> seeded({bool withEntries = true}) async {
    final db = createWidgetTestDatabase();
    await DriftProfileRepository(
      db,
      clock: createWidgetTestClock(),
    ).upsert(const UserProfile(id: profileId));
    if (!withEntries) {
      return db;
    }
    final foods = DriftFoodRepository(
      db,
      ids: SequentialIdGenerator(),
      clock: createWidgetTestClock(),
    );
    final diary = DriftDiaryRepository(
      db,
      clock: createWidgetTestClock(),
      ids: SequentialIdGenerator(),
      programRepository: DriftProgramRepository(
        db,
        clock: createWidgetTestClock(),
        ids: SequentialIdGenerator(),
      ),
    );
    final created = await foods.createUserFood(
      name: 'Nasi campur',
      category: FoodCategory.other,
      serving: ServingSizeInput(
        label: '1 porsi',
        amount: 1,
        unit: 'porsi',
        nutrition: NutritionProfile(
          energy: Energy.kcalValue(500, field: 'e').valueOrNull,
          proteinG: 10,
          carbohydrateG: 60,
          fatG: 15,
        ),
      ),
    );
    final food = (await foods.findById(created.id))!;
    Future<void> log(int day, MealTime time) => diary.addEntry(
      profileId: profileId,
      date: LocalDate(2026, 11, day),
      mealTime: time,
      food: food,
      serving: food.defaultServing,
      quantity: 1,
    );
    await log(3, MealTime.lunch);
    await log(5, MealTime.breakfast);
    await log(5, MealTime.dinner);
    await log(8, MealTime.lunch);
    return db;
  }

  List<Override> overrides({WeekStart? weekStart}) => <Override>[
    profileRepositoryAppOverride,
    programRepositoryAppOverride,
    foodRepositoryAppOverride,
    diaryRepositoryAppOverride,
    weightRepositoryAppOverride,
    if (weekStart != null)
      weekStartProvider.overrideWith(() => _FixedWeekStart(weekStart)),
  ];

  Future<AppDatabase> pump(
    WidgetTester tester,
    Widget child, {
    bool withEntries = true,
    WeekStart? weekStart,
    double textScale = 1,
  }) async {
    await useDesignViewport(tester);
    final db = await seeded(withEntries: withEntries);
    addTearDown(db.close);
    await tester.pumpWidget(
      wrapForTest(
        child,
        database: db,
        textScale: textScale,
        overrides: overrides(weekStart: weekStart),
      ),
    );
    await tester.pumpAndSettle();
    return db;
  }

  group('EnergyLineChart', () {
    testWidgets('hari kosong dibacakan belum dicatat, bukan 0 kkal', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrapForTest(
          Center(
            child: SizedBox(
              width: 300,
              child: EnergyLineChart(
                days: const <DailyEnergy>[
                  DailyEnergy(
                    date: LocalDate(2026, 11, 6),
                    state: DailyEnergyState.recorded,
                    kcal: 1800,
                  ),
                  DailyEnergy(
                    date: LocalDate(2026, 11, 7),
                    state: DailyEnergyState.notRecorded,
                  ),
                  DailyEnergy(
                    date: LocalDate(2026, 11, 8),
                    state: DailyEnergyState.unknown,
                  ),
                ],
                labels: const <String>['6', '7', '8'],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.bySemanticsLabel('6 Nov 2026, 1.800 kkal'), findsOneWidget);
      expect(
        find.bySemanticsLabel('7 Nov 2026, belum dicatat'),
        findsOneWidget,
      );
      expect(
        find.bySemanticsLabel('8 Nov 2026, energi belum diketahui'),
        findsOneWidget,
      );
      expect(find.textContaining('0 kkal'), findsNothing);
    });

    testWidgets('rentang 365 hari dapat digeser mendatar', (tester) async {
      final days = <DailyEnergy>[
        for (final d in datesBetween(
          const LocalDate(2025, 11, 9),
          const LocalDate(2026, 11, 8),
        ))
          DailyEnergy(date: d, state: DailyEnergyState.recorded, kcal: 1800),
      ];
      await tester.pumpWidget(
        wrapForTest(
          Center(
            child: SizedBox(
              width: 300,
              child: EnergyLineChart(
                days: days,
                labels: <String>[for (final d in days) '${d.date.day}'],
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(EnergyLineChart),
          matching: find.byType(SingleChildScrollView),
        ),
        findsOneWidget,
      );
      // Dibuka di ujung kanan: tanggal terbaru terlihat.
      expect(find.bySemanticsLabel('8 Nov 2026, 1.800 kkal'), findsOneWidget);
    });
  });

  group('EnergyWeekCard', () {
    testWidgets('awal minggu Senin: rata-rata dari hari tercatat saja', (
      tester,
    ) async {
      await pump(
        tester,
        const SingleChildScrollView(child: EnergyWeekCard()),
        weekStart: WeekStart.monday,
      );

      expect(find.text('Energi minggu ini'), findsOneWidget);
      // 2–8 Nov: 3, 5, 8 tercatat → (500 + 1.000 + 500) / 3.
      expect(find.text('Rata-rata 667 kkal · 3 hari tercatat'), findsOneWidget);
      expect(find.text('belum'), findsNWidgets(4));
    });

    testWidgets('awal minggu Minggu: minggu baru dimulai hari ini', (
      tester,
    ) async {
      await pump(
        tester,
        const SingleChildScrollView(child: EnergyWeekCard()),
        weekStart: WeekStart.sunday,
      );

      expect(find.text('Rata-rata 500 kkal · 1 hari tercatat'), findsOneWidget);
      // Tanggal setelah hari ini tidak ditandai belum dicatat.
      expect(find.text('belum'), findsNothing);
    });

    testWidgets('ketuk kartu membuka pantauan energi', (tester) async {
      await pump(tester, const SingleChildScrollView(child: EnergyWeekCard()));
      await tester.tap(find.text('Energi minggu ini'));
      await tester.pumpAndSettle();
      expect(find.byType(EnergyMonitorScreen), findsOneWidget);
    });
  });

  group('EnergyMonitorScreen', () {
    testWidgets('rentang bawaan tujuh hari terakhir dan ringkasannya', (
      tester,
    ) async {
      await pump(tester, const EnergyMonitorScreen());

      expect(find.text('2 Nov 2026 – 8 Nov 2026'), findsOneWidget);
      expect(find.text('667 kkal'), findsOneWidget);
      expect(find.text('RATA-RATA · 3 DARI 7 HARI TERCATAT'), findsOneWidget);
      expect(
        find.text(
          'Tidak ada target program pada rentang ini · 4 hari belum dicatat',
        ),
        findsOneWidget,
      );
    });

    testWidgets('ketuk tanggal lalu buka Riwayat pada tanggal itu', (
      tester,
    ) async {
      await pump(tester, const EnergyMonitorScreen());

      await tester.tap(find.bySemanticsLabel('5 Nov 2026, 1.000 kkal'));
      await tester.pumpAndSettle();
      expect(find.text('5 Nov 2026 · 1.000 kkal'), findsOneWidget);

      await tester.tap(find.text('Buka Riwayat'));
      await tester.pumpAndSettle();
      final history = tester.widget<HistoryCalendarScreen>(
        find.byType(HistoryCalendarScreen),
      );
      expect(history.initialDate, const LocalDate(2026, 11, 5));
      expect(find.text('5 Nov · Kamis'), findsOneWidget);
    });

    testWidgets('memilih rentang lewat kalender', (tester) async {
      await pump(tester, const EnergyMonitorScreen());

      await tester.tap(find.text('Ubah'));
      await tester.pumpAndSettle();
      expect(find.text('Pilih rentang tanggal'), findsOneWidget);

      // Tanggal sebelum catatan pertama (1 Nov) dan setelah hari ini (9 Nov)
      // tidak dapat dipilih.
      await tester.tap(find.bySemanticsLabel('9 Nov 2026'));
      await tester.tap(find.bySemanticsLabel('1 Nov 2026'));
      await tester.pumpAndSettle();
      expect(find.text('7 hari'), findsOneWidget);

      // Ketuk akhir lebih awal dari mulai → ditukar.
      await tester.tap(find.bySemanticsLabel('5 Nov 2026'));
      await tester.tap(find.bySemanticsLabel('3 Nov 2026'));
      await tester.pumpAndSettle();
      expect(find.text('3 hari'), findsOneWidget);

      await tester.tap(find.text('Terapkan'));
      await tester.pumpAndSettle();
      expect(find.text('3 Nov 2026 – 5 Nov 2026'), findsOneWidget);
      expect(find.text('750 kkal'), findsOneWidget);
    });

    testWidgets('rentang tanpa catatan menampilkan keadaan kosong', (
      tester,
    ) async {
      await pump(tester, const EnergyMonitorScreen(), withEntries: false);

      expect(find.text('Belum ada catatan energi'), findsOneWidget);
      expect(find.text('Catat makanan'), findsOneWidget);
      expect(find.byType(EnergyLineChart), findsNothing);
    });

    for (final scale in <double>[1, 1.5]) {
      testWidgets('tanpa overflow pada skala teks $scale', (tester) async {
        await pump(tester, const EnergyMonitorScreen(), textScale: scale);
        expect(tester.takeException(), isNull);
        await pump(
          tester,
          const SingleChildScrollView(child: EnergyWeekCard()),
          textScale: scale,
        );
        expect(tester.takeException(), isNull);
      });
    }
  });

  testWidgets(
    'Riwayat tanpa tanggal awal tetap hari ini; masa depan diabaikan',
    (tester) async {
      await pump(
        tester,
        const HistoryCalendarScreen(initialDate: LocalDate(2026, 11, 20)),
      );
      // Tanggal masa depan jatuh ke hari ini (Minggu, 8 November 2026).
      expect(find.text('8 Nov · Minggu'), findsOneWidget);
    },
  );
}

class _FixedWeekStart extends WeekStartSetting {
  _FixedWeekStart(this.value);

  final WeekStart value;

  @override
  Future<WeekStart> build() async => value;
}
