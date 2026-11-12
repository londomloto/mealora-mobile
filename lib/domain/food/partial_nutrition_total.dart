import 'package:mealora/domain/food/nutrition_profile.dart';
import 'package:mealora/domain/shared/units.dart';

/// Total satu zat gizi yang jujur (change 021, design D1): [known] hanya
/// menjumlahkan nilai yang diketahui, [unknownCount] menghitung bagian yang
/// nilainya belum diketahui. Nilai belum diketahui tidak pernah jadi nol.
final class PartialSum {
  const PartialSum({
    required this.known,
    required this.unknownCount,
    required this.knownCount,
  });

  /// Jumlah nilai yang diketahui (0 bila tidak ada satu pun).
  final double known;

  /// Banyaknya bagian yang nilainya belum diketahui.
  final int unknownCount;

  /// Banyaknya bagian yang nilainya diketahui.
  final int knownCount;

  bool get isComplete => unknownCount == 0;

  /// Tidak ada satu pun nilai yang diketahui — total belum diketahui.
  bool get isUnknown => knownCount == 0;

  static PartialSum of(Iterable<double?> values) {
    var known = 0.0;
    var knownCount = 0;
    var unknownCount = 0;
    for (final value in values) {
      if (value == null) {
        unknownCount++;
      } else {
        known += value;
        knownCount++;
      }
    }
    return PartialSum(
      known: known,
      unknownCount: unknownCount,
      knownCount: knownCount,
    );
  }
}

/// Total parsial energi dan makro dari sejumlah bagian. Bagian `null`
/// (mis. komponen foto tanpa padanan) dihitung belum diketahui untuk setiap
/// zat gizi. Berbeda dengan [NutritionProfile.sumAll] yang mengembalikan
/// null bila ada satu saja nilai belum diketahui.
final class PartialNutritionTotal {
  const PartialNutritionTotal({
    required this.energyKcal,
    required this.proteinG,
    required this.carbohydrateG,
    required this.fatG,
  });

  factory PartialNutritionTotal.of(Iterable<NutritionProfile?> parts) {
    final list = parts.toList(growable: false);
    return PartialNutritionTotal(
      energyKcal: PartialSum.of(list.map((p) => p?.energy?.kcal)),
      proteinG: PartialSum.of(list.map((p) => p?.proteinG)),
      carbohydrateG: PartialSum.of(list.map((p) => p?.carbohydrateG)),
      fatG: PartialSum.of(list.map((p) => p?.fatG)),
    );
  }

  final PartialSum energyKcal;
  final PartialSum proteinG;
  final PartialSum carbohydrateG;
  final PartialSum fatG;

  /// Energi yang diketahui, atau null bila seluruhnya belum diketahui.
  Energy? get knownEnergy => energyKcal.isUnknown
      ? null
      : Energy.kcalValue(energyKcal.known, field: 'energy').valueOrNull;
}
