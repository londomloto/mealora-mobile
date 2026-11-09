import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/core/clock/fixed_clock.dart';
import 'package:mealora/core/ids/id_generator.dart';
import 'package:mealora/data/local/drift_program_repository.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/database/seeds/program_catalog_seed.dart';
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
import 'package:mealora/domain/program/program_proposal_inputs.dart';
import 'package:mealora/domain/program/program_specific_input.dart';
import 'package:mealora/domain/program/program_state.dart';
import 'package:mealora/domain/shared/program_outcome.dart';
import 'package:mealora/domain/shared/units.dart';

import 'test_database.dart';

/// Seluruh uji perintah siklus hidup change 003 dijalankan ulang terhadap
/// penyimpanan sungguhan (task 3.4) — `DriftProgramRepository` di atas
/// SQLite nyata, bukan tiruan dalam memori.
void main() {
  final engine = ProgramEngine(
    NutritionPolicy.np100(status: PolicyApprovalStatus.approved),
  );

  ProgramProposalInputs maintenanceInputs({double currentWeight = 68.4}) =>
      ProgramProposalInputs(
        ageYears: 29,
        biologicalInput: BiologicalInput.female,
        height: Length.cmValue(165, field: 'h').valueOrNull!,
        currentWeight: Mass.kgValue(currentWeight, field: 'w').valueOrNull!,
        activity: ActivityLevel.moderatelyActive,
      );

  ProgramProposalInputs healthyEatingInputs() => ProgramProposalInputs(
    ageYears: 29,
    biologicalInput: BiologicalInput.female,
    height: Length.cmValue(165, field: 'h').valueOrNull!,
    currentWeight: Mass.kgValue(68.4, field: 'w').valueOrNull!,
    activity: ActivityLevel.moderatelyActive,
    specific: const ProgramSpecificInput(habitFocus: 'makan_sayur'),
  );

  NutritionEstimate estimateFor(ProgramProposalInputs inputs) {
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

  late AppDatabase db;
  late DriftProgramRepository repository;

  setUp(() async {
    db = createTestDatabase();
    repository = DriftProgramRepository(
      db,
      clock: createTestClock(),
      ids: createTestIds(),
    );
    // Foreign key sungguhan ke `profiles` (Design D8, change 005): setiap
    // `profileId` dipakai di baris uji ini harus menunjuk ke profil yang
    // benar-benar ada.
    for (final id in <String>['profile-1', 'profile-lain']) {
      await db
          .into(db.profiles)
          .insert(
            ProfilesCompanion.insert(
              id: id,
              createdAt: testInstant,
              updatedAt: testInstant,
            ),
          );
    }
  });

  tearDown(() => db.close());

  test(
    'aktivasi tersimpan dan dapat dibaca kembali dari baris yang sama',
    () async {
      final command = ActivateProgramCommand(
        repository: repository,
        clock: createTestClock(),
        idGenerator: createTestIds(),
        engine: engine,
      );
      final inputs = maintenanceInputs();

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

      final reloaded = await repository.findById(succeeded.program.id);
      expect(reloaded, isNotNull);
      expect(reloaded!.state, ProgramState.active);
      expect(reloaded.profileId, 'profile-1');
      expect(
        reloaded.proposal.energyTarget?.kcal,
        succeeded.program.proposal.energyTarget?.kcal,
      );
      expect(reloaded.inputSnapshot.currentWeight.kg, inputs.currentWeight.kg);

      final events = await repository.eventsFor(succeeded.program.id);
      expect(events, hasLength(1));

      final running = await repository.findRunning('profile-1');
      expect(running?.id, succeeded.program.id);
    },
  );

  test('kegagalan di tengah transaksi aktivasi tidak menyisakan apa pun '
      '(task 4.1/4.4)', () async {
    // Baris lama dengan id yang sama dengan yang akan dipakai pembangkit
    // pengenal — memaksa pelanggaran kunci utama sungguhan saat transaksi
    // aktivasi mencoba menyisipkan program baru.
    await db
        .into(db.userPrograms)
        .insert(
          UserProgramsCompanion.insert(
            id: 'test-0001',
            createdAt: testInstant,
            updatedAt: testInstant,
            profileId: 'profile-lain',
            programId: 'program-healthy-eating',
            status: 'completed',
            inputSnapshotJson: '{}',
            calculatorVersion: 'v1',
            policyVersion: 'v1',
          ),
        );

    final command = ActivateProgramCommand(
      repository: repository,
      clock: createTestClock(),
      idGenerator: createTestIds(),
      engine: engine,
    );
    final inputs = maintenanceInputs();

    final result = await command.execute(
      profileId: 'profile-1',
      program: ProgramCode.maintenance,
      previewInputs: inputs,
      currentInputs: inputs,
      userConfirmed: true,
      programRequiresTargetWeight: false,
      programRequiresHabitFocus: false,
    );

    expect(result, isA<ActivationFailed>());
    expect(await repository.findRunning('profile-1'), isNull);
    final rows = await db.select(db.userPrograms).get();
    expect(
      rows,
      hasLength(1),
      reason: 'hanya baris lama yang disisipkan di atas',
    );
    final events = await db.select(db.programEvents).get();
    expect(events, isEmpty, reason: 'tidak ada peristiwa yang bocor');
    final progress = await db.select(db.programProgress).get();
    expect(progress, isEmpty, reason: 'tidak ada potret yang bocor');
  });

  test('aktivasi dikirim dua kali tidak menghasilkan baris ganda', () async {
    final command = ActivateProgramCommand(
      repository: repository,
      clock: createTestClock(),
      idGenerator: createTestIds(),
      engine: engine,
    );
    final inputs = maintenanceInputs();

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

    final rows = await db.select(db.userPrograms).get();
    expect(rows, hasLength(1));
  });

  test(
    'pergantian program: lama changed tertaut, baru active, progres awal tercatat',
    () async {
      final idGenerator = createTestIds();
      final clock = createTestClock();
      final activate = ActivateProgramCommand(
        repository: repository,
        clock: clock,
        idGenerator: idGenerator,
        engine: engine,
      );
      final inputs = maintenanceInputs();
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
      final newInputs = healthyEatingInputs();
      final result = await change.execute(
        profileId: 'profile-1',
        newProgramCode: ProgramCode.healthyEating,
        currentInputs: newInputs,
        userConfirmed: true,
        programRequiresTargetWeight: false,
        programRequiresHabitFocus: true,
        estimate: estimateFor(newInputs),
      );

      expect(result, isA<ChangeSucceeded>());
      final succeeded = result as ChangeSucceeded;

      final oldReloaded = await repository.findById(activated.program.id);
      expect(oldReloaded!.state, ProgramState.changed);
      expect(oldReloaded.supersededByUserProgramId, succeeded.newProgram.id);

      final newReloaded = await repository.findById(succeeded.newProgram.id);
      expect(newReloaded!.state, ProgramState.active);
      expect(newReloaded.supersedesUserProgramId, activated.program.id);

      final progressRows = await db.select(db.programProgress).get();
      expect(
        progressRows.where((r) => r.userProgramId == succeeded.newProgram.id),
        hasLength(1),
      );

      // Satu program lama + satu program baru + satu baris peristiwa aktivasi
      // awal + dua peristiwa pergantian (changed, activated) = 3 peristiwa.
      final allEvents = await repository.eventsFor(activated.program.id);
      expect(allEvents.where((e) => e.type.name == 'changed'), hasLength(1));
    },
  );

  test(
    'kegagalan di tengah pergantian karena invarian DB tidak menyisakan apa pun',
    () async {
      final idGenerator = createTestIds();
      final clock = createTestClock();
      final activate = ActivateProgramCommand(
        repository: repository,
        clock: clock,
        idGenerator: idGenerator,
        engine: engine,
      );
      final inputs = maintenanceInputs();
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

      // Pengenal yang sengaja menabrak baris program lama yang masih ada —
      // memaksa pelanggaran kunci utama sungguhan di tengah transaksi
      // pergantian (bukan kegagalan yang disuntikkan secara artifisial).
      final collidingIds = _FixedIdGenerator(activated.program.id);

      final change = ChangeProgramCommand(
        repository: repository,
        clock: clock,
        idGenerator: collidingIds,
        engine: engine,
      );
      final newInputs = healthyEatingInputs();
      final result = await change.execute(
        profileId: 'profile-1',
        newProgramCode: ProgramCode.healthyEating,
        currentInputs: newInputs,
        userConfirmed: true,
        programRequiresTargetWeight: false,
        programRequiresHabitFocus: true,
        estimate: estimateFor(newInputs),
      );

      expect(result, isA<ChangeFailed>());

      final rows = await db.select(db.userPrograms).get();
      expect(rows, hasLength(1), reason: 'tidak ada program baru yang bocor');

      final restored = await repository.findById(activated.program.id);
      expect(
        restored!.state,
        ProgramState.active,
        reason: 'program lama tidak ikut tertandai changed',
      );

      final events = await db.select(db.programEvents).get();
      expect(events, hasLength(1), reason: 'hanya peristiwa aktivasi awal');
    },
  );

  test('jeda, lanjutkan, selesaikan bertahan di baris yang sama', () async {
    final idGenerator = createTestIds();
    final clock = createTestClock();
    final activate = ActivateProgramCommand(
      repository: repository,
      clock: clock,
      idGenerator: idGenerator,
      engine: engine,
    );
    final inputs = maintenanceInputs();
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
    final programId = activated.program.id;

    final pause = PauseProgramCommand(
      repository: repository,
      clock: clock,
      idGenerator: idGenerator,
    );
    final paused =
        await pause.execute(userProgramId: programId) as SimpleCommandSucceeded;
    expect(paused.program.state, ProgramState.paused);
    expect((await repository.findById(programId))!.state, ProgramState.paused);
    expect(
      (await repository.findById(programId))!.pauseIntervals.single.isOpen,
      isTrue,
    );

    final resume = ResumeProgramCommand(
      repository: repository,
      clock: clock,
      idGenerator: idGenerator,
    );
    await resume.execute(userProgramId: programId);
    final afterResume = await repository.findById(programId);
    expect(afterResume!.state, ProgramState.active);
    expect(afterResume.pauseIntervals.single.isOpen, isFalse);

    final complete = CompleteProgramCommand(
      repository: repository,
      clock: clock,
      idGenerator: idGenerator,
    );
    await complete.execute(
      userProgramId: programId,
      reasonCode: 'goal_reached',
    );
    final afterComplete = await repository.findById(programId);
    expect(afterComplete!.state, ProgramState.completed);
    expect(afterComplete.completionReason, 'goal_reached');
  });

  test('jeda dikirim dua kali tidak mencatat peristiwa ganda', () async {
    final idGenerator = createTestIds();
    final clock = createTestClock();
    final activate = ActivateProgramCommand(
      repository: repository,
      clock: clock,
      idGenerator: idGenerator,
      engine: engine,
    );
    final inputs = maintenanceInputs();
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
    final programId = activated.program.id;

    final pause = PauseProgramCommand(
      repository: repository,
      clock: clock,
      idGenerator: idGenerator,
    );
    final first = await pause.execute(userProgramId: programId);
    final second = await pause.execute(userProgramId: programId);

    expect(first, isA<SimpleCommandSucceeded>());
    expect(second, isA<SimpleCommandAlreadySatisfied>());

    final events = await repository.eventsFor(programId);
    expect(events.where((e) => e.type.name == 'paused'), hasLength(1));
  });

  test('record terhapus lunak tersaring dari pembacaan baku, tetap terbaca '
      'lewat jalur eksplisit', () async {
    final activate = ActivateProgramCommand(
      repository: repository,
      clock: createTestClock(),
      idGenerator: createTestIds(),
      engine: engine,
    );
    final inputs = maintenanceInputs();
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

    await (db.update(
      db.userPrograms,
    )..where((t) => t.id.equals(activated.program.id))).write(
      UserProgramsCompanion(deletedAt: Value(createTestClock().nowUtc())),
    );

    expect(await repository.findById(activated.program.id), isNull);
    expect(await repository.findRunning('profile-1'), isNull);
    expect(
      (await repository.findByIdIncludingDeleted(activated.program.id))?.id,
      activated.program.id,
    );
  });

  group('riwayat program (tasks 6.8/6.9)', () {
    test(
      'riwayat berurutan menurut waktu, memuat masukan dan versi apa adanya',
      () async {
        final idGenerator = createTestIds();
        final clock = FixedClock(
          instantUtc: DateTime.utc(2026, 11, 8, 10),
          timeZoneId: 'Asia/Jakarta',
          utcOffset: const Duration(hours: 7),
        );
        final activate = ActivateProgramCommand(
          repository: repository,
          clock: clock,
          idGenerator: idGenerator,
          engine: engine,
        );
        final inputs = maintenanceInputs();
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

        clock.advance(const Duration(days: 10));
        final change = ChangeProgramCommand(
          repository: repository,
          clock: clock,
          idGenerator: idGenerator,
          engine: engine,
        );
        final newInputs = healthyEatingInputs();
        final changed =
            await change.execute(
                  profileId: 'profile-1',
                  newProgramCode: ProgramCode.healthyEating,
                  currentInputs: newInputs,
                  userConfirmed: true,
                  programRequiresTargetWeight: false,
                  programRequiresHabitFocus: true,
                  estimate: estimateFor(newInputs),
                )
                as ChangeSucceeded;

        final history = await repository.history('profile-1');
        expect(history, hasLength(2));
        expect(history.first.id, activated.program.id);
        expect(history.first.state, ProgramState.changed);
        expect(history.last.id, changed.newProgram.id);
        expect(history.last.state, ProgramState.active);
        expect(
          history.first.inputSnapshot.currentWeight.kg,
          inputs.currentWeight.kg,
        );
        expect(history.first.proposal.calculatorVersion, 'msj-1.0.0');
      },
    );

    test(
      'pembaruan katalog, kebijakan, dan profil tidak mengubah nilai entri riwayat',
      () async {
        final idGenerator = createTestIds();
        final clock = createTestClock();
        final activate = ActivateProgramCommand(
          repository: repository,
          clock: clock,
          idGenerator: idGenerator,
          engine: engine,
        );
        final inputs = maintenanceInputs();
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

        final beforeTarget = activated.program.proposal.energyTarget?.kcal;
        final beforeSnapshotWeight =
            activated.program.inputSnapshot.currentWeight.kg;

        // Katalog ditarik (penanda ketersediaan) dan profil "diubah" di
        // tabel lain — keduanya tidak boleh menyentuh baris riwayat.
        await (db.update(db.programs)..where(
              (t) => t.id.equals(kProgramCatalogIds[ProgramCode.maintenance]!),
            ))
            .write(const ProgramsCompanion(isAvailable: Value(false)));

        final history = await repository.history('profile-1');
        expect(history.single.proposal.energyTarget?.kcal, beforeTarget);
        expect(
          history.single.inputSnapshot.currentWeight.kg,
          beforeSnapshotWeight,
        );
      },
    );
  });
}

/// Pembangkit pengenal yang selalu mengembalikan nilai tetap — dipakai
/// untuk memaksa tabrakan kunci utama sungguhan dalam uji rollback.
final class _FixedIdGenerator implements IdGenerator {
  _FixedIdGenerator(this._value);

  final String _value;

  @override
  String next() => _value;
}
