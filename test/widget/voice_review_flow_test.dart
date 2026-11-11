import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/app/widgets/mealora_components.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/data/local/drift_profile_repository.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/domain/nutrition/activity_level.dart';
import 'package:mealora/domain/nutrition/biological_input.dart';
import 'package:mealora/domain/profile/user_profile.dart';
import 'package:mealora/domain/shared/units.dart';
import 'package:mealora/domain/voice_input/food_sentence_parser.dart';
import 'package:mealora/domain/voice_input/mock_food_sentence_parser.dart';
import 'package:mealora/domain/voice_input/rule_based_food_sentence_parser.dart';
import 'package:mealora/features/diary/food_photo_review_screen.dart';
import 'package:mealora/features/diary/voice_type_screen.dart';

import 'harness.dart';

/// Change 012, grup 7: hasil penguraian ditinjau di layar peninjauan
/// komponen change 011 (task 7.6) dan dicatat lewat jalur yang sama
/// (task 7.7). Kegagalan di tengah penulisan sudah diuji pada
/// `drift_diary_repository_test.dart` ("menolak seluruhnya, tidak
/// menyisakan satu pun catatan") — jalur suara memakai `addEntries` yang
/// sama (task 7.8).
void main() {
  late AppDatabase database;

  setUp(() async {
    database = createWidgetTestDatabase();
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

  Future<int> entryCount() async =>
      (await database.select(database.mealEntries).get()).length;

  Future<void> parseInto(
    WidgetTester tester,
    List<ParsedFoodItem> items, {
    ParseSource source = ParseSource.service,
  }) async {
    await useDesignViewport(tester);
    await tester.pumpWidget(
      wrapForTest(
        const VoiceTypeScreen(),
        database: database,
        overrides: <Override>[
          profileRepositoryAppOverride,
          programRepositoryAppOverride,
          foodRepositoryAppOverride,
          diaryRepositoryAppOverride,
          foodSentenceParserProvider.overrideWithValue(
            MockFoodSentenceParser.returning(
              ParsedSentence(items: items, source: source),
            ),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'kalimat uji');
    await tester.pump();
    final parse = find.text('Urai kalimat ini');
    await tester.ensureVisible(parse);
    await tester.tap(parse);
    await tester.pumpAndSettle();
  }

  MealoraPrimaryButton confirmButton(WidgetTester tester) =>
      tester.widget<MealoraPrimaryButton>(
        find.descendant(
          of: find.byType(FoodPhotoReviewScreen),
          matching: find.byType(MealoraPrimaryButton),
        ),
      );

  const rice150g = ParsedFoodItem(
    foodName: 'nasi',
    quantity: 150,
    unit: 'g',
    unitStatus: ParsedUnitStatus.standard,
  );

  testWidgets('hasil urai membuka peninjauan komponen change 011, dan '
      'konfirmasi mencatat (task 7.6, 7.7)', (tester) async {
    await parseInto(tester, const <ParsedFoodItem>[rice150g]);

    expect(find.byType(FoodPhotoReviewScreen), findsOneWidget);
    expect(find.text('TINJAU HASIL SUARA'), findsOneWidget);
    expect(await entryCount(), 0);

    expect(confirmButton(tester).onPressed, isNotNull);
    await tester.ensureVisible(find.byType(MealoraPrimaryButton).last);
    confirmButton(tester).onPressed!();
    await tester.pumpAndSettle();

    expect(await entryCount(), 1);
  });

  testWidgets('jumlah yang belum ditentukan menahan konfirmasi dan tidak '
      'ditampilkan sebagai angka (task 7.1, 7.2)', (tester) async {
    await parseInto(tester, const <ParsedFoodItem>[
      rice150g,
      ParsedFoodItem(foodName: 'nasi', unitStatus: ParsedUnitStatus.missing),
    ]);

    expect(find.text('jumlah belum ditentukan'), findsOneWidget);
    expect(confirmButton(tester).onPressed, isNull);
    expect(await entryCount(), 0);
  });

  testWidgets('menutup peninjauan tanpa konfirmasi tidak membuat catatan '
      '(task 7.9)', (tester) async {
    await parseInto(tester, const <ParsedFoodItem>[rice150g]);

    await tester.tap(find.byIcon(Icons.arrow_back).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ya, batalkan').last);
    await tester.pumpAndSettle();

    expect(find.byType(FoodPhotoReviewScreen), findsNothing);
    expect(await entryCount(), 0);
    expect(await database.select(database.foodPhotoDrafts).get(), isEmpty);
  });

  testWidgets('hasil pengurai di perangkat dinyatakan diurai tanpa koneksi '
      '(task 5.10)', (tester) async {
    await parseInto(tester, const <ParsedFoodItem>[
      rice150g,
    ], source: ParseSource.onDevice);

    expect(
      find.text('Diurai tanpa koneksi · periksa lebih teliti'),
      findsOneWidget,
    );
  });
  testWidgets('kalimat bercampur: hanya makanan yang masuk peninjauan, sisanya '
      'diabaikan dan dinyatakan (task 6.2)', (tester) async {
    await useDesignViewport(tester);
    await tester.pumpWidget(
      wrapForTest(
        const VoiceTypeScreen(),
        database: database,
        overrides: <Override>[
          profileRepositoryAppOverride,
          programRepositoryAppOverride,
          foodRepositoryAppOverride,
          diaryRepositoryAppOverride,
          foodSentenceParserProvider.overrideWithValue(
            const RuleBasedFoodSentenceParser(),
          ),
        ],
      ),
    );
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextField),
      'buka pengaturan dong, oh iya tadi makan nasi seratus gram',
    );
    await tester.pump();
    final parse = find.text('Urai kalimat ini');
    await tester.ensureVisible(parse);
    await tester.tap(parse);
    await tester.pumpAndSettle();

    expect(find.byType(FoodPhotoReviewScreen), findsOneWidget);
    expect(
      find.text('Bagian di luar makanan diabaikan, tidak dijalankan.'),
      findsOneWidget,
    );
    expect(find.text('Nasi'), findsWidgets);
    expect(await entryCount(), 0);
  });
}
