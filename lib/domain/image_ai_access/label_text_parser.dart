import 'package:mealora/domain/image_ai_access/label_extraction.dart';
import 'package:mealora/domain/image_ai_access/reading_confidence.dart';

/// Pemetaan teks mentah hasil OCR ke [LabelExtraction] lewat pencocokan
/// kata kunci sederhana (Design D11, change 010) — dipakai
/// `OcrNutritionLabelProvider` (lib/data/ocr) di balik hasil pengenalan
/// teks ML Kit.
///
/// Murni Dart, tanpa Flutter/plugin, supaya heuristiknya diuji terpisah
/// dari komponen OCR sungguhan (task 3.12) — pola yang sama dengan
/// `VisionProxyLabelProvider._parseExtraction` (lib/data/remote), hanya
/// sumbernya teks baris demi baris, bukan JSON terstruktur dari model
/// vision.
///
/// Keyakinannya SHALL dipatok konservatif (Design D11): berbeda dari model
/// vision yang memahami struktur tabel, parser ini cuma mencocokkan kata
/// kunci pada baris teks. [ReadingConfidence.confident] HANYA untuk
/// kecocokan eksplisit yang tidak bersaing dengan baris lain (mis. "Energi
/// Total 150 kkal" dalam satu baris); selainnya [ReadingConfidence.needsCheck]
/// bila ada angka yang terbaca tapi meragukan, atau [ReadingConfidence.unread]
/// bila tidak ada kandidat sama sekali — tidak pernah ditebak (spec
/// nutrition-label-extraction, "Nilai yang tidak terbaca tetap belum
/// diketahui").
///
/// Basis (per sajian / per 100 g) SHALL TIDAK pernah [ReadingConfidence.confident]
/// dari parser ini, berapa pun jelasnya kecocokannya: salah membaca basis
/// menggandakan atau membagi SELURUH nilai, jauh lebih berbahaya daripada
/// satu nilai individu yang salah (Design D6).
final class LabelTextParser {
  const LabelTextParser();

  /// Catatan AKG (Angka Kecukupan Gizi) di bagian bawah label — mis.
  /// "*Persen AKG berdasarkan kebutuhan energi 2150 kkal" — menyebut angka
  /// acuan kebutuhan harian, BUKAN nilai gizi produk ini. Dibuang SEBELUM
  /// parser per-nilai mana pun berjalan, supaya "2150" (atau "2000" di
  /// label format lain) tidak pernah terambil sebagai energi/nilai produk
  /// — baris ini satu-satunya tempat angka itu muncul, dan ia muncul pada
  /// hampir semua label Indonesia.
  static final RegExp _referenceIntakeFootnotePattern = RegExp(
    r'akg|kebutuhan',
    caseSensitive: false,
  );

  LabelExtraction parse(String recognizedText) {
    final lines = recognizedText
        .split('\n')
        .map((line) => line.trim())
        .where((line) => line.isNotEmpty)
        .where((line) => !_referenceIntakeFootnotePattern.hasMatch(line))
        .toList(growable: false);

    return LabelExtraction(
      basis: _parseBasis(lines),
      servingSize: _parseServingSize(lines),
      servingsPerPackage: _parseServingsPerPackage(lines),
      energyKcal: _parseNutrient(lines, _energyFieldPatterns),
      protein: _parseNutrient(lines, _proteinFieldPatterns),
      carbohydrate: _parseNutrient(lines, _carbohydrateFieldPatterns),
      fat: _parseNutrient(lines, _fatFieldPatterns),
    );
  }

  // ---- Basis ---------------------------------------------------------

  static final RegExp _perHundredGramsPattern = RegExp(
    r'per\s*100\s*g',
    caseSensitive: false,
  );
  static final RegExp _perServingPattern = RegExp(
    r'per\s*saji|takaran\s*saji',
    caseSensitive: false,
  );

  ExtractedBasis _parseBasis(List<String> lines) {
    for (final line in lines) {
      if (_perHundredGramsPattern.hasMatch(line)) {
        return const ExtractedBasis(
          kind: ExtractedBasisKind.perHundredGrams,
          confidence: ReadingConfidence.needsCheck,
        );
      }
    }
    for (final line in lines) {
      if (_perServingPattern.hasMatch(line)) {
        return const ExtractedBasis(
          kind: ExtractedBasisKind.perServing,
          confidence: ReadingConfidence.needsCheck,
        );
      }
    }
    return const ExtractedBasis(
      kind: ExtractedBasisKind.unread,
      confidence: ReadingConfidence.unread,
    );
  }

  // ---- Ukuran sajian & jumlah sajian per kemasan ----------------------

  static final RegExp _servingSizeStrictPattern = RegExp(
    r'takaran\s*saji[^0-9]{0,15}(\d+(?:[.,]\d+)?)\s*(g|ml)\b',
    caseSensitive: false,
  );
  static final RegExp _servingSizeLoosePattern = RegExp(
    r'(?:takaran|saji)[^0-9]{0,20}(\d+(?:[.,]\d+)?)\s*(g|ml)?',
    caseSensitive: false,
  );

  ExtractedNumber _parseServingSize(List<String> lines) {
    for (final line in lines) {
      final strict = _servingSizeStrictPattern.firstMatch(line);
      if (strict == null) {
        continue;
      }
      final value = _parseLocaleNumber(strict.group(1)!);
      if (value == null) {
        continue;
      }
      return ExtractedNumber(
        confidence: ReadingConfidence.confident,
        value: value,
        unit: strict.group(2)!.toLowerCase(),
      );
    }
    for (final line in lines) {
      final loose = _servingSizeLoosePattern.firstMatch(line);
      if (loose == null) {
        continue;
      }
      final value = _parseLocaleNumber(loose.group(1)!);
      if (value == null) {
        continue;
      }
      return ExtractedNumber(
        confidence: ReadingConfidence.needsCheck,
        value: value,
        unit: loose.group(2)?.toLowerCase() ?? 'g',
      );
    }
    return const ExtractedNumber(confidence: ReadingConfidence.unread);
  }

  static final RegExp _servingsPerPackageStrictPattern = RegExp(
    r'(\d+(?:[.,]\d+)?)\s*sajian\s*per\s*kemasan',
    caseSensitive: false,
  );
  static final RegExp _servingsPerPackageLoosePattern = RegExp(
    r'sajian\s*per\s*kemasan[^0-9]{0,15}(\d+(?:[.,]\d+)?)',
    caseSensitive: false,
  );
  static final RegExp _servingsPerPackageKeywordOnlyPattern = RegExp(
    r'sajian\s*per\s*kemasan',
    caseSensitive: false,
  );

  ExtractedNumber _parseServingsPerPackage(List<String> lines) {
    for (final line in lines) {
      final strict = _servingsPerPackageStrictPattern.firstMatch(line);
      final match = strict ?? _servingsPerPackageLoosePattern.firstMatch(line);
      if (match == null) {
        continue;
      }
      final value = _parseLocaleNumber(match.group(1)!);
      if (value == null) {
        continue;
      }
      return ExtractedNumber(
        confidence: strict != null
            ? ReadingConfidence.confident
            : ReadingConfidence.needsCheck,
        value: value,
        unit: 'sajian',
      );
    }
    // Tata letak tabel sering membuat ML Kit memisahkan "Jumlah Sajian per
    // Kemasan" dan angkanya ke dua baris berbeda (laporan pengujian
    // perangkat) — ambil angka berdiri sendiri pada baris SETELAHNYA.
    for (var i = 0; i < lines.length; i++) {
      if (!_servingsPerPackageKeywordOnlyPattern.hasMatch(lines[i])) {
        continue;
      }
      if (i + 1 >= lines.length) {
        continue;
      }
      final match = _standaloneNumberPattern.firstMatch(lines[i + 1]);
      if (match == null) {
        continue;
      }
      final value = _parseLocaleNumber(match.group(1)!);
      if (value == null) {
        continue;
      }
      return ExtractedNumber(
        confidence: ReadingConfidence.needsCheck,
        value: value,
        unit: 'sajian',
      );
    }
    return const ExtractedNumber(confidence: ReadingConfidence.unread);
  }

  // ---- Nilai gizi (energi, protein, karbohidrat, lemak) ---------------

  /// Angka berdiri sendiri pada satu baris penuh (tidak ada teks lain) —
  /// dipakai jalur lintas-baris ketika tata letak tabel membuat ML Kit
  /// memisahkan kata kunci dan nilainya ke baris berbeda (laporan pengujian
  /// perangkat: "sajian per kemasan, energi, protein, karbo, lemak sering
  /// kosong" — "takaran saji" lolos karena ia satu kalimat utuh, baris
  /// tabel tidak). Satuan dibatasi ke satuan gizi yang dikenal supaya
  /// kolom %AKG di sebelahnya (mis. "8%") tidak ikut terambil.
  static final RegExp _standaloneNumberPattern = RegExp(
    r'^(\d+(?:[.,]\d+)?)\s*(g|kkal|kal|ml)?$',
    caseSensitive: false,
  );

  ExtractedNumber _parseNutrient(
    List<String> lines,
    _NutrientFieldPatterns patterns,
  ) {
    for (final line in lines) {
      final lower = line.toLowerCase();
      if (patterns.exclude.any(lower.contains)) {
        continue;
      }
      final strict = patterns.strict.firstMatch(line);
      if (strict == null) {
        continue;
      }
      final value = _parseLocaleNumber(strict.group(1)!);
      if (value == null) {
        continue;
      }
      return ExtractedNumber(
        confidence: ReadingConfidence.confident,
        value: value,
        unit:
            (strict.groupCount >= 2 ? strict.group(2) : null)?.toLowerCase() ??
            patterns.defaultUnit,
      );
    }
    for (final line in lines) {
      final lower = line.toLowerCase();
      if (patterns.exclude.any(lower.contains)) {
        continue;
      }
      final loose = patterns.loose.firstMatch(line);
      if (loose == null) {
        continue;
      }
      final value = _parseLocaleNumber(loose.group(1)!);
      if (value == null) {
        continue;
      }
      return ExtractedNumber(
        confidence: ReadingConfidence.needsCheck,
        value: value,
        unit:
            (loose.groupCount >= 2 ? loose.group(2) : null)?.toLowerCase() ??
            patterns.defaultUnit,
      );
    }
    for (var i = 0; i < lines.length; i++) {
      final lower = lines[i].toLowerCase();
      if (patterns.exclude.any(lower.contains)) {
        continue;
      }
      if (!patterns.keywordOnly.hasMatch(lines[i])) {
        continue;
      }
      if (i + 1 >= lines.length ||
          patterns.exclude.any(lines[i + 1].toLowerCase().contains)) {
        continue;
      }
      final match = _standaloneNumberPattern.firstMatch(lines[i + 1]);
      if (match == null) {
        continue;
      }
      final value = _parseLocaleNumber(match.group(1)!);
      if (value == null) {
        continue;
      }
      return ExtractedNumber(
        confidence: ReadingConfidence.needsCheck,
        value: value,
        unit: match.group(2)?.toLowerCase() ?? patterns.defaultUnit,
      );
    }
    return const ExtractedNumber(confidence: ReadingConfidence.unread);
  }
}

/// Pasangan pola regex ketat/longgar untuk satu nilai gizi, beserta
/// potongan teks yang membatalkan sebuah baris sebagai kandidat.
final class _NutrientFieldPatterns {
  const _NutrientFieldPatterns({
    required this.strict,
    required this.loose,
    required this.keywordOnly,
    required this.exclude,
    required this.defaultUnit,
  });

  /// Kecocokan langsung, kata kunci+angka+satuan berdekatan tanpa ambiguitas
  /// -> [ReadingConfidence.confident].
  final RegExp strict;

  /// Kata kunci ditemukan dengan angka di dekatnya, tapi tanpa format yang
  /// seketat [strict] -> [ReadingConfidence.needsCheck].
  final RegExp loose;

  /// Kata kunci saja, tanpa syarat angka di baris yang sama — dipakai jalur
  /// lintas-baris ([LabelTextParser._parseNutrient] tier 3) ketika tabel
  /// terpecah dua baris oleh ML Kit.
  final RegExp keywordOnly;

  /// Potongan teks (huruf kecil) yang membatalkan baris sebagai kandidat —
  /// mis. "dari lemak" supaya energi total tidak tertukar dengan energi
  /// dari lemak, "jenuh"/"trans" supaya lemak total tidak tertukar dengan
  /// sub-jenisnya.
  final List<String> exclude;

  final String defaultUnit;
}

final _NutrientFieldPatterns _energyFieldPatterns = _NutrientFieldPatterns(
  strict: RegExp(
    r'energi\s*total[^0-9]{0,15}(\d+(?:[.,]\d+)?)\s*(kkal|kal)\b',
    caseSensitive: false,
  ),
  loose: RegExp(
    r'energi[^0-9]{0,20}(\d+(?:[.,]\d+)?)\s*(kkal|kal)?',
    caseSensitive: false,
  ),
  keywordOnly: RegExp(r'energi', caseSensitive: false),
  exclude: const <String>['dari lemak', 'from fat'],
  defaultUnit: 'kkal',
);

final _NutrientFieldPatterns _proteinFieldPatterns = _NutrientFieldPatterns(
  strict: RegExp(
    r'protein[^0-9]{0,15}(\d+(?:[.,]\d+)?)\s*(g)\b',
    caseSensitive: false,
  ),
  loose: RegExp(
    r'protein[^0-9]{0,20}(\d+(?:[.,]\d+)?)\s*(g)?',
    caseSensitive: false,
  ),
  keywordOnly: RegExp(r'protein', caseSensitive: false),
  exclude: const <String>[],
  defaultUnit: 'g',
);

final _NutrientFieldPatterns _carbohydrateFieldPatterns =
    _NutrientFieldPatterns(
      strict: RegExp(
        r'karbohidrat\s*total[^0-9]{0,15}(\d+(?:[.,]\d+)?)\s*(g)\b',
        caseSensitive: false,
      ),
      loose: RegExp(
        r'karbohidrat[^0-9]{0,20}(\d+(?:[.,]\d+)?)\s*(g)?',
        caseSensitive: false,
      ),
      keywordOnly: RegExp(r'karbohidrat', caseSensitive: false),
      exclude: const <String>[],
      defaultUnit: 'g',
    );

final _NutrientFieldPatterns _fatFieldPatterns = _NutrientFieldPatterns(
  strict: RegExp(
    r'(?:lemak\s*total|total\s*lemak)[^0-9]{0,15}(\d+(?:[.,]\d+)?)\s*(g)\b',
    caseSensitive: false,
  ),
  loose: RegExp(
    r'lemak[^0-9]{0,20}(\d+(?:[.,]\d+)?)\s*(g)?',
    caseSensitive: false,
  ),
  keywordOnly: RegExp(r'lemak', caseSensitive: false),
  exclude: const <String>['jenuh', 'trans', 'dari lemak', 'from fat'],
  defaultUnit: 'g',
);

double? _parseLocaleNumber(String raw) =>
    double.tryParse(raw.replaceAll(',', '.'));
