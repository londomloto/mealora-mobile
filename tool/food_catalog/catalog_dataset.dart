// Dataset kurasi katalog makanan bawaan (change 015, design.md D3/D4).
//
// Pustaka Dart murni (tanpa Flutter) supaya bisa dipakai oleh
// `tool/generate_food_catalog.dart` dan oleh test di `test/database/`.

import 'dart:io';

/// Satu makanan dari `foods.csv`. Gizi per 100 g; `null` = belum diketahui.
final class CatalogFood {
  const CatalogFood({
    required this.id,
    required this.name,
    required this.category,
    required this.form,
    required this.active,
    required this.energyKcal,
    required this.proteinG,
    required this.carbohydrateG,
    required this.fatG,
    required this.fiberG,
    required this.sourceRef,
    required this.tkpi2017Ref,
    required this.verified,
    required this.energyException,
    required this.line,
  });

  final String id;
  final String name;
  final String category;
  final String? form;
  final bool active;
  final double? energyKcal;
  final double? proteinG;
  final double? carbohydrateG;
  final double? fatG;
  final double? fiberG;
  final String sourceRef;
  final String? tkpi2017Ref;
  final bool verified;

  /// Alasan terdokumentasi bila energi boleh menyimpang dari 4P + 4K + 9L.
  final String? energyException;

  /// Nomor baris di `foods.csv` (1 = header), untuk laporan pelanggaran.
  final int line;
}

/// Satu takaran dari `servings.csv`.
final class CatalogServing {
  const CatalogServing({
    required this.foodId,
    required this.slug,
    required this.label,
    required this.amount,
    required this.unit,
    required this.gram,
    required this.isDefault,
    required this.tier,
    required this.ref,
    required this.note,
    required this.line,
  });

  final String foodId;
  final String slug;
  final String label;
  final double amount;
  final String unit;
  final double? gram;
  final bool isDefault;
  final String? tier;
  final String? ref;
  final String? note;
  final int line;

  /// ID stabil: takaran asal 100 g tetap `food-<id>-default` (design.md D1).
  String get servingId => 'food-$foodId-$slug';
}

/// Rentang wajar gram (atau ml) per satuan dari `unit_ranges.csv`.
final class UnitRange {
  const UnitRange({
    required this.unit,
    required this.min,
    required this.max,
    required this.source,
  });

  final String unit;
  final double min;
  final double max;
  final String source;
}

final class CatalogDataset {
  const CatalogDataset({
    required this.foods,
    required this.servings,
    required this.unitRanges,
    required this.synonyms,
  });

  final List<CatalogFood> foods;
  final List<CatalogServing> servings;
  final List<UnitRange> unitRanges;

  /// Pasangan (bentuk sehari-hari → bentuk kanonik), mis. `telor → telur`.
  final Map<String, String> synonyms;

  static CatalogDataset load(String directory) {
    List<Map<String, String>> read(String name, {bool optional = false}) {
      final file = File('$directory/$name');
      if (optional && !file.existsSync()) return const [];
      return parseCsv(file.readAsStringSync());
    }

    var line = 1;
    final foods = read('foods.csv').map((r) {
      line++;
      return CatalogFood(
        id: _required(r, 'id', 'foods.csv', line),
        name: _required(r, 'name', 'foods.csv', line),
        category: _required(r, 'category', 'foods.csv', line),
        form: _optional(r['form']),
        active: _bool(r['active'], defaultValue: true),
        energyKcal: _number(r['energy_kcal']),
        proteinG: _number(r['protein_g']),
        carbohydrateG: _number(r['carbohydrate_g']),
        fatG: _number(r['fat_g']),
        fiberG: _number(r['fiber_g']),
        sourceRef: _required(r, 'source_ref', 'foods.csv', line),
        tkpi2017Ref: _optional(r['tkpi2017_ref']),
        verified: _bool(r['verified'], defaultValue: false),
        energyException: _optional(r['energy_exception']),
        line: line,
      );
    }).toList();

    line = 1;
    final servings = read('servings.csv').map((r) {
      line++;
      return CatalogServing(
        foodId: _required(r, 'food_id', 'servings.csv', line),
        slug: _required(r, 'slug', 'servings.csv', line),
        label: _required(r, 'label', 'servings.csv', line),
        amount: _number(r['amount']) ?? 1,
        unit: _required(r, 'unit', 'servings.csv', line),
        gram: _number(r['gram']),
        isDefault: _bool(r['is_default'], defaultValue: false),
        tier: _optional(r['tier']),
        ref: _optional(r['ref']),
        note: _optional(r['note']),
        line: line,
      );
    }).toList();

    final ranges = read('unit_ranges.csv', optional: true)
        .map(
          (r) => UnitRange(
            unit: r['unit']!.trim(),
            min: double.parse(r['min']!),
            max: double.parse(r['max']!),
            source: r['source'] ?? '',
          ),
        )
        .toList();

    final synonyms = <String, String>{
      for (final r in read('synonyms.csv', optional: true))
        r['variant']!.trim().toLowerCase(): r['canonical']!
            .trim()
            .toLowerCase(),
    };

    return CatalogDataset(
      foods: foods,
      servings: servings,
      unitRanges: ranges,
      synonyms: synonyms,
    );
  }
}

/// Gizi per takaran = nilai_100g × gram / 100 (design.md D4), dibulatkan ke
/// 2 desimal supaya hasil bangkitan stabil.
double? perServing(double? per100g, double gram) {
  if (per100g == null) return null;
  return (per100g * gram / 100 * 100).roundToDouble() / 100;
}

/// Membangkitkan isi `lib/database/seeds/food_catalog_data.dart`.
String generateSeedSource(CatalogDataset data) {
  final servingsByFood = <String, List<CatalogServing>>{};
  for (final s in data.servings) {
    servingsByFood.putIfAbsent(s.foodId, () => []).add(s);
  }
  final out = StringBuffer()
    ..writeln('// GENERATED by tool/generate_food_catalog.dart dari')
    ..writeln('// tool/food_catalog/*.csv — jangan disunting tangan.')
    ..writeln('// Ubah dataset CSV lalu jalankan:')
    ..writeln('//   dart run tool/generate_food_catalog.dart')
    ..writeln()
    ..writeln("part of 'food_catalog_seed.dart';")
    ..writeln()
    ..writeln('const List<_SeedFood> _kSeedFoods = <_SeedFood>[');
  for (final f in data.foods) {
    final servings = servingsByFood[f.id];
    if (servings == null || servings.isEmpty) {
      throw FormatException('foods.csv:${f.line}: ${f.name} tanpa takaran');
    }
    out
      ..writeln('  _SeedFood(')
      ..writeln('    idSuffix: ${_str(f.id)},')
      ..writeln('    name: ${_str(f.name)},')
      ..writeln('    category: ${_str(f.category)},')
      ..writeln('    form: ${f.form == null ? 'null' : _str(f.form!)},')
      ..writeln('    isActive: ${f.active},')
      ..writeln('    sourceRef: ${_str(f.sourceRef)},')
      ..writeln('    verified: ${f.verified},')
      ..writeln('    servings: <_SeedServing>[');
    for (final s in servings) {
      final gram = s.gram;
      if (gram == null) {
        throw FormatException(
          'servings.csv:${s.line}: takaran katalog wajib punya gram',
        );
      }
      out
        ..writeln('      _SeedServing(')
        ..writeln('        slug: ${_str(s.slug)},')
        ..writeln('        label: ${_str(s.label)},')
        ..writeln('        amount: ${_num(s.amount)},')
        ..writeln('        unit: ${_str(s.unit)},')
        ..writeln('        gram: ${_num(gram)},')
        ..writeln('        isDefault: ${s.isDefault},')
        ..writeln('        tier: ${s.tier == null ? 'null' : _str(s.tier!)},')
        ..writeln('        ref: ${s.ref == null ? 'null' : _str(s.ref!)},')
        ..writeln('        note: ${s.note == null ? 'null' : _str(s.note!)},')
        ..writeln(
          '        energyKcal: ${_num(perServing(f.energyKcal, gram))},',
        )
        ..writeln('        proteinG: ${_num(perServing(f.proteinG, gram))},')
        ..writeln(
          '        carbohydrateG: ${_num(perServing(f.carbohydrateG, gram))},',
        )
        ..writeln('        fatG: ${_num(perServing(f.fatG, gram))},')
        ..writeln('        fiberG: ${_num(perServing(f.fiberG, gram))},')
        ..writeln('      ),');
    }
    out
      ..writeln('    ],')
      ..writeln('  ),');
  }
  out
    ..writeln('];')
    ..writeln()
    ..writeln('/// Sinonim pencarian dari `synonyms.csv` (varian → kanonik).')
    ..writeln(
      'const Map<String, String> kFoodSearchSynonyms = <String, String>{',
    );
  for (final e in data.synonyms.entries) {
    out.writeln('  ${_str(e.key)}: ${_str(e.value)},');
  }
  out.writeln('};');
  return out.toString();
}

/// Pengurai CSV RFC 4180 minimal (kutip ganda, koma, baris baru di kutipan).
List<Map<String, String>> parseCsv(String text) {
  final rows = <List<String>>[];
  var row = <String>[];
  final field = StringBuffer();
  var quoted = false;
  for (var i = 0; i < text.length; i++) {
    final c = text[i];
    if (quoted) {
      if (c == '"') {
        if (i + 1 < text.length && text[i + 1] == '"') {
          field.write('"');
          i++;
        } else {
          quoted = false;
        }
      } else {
        field.write(c);
      }
    } else if (c == '"') {
      quoted = true;
    } else if (c == ',') {
      row.add(field.toString());
      field.clear();
    } else if (c == '\n' || c == '\r') {
      if (c == '\r' && i + 1 < text.length && text[i + 1] == '\n') i++;
      row.add(field.toString());
      field.clear();
      if (row.any((v) => v.isNotEmpty)) rows.add(row);
      row = <String>[];
    } else {
      field.write(c);
    }
  }
  if (field.isNotEmpty || row.isNotEmpty) {
    row.add(field.toString());
    if (row.any((v) => v.isNotEmpty)) rows.add(row);
  }
  if (rows.isEmpty) return const [];
  final header = rows.first;
  return [
    for (final r in rows.skip(1))
      {
        for (var i = 0; i < header.length; i++)
          header[i]: i < r.length ? r[i] : '',
      },
  ];
}

String _required(Map<String, String> r, String key, String file, int line) {
  final v = r[key]?.trim() ?? '';
  if (v.isEmpty) throw FormatException('$file:$line: kolom $key kosong');
  return v;
}

String? _optional(String? v) {
  final t = v?.trim() ?? '';
  return t.isEmpty ? null : t;
}

double? _number(String? v) {
  final t = v?.trim() ?? '';
  return t.isEmpty ? null : double.parse(t);
}

bool _bool(String? v, {required bool defaultValue}) {
  final t = v?.trim().toLowerCase() ?? '';
  if (t.isEmpty) return defaultValue;
  return t == 'true' || t == '1' || t == 'ya';
}

String _str(String v) =>
    "'${v.replaceAll(r'\', r'\\').replaceAll("'", r"\'").replaceAll(r'$', r'\$')}'";

String _num(double? v) {
  if (v == null) return 'null';
  return v == v.roundToDouble() ? '${v.toInt()}.0' : '$v';
}
