import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/core/clock/fixed_clock.dart';
import 'package:mealora/core/errors/result.dart';
import 'package:mealora/core/ids/sequential_id_generator.dart';
import 'package:mealora/domain/nutrition/activity_level.dart';
import 'package:mealora/domain/nutrition/biological_input.dart';
import 'package:mealora/domain/program/commands/activate_program_command.dart';
import 'package:mealora/domain/program/commands/activation_result.dart';
import 'package:mealora/domain/program/commands/change_program_command.dart';
import 'package:mealora/domain/program/nutrition_policy.dart';
import 'package:mealora/domain/program/program_code.dart';
import 'package:mealora/domain/program/program_engine.dart';
import 'package:mealora/domain/program/program_proposal_inputs.dart';
import 'package:mealora/domain/program/program_specific_input.dart';
import 'package:mealora/domain/program/program_state.dart';
import 'package:mealora/domain/program/program_target_proposal.dart';
import 'package:mealora/domain/shared/program_outcome.dart';
import 'package:mealora/domain/shared/units.dart';
import 'package:mealora/features/program/program_revision_service.dart';

import '../../domain/program/fakes/in_memory_program_repository.dart';

/// Uji lapisan `ProgramRevisionService` yang dipakai bersama oleh pergantian
/// program (task 6.5-6.7) dan revisi target dari ubah profil (task 8.5-8.6).
/// Keduanya memanggil service yang sama (Design D5), jadi satu berkas uji
/// ini menegaskan perilaku untuk kedua jalur: tidak ada layar/alur yang
/// diuji dua kali secara terpisah, karena di domain memang satu hal yang
/// sama (Design D5, lihat komentar `ProgramRevisionService`).
void main() {
  final engine = ProgramEngine(
    NutritionPolicy.np100(status: PolicyApprovalStatus.approved),
  );
  final clock = FixedClock(
    instantUtc: DateTime.utc(2026, 11, 8, 10),
    timeZoneId: 'Asia/Jakarta',
    utcOffset: const Duration(hours: 7),
  );

  ProgramProposalInputs maintenanceInputs({double currentWeight = 68.4}) =>
      ProgramProposalInputs(
        ageYears: 29,
        biologicalInput: BiologicalInput.female,
        height: (Length.cmValue(165, field: 'h') as Ok<Length>).value,
        currentWeight:
            (Mass.kgValue(currentWeight, field: 'w') as Ok<Mass>).value,
        activity: ActivityLevel.moderatelyActive,
      );

  ProgramProposalInputs healthyEatingInputs({double currentWeight = 68.4}) =>
      ProgramProposalInputs(
        ageYears: 29,
        biologicalInput: BiologicalInput.female,
        height: (Length.cmValue(165, field: 'h') as Ok<Length>).value,
        currentWeight:
            (Mass.kgValue(currentWeight, field: 'w') as Ok<Mass>).value,
        activity: ActivityLevel.moderatelyActive,
        specific: const ProgramSpecificInput(habitFocus: 'makan_sayur'),
      );

  /// Profil yang DITOLAK kebijakan untuk program pengubah berat (usia di
  /// bawah minimum) — dipakai menguji task 6.4/8.4 (penolakan tanpa angka
  /// target, program/target lama tidak tersentuh).
  ProgramProposalInputs ineligibleWeightLossInputs() => ProgramProposalInputs(
    ageYears: 16,
    biologicalInput: BiologicalInput.female,
    height: (Length.cmValue(160, field: 'h') as Ok<Length>).value,
    currentWeight: (Mass.kgValue(55, field: 'w') as Ok<Mass>).value,
    activity: ActivityLevel.moderatelyActive,
  );

  ({ProgramRevisionService service, InMemoryProgramRepository repository})
  newService(InMemoryProgramRepository repository, SequentialIdGenerator ids) {
    return (
      service: ProgramRevisionService(
        engine: engine,
        changeCommand: ChangeProgramCommand(
          repository: repository,
          clock: clock,
          idGenerator: ids,
          engine: engine,
        ),
        clock: clock,
      ),
      repository: repository,
    );
  }

  group('ProgramRevisionService.preview', () {
    test('murni perhitungan — tidak menulis apa pun ke penyimpanan', () async {
      final repository = InMemoryProgramRepository();
      final idGenerator = SequentialIdGenerator();
      final service = newService(repository, idGenerator).service;
      final activate = ActivateProgramCommand(
        repository: repository,
        clock: clock,
        idGenerator: idGenerator,
        engine: engine,
      );
      final inputs = maintenanceInputs();
      await activate.execute(
        profileId: 'profile-1',
        program: ProgramCode.maintenance,
        previewInputs: inputs,
        currentInputs: inputs,
        userConfirmed: true,
        programRequiresTargetWeight: false,
        programRequiresHabitFocus: false,
      );
      final before = repository.allPrograms.length;

      service.preview(
        programCode: ProgramCode.healthyEating,
        inputs: inputs,
        requiresTargetWeight: false,
        requiresHabitFocus: true,
      );

      expect(
        repository.allPrograms.length,
        before,
        reason:
            'task 6.5/8.5: membuka pratinjau saja (tanpa menyetujui) tidak boleh mengubah penyimpanan sama sekali',
      );
    });
  });

  group('ProgramRevisionService.approve — pergantian program (task 6)', () {
    test(
      'masukan berubah sejak pratinjau: TIDAK menulis apa pun, melaporkan pratinjau segar (task 6.3)',
      () async {
        final repository = InMemoryProgramRepository();
        final idGenerator = SequentialIdGenerator();
        final service = newService(repository, idGenerator).service;
        final activate = ActivateProgramCommand(
          repository: repository,
          clock: clock,
          idGenerator: idGenerator,
          engine: engine,
        );
        final original = maintenanceInputs();
        final activated =
            await activate.execute(
                  profileId: 'profile-1',
                  program: ProgramCode.maintenance,
                  previewInputs: original,
                  currentInputs: original,
                  userConfirmed: true,
                  programRequiresTargetWeight: false,
                  programRequiresHabitFocus: false,
                )
                as ActivationSucceeded;
        final beforeCount = repository.allPrograms.length;

        final changedWeight = healthyEatingInputs(currentWeight: 70.0);
        final result = await service.approve(
          profileId: 'profile-1',
          programCode: ProgramCode.healthyEating,
          previewInputs: healthyEatingInputs(),
          currentInputs: changedWeight,
          requiresTargetWeight: false,
          requiresHabitFocus: true,
        );

        expect(result, isA<RevisionInputsChanged>());
        expect(repository.allPrograms.length, beforeCount);
        final stillRunning = await repository.findRunning('profile-1');
        expect(stillRunning?.id, activated.program.id);
        expect(stillRunning?.state, ProgramState.active);
      },
    );

    test(
      'disetujui: program lama pindah ke riwayat (changed), program baru aktif, '
      'target lama tetap tersimpan apa adanya (task 6.6, 8.6)',
      () async {
        final repository = InMemoryProgramRepository();
        final idGenerator = SequentialIdGenerator();
        final service = newService(repository, idGenerator).service;
        final activate = ActivateProgramCommand(
          repository: repository,
          clock: clock,
          idGenerator: idGenerator,
          engine: engine,
        );
        final original = maintenanceInputs();
        final activated =
            await activate.execute(
                  profileId: 'profile-1',
                  program: ProgramCode.maintenance,
                  previewInputs: original,
                  currentInputs: original,
                  userConfirmed: true,
                  programRequiresTargetWeight: false,
                  programRequiresHabitFocus: false,
                )
                as ActivationSucceeded;
        final originalProposal = activated.program.proposal;

        final newInputs = healthyEatingInputs();
        final result = await service.approve(
          profileId: 'profile-1',
          programCode: ProgramCode.healthyEating,
          previewInputs: newInputs,
          currentInputs: newInputs,
          requiresTargetWeight: false,
          requiresHabitFocus: true,
        );

        expect(result, isA<RevisionSucceeded>());
        final succeeded = (result as RevisionSucceeded).change;

        // Program lama: dipindahkan ke riwayat dengan keadaan `changed`,
        // tertaut ke program baru, dan proposal/target-nya TIDAK ditulis
        // ulang — tetap seperti saat program itu disetujui (Design D6).
        final oldReloaded = await repository.findById(activated.program.id);
        expect(oldReloaded?.state, ProgramState.changed);
        expect(oldReloaded?.supersededByUserProgramId, succeeded.newProgram.id);
        expect(
          oldReloaded?.proposal.energyTarget?.kcal,
          originalProposal.energyTarget?.kcal,
          reason: 'target lama tersimpan apa adanya, tidak dihitung ulang',
        );
        expect(
          oldReloaded?.proposal.calculatorVersion,
          originalProposal.calculatorVersion,
        );

        // Program baru: aktif, tertaut balik ke program lama.
        final running = await repository.findRunning('profile-1');
        expect(running?.id, succeeded.newProgram.id);
        expect(running?.state, ProgramState.active);
        expect(running?.supersedesUserProgramId, activated.program.id);

        // Riwayat (task 7) memuat keduanya berurutan.
        final history = await repository.history('profile-1');
        expect(
          history.map((p) => p.id),
          containsAll(<String>[activated.program.id, succeeded.newProgram.id]),
        );
      },
    );

    test('penolakan kebijakan atas pengganti: program lama TIDAK tersentuh, '
        'tanpa satu pun angka target di hasil (task 6.4/8.4)', () async {
      final repository = InMemoryProgramRepository();
      final idGenerator = SequentialIdGenerator();
      final service = newService(repository, idGenerator).service;
      final activate = ActivateProgramCommand(
        repository: repository,
        clock: clock,
        idGenerator: idGenerator,
        engine: engine,
      );
      final original = maintenanceInputs();
      final activated =
          await activate.execute(
                profileId: 'profile-1',
                program: ProgramCode.maintenance,
                previewInputs: original,
                currentInputs: original,
                userConfirmed: true,
                programRequiresTargetWeight: false,
                programRequiresHabitFocus: false,
              )
              as ActivationSucceeded;

      final ineligible = ineligibleWeightLossInputs();
      final result = await service.approve(
        profileId: 'profile-1',
        programCode: ProgramCode.weightLoss,
        previewInputs: ineligible,
        currentInputs: ineligible,
        requiresTargetWeight: true,
        requiresHabitFocus: false,
      );

      expect(result, isA<RevisionRejected>());
      final rejected = (result as RevisionRejected).outcome;
      expect(rejected, isNot(isA<Approved<ProgramTargetProposal>>()));

      final stillRunning = await repository.findRunning('profile-1');
      expect(
        stillRunning?.id,
        activated.program.id,
        reason: 'program lama tetap berjalan setelah pengganti ditolak',
      );
      expect(stillRunning?.state, ProgramState.active);
      expect(
        repository.allPrograms.length,
        1,
        reason: 'tidak ada program baru yang tertulis ketika ditolak',
      );
    });
  });

  group(
    'ProgramRevisionService.approve — revisi profil, program sama (task 8)',
    () {
      test('menutup peninjauan tanpa menyetujui: target lama tetap berlaku, '
          'riwayat tidak berubah (task 8.5)', () async {
        final repository = InMemoryProgramRepository();
        final idGenerator = SequentialIdGenerator();
        final service = newService(repository, idGenerator).service;
        final activate = ActivateProgramCommand(
          repository: repository,
          clock: clock,
          idGenerator: idGenerator,
          engine: engine,
        );
        final original = maintenanceInputs();
        final activated =
            await activate.execute(
                  profileId: 'profile-1',
                  program: ProgramCode.maintenance,
                  previewInputs: original,
                  currentInputs: original,
                  userConfirmed: true,
                  programRequiresTargetWeight: false,
                  programRequiresHabitFocus: false,
                )
                as ActivationSucceeded;

        // Hanya memanggil preview() — setara dengan membuka layar 34 lalu
        // menutupnya kembali tanpa menekan "Tinjau target baru" sampai
        // menyetujui. service.approve() TIDAK dipanggil sama sekali.
        service.preview(
          programCode: ProgramCode.maintenance,
          inputs: maintenanceInputs(currentWeight: 71.0),
          requiresTargetWeight: false,
          requiresHabitFocus: false,
        );

        final stillRunning = await repository.findRunning('profile-1');
        expect(stillRunning?.id, activated.program.id);
        expect(
          stillRunning?.proposal.energyTarget?.kcal,
          activated.program.proposal.energyTarget?.kcal,
          reason: 'target yang berlaku tidak berubah',
        );
        expect(await repository.history('profile-1'), hasLength(1));
      });

      test('menyetujui revisi: target baru berlaku sekarang, target sebelumnya '
          'tetap tersimpan apa adanya di riwayat (task 8.6)', () async {
        final repository = InMemoryProgramRepository();
        final idGenerator = SequentialIdGenerator();
        final service = newService(repository, idGenerator).service;
        final activate = ActivateProgramCommand(
          repository: repository,
          clock: clock,
          idGenerator: idGenerator,
          engine: engine,
        );
        final original = maintenanceInputs(currentWeight: 68.4);
        final activated =
            await activate.execute(
                  profileId: 'profile-1',
                  program: ProgramCode.maintenance,
                  previewInputs: original,
                  currentInputs: original,
                  userConfirmed: true,
                  programRequiresTargetWeight: false,
                  programRequiresHabitFocus: false,
                )
                as ActivationSucceeded;
        final oldEnergyTarget = activated.program.proposal.energyTarget?.kcal;

        // Revisi profil: BERAT berubah (seolah pengguna memperbarui profil
        // di layar 34), programCode-nya sama persis — bukan pergantian
        // program (task 6), tapi mesin di baliknya satu hal yang sama
        // (Design D5).
        final revisedInputs = maintenanceInputs(currentWeight: 75.0);
        final result = await service.approve(
          profileId: 'profile-1',
          programCode: ProgramCode.maintenance,
          previewInputs: revisedInputs,
          currentInputs: revisedInputs,
          requiresTargetWeight: false,
          requiresHabitFocus: false,
        );

        expect(result, isA<RevisionSucceeded>());
        final succeeded = (result as RevisionSucceeded).change;
        final newEnergyTarget =
            succeeded.newProgram.proposal.energyTarget?.kcal;

        expect(
          newEnergyTarget,
          isNot(oldEnergyTarget),
          reason: 'berat yang berbeda signifikan menghasilkan target berbeda',
        );

        final running = await repository.findRunning('profile-1');
        expect(running?.id, succeeded.newProgram.id);
        expect(running?.proposal.energyTarget?.kcal, newEnergyTarget);

        final oldReloaded = await repository.findById(activated.program.id);
        expect(oldReloaded?.state, ProgramState.changed);
        expect(
          oldReloaded?.proposal.energyTarget?.kcal,
          oldEnergyTarget,
          reason:
              'target sebelumnya tetap tersimpan apa adanya di riwayat, tidak ditulis ulang',
        );
      });
    },
  );

  group('Paritas jalur masuk onboarding vs pergantian (task 6.7)', () {
    test('pratinjau pergantian menghasilkan versi kalkulator/kebijakan yang sama '
        'dengan aktivasi onboarding untuk masukan setara', () async {
      final repository = InMemoryProgramRepository();
      final idGenerator = SequentialIdGenerator();
      final activate = ActivateProgramCommand(
        repository: repository,
        clock: clock,
        idGenerator: idGenerator,
        engine: engine,
      );
      final service = ProgramRevisionService(
        engine: engine,
        changeCommand: ChangeProgramCommand(
          repository: repository,
          clock: clock,
          idGenerator: idGenerator,
          engine: engine,
        ),
        clock: clock,
      );
      final inputs = maintenanceInputs();

      final onboardingResult =
          await activate.execute(
                profileId: 'profile-onboarding',
                program: ProgramCode.maintenance,
                previewInputs: inputs,
                currentInputs: inputs,
                userConfirmed: true,
                programRequiresTargetWeight: false,
                programRequiresHabitFocus: false,
              )
              as ActivationSucceeded;

      final changeOutcome = service.preview(
        programCode: ProgramCode.maintenance,
        inputs: inputs,
        requiresTargetWeight: false,
        requiresHabitFocus: false,
      );

      expect(changeOutcome, isA<Approved<ProgramTargetProposal>>());
      final changeProposal =
          (changeOutcome as Approved<ProgramTargetProposal>).value;
      final onboardingProposal = onboardingResult.program.proposal;

      expect(
        changeProposal.calculatorVersion,
        onboardingProposal.calculatorVersion,
        reason:
            'kedua jalur masuk (onboarding & pergantian) memakai mesin kebijakan/kalkulator yang sama (Design D4)',
      );
      expect(changeProposal.policyVersion, onboardingProposal.policyVersion);
      expect(
        changeProposal.energyTarget?.kcal,
        onboardingProposal.energyTarget?.kcal,
        reason: 'masukan setara harus menghasilkan target yang sama persis',
      );

      // Re-verifikasi "masukan berubah sejak pratinjau" berlaku sama-sama
      // di kedua jalur (task 6.3): onboarding lewat ActivateProgramCommand
      // sendiri, pergantian/revisi lewat ProgramRevisionService.approve.
      final staleOnboarding =
          await ActivateProgramCommand(
            repository: InMemoryProgramRepository(),
            clock: clock,
            idGenerator: SequentialIdGenerator(),
            engine: engine,
          ).execute(
            profileId: 'profile-2',
            program: ProgramCode.maintenance,
            previewInputs: inputs,
            currentInputs: maintenanceInputs(currentWeight: 70.0),
            userConfirmed: true,
            programRequiresTargetWeight: false,
            programRequiresHabitFocus: false,
          );
      expect(staleOnboarding, isA<ActivationInputsChangedSincePreview>());

      final staleChange = await service.approve(
        profileId: 'profile-onboarding',
        programCode: ProgramCode.maintenance,
        previewInputs: inputs,
        currentInputs: maintenanceInputs(currentWeight: 70.0),
        requiresTargetWeight: false,
        requiresHabitFocus: false,
      );
      expect(staleChange, isA<RevisionInputsChanged>());
    });
  });
}
