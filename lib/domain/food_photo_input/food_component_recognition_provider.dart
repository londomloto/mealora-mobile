import 'dart:typed_data' show Uint8List;

import 'package:mealora/domain/food_photo_input/food_component_recognition.dart';
import 'package:mealora/domain/image_ai_access/label_service_failure.dart';

/// Hasil satu panggilan [FoodComponentRecognitionProvider.recognizeComponents]
/// — sealed supaya pemanggil SHALL menangani kedua keadaan secara eksplisit,
/// sama seperti `LabelExtractionOutcome` (domain/image_ai_access, change
/// 010): kegagalan tidak pernah diam-diam jadi usulan kosong.
sealed class FoodComponentRecognitionOutcome {
  const FoodComponentRecognitionOutcome();
}

final class FoodComponentRecognitionRead
    extends FoodComponentRecognitionOutcome {
  const FoodComponentRecognitionRead(this.recognition);

  final FoodPhotoRecognition recognition;
}

final class FoodComponentRecognitionServiceUnavailable
    extends FoodComponentRecognitionOutcome {
  const FoodComponentRecognitionServiceUnavailable(this.reason);

  /// Memakai ulang `image-ai-access` apa adanya (Design D2, change 011):
  /// alasan kegagalan sama persis dengan jalur label gizi — luring, waktu
  /// tunggu lewat, kuota habis, atau penyedia menolak.
  final LabelServiceFailureReason reason;
}

/// Antarmuka penyedia model pengenalan komponen makanan yang dapat diganti
/// (Design D1/D7, change 011) — di atas antarmuka proksi inferensi dan
/// aturan akses gambar yang sudah ditetapkan change 010, dengan tugas dan
/// skema keluaran yang berbeda dari `NutritionLabelProvider` (domain/
/// image_ai_access, change 010): evaluasi penyedia untuk tugas ini berdiri
/// sendiri (Design D7).
///
/// Implementasi SHALL TIDAK melempar pengecualian ke pemanggil untuk
/// kegagalan layanan — seluruhnya dilaporkan lewat
/// [FoodComponentRecognitionServiceUnavailable].
abstract interface class FoodComponentRecognitionProvider {
  Future<FoodComponentRecognitionOutcome> recognizeComponents(
    Uint8List imageBytes,
  );
}
