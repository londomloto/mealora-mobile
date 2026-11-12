import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/core/ids/sequential_id_generator.dart';
import 'package:mealora/data/local/drift_diary_repository.dart';
import 'package:mealora/data/local/drift_food_repository.dart';
import 'package:mealora/data/local/drift_photo_draft_repository.dart';
import 'package:mealora/data/local/drift_profile_repository.dart';
import 'package:mealora/data/local/drift_program_repository.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/domain/food/food_category.dart';
import 'package:mealora/domain/food/food_repository.dart';
import 'package:mealora/domain/food/meal_time.dart';
import 'package:mealora/domain/food/nutrition_profile.dart';
import 'package:mealora/domain/food/partial_nutrition_total.dart';
import 'package:mealora/domain/food_photo_input/photo_draft.dart';
import 'package:mealora/domain/profile/user_profile.dart';
import 'package:mealora/domain/shared/units.dart';
import 'package:mealora/features/diary/custom_food_screen.dart';
import 'package:mealora/features/diary/food_photo_review_screen.dart';
import 'package:mealora/features/history/history_screen.dart';
import 'package:mealora/features/share/daily_summary_share_card.dart';
import 'package:mealora/features/share/meal_share_card.dart';
import 'package:mealora/features/share/share_card_frame.dart';
import 'package:mealora/features/share/share_preview_screen.dart';
import 'package:mealora/features/share/share_service.dart';
import 'package:mealora/features/today/today_screen.dart';

import 'harness.dart';

/// Change 021, task 5.1: total jujur di tinjau foto, melengkapi komponen
/// tanpa padanan, dan berbagi tanpa mencatat.
void main() {
  late AppDatabase database;
  const profileId = 'test-profile';

  PhotoDraftComponent unmatched(String id, String name) => PhotoDraftComponent(
    localId: id,
    foodNameGuess: name,
    quantity: 1,
    quantityUnitLabel: 'potong',
    portionNeedsCheck: false,
    cookingMethodNeedsCheck: false,
  );

  setUp(() async {
    database = createWidgetTestDatabase();
    await DriftProfileRepository(
      database,
      clock: createWidgetTestClock(),
    ).upsert(const UserProfile(id: profileId, isOnboardingComplete: true));
  });

  tearDown(() => database.close());

  Future<PhotoDraft> saveDraft() async {
    final draft = PhotoDraft(
      id: 'draft-021',
      profileId: profileId,
      localDate: createWidgetTestClock().today(),
      mealTime: MealTime.snack,
      sourceImagePath: null,
      createdAt: createWidgetTestClock().nowUtc(),
      components: <PhotoDraftComponent>[
        const PhotoDraftComponent(
          localId: 'c-nasi',
          foodNameGuess: 'Nasi putih',
          matchedFoodId: 'food-tkpi-921',
          matchedFoodName: 'Nasi putih',
          quantity: 1,
          portionNeedsCheck: false,
          cookingMethodNeedsCheck: false,
        ),
        unmatched('c-cheesecake', 'Cheesecake'),
        unmatched('c-muffin', 'Muffin'),
        unmatched('c-kue', 'Kue kering'),
      ],
    );
    await DriftPhotoDraftRepository(
      database,
      clock: createWidgetTestClock(),
    ).save(draft);
    return draft;
  }

  Future<void> pumpReview(WidgetTester tester, PhotoDraft draft) async {
    await useDesignViewport(tester);
    await tester.pumpWidget(
      wrapForTest(
        FoodPhotoReviewScreen(draft: draft),
        database: database,
        overrides: <Override>[
          profileRepositoryAppOverride,
          programRepositoryAppOverride,
          foodRepositoryAppOverride,
          diaryRepositoryAppOverride,
          photoDraftRepositoryAppOverride,
          shareCardServiceProvider.overrideWithValue(_NoopShareService()),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  testWidgets('total tidak menghitung komponen tanpa padanan sebagai nol, '
      'dan tombol utama berbunyi "Lengkapi 3 bahan"', (tester) async {
    await pumpReview(tester, await saveDraft());

    expect(find.textContaining('+ 3 belum diketahui'), findsOneWidget);
    expect(find.text('belum ada di katalog'), findsNWidgets(3));
    expect(find.text('Lengkapi'), findsNWidgets(3));
    expect(find.text('Lengkapi 3 bahan'), findsOneWidget);
    expect(find.text('Konfirmasi & catat'), findsNothing);
    expect(find.text('Bagikan saja tanpa mencatat'), findsOneWidget);
  });

  testWidgets('Buat makanan ini: batal tetap belum lengkap; simpan '
      'mengikat makanan baru dan kembali ke tinjau', (tester) async {
    await pumpReview(tester, await saveDraft());

    await tapVisible(tester, find.text('Lengkapi 3 bahan'));
    expect(
      find.text('Belum ada di katalog — nutrisinya belum diketahui.'),
      findsOneWidget,
    );
    await tapVisible(tester, find.text('Buat makanan ini'));

    expect(find.byType(CustomFoodScreen), findsOneWidget);
    final form = find.descendant(
      of: find.byType(CustomFoodScreen),
      matching: find.byType(TextField),
    );
    expect(tester.widget<TextField>(form.at(0)).controller!.text, 'Cheesecake');
    expect(tester.widget<TextField>(form.at(1)).controller!.text, '1 potong');

    // Batal: kembali tanpa menyimpan.
    tester.state<NavigatorState>(find.byType(Navigator).last).pop();
    await tester.pumpAndSettle();
    expect(find.byType(CustomFoodScreen), findsNothing);

    // Sheet masih terbuka untuk komponen yang sama → buat dan simpan.
    await tapVisible(tester, find.text('Buat makanan ini'));
    await tester.enterText(form.at(2), '320');
    await tapVisible(tester, find.text('Simpan makanan'));

    expect(find.byType(FoodPhotoReviewScreen), findsOneWidget);
    expect(find.text('belum ada di katalog'), findsNWidgets(2));
    expect(find.text('Lengkapi 2 bahan'), findsOneWidget);
    expect(find.textContaining('+ 2 belum diketahui'), findsOneWidget);
    expect(
      await database.select(database.mealEntries).get(),
      isEmpty,
      reason: 'melengkapi komponen tidak mencatat apa pun',
    );
  });

  testWidgets('Bagikan saja tanpa mencatat: kartu tanpa angka, buku harian '
      'tidak berubah, dan kembali ke tinjau dengan draf utuh', (tester) async {
    await pumpReview(tester, await saveDraft());

    await tapVisible(tester, find.text('Bagikan saja tanpa mencatat'));

    expect(find.byType(SharePreviewScreen), findsOneWidget);
    final card = tester.widget<MealShareCard>(find.byType(MealShareCard));
    expect(card.data.showNutrition, isFalse);
    expect(card.data.notLogged, isTrue);
    expect(card.data.items.map((i) => i.name), <String>[
      'Nasi putih',
      'Cheesecake',
      'Muffin',
      'Kue kering',
    ]);
    expect(find.textContaining('Belum dicatat di buku harian'), findsOneWidget);
    final cardText = tester
        .widgetList<Text>(
          find.descendant(
            of: find.byType(MealShareCard),
            matching: find.byType(Text),
          ),
        )
        .map((t) => t.data ?? '')
        .join(' | ');
    expect(cardText, isNot(contains('kkal')));
    expect(cardText, contains('Dibagikan dari Mealora'));

    await tester.tap(find.byTooltip('Tutup'));
    await tester.pumpAndSettle();

    expect(find.byType(FoodPhotoReviewScreen), findsOneWidget);
    expect(find.text('Lengkapi 3 bahan'), findsOneWidget);
    expect(await database.select(database.mealEntries).get(), isEmpty);
  });

  testWidgets('kartu tanpa total: foto/nama/waktu makan tanpa angka gizi', (
    tester,
  ) async {
    const data = MealShareData(
      mealTimeLabel: 'Camilan',
      items: <MealShareItem>[
        MealShareItem(name: 'Cheesecake', portion: '1 potong', kcal: 320),
        MealShareItem(name: 'Kopi susu', portion: '1 cangkir', kcal: 7),
      ],
      photoPath: null,
      showNutrition: false,
    );
    await tester.pumpWidget(
      wrapForTest(
        const Center(
          child: SizedBox(
            width: ShareCardSize.width,
            height: ShareCardSize.height,
            child: MealShareCard(data: data),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // `96`: nama bahan sebagai satu kalimat.
    expect(find.text('Cheesecake dan Kopi susu'), findsOneWidget);
    expect(find.text('Camilan'), findsOneWidget);
    expect(find.text('Dibagikan dari Mealora'), findsOneWidget);
    expect(find.textContaining('kkal'), findsNothing);
    expect(find.textContaining('320'), findsNothing);
  });

  test('kartu ringkasan harian: tanpa persentase bila energi belum '
      'lengkap', () {
    final data = DailySummaryShareData(
      date: createWidgetTestClock().today(),
      consumedKcal: PartialSum.of(<double?>[1200, null]),
      targetKcal: 2000,
      proteinG: PartialSum.of(<double?>[40, null]),
      carbohydrateG: PartialSum.of(<double?>[null]),
      fatG: PartialSum.of(<double?>[12]),
    );
    expect(data.percentOfTarget, isNull);
    expect(data.consumedKcal.known, 1200);
  });

  testWidgets('kartu ringkasan harian: makro parsial, bukan "–" untuk '
      'seluruhnya', (tester) async {
    await tester.pumpWidget(
      wrapForTest(
        Center(
          child: DailySummaryShareCard(
            data: DailySummaryShareData(
              date: createWidgetTestClock().today(),
              consumedKcal: PartialSum.of(<double?>[1200, null]),
              targetKcal: 2000,
              proteinG: PartialSum.of(<double?>[40, null]),
              carbohydrateG: PartialSum.of(<double?>[null]),
              fatG: PartialSum.of(<double?>[12]),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text('Protein ≥ 40 g · Karbo – g · Lemak 12 g'),
      findsOneWidget,
    );
    expect(find.textContaining('dari target'), findsNothing);
  });

  test('total kartu makanan parsial, bukan nol', () {
    const data = MealShareData(
      mealTimeLabel: 'Camilan',
      items: <MealShareItem>[
        MealShareItem(name: 'Kopi susu', portion: '1 cangkir', kcal: 7),
        MealShareItem(name: 'Roti', portion: '1 potong', kcal: null),
      ],
      photoPath: null,
    );
    expect(data.total.known, 7);
    expect(data.total.unknownCount, 1);
  });

  testWidgets('Hari ini: catatan berenergi kosong disebut di catatan amber '
      'yang membuka buku harian, bukan di dalam lingkaran', (tester) async {
    final foods = DriftFoodRepository(
      database,
      ids: SequentialIdGenerator(),
      clock: createWidgetTestClock(),
    );
    final diary = DriftDiaryRepository(
      database,
      clock: createWidgetTestClock(),
      ids: SequentialIdGenerator(prefix: 'e'),
      programRepository: DriftProgramRepository(
        database,
        clock: createWidgetTestClock(),
        ids: SequentialIdGenerator(prefix: 'p'),
      ),
    );
    Future<void> log(String name, NutritionProfile nutrition) async {
      final created = await foods.createUserFood(
        name: name,
        category: FoodCategory.other,
        serving: ServingSizeInput(
          label: '1 porsi',
          amount: 1,
          unit: 'porsi',
          nutrition: nutrition,
        ),
      );
      final food = (await foods.findById(created.id))!;
      await diary.addEntry(
        profileId: profileId,
        date: createWidgetTestClock().today(),
        mealTime: MealTime.lunch,
        food: food,
        serving: food.defaultServing,
        quantity: 1,
      );
    }

    await log(
      'Nasi',
      NutritionProfile(
        energy: Energy.kcalValue(300, field: 'energy').valueOrNull,
      ),
    );
    await log('Sambal hijau', NutritionProfile.unknown);

    await useDesignViewport(tester);
    await tester.pumpWidget(
      wrapForTest(
        const TodayScreen(),
        database: database,
        overrides: <Override>[
          profileRepositoryAppOverride,
          programRepositoryAppOverride,
          foodRepositoryAppOverride,
          diaryRepositoryAppOverride,
          photoDraftRepositoryAppOverride,
        ],
      ),
    );
    await tester.pumpAndSettle();

    final note = find.byKey(
      const ValueKey<String>('today-unknown-energy-note'),
    );
    expect(note, findsOneWidget);
    expect(
      find.text('1 catatan hari ini belum diketahui energinya'),
      findsOneWidget,
    );
    expect(
      find.textContaining('belum diketahui', findRichText: true),
      findsOneWidget,
      reason: 'penanda tidak lagi diulang di dalam lingkaran',
    );

    await tester.ensureVisible(note);
    await tester.tap(note);
    await tester.pumpAndSettle();
    expect(find.byType(HistoryCalendarScreen), findsOneWidget);
  });
}

class _NoopShareService extends ShareCardService {
  _NoopShareService()
    : super(gateway: const SystemShareSheetGateway(), nextId: () => 'x');

  @override
  Future<void> share(RenderRepaintBoundary boundary) async {}
}
