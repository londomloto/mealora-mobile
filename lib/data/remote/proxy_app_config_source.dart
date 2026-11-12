import 'dart:async' show TimeoutException;
import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint, kDebugMode;
import 'package:http/http.dart' as http;
import 'package:mealora/data/remote/vision_proxy_label_provider.dart'
    show VisionProxyConfig;
import 'package:mealora/domain/app_update/app_update.dart';

/// Sumber konfigurasi versi lewat `mealora-model-proxy` (change 017, design
/// D3). Endpoint publik: tidak mengirim token, data pengguna, atau pengenal
/// perangkat apa pun. Setiap kegagalan menjadi null (fail-open).
final class ProxyAppConfigSource implements AppConfigSource {
  ProxyAppConfigSource({
    required this.config,
    http.Client? httpClient,
    this.timeout = const Duration(seconds: 3),
  }) : _httpClient = httpClient ?? http.Client();

  final VisionProxyConfig config;
  final http.Client _httpClient;
  final Duration timeout;

  @override
  Future<AppVersionConfig?> fetch() async {
    if (!config.isConfigured) return null;
    try {
      final response = await _httpClient
          .get(Uri.parse('${config.baseUrl}/app-config'))
          .timeout(timeout);
      if (response.statusCode != 200) return null;
      return AppVersionConfig.fromJson(jsonDecode(response.body));
    } on TimeoutException {
      return null;
    } on Object catch (error) {
      if (kDebugMode) {
        debugPrint('App config fetch failed: ${error.runtimeType}');
      }
      return null;
    }
  }
}
