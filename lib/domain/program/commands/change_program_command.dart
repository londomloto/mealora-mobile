import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/ids/id_generator.dart';
import 'package:mealora/domain/nutrition/nutrition_estimate.dart';
import 'package:mealora/domain/program/program_code.dart';
import 'package:mealora/domain/program/program_engine.dart';
import 'package:mealora/domain/program/program_event.dart';
import 'package:mealora/domain/program/program_proposal_inputs.dart';
import 'package:mealora/domain/program/program_repository.dart';
import 'package:mealora/domain/program/program_state.dart';
import 'package:mealora/domain/program/program_target_proposal.dart';
import 'package:mealora/domain/program/user_program.dart';
import 'package:mealora/domain/shared/program_outcome.dart';

/// Hasil `ChangeProgramCommand`.
sealed class ChangeResult {
  const ChangeResult();
}

final class ChangeSucceeded extends ChangeResult {
  const ChangeSucceeded({required this.oldProgram, required this.newProgram});

  final UserProgram oldProgram;
  final UserProgram newProgram;
}

final class ChangeRequiresConfirmation extends ChangeResult {
  const ChangeRequiresConfirmation();
}

final class ChangeRejectedNotApproved extends ChangeResult {
  const ChangeRejectedNotApproved(this.outcome);

  final ProgramOutcome<ProgramTargetProposal> outcome;
}

final class ChangeNoRunningProgram extends ChangeResult {
  const ChangeNoRunningProgram();
}

/// Pergantian gagal diterapkan — Design D7, penyimpanan SHALL kembali
/// seperti semula (dibuktikan lewat `ProgramRepository.applyProgramChange`
/// yang dipanggil tepat sekali dan diuji atomik di task 7.9).
final class ChangeFailed extends ChangeResult {
  const ChangeFailed(this.error);

  final Object error;
}

/// Mengganti program yang berjalan dengan program baru sebagai satu
/// kesatuan: menandai lama `changed`, menautkan dua arah, mencatat
/// peristiwa, dan mengaktifkan yang baru (program-lifecycle spec,
/// "Pergantian program berlangsung utuh").
final class ChangeProgramCommand {
  const ChangeProgramCommand({
    required this.repository,
    required this.clock,
    required this.idGenerator,
    required this.engine,
  });

  final ProgramRepository repository;
  final Clock clock;
  final IdGenerator idGenerator;
  final ProgramEngine engine;

  ChangeResult execute({
    required String profileId,
    required ProgramCode newProgramCode,
    required ProgramProposalInputs currentInputs,
    required bool userConfirmed,
    required bool programRequiresTargetWeight,
    required bool programRequiresHabitFocus,
    required NutritionEstimate estimate,
  }) {
    if (!userConfirmed) {
      return const ChangeRequiresConfirmation();
    }
    final running = repository.findRunning(profileId);
    if (running == null) {
      return const ChangeNoRunningProgram();
    }

    final outcome = engine.proposeTarget(
      program: newProgramCode,
      ageYears: currentInputs.ageYears,
      biologicalInput: currentInputs.biologicalInput,
      height: currentInputs.height,
      currentWeight: currentInputs.currentWeight,
      estimate: estimate,
      screening: currentInputs.screening,
      specific: currentInputs.specific,
      asOfDate: clock.today(),
      programRequiresTargetWeight: programRequiresTargetWeight,
      programRequiresHabitFocus: programRequiresHabitFocus,
    );
    if (outcome is! Approved<ProgramTargetProposal>) {
      return ChangeRejectedNotApproved(outcome);
    }

    final now = clock.nowUtc();
    final newProgram = UserProgram(
      id: idGenerator.next(),
      profileId: profileId,
      programCode: newProgramCode,
      state: ProgramState.active,
      proposal: outcome.value,
      inputSnapshot: currentInputs,
      startedAt: now,
      supersedesUserProgramId: running.id,
    );
    final updatedOld = running.copyWith(
      state: ProgramState.changed,
      endedAt: now,
      supersededByUserProgramId: newProgram.id,
    );
    final events = <ProgramEvent>[
      ProgramEvent(
        id: idGenerator.next(),
        userProgramId: running.id,
        type: ProgramEventType.changed,
        occurredAt: now,
        fromState: running.state,
        toState: ProgramState.changed,
      ),
      ProgramEvent(
        id: idGenerator.next(),
        userProgramId: newProgram.id,
        type: ProgramEventType.activated,
        occurredAt: now,
        toState: ProgramState.active,
      ),
    ];

    try {
      repository.applyProgramChange(
        supersededProgram: updatedOld,
        newProgram: newProgram,
        events: events,
      );
    } on Object catch (error) {
      return ChangeFailed(error);
    }

    return ChangeSucceeded(oldProgram: updatedOld, newProgram: newProgram);
  }
}
