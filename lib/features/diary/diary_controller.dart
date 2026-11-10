import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/domain/diary/diary_repository.dart';
import 'package:mealora/domain/food/food_repository.dart';

/// Diinjeksi di `main.dart`/pengujian, mengikuti pola `profileRepositoryProvider`
/// (features/onboarding, change 005).
final Provider<FoodRepository> foodRepositoryProvider =
    Provider<FoodRepository>(
      (ref) => throw UnimplementedError(
        'foodRepositoryProvider harus ditimpa di ProviderScope '
        '(lihat lib/main.dart dan test/).',
      ),
    );

/// Diinjeksi di `main.dart`/pengujian, sama seperti [foodRepositoryProvider].
final Provider<DiaryRepository> diaryRepositoryProvider =
    Provider<DiaryRepository>(
      (ref) => throw UnimplementedError(
        'diaryRepositoryProvider harus ditimpa di ProviderScope '
        '(lihat lib/main.dart dan test/).',
      ),
    );

/// Menandai perubahan buku harian (tambah/sunting/pindah/hapus catatan, atau
/// makanan buatan sendiri baru) — menaikkan nilai ini memaksa seluruh
/// provider turunan di `diary_providers.dart` membaca ulang penyimpanan,
/// mengikuti pola `onboardingRefreshSignalProvider`/
/// `programLifecycleRefreshSignalProvider`.
final StateProvider<int> diaryRefreshSignalProvider = StateProvider<int>(
  (ref) => 0,
);

void bumpDiaryRefresh(WidgetRef ref) {
  ref.read(diaryRefreshSignalProvider.notifier).state++;
}
