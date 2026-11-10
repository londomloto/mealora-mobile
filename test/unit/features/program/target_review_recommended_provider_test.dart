import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/clock/fixed_clock.dart';
import 'package:mealora/core/errors/result.dart';
import 'package:mealora/core/ids/sequential_id_generator.dart';
import 'package:mealora/domain/nutrition/activity_level.dart';
import 'package:mealora/domain/nutrition/biological_input.dart';
import 'package:mealora/domain/program/commands/activate_program_command.dart';
import 'package:mealora/domain/program/commands/activation_result.dart';
import 'package:mealora/domain/program/nutrition_policy.dart';
import 'package:mealora/domain/program/program_code.dart';
import 'package:mealora/domain/program/program_engine.dart';
import 'package:mealora/domain/program/program_proposal_inputs.dart';
import 'package:mealora/domain/program/program_specific_input.dart';
import 'package:mealora/domain/shared/units.dart';
import 'package:mealora/domain/weight/weight_record.dart';
import 'package:mealora/domain/weight/weight_repository.dart';
import 'package:mealora/features/onboarding/onboarding_controller.dart'
    show nutritionPolicyProvider, programRepositoryProvider;
import 'package:mealora/features/program/program_providers.dart';
import 'package:mealora/features/weight/weight_controller.dart';

import '../../domain/program/fakes/in_memory_program_repository.dart';

/// `targetReviewRecommendedProvider` (change 008, task 3.6): usulan
/// peninjauan target muncul hanya ketika program bertarget berat, ambang
/// `np-1.0.0` terlewati, dan kebijakan sudah disetujui.
void main() {
  const profileId = 'profile-1';
  final clock = FixedClock(
    instantUtc: DateTime.utc(2026, 11, 8),
    timeZoneId: 'Asia/Jakarta',
    utcOffset: const Duration(hours: 7),
  );

  Future<String> activateWeightLossProgram(
    InMemoryProgramRepository repository, {
    required double startingWeightKg,
  }) async {
    final engine = ProgramEngine(
      NutritionPolicy.np100(status: PolicyApprovalStatus.approved),
    );
    final inputs = ProgramProposalInputs(
      ageYears: 29,
      biologicalInput: BiologicalInput.female,
      height: Length.cmValue(165, field: 'h').valueOrNull!,
      currentWeight: Mass.kgValue(startingWeightKg, field: 'w').valueOrNull!,
      activity: ActivityLevel.moderatelyActive,
      specific: ProgramSpecificInput(
        targetWeight: Mass.kgValue(
          startingWeightKg - 10,
          field: 'target',
        ).valueOrNull,
      ),
    );
    final command = ActivateProgramCommand(
      repository: repository,
      clock: clock,
      idGenerator: SequentialIdGenerator(),
      engine: engine,
    );
    final result = await command.execute(
      profileId: profileId,
      program: ProgramCode.weightLoss,
      previewInputs: inputs,
      currentInputs: inputs,
      userConfirmed: true,
      programRequiresTargetWeight: true,
      programRequiresHabitFocus: false,
    );
    expect(result, isA<ActivationSucceeded>());
    final program = await repository.findRunning(profileId);
    return program!.id;
  }

  ProviderContainer buildContainer({
    required InMemoryProgramRepository programRepository,
    required WeightRepository weightRepository,
    PolicyApprovalStatus policyStatus = PolicyApprovalStatus.approved,
  }) {
    final container = ProviderContainer(
      overrides: <Override>[
        programRepositoryProvider.overrideWithValue(programRepository),
        weightRepositoryProvider.overrideWithValue(weightRepository),
        nutritionPolicyProvider.overrideWithValue(
          NutritionPolicy.np100(status: policyStatus),
        ),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('false ketika belum ada catatan berat', () async {
    final programRepository = InMemoryProgramRepository();
    final userProgramId = await activateWeightLossProgram(
      programRepository,
      startingWeightKg: 70,
    );
    final container = buildContainer(
      programRepository: programRepository,
      weightRepository: _FakeWeightRepository(latestWeightKg: null),
    );

    final recommended = await container.read(
      targetReviewRecommendedProvider(userProgramId).future,
    );
    expect(recommended, isFalse);
  });

  test('false ketika perubahan berat di bawah ambang 5%', () async {
    final programRepository = InMemoryProgramRepository();
    final userProgramId = await activateWeightLossProgram(
      programRepository,
      startingWeightKg: 70,
    );
    final container = buildContainer(
      programRepository: programRepository,
      weightRepository: _FakeWeightRepository(latestWeightKg: 68),
    );

    final recommended = await container.read(
      targetReviewRecommendedProvider(userProgramId).future,
    );
    expect(recommended, isFalse);
  });

  test('true ketika perubahan berat melewati ambang 5%', () async {
    final programRepository = InMemoryProgramRepository();
    final userProgramId = await activateWeightLossProgram(
      programRepository,
      startingWeightKg: 70,
    );
    final container = buildContainer(
      programRepository: programRepository,
      weightRepository: _FakeWeightRepository(latestWeightKg: 66),
    );

    final recommended = await container.read(
      targetReviewRecommendedProvider(userProgramId).future,
    );
    expect(recommended, isTrue);
  });

  test(
    'false ketika kebijakan belum disetujui, walau ambang terlewati',
    () async {
      final programRepository = InMemoryProgramRepository();
      final userProgramId = await activateWeightLossProgram(
        programRepository,
        startingWeightKg: 70,
      );
      final container = buildContainer(
        programRepository: programRepository,
        weightRepository: _FakeWeightRepository(latestWeightKg: 66),
        policyStatus: PolicyApprovalStatus.draft,
      );

      final recommended = await container.read(
        targetReviewRecommendedProvider(userProgramId).future,
      );
      expect(recommended, isFalse);
    },
  );

  test('false untuk program Makan Sehat walau ambang terlewati', () async {
    final programRepository = InMemoryProgramRepository();
    final engine = ProgramEngine(
      NutritionPolicy.np100(status: PolicyApprovalStatus.approved),
    );
    final inputs = ProgramProposalInputs(
      ageYears: 29,
      biologicalInput: BiologicalInput.female,
      height: Length.cmValue(165, field: 'h').valueOrNull!,
      currentWeight: Mass.kgValue(70, field: 'w').valueOrNull!,
      activity: ActivityLevel.moderatelyActive,
      specific: const ProgramSpecificInput(habitFocus: 'makan_sayur'),
    );
    final command = ActivateProgramCommand(
      repository: programRepository,
      clock: clock,
      idGenerator: SequentialIdGenerator(),
      engine: engine,
    );
    final result = await command.execute(
      profileId: profileId,
      program: ProgramCode.healthyEating,
      previewInputs: inputs,
      currentInputs: inputs,
      userConfirmed: true,
      programRequiresTargetWeight: false,
      programRequiresHabitFocus: true,
    );
    expect(result, isA<ActivationSucceeded>());
    final userProgramId = (await programRepository.findRunning(profileId))!.id;

    final container = buildContainer(
      programRepository: programRepository,
      weightRepository: _FakeWeightRepository(latestWeightKg: 66),
    );

    final recommended = await container.read(
      targetReviewRecommendedProvider(userProgramId).future,
    );
    expect(recommended, isFalse);
  });
}

class _FakeWeightRepository implements WeightRepository {
  _FakeWeightRepository({required this.latestWeightKg});

  final double? latestWeightKg;

  @override
  Future<WeightRecord?> latest(String profileId) async {
    if (latestWeightKg == null) {
      return null;
    }
    return WeightRecord(
      id: 'fake-weight',
      profileId: profileId,
      localDate: const LocalDate(2026, 11, 8),
      recordedAt: DateTime.utc(2026, 11, 8),
      weightKg: latestWeightKg!,
      createdAt: DateTime.utc(2026, 11, 8),
    );
  }

  @override
  Future<List<WeightRecord>> recordsInRange(
    String profileId, {
    required LocalDate from,
    required LocalDate to,
  }) async => <WeightRecord>[];

  @override
  Future<Result<WeightRecord>> addRecord({
    required String profileId,
    required LocalDate date,
    required double weightKg,
    String? note,
  }) => throw UnimplementedError();

  @override
  Future<Result<WeightRecord>> updateRecord({
    required String recordId,
    required LocalDate date,
    required double weightKg,
    String? note,
  }) => throw UnimplementedError();

  @override
  Future<void> deleteRecord(String recordId) => throw UnimplementedError();
}
