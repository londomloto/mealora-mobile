import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/data/local/drift_profile_repository.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/domain/image_ai_access/label_service_failure.dart';
import 'package:mealora/domain/nutrition_import/nutrition_import.dart';
import 'package:mealora/domain/nutrition_import/nutrition_reading.dart';
import 'package:mealora/domain/profile/user_profile.dart';
import 'package:mealora/features/diary/custom_food_screen.dart';
import 'package:mealora/features/diary/nutrition_import_review_screen.dart';
import 'package:mealora/features/diary/nutrition_text_import_screen.dart';

import 'harness.dart';

const NutritionReading _steak = NutritionReading(
  sourceKind: NutritionSourceKind.general,
  foodName: 'steak daging sapi',
  basis: NutritionBasis(
    kind: NutritionBasisKind.perHundredGrams,
    amount: 100,
    unit: 'g',
  ),
  energyKcal: NutrientReading.range(214, 252),
  proteinGrams: NutrientReading.range(24, 27),
  carbohydrateGrams: NutrientReading.read(0),
  fatGrams: NutrientReading.read(15),
  ignoredNutrients: <String>['vitamin B12', 'zat besi'],
);

const NutritionReading _empty = NutritionReading(
  sourceKind: NutritionSourceKind.general,
  basis: NutritionBasis.unread,
  energyKcal: NutrientReading.unread,
  proteinGrams: NutrientReading.unread,
  carbohydrateGrams: NutrientReading.unread,
  fatGrams: NutrientReading.unread,
);

final class _FakeText implements NutritionTextReader {
  _FakeText(this.outcome);
  final NutritionReadOutcome outcome;
  final List<String> sent = <String>[];

  @override
  Future<NutritionReadOutcome> readText(String text) async {
    sent.add(text);
    return outcome;
  }
}

/// Change 020: layar 82–85 (Tempel teks → tinjau → form Buat makanan).
void main() {
  late AppDatabase db;

  setUp(() async {
    db = createWidgetTestDatabase();
    await DriftProfileRepository(
      db,
      clock: createWidgetTestClock(),
    ).upsert(const UserProfile(id: 'profile-1'));
  });
  tearDown(() => db.close());

  Future<void> tapVisible(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pumpAndSettle();
    await tester.tap(finder);
    await tester.pumpAndSettle();
  }

  Future<void> pumpForm(WidgetTester tester, _FakeText reader) async {
    await useDesignViewport(tester);
    await tester.pumpWidget(
      wrapForTest(
        const CustomFoodScreen(),
        database: db,
        overrides: <Override>[
          profileRepositoryAppOverride,
          foodRepositoryAppOverride,
          diaryRepositoryAppOverride,
          nutritionTextReaderProvider.overrideWithValue(reader),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  Future<void> pumpPaste(
    WidgetTester tester,
    _FakeText reader, {
    String? clipboard,
  }) async {
    await useDesignViewport(tester);
    await tester.pumpWidget(
      wrapForTest(
        NutritionTextImportScreen(readClipboard: () async => clipboard),
        database: db,
        overrides: <Override>[
          nutritionTextReaderProvider.overrideWithValue(reader),
        ],
      ),
    );
    await tester.pumpAndSettle();
  }

  final chip = find.byKey(const ValueKey('custom-food-paste-text'));

  testWidgets('chip Tempel teks hanya pada mode isi manual', (tester) async {
    await pumpForm(tester, _FakeText(const NutritionReadNoText()));
    expect(chip, findsOneWidget);

    await tapVisible(tester, find.text('Hitung dari bahan'));
    expect(chip, findsNothing);
  });

  testWidgets('tempel → baca → tinjau → form terisi tanpa tersimpan; nama yang '
      'sudah diketik dipertahankan', (tester) async {
    final reader = _FakeText(
      const NutritionReadSuccess(_steak, ReadingTier.text),
    );
    await pumpForm(tester, reader);

    await tester.enterText(find.byType(TextField).first, 'Steak buatan ibu');
    await tapVisible(tester, chip);
    expect(find.byType(NutritionTextImportScreen), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('nutrition-paste-text')),
      'Kalori: Sekitar 214 – 252 kkal',
    );
    await tapVisible(tester, find.text('Baca nilai gizi'));

    expect(reader.sent.single, 'Kalori: Sekitar 214 – 252 kkal');
    expect(find.byType(NutritionImportReviewScreen), findsOneWidget);
    expect(find.text('Nilai tengah'), findsNWidgets(2));
    expect(find.textContaining('vitamin B12'), findsOneWidget);

    await tapVisible(tester, find.text('Pakai di Buat makanan'));

    expect(find.byType(CustomFoodScreen), findsOneWidget);
    expect(find.text('Steak buatan ibu'), findsOneWidget);
    expect(find.text('100 g'), findsOneWidget);
    expect(find.text('233'), findsOneWidget);
    expect(find.text('25,5'), findsOneWidget);
    final foods = await db.select(db.foods).get();
    expect(
      foods.where((f) => f.name.startsWith('Steak')),
      isEmpty,
      reason: 'tidak ada yang tersimpan sebelum pengguna menekan Simpan',
    );
  });

  testWidgets('clipboard terisi otomatis saat layar dibuka', (tester) async {
    await pumpPaste(
      tester,
      _FakeText(const NutritionReadNoText()),
      clipboard: 'Protein 20 g',
    );
    expect(find.text('Protein 20 g'), findsOneWidget);
  });

  testWidgets('teks lebih dari 4000 karakter menonaktifkan tombol baca', (
    tester,
  ) async {
    final reader = _FakeText(const NutritionReadNoText());
    await pumpPaste(tester, reader, clipboard: 'a' * 4001);

    expect(
      find.text('Teks terlalu panjang. Maksimal 4000 karakter.'),
      findsOneWidget,
    );
    await tapVisible(tester, find.text('Baca nilai gizi'));
    expect(reader.sent, isEmpty);
  });

  testWidgets('teks tanpa angka gizi → pesan, tetap di layar tempel', (
    tester,
  ) async {
    await pumpPaste(
      tester,
      _FakeText(const NutritionReadSuccess(_empty, ReadingTier.text)),
      clipboard: 'Rendang adalah masakan khas Minang',
    );
    await tapVisible(tester, find.text('Baca nilai gizi'));

    expect(find.text('Tidak ada angka gizi di teks ini'), findsOneWidget);
    expect(find.byType(NutritionTextImportScreen), findsOneWidget);
  });

  testWidgets('layanan gagal → pesan, teks tetap ada, isi manual tersedia', (
    tester,
  ) async {
    await pumpPaste(
      tester,
      _FakeText(
        const NutritionReadUnavailable(LabelServiceFailureReason.offline),
      ),
      clipboard: 'Protein 20 g',
    );
    await tapVisible(tester, find.text('Baca nilai gizi'));

    expect(
      find.text('Pembacaan otomatis belum bisa dilakukan'),
      findsOneWidget,
    );
    expect(find.text('Protein 20 g'), findsOneWidget);
    expect(find.text('Isi manual saja'), findsOneWidget);
  });
}
