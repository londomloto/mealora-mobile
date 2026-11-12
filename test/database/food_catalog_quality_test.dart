import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/food_catalog/catalog_dataset.dart';
import '../../tool/food_catalog/catalog_quality.dart';

/// Gerbang mutu katalog bawaan (spec food-catalog-quality, change 015
/// task 2.2). Pelanggaran yang sudah diketahui sebelum koreksi TKPI 2017
/// dicatat di `quality_baseline.txt` (task 2.3) dan harus berkurang seiring
/// koreksi; pelanggaran baru di luar baseline menggagalkan test.
void main() {
  final data = CatalogDataset.load('tool/food_catalog');
  final violations = checkCatalog(data);
  final baseline = File('tool/food_catalog/quality_baseline.txt')
      .readAsLinesSync()
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty && !l.startsWith('#'))
      .toSet();

  test('tidak ada pelanggaran mutu baru di luar baseline', () {
    final fresh = violations.where((v) => !baseline.contains(v.key)).toList();
    expect(fresh, isEmpty, reason: fresh.join('\n'));
  });

  test('baseline tidak memuat pelanggaran yang sudah diperbaiki', () {
    final current = violations.map((v) => v.key).toSet();
    final stale = baseline.difference(current);
    expect(
      stale,
      isEmpty,
      reason:
          'Hapus dari quality_baseline.txt (sudah diperbaiki):\n'
          '${stale.join('\n')}',
    );
  });

  group('aturan (dataset sintetis)', () {
    CatalogFood food(
      String id,
      String name, {
      double? e = 100,
      double? p = 5,
      double? c = 15,
      double? l = 2,
      bool active = true,
      String? exception,
    }) => CatalogFood(
      id: id,
      name: name,
      category: 'other',
      form: null,
      active: active,
      energyKcal: e,
      proteinG: p,
      carbohydrateG: c,
      fatG: l,
      fiberG: null,
      sourceRef: '1',
      tkpi2017Ref: null,
      verified: true,
      energyException: exception,
      line: 2,
    );

    CatalogServing serving(
      String foodId, {
      String slug = 'default',
      String unit = 'gram',
      double amount = 100,
      double? gram = 100,
      bool isDefault = true,
      String? tier = 'official',
      String? ref = 'TKPI',
      String? note,
    }) => CatalogServing(
      foodId: foodId,
      slug: slug,
      label: '$amount $unit',
      amount: amount,
      unit: unit,
      gram: gram,
      isDefault: isDefault,
      tier: tier,
      ref: ref,
      note: note,
      line: 2,
    );

    List<String> rules(List<CatalogFood> foods, List<CatalogServing> s) =>
        checkCatalog(
          CatalogDataset(
            foods: foods,
            servings: s,
            unitRanges: CatalogDataset.load('tool/food_catalog').unitRanges,
            synonyms: const {},
          ),
        ).map((v) => v.rule).toList();

    test('data bersih lolos', () {
      expect(rules([food('a', 'A')], [serving('a')]), isEmpty);
    });

    test('energi menyimpang tanpa pengecualian gagal; dengan alasan lolos', () {
      expect(rules([food('a', 'Bir', e: 300)], [serving('a')]), [
        'energi-makro',
      ]);
      expect(
        rules(
          [food('a', 'Bir', e: 300, exception: 'mengandung alkohol')],
          [serving('a')],
        ),
        isEmpty,
      );
    });

    test('"1 sdm" 80 g gagal rentang', () {
      expect(
        rules(
          [food('a', 'A')],
          [
            serving('a', isDefault: false),
            serving(
              'a',
              slug: 'sdm',
              unit: 'sdm',
              amount: 1,
              gram: 80,
              isDefault: true,
            ),
          ],
        ),
        ['rentang'],
      );
    });

    test('"Bika ambon" dan "Bika Ambon" aktif → duplikat, nonaktif lolos', () {
      final s = [serving('a'), serving('b')];
      expect(rules([food('a', 'Bika ambon'), food('b', 'Bika Ambon')], s), [
        'duplikat',
        'duplikat',
      ]);
      expect(
        rules([
          food('a', 'Bika ambon'),
          food('b', 'Bika Ambon', active: false),
        ], s),
        isEmpty,
      );
    });

    test('dua takaran bawaan gagal', () {
      expect(
        rules(
          [food('a', 'A')],
          [
            serving('a'),
            serving('a', slug: 'sdm', unit: 'sdm', amount: 1, gram: 10),
          ],
        ),
        ['takaran-bawaan'],
      );
    });

    test('perkiraan tanpa catatan dasar gagal', () {
      expect(
        rules([food('a', 'A')], [serving('a', tier: 'estimate', ref: null)]),
        ['provenans'],
      );
    });
  });
}
