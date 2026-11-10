import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/domain/weight/weight_repository.dart';

/// Diinjeksi di `main.dart`/pengujian, mengikuti pola
/// `diaryRepositoryProvider` (features/diary, change 007).
final Provider<WeightRepository> weightRepositoryProvider =
    Provider<WeightRepository>(
      (ref) => throw UnimplementedError(
        'weightRepositoryProvider harus ditimpa di ProviderScope '
        '(lihat lib/main.dart dan test/).',
      ),
    );

/// Menandai perubahan catatan berat (tambah/sunting/hapus) — menaikkan
/// nilai ini memaksa pembaca berat (ruang Program, pantau berat, riwayat)
/// membaca ulang penyimpanan, mengikuti pola
/// `programLifecycleRefreshSignalProvider` (features/program, change 006).
final StateProvider<int> weightRefreshSignalProvider = StateProvider<int>(
  (ref) => 0,
);

void bumpWeightRefresh(WidgetRef ref) {
  ref.read(weightRefreshSignalProvider.notifier).state++;
}
