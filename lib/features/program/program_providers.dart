import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/data/local/drift_program_repository.dart';
import 'package:mealora/data/local/program_progress_snapshot.dart';
import 'package:mealora/domain/program/commands/change_program_command.dart';
import 'package:mealora/domain/program/commands/simple_lifecycle_commands.dart';
import 'package:mealora/domain/program/user_program.dart';
import 'package:mealora/features/onboarding/onboarding_controller.dart'
    show
        onboardingRefreshSignalProvider,
        profileRepositoryProvider,
        programEngineProvider,
        programRepositoryProvider;

/// Menandai perubahan siklus hidup (jeda/lanjutkan/ganti/selesaikan) yang
/// terjadi di ruang Program (task 5.1, 6.2, 8.2) — menaikkan nilai ini
/// memaksa [activeProgramProvider]/[programHistoryProvider]/
/// [programProgressProvider] membaca ulang penyimpanan, mengikuti pola
/// `onboardingRefreshSignalProvider` (app/providers.dart, change 005).
final StateProvider<int> programLifecycleRefreshSignalProvider =
    StateProvider<int>((ref) => 0);

void bumpProgramRefresh(WidgetRef ref) {
  ref.read(programLifecycleRefreshSignalProvider.notifier).state++;
  // Aktivasi/pergantian juga mengubah apakah onboarding dianggap selesai
  // (tidak sebenarnya, tapi `activeProgramProvider`, app/providers.dart,
  // mengawasi sinyal yang sama) — menaikkan keduanya menjaga seluruh
  // pembaca program tetap sinkron dengan satu sinyal tunggal.
  ref.read(onboardingRefreshSignalProvider.notifier).state++;
}

final Provider<PauseProgramCommand> pauseProgramCommandProvider =
    Provider<PauseProgramCommand>(
      (ref) => PauseProgramCommand(
        repository: ref.watch(programRepositoryProvider),
        clock: ref.watch(clockProvider),
        idGenerator: ref.watch(idGeneratorProvider),
      ),
    );

final Provider<ResumeProgramCommand> resumeProgramCommandProvider =
    Provider<ResumeProgramCommand>(
      (ref) => ResumeProgramCommand(
        repository: ref.watch(programRepositoryProvider),
        clock: ref.watch(clockProvider),
        idGenerator: ref.watch(idGeneratorProvider),
      ),
    );

final Provider<CompleteProgramCommand> completeProgramCommandProvider =
    Provider<CompleteProgramCommand>(
      (ref) => CompleteProgramCommand(
        repository: ref.watch(programRepositoryProvider),
        clock: ref.watch(clockProvider),
        idGenerator: ref.watch(idGeneratorProvider),
      ),
    );

final Provider<ChangeProgramCommand> changeProgramCommandProvider =
    Provider<ChangeProgramCommand>(
      (ref) => ChangeProgramCommand(
        repository: ref.watch(programRepositoryProvider),
        clock: ref.watch(clockProvider),
        idGenerator: ref.watch(idGeneratorProvider),
        engine: ref.watch(programEngineProvider),
      ),
    );

/// Seluruh program yang pernah dijalani profil ini, berurutan menurut waktu
/// mulai (task 7.1) — dibaca apa adanya (Design D6), tidak menghitung
/// ulang apa pun.
final FutureProvider<List<UserProgram>> programHistoryProvider =
    FutureProvider<List<UserProgram>>((ref) async {
      ref.watch(onboardingRefreshSignalProvider);
      ref.watch(programLifecycleRefreshSignalProvider);
      final profile = await ref.watch(profileRepositoryProvider).current();
      if (profile == null) {
        return const <UserProgram>[];
      }
      final repository = ref.watch(programRepositoryProvider);
      return repository.history(profile.id);
    });

/// Potret kemajuan tersimpan untuk satu program (task 2.3/2.4, 7.3) —
/// dibaca apa adanya (Design D6/D10): tidak menghitung ulang, tidak mengisi
/// celah kosong.
///
/// `ProgramRepository` (domain) tidak mengekspos `listProgress` — ini
/// adalah detail penyimpanan Drift (Design D9) — jadi provider ini
/// bergantung pada [DriftProgramRepository] secara langsung, mengikuti pola
/// `drift_profile_repository.dart`/`drift_program_repository.dart` lain di
/// aplikasi ini yang juga diakses lewat implementasi konkret saat perlu
/// kemampuan di luar kontrak domain.
final FutureProviderFamily<List<ProgramProgressSnapshot>, String>
programProgressProvider =
    FutureProvider.family<List<ProgramProgressSnapshot>, String>((
      ref,
      userProgramId,
    ) async {
      ref.watch(programLifecycleRefreshSignalProvider);
      final repository = ref.watch(programRepositoryProvider);
      if (repository is DriftProgramRepository) {
        return repository.listProgress(userProgramId);
      }
      return const <ProgramProgressSnapshot>[];
    });

/// Baris program yang digantikan oleh program ini (`supersedesUserProgramId`),
/// atau yang menggantikannya (`supersededByUserProgramId`) — dipakai layar
/// detail riwayat (task 7.2) untuk menyebut program sebelum/sesudahnya apa
/// adanya, tanpa menghitung ulang.
final FutureProviderFamily<UserProgram?, String> programByIdProvider =
    FutureProvider.family<UserProgram?, String>((ref, id) async {
      final repository = ref.watch(programRepositoryProvider);
      return repository.findById(id);
    });

/// Potret kemajuan terbaru yang memuat berat badan, atau `null` bila belum
/// ada satu pun catatan berat (task 2.2, 3.3) — "belum ada catatan", bukan
/// 0 kg, sampai buku harian/pemantauan berat (change berikutnya) benar-benar
/// menulis potret berbobot.
ProgramProgressSnapshot? latestWeightSnapshot(
  List<ProgramProgressSnapshot> snapshots,
) {
  for (final snapshot in snapshots.reversed) {
    if (snapshot.weightKg != null) {
      return snapshot;
    }
  }
  return null;
}
