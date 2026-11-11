import 'dart:async' show TimeoutException;
import 'dart:convert';
import 'dart:typed_data' show Uint8List;

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' show MediaType;
import 'package:mealora/domain/image_ai_access/label_extraction.dart';
import 'package:mealora/domain/image_ai_access/label_service_failure.dart';
import 'package:mealora/domain/image_ai_access/nutrition_label_provider.dart';
import 'package:mealora/domain/image_ai_access/reading_confidence.dart';

/// Konfigurasi proksi inferensi (`mealora-apps/mealora-model-proxy`) —
/// dibaca dari waktu build, TIDAK PERNAH memuat kredensial penyedia model
/// (Design D2, task 3.2): hanya alamat proksi dan token level-aplikasi
/// opsional yang bukan kredensial penyedia (`docs/inference-proxy.md` §4).
final class VisionProxyConfig {
  const VisionProxyConfig({required this.baseUrl, this.sharedToken});

  /// Dibaca dari `--dart-define=MEALORA_VISION_PROXY_BASE_URL=...` saat
  /// build. Kosong berarti proksi belum dikonfigurasi pada build ini —
  /// klien memperlakukannya sebagai layanan tidak tersedia, BUKAN
  /// pengecualian tak tertangani, sehingga jalur manual tetap satu-satunya
  /// yang bekerja pada build yang belum menunjuk ke proksi mana pun (spec
  /// image-ai-access, "Jalur tanpa koneksi selalu tersedia").
  static const VisionProxyConfig fromEnvironment = VisionProxyConfig(
    baseUrl: String.fromEnvironment('MEALORA_VISION_PROXY_BASE_URL'),
    sharedToken: String.fromEnvironment('MEALORA_VISION_PROXY_TOKEN'),
  );

  final String baseUrl;
  final String? sharedToken;

  bool get isConfigured => baseUrl.isNotEmpty;
}

/// Klien `mealora-model-proxy` (change 010, Design D2) — SATU DARI DUA
/// berkas di aplikasi yang boleh memakai `package:http`, bersama
/// `OpenFoodFactsProductClient` (change 009); dipagari oleh
/// `test/unit/architecture/layer_rules_test.dart`, grup "kemandirian dari
/// jaringan".
///
/// Mengirim HANYA bita gambar label (task 3.2) — tidak ada pengenal
/// perangkat, profil, maupun kredensial penyedia model yang ikut terkirim;
/// kredensial penyedia tetap di server proksi (`docs/inference-proxy.md`).
final class VisionProxyLabelProvider implements NutritionLabelProvider {
  VisionProxyLabelProvider({
    required this.config,
    http.Client? httpClient,
    this.timeout = const Duration(seconds: 55),
  }) : _httpClient = httpClient ?? http.Client();

  final VisionProxyConfig config;
  final http.Client _httpClient;
  final Duration timeout;

  @override
  Future<LabelExtractionOutcome> extractLabel(Uint8List imageBytes) async {
    if (!config.isConfigured) {
      return const LabelExtractionServiceUnavailable(
        LabelServiceFailureReason.offline,
      );
    }

    final uri = Uri.parse('${config.baseUrl}/extract-label');
    if (kDebugMode) {
      debugPrint('Vision proxy request: $uri (${imageBytes.length} bytes)');
    }
    final request = http.MultipartRequest('POST', uri)
      ..files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: 'label.jpg',
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
      return const LabelExtractionServiceUnavailable(
        LabelServiceFailureReason.timeout,
      );
    } on Object catch (error) {
      if (kDebugMode) {
        debugPrint('Vision proxy transport error: $error');
      }
      // Jaringan tidak terjangkau, DNS gagal, atau koneksi ditolak —
      // seluruhnya diperlakukan sebagai luring (task 4.6, pola yang sama
      // dengan `OpenFoodFactsProductClient`, change 009): pemanggil SHALL
      // TIDAK pernah menerima exception mentah dari klien ini.
      return const LabelExtractionServiceUnavailable(
        LabelServiceFailureReason.offline,
      );
    }

    final response = await http.Response.fromStream(streamed);
    if (kDebugMode) {
      debugPrint('Vision proxy response: ${response.statusCode}');
    }
    if (response.statusCode != 200) {
      return LabelExtractionServiceUnavailable(
        _reasonForStatus(response.statusCode),
      );
    }

    try {
      return LabelExtractionRead(_parseExtraction(response.body));
    } on Object {
      // Respons 200 tapi bentuknya tak terduga — penyedia/proksi dianggap
      // menolak permintaan ini, bukan ditebak isinya (Design D6/D8).
      return const LabelExtractionServiceUnavailable(
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

  LabelExtraction _parseExtraction(String body) {
    final json = jsonDecode(body) as Map<String, Object?>;
    return LabelExtraction(
      basis: _parseBasis(json['basis']),
      servingSize: _parseNumber(json['servingSize']),
      servingsPerPackage: _parseNumber(json['servingsPerPackage']),
      energyKcal: _parseNumber(json['energyKcal']),
      protein: _parseNumber(json['proteinGrams']),
      carbohydrate: _parseNumber(json['carbohydrateGrams']),
      fat: _parseNumber(json['fatGrams']),
    );
  }

  ExtractedBasis _parseBasis(Object? raw) {
    final map = raw as Map<String, Object?>? ?? const <String, Object?>{};
    final kind = switch (map['kind']) {
      'per_serving' => ExtractedBasisKind.perServing,
      'per_100g' => ExtractedBasisKind.perHundredGrams,
      _ => ExtractedBasisKind.unread,
    };
    return ExtractedBasis(
      kind: kind,
      confidence: _parseConfidence(map['confidence']),
    );
  }

  ExtractedNumber _parseNumber(Object? raw) {
    final map = raw as Map<String, Object?>? ?? const <String, Object?>{};
    final confidence = _parseConfidence(map['confidence']);
    final value = map['value'];
    return ExtractedNumber(
      confidence: confidence,
      value: confidence == ReadingConfidence.unread
          ? null
          : (value is num ? value.toDouble() : null),
      unit: confidence == ReadingConfidence.unread
          ? null
          : map['unit'] as String?,
    );
  }

  /// String yang tidak dikenal ATAU hilang dipetakan ke
  /// [ReadingConfidence.needsCheck], tidak pernah
  /// [ReadingConfidence.confident] — keyakinan penuh SHALL hanya datang
  /// dari provider yang secara eksplisit menyatakannya (Design D6, spec
  /// "Satuan ambigu").
  ReadingConfidence _parseConfidence(Object? raw) => switch (raw) {
    'confident' => ReadingConfidence.confident,
    'unread' => ReadingConfidence.unread,
    // 'needs_check' (lihat mealora-model-proxy/src/schema.js
    // CONFIDENCE_ENUM) jatuh ke sini bersama string tak dikenal/hilang.
    _ => ReadingConfidence.needsCheck,
  };
}
