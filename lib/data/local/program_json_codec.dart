import 'dart:convert';

import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/domain/nutrition/activity_level.dart';
import 'package:mealora/domain/nutrition/biological_input.dart';
import 'package:mealora/domain/program/declared_condition.dart';
import 'package:mealora/domain/program/profile_screening_facts.dart';
import 'package:mealora/domain/program/program_proposal_inputs.dart';
import 'package:mealora/domain/program/program_specific_input.dart';
import 'package:mealora/domain/shared/program_warning.dart';
import 'package:mealora/domain/shared/units.dart';

/// Bagian `ProgramTargetProposal` yang tidak punya kolom diskret sendiri di
/// `user_programs` (change 004, design.md Design D9).
final class ProposalExtras {
  const ProposalExtras({
    required this.showsEnergyTarget,
    required this.showsWeightProgressPercent,
    this.referenceWeight,
    this.toleranceBand,
    this.proteinPercentEnergy,
    this.fatPercentEnergy,
    this.carbohydratePercentEnergy,
    this.warnings = const <ProgramWarning>{},
  });

  final bool showsEnergyTarget;
  final bool showsWeightProgressPercent;
  final Mass? referenceWeight;
  final (Energy lower, Energy upper)? toleranceBand;
  final double? proteinPercentEnergy;
  final double? fatPercentEnergy;
  final double? carbohydratePercentEnergy;
  final Set<ProgramWarning> warnings;
}

/// Kodek JSON untuk kolom `input_snapshot_json` (change 004, Design D9).
///
/// Satu blob menampung dua bagian: `inputs` (salinan `ProgramProposalInputs`
/// apa adanya saat proposal disetujui — Design D9, change 003) dan
/// `proposal` ([ProposalExtras]). Kolom diskret (`daily_energy_target_kcal`,
/// `protein_target_g`, dst.) tetap ada untuk kueri cepat tanpa membongkar
/// JSON.
///
/// Nilai di sini diasumsikan sudah pernah lolos validasi domain saat
/// pertama ditulis — pembacaan ulang tidak divalidasi ulang, hanya
/// dipulihkan.
abstract final class ProgramJsonCodec {
  static String encode({
    required ProgramProposalInputs inputs,
    required ProposalExtras proposal,
  }) => jsonEncode({
    'inputs': _inputsToJson(inputs),
    'proposal': _proposalToJson(proposal),
  });

  static ({ProgramProposalInputs inputs, ProposalExtras proposal}) decode(
    String json,
  ) {
    final map = jsonDecode(json) as Map<String, Object?>;
    return (
      inputs: _inputsFromJson(map['inputs']! as Map<String, Object?>),
      proposal: _proposalFromJson(map['proposal']! as Map<String, Object?>),
    );
  }

  static Map<String, Object?> _inputsToJson(ProgramProposalInputs inputs) => {
    'ageYears': inputs.ageYears,
    'biologicalInput': inputs.biologicalInput.name,
    'heightCm': inputs.height.cm,
    'currentWeightKg': inputs.currentWeight.kg,
    'activity': inputs.activity.name,
    'screening': {
      'isPregnantOrLactating': inputs.screening.isPregnantOrLactating,
      'declaredConditions': inputs.screening.declaredConditions
          .map((c) => c.name)
          .toList(),
      'unintendedWeightChange': inputs.screening.unintendedWeightChange == null
          ? null
          : {
              'percentOfBodyWeight':
                  inputs.screening.unintendedWeightChange!.percentOfBodyWeight,
              'windowDays': inputs.screening.unintendedWeightChange!.windowDays,
            },
    },
    'specific': {
      'targetWeightKg': inputs.specific.targetWeight?.kg,
      'targetDate': inputs.specific.targetDate?.iso,
      'requestedPaceKgPerWeek': inputs.specific.requestedPaceKgPerWeek,
      'habitFocus': inputs.specific.habitFocus,
      'preferredMaintenanceRange': inputs.specific.preferredMaintenanceRange,
    },
  };

  static ProgramProposalInputs _inputsFromJson(Map<String, Object?> json) {
    final screeningJson = json['screening'] as Map<String, Object?>;
    final unintendedJson =
        screeningJson['unintendedWeightChange'] as Map<String, Object?>?;
    final specificJson = json['specific'] as Map<String, Object?>;

    return ProgramProposalInputs(
      ageYears: json['ageYears']! as int,
      biologicalInput: BiologicalInput.values.byName(
        json['biologicalInput']! as String,
      ),
      height: Length.cmValue(
        json['heightCm']! as double,
        field: 'height',
      ).valueOrNull!,
      currentWeight: Mass.kgValue(
        json['currentWeightKg']! as double,
        field: 'currentWeight',
      ).valueOrNull!,
      activity: ActivityLevel.values.byName(json['activity']! as String),
      screening: ProfileScreeningFacts(
        isPregnantOrLactating: screeningJson['isPregnantOrLactating']! as bool,
        declaredConditions: (screeningJson['declaredConditions']! as List)
            .map((c) => DeclaredCondition.values.byName(c as String))
            .toSet(),
        unintendedWeightChange: unintendedJson == null
            ? null
            : UnintendedWeightChange(
                percentOfBodyWeight:
                    unintendedJson['percentOfBodyWeight']! as double,
                windowDays: unintendedJson['windowDays']! as int,
              ),
      ),
      specific: ProgramSpecificInput(
        targetWeight: specificJson['targetWeightKg'] == null
            ? null
            : Mass.kgValue(
                specificJson['targetWeightKg']! as double,
                field: 'targetWeight',
              ).valueOrNull!,
        targetDate: specificJson['targetDate'] == null
            ? null
            : LocalDate.parse(specificJson['targetDate']! as String),
        requestedPaceKgPerWeek:
            specificJson['requestedPaceKgPerWeek'] as double?,
        habitFocus: specificJson['habitFocus'] as String?,
        preferredMaintenanceRange:
            specificJson['preferredMaintenanceRange'] as String?,
      ),
    );
  }

  static Map<String, Object?> _proposalToJson(ProposalExtras proposal) => {
    'showsEnergyTarget': proposal.showsEnergyTarget,
    'showsWeightProgressPercent': proposal.showsWeightProgressPercent,
    'referenceWeightKg': proposal.referenceWeight?.kg,
    'toleranceLowerKcal': proposal.toleranceBand?.$1.kcal,
    'toleranceUpperKcal': proposal.toleranceBand?.$2.kcal,
    'proteinPercentEnergy': proposal.proteinPercentEnergy,
    'fatPercentEnergy': proposal.fatPercentEnergy,
    'carbohydratePercentEnergy': proposal.carbohydratePercentEnergy,
    'warnings': proposal.warnings.map((w) => w.name).toList(),
  };

  static ProposalExtras _proposalFromJson(Map<String, Object?> map) {
    final lower = map['toleranceLowerKcal'] as double?;
    final upper = map['toleranceUpperKcal'] as double?;
    return ProposalExtras(
      showsEnergyTarget: map['showsEnergyTarget']! as bool,
      showsWeightProgressPercent: map['showsWeightProgressPercent']! as bool,
      referenceWeight: map['referenceWeightKg'] == null
          ? null
          : Mass.kgValue(
              map['referenceWeightKg']! as double,
              field: 'referenceWeight',
            ).valueOrNull!,
      toleranceBand: (lower == null || upper == null)
          ? null
          : (
              Energy.kcalValue(lower, field: 'toleranceLower').valueOrNull!,
              Energy.kcalValue(upper, field: 'toleranceUpper').valueOrNull!,
            ),
      proteinPercentEnergy: map['proteinPercentEnergy'] as double?,
      fatPercentEnergy: map['fatPercentEnergy'] as double?,
      carbohydratePercentEnergy: map['carbohydratePercentEnergy'] as double?,
      warnings: (map['warnings']! as List)
          .map((w) => ProgramWarning.values.byName(w as String))
          .toSet(),
    );
  }
}
