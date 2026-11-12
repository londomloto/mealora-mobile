import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/ids/id_generator.dart';
import 'package:mealora/domain/food_photo_input/food_component_recognition_provider.dart';
import 'package:mealora/domain/image_ai_access/nutrition_label_provider.dart';
import 'package:mealora/domain/nutrition_import/nutrition_import.dart';
import 'package:mealora/domain/reminders/reminder_scheduler.dart';
import 'package:mealora/domain/voice_input/food_sentence_parser.dart';
import 'package:mealora/domain/voice_input/speech_recognizer.dart';

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

/// Pengenal ucapan di perangkat untuk masukan suara (change 012, Design
/// D2). Ditimpa dengan `DeviceSpeechRecognizer` di `lib/main.dart`, dan
/// dengan tiruan pada pengujian. Membaca provider ini TIDAK meminta izin
/// mikrofon; izin baru diminta saat [SpeechRecognizer.prepare] dipanggil.
final Provider<SpeechRecognizer> speechRecognizerProvider =
    Provider<SpeechRecognizer>(
      (ref) => throw UnimplementedError(
        'speechRecognizerProvider harus ditimpa di ProviderScope '
        '(lihat lib/main.dart dan test/).',
      ),
    );

/// Pengurai kalimat pencatatan makanan (change 012, Design D3/D14). Ditimpa
/// dengan `FallbackFoodSentenceParser` (proksi lalu aturan di perangkat) di
/// `lib/main.dart`, dan dengan `MockFoodSentenceParser` pada pengujian.
final Provider<FoodSentenceParser> foodSentenceParserProvider =
    Provider<FoodSentenceParser>(
      (ref) => throw UnimplementedError(
        'foodSentenceParserProvider harus ditimpa di ProviderScope '
        '(lihat lib/main.dart dan test/).',
      ),
    );

/// Pembaca teks info gizi lewat proksi `/parse-nutrition-text` (change 020,
/// design D5). Ditimpa dengan `ModelProxyNutritionTextReader` di
/// `lib/main.dart`, dan dengan tiruan pada pengujian.
final Provider<NutritionTextReader> nutritionTextReaderProvider =
    Provider<NutritionTextReader>(
      (ref) => throw UnimplementedError(
        'nutritionTextReaderProvider harus ditimpa di ProviderScope '
        '(lihat lib/main.dart dan test/).',
      ),
    );

/// Pembacaan foto info gizi bertingkat (change 020, design D3). Ditimpa
/// di `lib/main.dart` dengan klien proksi sungguhan dan OCR ML Kit, dan
/// dengan tiruan pada pengujian.
final Provider<NutritionReadingPipeline> nutritionReadingPipelineProvider =
    Provider<NutritionReadingPipeline>(
      (ref) => throw UnimplementedError(
        'nutritionReadingPipelineProvider harus ditimpa di ProviderScope '
        '(lihat lib/main.dart dan test/).',
      ),
    );

/// Penjadwal notifikasi pengingat lokal (change 013). Ditimpa dengan
/// `LocalNotificationsGateway` di `lib/main.dart`, dan dengan tiruan pada
/// pengujian. Membaca provider ini TIDAK meminta izin notifikasi.
final Provider<ReminderNotificationGateway>
reminderNotificationGatewayProvider = Provider<ReminderNotificationGateway>(
  (ref) => throw UnimplementedError(
    'reminderNotificationGatewayProvider harus ditimpa di ProviderScope '
    '(lihat lib/main.dart dan test/).',
  ),
);
