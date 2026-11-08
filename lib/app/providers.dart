import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/core/errors/result.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/data/local/ui_preference_dao.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/database/storage_bootstrap.dart';
import 'package:mealora/features/shell/destinations.dart';

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
