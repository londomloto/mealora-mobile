import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mealora/data/remote/model_proxy_nutrition_reader.dart';
import 'package:mealora/data/remote/vision_proxy_label_provider.dart'
    show VisionProxyConfig;
import 'package:mealora/domain/image_ai_access/label_service_failure.dart';
import 'package:mealora/domain/nutrition_import/nutrition_import.dart';
import 'package:mealora/domain/nutrition_import/nutrition_reading.dart';

const Map<String, Object?> _body = <String, Object?>{
  'sourceKind': 'general',
  'basis': {'kind': 'per_100g', 'amount': 100, 'unit': 'g'},
  'energyKcal': {'min': 214, 'max': 252, 'status': 'range'},
  'proteinGrams': {'status': 'unread'},
  'carbohydrateGrams': {'status': 'unread'},
  'fatGrams': {'min': 15, 'max': 15, 'status': 'read'},
  'ignoredNutrients': <String>[],
};

void main() {
  const config = VisionProxyConfig(
    baseUrl: 'http://proxy.test',
    sharedToken: 'tok',
  );

  ModelProxyNutritionReader readerWith(
    Future<http.Response> Function(http.Request) handler,
  ) => ModelProxyNutritionReader(
    config: config,
    httpClient: MockClient(handler),
  );

  group('ModelProxyNutritionReader (change 020)', () {
    test('readText hanya mengirim teks ke /parse-nutrition-text', () async {
      late http.Request sent;
      final reader = readerWith((request) async {
        sent = request;
        return http.Response(jsonEncode(_body), 200);
      });

      final out = await reader.readText('  Kalori 214–252 kkal  ');

      expect(sent.url.path, '/parse-nutrition-text');
      expect(sent.headers['X-Proxy-Token'], 'tok');
      expect(jsonDecode(sent.body), {'text': 'Kalori 214–252 kkal'});
      final success = out as NutritionReadSuccess;
      expect(success.tier, ReadingTier.text);
      expect(success.reading.energyKcal.proposed, 233);
    });

    test('teks kosong atau lebih dari 4000 tidak dikirim', () async {
      var calls = 0;
      final reader = readerWith((_) async {
        calls++;
        return http.Response('{}', 200);
      });

      expect(await reader.readText('  '), isA<NutritionReadUnavailable>());
      expect(
        await reader.readText('a' * (maxNutritionTextChars + 1)),
        isA<NutritionReadUnavailable>(),
      );
      expect(calls, 0);
    });

    test('readImage mengirim multipart ke /read-nutrition-image', () async {
      late http.Request sent;
      final reader = readerWith((request) async {
        sent = request;
        return http.Response(jsonEncode(_body), 200);
      });

      final out = await reader.readImage(Uint8List.fromList(<int>[1, 2, 3]));

      expect(sent.url.path, '/read-nutrition-image');
      expect(sent.headers['content-type'], startsWith('multipart/form-data'));
      expect((out as NutritionReadSuccess).tier, ReadingTier.vision);
    });

    test('status HTTP dipetakan ke alasan kegagalan', () async {
      Future<LabelServiceFailureReason> reasonFor(int status) async {
        final out = await readerWith(
          (_) async => http.Response('{}', status),
        ).readText('x');
        return (out as NutritionReadUnavailable).reason;
      }

      expect(await reasonFor(429), LabelServiceFailureReason.quotaExceeded);
      expect(await reasonFor(504), LabelServiceFailureReason.timeout);
      expect(await reasonFor(502), LabelServiceFailureReason.refused);
    });

    test('respons bukan JSON objek → refused', () async {
      final out = await readerWith(
        (_) async => http.Response('[1]', 200),
      ).readText('x');
      expect(
        (out as NutritionReadUnavailable).reason,
        LabelServiceFailureReason.refused,
      );
    });

    test('kesalahan transport → offline', () async {
      final out = await readerWith(
        (_) async => throw http.ClientException('down'),
      ).readText('x');
      expect(
        (out as NutritionReadUnavailable).reason,
        LabelServiceFailureReason.offline,
      );
    });

    test('proksi belum dikonfigurasi → offline tanpa permintaan', () async {
      final reader = ModelProxyNutritionReader(
        config: const VisionProxyConfig(baseUrl: ''),
        httpClient: MockClient((_) async => fail('tidak boleh dipanggil')),
      );
      final out = await reader.readText('x');
      expect(
        (out as NutritionReadUnavailable).reason,
        LabelServiceFailureReason.offline,
      );
    });
  });
}
