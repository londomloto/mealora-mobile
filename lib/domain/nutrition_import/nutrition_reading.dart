import 'package:mealora/domain/image_ai_access/label_extraction.dart';
import 'package:mealora/domain/image_ai_access/reading_confidence.dart';

/// Hasil baca info gizi dari teks atau gambar (change 020, design D1). Satu
/// bentuk untuk ketiga tingkat pembacaan. Model hanya melaporkan angka
/// mentah (min/max); nilai tengah dan validasi dihitung di sini supaya
/// deterministik dan dapat diuji.
enum NutritionSourceKind { packageLabel, general, unknown }

enum NutrientReadStatus { read, range, unread }

enum NutritionBasisKind { perServing, perHundredGrams, perAmount, unread }

/// Tingkat pembacaan yang menghasilkan [NutritionReading] (design D3).
enum ReadingTier {
  /// Gambar dibaca AI vision (izin unggah diberikan).
  vision,

  /// Teks (tempel atau hasil OCR di perangkat) dibaca AI.
  text,

  /// Teks hasil OCR dibaca sepenuhnya di perangkat, tanpa jaringan.
  offline,
}

enum ImportNutrient { energy, protein, carbohydrate, fat }

final class NutrientReading {
  const NutrientReading._(this.min, this.max, this.status);

  const NutrientReading.read(double value)
    : this._(value, value, NutrientReadStatus.read);

  const NutrientReading.range(double min, double max)
    : this._(min, max, NutrientReadStatus.range);

  static const NutrientReading unread = NutrientReading._(
    null,
    null,
    NutrientReadStatus.unread,
  );

  final double? min;
  final double? max;
  final NutrientReadStatus status;

  bool get isRead => status != NutrientReadStatus.unread;

  /// Nilai usulan: angka itu sendiri, atau nilai tengah rentang
  /// (spec "Rentang angka diisi nilai tengah berlabel").
  double? get proposed => switch (status) {
    NutrientReadStatus.unread => null,
    NutrientReadStatus.read => min,
    NutrientReadStatus.range => (min! + max!) / 2,
  };
}

final class NutritionBasis {
  const NutritionBasis({
    required this.kind,
    this.amount,
    this.unit,
    this.description,
  });

  static const NutritionBasis unread = NutritionBasis(
    kind: NutritionBasisKind.unread,
  );

  final NutritionBasisKind kind;
  final double? amount;
  final String? unit;
  final String? description;

  bool get _isMass {
    final u = unit?.trim().toLowerCase();
    return u == 'g' || u == 'gram' || u == 'ml';
  }

  /// Massa/volume (g atau ml) yang diwakili basis, bila diketahui.
  double? get gramsOrMl => switch (kind) {
    NutritionBasisKind.perHundredGrams => 100,
    NutritionBasisKind.perServing ||
    NutritionBasisKind.perAmount => _isMass ? amount : null,
    NutritionBasisKind.unread => null,
  };

  /// Label ukuran sajian untuk form Buat makanan (spec "Basis porsi menjadi
  /// ukuran sajian"); `null` bila basis tidak terbaca.
  String? servingLabel(String Function(double) formatNumber) {
    final u = _normalizedUnit;
    switch (kind) {
      case NutritionBasisKind.unread:
        return null;
      case NutritionBasisKind.perHundredGrams:
        return '100 ${u ?? 'g'}';
      case NutritionBasisKind.perServing:
        final a = amount;
        return a == null || u == null
            ? '1 sajian'
            : '1 sajian (${formatNumber(a)} $u)';
      case NutritionBasisKind.perAmount:
        final a = amount;
        if (a == null || u == null) {
          return null;
        }
        return '${formatNumber(a)} $u';
    }
  }

  String? get _normalizedUnit {
    final u = unit?.trim();
    if (u == null || u.isEmpty) {
      return null;
    }
    return u.toLowerCase() == 'gram' ? 'g' : u;
  }
}

final class NutritionReading {
  const NutritionReading({
    required this.sourceKind,
    required this.basis,
    required this.energyKcal,
    required this.proteinGrams,
    required this.carbohydrateGrams,
    required this.fatGrams,
    this.foodName,
    this.servingsPerPackage,
    this.ignoredNutrients = const <String>[],
  });

  /// Membaca JSON respons proksi. Field yang tidak dikenal dibuang; nilai
  /// yang tidak valid atau di luar batas wajar menjadi tidak terbaca (spec
  /// "Isi teks atau gambar diperlakukan sebagai data"). Melempar
  /// [FormatException] bila bentuk dasarnya bukan objek.
  factory NutritionReading.fromJson(Object? json) {
    if (json is! Map<String, Object?>) {
      throw const FormatException('nutrition reading is not an object');
    }
    final basis = _basisFromJson(json['basis']);
    final limits = _Limits.forBasis(basis);
    return NutritionReading(
      sourceKind: switch (json['sourceKind']) {
        'package_label' => NutritionSourceKind.packageLabel,
        'general' => NutritionSourceKind.general,
        _ => NutritionSourceKind.unknown,
      },
      foodName: _cleanString(json['foodName'], maxLength: 80),
      basis: basis,
      servingsPerPackage: _positive(json['servingsPerPackage']),
      energyKcal: _nutrientFromJson(json['energyKcal'], limits.energyKcal),
      proteinGrams: _nutrientFromJson(json['proteinGrams'], limits.grams),
      carbohydrateGrams: _nutrientFromJson(
        json['carbohydrateGrams'],
        limits.grams,
      ),
      fatGrams: _nutrientFromJson(json['fatGrams'], limits.grams),
      ignoredNutrients: _stringList(json['ignoredNutrients']),
    );
  }

  /// Pembacaan offline (tingkat 3): [LabelExtraction] dari `LabelTextParser`
  /// diubah ke bentuk bersama. Jenis sumber ditebak dari kata kunci panel
  /// kemasan pada teks OCR (design D3).
  factory NutritionReading.fromOfflineExtraction(
    LabelExtraction extraction,
    String recognizedText,
  ) {
    NutrientReading n(ExtractedNumber x) {
      final v = x.value;
      return v == null || x.confidence == ReadingConfidence.unread
          ? NutrientReading.unread
          : NutrientReading.read(v);
    }

    final serving = extraction.servingSize.value;
    final basis = switch (extraction.basis.kind) {
      ExtractedBasisKind.perHundredGrams => const NutritionBasis(
        kind: NutritionBasisKind.perHundredGrams,
        amount: 100,
        unit: 'g',
      ),
      ExtractedBasisKind.perServing => NutritionBasis(
        kind: NutritionBasisKind.perServing,
        amount: serving,
        unit: serving == null ? null : (extraction.servingSize.unit ?? 'g'),
      ),
      ExtractedBasisKind.unread => NutritionBasis.unread,
    };
    final limits = _Limits.forBasis(basis);
    NutrientReading bounded(NutrientReading r, double max) {
      final v = r.min;
      return v == null || v < 0 || v > max ? NutrientReading.unread : r;
    }

    return NutritionReading(
      sourceKind: looksLikePackageLabel(recognizedText)
          ? NutritionSourceKind.packageLabel
          : NutritionSourceKind.unknown,
      basis: basis,
      servingsPerPackage: extraction.servingsPerPackage.value,
      energyKcal: bounded(n(extraction.energyKcal), limits.energyKcal),
      proteinGrams: bounded(n(extraction.protein), limits.grams),
      carbohydrateGrams: bounded(n(extraction.carbohydrate), limits.grams),
      fatGrams: bounded(n(extraction.fat), limits.grams),
    );
  }

  final NutritionSourceKind sourceKind;
  final String? foodName;
  final NutritionBasis basis;
  final double? servingsPerPackage;
  final NutrientReading energyKcal;
  final NutrientReading proteinGrams;
  final NutrientReading carbohydrateGrams;
  final NutrientReading fatGrams;
  final List<String> ignoredNutrients;

  NutrientReading nutrient(ImportNutrient n) => switch (n) {
    ImportNutrient.energy => energyKcal,
    ImportNutrient.protein => proteinGrams,
    ImportNutrient.carbohydrate => carbohydrateGrams,
    ImportNutrient.fat => fatGrams,
  };

  /// Spec "Sumber tanpa angka gizi dilaporkan".
  bool get hasAnyNutrient =>
      ImportNutrient.values.any((n) => nutrient(n).isRead);

  /// Pemetaan ke [LabelExtraction] untuk jalur produk kemasan (design D1):
  /// read → confident, range → needsCheck (nilai tengah), unread → unread.
  /// Basis selain per sajian / per 100 g menjadi unread agar pengguna
  /// memilih sendiri di tinjau label.
  LabelExtraction toLabelExtraction({bool forceNeedsCheck = false}) {
    ExtractedNumber number(NutrientReading r, {String? unit}) {
      final v = r.proposed;
      if (v == null) {
        return ExtractedNumber.genuinelyAbsent;
      }
      final confidence = forceNeedsCheck || r.status == NutrientReadStatus.range
          ? ReadingConfidence.needsCheck
          : ReadingConfidence.confident;
      return ExtractedNumber(value: v, unit: unit, confidence: confidence);
    }

    final basisKind = switch (basis.kind) {
      NutritionBasisKind.perServing => ExtractedBasisKind.perServing,
      NutritionBasisKind.perHundredGrams => ExtractedBasisKind.perHundredGrams,
      NutritionBasisKind.perAmount ||
      NutritionBasisKind.unread => ExtractedBasisKind.unread,
    };
    final servingGrams = basis.kind == NutritionBasisKind.perServing
        ? basis.gramsOrMl
        : null;
    final perPackage = servingsPerPackage;
    return LabelExtraction(
      basis: ExtractedBasis(
        kind: basisKind,
        confidence: basisKind == ExtractedBasisKind.unread
            ? ReadingConfidence.unread
            : forceNeedsCheck
            ? ReadingConfidence.needsCheck
            : ReadingConfidence.confident,
      ),
      servingSize: servingGrams == null
          ? ExtractedNumber.genuinelyAbsent
          : ExtractedNumber(
              value: servingGrams,
              unit: basis._normalizedUnit,
              confidence: forceNeedsCheck
                  ? ReadingConfidence.needsCheck
                  : ReadingConfidence.confident,
            ),
      servingsPerPackage: perPackage == null
          ? ExtractedNumber.genuinelyAbsent
          : ExtractedNumber(
              value: perPackage,
              confidence: forceNeedsCheck
                  ? ReadingConfidence.needsCheck
                  : ReadingConfidence.confident,
            ),
      energyKcal: number(energyKcal, unit: 'kkal'),
      protein: number(proteinGrams, unit: 'g'),
      carbohydrate: number(carbohydrateGrams, unit: 'g'),
      fat: number(fatGrams, unit: 'g'),
    );
  }
}

/// Ciri panel "Informasi Nilai Gizi" kemasan pada teks OCR (design D3).
bool looksLikePackageLabel(String text) {
  final t = text.toLowerCase();
  return t.contains('informasi nilai gizi') ||
      t.contains('nutrition facts') ||
      t.contains('takaran saji') ||
      t.contains('sajian per kemasan') ||
      t.contains('jumlah per sajian');
}

/// Batas wajar per basis (design D6): per 100 g energi ≤ 900 kkal dan makro
/// ≤ 100 g, diskalakan menurut massa basis bila diketahui. Bila massa basis
/// tidak diketahui (mis. "per potong"), batas dilonggarkan setara 1 kg.
final class _Limits {
  const _Limits(this.energyKcal, this.grams);

  factory _Limits.forBasis(NutritionBasis basis) {
    final mass = basis.gramsOrMl;
    final factor = mass == null || mass <= 0 ? 10.0 : mass / 100;
    return _Limits(900 * factor, 100 * factor);
  }

  final double energyKcal;
  final double grams;
}

NutritionBasis _basisFromJson(Object? json) {
  if (json is! Map<String, Object?>) {
    return NutritionBasis.unread;
  }
  final kind = switch (json['kind']) {
    'per_serving' => NutritionBasisKind.perServing,
    'per_100g' => NutritionBasisKind.perHundredGrams,
    'per_amount' => NutritionBasisKind.perAmount,
    _ => NutritionBasisKind.unread,
  };
  if (kind == NutritionBasisKind.unread) {
    return NutritionBasis.unread;
  }
  final amount = _positive(json['amount']);
  final unit = _cleanString(json['unit'], maxLength: 16);
  if (kind == NutritionBasisKind.perAmount &&
      (amount == null || unit == null)) {
    return NutritionBasis.unread;
  }
  return NutritionBasis(
    kind: kind,
    amount: kind == NutritionBasisKind.perHundredGrams ? 100 : amount,
    unit: kind == NutritionBasisKind.perHundredGrams ? (unit ?? 'g') : unit,
    description: _cleanString(json['description'], maxLength: 80),
  );
}

NutrientReading _nutrientFromJson(Object? json, double maxValue) {
  if (json is! Map<String, Object?>) {
    return NutrientReading.unread;
  }
  double? valid(Object? v) {
    if (v is! num) {
      return null;
    }
    final d = v.toDouble();
    return d.isFinite && d >= 0 && d <= maxValue ? d : null;
  }

  final min = valid(json['min']);
  final max = valid(json['max']);
  switch (json['status']) {
    case 'read':
      final v = min ?? max;
      return v == null ? NutrientReading.unread : NutrientReading.read(v);
    case 'range':
      if (min == null || max == null || min > max) {
        return NutrientReading.unread;
      }
      return min == max
          ? NutrientReading.read(min)
          : NutrientReading.range(min, max);
    default:
      return NutrientReading.unread;
  }
}

double? _positive(Object? v) {
  if (v is! num) {
    return null;
  }
  final d = v.toDouble();
  return d.isFinite && d > 0 ? d : null;
}

String? _cleanString(Object? v, {required int maxLength}) {
  if (v is! String) {
    return null;
  }
  final s = v.trim();
  if (s.isEmpty) {
    return null;
  }
  return s.length > maxLength ? s.substring(0, maxLength) : s;
}

List<String> _stringList(Object? v) {
  if (v is! List) {
    return const <String>[];
  }
  return v
      .whereType<String>()
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty && s.length <= 40)
      .take(20)
      .toList(growable: false);
}
