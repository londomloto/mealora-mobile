import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:mealora/domain/food/nutrition_profile.dart';
import 'package:mealora/domain/food/partial_nutrition_total.dart';
import 'package:mealora/domain/shared/units.dart';
import 'package:mealora/features/diary/diary_format.dart';
import 'package:mealora/l10n/generated/app_localizations_id.dart';

/// Change 021, task 1.1/1.2: total parsial tidak pernah menghitung nilai
/// belum diketahui sebagai nol.
void main() {
  Energy kcal(double value) =>
      Energy.kcalValue(value, field: 'energy').valueOrNull!;
  final text = AppTextId();

  setUpAll(() async {
    await initializeDateFormatting('id_ID');
  });

  group('PartialNutritionTotal.of', () {
    test('semua diketahui → lengkap', () {
      final total = PartialNutritionTotal.of(<NutritionProfile?>[
        NutritionProfile(
          energy: kcal(100),
          proteinG: 5,
          carbohydrateG: 10,
          fatG: 2,
        ),
        NutritionProfile(
          energy: kcal(50),
          proteinG: 1,
          carbohydrateG: 4,
          fatG: 1,
        ),
      ]);
      expect(total.energyKcal.known, 150);
      expect(total.energyKcal.isComplete, isTrue);
      expect(total.energyKcal.isUnknown, isFalse);
      expect(total.proteinG.known, 6);
      expect(total.knownEnergy?.kcal, 150);
    });

    test('sebagian null → yang diketahui saja + jumlah belum diketahui', () {
      final total = PartialNutritionTotal.of(<NutritionProfile?>[
        NutritionProfile(energy: kcal(7), proteinG: 0.5),
        const NutritionProfile(proteinG: 2),
      ]);
      expect(total.energyKcal.known, 7);
      expect(total.energyKcal.unknownCount, 1);
      expect(total.energyKcal.isComplete, isFalse);
      expect(total.proteinG.isComplete, isTrue);
      expect(total.fatG.isUnknown, isTrue);
    });

    test('semua null → belum diketahui, bukan nol', () {
      final total = PartialNutritionTotal.of(<NutritionProfile?>[
        NutritionProfile.unknown,
        NutritionProfile.unknown,
      ]);
      expect(total.energyKcal.isUnknown, isTrue);
      expect(total.energyKcal.unknownCount, 2);
      expect(total.knownEnergy, isNull);
    });

    test('komponen tanpa padanan (null) dihitung belum diketahui', () {
      final total = PartialNutritionTotal.of(<NutritionProfile?>[
        NutritionProfile(energy: kcal(7)),
        null,
        null,
        null,
      ]);
      expect(total.energyKcal.known, 7);
      expect(total.energyKcal.unknownCount, 3);
      expect(total.carbohydrateG.unknownCount, 4);
    });

    test('daftar kosong → belum diketahui dan lengkap', () {
      final total = PartialNutritionTotal.of(const <NutritionProfile?>[]);
      expect(total.energyKcal.isUnknown, isTrue);
      expect(total.energyKcal.isComplete, isTrue);
    });
  });

  group('DiaryFormat parsial', () {
    test('energi', () {
      expect(
        DiaryFormat.partialKcal(
          PartialSum.of(<double?>[7, null, null, null]),
          text,
        ),
        '7 kkal + 3 belum diketahui',
      );
      expect(
        DiaryFormat.partialKcal(PartialSum.of(<double?>[7]), text),
        '7 kkal',
      );
      expect(
        DiaryFormat.partialKcal(PartialSum.of(<double?>[null]), text),
        '–',
      );
    });

    test('gram', () {
      expect(
        DiaryFormat.partialGrams(PartialSum.of(<double?>[2.5, null]), text),
        '2,5 g + 1 belum diketahui',
      );
      expect(
        DiaryFormat.partialGramsCompact(
          PartialSum.of(<double?>[2.5, null]),
          text,
        ),
        '≥ 2,5 g',
      );
      expect(
        DiaryFormat.partialGramsCompact(PartialSum.of(<double?>[3]), text),
        '3 g',
      );
      expect(
        DiaryFormat.partialGramsCompact(PartialSum.of(<double?>[null]), text),
        '–',
      );
    });
  });
}
