import 'package:mealora/domain/voice_input/food_sentence_parser.dart';

/// Pengurai kalimat di perangkat berbasis aturan — cadangan ketika proksi
/// tidak tersedia (change 012, design D14, task 5.8). Pola yang sama dengan
/// `LabelTextParser` change 010: murni Dart, konservatif, tidak pernah
/// menebak.
///
/// Aturan yang SHALL dijaga (diuji dengan himpunan uji evaluasi, task 5.11):
/// - Jumlah hanya diisi bila disebut eksplisit; kata samar ("beberapa",
///   "sedikit") dan jumlah yang dibantah ("tapi yang satu nggak habis")
///   membuat jumlah kosong (design D5).
/// - Bagian kalimat yang memuat permintaan di luar pencatatan makanan
///   dibuang seluruhnya, tidak pernah menjadi makanan (design D11).
/// - Setiap komponen ditandai perlu diperiksa (task 5.10).
final class RuleBasedFoodSentenceParser implements FoodSentenceParser {
  const RuleBasedFoodSentenceParser();

  @override
  Future<FoodSentenceParseOutcome> parse(String sentence) async =>
      FoodSentenceParsed(parseSentence(sentence));

  ParsedSentence parseSentence(String sentence) {
    final items = <ParsedFoodItem>[];
    final nonFood = <String>[];

    for (final clause in _splitClauses(_normalize(sentence))) {
      final target = _nonFoodTarget(clause);
      if (target != null) {
        nonFood.add(target);
        continue;
      }
      if (_negation.hasMatch(clause)) continue;
      if (_partlyUneaten.hasMatch(clause)) {
        if (items.isNotEmpty) {
          final last = items.removeLast();
          items.add(
            ParsedFoodItem(
              foodName: last.foodName,
              unit: last.unit,
              unitStatus: last.unit == null
                  ? ParsedUnitStatus.missing
                  : ParsedUnitStatus.nonstandard,
              needsCheck: true,
            ),
          );
        }
        continue;
      }
      final item = _parseClause(clause);
      if (item != null) items.add(item);
    }

    return ParsedSentence(
      items: items,
      source: ParseSource.onDevice,
      nonFoodRequests: nonFood,
    );
  }

  // ---- Normalisasi dan pemecahan --------------------------------------

  static String _normalize(String input) => input
      .toLowerCase()
      .replaceAll(RegExp('[“”"!?.]'), ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  static final RegExp _separator = RegExp(
    r',|;| dan | sama | terus | trus | lalu | pakai | ditambah | sekalian '
    r'| oh iya | di | tapi ',
  );

  static List<String> _splitClauses(String text) => ' $text '
      .split(_separator)
      .map((c) => c.trim())
      .where((c) => c.isNotEmpty)
      .toList(growable: false);

  // ---- Batas cakupan --------------------------------------------------

  static const Map<String, String> _nonFoodKeywords = <String, String>{
    'berat': 'berat_badan',
    'kilo': 'berat_badan',
    'kg': 'berat_badan',
    'program': 'program',
    'pengaturan': 'pengaturan',
    'setting': 'pengaturan',
    'tinggi badan': 'profil',
    'profil': 'profil',
    'hapus': 'buku_harian',
    'ubah': 'lainnya',
    'ganti': 'lainnya',
    'ingetin': 'lainnya',
    'ingatkan': 'lainnya',
    'pengingat': 'lainnya',
    'kalori': 'hari_ini',
    'berapa': 'hari_ini',
    'abaikan': 'lainnya',
    'instruksi': 'lainnya',
  };

  static String? _nonFoodTarget(String clause) {
    for (final entry in _nonFoodKeywords.entries) {
      if (RegExp('\\b${entry.key}').hasMatch(clause)) return entry.value;
    }
    return null;
  }

  static final RegExp _negation = RegExp(
    r'\b(nggak|gak|ga|tidak|enggak) jadi\b|\bbatal\b',
  );

  static final RegExp _partlyUneaten = RegExp(
    r'\b(nggak|gak|ga|tidak|enggak|belum) (habis|dihabiskan)\b|\bsisa\b|'
    r'\bcuma dicicip',
  );

  // ---- Satu klausa ----------------------------------------------------

  static const List<String> _standardUnits = <String>[
    'sendok makan',
    'sendok teh',
    'piring',
    'mangkuk',
    'mangkok',
    'porsi',
    'potong',
    'buah',
    'butir',
    'biji',
    'lembar',
    'tusuk',
    'ekor',
    'gelas',
    'cangkir',
    'cup',
    'bungkus',
    'centong',
    'gram',
    'ml',
  ];

  static const List<String> _sizeWords = <String>[
    'besar',
    'kecil',
    'penuh',
    'jumbo',
    'sedang',
  ];

  /// Kata satuan tidak baku, beserta jumlah yang tersirat bila ada.
  static const Map<String, ({double? quantity, String unit})> _vagueUnits =
      <String, ({double? quantity, String unit})>{
        'segenggam': (quantity: 1, unit: 'genggam'),
        'secuil': (quantity: null, unit: 'secuil'),
        'sedikit': (quantity: null, unit: 'sedikit'),
        'dikit': (quantity: null, unit: 'sedikit'),
      };

  static const Set<String> _fillers = <String>{
    'tadi',
    'makan',
    'minum',
    'aku',
    'saya',
    'gw',
    'gue',
    'barusan',
    'ngemil',
    'sarapan',
    'siang',
    'malam',
    'pagi',
    'ini',
    'hari',
    'cuma',
    'juga',
    'eh',
    'apa',
    'ya',
    'tuh',
    'abis',
    'yang',
    'dong',
    'deh',
  };

  static const Map<String, String> _synonyms = <String, String>{
    'sambel': 'sambal',
    'mangkok': 'mangkuk',
  };

  ParsedFoodItem? _parseClause(String rawClause) {
    var clause = rawClause;
    // Koreksi diri: "tiga eh bukan dua potong" → pakai bagian terakhir.
    final correction = RegExp(r'^(.*?)\b(\w+) (eh )?bukan (.+)$');
    final corrected = correction.firstMatch(clause);
    if (corrected != null) {
      clause = '${corrected.group(1)!} ${corrected.group(4)!}'.trim();
    }
    clause = clause.replaceAll(RegExp(r'\blevel \w+'), ' ');

    var tokens = clause.split(' ').where((t) => t.isNotEmpty).toList();
    double? quantity;
    String? unit;
    var status = ParsedUnitStatus.missing;
    var quantityVague = false;

    // Satuan (dengan atau tanpa awalan "se-", dan ukuran sesudahnya).
    for (var i = 0; i < tokens.length && unit == null; i++) {
      for (final candidate in _standardUnits) {
        final words = candidate.split(' ');
        if (i + words.length > tokens.length) continue;
        final head = tokens.sublist(i, i + words.length).join(' ');
        final prefixed = head == 'se$candidate';
        if (head != candidate && !prefixed) continue;
        var end = i + words.length;
        unit = _synonyms[candidate] ?? candidate;
        status = ParsedUnitStatus.standard;
        if (prefixed) quantity = 1;
        if (end < tokens.length && _sizeWords.contains(tokens[end])) {
          unit = '$unit ${tokens[end]}';
          status = ParsedUnitStatus.nonstandard;
          end++;
        }
        tokens = <String>[...tokens.sublist(0, i), ...tokens.sublist(end)];
        if (!prefixed) {
          final number = _numberBefore(tokens, i);
          if (number != null) {
            quantity = number.value;
            tokens.removeRange(number.start, i);
          }
        }
        break;
      }
    }

    // "sendok" tanpa keterangan selalu tidak baku.
    if (unit == null) {
      final idx = tokens.indexOf('sendok');
      if (idx >= 0) {
        unit = 'sendok';
        status = ParsedUnitStatus.nonstandard;
        tokens.removeAt(idx);
        final number = _numberBefore(tokens, idx);
        if (number != null) {
          quantity = number.value;
          tokens.removeRange(number.start, idx);
        }
      }
    }

    // Satuan samar.
    if (unit == null) {
      for (var i = 0; i < tokens.length; i++) {
        final vague = _vagueUnits[tokens[i]];
        if (vague == null) continue;
        unit = vague.unit;
        quantity = vague.quantity;
        status = ParsedUnitStatus.nonstandard;
        tokens.removeAt(i);
        break;
      }
    }

    if (tokens.contains('beberapa')) {
      quantityVague = true;
      tokens.remove('beberapa');
    }

    // Angka berdiri sendiri tanpa satuan ("tempe dua").
    if (quantity == null && !quantityVague && unit == null) {
      for (var end = tokens.length; end > 0; end--) {
        final number = _numberBefore(tokens, end);
        if (number != null) {
          quantity = number.value;
          tokens.removeRange(number.start, end);
          break;
        }
      }
    }

    final name = tokens
        .where((t) => !_fillers.contains(t))
        .map(_stripPossessive)
        .map((t) => _synonyms[t] ?? t)
        .join(' ')
        .trim();
    if (name.isEmpty) return null;

    return ParsedFoodItem(
      foodName: name,
      quantity: quantityVague ? null : quantity,
      unit: unit,
      unitStatus: status,
      needsCheck: true,
    );
  }

  static String _stripPossessive(String token) =>
      token.length > 5 && token.endsWith('nya')
      ? token.substring(0, token.length - 3)
      : token;

  // ---- Bilangan -------------------------------------------------------

  static const Map<String, int> _digits = <String, int>{
    'satu': 1,
    'dua': 2,
    'tiga': 3,
    'empat': 4,
    'lima': 5,
    'enam': 6,
    'tujuh': 7,
    'delapan': 8,
    'sembilan': 9,
  };

  static bool _isNumberWord(String t) =>
      _digits.containsKey(t) ||
      double.tryParse(t.replaceAll(',', '.')) != null ||
      const <String>{
        'setengah',
        'sepuluh',
        'sebelas',
        'seratus',
        'seribu',
        'belas',
        'puluh',
        'ratus',
        'ribu',
      }.contains(t);

  /// Bilangan yang berakhir tepat sebelum indeks [end].
  static ({double value, int start})? _numberBefore(
    List<String> tokens,
    int end,
  ) {
    var start = end;
    while (start > 0 && _isNumberWord(tokens[start - 1])) {
      start--;
    }
    if (start == end) return null;
    final value = _numberValue(tokens.sublist(start, end));
    if (value == null) return null;
    return (value: value, start: start);
  }

  static double? _numberValue(List<String> words) {
    if (words.length == 1) {
      final numeric = double.tryParse(words.single.replaceAll(',', '.'));
      if (numeric != null) return numeric;
      if (words.single == 'setengah') return 0.5;
    }
    var total = 0;
    var current = 0;
    for (final w in words) {
      final d = _digits[w];
      if (d != null) {
        current += d;
        continue;
      }
      switch (w) {
        case 'sepuluh':
          current += 10;
        case 'sebelas':
          current += 11;
        case 'seratus':
          total += 100;
        case 'seribu':
          total += 1000;
        case 'belas':
          current += 10;
        case 'puluh':
          current = (current == 0 ? 1 : current) * 10;
        case 'ratus':
          total += (current == 0 ? 1 : current) * 100;
          current = 0;
        case 'ribu':
          total = (total + (current == 0 ? 1 : current)) * 1000;
          current = 0;
        default:
          return null;
      }
    }
    final value = total + current;
    return value > 0 ? value.toDouble() : null;
  }
}
