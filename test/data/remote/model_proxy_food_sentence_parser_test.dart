import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mealora/data/remote/model_proxy_food_sentence_parser.dart';
import 'package:mealora/data/remote/vision_proxy_label_provider.dart'
    show VisionProxyConfig;
import 'package:mealora/domain/image_ai_access/label_service_failure.dart';
import 'package:mealora/domain/voice_input/fallback_food_sentence_parser.dart';
import 'package:mealora/domain/voice_input/food_sentence_parser.dart';
import 'package:mealora/domain/voice_input/mock_food_sentence_parser.dart';
import 'package:mealora/domain/voice_input/rule_based_food_sentence_parser.dart';

void main() {
  const config = VisionProxyConfig(baseUrl: 'http://proxy.test');

  ModelProxyFoodSentenceParser parserWith(
    Future<http.Response> Function(http.Request) handler,
  ) => ModelProxyFoodSentenceParser(
    config: config,
    httpClient: MockClient(handler),
  );

  group('ModelProxyFoodSentenceParser (change 012)', () {
    test(
      'hanya mengirim teks kalimat ke /parse-food-text (task 5.2)',
      () async {
        late http.Request sent;
        final parser = parserWith((request) async {
          sent = request;
          return http.Response(
            jsonEncode({'items': <Object>[], 'nonFoodRequests': <Object>[]}),
            200,
          );
        });

        await parser.parse('tempe dua');

        expect(sent.url.path, '/parse-food-text');
        expect(sent.headers['Content-Type'], contains('application/json'));
        expect(jsonDecode(sent.body), <String, String>{'text': 'tempe dua'});
      },
    );

    test('angka gizi dari model tidak pernah masuk ke komponen '
        '(task 5.4, 5.7)', () async {
      final parser = parserWith(
        (_) async => http.Response.bytes(
          utf8.encode(
            jsonEncode({
              'items': [
                {
                  'foodName': 'nasi goreng',
                  'quantity': 1,
                  'unit': 'piring',
                  'unitStatus': 'standard',
                  'calories': 650,
                  'energyKcal': 650,
                  'protein': 20,
                },
              ],
              'nonFoodRequests': <Object>[],
              'totalCalories': 650,
            }),
          ),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        ),
      );

      final outcome = await parser.parse('nasi goreng satu piring');
      final item = (outcome as FoodSentenceParsed).sentence.items.single;
      expect(item.foodName, 'nasi goreng');
      expect(item.quantity, 1);
      expect(item.unit, 'piring');
      // ParsedFoodItem tidak punya bidang gizi; nilai gizi hanya dari katalog.
      expect(outcome.sentence.source, ParseSource.service);
    });

    test('jumlah kosong tetap kosong dan status satuan tak dikenal menjadi '
        'tidak baku', () async {
      final parser = parserWith(
        (_) async => http.Response(
          jsonEncode({
            'items': [
              {'foodName': 'tempe', 'quantity': null, 'unitStatus': 'missing'},
              {'foodName': 'gula', 'quantity': 2, 'unit': 'sendok'},
            ],
            'nonFoodRequests': ['berat_badan'],
          }),
          200,
        ),
      );

      final outcome = await parser.parse('x') as FoodSentenceParsed;
      expect(outcome.sentence.items[0].quantity, isNull);
      expect(
        outcome.sentence.items[1].unitStatus,
        ParsedUnitStatus.nonstandard,
      );
      expect(outcome.sentence.nonFoodRequests, ['berat_badan']);
    });

    test('status HTTP dipetakan ke alasan yang dapat dimengerti '
        '(task 5.6)', () async {
      for (final (status, reason) in <(int, LabelServiceFailureReason)>[
        (429, LabelServiceFailureReason.quotaExceeded),
        (504, LabelServiceFailureReason.timeout),
        (502, LabelServiceFailureReason.refused),
      ]) {
        final outcome = await parserWith(
          (_) async => http.Response('{"error":"x"}', status),
        ).parse('tempe');
        expect(
          (outcome as FoodSentenceParseUnavailable).reason,
          reason,
          reason: '$status',
        );
      }
    });

    test(
      'kegagalan jaringan menjadi luring, respons rusak menjadi ditolak',
      () async {
        final offline = await parserWith(
          (_) async => throw http.ClientException('no route'),
        ).parse('tempe');
        expect(
          (offline as FoodSentenceParseUnavailable).reason,
          LabelServiceFailureReason.offline,
        );

        final broken = await parserWith(
          (_) async => http.Response('bukan json', 200),
        ).parse('tempe');
        expect(
          (broken as FoodSentenceParseUnavailable).reason,
          LabelServiceFailureReason.refused,
        );
      },
    );

    test('proksi belum dikonfigurasi dinyatakan luring', () async {
      final outcome = await ModelProxyFoodSentenceParser(
        config: const VisionProxyConfig(baseUrl: ''),
      ).parse('tempe');
      expect(
        (outcome as FoodSentenceParseUnavailable).reason,
        LabelServiceFailureReason.offline,
      );
    });
  });

  group('FallbackFoodSentenceParser (task 5.9)', () {
    test('layanan berhasil: hasil layanan dipakai', () async {
      const fromService = ParsedSentence(
        items: [
          ParsedFoodItem(
            foodName: 'tempe',
            unitStatus: ParsedUnitStatus.missing,
          ),
        ],
        source: ParseSource.service,
      );
      final parser = FallbackFoodSentenceParser(
        primary: MockFoodSentenceParser.returning(fromService),
        fallback: const RuleBasedFoodSentenceParser(),
      );
      final outcome = await parser.parse('tempe dua') as FoodSentenceParsed;
      expect(outcome.sentence.source, ParseSource.service);
    });

    test('layanan tidak tersedia: diurai di perangkat dan ditandai perlu '
        'diperiksa', () async {
      final parser = FallbackFoodSentenceParser(
        primary: MockFoodSentenceParser.failing(
          LabelServiceFailureReason.quotaExceeded,
        ),
        fallback: const RuleBasedFoodSentenceParser(),
      );
      final outcome = await parser.parse('tempe dua') as FoodSentenceParsed;
      expect(outcome.sentence.source, ParseSource.onDevice);
      expect(outcome.sentence.items.single.needsCheck, isTrue);
    });

    test(
      'perangkat pun tidak menemukan makanan: alasan layanan diteruskan',
      () async {
        final parser = FallbackFoodSentenceParser(
          primary: MockFoodSentenceParser.failing(
            LabelServiceFailureReason.offline,
          ),
          fallback: const RuleBasedFoodSentenceParser(),
        );
        final outcome = await parser.parse('buka pengaturan');
        expect(
          (outcome as FoodSentenceParseUnavailable).reason,
          LabelServiceFailureReason.offline,
        );
      },
    );
  });
}
