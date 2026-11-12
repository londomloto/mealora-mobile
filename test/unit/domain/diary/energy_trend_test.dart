import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/clock/fixed_clock.dart';
import 'package:mealora/domain/diary/energy_trend.dart';
import 'package:mealora/domain/nutrition/activity_level.dart';
import 'package:mealora/domain/nutrition/biological_input.dart';
import 'package:mealora/domain/program/pause_interval.dart';
import 'package:mealora/domain/program/program_code.dart';
import 'package:mealora/domain/program/program_proposal_inputs.dart';
import 'package:mealora/domain/program/program_state.dart';
import 'package:mealora/domain/program/program_target_proposal.dart';
import 'package:mealora/domain/program/user_program.dart';
import 'package:mealora/domain/shared/units.dart';

/// Tren energi dan target per tanggal (change 018, tasks 1.5/1.6).
void main() {
  final clock = FixedClock(
    instantUtc: DateTime.utc(2026, 11, 12, 3),
    timeZoneId: 'Asia/Jakarta',
    utcOffset: const Duration(hours: 7),
  );
  const today = LocalDate(2026, 11, 12);

  /// Tengah hari WIB pada [day] November 2026, sebagai instan UTC.
  DateTime nov(int day) => DateTime.utc(2026, 11, day, 5);

  UserProgram program({
    required String id,
    required double? kcal,
    required DateTime startedAt,
    DateTime? endedAt,
    ProgramState state = ProgramState.active,
    List<PauseInterval> pauses = const <PauseInterval>[],
  }) => UserProgram(
    id: id,
    profileId: 'p',
    programCode: ProgramCode.maintenance,
    state: state,
    proposal: ProgramTargetProposal(
      program: ProgramCode.maintenance,
      policyVersion: 'np-1.0.0',
      calculatorVersion: 'c',
      showsEnergyTarget: kcal != null,
      showsWeightProgressPercent: false,
      energyTarget: kcal == null
          ? null
          : Energy.kcalValue(kcal, field: 'e').valueOrNull,
    ),
    inputSnapshot: ProgramProposalInputs(
      ageYears: 29,
      biologicalInput: BiologicalInput.female,
      height: Length.cmValue(165, field: 'h').valueOrNull!,
      currentWeight: Mass.kgValue(68, field: 'w').valueOrNull!,
      activity: ActivityLevel.moderatelyActive,
    ),
    startedAt: startedAt,
    endedAt: endedAt,
    pauseIntervals: pauses,
  );

  EnergyTrend build(
    Map<String, DiaryDayEnergy> diary, {
    LocalDate from = const LocalDate(2026, 11, 6),
    LocalDate to = today,
    List<UserProgram> programs = const <UserProgram>[],
  }) => EnergyTrend.build(
    from: from,
    to: to,
    today: today,
    diary: diary,
    targets: EnergyTargetTimeline.fromPrograms(programs, clock: clock),
  );

  group('EnergyTrend.build', () {
    test('hari kosong bukan nol dan tidak dihitung ke rata-rata', () {
      final trend = build(<String, DiaryDayEnergy>{
        '2026-11-06': const DiaryDayEnergy.known(2000),
        '2026-11-08': const DiaryDayEnergy.known(1600),
      });

      expect(trend.days, hasLength(7));
      expect(trend.days[1].state, DailyEnergyState.notRecorded);
      expect(trend.days[1].kcal, isNull);
      expect(trend.recordedDays, 2);
      expect(trend.averageKcal, 1800);
    });

    test('energi tidak diketahui tidak dihitung ke rata-rata', () {
      final trend = build(<String, DiaryDayEnergy>{
        '2026-11-06': const DiaryDayEnergy.known(2000),
        '2026-11-07': const DiaryDayEnergy.unknown(),
      });

      expect(trend.days[1].state, DailyEnergyState.unknown);
      expect(trend.averageKcal, 2000);
      expect(trend.hasAnyRecord, isTrue);
    });

    test('hari sebagian tercatat tampil apa adanya dan ikut rata-rata', () {
      final trend = build(<String, DiaryDayEnergy>{
        '2026-11-12': const DiaryDayEnergy.known(400),
      });

      expect(trend.days.last.state, DailyEnergyState.recorded);
      expect(trend.days.last.kcal, 400);
      expect(trend.averageKcal, 400);
    });

    test('hari dengan catatan berenergi kosong tetap tergambar sebagai '
        'batas bawah dan tidak ikut rata-rata (change 021)', () {
      final trend = build(<String, DiaryDayEnergy>{
        '2026-11-06': const DiaryDayEnergy.known(2000),
        '2026-11-07': const DiaryDayEnergy.known(769, unknownCount: 1),
      });

      expect(trend.days[1].state, DailyEnergyState.recorded);
      expect(trend.days[1].kcal, 769);
      expect(trend.days[1].isPartial, isTrue);
      expect(trend.averageKcal, 2000);
      expect(trend.recordedDays, 1);
    });

    test('rentang kosong tidak punya rata-rata', () {
      final trend = build(const <String, DiaryDayEnergy>{});
      expect(trend.averageKcal, isNull);
      expect(trend.hasAnyRecord, isFalse);
    });

    test('tanggal setelah hari ini berstatus future', () {
      final trend = build(
        const <String, DiaryDayEnergy>{},
        from: const LocalDate(2026, 11, 9),
        to: const LocalDate(2026, 11, 15),
      );
      expect(
        trend.days.where((d) => d.state == DailyEnergyState.future),
        hasLength(3),
      );
    });

    test('rentang melintasi pergantian bulan', () {
      final trend = build(
        const <String, DiaryDayEnergy>{},
        from: const LocalDate(2026, 10, 30),
        to: const LocalDate(2026, 11, 2),
      );
      expect(trend.days.map((d) => d.date.iso), <String>[
        '2026-10-30',
        '2026-10-31',
        '2026-11-01',
        '2026-11-02',
      ]);
    });
  });

  group('EnergyTargetTimeline', () {
    test('target tetap memberi satu target dan tidak berubah', () {
      final trend = build(
        const <String, DiaryDayEnergy>{},
        programs: <UserProgram>[
          program(id: 'a', kcal: 2100, startedAt: nov(1)),
        ],
      );
      expect(trend.targetKcal, 2100);
      expect(trend.targetChanged, isFalse);
      expect(trend.days.every((d) => d.targetKcal == 2100), isTrue);
    });

    test('revisi target di tengah rentang', () {
      final trend = build(
        const <String, DiaryDayEnergy>{},
        programs: <UserProgram>[
          program(
            id: 'a',
            kcal: 2100,
            startedAt: nov(1),
            endedAt: nov(9),
            state: ProgramState.changed,
          ),
          program(id: 'b', kcal: 1900, startedAt: nov(9)),
        ],
      );
      final byDay = {for (final d in trend.days) d.date.day: d.targetKcal};
      expect(byDay[8], 2100);
      expect(byDay[9], 1900);
      expect(byDay[12], 1900);
      expect(trend.targetKcal, isNull);
      expect(trend.targetChanged, isTrue);
    });

    test('hari dijeda tidak punya target', () {
      final timeline = EnergyTargetTimeline.fromPrograms(<UserProgram>[
        program(
          id: 'a',
          kcal: 2100,
          startedAt: nov(1),
          state: ProgramState.paused,
          pauses: <PauseInterval>[
            PauseInterval(startedAt: nov(5), endedAt: nov(7)),
            PauseInterval(startedAt: nov(10)),
          ],
        ),
      ], clock: clock);

      expect(timeline.kcalOn(const LocalDate(2026, 11, 4)), 2100);
      expect(timeline.kcalOn(const LocalDate(2026, 11, 5)), isNull);
      expect(timeline.kcalOn(const LocalDate(2026, 11, 6)), isNull);
      expect(timeline.kcalOn(const LocalDate(2026, 11, 7)), 2100);
      expect(timeline.kcalOn(const LocalDate(2026, 11, 11)), isNull);
    });

    test('pergantian program dan tanggal sebelum program pertama', () {
      final timeline = EnergyTargetTimeline.fromPrograms(<UserProgram>[
        program(
          id: 'a',
          kcal: 2100,
          startedAt: nov(3),
          endedAt: nov(6),
          state: ProgramState.completed,
        ),
        program(id: 'b', kcal: null, startedAt: nov(8)),
      ], clock: clock);

      expect(timeline.kcalOn(const LocalDate(2026, 11, 2)), isNull);
      expect(timeline.kcalOn(const LocalDate(2026, 11, 6)), 2100);
      expect(timeline.kcalOn(const LocalDate(2026, 11, 7)), isNull);
      expect(timeline.kcalOn(const LocalDate(2026, 11, 9)), isNull);
    });
  });
}
