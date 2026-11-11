import 'dart:convert';
import 'dart:typed_data' show Uint8List;

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:http_parser/http_parser.dart' show MediaType;
import 'package:mealora/data/remote/vision_proxy_label_provider.dart';
import 'package:mealora/domain/image_ai_access/label_service_failure.dart';
import 'package:mealora/domain/image_ai_access/nutrition_label_provider.dart';
import 'package:mealora/domain/image_ai_access/reading_confidence.dart';

const _fixtureBody = {
  'basis': {'kind': 'per_serving', 'confidence': 'confident'},
  'servingSize': {'value': 30, 'unit': 'g', 'confidence': 'confident'},
  'servingsPerPackage': {'value': 2, 'confidence': 'confident'},
  'energyKcal': {'value': 150, 'unit': 'kkal', 'confidence': 'confident'},
  'proteinGrams': {'value': 2, 'unit': 'g', 'confidence': 'needs_check'},
  'carbohydrateGrams': {'value': 18, 'unit': 'g', 'confidence': 'confident'},
  'fatGrams': {'confidence': 'unread'},
};

http.StreamedResponse _streamed(String body, {int statusCode = 200}) {
  final bytes = utf8.encode(body);
  return http.StreamedResponse(Stream<List<int>>.value(bytes), statusCode);
}

void main() {
  group('konfigurasi belum ada (build tanpa proxy)', () {
    test(
      'langsung ServiceUnavailable(offline) tanpa panggilan jaringan',
      () async {
        var called = false;
        final provider = VisionProxyLabelProvider(
          config: const VisionProxyConfig(baseUrl: ''),
          httpClient: MockClient.streaming((request, bodyStream) async {
            called = true;
            return _streamed('{}');
          }),
        );

        final outcome = await provider.extractLabel(Uint8List.fromList([1]));

        expect(called, isFalse);
        expect(outcome, isA<LabelExtractionServiceUnavailable>());
        expect(
          (outcome as LabelExtractionServiceUnavailable).reason,
          LabelServiceFailureReason.offline,
        );
      },
    );
  });

  group('respons 200', () {
    test('diparsing menjadi LabelExtraction sesuai skema proksi', () async {
      final provider = VisionProxyLabelProvider(
        config: const VisionProxyConfig(baseUrl: 'https://proxy.example'),
        httpClient: MockClient.streaming(
          (request, bodyStream) async => _streamed(jsonEncode(_fixtureBody)),
        ),
      );

      final outcome = await provider.extractLabel(Uint8List.fromList([1]));

      expect(outcome, isA<LabelExtractionRead>());
      final extraction = (outcome as LabelExtractionRead).extraction;
      expect(extraction.servingSize.value, 30);
      expect(extraction.servingsPerPackage.value, 2);
      expect(extraction.energyKcal.value, 150);
      expect(
        extraction.protein.confidence,
        ReadingConfidence.needsCheck,
        reason: 'needs_check (snake_case dari proxy) SHALL terpetakan benar',
      );
      expect(extraction.fat.confidence, ReadingConfidence.unread);
      expect(
        extraction.fat.value,
        isNull,
        reason: 'unread SHALL TIDAK membawa value — tidak pernah nol',
      );
    });

    test('bentuk tak terduga dipetakan ke refused, bukan dilempar', () async {
      final provider = VisionProxyLabelProvider(
        config: const VisionProxyConfig(baseUrl: 'https://proxy.example'),
        httpClient: MockClient.streaming(
          (request, bodyStream) async => _streamed('not json at all'),
        ),
      );

      final outcome = await provider.extractLabel(Uint8List.fromList([1]));

      expect(outcome, isA<LabelExtractionServiceUnavailable>());
      expect(
        (outcome as LabelExtractionServiceUnavailable).reason,
        LabelServiceFailureReason.refused,
      );
    });
  });

  group('kode status proksi (docs/inference-proxy.md)', () {
    Future<LabelExtractionOutcome> outcomeFor(int statusCode) {
      final provider = VisionProxyLabelProvider(
        config: const VisionProxyConfig(baseUrl: 'https://proxy.example'),
        httpClient: MockClient.streaming(
          (request, bodyStream) async =>
              _streamed(jsonEncode({'error': 'x'}), statusCode: statusCode),
        ),
      );
      return provider.extractLabel(Uint8List.fromList([1]));
    }

    test('429 -> quotaExceeded', () async {
      final outcome = await outcomeFor(429);
      expect(
        (outcome as LabelExtractionServiceUnavailable).reason,
        LabelServiceFailureReason.quotaExceeded,
      );
    });

    test('504 -> timeout', () async {
      final outcome = await outcomeFor(504);
      expect(
        (outcome as LabelExtractionServiceUnavailable).reason,
        LabelServiceFailureReason.timeout,
      );
    });

    test('502 -> refused', () async {
      final outcome = await outcomeFor(502);
      expect(
        (outcome as LabelExtractionServiceUnavailable).reason,
        LabelServiceFailureReason.refused,
      );
    });
  });

  test(
    'token bersama dikirim sebagai header X-Proxy-Token ketika diisi',
    () async {
      Map<String, String>? capturedHeaders;
      final provider = VisionProxyLabelProvider(
        config: const VisionProxyConfig(
          baseUrl: 'https://proxy.example',
          sharedToken: 'secret-app-token',
        ),
        httpClient: MockClient.streaming((request, bodyStream) async {
          capturedHeaders = request.headers;
          return _streamed(jsonEncode(_fixtureBody));
        }),
      );

      await provider.extractLabel(Uint8List.fromList([1]));

      expect(capturedHeaders!['X-Proxy-Token'], 'secret-app-token');
    },
  );

  test('foto dikirim sebagai image/jpeg, bukan octet-stream', () async {
    MediaType? capturedContentType;
    final provider = VisionProxyLabelProvider(
      config: const VisionProxyConfig(baseUrl: 'https://proxy.example'),
      httpClient: MockClient.streaming((request, bodyStream) async {
        capturedContentType =
            (request as http.MultipartRequest).files.single.contentType;
        return _streamed(jsonEncode(_fixtureBody));
      }),
    );

    await provider.extractLabel(Uint8List.fromList([1, 2, 3]));

    expect(capturedContentType?.mimeType, 'image/jpeg');
  });
}
