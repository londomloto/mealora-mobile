/// Keadaan sebuah program pengguna (program-lifecycle spec, "Keadaan
/// program dan perpindahan yang sah").
///
/// `completed`, `changed`, dan `cancelled` adalah keadaan akhir — tidak ada
/// perpindahan keluar darinya.
enum ProgramState { draft, active, paused, completed, changed, cancelled }

extension ProgramStateTerminal on ProgramState {
  bool get isTerminal => switch (this) {
    ProgramState.completed ||
    ProgramState.changed ||
    ProgramState.cancelled => true,
    ProgramState.draft || ProgramState.active || ProgramState.paused => false,
  };

  bool get isRunning =>
      this == ProgramState.active || this == ProgramState.paused;
}
