import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/domain/image_ai_access/label_extraction.dart';
import 'package:mealora/domain/image_ai_access/reading_confidence.dart';
import 'package:mealora/domain/nutrition_import/nutrition_import.dart';
import 'package:mealora/domain/nutrition_import/nutrition_reading.dart';

String fmt(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

Map<String, Object?> steakJson() => <String, Object?>{
  'sourceKind': 'general',
  'foodName': 'steak daging sapi',
  'basis': {
    'kind': 'per_100g',
    'amount': 100,
    'unit': 'g',
    'description': 'daging sapi matang',
  },
  'energyKcal': {'min': 214, 'max': 252, 'status': 'range'},
  'proteinGrams': {'min': 24, 'max': 27, 'status': 'range'},
  'carbohydrateGrams': {'min': 0, 'max': 0, 'status': 'read'},
  'fatGrams': {'min': 15, 'max': 15, 'status': 'read'},
  'ignoredNutrients': ['vitamin B12', 'zat besi', 'zinc', 'niasin'],
  'unexpected': 'dibuang',
};

void main() {
  group('NutritionReading.fromJson (change 020)', () {
    test('contoh steak tester: nilai tengah, nol eksplisit, basis 100 g', () {
      final r = NutritionReading.fromJson(steakJson());

      expect(r.sourceKind, NutritionSourceKind.general);
      expect(r.energyKcal.status, NutrientReadStatus.range);
      expect(r.energyKcal.proposed, 233);
      expect(r.proteinGrams.proposed, 25.5);
      expect(r.carbohydrateGrams.proposed, 0);
      expect(r.fatGrams.proposed, 15);
      expect(r.basis.servingLabel(fmt), '100 g');
      expect(r.ignoredNutrients, hasLength(4));
      expect(r.hasAnyNutrient, isTrue);
    });

    test('nilai tidak disebut tetap belum diketahui, bukan nol', () {
      final json = steakJson()
        ..['carbohydrateGrams'] = {
          'min': null,
          'max': null,
          'status': 'unread',
        };
      final r = NutritionReading.fromJson(json);

      expect(r.carbohydrateGrams.isRead, isFalse);
      expect(r.carbohydrateGrams.proposed, isNull);
    });

    test('nilai negatif, di luar batas wajar, atau min > max jadi unread', () {
      final json = steakJson()
        ..['energyKcal'] = {'min': -5, 'max': -5, 'status': 'read'}
        ..['proteinGrams'] = {'min': 999, 'max': 999, 'status': 'read'}
        ..['fatGrams'] = {'min': 20, 'max': 10, 'status': 'range'}
        ..['carbohydrateGrams'] = {'min': 'nol', 'status': 'read'};
      final r = NutritionReading.fromJson(json);

      expect(r.energyKcal.isRead, isFalse);
      expect(r.proteinGrams.isRead, isFalse);
      expect(r.fatGrams.isRead, isFalse);
      expect(r.carbohydrateGrams.isRead, isFalse);
      expect(r.hasAnyNutrient, isFalse);
    });

    test('batas wajar diskalakan menurut massa basis', () {
      final json = steakJson()
        ..['basis'] = {'kind': 'per_amount', 'amount': 300, 'unit': 'g'}
        ..['energyKcal'] = {'min': 2000, 'max': 2000, 'status': 'read'};
      final r = NutritionReading.fromJson(json);

      expect(r.energyKcal.proposed, 2000);
      expect(r.basis.servingLabel(fmt), '300 g');
    });

    test('basis tidak terbaca → ukuran sajian kosong', () {
      final json = steakJson()..['basis'] = {'kind': 'unread'};
      expect(NutritionReading.fromJson(json).basis.servingLabel(fmt), isNull);
    });

    test('bentuk dasar bukan objek → FormatException', () {
      expect(
        () => NutritionReading.fromJson(<Object>[]),
        throwsFormatException,
      );
    });
  });

  group('toLabelExtraction (jalur produk kemasan)', () {
    test('read → confident, range → needsCheck, unread → unread', () {
      final json = steakJson()
        ..['basis'] = {'kind': 'per_serving', 'amount': 30, 'unit': 'g'}
        ..['servingsPerPackage'] = 2
        ..['carbohydrateGrams'] = {'status': 'unread'};
      final e = NutritionReading.fromJson(json).toLabelExtraction();

      expect(e.basis.kind, ExtractedBasisKind.perServing);
      expect(e.servingSize.value, 30);
      expect(e.servingsPerPackage.value, 2);
      expect(e.energyKcal.value, 233);
      expect(e.energyKcal.confidence, ReadingConfidence.needsCheck);
      expect(e.fat.confidence, ReadingConfidence.confident);
      expect(e.carbohydrate.confidence, ReadingConfidence.unread);
      expect(e.carbohydrate.value, isNull);
    });

    test('basis per_amount dipetakan ke unread', () {
      final json = steakJson()
        ..['basis'] = {'kind': 'per_amount', 'amount': 1, 'unit': 'potong'};
      final e = NutritionReading.fromJson(json).toLabelExtraction();
      expect(e.basis.kind, ExtractedBasisKind.unread);
    });
  });

  group('FormPrefill', () {
    final result = NutritionImportResult.fromReading(
      NutritionReading.fromJson(steakJson()),
      fmt,
    );

    test('nama diisi bila kolom kosong, nutrien diformat', () {
      final p = FormPrefill.from(result, currentName: ' ', formatNumber: fmt);
      expect(p.name, 'Steak daging sapi');
      expect(p.servingLabel, '100 g');
      expect(p.nutrients[ImportNutrient.energy], '233');
      expect(p.nutrients[ImportNutrient.protein], '25.5');
      expect(p.nutrients[ImportNutrient.carbohydrate], '0');
    });

    test('nama yang sudah diisi tidak ditimpa', () {
      final p = FormPrefill.from(
        result,
        currentName: 'Steak buatan ibu',
        formatNumber: fmt,
      );
      expect(p.name, isNull);
    });

    test('nilai unread mengosongkan field', () {
      const r = NutritionImportResult(
        values: <ImportNutrient, double?>{ImportNutrient.fat: null},
      );
      final p = FormPrefill.from(r, currentName: '', formatNumber: fmt);
      expect(p.nutrients[ImportNutrient.fat], '');
    });
  });

  group('looksLikePackageLabel', () {
    test('mengenali panel kemasan', () {
      expect(
        looksLikePackageLabel('INFORMASI NILAI GIZI\nTakaran saji'),
        isTrue,
      );
      expect(looksLikePackageLabel('Kalori steak sekitar 214 kkal'), isFalse);
    });
  });
}
