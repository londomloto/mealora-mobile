import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/core/clock/clock.dart';
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
import 'package:mealora/domain/program/commands/simple_lifecycle_commands.dart';
import 'package:mealora/domain/program/nutrition_policy.dart';
import 'package:mealora/domain/program/profile_screening_facts.dart';
import 'package:mealora/domain/program/program_code.dart';
import 'package:mealora/domain/program/program_engine.dart';
import 'package:mealora/domain/program/program_lifecycle.dart';
import 'package:mealora/domain/program/program_proposal_inputs.dart';
import 'package:mealora/domain/program/program_specific_input.dart';
import 'package:mealora/domain/shared/program_outcome.dart';
import 'package:mealora/domain/shared/units.dart';

import 'fakes/in_memory_program_repository.dart';

bool _finite(double v) => !v.isNaN && !v.isInfinite;

void main() {
  final policy = NutritionPolicy.np100(status: PolicyApprovalStatus.approved);
  final engine = ProgramEngine(policy);
  const calculator = NutritionCalculator(EnergyEquationPolicy.np100);
  final random = Random(42);

  group('uji properti — target tidak pernah melewati batas kebijakan', () {
    test(
      '1000 profil acak sah: energi dan makro selalu dalam batas, tanpa NaN/tak hingga',
      () {
        var sampleCount = 0;

        for (var i = 0; i < 1000; i++) {
          final program =
              ProgramCode.values[random.nextInt(ProgramCode.values.length)];
          final ageYears = 19 + random.nextInt(46); // 19-64
          final biological = random.nextBool()
              ? BiologicalInput.male
              : BiologicalInput.female;
          final heightCm = 145 + random.nextDouble() * 50; // 145-195
          final weightKg = 45 + random.nextDouble() * 70; // 45-115
          final activity =
              ActivityLevel.values[random.nextInt(ActivityLevel.values.length)];

          final bmi = weightKg / ((heightCm / 100) * (heightCm / 100));
          if (bmi < 18.6 || bmi >= 37.4) {
            continue; // hindari tepi kelayakan; itu sudah diuji di boundary test
          }

          final estimateOutcome = calculator.estimate(
            PhysiologicalFactsInput(
              ageYears: ageYears,
              biologicalInput: biological,
              heightCm: heightCm,
              weightKg: weightKg,
              activity: activity,
            ),
          );
          final estimate = switch (estimateOutcome) {
            Approved<NutritionEstimate>(:final value) => value,
            _ => throw StateError('masukan acak tidak valid: $estimateOutcome'),
          };

          Mass? targetWeight;
          if (program == ProgramCode.weightLoss) {
            targetWeight =
                (Mass.kgValue(weightKg * 0.9, field: 't') as Ok<Mass>).value;
          } else if (program == ProgramCode.weightGain) {
            targetWeight =
                (Mass.kgValue(weightKg * 1.1, field: 't') as Ok<Mass>).value;
          }

          final outcome = engine.proposeTarget(
            program: program,
            ageYears: ageYears,
            biologicalInput: biological,
            height: (Length.cmValue(heightCm, field: 'h') as Ok<Length>).value,
            currentWeight:
                (Mass.kgValue(weightKg, field: 'w') as Ok<Mass>).value,
            estimate: estimate,
            screening: const ProfileScreeningFacts(),
            specific: ProgramSpecificInput(
              targetWeight: targetWeight,
              habitFocus: program == ProgramCode.healthyEating
                  ? 'makan_sayur'
                  : null,
            ),
            asOfDate: const LocalDate(2026, 11, 8),
            programRequiresTargetWeight:
                program == ProgramCode.weightLoss ||
                program == ProgramCode.weightGain,
            programRequiresHabitFocus: program == ProgramCode.healthyEating,
          );

          switch (outcome) {
            case Approved(:final value):
              sampleCount++;
              expect(_finite(value.energyTarget?.kcal ?? 0), isTrue);

              if (value.showsEnergyTarget) {
                final energy = value.energyTarget!.kcal;
                expect(_finite(energy), isTrue);
                expect(energy, greaterThanOrEqualTo(800));

                final macros = value.macros!;
                expect(_finite(macros.proteinPercentEnergy), isTrue);
                expect(_finite(macros.fatPercentEnergy), isTrue);
                expect(_finite(macros.carbohydratePercentEnergy), isTrue);
                expect(macros.proteinGrams, greaterThanOrEqualTo(0));
                expect(macros.fatGrams, greaterThanOrEqualTo(0));
                expect(macros.carbohydrateGrams, greaterThanOrEqualTo(0));
                expect(macros.fiberGrams, inInclusiveRange(20, 38));

                if (program == ProgramCode.weightLoss) {
                  final remainingDeficit =
                      estimate.totalDailyEnergy.kcal - energy;
                  expect(remainingDeficit, greaterThanOrEqualTo(290));
                  expect(remainingDeficit, lessThanOrEqualTo(760));
                }
                if (program == ProgramCode.weightGain) {
                  final surplus = energy - estimate.totalDailyEnergy.kcal;
                  expect(surplus, greaterThanOrEqualTo(245));
                  expect(surplus, lessThanOrEqualTo(505));
                }
              }
            case NeedsUserCorrection() ||
                NeedsProfessionalReview() ||
                UnsupportedProfile() ||
                MissingValidatedPolicy():
              // Hasil tidak-disetujui tidak membawa angka — tidak ada yang
              // perlu diperiksa batasnya.
              break;
          }
        }

        // Pastikan sampel acak ini benar-benar menguji jalur approved, bukan
        // seluruhnya tersaring oleh kelayakan.
        expect(sampleCount, greaterThan(100));
      },
    );
  });

  group('uji properti — invarian satu program berjalan', () {
    test(
      '50 urutan perintah siklus hidup acak tidak pernah menghasilkan dua program berjalan',
      () async {
        final sequenceRandom = Random(7);

        for (var sequence = 0; sequence < 50; sequence++) {
          final repository = InMemoryProgramRepository();
          final idGenerator = SequentialIdGenerator(prefix: 'seq$sequence');
          final clock = FixedClock(
            instantUtc: DateTime.utc(2026, 11, 8),
            timeZoneId: 'Asia/Jakarta',
            utcOffset: const Duration(hours: 7),
          );
          final activate = ActivateProgramCommand(
            repository: repository,
            clock: clock,
            idGenerator: idGenerator,
            engine: engine,
          );
          final pause = PauseProgramCommand(
            repository: repository,
            clock: clock,
            idGenerator: idGenerator,
          );
          final resume = ResumeProgramCommand(
            repository: repository,
            clock: clock,
            idGenerator: idGenerator,
          );
          final complete = CompleteProgramCommand(
            repository: repository,
            clock: clock,
            idGenerator: idGenerator,
          );
          final cancel = CancelProgramCommand(
            repository: repository,
            clock: clock,
            idGenerator: idGenerator,
          );

          final inputs = ProgramProposalInputs(
            ageYears: 29,
            biologicalInput: BiologicalInput.female,
            height: (Length.cmValue(165, field: 'h') as Ok<Length>).value,
            currentWeight: (Mass.kgValue(68.4, field: 'w') as Ok<Mass>).value,
            activity: ActivityLevel.moderatelyActive,
          );
          String? lastProgramId;

          for (var step = 0; step < 30; step++) {
            final action = sequenceRandom.nextInt(5);
            switch (action) {
              case 0:
                final result = await activate.execute(
                  profileId: 'profile-1',
                  program: ProgramCode.maintenance,
                  previewInputs: inputs,
                  currentInputs: inputs,
                  userConfirmed: true,
                  programRequiresTargetWeight: false,
                  programRequiresHabitFocus: false,
                );
                if (result is ActivationSucceeded) {
                  lastProgramId = result.program.id;
                }
              case 1:
                if (lastProgramId != null) {
                  await pause.execute(userProgramId: lastProgramId);
                }
              case 2:
                if (lastProgramId != null) {
                  await resume.execute(userProgramId: lastProgramId);
                }
              case 3:
                if (lastProgramId != null) {
                  await complete.execute(
                    userProgramId: lastProgramId,
                    reasonCode: 'test',
                  );
                }
              case 4:
                if (lastProgramId != null) {
                  await cancel.execute(userProgramId: lastProgramId);
                }
            }

            final states = repository.allPrograms.map((p) => p.state);
            expect(
              ProgramLifecycle.satisfiesSingleRunningInvariant(states),
              isTrue,
              reason:
                  'urutan $sequence langkah $step: ${repository.allPrograms.map((p) => p.state)}',
            );
          }
        }
      },
    );
  });
}
