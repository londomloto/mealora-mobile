import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/ids/id_generator.dart';
import 'package:mealora/domain/program/pause_interval.dart';
import 'package:mealora/domain/program/program_command.dart';
import 'package:mealora/domain/program/program_event.dart';
import 'package:mealora/domain/program/program_lifecycle.dart';
import 'package:mealora/domain/program/program_repository.dart';
import 'package:mealora/domain/program/program_state.dart';
import 'package:mealora/domain/program/user_program.dart';

/// Hasil umum untuk perintah siklus hidup sederhana (jeda, lanjutkan,
/// selesaikan, batalkan): sah, sudah sesuai (idempoten), atau perpindahan
/// tidak sah.
sealed class SimpleCommandResult {
  const SimpleCommandResult();
}

final class SimpleCommandSucceeded extends SimpleCommandResult {
  const SimpleCommandSucceeded(this.program);

  final UserProgram program;
}

/// Perintah berulang dengan maksud yang sama (task 7.7) — keadaan memang
/// sudah sesuai, tanpa peristiwa ganda dan tanpa mengubah waktu mulai jeda.
final class SimpleCommandAlreadySatisfied extends SimpleCommandResult {
  const SimpleCommandAlreadySatisfied(this.program);

  final UserProgram program;
}

final class SimpleCommandInvalidTransition extends SimpleCommandResult {
  const SimpleCommandInvalidTransition(this.error);

  final InvalidProgramTransition error;
}

final class SimpleCommandNotFound extends SimpleCommandResult {
  const SimpleCommandNotFound();
}

base class _BaseLifecycleCommand {
  const _BaseLifecycleCommand({
    required this.repository,
    required this.clock,
    required this.idGenerator,
  });

  final ProgramRepository repository;
  final Clock clock;
  final IdGenerator idGenerator;

  SimpleCommandResult _run({
    required String userProgramId,
    required ProgramCommand command,
    required ProgramEventType eventType,
    required UserProgram Function(UserProgram current, DateTime now)
    applyChange,
    String? reasonCode,
  }) {
    final current = repository.findById(userProgramId);
    if (current == null) {
      return const SimpleCommandNotFound();
    }

    // Idempotensi: perintah yang sudah terpenuhi (mis. jeda yang sudah
    // dijeda) tidak menghasilkan keadaan atau peristiwa ganda.
    final alreadyTarget = switch (command) {
      ProgramCommand.pause => current.state == ProgramState.paused,
      ProgramCommand.resume => current.state == ProgramState.active,
      ProgramCommand.complete => current.state == ProgramState.completed,
      ProgramCommand.cancel => current.state == ProgramState.cancelled,
      ProgramCommand.activate || ProgramCommand.change => false,
    };
    if (alreadyTarget) {
      return SimpleCommandAlreadySatisfied(current);
    }

    final transition = ProgramLifecycle.transition(current.state, command);
    if (transition is TransitionDenied) {
      return SimpleCommandInvalidTransition(transition.error);
    }

    final now = clock.nowUtc();
    final updated = applyChange(current, now);
    repository.upsert(updated);
    repository.appendEvent(
      ProgramEvent(
        id: idGenerator.next(),
        userProgramId: updated.id,
        type: eventType,
        occurredAt: now,
        fromState: current.state,
        toState: updated.state,
        reasonCode: reasonCode,
      ),
    );
    return SimpleCommandSucceeded(updated);
  }
}

/// Menjeda program — mencatat waktu mulai jeda, menghentikan hari aktif
/// (program-lifecycle spec, "Jeda dan lanjutkan").
final class PauseProgramCommand extends _BaseLifecycleCommand {
  const PauseProgramCommand({
    required super.repository,
    required super.clock,
    required super.idGenerator,
  });

  SimpleCommandResult execute({required String userProgramId}) => _run(
    userProgramId: userProgramId,
    command: ProgramCommand.pause,
    eventType: ProgramEventType.paused,
    applyChange: (current, now) => current.copyWith(
      state: ProgramState.paused,
      pauseIntervals: <PauseInterval>[
        ...current.pauseIntervals,
        PauseInterval(startedAt: now),
      ],
    ),
  );
}

/// Melanjutkan program — mengembalikan ke `active`; rentang jeda tetap
/// tertelusuri di riwayat (Design D8).
final class ResumeProgramCommand extends _BaseLifecycleCommand {
  const ResumeProgramCommand({
    required super.repository,
    required super.clock,
    required super.idGenerator,
  });

  SimpleCommandResult execute({required String userProgramId}) => _run(
    userProgramId: userProgramId,
    command: ProgramCommand.resume,
    eventType: ProgramEventType.resumed,
    applyChange: (current, now) {
      final intervals = List<PauseInterval>.of(current.pauseIntervals);
      if (intervals.isNotEmpty && intervals.last.isOpen) {
        intervals[intervals.length - 1] = intervals.last.ended(now);
      }
      return current.copyWith(
        state: ProgramState.active,
        pauseIntervals: intervals,
      );
    },
  );
}

/// Menyelesaikan program — mencatat alasan dan memindahkan ke `completed`.
final class CompleteProgramCommand extends _BaseLifecycleCommand {
  const CompleteProgramCommand({
    required super.repository,
    required super.clock,
    required super.idGenerator,
  });

  SimpleCommandResult execute({
    required String userProgramId,
    required String reasonCode,
  }) => _run(
    userProgramId: userProgramId,
    command: ProgramCommand.complete,
    eventType: ProgramEventType.completed,
    reasonCode: reasonCode,
    applyChange: (current, now) => current.copyWith(
      state: ProgramState.completed,
      endedAt: now,
      completionReason: reasonCode,
    ),
  );
}

/// Membatalkan program — biasanya dipakai untuk program `draft` yang belum
/// pernah aktif; tidak mengubah program lain maupun data apa pun.
final class CancelProgramCommand extends _BaseLifecycleCommand {
  const CancelProgramCommand({
    required super.repository,
    required super.clock,
    required super.idGenerator,
  });

  SimpleCommandResult execute({required String userProgramId}) => _run(
    userProgramId: userProgramId,
    command: ProgramCommand.cancel,
    eventType: ProgramEventType.cancelled,
    applyChange: (current, now) =>
        current.copyWith(state: ProgramState.cancelled, endedAt: now),
  );
}
