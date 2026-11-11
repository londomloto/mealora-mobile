import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/app/theme/app_theme.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/clock/fixed_clock.dart';
import 'package:mealora/core/errors/failure.dart';
import 'package:mealora/core/errors/result.dart';
import 'package:mealora/core/ids/sequential_id_generator.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/data/local/drift_food_repository.dart';
import 'package:mealora/data/local/drift_profile_repository.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/domain/diary/diary_repository.dart';
import 'package:mealora/domain/diary/meal_entry.dart';
import 'package:mealora/domain/food/food.dart';
import 'package:mealora/domain/food/meal_time.dart';
import 'package:mealora/domain/food/serving_size.dart';
import 'package:mealora/domain/profile/user_profile.dart';
import 'package:mealora/features/diary/diary_controller.dart';
import 'package:mealora/features/diary/serving_detail_screen.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

import 'harness.dart';

/// Peringatan makan menjelang tidur lewat jalur katalog/serving (change 013,
/// task 4.5).
void main() {
  // Satu pembangkit untuk seluruh berkas supaya pencatatan berulang di
  // basis data yang sama tidak bertabrakan ID.
  final ids = SequentialIdGenerator(prefix: 'late');
  const title = 'Sudah dekat jam tidur.';

  /// 2026-11-08 21:15 WIB — di dalam rentang untuk jam tidur bawaan 22:00.
  FixedClock eveningClock() => FixedClock(
    instantUtc: DateTime.utc(2026, 11, 8, 14, 15),
    timeZoneId: 'Asia/Jakarta',
    utcOffset: const Duration(hours: 7),
  );

  Future<(AppDatabase, Food)> seeded() async {
    final db = createWidgetTestDatabase();
    await DriftProfileRepository(
      db,
      clock: eveningClock(),
    ).upsert(const UserProfile(id: 'profile-1'));
    final foods = await DriftFoodRepository(
      db,
      ids: SequentialIdGenerator(),
      clock: eveningClock(),
    ).search('nasi');
    return (db, foods.first);
  }

  Future<void> logOnce(
    WidgetTester tester, {
    required AppDatabase db,
    required Food food,
    required Clock clock,
    LocalDate? date,
    List<Override> extra = const <Override>[],
  }) async {
    await tester.pumpWidget(
      ProviderScope(
        key: UniqueKey(),
        overrides: <Override>[
          clockProvider.overrideWithValue(clock),
          idGeneratorProvider.overrideWithValue(ids),
          appDatabaseProvider.overrideWithValue(db),
          profileRepositoryAppOverride,
          foodRepositoryAppOverride,
          if (extra.isEmpty) diaryRepositoryAppOverride,
          ...extra,
        ],
        child: MaterialApp(
          theme: MealoraTheme.light(),
          localizationsDelegates: AppText.localizationsDelegates,
          supportedLocales: AppText.supportedLocales,
          locale: const Locale('id'),
          home: ServingDetailScreen(food: food, date: date),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final save = find.textContaining('Tambahkan ke');
    await tester.ensureVisible(save);
    await tester.tap(save);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> dismissSnackBars(WidgetTester tester) async {
    await tester.pump(const Duration(seconds: 10));
    await tester.pumpAndSettle();
  }

  testWidgets('tampil sekali, lalu tidak tampil lagi di malam yang sama', (
    tester,
  ) async {
    await useDesignViewport(tester);
    final (db, food) = await seeded();
    addTearDown(db.close);
    final clock = eveningClock();

    await logOnce(tester, db: db, food: food, clock: clock);
    expect(find.text(title), findsOneWidget);
    await dismissSnackBars(tester);

    clock.advance(const Duration(minutes: 25));
    await logOnce(tester, db: db, food: food, clock: clock);
    expect(find.text(title), findsNothing);
    await dismissSnackBars(tester);

    // Malam berikutnya di dalam rentang → tampil lagi.
    clock.advance(const Duration(hours: 24));
    await logOnce(tester, db: db, food: food, clock: clock);
    expect(find.text(title), findsOneWidget);
    await dismissSnackBars(tester);
  });

  testWidgets('tidak tampil saat mencatat untuk tanggal lampau', (
    tester,
  ) async {
    await useDesignViewport(tester);
    final (db, food) = await seeded();
    addTearDown(db.close);

    await logOnce(
      tester,
      db: db,
      food: food,
      clock: eveningClock(),
      date: const LocalDate(2026, 11, 7),
    );
    expect(find.text(title), findsNothing);
    await dismissSnackBars(tester);
  });

  testWidgets('tidak tampil di luar rentang', (tester) async {
    await useDesignViewport(tester);
    final (db, food) = await seeded();
    addTearDown(db.close);

    await logOnce(tester, db: db, food: food, clock: createWidgetTestClock());
    expect(find.text(title), findsNothing);
    await dismissSnackBars(tester);
  });

  testWidgets('tidak tampil bila penyimpanan gagal', (tester) async {
    await useDesignViewport(tester);
    final (db, food) = await seeded();
    addTearDown(db.close);

    await logOnce(
      tester,
      db: db,
      food: food,
      clock: eveningClock(),
      extra: <Override>[
        diaryRepositoryProvider.overrideWithValue(_FailingDiaryRepository()),
      ],
    );
    expect(find.text(title), findsNothing);
    expect(find.byType(ServingDetailScreen), findsOneWidget);
    await dismissSnackBars(tester);
  });
}

class _FailingDiaryRepository implements DiaryRepository {
  @override
  Future<Result<MealEntry>> addEntry({
    required String profileId,
    required LocalDate date,
    required MealTime mealTime,
    required Food food,
    required ServingSize serving,
    required double quantity,
  }) async => const Err<MealEntry>(Failure(FailureCode.storageUnavailable));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
