import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/domain/nutrition/energy_equation_policy.dart';
import 'package:mealora/domain/nutrition/nutrition_calculator.dart';
import 'package:mealora/domain/nutrition/nutrition_estimate.dart';
import 'package:mealora/domain/nutrition/physiological_facts.dart';
import 'package:mealora/domain/program/commands/change_program_command.dart';
import 'package:mealora/domain/program/program_code.dart';
import 'package:mealora/domain/program/program_engine.dart';
import 'package:mealora/domain/program/program_proposal_inputs.dart';
import 'package:mealora/domain/program/program_target_proposal.dart';
import 'package:mealora/domain/shared/program_outcome.dart';
import 'package:mealora/features/onboarding/onboarding_controller.dart'
    show programEngineProvider;
import 'package:mealora/features/program/program_providers.dart';

/// Hasil [ProgramRevisionService.approve].
sealed class RevisionResult {
  const RevisionResult();
}

final class RevisionSucceeded extends RevisionResult {
  const RevisionSucceeded(this.change);

  final ChangeSucceeded change;
}

/// Masukan berubah sejak pratinjau (Design D4/D5, task 6.3) — `
/// ChangeProgramCommand` (change 003) sendiri tidak memverifikasi ini
/// (berbeda dari `ActivateProgramCommand`), jadi lapisan ini yang
/// membandingkan `refreshedInputs`/`refreshedOutcome`
/// sebelum memanggil perintah, mengikuti pola yang sama persis dengan
/// `OnboardingController.approve` (task 6.2: perintah aktivasi yang sama,
/// jalur masuk kedua TIDAK dibangun — hanya pemeriksaan staleness yang
/// diduplikasi di lapisan tampilan, karena perintah pergantian tidak
/// memilikinya).
final class RevisionInputsChanged extends RevisionResult {
  const RevisionInputsChanged({
    required this.refreshedInputs,
    required this.refreshedOutcome,
  });

  final ProgramProposalInputs refreshedInputs;
  final ProgramOutcome<ProgramTargetProposal> refreshedOutcome;
}

final class RevisionRejected extends RevisionResult {
  const RevisionRejected(this.outcome);

  final ProgramOutcome<ProgramTargetProposal> outcome;
}

final class RevisionNoRunningProgram extends RevisionResult {
  const RevisionNoRunningProgram();
}

final class RevisionFailed extends RevisionResult {
  const RevisionFailed(this.error);

  final Object error;
}

/// Menghitung pratinjau dan menerapkan revisi target lewat
/// `ChangeProgramCommand` — dipakai baik oleh pergantian program (`28`,
/// task 6.1/6.2) maupun revisi target dari ubah profil (`34`, task 8.2):
/// keduanya pada dasarnya satu hal yang sama di domain (program berjalan
/// digantikan oleh program baru dengan masukan baru), hanya bingkainya yang
/// beda (Design D5) — jadi satu layanan, bukan dua.
final class ProgramRevisionService {
  const ProgramRevisionService({
    required this.engine,
    required this.changeCommand,
    required this.clock,
  });

  final ProgramEngine engine;
  final ChangeProgramCommand changeCommand;
  final Clock clock;

  ProgramOutcome<ProgramTargetProposal> preview({
    required ProgramCode programCode,
    required ProgramProposalInputs inputs,
    required bool requiresTargetWeight,
    required bool requiresHabitFocus,
  }) {
    return engine.proposeTarget(
      program: programCode,
      ageYears: inputs.ageYears,
      biologicalInput: inputs.biologicalInput,
      height: inputs.height,
      currentWeight: inputs.currentWeight,
      estimate: _estimateFrom(inputs),
      screening: inputs.screening,
      specific: inputs.specific,
      asOfDate: clock.today(),
      programRequiresTargetWeight: requiresTargetWeight,
      programRequiresHabitFocus: requiresHabitFocus,
    );
  }

  Future<RevisionResult> approve({
    required String profileId,
    required ProgramCode programCode,
    required ProgramProposalInputs previewInputs,
    required ProgramProposalInputs currentInputs,
    required bool requiresTargetWeight,
    required bool requiresHabitFocus,
  }) async {
    if (!previewInputs.matches(currentInputs)) {
      final refreshedOutcome = preview(
        programCode: programCode,
        inputs: currentInputs,
        requiresTargetWeight: requiresTargetWeight,
        requiresHabitFocus: requiresHabitFocus,
      );
      return RevisionInputsChanged(
        refreshedInputs: currentInputs,
        refreshedOutcome: refreshedOutcome,
      );
    }

    final estimate = _estimateFrom(currentInputs);
    final result = await changeCommand.execute(
      profileId: profileId,
      newProgramCode: programCode,
      currentInputs: currentInputs,
      userConfirmed: true,
      programRequiresTargetWeight: requiresTargetWeight,
      programRequiresHabitFocus: requiresHabitFocus,
      estimate: estimate,
    );

    return switch (result) {
      ChangeSucceeded() => RevisionSucceeded(result),
      ChangeRejectedNotApproved(:final outcome) => RevisionRejected(outcome),
      ChangeNoRunningProgram() => const RevisionNoRunningProgram(),
      ChangeFailed(:final error) => RevisionFailed(error),
      ChangeRequiresConfirmation() => const RevisionFailed(
        'userConfirmed=true tetapi perintah meminta konfirmasi — tidak seharusnya terjadi',
      ),
    };
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
        'fakta revisi tidak valid untuk kalkulator: $outcome',
      ),
    };
  }
}

final Provider<ProgramRevisionService> programRevisionServiceProvider =
    Provider<ProgramRevisionService>(
      (ref) => ProgramRevisionService(
        engine: ref.watch(programEngineProvider),
        changeCommand: ref.watch(changeProgramCommandProvider),
        clock: ref.watch(clockProvider),
      ),
    );
