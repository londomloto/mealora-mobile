import 'package:mealora/domain/program/program_target_proposal.dart';
import 'package:mealora/domain/program/user_program.dart';
import 'package:mealora/domain/shared/program_outcome.dart';

/// Hasil `ActivateProgramCommand` (program-lifecycle spec, "Aktivasi
/// memerlukan proposal yang disetujui dan konfirmasi pengguna").
sealed class ActivationResult {
  const ActivationResult();
}

final class ActivationSucceeded extends ActivationResult {
  const ActivationSucceeded(this.program);

  final UserProgram program;
}

/// Perintah berulang dengan proposal yang sama — dikenali sebagai
/// pengulangan, bukan program kedua (task 7.7).
final class ActivationAlreadySatisfied extends ActivationResult {
  const ActivationAlreadySatisfied(this.existing);

  final UserProgram existing;
}

final class ActivationRequiresConfirmation extends ActivationResult {
  const ActivationRequiresConfirmation();
}

/// Fakta yang dipakai proposal sudah berubah sejak pratinjau.
final class ActivationInputsChangedSincePreview extends ActivationResult {
  const ActivationInputsChangedSincePreview();
}

/// Sistem SHALL TIDAK mengaktifkan program atas dasar hasil yang tidak
/// disetujui, meskipun perintah datang tanpa melewati antarmuka pengguna.
final class ActivationRejectedNotApproved extends ActivationResult {
  const ActivationRejectedNotApproved(this.outcome);

  final ProgramOutcome<ProgramTargetProposal> outcome;
}

/// Sudah ada program lain yang berjalan — pemanggil SHALL memakai
/// `ChangeProgramCommand`, bukan aktivasi langsung.
final class ActivationConflictExistingRunningProgram extends ActivationResult {
  const ActivationConflictExistingRunningProgram(this.existing);

  final UserProgram existing;
}

/// Aktivasi gagal diterapkan — Design D4, change 004: penyimpanan SHALL
/// kembali seperti semula (dibuktikan lewat `ProgramRepository.applyActivation`
/// yang dipanggil tepat sekali dan diuji atomik).
final class ActivationFailed extends ActivationResult {
  const ActivationFailed(this.error);

  final Object error;
}
