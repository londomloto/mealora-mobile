import 'package:mealora/domain/program/program_command.dart';
import 'package:mealora/domain/program/program_state.dart';

/// Perpindahan yang tidak sah — memuat keadaan saat ini dan perintah yang
/// ditolak, bukan pengecualian umum (program-lifecycle spec, "Keadaan
/// program dan perpindahan yang sah").
final class InvalidProgramTransition {
  const InvalidProgramTransition({
    required this.currentState,
    required this.command,
  });

  final ProgramState currentState;
  final ProgramCommand command;

  @override
  bool operator ==(Object other) =>
      other is InvalidProgramTransition &&
      other.currentState == currentState &&
      other.command == command;

  @override
  int get hashCode => Object.hash(currentState, command);

  @override
  String toString() =>
      'InvalidProgramTransition(${currentState.name} -/-> ${command.name})';
}

/// Hasil `ProgramLifecycle.transition`.
sealed class TransitionOutcome {
  const TransitionOutcome();
}

final class TransitionAllowed extends TransitionOutcome {
  const TransitionAllowed(this.nextState);

  final ProgramState nextState;
}

final class TransitionDenied extends TransitionOutcome {
  const TransitionDenied(this.error);

  final InvalidProgramTransition error;
}

/// Mesin keadaan siklus hidup program — tabel perpindahan eksplisit, bukan
/// rangkaian `if` (Design D4).
///
/// Untuk setiap pasangan (keadaan, perintah) ada tepat satu hasil: sah
/// (dengan keadaan tujuan) atau ditolak (dengan kesalahan bertipe). Tidak
/// menangani idempotensi perintah berulang — itu tanggung jawab lapisan
/// perintah (change 003, task 7.7), yang mengenali pengulangan dengan
/// maksud sama sebelum memanggil mesin ini.
abstract final class ProgramLifecycle {
  static final Map<(ProgramState, ProgramCommand), ProgramState> _table =
      <(ProgramState, ProgramCommand), ProgramState>{
        (ProgramState.draft, ProgramCommand.activate): ProgramState.active,
        (ProgramState.draft, ProgramCommand.cancel): ProgramState.cancelled,
        (ProgramState.active, ProgramCommand.pause): ProgramState.paused,
        (ProgramState.active, ProgramCommand.complete): ProgramState.completed,
        (ProgramState.active, ProgramCommand.change): ProgramState.changed,
        (ProgramState.active, ProgramCommand.cancel): ProgramState.cancelled,
        (ProgramState.paused, ProgramCommand.resume): ProgramState.active,
        (ProgramState.paused, ProgramCommand.complete): ProgramState.completed,
        (ProgramState.paused, ProgramCommand.change): ProgramState.changed,
        (ProgramState.paused, ProgramCommand.cancel): ProgramState.cancelled,
      };

  static TransitionOutcome transition(
    ProgramState current,
    ProgramCommand command,
  ) {
    final next = _table[(current, command)];
    if (next == null) {
      return TransitionDenied(
        InvalidProgramTransition(currentState: current, command: command),
      );
    }
    return TransitionAllowed(next);
  }

  /// Invarian: sebuah profil SHALL memiliki paling banyak satu program
  /// berstatus `active` atau `paused` (program-lifecycle spec, "Satu
  /// program berjalan per profil"). Dirumuskan di sini agar dapat diperiksa
  /// berulang kali — oleh uji properti sekarang, dan oleh lapisan
  /// persistensi di change berikutnya.
  static bool satisfiesSingleRunningInvariant(
    Iterable<ProgramState> statesForProfile,
  ) {
    final runningCount = statesForProfile.where((s) => s.isRunning).length;
    return runningCount <= 1;
  }
}
