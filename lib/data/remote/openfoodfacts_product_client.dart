import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:mealora/domain/food/nutrition_profile.dart';
import 'package:mealora/domain/packaged_food/product_data_source_client.dart';
import 'package:mealora/domain/packaged_food/serving_basis.dart';
import 'package:mealora/domain/shared/units.dart';

/// Klien Open Food Facts (change 009, Design D2).
///
/// SATU-SATUNYA berkas di aplikasi yang boleh memakai `package:http` —
/// dipagari oleh `test/unit/architecture/layer_rules_test.dart`, grup
/// "kemandirian dari jaringan". Mengirim HANYA nomor barcode pada setiap
/// permintaan (Design D3): tidak ada gambar, pengenal perangkat, atau data
/// profil pengguna yang ikut terkirim.
///
/// Kewajiban atribusi ODbL dipenuhi di layar yang MEMAKAI hasil klien ini
/// (layar tinjau produk), bukan di sini — lihat
/// `mealora-plans/docs/packaged-food-sources.md` §2.
final class OpenFoodFactsProductClient implements ProductDataSourceClient {
  OpenFoodFactsProductClient({
    http.Client? httpClient,
    this.timeout = const Duration(seconds: 6),
  }) : _httpClient = httpClient ?? http.Client();

  final http.Client _httpClient;
  final Duration timeout;

  /// Etiket pemakaian API Open Food Facts: klien SHALL mengidentifikasi
  /// dirinya, bukan memakai User-Agent bawaan pustaka HTTP.
  static const _userAgent = 'Mealora/1.0 (+https://mealora.app)';

  static const _fields =
      'code,product_name,brands,quantity,product_quantity,'
      'serving_quantity,nutrition_data_per,nutriments,last_modified_t';

  @override
  Future<RemoteProductLookup?> lookupByBarcode(String barcode) async {
    final uri = Uri.https(
      'world.openfoodfacts.org',
      '/api/v2/product/$barcode.json',
      <String, String>{'fields': _fields},
    );

    try {
      final response = await _httpClient
          .get(uri, headers: const <String, String>{'User-Agent': _userAgent})
          .timeout(timeout);
      if (response.statusCode != 200) {
        return null;
      }
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, Object?> || decoded['status'] != 1) {
        return null;
      }
      final product = decoded['product'];
      if (product is! Map<String, Object?>) {
        return null;
      }
      return _parseProduct(product);
    } on Object {
      // Gagal (jaringan, format respons tak terduga), lambat (melewati
      // [timeout]), atau ditolak (status bukan 200) — ketiganya diperlakukan
      // sama: produk belum ditemukan daring (task 4.6). Repositori jatuh
      // kembali ke "tidak ditemukan", jalur luring tidak pernah terganggu.
      return null;
    }
  }

  RemoteProductLookup? _parseProduct(Map<String, Object?> product) {
    final name = _trimmedOrNull(product['product_name']);
    if (name == null) {
      return null;
    }

    final nutriments = product['nutriments'];
    final nutrimentsMap = nutriments is Map<String, Object?>
        ? nutriments
        : const <String, Object?>{};

    final basis = product['nutrition_data_per'] == '100g'
        ? ServingBasis.perHundredGrams
        : ServingBasis.perServing;
    final suffix = basis == ServingBasis.perHundredGrams ? '_100g' : '_serving';

    double? numberAt(String key) {
      final value = nutrimentsMap[key];
      if (value is num) {
        return value.toDouble();
      }
      if (value is String) {
        return double.tryParse(value);
      }
      return null;
    }

    final energyKcal = numberAt('energy-kcal$suffix');
    final servingGrams = _asDouble(product['serving_quantity']);

    return RemoteProductLookup(
      name: name,
      brand: _firstBrand(product['brands']),
      packageSize: _trimmedOrNull(product['quantity']),
      servingSizeGrams: basis == ServingBasis.perServing ? servingGrams : null,
      unitsPerPackage: basis == ServingBasis.perServing
          ? _unitsPerPackage(
              packageGrams: _asDouble(product['product_quantity']),
              servingGrams: servingGrams,
            )
          : null,
      servingBasis: basis,
      nutritionAtRecordedBasis: NutritionProfile(
        energy: energyKcal == null
            ? null
            : Energy.kcalValue(energyKcal, field: 'energyKcal').valueOrNull,
        proteinG: numberAt('proteins$suffix'),
        carbohydrateG: numberAt('carbohydrates$suffix'),
        fatG: numberAt('fat$suffix'),
        fiberG: numberAt('fiber$suffix'),
        sugarG: numberAt('sugars$suffix'),
        sodiumMg: _sodiumMgAt(nutrimentsMap, suffix),
      ),
      sourceRef: _trimmedOrNull(product['code']),
      sourceVersion: _lastModifiedDate(product['last_modified_t']),
    );
  }

  /// Tanggal data terakhir diperbarui pada sumber (`last_modified_t`, detik
  /// Unix UTC) — dicatat sebagai versi sumber (`YYYY-MM-DD`), bukan sebagai
  /// tanggal verifikasi (itu milik repositori, diisi saat pengguna
  /// meninjau/mengonfirmasi).
  String? _lastModifiedDate(Object? value) {
    final seconds = value is num
        ? value.toInt()
        : value is String
        ? int.tryParse(value)
        : null;
    if (seconds == null) {
      return null;
    }
    final date = DateTime.fromMillisecondsSinceEpoch(
      seconds * 1000,
      isUtc: true,
    );
    return '${date.year.toString().padLeft(4, '0')}-'
        '${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
  }

  /// Open Food Facts menyatakan natrium dalam gram (`sodium_*`), kadang
  /// garam dalam gram (`salt_*`) — Mealora menyimpan natrium dalam
  /// miligram (`NutritionValues.sodiumMg`, change 007).
  double? _sodiumMgAt(Map<String, Object?> nutriments, String suffix) {
    final sodiumG = nutriments['sodium$suffix'];
    if (sodiumG is num) {
      return sodiumG.toDouble() * 1000;
    }
    return null;
  }

  double? _unitsPerPackage({double? packageGrams, double? servingGrams}) {
    if (packageGrams == null || servingGrams == null || servingGrams <= 0) {
      return null;
    }
    return packageGrams / servingGrams;
  }

  String? _firstBrand(Object? brands) {
    final text = _trimmedOrNull(brands);
    if (text == null) {
      return null;
    }
    return text.split(',').first.trim();
  }

  double? _asDouble(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  String? _trimmedOrNull(Object? value) {
    if (value is! String) {
      return null;
    }
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }
}
