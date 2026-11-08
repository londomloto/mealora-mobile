import 'package:mealora/domain/program/program_event.dart';
import 'package:mealora/domain/program/program_repository.dart';
import 'package:mealora/domain/program/program_state.dart';
import 'package:mealora/domain/program/user_program.dart';

/// Tiruan `ProgramRepository` dalam memori untuk pengujian (task 7.9) —
/// tanpa Drift, tanpa basis data sungguhan.
///
/// `Future`-based untuk memenuhi kontrak (Design D11, change 004), meski
/// tidak melakukan I/O sungguhan — seluruhnya tetap sinkron di bawah tenda.
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
  Future<UserProgram?> findRunning(String profileId) async {
    for (final program in _programs.values) {
      if (program.profileId == profileId && program.state.isRunning) {
        return program;
      }
    }
    return null;
  }

  @override
  Future<UserProgram?> findById(String id) async => _programs[id];

  @override
  Future<List<ProgramEvent>> eventsFor(String userProgramId) async => _events
      .where((e) => e.userProgramId == userProgramId)
      .toList(growable: false);

  @override
  Future<List<UserProgram>> history(String profileId) async {
    final programs =
        _programs.values.where((p) => p.profileId == profileId).toList()
          ..sort((a, b) => a.startedAt.compareTo(b.startedAt));
    return programs;
  }

  @override
  Future<void> upsert(UserProgram program) async {
    _programs[program.id] = program;
  }

  @override
  Future<void> appendEvent(ProgramEvent event) async {
    _events.add(event);
  }

  @override
  Future<void> applyActivation({
    required UserProgram newProgram,
    required ProgramEvent event,
  }) async {
    final programsSnapshot = Map<String, UserProgram>.of(_programs);
    final eventsSnapshot = List<ProgramEvent>.of(_events);
    try {
      _programs[newProgram.id] = newProgram;
      failureInjector?.call('after_new_program');
      _events.add(event);
      failureInjector?.call('after_event');
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

  @override
  Future<void> applyProgramChange({
    required UserProgram supersededProgram,
    required UserProgram newProgram,
    required List<ProgramEvent> events,
  }) async {
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
