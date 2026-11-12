// Membangkitkan lib/database/seeds/food_catalog_data.dart dari dataset
// kurasi di tool/food_catalog/ (change 015, design.md D3).
//
//   dart run tool/generate_food_catalog.dart

import 'dart:io';

import 'food_catalog/catalog_dataset.dart';

const String kDatasetDir = 'tool/food_catalog';
const String kOutputPath = 'lib/database/seeds/food_catalog_data.dart';

void main() {
  final data = CatalogDataset.load(kDatasetDir);
  File(kOutputPath).writeAsStringSync(generateSeedSource(data));
  final result = Process.runSync('dart', <String>['format', kOutputPath]);
  if (result.exitCode != 0) {
    stderr.write(result.stderr);
    exitCode = result.exitCode;
    return;
  }
  stdout.writeln(
    'Ditulis $kOutputPath: ${data.foods.length} makanan, '
    '${data.servings.length} takaran.',
  );
}
