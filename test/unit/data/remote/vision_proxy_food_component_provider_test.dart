import 'dart:convert';
import 'dart:typed_data' show Uint8List;

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mealora/data/remote/vision_proxy_food_component_provider.dart';
import 'package:mealora/data/remote/vision_proxy_label_provider.dart'
    show VisionProxyConfig;
import 'package:mealora/domain/food_photo_input/food_component_recognition_provider.dart';
import 'package:mealora/domain/image_ai_access/label_service_failure.dart';
import 'package:mealora/domain/image_ai_access/reading_confidence.dart';

const _fixtureBody = {
  'components': [
    {
      'foodName': 'Nasi putih',
      'quantity': {'value': 150, 'unit': 'g', 'confidence': 'confident'},
      'cookingMethod': {'confidence': 'unread'},
    },
    {
      'foodName': 'Tempe goreng',
      'quantity': {'value': 2, 'unit': 'potong', 'confidence': 'needs_check'},
      'cookingMethod': {'value': 'digoreng', 'confidence': 'needs_check'},
    },
  ],
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
        final provider = VisionProxyFoodComponentProvider(
          config: const VisionProxyConfig(baseUrl: ''),
          httpClient: MockClient.streaming((request, bodyStream) async {
            called = true;
            return _streamed('{}');
          }),
        );

        final outcome = await provider.recognizeComponents(
          Uint8List.fromList([1]),
        );

        expect(called, isFalse);
        expect(outcome, isA<FoodComponentRecognitionServiceUnavailable>());
        expect(
          (outcome as FoodComponentRecognitionServiceUnavailable).reason,
          LabelServiceFailureReason.offline,
        );
      },
    );
  });

  group('respons 200', () {
    test(
      'diparsing menjadi FoodPhotoRecognition sesuai skema proksi',
      () async {
        final provider = VisionProxyFoodComponentProvider(
          config: const VisionProxyConfig(baseUrl: 'https://proxy.example'),
          httpClient: MockClient.streaming(
            (request, bodyStream) async => _streamed(jsonEncode(_fixtureBody)),
          ),
        );

        final outcome = await provider.recognizeComponents(
          Uint8List.fromList([1]),
        );

        expect(outcome, isA<FoodComponentRecognitionRead>());
        final recognition =
            (outcome as FoodComponentRecognitionRead).recognition;
        expect(recognition.components, hasLength(2));

        final rice = recognition.components[0];
        expect(rice.foodNameGuess, 'Nasi putih');
        expect(rice.quantity.value, 150);
        expect(rice.quantity.confidence, ReadingConfidence.confident);
        expect(rice.cookingMethod.confidence, ReadingConfidence.unread);
        expect(
          rice.cookingMethod.value,
          isNull,
          reason: 'unread SHALL TIDAK membawa value — tidak pernah ditebak',
        );

        final tempe = recognition.components[1];
        expect(tempe.cookingMethod.value, 'digoreng');
        expect(tempe.cookingMethod.confidence, ReadingConfidence.needsCheck);
      },
    );

    test('bentuk tak terduga dipetakan ke refused, bukan dilempar', () async {
      final provider = VisionProxyFoodComponentProvider(
        config: const VisionProxyConfig(baseUrl: 'https://proxy.example'),
        httpClient: MockClient.streaming(
          (request, bodyStream) async => _streamed('not json at all'),
        ),
      );

      final outcome = await provider.recognizeComponents(
        Uint8List.fromList([1]),
      );

      expect(outcome, isA<FoodComponentRecognitionServiceUnavailable>());
      expect(
        (outcome as FoodComponentRecognitionServiceUnavailable).reason,
        LabelServiceFailureReason.refused,
      );
    });
  });

  group('kode status proksi', () {
    Future<FoodComponentRecognitionOutcome> outcomeFor(int statusCode) {
      final provider = VisionProxyFoodComponentProvider(
        config: const VisionProxyConfig(baseUrl: 'https://proxy.example'),
        httpClient: MockClient.streaming(
          (request, bodyStream) async =>
              _streamed(jsonEncode({'error': 'x'}), statusCode: statusCode),
        ),
      );
      return provider.recognizeComponents(Uint8List.fromList([1]));
    }

    test('429 -> quotaExceeded', () async {
      final outcome = await outcomeFor(429);
      expect(
        (outcome as FoodComponentRecognitionServiceUnavailable).reason,
        LabelServiceFailureReason.quotaExceeded,
      );
    });

    test('504 -> timeout', () async {
      final outcome = await outcomeFor(504);
      expect(
        (outcome as FoodComponentRecognitionServiceUnavailable).reason,
        LabelServiceFailureReason.timeout,
      );
    });
  });

  test(
    'foto dikirim sebagai bita gambar saja, bukan JSON dengan metadata',
    () async {
      http.MultipartRequest? captured;
      final provider = VisionProxyFoodComponentProvider(
        config: const VisionProxyConfig(baseUrl: 'https://proxy.example'),
        httpClient: MockClient.streaming((request, bodyStream) async {
          captured = request as http.MultipartRequest;
          return _streamed(jsonEncode(_fixtureBody));
        }),
      );

      await provider.recognizeComponents(Uint8List.fromList([1, 2, 3]));

      expect(captured!.files.single.contentType.mimeType, 'image/jpeg');
      expect(captured!.fields, isEmpty);
    },
  );
}
