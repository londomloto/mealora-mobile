import 'package:mealora/domain/shared/program_warning.dart';
import 'package:mealora/domain/shared/units.dart';

/// Hasil langkah D (target energi harian) sebelum makro dihitung.
final class EnergyTargetResult {
  const EnergyTargetResult.approved({
    required this.roundedTarget,
    required this.deficitOrSurplusRawKcal,
    required this.deficitOrSurplusAppliedKcal,
    required this.remainingDeficitKcal,
    this.toleranceBand,
    this.warnings = const <ProgramWarning>{},
  }) : rejectedRemainingDeficitKcal = null;

  const EnergyTargetResult.rejectedBelowMinimumEnergy({
    required double remainingDeficitKcal,
  }) : roundedTarget = null,
       deficitOrSurplusRawKcal = null,
       deficitOrSurplusAppliedKcal = null,
       remainingDeficitKcal = null,
       toleranceBand = null,
       warnings = const <ProgramWarning>{},
       rejectedRemainingDeficitKcal = remainingDeficitKcal;

  final Energy? roundedTarget;
  final double? deficitOrSurplusRawKcal;
  final double? deficitOrSurplusAppliedKcal;
  final double? remainingDeficitKcal;
  final (Energy lower, Energy upper)? toleranceBand;
  final Set<ProgramWarning> warnings;

  /// Hanya terisi ketika D6 menolak (defisit tersisa < 300 kkal).
  final double? rejectedRemainingDeficitKcal;

  bool get isRejected => rejectedRemainingDeficitKcal != null;
}
