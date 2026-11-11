import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/ids/id_generator.dart';
import 'package:mealora/domain/food_photo_input/food_component_recognition_provider.dart';
import 'package:mealora/domain/image_ai_access/nutrition_label_provider.dart';

/// Sumber waktu aplikasi.
///
/// Ditimpa saat aplikasi dimulai (`main.dart`) dan di dalam pengujian.
final Provider<Clock> clockProvider = Provider<Clock>(
  (ref) => throw UnimplementedError(
    'clockProvider harus ditimpa di ProviderScope '
    '(lihat lib/main.dart dan test/).',
  ),
);

/// Pembangkit pengenal record.
final Provider<IdGenerator> idGeneratorProvider = Provider<IdGenerator>(
  (ref) => throw UnimplementedError(
    'idGeneratorProvider harus ditimpa di ProviderScope '
    '(lihat lib/main.dart dan test/).',
  ),
);

/// Penyedia model pembacaan label gizi (change 010, Design D2/D8) — di
/// balik antarmuka [NutritionLabelProvider] supaya penggantian penyedia
/// tidak menyentuh layar mana pun. Ditimpa dengan
/// `VisionProxyLabelProvider` di `lib/main.dart`, dan dengan
/// `MockNutritionLabelProvider` pada pengujian.
final Provider<NutritionLabelProvider> nutritionLabelProviderProvider =
    Provider<NutritionLabelProvider>(
      (ref) => throw UnimplementedError(
        'nutritionLabelProviderProvider harus ditimpa di ProviderScope '
        '(lihat lib/main.dart dan test/).',
      ),
    );

/// Penyedia model pengenalan komponen foto makanan (change 011, Design
/// D1/D2) — di balik antarmuka [FoodComponentRecognitionProvider], berdiri
/// sendiri dari [nutritionLabelProviderProvider] karena tugas dan skema
/// keluarannya berbeda (Design D7: evaluasi penyedia tidak dapat dipakai
/// silang). Ditimpa dengan `VisionProxyFoodComponentProvider` di
/// `lib/main.dart`, dan dengan `MockFoodComponentRecognitionProvider` pada
/// pengujian.
final Provider<FoodComponentRecognitionProvider>
foodComponentRecognitionProviderProvider =
    Provider<FoodComponentRecognitionProvider>(
      (ref) => throw UnimplementedError(
        'foodComponentRecognitionProviderProvider harus ditimpa di '
        'ProviderScope (lihat lib/main.dart dan test/).',
      ),
    );
