import 'package:mealora/domain/program/program_state.dart';

/// Jenis peristiwa siklus hidup (program-lifecycle spec, "Jejak peristiwa
/// siklus hidup").
enum ProgramEventType {
  activated,
  paused,
  resumed,
  changed,
  completed,
  cancelled,
}

/// Satu peristiwa dalam jejak siklus hidup program. Jejak ini SHALL cukup
/// untuk menjelaskan kapan program dimulai, dijeda, dilanjutkan, diganti,
/// atau diselesaikan, serta berapa lama setiap jeda berlangsung.
final class ProgramEvent {
  const ProgramEvent({
    required this.id,
    required this.userProgramId,
    required this.type,
    required this.occurredAt,
    this.fromState,
    this.toState,
    this.reasonCode,
  });

  final String id;
  final String userProgramId;
  final ProgramEventType type;
  final DateTime occurredAt;
  final ProgramState? fromState;
  final ProgramState? toState;

  /// Kode alasan pengguna (mis. alasan selesai/jeda) — kode, bukan kalimat
  /// bebas; pemetaan ke teks ada di lapisan presentasi.
  final String? reasonCode;
}
