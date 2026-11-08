import 'package:mealora/domain/program/pause_interval.dart';
import 'package:mealora/domain/program/program_code.dart';
import 'package:mealora/domain/program/program_proposal_inputs.dart';
import 'package:mealora/domain/program/program_state.dart';
import 'package:mealora/domain/program/program_target_proposal.dart';

/// Pendaftaran seorang pengguna pada sebuah program — terpisah dari
/// definisi katalog (program-catalog spec, "Definisi program terpisah dari
/// program pengguna").
///
/// Menyimpan salinan masukan dan target yang disetujui, bukan rujukan ke
/// profil hidup (Design D9): mengubah profil atau katalog di kemudian hari
/// SHALL TIDAK mengubah apa yang tersimpan di sini.
final class UserProgram {
  const UserProgram({
    required this.id,
    required this.profileId,
    required this.programCode,
    required this.state,
    required this.proposal,
    required this.inputSnapshot,
    required this.startedAt,
    this.endedAt,
    this.pauseIntervals = const <PauseInterval>[],
    this.completionReason,
    this.supersedesUserProgramId,
    this.supersededByUserProgramId,
  });

  final String id;
  final String profileId;
  final ProgramCode programCode;
  final ProgramState state;

  /// Target yang disetujui, asumsi, peringatan, `calculator_version`, dan
  /// `policy_version` seperti saat program ini diaktifkan (task 7.8).
  final ProgramTargetProposal proposal;

  /// Salinan masukan yang dipakai saat perhitungan (Design D9).
  final ProgramProposalInputs inputSnapshot;

  final DateTime startedAt;
  final DateTime? endedAt;
  final List<PauseInterval> pauseIntervals;

  final String? completionReason;

  /// Tautan dua arah pergantian program (program-lifecycle spec,
  /// "Pergantian program berlangsung utuh").
  final String? supersedesUserProgramId;
  final String? supersededByUserProgramId;

  UserProgram copyWith({
    ProgramState? state,
    DateTime? endedAt,
    List<PauseInterval>? pauseIntervals,
    String? completionReason,
    String? supersedesUserProgramId,
    String? supersededByUserProgramId,
  }) => UserProgram(
    id: id,
    profileId: profileId,
    programCode: programCode,
    state: state ?? this.state,
    proposal: proposal,
    inputSnapshot: inputSnapshot,
    startedAt: startedAt,
    endedAt: endedAt ?? this.endedAt,
    pauseIntervals: pauseIntervals ?? this.pauseIntervals,
    completionReason: completionReason ?? this.completionReason,
    supersedesUserProgramId:
        supersedesUserProgramId ?? this.supersedesUserProgramId,
    supersededByUserProgramId:
        supersededByUserProgramId ?? this.supersededByUserProgramId,
  );
}
