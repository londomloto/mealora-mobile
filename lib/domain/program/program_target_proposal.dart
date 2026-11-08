import 'package:mealora/domain/program/program_code.dart';
import 'package:mealora/domain/shared/program_warning.dart';
import 'package:mealora/domain/shared/units.dart';

/// Target makro yang sudah dibulatkan ke gram terdekat (G2).
final class MacronutrientTargets {
  const MacronutrientTargets({
    required this.proteinGrams,
    required this.proteinPercentEnergy,
    required this.fatGrams,
    required this.fatPercentEnergy,
    required this.carbohydrateGrams,
    required this.carbohydratePercentEnergy,
    required this.fiberGrams,
  });

  final int proteinGrams;
  final double proteinPercentEnergy;
  final int fatGrams;
  final double fatPercentEnergy;
  final int carbohydrateGrams;
  final double carbohydratePercentEnergy;
  final int fiberGrams;
}

/// Hasil `approved` dari `ProgramEngine` (Design D1, assessment §39).
///
/// Untuk Makan Sehat pada profil yang berjalan tanpa angka (usia < 19 atau
/// gangguan makan dinyatakan), [showsEnergyTarget] SHALL `false` dan seluruh
/// kolom angka SHALL kosong — bukan dikarang.
final class ProgramTargetProposal {
  const ProgramTargetProposal({
    required this.program,
    required this.policyVersion,
    required this.calculatorVersion,
    required this.showsEnergyTarget,
    required this.showsWeightProgressPercent,
    this.energyTarget,
    this.referenceWeight,
    this.macros,
    this.toleranceBand,
    this.warnings = const <ProgramWarning>{},
  }) : assert(
         showsEnergyTarget || energyTarget == null,
         'energyTarget harus kosong ketika showsEnergyTarget false',
       );

  final ProgramCode program;
  final String policyVersion;
  final String calculatorVersion;

  final bool showsEnergyTarget;
  final bool showsWeightProgressPercent;

  /// Target energi harian, sudah dibulatkan ke kelipatan 10 kkal (G1).
  final Energy? energyTarget;

  /// min(berat saat ini, berat setara IMT 23), dibulatkan ke 0,1 kg (G3).
  final Mass? referenceWeight;

  final MacronutrientTargets? macros;

  /// Pita toleransi Pertahankan, dalam kkal (D11).
  final (Energy lower, Energy upper)? toleranceBand;

  final Set<ProgramWarning> warnings;
}
