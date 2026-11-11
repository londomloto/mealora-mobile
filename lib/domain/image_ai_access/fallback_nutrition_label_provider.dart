import 'dart:typed_data' show Uint8List;

import 'package:mealora/domain/image_ai_access/nutrition_label_provider.dart';

/// Composite [NutritionLabelProvider] yang mencoba `primary` (penyedia
/// cloud) lebih dulu, lalu `fallback` (OCR lokal) ketika `primary` gagal —
/// offline, waktu tunggu lewat, kuota habis, atau ditolak (Design D11,
/// change 010).
///
/// Diekspos sebagai SATU [NutritionLabelProvider] ke layar, sesuai D2:
/// layar foto label dan layar tinjau SHALL TIDAK tahu ada dua penyedia di
/// baliknya — satu-satunya titik ganti tetap konstruksi provider ini di
/// `lib/app/providers.dart`. Hasil `fallback` — baik hasil berupa bacaan
/// maupun layanan tidak tersedia — dikembalikan apa adanya sebagai hasil
/// akhir; kegagalan ganda (cloud gagal, lalu OCR juga gagal) tetap bermuara
/// ke jalur manual lewat kegagalan yang sama seperti kegagalan tunggal
/// (spec image-ai-access, "Kegagalan layanan cloud dicoba lewat OCR lokal
/// sebelum jalur manual").
final class FallbackNutritionLabelProvider implements NutritionLabelProvider {
  const FallbackNutritionLabelProvider({
    required NutritionLabelProvider primary,
    required NutritionLabelProvider fallback,
  }) : _primary = primary,
       _fallback = fallback;

  final NutritionLabelProvider _primary;
  final NutritionLabelProvider _fallback;

  @override
  Future<LabelExtractionOutcome> extractLabel(Uint8List imageBytes) async {
    final primaryOutcome = await _primary.extractLabel(imageBytes);
    if (primaryOutcome is LabelExtractionRead) {
      return primaryOutcome;
    }
    return _fallback.extractLabel(imageBytes);
  }
}
