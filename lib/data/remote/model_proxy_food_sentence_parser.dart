import 'dart:async' show TimeoutException;
import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:mealora/data/remote/vision_proxy_label_provider.dart'
    show VisionProxyConfig;
import 'package:mealora/domain/image_ai_access/label_service_failure.dart';
import 'package:mealora/domain/voice_input/food_sentence_parser.dart';

/// Klien `mealora-model-proxy` untuk penguraian kalimat (change 012, design
/// D3, task 5.1) — dipagari `layer_rules_test.dart`, grup "kemandirian dari
/// jaringan".
///
/// Memakai ulang [VisionProxyConfig], batas permintaan, dan batas biaya
/// proksi apa adanya. Yang dikirim HANYA teks kalimat (task 5.2): tidak ada
/// audio, pengenal perangkat, profil, maupun kredensial penyedia model.
final class ModelProxyFoodSentenceParser implements FoodSentenceParser {
  ModelProxyFoodSentenceParser({
    required this.config,
    http.Client? httpClient,
    this.timeout = const Duration(seconds: 20),
  }) : _httpClient = httpClient ?? http.Client();

  final VisionProxyConfig config;
  final http.Client _httpClient;
  final Duration timeout;

  @override
  Future<FoodSentenceParseOutcome> parse(String sentence) async {
    if (!config.isConfigured) {
      return const FoodSentenceParseUnavailable(
        LabelServiceFailureReason.offline,
      );
    }

    final headers = <String, String>{
      'Content-Type': 'application/json; charset=utf-8',
    };
    final token = config.sharedToken;
    if (token != null && token.isNotEmpty) {
      headers['X-Proxy-Token'] = token;
    }

    final http.Response response;
    try {
      response = await _httpClient
          .post(
            Uri.parse('${config.baseUrl}/parse-food-text'),
            headers: headers,
            body: jsonEncode(<String, String>{'text': sentence}),
          )
          .timeout(timeout);
    } on TimeoutException {
      return const FoodSentenceParseUnavailable(
        LabelServiceFailureReason.timeout,
      );
    } on Object catch (error) {
      if (kDebugMode) {
        debugPrint('Model proxy transport error: ${error.runtimeType}');
      }
      return const FoodSentenceParseUnavailable(
        LabelServiceFailureReason.offline,
      );
    }

    if (response.statusCode != 200) {
      return FoodSentenceParseUnavailable(switch (response.statusCode) {
        429 => LabelServiceFailureReason.quotaExceeded,
        504 => LabelServiceFailureReason.timeout,
        _ => LabelServiceFailureReason.refused,
      });
    }

    try {
      return FoodSentenceParsed(
        parseFoodSentenceResponse(utf8.decode(response.bodyBytes)),
      );
    } on Object {
      return const FoodSentenceParseUnavailable(
        LabelServiceFailureReason.refused,
      );
    }
  }
}

/// Membaca respons proksi. Hanya `foodName`, `quantity`, `unit`, dan
/// `unitStatus` yang dibaca; bidang lain — termasuk angka gizi apa pun —
/// diabaikan (task 5.4).
ParsedSentence parseFoodSentenceResponse(String body) {
  final json = jsonDecode(body) as Map<String, Object?>;
  final rawItems = json['items'] as List<Object?>? ?? const <Object?>[];
  final items = <ParsedFoodItem>[];
  for (final raw in rawItems) {
    if (raw is! Map<String, Object?>) continue;
    final name = raw['foodName'];
    if (name is! String || name.trim().isEmpty) continue;
    final quantity = raw['quantity'];
    final unit = raw['unit'];
    items.add(
      ParsedFoodItem(
        foodName: name.trim(),
        quantity: quantity is num && quantity > 0 ? quantity.toDouble() : null,
        unit: unit is String && unit.trim().isNotEmpty ? unit.trim() : null,
        unitStatus: switch (raw['unitStatus']) {
          'standard' => ParsedUnitStatus.standard,
          'missing' => ParsedUnitStatus.missing,
          _ => ParsedUnitStatus.nonstandard,
        },
      ),
    );
  }
  final nonFood = json['nonFoodRequests'];
  return ParsedSentence(
    items: items,
    source: ParseSource.service,
    nonFoodRequests: nonFood is List
        ? nonFood.whereType<String>().toList(growable: false)
        : const <String>[],
  );
}
