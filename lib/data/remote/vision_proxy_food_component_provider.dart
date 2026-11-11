import 'dart:async' show TimeoutException;
import 'dart:convert';
import 'dart:typed_data' show Uint8List;

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' show MediaType;
import 'package:mealora/data/remote/vision_proxy_label_provider.dart'
    show VisionProxyConfig;
import 'package:mealora/domain/food_photo_input/food_component_recognition.dart';
import 'package:mealora/domain/food_photo_input/food_component_recognition_provider.dart';
import 'package:mealora/domain/image_ai_access/label_service_failure.dart';
import 'package:mealora/domain/image_ai_access/reading_confidence.dart';

/// Klien `mealora-vision-proxy` untuk pengenalan komponen makanan (change
/// 011-food-photo-input, Design D1/D2, task 2.1) — satu dari sedikit berkas
/// di aplikasi yang boleh memakai `package:http`, dipagari oleh
/// `test/unit/architecture/layer_rules_test.dart`, grup "kemandirian dari
/// jaringan".
///
/// Memakai ulang [VisionProxyConfig] apa adanya (Design D2): alamat proksi
/// dan token level-aplikasi yang sama dengan `VisionProxyLabelProvider`,
/// TIDAK PERNAH kredensial penyedia model. Mengirim HANYA bita gambar —
/// tidak ada pengenal perangkat, profil, maupun kredensial yang ikut
/// terkirim.
final class VisionProxyFoodComponentProvider
    implements FoodComponentRecognitionProvider {
  VisionProxyFoodComponentProvider({
    required this.config,
    http.Client? httpClient,
    this.timeout = const Duration(seconds: 55),
  }) : _httpClient = httpClient ?? http.Client();

  final VisionProxyConfig config;
  final http.Client _httpClient;
  final Duration timeout;

  @override
  Future<FoodComponentRecognitionOutcome> recognizeComponents(
    Uint8List imageBytes,
  ) async {
    if (!config.isConfigured) {
      return const FoodComponentRecognitionServiceUnavailable(
        LabelServiceFailureReason.offline,
      );
    }

    final uri = Uri.parse('${config.baseUrl}/recognize-food-components');
    if (kDebugMode) {
      debugPrint('Vision proxy request: $uri (${imageBytes.length} bytes)');
    }
    final request = http.MultipartRequest('POST', uri)
      ..files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: 'food-photo.jpg',
          contentType: MediaType('image', 'jpeg'),
        ),
      );
    final token = config.sharedToken;
    if (token != null && token.isNotEmpty) {
      request.headers['X-Proxy-Token'] = token;
    }

    final http.StreamedResponse streamed;
    try {
      streamed = await _httpClient.send(request).timeout(timeout);
    } on TimeoutException {
      return const FoodComponentRecognitionServiceUnavailable(
        LabelServiceFailureReason.timeout,
      );
    } on Object catch (error) {
      if (kDebugMode) {
        debugPrint('Vision proxy transport error: $error');
      }
      return const FoodComponentRecognitionServiceUnavailable(
        LabelServiceFailureReason.offline,
      );
    }

    final response = await http.Response.fromStream(streamed);
    if (kDebugMode) {
      debugPrint('Vision proxy response: ${response.statusCode}');
    }
    if (response.statusCode != 200) {
      return FoodComponentRecognitionServiceUnavailable(
        _reasonForStatus(response.statusCode),
      );
    }

    try {
      return FoodComponentRecognitionRead(_parseRecognition(response.body));
    } on Object {
      // Respons 200 tapi bentuknya tak terduga — penyedia/proksi dianggap
      // menolak permintaan ini, bukan ditebak isinya.
      return const FoodComponentRecognitionServiceUnavailable(
        LabelServiceFailureReason.refused,
      );
    }
  }

  LabelServiceFailureReason _reasonForStatus(int statusCode) =>
      switch (statusCode) {
        429 => LabelServiceFailureReason.quotaExceeded,
        504 => LabelServiceFailureReason.timeout,
        _ => LabelServiceFailureReason.refused,
      };

  FoodPhotoRecognition _parseRecognition(String body) {
    final json = jsonDecode(body) as Map<String, Object?>;
    final rawComponents = json['components'] as List<Object?>? ?? const [];
    return FoodPhotoRecognition(
      components: rawComponents
          .map((raw) => _parseComponent(raw as Map<String, Object?>))
          .toList(growable: false),
    );
  }

  RecognizedComponent _parseComponent(Map<String, Object?> json) {
    final foodName = json['foodName'];
    return RecognizedComponent(
      foodNameGuess: foodName is String && foodName.trim().isNotEmpty
          ? foodName.trim()
          : '',
      quantity: _parseQuantity(json['quantity']),
      cookingMethod: _parseCookingMethod(json['cookingMethod']),
    );
  }

  RecognizedQuantity _parseQuantity(Object? raw) {
    final map = raw as Map<String, Object?>? ?? const <String, Object?>{};
    final confidence = _parseConfidence(map['confidence']);
    final value = map['value'];
    return RecognizedQuantity(
      confidence: confidence,
      value: confidence == ReadingConfidence.unread
          ? null
          : (value is num ? value.toDouble() : null),
      unit: confidence == ReadingConfidence.unread
          ? null
          : map['unit'] as String?,
    );
  }

  RecognizedCookingMethod _parseCookingMethod(Object? raw) {
    final map = raw as Map<String, Object?>? ?? const <String, Object?>{};
    final confidence = _parseConfidence(map['confidence']);
    final value = map['value'];
    return RecognizedCookingMethod(
      confidence: confidence,
      value: confidence == ReadingConfidence.unread
          ? null
          : (value is String ? value : null),
    );
  }

  /// String yang tidak dikenal ATAU hilang dipetakan ke
  /// [ReadingConfidence.needsCheck], tidak pernah
  /// [ReadingConfidence.confident] — sama persis dengan
  /// `VisionProxyLabelProvider` (change 010).
  ReadingConfidence _parseConfidence(Object? raw) => switch (raw) {
    'confident' => ReadingConfidence.confident,
    'unread' => ReadingConfidence.unread,
    _ => ReadingConfidence.needsCheck,
  };
}
