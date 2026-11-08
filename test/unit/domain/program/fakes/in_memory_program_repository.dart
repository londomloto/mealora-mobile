import 'package:mealora/domain/program/program_event.dart';
import 'package:mealora/domain/program/program_repository.dart';
import 'package:mealora/domain/program/program_state.dart';
import 'package:mealora/domain/program/user_program.dart';

/// Tiruan `ProgramRepository` dalam memori untuk pengujian (task 7.9) —
/// tanpa Drift, tanpa basis data sungguhan.
///
/// `applyProgramChange` meniru transaksi basis data: dijalankan atas
/// salinan, lalu diterapkan sekaligus. [failureInjector], bila diberi,
/// dipanggil di antara tiap langkah dan dapat melempar untuk menyimulasikan
/// kegagalan — penyimpanan SHALL kembali seperti semula.
final class InMemoryProgramRepository implements ProgramRepository {
  final Map<String, UserProgram> _programs = <String, UserProgram>{};
  final List<ProgramEvent> _events = <ProgramEvent>[];

  void Function(String checkpoint)? failureInjector;

  @override
  UserProgram? findRunning(String profileId) {
    for (final program in _programs.values) {
      if (program.profileId == profileId && program.state.isRunning) {
        return program;
      }
    }
    return null;
  }

  @override
  UserProgram? findById(String id) => _programs[id];

  @override
  List<ProgramEvent> eventsFor(String userProgramId) => _events
      .where((e) => e.userProgramId == userProgramId)
      .toList(growable: false);

  @override
  void upsert(UserProgram program) {
    _programs[program.id] = program;
  }

  @override
  void appendEvent(ProgramEvent event) {
    _events.add(event);
  }

  @override
  void applyProgramChange({
    required UserProgram supersededProgram,
    required UserProgram newProgram,
    required List<ProgramEvent> events,
  }) {
    final programsSnapshot = Map<String, UserProgram>.of(_programs);
    final eventsSnapshot = List<ProgramEvent>.of(_events);
    try {
      _programs[supersededProgram.id] = supersededProgram;
      failureInjector?.call('after_supersede');
      _programs[newProgram.id] = newProgram;
      failureInjector?.call('after_new_program');
      _events.addAll(events);
      failureInjector?.call('after_events');
    } catch (_) {
      _programs
        ..clear()
        ..addAll(programsSnapshot);
      _events
        ..clear()
        ..addAll(eventsSnapshot);
      rethrow;
    }
  }

  /// Hanya untuk pengujian: seluruh program yang tersimpan saat ini.
  List<UserProgram> get allPrograms => _programs.values.toList(growable: false);
}
