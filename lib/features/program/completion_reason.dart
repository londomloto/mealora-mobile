import 'package:mealora/l10n/generated/app_localizations.dart';

/// Alasan selesai yang dapat dipilih pengguna (`39 · Selesaikan program`,
/// task 5.2) — kode mesin stabil disimpan sebagai `UserProgram.completionReason`
/// (`CompleteProgramCommand.execute(reasonCode: ...)`); tidak ada katalog
/// alasan di domain (change 003 menerima `String` bebas), jadi daftar
/// tertutup ini murni lapisan tampilan, mengikuti pola `kHabitFocusCodes`
/// (features/onboarding/program_detail_screen.dart).
enum ProgramCompletionReason {
  goalReached('goal_reached'),
  switchingProgram('switching_program'),
  takingABreak('taking_a_break'),
  other('other');

  const ProgramCompletionReason(this.code);

  final String code;

  String label(AppText text) => switch (this) {
    ProgramCompletionReason.goalReached => text.completeReasonGoalReached,
    ProgramCompletionReason.switchingProgram =>
      text.completeReasonSwitchingProgram,
    ProgramCompletionReason.takingABreak => text.completeReasonTakingABreak,
    ProgramCompletionReason.other => text.completeReasonOther,
  };
}
