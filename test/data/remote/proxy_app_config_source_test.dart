import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mealora/data/remote/proxy_app_config_source.dart';
import 'package:mealora/data/remote/vision_proxy_label_provider.dart';

const String _body =
    '{"latestVersion":"1.2.0","minSupportedVersion":"1.0.0",'
    '"releaseNotes":"x","storeUrl":{"android":"https://p","ios":""}}';

ProxyAppConfigSource _source(
  MockClientHandler handler, {
  String baseUrl = 'http://proxy',
}) => ProxyAppConfigSource(
  config: VisionProxyConfig(baseUrl: baseUrl, sharedToken: 'tok'),
  httpClient: MockClient(handler),
  timeout: const Duration(milliseconds: 50),
);

/// change 017-app-update-check, task 2.5.
void main() {
  test('sukses: GET /app-config tanpa token', () async {
    late http.Request seen;
    final result = await _source((req) async {
      seen = req;
      return http.Response(_body, 200);
    }).fetch();
    expect(result!.latestVersion.toString(), '1.2.0');
    expect(seen.method, 'GET');
    expect(seen.url.path, '/app-config');
    expect(seen.headers.containsKey('X-Proxy-Token'), isFalse);
  });

  test('tidak dikonfigurasi: null tanpa request', () async {
    var called = false;
    final result = await _source((_) async {
      called = true;
      return http.Response(_body, 200);
    }, baseUrl: '').fetch();
    expect(result, isNull);
    expect(called, isFalse);
  });

  test('timeout, 500, 404, JSON rusak, error jaringan: null', () async {
    final handlers = <MockClientHandler>[
      (_) => Completer<http.Response>().future,
      (_) async => http.Response('{}', 500),
      (_) async => http.Response('{"error":"APP_CONFIG_UNSET"}', 404),
      (_) async => http.Response('not json', 200),
      (_) async => http.Response('{"latestVersion":"1.2"}', 200),
      (_) async => throw http.ClientException('offline'),
    ];
    for (final handler in handlers) {
      expect(await _source(handler).fetch(), isNull);
    }
  });
}
