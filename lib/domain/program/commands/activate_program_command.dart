import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/ids/id_generator.dart';
import 'package:mealora/domain/nutrition/energy_equation_policy.dart';
import 'package:mealora/domain/nutrition/nutrition_calculator.dart';
import 'package:mealora/domain/nutrition/nutrition_estimate.dart';
import 'package:mealora/domain/nutrition/physiological_facts.dart';
import 'package:mealora/domain/program/commands/activation_result.dart';
import 'package:mealora/domain/program/program_code.dart';
import 'package:mealora/domain/program/program_engine.dart';
import 'package:mealora/domain/program/program_event.dart';
import 'package:mealora/domain/program/program_proposal_inputs.dart';
import 'package:mealora/domain/program/program_repository.dart';
import 'package:mealora/domain/program/program_state.dart';
import 'package:mealora/domain/program/program_target_proposal.dart';
import 'package:mealora/domain/program/user_program.dart';
import 'package:mealora/domain/shared/program_outcome.dart';

/// Mengaktifkan sebuah program — membaca ulang fakta terkini, memverifikasi
/// proposal masih sesuai, mewajibkan konfirmasi, dan menolak setiap hasil
/// yang tidak disetujui (Design D6, assessment §39, task 7.1/7.2).
///
/// Menghitung ulang estimasi energi dari fakta terkini lewat
/// `NutritionCalculator` alih-alih memercayai nilai pratinjau — satu sumber
/// kebenaran untuk "membaca ulang fakta profil terkini".
final class ActivateProgramCommand {
  const ActivateProgramCommand({
    required this.repository,
    required this.clock,
    required this.idGenerator,
    required this.engine,
  });

  final ProgramRepository repository;
  final Clock clock;
  final IdGenerator idGenerator;
  final ProgramEngine engine;

  Future<ActivationResult> execute({
    required String profileId,
    required ProgramCode program,
    required ProgramProposalInputs previewInputs,
    required ProgramProposalInputs currentInputs,
    required bool userConfirmed,
    required bool programRequiresTargetWeight,
    required bool programRequiresHabitFocus,
  }) async {
    if (!userConfirmed) {
      return const ActivationRequiresConfirmation();
    }
    if (!previewInputs.matches(currentInputs)) {
      return const ActivationInputsChangedSincePreview();
    }

    final outcome = engine.proposeTarget(
      program: program,
      ageYears: currentInputs.ageYears,
      biologicalInput: currentInputs.biologicalInput,
      height: currentInputs.height,
      currentWeight: currentInputs.currentWeight,
      estimate: _estimateFrom(currentInputs),
      screening: currentInputs.screening,
      specific: currentInputs.specific,
      asOfDate: clock.today(),
      programRequiresTargetWeight: programRequiresTargetWeight,
      programRequiresHabitFocus: programRequiresHabitFocus,
    );

    if (outcome is! Approved<ProgramTargetProposal>) {
      return ActivationRejectedNotApproved(outcome);
    }
    final proposal = outcome.value;

    final existing = await repository.findRunning(profileId);
    if (existing != null) {
      final sameRequest =
          existing.programCode == program &&
          existing.inputSnapshot.matches(currentInputs);
      if (sameRequest) {
        return ActivationAlreadySatisfied(existing);
      }
      return ActivationConflictExistingRunningProgram(existing);
    }

    final now = clock.nowUtc();
    final newProgram = UserProgram(
      id: idGenerator.next(),
      profileId: profileId,
      programCode: program,
      state: ProgramState.active,
      proposal: proposal,
      inputSnapshot: currentInputs,
      startedAt: now,
    );
    final event = ProgramEvent(
      id: idGenerator.next(),
      userProgramId: newProgram.id,
      type: ProgramEventType.activated,
      occurredAt: now,
      toState: ProgramState.active,
    );

    try {
      await repository.applyActivation(newProgram: newProgram, event: event);
    } on Object catch (error) {
      return ActivationFailed(error);
    }
    return ActivationSucceeded(newProgram);
  }

  NutritionEstimate _estimateFrom(ProgramProposalInputs inputs) {
    const calculator = NutritionCalculator(EnergyEquationPolicy.np100);
    final outcome = calculator.estimate(
      PhysiologicalFactsInput(
        ageYears: inputs.ageYears,
        biologicalInput: inputs.biologicalInput,
        heightCm: inputs.height.cm,
        weightKg: inputs.currentWeight.kg,
        activity: inputs.activity,
      ),
    );
    return switch (outcome) {
      Approved<NutritionEstimate>(:final value) => value,
      _ => throw StateError(
        'fakta aktivasi tidak valid untuk kalkulator: $outcome',
      ),
    };
  }
}
