// Aturan mutu katalog bawaan (spec food-catalog-quality, design.md D7).

import 'catalog_dataset.dart';

/// Satu pelanggaran: aturan, makanan/takaran, dan penjelasan.
final class QualityViolation implements Comparable<QualityViolation> {
  const QualityViolation(this.rule, this.subject, this.detail);

  final String rule;

  /// ID makanan (`tkpi-12`) atau takaran (`food-tkpi-12-gelas`).
  final String subject;
  final String detail;

  /// Kunci stabil untuk baseline: tanpa angka detail supaya koreksi kecil
  /// tidak mengubah kuncinya.
  String get key => '$rule|$subject';

  @override
  String toString() => '[$rule] $subject: $detail';

  @override
  int compareTo(QualityViolation other) => key.compareTo(other.key);
}

const double kEnergyTolerance = 0.25;
const double kEnergyCheckMinKcal = 20;
const Set<String> kTiers = <String>{'official', 'derived', 'estimate'};
const Set<String> kForms = <String>{'ready', 'raw', 'dry'};

/// Nama ternormalisasi: huruf kecil, spasi berlebih diabaikan.
String normalizeName(String name) =>
    name.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');

List<QualityViolation> checkCatalog(CatalogDataset data) {
  final out = <QualityViolation>[];
  final foodIds = {for (final f in data.foods) f.id};

  for (final f in data.foods) {
    final p = f.proteinG, c = f.carbohydrateG, l = f.fatG, e = f.energyKcal;
    if (e != null &&
        e > kEnergyCheckMinKcal &&
        p != null &&
        c != null &&
        l != null &&
        f.energyException == null) {
      final computed = 4 * p + 4 * c + 9 * l;
      final deviation = (e - computed).abs() / e;
      if (deviation > kEnergyTolerance) {
        out.add(
          QualityViolation(
            'energi-makro',
            f.id,
            '${f.name}: energi $e kkal vs 4P+4K+9L = '
                '${computed.toStringAsFixed(1)} kkal '
                '(${(deviation * 100).toStringAsFixed(0)}%)',
          ),
        );
      }
    }
    if (f.form != null && !kForms.contains(f.form)) {
      out.add(QualityViolation('bentuk', f.id, '${f.name}: form "${f.form}"'));
    }
  }

  final activeByName = <String, List<CatalogFood>>{};
  for (final f in data.foods.where((f) => f.active)) {
    activeByName.putIfAbsent(normalizeName(f.name), () => []).add(f);
  }
  for (final group in activeByName.values.where((g) => g.length > 1)) {
    final names = group.map((f) => '${f.name} (${f.id})').join(', ');
    for (final f in group) {
      out.add(QualityViolation('duplikat', f.id, names));
    }
  }

  final defaults = <String, int>{for (final id in foodIds) id: 0};
  final ranges = {for (final r in data.unitRanges) r.unit: r};
  final density = ranges['density_g_per_ml'];
  final seenServingIds = <String>{};

  for (final s in data.servings) {
    final subject = s.servingId;
    if (!foodIds.contains(s.foodId)) {
      out.add(QualityViolation('takaran-yatim', subject, 'makanan tidak ada'));
      continue;
    }
    if (!seenServingIds.add(subject)) {
      out.add(QualityViolation('takaran-ganda', subject, 'slug terpakai'));
    }
    if (s.isDefault) defaults[s.foodId] = defaults[s.foodId]! + 1;

    if (s.tier == null || !kTiers.contains(s.tier)) {
      out.add(
        QualityViolation('provenans', subject, 'tingkat "${s.tier}" tidak sah'),
      );
    } else if (s.tier == 'estimate' && s.note == null) {
      out.add(
        QualityViolation('provenans', subject, 'perkiraan tanpa catatan dasar'),
      );
    } else if (s.tier != 'estimate' && s.ref == null) {
      out.add(QualityViolation('provenans', subject, 'tanpa rujukan'));
    }

    final gram = s.gram;
    if (gram == null || gram <= 0 || s.amount <= 0) {
      out.add(QualityViolation('rentang', subject, 'gram/jumlah tidak sah'));
      continue;
    }
    final perUnit = gram / s.amount;
    if (s.unit == 'ml') {
      if (density != null && (perUnit < density.min || perUnit > density.max)) {
        out.add(
          QualityViolation(
            'rentang',
            subject,
            '${s.label}: ${perUnit.toStringAsFixed(2)} g/ml di luar '
                '${density.min}-${density.max}',
          ),
        );
      }
      continue;
    }
    final range = ranges[s.unit];
    if (range == null) {
      out.add(
        QualityViolation(
          'rentang',
          subject,
          'satuan "${s.unit}" tanpa rentang',
        ),
      );
    } else if (s.unit != 'gram' &&
        (perUnit < range.min || perUnit > range.max)) {
      out.add(
        QualityViolation(
          'rentang',
          subject,
          '${s.label}: ${perUnit.toStringAsFixed(1)} g per ${s.unit} di luar '
              '${range.min}-${range.max} g',
        ),
      );
    }
  }

  for (final entry in defaults.entries.where((e) => e.value != 1)) {
    out.add(
      QualityViolation(
        'takaran-bawaan',
        entry.key,
        '${entry.value} takaran bawaan (harus tepat 1)',
      ),
    );
  }

  final food = {for (final f in data.foods) f.id: f};
  for (final f in food.values) {
    if (f.sourceRef.isEmpty) {
      out.add(QualityViolation('provenans', f.id, '${f.name}: tanpa rujukan'));
    }
  }
  return out..sort();
}
