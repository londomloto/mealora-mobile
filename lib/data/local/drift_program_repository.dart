import 'package:drift/drift.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/ids/id_generator.dart';
import 'package:mealora/data/local/program_json_codec.dart';
import 'package:mealora/data/local/program_progress_snapshot.dart';
import 'package:mealora/data/local/user_record_support.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/database/seeds/program_catalog_seed.dart';
import 'package:mealora/database/tables/program_events_table.dart';
import 'package:mealora/database/tables/program_progress_table.dart';
import 'package:mealora/database/tables/programs_table.dart';
import 'package:mealora/database/tables/user_programs_table.dart';
import 'package:mealora/domain/program/pause_interval.dart';
import 'package:mealora/domain/program/program_code.dart';
import 'package:mealora/domain/program/program_event.dart';
import 'package:mealora/domain/program/program_repository.dart';
import 'package:mealora/domain/program/program_state.dart';
import 'package:mealora/domain/program/program_target_proposal.dart';
import 'package:mealora/domain/program/user_program.dart';
import 'package:mealora/domain/shared/units.dart';

part 'drift_program_repository.g.dart';

/// Implementasi `ProgramRepository` (change 003) memakai DAO Drift (change
/// 004, task 3.1) — Drift tidak pernah bocor ke lapisan domain (Design D9).
///
/// Jeda ([UserProgram.pauseIntervals]) tidak tersimpan sebagai kolom;
/// dipulihkan dari pasangan peristiwa `paused`/`resumed` di `program_events`
/// setiap kali baris dibaca (Design D9 catatan implementasi).
@DriftAccessor(
  tables: <Type>[UserPrograms, ProgramEvents, ProgramProgress, Programs],
)
class DriftProgramRepository extends DatabaseAccessor<AppDatabase>
    with _$DriftProgramRepositoryMixin
    implements ProgramRepository {
  DriftProgramRepository(
    super.db, {
    required Clock clock,
    required IdGenerator ids,
  }) : _clock = clock,
       _ids = ids;

  final Clock _clock;
  final IdGenerator _ids;

  @override
  Future<UserProgram?> findRunning(String profileId) async {
    final row =
        await (select(userPrograms)..where(
              (t) =>
                  t.profileId.equals(profileId) &
                  t.status.isIn(<String>['active', 'paused']) &
                  UserRecords.active(t.deletedAt),
            ))
            .getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _toDomain(row, await _eventRowsFor(row.id));
  }

  @override
  Future<UserProgram?> findById(String id) async {
    final row =
        await (select(userPrograms)
              ..where((t) => t.id.equals(id) & UserRecords.active(t.deletedAt)))
            .getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _toDomain(row, await _eventRowsFor(id));
  }

  /// Jalur eksplisit untuk membaca program pengguna yang sudah ditandai
  /// terhapus — pembacaan baku ([findById], [findRunning]) selalu
  /// menyaringnya (task 3.2, konvensi change 001).
  Future<UserProgram?> findByIdIncludingDeleted(String id) async {
    final row = await (select(
      userPrograms,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
    if (row == null) {
      return null;
    }
    return _toDomain(row, await _eventRowsFor(id));
  }

  @override
  Future<List<ProgramEvent>> eventsFor(String userProgramId) async {
    final rows = await _eventRowsFor(userProgramId);
    return rows.map(_eventToDomain).toList(growable: false);
  }

  @override
  Future<List<UserProgram>> history(String profileId) async {
    final rows =
        await (select(userPrograms)
              ..where(
                (t) =>
                    t.profileId.equals(profileId) &
                    UserRecords.active(t.deletedAt),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.startedAt)]))
            .get();
    return Future.wait(
      rows.map((row) async => _toDomain(row, await _eventRowsFor(row.id))),
    );
  }

  @override
  Future<void> upsert(UserProgram program) async {
    final existing = await (select(
      userPrograms,
    )..where((t) => t.id.equals(program.id))).getSingleOrNull();
    final now = _clock.nowUtc();

    if (existing == null) {
      await into(
        userPrograms,
      ).insert(_toCompanion(program, createdAt: now, updatedAt: now));
      return;
    }
    await (update(userPrograms)..where((t) => t.id.equals(program.id))).write(
      _toCompanion(program, createdAt: existing.createdAt, updatedAt: now),
    );
  }

  @override
  Future<void> appendEvent(ProgramEvent event) async {
    await into(programEvents).insert(_eventToCompanion(event, _clock.nowUtc()));
  }

  @override
  Future<void> applyActivation({
    required UserProgram newProgram,
    required ProgramEvent event,
  }) async {
    final now = _clock.nowUtc();
    await transaction(() async {
      await into(
        userPrograms,
      ).insert(_toCompanion(newProgram, createdAt: now, updatedAt: now));
      await into(programEvents).insert(_eventToCompanion(event, now));
      await _insertInitialProgressSnapshot(newProgram, now);
    });
  }

  @override
  Future<void> applyProgramChange({
    required UserProgram supersededProgram,
    required UserProgram newProgram,
    required List<ProgramEvent> events,
  }) async {
    final now = _clock.nowUtc();
    await transaction(() async {
      final existing = await (select(
        userPrograms,
      )..where((t) => t.id.equals(supersededProgram.id))).getSingle();
      await (update(
        userPrograms,
      )..where((t) => t.id.equals(supersededProgram.id))).write(
        _toCompanion(
          supersededProgram,
          createdAt: existing.createdAt,
          updatedAt: now,
        ),
      );
      await into(
        userPrograms,
      ).insert(_toCompanion(newProgram, createdAt: now, updatedAt: now));
      for (final event in events) {
        await into(programEvents).insert(_eventToCompanion(event, now));
      }
      await _insertInitialProgressSnapshot(newProgram, now);
    });
  }

  /// Membangun ulang potret kemajuan untuk satu [userProgramId] dan
  /// [localDate] sebagai penyisipan-atau-perbarui (task 6.1, Design D5) —
  /// idempoten: memanggilnya berkali-kali untuk tanggal yang sama tidak
  /// pernah menggandakan baris, dan selalu mencerminkan [input] terbaru.
  Future<void> rebuildProgressForDate({
    required String userProgramId,
    required LocalDate localDate,
    required ProgramProgressInput input,
  }) async {
    final existing =
        await (select(programProgress)..where(
              (t) =>
                  t.userProgramId.equals(userProgramId) &
                  t.recordedLocalDate.equals(localDate.iso) &
                  UserRecords.active(t.deletedAt),
            ))
            .getSingleOrNull();

    final companion = ProgramProgressCompanion.insert(
      id: existing?.id ?? _ids.next(),
      createdAt: existing?.createdAt ?? input.recordedAt,
      updatedAt: input.recordedAt,
      userProgramId: userProgramId,
      recordedLocalDate: localDate.iso,
      recordedAt: input.recordedAt,
      weightKg: Value<double?>(input.weightKg),
      weightChangeKg: Value<double?>(input.weightChangeKg),
      targetProgressRatio: Value<double?>(input.targetProgressRatio),
      consumedEnergyKcal: Value<double?>(input.consumedEnergyKcal),
      energyAdherenceRatio: Value<double?>(input.energyAdherenceRatio),
      proteinG: Value<double?>(input.proteinG),
      carbohydrateG: Value<double?>(input.carbohydrateG),
      fatG: Value<double?>(input.fatG),
      loggedMealsCount: Value<int>(input.loggedMealsCount),
      diaryComplete: Value<bool>(input.diaryComplete),
      activeDayNumber: input.activeDayNumber,
      metricsJson: Value<String>(input.metricsJson ?? '{}'),
      calculationVersion: input.calculationVersion,
    );

    if (existing == null) {
      await into(programProgress).insert(companion);
    } else {
      await (update(
        programProgress,
      )..where((t) => t.id.equals(existing.id))).write(companion);
    }
  }

  /// Seluruh potret kemajuan tersimpan untuk [userProgramId], berurutan
  /// menurut tanggal lokal — membaca apa adanya, tanpa menghitung ulang
  /// (task 6.8, Design D10).
  Future<List<ProgramProgressSnapshot>> listProgress(
    String userProgramId,
  ) async {
    final rows =
        await (select(programProgress)
              ..where(
                (t) =>
                    t.userProgramId.equals(userProgramId) &
                    UserRecords.active(t.deletedAt),
              )
              ..orderBy([(t) => OrderingTerm.asc(t.recordedLocalDate)]))
            .get();
    return rows.map(_progressToDomain).toList(growable: false);
  }

  ProgramProgressSnapshot _progressToDomain(ProgramProgressRow row) =>
      ProgramProgressSnapshot(
        id: row.id,
        userProgramId: row.userProgramId,
        recordedLocalDate: LocalDate.parse(row.recordedLocalDate),
        recordedAt: row.recordedAt,
        weightKg: row.weightKg,
        weightChangeKg: row.weightChangeKg,
        targetProgressRatio: row.targetProgressRatio,
        consumedEnergyKcal: row.consumedEnergyKcal,
        energyAdherenceRatio: row.energyAdherenceRatio,
        proteinG: row.proteinG,
        carbohydrateG: row.carbohydrateG,
        fatG: row.fatG,
        loggedMealsCount: row.loggedMealsCount,
        diaryComplete: row.diaryComplete,
        activeDayNumber: row.activeDayNumber,
        calculationVersion: row.calculationVersion,
      );

  Future<void> _insertInitialProgressSnapshot(
    UserProgram program,
    DateTime now,
  ) async {
    await into(programProgress).insert(
      ProgramProgressCompanion.insert(
        id: _ids.next(),
        createdAt: now,
        updatedAt: now,
        userProgramId: program.id,
        recordedLocalDate: _clock.localDateOf(now).iso,
        recordedAt: now,
        activeDayNumber: 1,
        calculationVersion: program.proposal.calculatorVersion,
      ),
    );
  }

  Future<List<ProgramEventRow>> _eventRowsFor(String userProgramId) =>
      (select(programEvents)
            ..where((t) => t.userProgramId.equals(userProgramId))
            ..orderBy([(t) => OrderingTerm.asc(t.occurredAt)]))
          .get();

  UserProgram _toDomain(UserProgramRow row, List<ProgramEventRow> events) {
    final decoded = ProgramJsonCodec.decode(row.inputSnapshotJson);
    final proposal = ProgramTargetProposal(
      program: _programCodeOf(row.programId),
      policyVersion: row.policyVersion,
      calculatorVersion: row.calculatorVersion,
      showsEnergyTarget: decoded.proposal.showsEnergyTarget,
      showsWeightProgressPercent: decoded.proposal.showsWeightProgressPercent,
      energyTarget: row.dailyEnergyTargetKcal == null
          ? null
          : Energy.kcalValue(
              row.dailyEnergyTargetKcal!,
              field: 'dailyEnergyTarget',
            ).valueOrNull!,
      referenceWeight: decoded.proposal.referenceWeight,
      macros: row.proteinTargetG == null
          ? null
          : MacronutrientTargets(
              proteinGrams: row.proteinTargetG!.round(),
              proteinPercentEnergy: decoded.proposal.proteinPercentEnergy!,
              fatGrams: row.fatTargetG!.round(),
              fatPercentEnergy: decoded.proposal.fatPercentEnergy!,
              carbohydrateGrams: row.carbohydrateTargetG!.round(),
              carbohydratePercentEnergy:
                  decoded.proposal.carbohydratePercentEnergy!,
              fiberGrams: row.fiberTargetG!.round(),
            ),
      toleranceBand: decoded.proposal.toleranceBand,
      warnings: decoded.proposal.warnings,
    );

    return UserProgram(
      id: row.id,
      profileId: row.profileId,
      programCode: _programCodeOf(row.programId),
      state: ProgramState.values.byName(row.status),
      proposal: proposal,
      inputSnapshot: decoded.inputs,
      startedAt: row.startedAt!,
      endedAt: row.endedAt,
      pauseIntervals: _reconstructPauseIntervals(events),
      completionReason: row.completionReason,
      supersedesUserProgramId: row.supersedesUserProgramId,
      supersededByUserProgramId: row.supersededByUserProgramId,
    );
  }

  UserProgramsCompanion _toCompanion(
    UserProgram program, {
    required DateTime createdAt,
    required DateTime updatedAt,
  }) {
    final proposal = program.proposal;
    final extras = ProposalExtras(
      showsEnergyTarget: proposal.showsEnergyTarget,
      showsWeightProgressPercent: proposal.showsWeightProgressPercent,
      referenceWeight: proposal.referenceWeight,
      toleranceBand: proposal.toleranceBand,
      proteinPercentEnergy: proposal.macros?.proteinPercentEnergy,
      fatPercentEnergy: proposal.macros?.fatPercentEnergy,
      carbohydratePercentEnergy: proposal.macros?.carbohydratePercentEnergy,
      warnings: proposal.warnings,
    );
    final pausedAt = program.state == ProgramState.paused
        ? program.pauseIntervals.where((p) => p.isOpen).lastOrNull?.startedAt
        : null;

    return UserProgramsCompanion.insert(
      id: program.id,
      createdAt: createdAt,
      updatedAt: updatedAt,
      profileId: program.profileId,
      programId: _programIdOf(program.programCode),
      status: program.state.name,
      startedAt: Value<DateTime?>(program.startedAt),
      pausedAt: Value<DateTime?>(pausedAt),
      endedAt: Value<DateTime?>(program.endedAt),
      baselineWeightKg: Value<double?>(program.inputSnapshot.currentWeight.kg),
      targetWeightKg: Value<double?>(
        program.inputSnapshot.specific.targetWeight?.kg,
      ),
      targetDate: Value<String?>(
        program.inputSnapshot.specific.targetDate?.iso,
      ),
      dailyEnergyTargetKcal: Value<double?>(proposal.energyTarget?.kcal),
      proteinTargetG: Value<double?>(proposal.macros?.proteinGrams.toDouble()),
      carbohydrateTargetG: Value<double?>(
        proposal.macros?.carbohydrateGrams.toDouble(),
      ),
      fatTargetG: Value<double?>(proposal.macros?.fatGrams.toDouble()),
      fiberTargetG: Value<double?>(proposal.macros?.fiberGrams.toDouble()),
      inputSnapshotJson: ProgramJsonCodec.encode(
        inputs: program.inputSnapshot,
        proposal: extras,
      ),
      calculatorVersion: proposal.calculatorVersion,
      policyVersion: proposal.policyVersion,
      completionReason: Value<String?>(program.completionReason),
      supersedesUserProgramId: Value<String?>(program.supersedesUserProgramId),
      supersededByUserProgramId: Value<String?>(
        program.supersededByUserProgramId,
      ),
    );
  }

  ProgramEventsCompanion _eventToCompanion(ProgramEvent event, DateTime now) =>
      ProgramEventsCompanion.insert(
        id: event.id,
        createdAt: now,
        userProgramId: event.userProgramId,
        eventType: event.type.name,
        occurredAt: event.occurredAt,
        fromStatus: Value<String?>(event.fromState?.name),
        toStatus: Value<String?>(event.toState?.name),
        reasonCode: Value<String?>(event.reasonCode),
      );

  ProgramEvent _eventToDomain(ProgramEventRow row) => ProgramEvent(
    id: row.id,
    userProgramId: row.userProgramId,
    type: ProgramEventType.values.byName(row.eventType),
    occurredAt: row.occurredAt,
    fromState: row.fromStatus == null
        ? null
        : ProgramState.values.byName(row.fromStatus!),
    toState: row.toStatus == null
        ? null
        : ProgramState.values.byName(row.toStatus!),
    reasonCode: row.reasonCode,
  );

  List<PauseInterval> _reconstructPauseIntervals(List<ProgramEventRow> events) {
    final intervals = <PauseInterval>[];
    DateTime? openStart;
    for (final event in events) {
      if (event.eventType == 'paused') {
        openStart = event.occurredAt;
      } else if (event.eventType == 'resumed' && openStart != null) {
        intervals.add(
          PauseInterval(startedAt: openStart, endedAt: event.occurredAt),
        );
        openStart = null;
      }
    }
    if (openStart != null) {
      intervals.add(PauseInterval(startedAt: openStart));
    }
    return intervals;
  }

  String _programIdOf(ProgramCode code) => kProgramCatalogIds[code]!;

  ProgramCode _programCodeOf(String programId) => _kProgramCodeById[programId]!;
}

/// Peta balik dari pengenal katalog tetap (Design D2) ke [ProgramCode].
final Map<String, ProgramCode> _kProgramCodeById = <String, ProgramCode>{
  for (final entry in kProgramCatalogIds.entries) entry.value: entry.key,
};
