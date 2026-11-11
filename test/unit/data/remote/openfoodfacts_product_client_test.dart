import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:mealora/data/remote/openfoodfacts_product_client.dart';
import 'package:mealora/domain/packaged_food/serving_basis.dart';

/// Uji klien Open Food Facts (task 4.1-4.2/4.6, change 009) — tanpa
/// jaringan sungguhan, lewat `MockClient` (`package:http/testing.dart`).
void main() {
  http.Response jsonResponse(
    Map<String, Object?> body, {
    int statusCode = 200,
  }) => http.Response(jsonEncode(body), statusCode);

  group('mengirim hanya nomor barcode (Design D3, task 4.2/8.4)', () {
    test('URL permintaan hanya memuat barcode dan daftar field, tanpa '
        'data lain', () async {
      Uri? requestedUri;
      Map<String, String>? requestedHeaders;
      final client = OpenFoodFactsProductClient(
        httpClient: MockClient((request) async {
          requestedUri = request.url;
          requestedHeaders = request.headers;
          return jsonResponse({'status': 0});
        }),
      );

      await client.lookupByBarcode('8991234567890');

      expect(requestedUri, isNotNull);
      expect(requestedUri!.host, 'world.openfoodfacts.org');
      expect(requestedUri!.path, '/api/v2/product/8991234567890.json');
      expect(
        requestedUri!.queryParameters.keys,
        equals(<String>['fields']),
        reason: 'tidak ada parameter selain daftar field yang diminta',
      );
      expect(
        requestedHeaders!['user-agent'],
        isNot(contains('Dart')),
        reason:
            'klien SHALL mengidentifikasi diri sendiri, bukan '
            'User-Agent bawaan pustaka HTTP',
      );
    });
  });

  group('produk ditemukan', () {
    test(
      'basis per sajian diparsing apa adanya dari sumber (task 3.4)',
      () async {
        final client = OpenFoodFactsProductClient(
          httpClient: MockClient(
            (request) async => jsonResponse({
              'status': 1,
              'product': {
                'code': '8991234567890',
                'product_name': 'Keripik Singkong Renyah',
                'brands': 'MerekA, MerekB',
                'quantity': '60 g',
                'product_quantity': 60,
                'serving_quantity': 30,
                'nutrition_data_per': 'serving',
                'nutriments': {
                  'energy-kcal_serving': 150,
                  'proteins_serving': 2,
                  'carbohydrates_serving': 18,
                  'fat_serving': 7,
                  'sodium_serving': 0.48,
                },
              },
            }),
          ),
        );

        final result = await client.lookupByBarcode('8991234567890');

        expect(result, isNotNull);
        expect(result!.name, 'Keripik Singkong Renyah');
        expect(result.brand, 'MerekA');
        expect(result.packageSize, '60 g');
        expect(result.servingBasis, ServingBasis.perServing);
        expect(result.servingSizeGrams, 30);
        expect(result.unitsPerPackage, 2);
        expect(result.nutritionAtRecordedBasis.energy?.kcal, 150);
        expect(result.nutritionAtRecordedBasis.proteinG, 2);
        expect(result.nutritionAtRecordedBasis.carbohydrateG, 18);
        expect(result.nutritionAtRecordedBasis.fatG, 7);
        expect(result.nutritionAtRecordedBasis.sodiumMg, closeTo(480, 1e-9));
        expect(result.sourceRef, '8991234567890');
      },
    );

    test('basis per 100 g diparsing apa adanya, bukan dikonversi di sini '
        '(Design D4)', () async {
      final client = OpenFoodFactsProductClient(
        httpClient: MockClient(
          (request) async => jsonResponse({
            'status': 1,
            'product': {
              'code': '89912340001',
              'product_name': 'Saus Sambal Botolan',
              'nutrition_data_per': '100g',
              'nutriments': {'energy-kcal_100g': 200, 'proteins_100g': 3},
            },
          }),
        ),
      );

      final result = await client.lookupByBarcode('89912340001');

      expect(result, isNotNull);
      expect(result!.servingBasis, ServingBasis.perHundredGrams);
      expect(result.unitsPerPackage, isNull);
      expect(result.servingSizeGrams, isNull);
      expect(result.nutritionAtRecordedBasis.energy?.kcal, 200);
      expect(result.nutritionAtRecordedBasis.proteinG, 3);
    });

    test('nilai yang tidak ada pada respons tetap belum diketahui, bukan '
        'nol (task 3.5)', () async {
      final client = OpenFoodFactsProductClient(
        httpClient: MockClient(
          (request) async => jsonResponse({
            'status': 1,
            'product': {
              'product_name': 'Produk Tanpa Lemak Tercatat',
              'nutrition_data_per': 'serving',
              'nutriments': {'energy-kcal_serving': 100},
            },
          }),
        ),
      );

      final result = await client.lookupByBarcode('12345678');

      expect(result, isNotNull);
      expect(result!.nutritionAtRecordedBasis.fatG, isNull);
      expect(result.nutritionAtRecordedBasis.fiberG, isNull);
    });
  });

  group('gagal, lambat, atau ditolak diperlakukan sama: belum ditemukan '
      '(task 4.6)', () {
    test('status produk 0 (tidak ditemukan pada sumber) → null', () async {
      final client = OpenFoodFactsProductClient(
        httpClient: MockClient((request) async => jsonResponse({'status': 0})),
      );

      expect(await client.lookupByBarcode('00000000'), isNull);
    });

    test('kode status HTTP bukan 200 → null, tidak melempar', () async {
      final client = OpenFoodFactsProductClient(
        httpClient: MockClient(
          (request) async => http.Response('Service Unavailable', 503),
        ),
      );

      expect(await client.lookupByBarcode('00000000'), isNull);
    });

    test('respons JSON tidak terduga → null, tidak melempar', () async {
      final client = OpenFoodFactsProductClient(
        httpClient: MockClient(
          (request) async => http.Response('bukan json', 200),
        ),
      );

      expect(await client.lookupByBarcode('00000000'), isNull);
    });

    test('permintaan melewati batas waktu → null, tidak melempar', () async {
      final client = OpenFoodFactsProductClient(
        timeout: const Duration(milliseconds: 20),
        httpClient: MockClient((request) async {
          await Future<void>.delayed(const Duration(milliseconds: 200));
          return jsonResponse({'status': 0});
        }),
      );

      expect(await client.lookupByBarcode('00000000'), isNull);
    });

    test('koneksi melempar pengecualian → null, tidak melempar', () async {
      final client = OpenFoodFactsProductClient(
        httpClient: MockClient((request) async {
          throw const SocketExceptionStub();
        }),
      );

      expect(await client.lookupByBarcode('00000000'), isNull);
    });
  });
}

/// Tiruan ringan pengecualian jaringan — tidak memerlukan `dart:io` pada
/// berkas uji (menghormati batas arsitektur yang sama dengan kode aplikasi).
final class SocketExceptionStub implements Exception {
  const SocketExceptionStub();
}
