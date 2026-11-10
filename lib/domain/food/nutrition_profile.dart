import 'package:mealora/domain/shared/units.dart';

/// Nilai gizi sebuah takaran saji atau sebuah total — setiap bidang `null`
/// berarti **belum diketahui**, berbeda dari nol (Design D9, change 007).
/// Tidak pernah diperlakukan sebagai nol di mana pun pada rantai perhitungan:
/// katalog, potret catatan, maupun agregasi harian.
final class NutritionProfile {
  const NutritionProfile({
    this.energy,
    this.proteinG,
    this.carbohydrateG,
    this.fatG,
    this.fiberG,
    this.sugarG,
    this.sodiumMg,
  });

  /// Seluruh zat gizi belum diketahui — titik awal yang bermakna hanya untuk
  /// "hari tanpa catatan" ([sumAll] daftar kosong), bukan untuk akumulasi.
  static const NutritionProfile unknown = NutritionProfile();

  final Energy? energy;
  final double? proteinG;
  final double? carbohydrateG;
  final double? fatG;
  final double? fiberG;
  final double? sugarG;
  final double? sodiumMg;

  /// Profil ini sepenuhnya belum diketahui.
  bool get isFullyUnknown =>
      energy == null &&
      proteinG == null &&
      carbohydrateG == null &&
      fatG == null &&
      fiberG == null &&
      sugarG == null &&
      sodiumMg == null;

  /// Nilai per takaran dikalikan [factor] (jumlah takaran) — dipakai untuk
  /// mengubah potret per-takaran sebuah butir catatan menjadi total butir
  /// itu (spec food-diary, "Nilai gizi dibekukan pada saat pencatatan").
  /// `null` dikalikan apa pun tetap `null`.
  NutritionProfile scaledBy(double factor) => NutritionProfile(
    energy: energy?.times(factor),
    proteinG: proteinG == null ? null : proteinG! * factor,
    carbohydrateG: carbohydrateG == null ? null : carbohydrateG! * factor,
    fatG: fatG == null ? null : fatG! * factor,
    fiberG: fiberG == null ? null : fiberG! * factor,
    sugarG: sugarG == null ? null : sugarG! * factor,
    sodiumMg: sodiumMg == null ? null : sodiumMg! * factor,
  );

  /// Menjumlahkan sejumlah profil (mis. seluruh butir catatan sehari) sesuai
  /// §14 dan Design D9: daftar kosong menghasilkan seluruhnya belum diketahui
  /// (bukan nol — hari tanpa catatan). Untuk setiap zat gizi, bila SATU PUN
  /// kontributor bernilai belum diketahui, totalnya belum diketahui —
  /// menjumlahkan yang ada seolah-olah itu totalnya akan menyesatkan (spec
  /// daily-dashboard, task 5.2).
  static NutritionProfile sumAll(Iterable<NutritionProfile> items) {
    final list = items.toList(growable: false);
    if (list.isEmpty) {
      return NutritionProfile.unknown;
    }
    return NutritionProfile(
      energy: _sumEnergy(list.map((p) => p.energy)),
      proteinG: _sumDouble(list.map((p) => p.proteinG)),
      carbohydrateG: _sumDouble(list.map((p) => p.carbohydrateG)),
      fatG: _sumDouble(list.map((p) => p.fatG)),
      fiberG: _sumDouble(list.map((p) => p.fiberG)),
      sugarG: _sumDouble(list.map((p) => p.sugarG)),
      sodiumMg: _sumDouble(list.map((p) => p.sodiumMg)),
    );
  }

  static double? _sumDouble(Iterable<double?> values) {
    final list = values.toList(growable: false);
    if (list.any((v) => v == null)) {
      return null;
    }
    return list.fold<double>(0, (sum, value) => sum + value!);
  }

  static Energy? _sumEnergy(Iterable<Energy?> values) {
    final list = values.toList(growable: false);
    if (list.any((v) => v == null)) {
      return null;
    }
    return list.fold<Energy>(Energy.zero, (sum, value) => sum + value!);
  }
}
