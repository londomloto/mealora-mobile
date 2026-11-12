// Menjalankan pemeriksa mutu katalog dan mencetak pelanggaran.
//
//   dart run tool/check_food_catalog.dart                   # laporan
//   dart run tool/check_food_catalog.dart --write-baseline  # tulis baseline
//
// Baseline (tool/food_catalog/quality_baseline.txt) mencatat pelanggaran
// yang sudah diketahui sebelum koreksi TKPI 2017 (change 015, task 2.3).
// Test mutu gagal untuk pelanggaran baru di luar baseline, dan juga bila
// entri baseline sudah diperbaiki tapi belum dihapus dari baseline.

import 'dart:io';

import 'food_catalog/catalog_dataset.dart';
import 'food_catalog/catalog_quality.dart';

const String kBaselinePath = 'tool/food_catalog/quality_baseline.txt';

void main(List<String> args) {
  final violations = checkCatalog(CatalogDataset.load('tool/food_catalog'));
  for (final v in violations) {
    stdout.writeln(v);
  }
  stdout.writeln('${violations.length} pelanggaran.');
  if (args.contains('--write-baseline')) {
    File(kBaselinePath).writeAsStringSync(
      '# Pelanggaran mutu yang diketahui (aturan|subjek). Jangan menambah\n'
      '# entri baru di sini kecuali disetujui; kurangi saat dikoreksi.\n'
      '${violations.map((v) => v.key).toSet().join('\n')}\n',
    );
    stdout.writeln('Baseline ditulis ke $kBaselinePath');
  }
}
