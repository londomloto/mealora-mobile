import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/domain/food/nutrition_profile.dart';
import 'package:mealora/domain/shared/units.dart';

/// `NutritionProfile` — belum diketahui tetap belum diketahui di seluruh
/// rantai (Design D9, change 007).
void main() {
  Energy kcal(double value) =>
      Energy.kcalValue(value, field: 'energy').valueOrNull!;

  group('scaledBy', () {
    test('mengalikan seluruh zat gizi yang diketahui', () {
      const profile = NutritionProfile(
        proteinG: 10,
        carbohydrateG: 20,
        fatG: 5,
      );
      final scaled = profile.scaledBy(1.5);

      expect(scaled.proteinG, 15);
      expect(scaled.carbohydrateG, 30);
      expect(scaled.fatG, 7.5);
    });

    test('nilai belum diketahui tetap belum diketahui setelah dikalikan', () {
      const profile = NutritionProfile(proteinG: 10);
      final scaled = profile.scaledBy(2);

      expect(scaled.carbohydrateG, isNull);
      expect(scaled.fatG, isNull);
      expect(scaled.energy, isNull);
    });
  });

  group('sumAll', () {
    test(
      'daftar kosong menghasilkan seluruhnya belum diketahui (hari tanpa catatan)',
      () {
        final sum = NutritionProfile.sumAll(const <NutritionProfile>[]);

        expect(sum.energy, isNull);
        expect(sum.proteinG, isNull);
        expect(sum.isFullyUnknown, isTrue);
      },
    );

    test('menjumlahkan seluruh profil yang lengkap', () {
      final sum = NutritionProfile.sumAll(<NutritionProfile>[
        NutritionProfile(energy: kcal(100), proteinG: 5),
        NutritionProfile(energy: kcal(200), proteinG: 10),
      ]);

      expect(sum.energy!.kcal, 300);
      expect(sum.proteinG, 15);
    });

    test('satu kontributor belum diketahui membuat total zat gizi itu belum '
        'diketahui, bukan menjumlahkan yang ada seolah-olah itu totalnya '
        '(task 5.2)', () {
      final sum = NutritionProfile.sumAll(<NutritionProfile>[
        NutritionProfile(energy: kcal(100), fatG: 3),
        NutritionProfile(energy: kcal(200)), // fatG tidak diketahui
      ]);

      expect(
        sum.energy!.kcal,
        300,
        reason: 'energi lengkap di kedua kontributor',
      );
      expect(
        sum.fatG,
        isNull,
        reason:
            'satu kontributor tidak tahu lemaknya, jadi total lemak '
            'tidak boleh berpura-pura hanya 3 g',
      );
    });
  });
}
