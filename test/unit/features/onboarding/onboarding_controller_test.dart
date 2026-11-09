import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/clock/fixed_clock.dart';
import 'package:mealora/core/ids/sequential_id_generator.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/domain/nutrition/activity_level.dart';
import 'package:mealora/domain/nutrition/biological_input.dart';
import 'package:mealora/domain/program/commands/activation_result.dart';
import 'package:mealora/domain/program/program_code.dart';
import 'package:mealora/domain/program/program_target_proposal.dart';
import 'package:mealora/domain/shared/program_outcome.dart';
import 'package:mealora/domain/shared/reason_code.dart';
import 'package:mealora/domain/shared/units.dart';
import 'package:mealora/features/onboarding/onboarding_controller.dart';
import 'package:mealora/features/onboarding/onboarding_step.dart';

import '../../domain/profile/fakes/in_memory_profile_repository.dart';
import '../../domain/program/fakes/in_memory_program_repository.dart';

/// Wadah state onboarding (Design D9, tasks 3.1–3.5): penyimpanan bertahap,
/// penanda kelengkapan, navigasi maju-mundur, dan kelanjutan sesi.
void main() {
  const today = LocalDate(2026, 11, 9);

  Clock testClock() => FixedClock(
    instantUtc: DateTime.utc(2026, 11, 9, 2, 30),
    timeZoneId: 'Asia/Jakarta',
    utcOffset: const Duration(hours: 7),
  );

  ProviderContainer buildContainer({
    InMemoryProfileRepository? repository,
    InMemoryProgramRepository? programRepository,
  }) {
    final container = ProviderContainer(
      overrides: <Override>[
        profileRepositoryProvider.overrideWithValue(
          repository ?? InMemoryProfileRepository(),
        ),
        programRepositoryProvider.overrideWithValue(
          programRepository ?? InMemoryProgramRepository(),
        ),
        idGeneratorProvider.overrideWithValue(SequentialIdGenerator()),
        clockProvider.overrideWithValue(testClock()),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  test('profil baru dimulai dari langkah sambutan tanpa profileId', () async {
    final container = buildContainer();
    final draft = await container.read(onboardingControllerProvider.future);

    expect(draft.currentStep, OnboardingStep.welcome);
    expect(draft.profileId, isNull);
    expect(draft.missingProfileFields, isNotEmpty);
  });

  test('menyimpan langkah profil awal yang sah berpindah ke langkah aktivitas '
      'dan tersimpan ke repositori (task 3.2)', () async {
    final repository = InMemoryProfileRepository();
    final container = buildContainer(repository: repository);
    await container.read(onboardingControllerProvider.future);

    final result = await container
        .read(onboardingControllerProvider.notifier)
        .saveProfileBasics(
          nickname: 'Budi',
          birthDate: const LocalDate(1997, 5, 20),
          heightCm: 165,
          currentWeightKg: 68.4,
          biologicalInput: BiologicalInput.male,
          today: today,
        );

    expect(result.isOk, isTrue);
    expect(repository.upsertCallCount, 1);

    final draft = container.read(onboardingControllerProvider).valueOrNull;
    expect(draft!.currentStep, OnboardingStep.activity);
    expect(draft.profileId, isNotNull);
    expect(draft.nickname, 'Budi');

    final stored = await repository.current();
    expect(stored!.isOnboardingComplete, isFalse);
    expect(stored.missingRequiredFields, <String>['activityLevel']);
  });

  test('menolak tinggi badan tidak masuk akal dan tidak menyimpan apa pun '
      '(scenario 6.3, FRS 2.3.5)', () async {
    final repository = InMemoryProfileRepository();
    final container = buildContainer(repository: repository);
    await container.read(onboardingControllerProvider.future);

    final result = await container
        .read(onboardingControllerProvider.notifier)
        .saveProfileBasics(
          nickname: '',
          birthDate: const LocalDate(1997, 5, 20),
          heightCm: 15,
          currentWeightKg: 68.4,
          biologicalInput: BiologicalInput.male,
          today: today,
        );

    expect(result.isErr, isTrue);
    expect(result.failureOrNull?.field, 'height');
    expect(repository.upsertCallCount, 0);

    final draft = container.read(onboardingControllerProvider).valueOrNull;
    expect(draft!.currentStep, OnboardingStep.welcome);
    expect(draft.profileId, isNull);
  });

  test(
    'nama panggilan boleh dikosongkan dan tetap melanjutkan (scenario 6.2)',
    () async {
      final container = buildContainer();
      await container.read(onboardingControllerProvider.future);

      final result = await container
          .read(onboardingControllerProvider.notifier)
          .saveProfileBasics(
            nickname: '   ',
            birthDate: const LocalDate(1997, 5, 20),
            heightCm: 165,
            currentWeightKg: 68.4,
            biologicalInput: BiologicalInput.female,
            today: today,
          );

      expect(result.isOk, isTrue);
      final draft = container.read(onboardingControllerProvider).valueOrNull;
      expect(draft!.nickname, isNull);
    },
  );

  test('menyimpan tingkat aktivitas melengkapi profil dan menyelesaikan '
      'onboarding (Design D2)', () async {
    final repository = InMemoryProfileRepository();
    final container = buildContainer(repository: repository);
    await container.read(onboardingControllerProvider.future);
    final notifier = container.read(onboardingControllerProvider.notifier);

    await notifier.saveProfileBasics(
      nickname: 'Budi',
      birthDate: const LocalDate(1997, 5, 20),
      heightCm: 165,
      currentWeightKg: 68.4,
      biologicalInput: BiologicalInput.male,
      today: today,
    );
    await notifier.saveActivityLevel(ActivityLevel.moderatelyActive);

    final draft = container.read(onboardingControllerProvider).valueOrNull;
    expect(draft!.currentStep, OnboardingStep.programSelect);
    expect(draft.missingProfileFields, isEmpty);

    final stored = await repository.current();
    expect(stored!.isOnboardingComplete, isTrue);
  });

  test('berpindah mundur ke langkah profil tidak menghilangkan isian yang '
      'sudah disimpan (task 3.4, scenario 6.4)', () async {
    final container = buildContainer();
    await container.read(onboardingControllerProvider.future);
    final notifier = container.read(onboardingControllerProvider.notifier);

    await notifier.saveProfileBasics(
      nickname: 'Budi',
      birthDate: const LocalDate(1997, 5, 20),
      heightCm: 165,
      currentWeightKg: 68.4,
      biologicalInput: BiologicalInput.male,
      today: today,
    );
    await notifier.saveActivityLevel(ActivityLevel.moderatelyActive);

    notifier.goToStep(OnboardingStep.profileBasics);

    final draft = container.read(onboardingControllerProvider).valueOrNull;
    expect(draft!.currentStep, OnboardingStep.profileBasics);
    expect(draft.nickname, 'Budi');
    expect(draft.height?.cm, 165);
    expect(draft.activityLevel, ActivityLevel.moderatelyActive);
  });

  test('menutup dan membuka ulang melanjutkan dari langkah yang benar dengan '
      'isian utuh (task 3.5, scenario 6.5)', () async {
    final repository = InMemoryProfileRepository();
    final firstContainer = buildContainer(repository: repository);
    await firstContainer.read(onboardingControllerProvider.future);
    await firstContainer
        .read(onboardingControllerProvider.notifier)
        .saveProfileBasics(
          nickname: 'Budi',
          birthDate: const LocalDate(1997, 5, 20),
          heightCm: 165,
          currentWeightKg: 68.4,
          biologicalInput: BiologicalInput.male,
          today: today,
        );
    firstContainer.dispose();

    final secondContainer = buildContainer(repository: repository);
    final resumed = await secondContainer.read(
      onboardingControllerProvider.future,
    );

    expect(resumed.currentStep, OnboardingStep.activity);
    expect(resumed.nickname, 'Budi');
    expect(resumed.height?.cm, 165);
    expect(resumed.currentWeight?.kg, 68.4);
  });

  group('pemilihan program dan masukan khusus program', () {
    test('memilih Turun Berat menandai pilihan tanpa berpindah langkah dan '
        'tidak tersimpan ke repositori (Design D3)', () async {
      final repository = InMemoryProfileRepository();
      final container = buildContainer(repository: repository);
      await container.read(onboardingControllerProvider.future);
      final notifier = container.read(onboardingControllerProvider.notifier);
      final stepBefore = container
          .read(onboardingControllerProvider)
          .valueOrNull!
          .currentStep;

      notifier.selectProgram(ProgramCode.weightLoss);

      final draft = container.read(onboardingControllerProvider).valueOrNull;
      expect(draft!.currentStep, stepBefore);
      expect(draft.selectedProgram, ProgramCode.weightLoss);
      expect(draft.requiresTargetWeight, isTrue);
      expect(repository.upsertCallCount, 0);
    });

    test('Makan Sehat tidak pernah membutuhkan berat tujuan (task 4.10, '
        'scenario 6.6)', () async {
      final container = buildContainer();
      await container.read(onboardingControllerProvider.future);
      final notifier = container.read(onboardingControllerProvider.notifier);

      notifier.selectProgram(ProgramCode.healthyEating);
      expect(
        container
            .read(onboardingControllerProvider)
            .valueOrNull!
            .requiresTargetWeight,
        isFalse,
      );
      notifier.setEstimateAcknowledged(true);

      final advanced = notifier.continueFromProgramDetail();
      expect(advanced, isTrue);
      expect(
        container.read(onboardingControllerProvider).valueOrNull!.currentStep,
        OnboardingStep.review,
      );
    });

    test(
      'berganti program mengosongkan masukan khusus program sebelumnya',
      () async {
        final container = buildContainer();
        await container.read(onboardingControllerProvider.future);
        final notifier = container.read(onboardingControllerProvider.notifier);

        notifier.selectProgram(ProgramCode.weightLoss);
        notifier.saveTargetWeightDetails(targetWeightKg: 62);
        notifier.selectProgram(ProgramCode.healthyEating);

        final draft = container.read(onboardingControllerProvider).valueOrNull;
        expect(draft!.targetWeight, isNull);
        expect(draft.estimateAcknowledged, isFalse);
      },
    );

    test(
      'Turun Berat berpindah ke langkah target berat setelah detail program',
      () async {
        final container = buildContainer();
        await container.read(onboardingControllerProvider.future);
        final notifier = container.read(onboardingControllerProvider.notifier);

        notifier.selectProgram(ProgramCode.weightLoss);
        notifier.setEstimateAcknowledged(true);
        notifier.continueFromProgramDetail();

        expect(
          container.read(onboardingControllerProvider).valueOrNull!.currentStep,
          OnboardingStep.targetWeight,
        );
      },
    );

    test('menahan langkah bila pengakuan perkiraan belum diberikan (task 4.8, '
        'scenario 6.7)', () async {
      final container = buildContainer();
      await container.read(onboardingControllerProvider.future);
      final notifier = container.read(onboardingControllerProvider.notifier);

      notifier.selectProgram(ProgramCode.healthyEating);
      final advanced = notifier.continueFromProgramDetail();

      expect(advanced, isFalse);
      expect(
        container.read(onboardingControllerProvider).valueOrNull!.currentStep,
        isNot(OnboardingStep.review),
      );
    });

    test(
      'menolak berat tujuan tidak masuk akal dan tidak berpindah langkah',
      () async {
        final container = buildContainer();
        await container.read(onboardingControllerProvider.future);
        final notifier = container.read(onboardingControllerProvider.notifier);
        notifier.selectProgram(ProgramCode.weightLoss);
        notifier.goToStep(OnboardingStep.targetWeight);

        final result = notifier.saveTargetWeightDetails(targetWeightKg: 5);

        expect(result.isErr, isTrue);
        expect(result.failureOrNull?.field, 'targetWeight');
        expect(
          container.read(onboardingControllerProvider).valueOrNull!.currentStep,
          OnboardingStep.targetWeight,
        );
      },
    );

    test(
      'tanggal tujuan opsional — berat tujuan saja tetap diterima (FRS 3.3.5)',
      () async {
        final container = buildContainer();
        await container.read(onboardingControllerProvider.future);
        final notifier = container.read(onboardingControllerProvider.notifier);
        notifier.selectProgram(ProgramCode.weightLoss);

        final result = notifier.saveTargetWeightDetails(targetWeightKg: 62);

        expect(result.isOk, isTrue);
        final draft = container.read(onboardingControllerProvider).valueOrNull;
        expect(draft!.targetWeight?.kg, 62);
        expect(draft.targetDate, isNull);
        expect(draft.currentStep, OnboardingStep.review);
      },
    );
  });

  group('pratinjau dan aktivasi (task 5.1–5.3, Tahap 3)', () {
    Future<OnboardingController> reachReviewForHealthyEating(
      ProviderContainer container,
    ) async {
      await container.read(onboardingControllerProvider.future);
      final notifier = container.read(onboardingControllerProvider.notifier);
      await notifier.saveProfileBasics(
        nickname: 'Budi',
        birthDate: const LocalDate(1997, 5, 20),
        heightCm: 165,
        currentWeightKg: 68.4,
        biologicalInput: BiologicalInput.male,
        today: today,
      );
      await notifier.saveActivityLevel(ActivityLevel.moderatelyActive);
      notifier.selectProgram(ProgramCode.healthyEating);
      notifier.saveHabitFocus('consistent_logging');
      notifier.setEstimateAcknowledged(true);
      notifier.continueFromProgramDetail();
      return notifier;
    }

    test('pratinjau murni perhitungan: tidak menulis apa pun ke repositori '
        'program (Design D3, task 5.2)', () async {
      final programRepository = InMemoryProgramRepository();
      final container = buildContainer(programRepository: programRepository);
      final notifier = await reachReviewForHealthyEating(container);

      await notifier.prepareReview();

      final draft = container.read(onboardingControllerProvider).valueOrNull;
      expect(draft!.previewInputs, isNotNull);
      expect(draft.lastOutcome, isA<Approved<ProgramTargetProposal>>());
      expect(programRepository.allPrograms, isEmpty);
    });

    test('menyetujui pratinjau mengaktifkan program dan menaikkan penanda '
        'refresh onboarding (task 5.3/5.5)', () async {
      final container = buildContainer();
      final notifier = await reachReviewForHealthyEating(container);
      await notifier.prepareReview();

      final before = container.read(onboardingRefreshSignalProvider);
      final result = await notifier.approve();

      expect(result, isA<ActivationSucceeded>());
      expect(
        container.read(onboardingRefreshSignalProvider),
        greaterThan(before),
      );
    });

    test(
      'menutup pratinjau tanpa menyetujui tidak mengaktifkan program apa pun '
      '(scenario 6.8)',
      () async {
        final programRepository = InMemoryProgramRepository();
        final container = buildContainer(programRepository: programRepository);
        final notifier = await reachReviewForHealthyEating(container);
        await notifier.prepareReview();

        expect(programRepository.allPrograms, isEmpty);
      },
    );

    test('berat badan berubah sejak pratinjau membatalkan aktivasi dan '
        'membekukan ulang pratinjau dengan nilai terbaru (scenario 6.9, '
        'FRS 4.3.5/4.3.6)', () async {
      final repository = InMemoryProfileRepository();
      final container = buildContainer(repository: repository);
      final notifier = await reachReviewForHealthyEating(container);
      await notifier.prepareReview();

      final before = container.read(onboardingControllerProvider).valueOrNull!;
      final staleCurrentWeight = before.previewInputs!.currentWeight.kg;

      // Berat badan diperbarui "di latar" — lewat repositori langsung,
      // bukan lewat layar (belum ada layar ubah profil di change ini).
      final profile = await repository.current();
      await repository.upsert(
        profile!.copyWith(
          currentWeight: Mass.kgValue(71, field: 'w').valueOrNull,
        ),
      );

      final result = await notifier.approve();

      expect(result, isA<ActivationInputsChangedSincePreview>());
      final after = container.read(onboardingControllerProvider).valueOrNull!;
      expect(after.previewInputs!.currentWeight.kg, 71);
      expect(after.previewInputs!.currentWeight.kg, isNot(staleCurrentWeight));
    });

    test('profil di luar cakupan kebijakan menghasilkan lastOutcome bukan '
        'Approved, tanpa angka target (scenario 6.11)', () async {
      final container = buildContainer();
      await container.read(onboardingControllerProvider.future);
      final notifier = container.read(onboardingControllerProvider.notifier);
      await notifier.saveProfileBasics(
        nickname: '',
        birthDate: const LocalDate(2009, 5, 20), // 17 tahun pada `today`
        heightCm: 165,
        currentWeightKg: 55,
        biologicalInput: BiologicalInput.female,
        today: today,
      );
      await notifier.saveActivityLevel(ActivityLevel.moderatelyActive);
      notifier.selectProgram(ProgramCode.weightLoss);
      notifier.setEstimateAcknowledged(true);
      notifier.continueFromProgramDetail();
      notifier.saveTargetWeightDetails(targetWeightKg: 50);

      await notifier.prepareReview();

      final draft = container.read(onboardingControllerProvider).valueOrNull;
      expect(draft!.lastOutcome, isNot(isA<Approved<ProgramTargetProposal>>()));
      final outcome =
          draft.lastOutcome as UnsupportedProfile<ProgramTargetProposal>;
      expect(outcome.reasonCode, ReasonCode.ageBelowMinimum);
    });
  });
}
