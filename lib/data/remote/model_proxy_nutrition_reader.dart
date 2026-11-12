import 'dart:async' show TimeoutException;
import 'dart:convert';
import 'dart:typed_data' show Uint8List;

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' show MediaType;
import 'package:mealora/data/remote/vision_proxy_label_provider.dart'
    show VisionProxyConfig;
import 'package:mealora/domain/image_ai_access/label_service_failure.dart';
import 'package:mealora/domain/nutrition_import/nutrition_import.dart';
import 'package:mealora/domain/nutrition_import/nutrition_reading.dart';

/// Klien `mealora-model-proxy` untuk baca info gizi (change 020, design
/// D2/D5): `/parse-nutrition-text` (hanya teks) dan `/read-nutrition-image`
/// (hanya bita gambar, dipanggil hanya dengan izin unggah). Dipagari
/// `layer_rules_test.dart`, grup "kemandirian dari jaringan".
///
/// Tidak ada pengenal perangkat, profil, maupun kredensial penyedia model
/// yang ikut terkirim.
final class ModelProxyNutritionReader
    implements NutritionTextReader, NutritionImageReader {
  ModelProxyNutritionReader({
    required this.config,
    http.Client? httpClient,
    this.textTimeout = const Duration(seconds: 20),
    this.imageTimeout = const Duration(seconds: 55),
  }) : _httpClient = httpClient ?? http.Client();

  final VisionProxyConfig config;
  final http.Client _httpClient;
  final Duration textTimeout;
  final Duration imageTimeout;

  Map<String, String> get _tokenHeader {
    final token = config.sharedToken;
    return token != null && token.isNotEmpty
        ? <String, String>{'X-Proxy-Token': token}
        : const <String, String>{};
  }

  @override
  Future<NutritionReadOutcome> readText(String text) {
    final trimmed = text.trim();
    if (trimmed.isEmpty || trimmed.length > maxNutritionTextChars) {
      return Future<NutritionReadOutcome>.value(
        const NutritionReadUnavailable(LabelServiceFailureReason.refused),
      );
    }
    return _send(
      ReadingTier.text,
      textTimeout,
      () => _httpClient.post(
        Uri.parse('${config.baseUrl}/parse-nutrition-text'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=utf-8',
          ..._tokenHeader,
        },
        body: jsonEncode(<String, String>{'text': trimmed}),
      ),
    );
  }

  @override
  Future<NutritionReadOutcome> readImage(Uint8List imageBytes) {
    return _send(ReadingTier.vision, imageTimeout, () async {
      final request =
          http.MultipartRequest(
              'POST',
              Uri.parse('${config.baseUrl}/read-nutrition-image'),
            )
            ..headers.addAll(_tokenHeader)
            ..files.add(
              http.MultipartFile.fromBytes(
                'image',
                imageBytes,
                filename: 'info-gizi.jpg',
                contentType: MediaType('image', 'jpeg'),
              ),
            );
      return http.Response.fromStream(await _httpClient.send(request));
    });
  }

  Future<NutritionReadOutcome> _send(
    ReadingTier tier,
    Duration timeout,
    Future<http.Response> Function() request,
  ) async {
    if (!config.isConfigured) {
      return const NutritionReadUnavailable(LabelServiceFailureReason.offline);
    }

    final http.Response response;
    try {
      response = await request().timeout(timeout);
    } on TimeoutException {
      return const NutritionReadUnavailable(LabelServiceFailureReason.timeout);
    } on Object catch (error) {
      if (kDebugMode) {
        debugPrint('Model proxy transport error: ${error.runtimeType}');
      }
      return const NutritionReadUnavailable(LabelServiceFailureReason.offline);
    }

    if (response.statusCode != 200) {
      return NutritionReadUnavailable(switch (response.statusCode) {
        429 => LabelServiceFailureReason.quotaExceeded,
        504 => LabelServiceFailureReason.timeout,
        _ => LabelServiceFailureReason.refused,
      });
    }

    try {
      return NutritionReadSuccess(
        NutritionReading.fromJson(jsonDecode(utf8.decode(response.bodyBytes))),
        tier,
      );
    } on Object {
      return const NutritionReadUnavailable(LabelServiceFailureReason.refused);
    }
  }
}
