import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/core/errors/result.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/data/local/drift_diary_repository.dart';
import 'package:mealora/data/local/drift_food_repository.dart';
import 'package:mealora/data/local/drift_profile_repository.dart';
import 'package:mealora/data/local/drift_program_repository.dart';
import 'package:mealora/data/local/drift_weight_repository.dart';
import 'package:mealora/data/local/ui_preference_dao.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/database/storage_bootstrap.dart';
import 'package:mealora/domain/profile/user_profile.dart';
import 'package:mealora/domain/program/user_program.dart';
import 'package:mealora/features/diary/diary_controller.dart';
import 'package:mealora/features/onboarding/onboarding_controller.dart'
    show
        onboardingRefreshSignalProvider,
        profileRepositoryProvider,
        programRepositoryProvider;
import 'package:mealora/features/shell/destinations.dart';
import 'package:mealora/features/weight/weight_controller.dart';

/// Pabrik basis data.
///
/// Dapat ditimpa dalam pengujian untuk memakai basis data in-memory atau
/// mensimulasikan kegagalan pembukaan penyimpanan.
final Provider<AppDatabase Function()?> databaseFactoryProvider =
    Provider<AppDatabase Function()?>((ref) => null);

/// Pembukaan dan verifikasi penyimpanan lokal.
final FutureProvider<Result<AppDatabase>> storageProvider =
    FutureProvider<Result<AppDatabase>>((ref) async {
      final result = await openLocalStorage(
        databaseFactory: ref.watch(databaseFactoryProvider),
      );
      ref.onDispose(() => result.valueOrNull?.close());
      return result;
    });

/// Penyimpanan lokal yang sudah siap dipakai.
///
/// Hanya dibaca dari pohon widget yang berada di belakang gerbang peluncuran,
/// sehingga penyimpanan dipastikan sudah terbuka dan terverifikasi.
final Provider<AppDatabase> appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = ref.watch(storageProvider).valueOrNull?.valueOrNull;
  if (database == null) {
    throw StateError(
      'appDatabaseProvider dibaca sebelum penyimpanan lokal siap.',
    );
  }
  return database;
});

final Provider<UiPreferenceDao> uiPreferenceDaoProvider =
    Provider<UiPreferenceDao>(
      (ref) => UiPreferenceDao(
        ref.watch(appDatabaseProvider),
        clock: ref.watch(clockProvider),
      ),
    );

/// Menimpa `profileRepositoryProvider` (features/onboarding, change 005)
/// dengan implementasi Drift sungguhan. Lazy seperti provider lain — baru
/// membaca `appDatabaseProvider` saat benar-benar dipakai, yaitu di
/// belakang gerbang peluncuran tempat penyimpanan sudah siap (lihat
/// `main.dart`, overrides `ProviderScope` akar).
final Override profileRepositoryAppOverride = profileRepositoryProvider
    .overrideWith(
      (ref) => DriftProfileRepository(
        ref.watch(appDatabaseProvider),
        clock: ref.watch(clockProvider),
      ),
    );

/// Menimpa `programRepositoryProvider` (features/onboarding, change 005)
/// dengan implementasi Drift sungguhan — sama seperti
/// [profileRepositoryAppOverride].
final Override programRepositoryAppOverride = programRepositoryProvider
    .overrideWith(
      (ref) => DriftProgramRepository(
        ref.watch(appDatabaseProvider),
        clock: ref.watch(clockProvider),
        ids: ref.watch(idGeneratorProvider),
      ),
    );

/// Menimpa `foodRepositoryProvider` (features/diary, change 007) dengan
/// implementasi Drift sungguhan.
final Override foodRepositoryAppOverride = foodRepositoryProvider.overrideWith(
  (ref) => DriftFoodRepository(
    ref.watch(appDatabaseProvider),
    ids: ref.watch(idGeneratorProvider),
    clock: ref.watch(clockProvider),
  ),
);

/// Menimpa `diaryRepositoryProvider` (features/diary, change 007) dengan
/// implementasi Drift sungguhan — bergantung langsung pada
/// `DriftProgramRepository` untuk memicu pembangunan ulang potret kemajuan
/// (Design D8), dibangun sebagai instance terpisah di atas basis data yang
/// sama (aman: keduanya `DatabaseAccessor` tanpa keadaan di memori).
final Override diaryRepositoryAppOverride = diaryRepositoryProvider
    .overrideWith(
      (ref) => DriftDiaryRepository(
        ref.watch(appDatabaseProvider),
        clock: ref.watch(clockProvider),
        ids: ref.watch(idGeneratorProvider),
        programRepository: DriftProgramRepository(
          ref.watch(appDatabaseProvider),
          clock: ref.watch(clockProvider),
          ids: ref.watch(idGeneratorProvider),
        ),
      ),
    );

/// Menimpa `weightRepositoryProvider` (features/weight, change 008) dengan
/// implementasi Drift sungguhan — bergantung langsung pada
/// `DriftDiaryRepository` untuk memicu pembangunan ulang potret kemajuan
/// bersama (design D5), sama seperti [diaryRepositoryAppOverride].
final Override weightRepositoryAppOverride = weightRepositoryProvider
    .overrideWith(
      (ref) => DriftWeightRepository(
        ref.watch(appDatabaseProvider),
        clock: ref.watch(clockProvider),
        ids: ref.watch(idGeneratorProvider),
        diaryRepository: DriftDiaryRepository(
          ref.watch(appDatabaseProvider),
          clock: ref.watch(clockProvider),
          ids: ref.watch(idGeneratorProvider),
          programRepository: DriftProgramRepository(
            ref.watch(appDatabaseProvider),
            clock: ref.watch(clockProvider),
            ids: ref.watch(idGeneratorProvider),
          ),
        ),
      ),
    );

/// Profil lokal perangkat ini sudah lengkap (Design D2, change 005) — gerbang
/// antara alur onboarding dan ruang utama. `null`/belum lengkap berarti
/// onboarding, apa pun alasannya (belum pernah diisi, atau ditinggalkan di
/// tengah jalan).
///
/// Mengawasi `onboardingRefreshSignalProvider` supaya aktivasi yang
/// berhasil (task 5.5) memaksa pembacaan ulang, bukan memakai nilai yang
/// pernah dihitung sebelum program aktif.
final FutureProvider<bool> isOnboardingCompleteProvider = FutureProvider<bool>((
  ref,
) async {
  ref.watch(onboardingRefreshSignalProvider);
  final repository = ref.watch(profileRepositoryProvider);
  final profile = await repository.current();
  return profile?.isOnboardingComplete ?? false;
});

/// Profil lokal untuk sapaan dan identitas pada ruang utama.
final FutureProvider<UserProfile?> currentProfileProvider =
    FutureProvider<UserProfile?>((ref) async {
      ref.watch(onboardingRefreshSignalProvider);
      return ref.watch(profileRepositoryProvider).current();
    });

/// Program aktif atau dijeda milik profil ini, atau `null` bila belum ada
/// (task 7.1; keadaan "belum ada program", `36`).
final FutureProvider<UserProgram?> activeProgramProvider =
    FutureProvider<UserProgram?>((ref) async {
      ref.watch(onboardingRefreshSignalProvider);
      final profileRepository = ref.watch(profileRepositoryProvider);
      final profile = await profileRepository.current();
      if (profile == null) {
        return null;
      }
      final programRepository = ref.watch(programRepositoryProvider);
      return programRepository.findRunning(profile.id);
    });

/// Ruang navigasi yang sedang dibuka.
///
/// Dipulihkan dari penyimpanan lokal saat aplikasi dibuka kembali, dan
/// disimpan setiap kali pengguna berpindah ruang.
final AsyncNotifierProvider<SelectedDestination, MealoraDestination>
selectedDestinationProvider =
    AsyncNotifierProvider<SelectedDestination, MealoraDestination>(
      SelectedDestination.new,
    );

class SelectedDestination extends AsyncNotifier<MealoraDestination> {
  @override
  Future<MealoraDestination> build() async {
    final dao = ref.watch(uiPreferenceDaoProvider);
    final stored = await dao.read(UiPreferenceKeys.selectedDestination);
    return MealoraDestination.fromStorageKey(stored) ??
        MealoraDestination.today;
  }

  Future<void> select(MealoraDestination destination) async {
    state = AsyncValue<MealoraDestination>.data(destination);
    await ref
        .read(uiPreferenceDaoProvider)
        .write(UiPreferenceKeys.selectedDestination, destination.storageKey);
  }
}
