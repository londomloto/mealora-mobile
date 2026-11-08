import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/core/clock/fixed_clock.dart';
import 'package:mealora/core/errors/result.dart';
import 'package:mealora/core/ids/sequential_id_generator.dart';
import 'package:mealora/domain/nutrition/activity_level.dart';
import 'package:mealora/domain/nutrition/biological_input.dart';
import 'package:mealora/domain/nutrition/energy_equation_policy.dart';
import 'package:mealora/domain/nutrition/nutrition_calculator.dart';
import 'package:mealora/domain/nutrition/nutrition_estimate.dart';
import 'package:mealora/domain/nutrition/physiological_facts.dart';
import 'package:mealora/domain/program/commands/activate_program_command.dart';
import 'package:mealora/domain/program/commands/activation_result.dart';
import 'package:mealora/domain/program/commands/change_program_command.dart';
import 'package:mealora/domain/program/commands/simple_lifecycle_commands.dart';
import 'package:mealora/domain/program/nutrition_policy.dart';
import 'package:mealora/domain/program/program_code.dart';
import 'package:mealora/domain/program/program_engine.dart';
import 'package:mealora/domain/program/program_event.dart';
import 'package:mealora/domain/program/program_proposal_inputs.dart';
import 'package:mealora/domain/program/program_specific_input.dart';
import 'package:mealora/domain/program/program_state.dart';
import 'package:mealora/domain/shared/program_outcome.dart';
import 'package:mealora/domain/shared/units.dart';

import 'fakes/in_memory_program_repository.dart';

ProgramProposalInputs _maintenanceInputs({double currentWeight = 68.4}) =>
    ProgramProposalInputs(
      ageYears: 29,
      biologicalInput: BiologicalInput.female,
      height: (Length.cmValue(165, field: 'h') as Ok<Length>).value,
      currentWeight:
          (Mass.kgValue(currentWeight, field: 'w') as Ok<Mass>).value,
      activity: ActivityLevel.moderatelyActive,
    );

ProgramProposalInputs _healthyEatingInputs({double currentWeight = 68.4}) =>
    ProgramProposalInputs(
      ageYears: 29,
      biologicalInput: BiologicalInput.female,
      height: (Length.cmValue(165, field: 'h') as Ok<Length>).value,
      currentWeight:
          (Mass.kgValue(currentWeight, field: 'w') as Ok<Mass>).value,
      activity: ActivityLevel.moderatelyActive,
      specific: const ProgramSpecificInput(habitFocus: 'makan_sayur'),
    );

NutritionEstimate _estimateFor(ProgramProposalInputs inputs) {
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
    _ => throw StateError('tidak valid: $outcome'),
  };
}

void main() {
  final engine = ProgramEngine(
    NutritionPolicy.np100(status: PolicyApprovalStatus.approved),
  );
  final clock = FixedClock(
    instantUtc: DateTime.utc(2026, 11, 8, 10),
    timeZoneId: 'Asia/Jakarta',
    utcOffset: const Duration(hours: 7),
  );

  InMemoryProgramRepository repo() => InMemoryProgramRepository();
  SequentialIdGenerator ids() => SequentialIdGenerator();

  group('ActivateProgramCommand', () {
    test('mengaktifkan program baru ketika semua syarat terpenuhi', () async {
      final repository = repo();
      final command = ActivateProgramCommand(
        repository: repository,
        clock: clock,
        idGenerator: ids(),
        engine: engine,
      );
      final inputs = _maintenanceInputs();

      final result = await command.execute(
        profileId: 'profile-1',
        program: ProgramCode.maintenance,
        previewInputs: inputs,
        currentInputs: inputs,
        userConfirmed: true,
        programRequiresTargetWeight: false,
        programRequiresHabitFocus: false,
      );

      expect(result, isA<ActivationSucceeded>());
      final succeeded = result as ActivationSucceeded;
      expect(succeeded.program.state, ProgramState.active);
      expect(succeeded.program.proposal.energyTarget, isNotNull);
      expect(succeeded.program.proposal.policyVersion, 'np-1.0.0');
      expect(succeeded.program.proposal.calculatorVersion, 'msj-1.0.0');
      expect(await repository.eventsFor(succeeded.program.id), hasLength(1));
    });

    test('menolak tanpa konfirmasi pengguna', () async {
      final command = ActivateProgramCommand(
        repository: repo(),
        clock: clock,
        idGenerator: ids(),
        engine: engine,
      );
      final inputs = _maintenanceInputs();

      final result = await command.execute(
        profileId: 'profile-1',
        program: ProgramCode.maintenance,
        previewInputs: inputs,
        currentInputs: inputs,
        userConfirmed: false,
        programRequiresTargetWeight: false,
        programRequiresHabitFocus: false,
      );

      expect(result, isA<ActivationRequiresConfirmation>());
    });

    test(
      'membatalkan aktivasi ketika masukan berubah sejak pratinjau',
      () async {
        final command = ActivateProgramCommand(
          repository: repo(),
          clock: clock,
          idGenerator: ids(),
          engine: engine,
        );

        final result = await command.execute(
          profileId: 'profile-1',
          program: ProgramCode.maintenance,
          previewInputs: _maintenanceInputs(currentWeight: 68.4),
          currentInputs: _maintenanceInputs(currentWeight: 70.0),
          userConfirmed: true,
          programRequiresTargetWeight: false,
          programRequiresHabitFocus: false,
        );

        expect(result, isA<ActivationInputsChangedSincePreview>());
      },
    );

    test(
      'menolak aktivasi atas hasil yang tidak disetujui meski dikonfirmasi',
      () async {
        final command = ActivateProgramCommand(
          repository: repo(),
          clock: clock,
          idGenerator: ids(),
          engine: engine,
        );
        final inputs = ProgramProposalInputs(
          ageYears: 16, // di bawah minimum untuk program pengubah berat
          biologicalInput: BiologicalInput.female,
          height: (Length.cmValue(160, field: 'h') as Ok<Length>).value,
          currentWeight: (Mass.kgValue(55, field: 'w') as Ok<Mass>).value,
          activity: ActivityLevel.moderatelyActive,
        );

        final result = await command.execute(
          profileId: 'profile-1',
          program: ProgramCode.weightLoss,
          previewInputs: inputs,
          currentInputs: inputs,
          userConfirmed: true,
          programRequiresTargetWeight: true,
          programRequiresHabitFocus: false,
        );

        expect(result, isA<ActivationRejectedNotApproved>());
      },
    );

    test(
      'aktivasi dikirim dua kali tetap menghasilkan satu program berjalan',
      () async {
        final repository = repo();
        final command = ActivateProgramCommand(
          repository: repository,
          clock: clock,
          idGenerator: ids(),
          engine: engine,
        );
        final inputs = _maintenanceInputs();

        final first = await command.execute(
          profileId: 'profile-1',
          program: ProgramCode.maintenance,
          previewInputs: inputs,
          currentInputs: inputs,
          userConfirmed: true,
          programRequiresTargetWeight: false,
          programRequiresHabitFocus: false,
        );
        final second = await command.execute(
          profileId: 'profile-1',
          program: ProgramCode.maintenance,
          previewInputs: inputs,
          currentInputs: inputs,
          userConfirmed: true,
          programRequiresTargetWeight: false,
          programRequiresHabitFocus: false,
        );

        expect(first, isA<ActivationSucceeded>());
        expect(second, isA<ActivationAlreadySatisfied>());
        expect(
          repository.allPrograms.where((p) => p.state.isRunning).length,
          1,
        );
      },
    );

    test(
      'draf tidak mengganggu program berjalan — aktivasi program berbeda berarti konflik',
      () async {
        final repository = repo();
        final command = ActivateProgramCommand(
          repository: repository,
          clock: clock,
          idGenerator: ids(),
          engine: engine,
        );
        final inputs = _maintenanceInputs();
        await command.execute(
          profileId: 'profile-1',
          program: ProgramCode.maintenance,
          previewInputs: inputs,
          currentInputs: inputs,
          userConfirmed: true,
          programRequiresTargetWeight: false,
          programRequiresHabitFocus: false,
        );

        final healthyEatingInputs = _healthyEatingInputs();
        final result = await command.execute(
          profileId: 'profile-1',
          program: ProgramCode.healthyEating,
          previewInputs: healthyEatingInputs,
          currentInputs: healthyEatingInputs,
          userConfirmed: true,
          programRequiresTargetWeight: false,
          programRequiresHabitFocus: true,
        );

        expect(result, isA<ActivationConflictExistingRunningProgram>());
      },
    );
  });

  group('ChangeProgramCommand', () {
    test('pergantian berhasil: lama changed tertaut, baru active', () async {
      final repository = repo();
      final idGenerator = ids();
      final activate = ActivateProgramCommand(
        repository: repository,
        clock: clock,
        idGenerator: idGenerator,
        engine: engine,
      );
      final inputs = _maintenanceInputs();
      final activated =
          await activate.execute(
                profileId: 'profile-1',
                program: ProgramCode.maintenance,
                previewInputs: inputs,
                currentInputs: inputs,
                userConfirmed: true,
                programRequiresTargetWeight: false,
                programRequiresHabitFocus: false,
              )
              as ActivationSucceeded;

      final change = ChangeProgramCommand(
        repository: repository,
        clock: clock,
        idGenerator: idGenerator,
        engine: engine,
      );
      final newInputs = _healthyEatingInputs();
      final result = await change.execute(
        profileId: 'profile-1',
        newProgramCode: ProgramCode.healthyEating,
        currentInputs: newInputs,
        userConfirmed: true,
        programRequiresTargetWeight: false,
        programRequiresHabitFocus: true,
        estimate: _estimateFor(newInputs),
      );

      expect(result, isA<ChangeSucceeded>());
      final succeeded = result as ChangeSucceeded;
      expect(succeeded.oldProgram.state, ProgramState.changed);
      expect(
        succeeded.oldProgram.supersededByUserProgramId,
        succeeded.newProgram.id,
      );
      expect(succeeded.newProgram.state, ProgramState.active);
      expect(
        succeeded.newProgram.supersedesUserProgramId,
        activated.program.id,
      );

      final running = await repository.findRunning('profile-1');
      expect(running?.id, succeeded.newProgram.id);
    });

    test(
      'pergantian gagal di tengah jalan mengembalikan seluruh keadaan',
      () async {
        final repository = repo();
        final idGenerator = ids();
        final activate = ActivateProgramCommand(
          repository: repository,
          clock: clock,
          idGenerator: idGenerator,
          engine: engine,
        );
        final inputs = _maintenanceInputs();
        final activated =
            await activate.execute(
                  profileId: 'profile-1',
                  program: ProgramCode.maintenance,
                  previewInputs: inputs,
                  currentInputs: inputs,
                  userConfirmed: true,
                  programRequiresTargetWeight: false,
                  programRequiresHabitFocus: false,
                )
                as ActivationSucceeded;

        for (final checkpoint in [
          'after_supersede',
          'after_new_program',
          'after_events',
        ]) {
          final failingRepo = repo();
          await failingRepo.upsert(activated.program);
          failingRepo.failureInjector = (c) {
            if (c == checkpoint) {
              throw StateError('kegagalan disuntikkan di $checkpoint');
            }
          };

          final change = ChangeProgramCommand(
            repository: failingRepo,
            clock: clock,
            idGenerator: idGenerator,
            engine: engine,
          );
          final newInputs = _healthyEatingInputs();
          final result = await change.execute(
            profileId: 'profile-1',
            newProgramCode: ProgramCode.healthyEating,
            currentInputs: newInputs,
            userConfirmed: true,
            programRequiresTargetWeight: false,
            programRequiresHabitFocus: true,
            estimate: _estimateFor(newInputs),
          );

          expect(result, isA<ChangeFailed>(), reason: 'checkpoint $checkpoint');
          final restored = await failingRepo.findById(activated.program.id);
          expect(
            restored?.state,
            ProgramState.active,
            reason: 'checkpoint $checkpoint',
          );
          expect(
            failingRepo.allPrograms.length,
            1,
            reason: 'checkpoint $checkpoint: tidak ada program baru yang bocor',
          );
        }
      },
    );

    test('pembatalan sebelum konfirmasi tidak mengubah apa pun', () async {
      final repository = repo();
      final idGenerator = ids();
      final activate = ActivateProgramCommand(
        repository: repository,
        clock: clock,
        idGenerator: idGenerator,
        engine: engine,
      );
      final inputs = _maintenanceInputs();
      final activated =
          await activate.execute(
                profileId: 'profile-1',
                program: ProgramCode.maintenance,
                previewInputs: inputs,
                currentInputs: inputs,
                userConfirmed: true,
                programRequiresTargetWeight: false,
                programRequiresHabitFocus: false,
              )
              as ActivationSucceeded;

      final change = ChangeProgramCommand(
        repository: repository,
        clock: clock,
        idGenerator: idGenerator,
        engine: engine,
      );
      final newInputs = _healthyEatingInputs();
      final result = await change.execute(
        profileId: 'profile-1',
        newProgramCode: ProgramCode.healthyEating,
        currentInputs: newInputs,
        userConfirmed: false,
        programRequiresTargetWeight: false,
        programRequiresHabitFocus: true,
        estimate: _estimateFor(newInputs),
      );

      expect(result, isA<ChangeRequiresConfirmation>());
      expect(
        (await repository.findById(activated.program.id))?.state,
        ProgramState.active,
      );
      expect(repository.allPrograms, hasLength(1));
    });
  });

  group('Jeda, lanjutkan, selesaikan, batalkan', () {
    late InMemoryProgramRepository repository;
    late String programId;

    setUp(() async {
      repository = repo();
      final activate = ActivateProgramCommand(
        repository: repository,
        clock: clock,
        idGenerator: ids(),
        engine: engine,
      );
      final inputs = _maintenanceInputs();
      final activated =
          await activate.execute(
                profileId: 'profile-1',
                program: ProgramCode.maintenance,
                previewInputs: inputs,
                currentInputs: inputs,
                userConfirmed: true,
                programRequiresTargetWeight: false,
                programRequiresHabitFocus: false,
              )
              as ActivationSucceeded;
      programId = activated.program.id;
    });

    test('jeda mencatat rentang dan berhenti menambah hari aktif', () async {
      final pause = PauseProgramCommand(
        repository: repository,
        clock: clock,
        idGenerator: ids(),
      );
      final result = await pause.execute(userProgramId: programId);

      expect(result, isA<SimpleCommandSucceeded>());
      final paused = (result as SimpleCommandSucceeded).program;
      expect(paused.state, ProgramState.paused);
      expect(paused.pauseIntervals, hasLength(1));
      expect(paused.pauseIntervals.single.isOpen, isTrue);
    });

    test('jeda dikirim dua kali tidak mencatat peristiwa ganda', () async {
      final idGenerator = ids();
      final pause = PauseProgramCommand(
        repository: repository,
        clock: clock,
        idGenerator: idGenerator,
      );
      final first =
          await pause.execute(userProgramId: programId)
              as SimpleCommandSucceeded;
      final second = await pause.execute(userProgramId: programId);

      expect(second, isA<SimpleCommandAlreadySatisfied>());
      expect(
        (await repository.eventsFor(
          programId,
        )).where((e) => e.type == ProgramEventType.paused),
        hasLength(1),
      );
      expect(
        first.program.pauseIntervals.single.startedAt,
        (second as SimpleCommandAlreadySatisfied)
            .program
            .pauseIntervals
            .single
            .startedAt,
      );
    });

    test(
      'lanjutkan mengembalikan ke active dan menutup rentang jeda',
      () async {
        final pause = PauseProgramCommand(
          repository: repository,
          clock: clock,
          idGenerator: ids(),
        );
        await pause.execute(userProgramId: programId);

        clock.advance(const Duration(days: 3));
        final resume = ResumeProgramCommand(
          repository: repository,
          clock: clock,
          idGenerator: ids(),
        );
        final result =
            await resume.execute(userProgramId: programId)
                as SimpleCommandSucceeded;

        expect(result.program.state, ProgramState.active);
        expect(result.program.pauseIntervals.single.isOpen, isFalse);
      },
    );

    test('melanjutkan program yang sudah selesai ditolak bertipe', () async {
      final complete = CompleteProgramCommand(
        repository: repository,
        clock: clock,
        idGenerator: ids(),
      );
      await complete.execute(
        userProgramId: programId,
        reasonCode: 'goal_reached',
      );

      final resume = ResumeProgramCommand(
        repository: repository,
        clock: clock,
        idGenerator: ids(),
      );
      final result = await resume.execute(userProgramId: programId);

      expect(result, isA<SimpleCommandInvalidTransition>());
      expect(
        (await repository.findById(programId))?.state,
        ProgramState.completed,
      );
    });

    test(
      'selesaikan mencatat alasan dan tidak dapat dilanjutkan lagi',
      () async {
        final complete = CompleteProgramCommand(
          repository: repository,
          clock: clock,
          idGenerator: ids(),
        );
        final result =
            await complete.execute(
                  userProgramId: programId,
                  reasonCode: 'goal_reached',
                )
                as SimpleCommandSucceeded;

        expect(result.program.state, ProgramState.completed);
        expect(result.program.completionReason, 'goal_reached');
      },
    );
  });
}
