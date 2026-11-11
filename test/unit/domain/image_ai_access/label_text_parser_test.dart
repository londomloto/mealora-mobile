import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/domain/image_ai_access/label_extraction.dart';
import 'package:mealora/domain/image_ai_access/label_text_parser.dart';
import 'package:mealora/domain/image_ai_access/reading_confidence.dart';

void main() {
  const parser = LabelTextParser();

  group('energi — tidak tertukar dengan energi dari lemak', () {
    test('baris "Energi Total" dengan satuan eksplisit -> confident', () {
      final extraction = parser.parse(
        'INFORMASI NILAI GIZI\n'
        'Energi Total 150 kkal\n'
        'Energi dari Lemak 45 kkal\n',
      );

      expect(extraction.energyKcal.confidence, ReadingConfidence.confident);
      expect(extraction.energyKcal.value, 150);
      expect(
        extraction.energyKcal.value,
        isNot(45),
        reason:
            'SHALL TIDAK mengambil angka dari baris "Energi dari Lemak" '
            'sebagai energi total',
      );
    });

    test('hanya ada baris "Energi dari Lemak", tanpa "Energi Total" -> unread, '
        'bukan ditebak dari baris yang dikecualikan', () {
      final extraction = parser.parse('Energi dari Lemak 45 kkal\n');

      expect(extraction.energyKcal.confidence, ReadingConfidence.unread);
      expect(extraction.energyKcal.value, isNull);
    });

    test(
      'baris "Energi" tanpa kualifier "Total" -> needsCheck, bukan unread',
      () {
        final extraction = parser.parse('Energi 190 kkal\n');

        expect(extraction.energyKcal.confidence, ReadingConfidence.needsCheck);
        expect(extraction.energyKcal.value, 190);
      },
    );

    test('tidak ada baris energi sama sekali -> unread, tidak ditebak', () {
      final extraction = parser.parse('Protein 5 g\n');

      expect(extraction.energyKcal.confidence, ReadingConfidence.unread);
      expect(extraction.energyKcal.value, isNull);
    });

    test('catatan AKG "kebutuhan energi 2150 kkal" SHALL TIDAK terambil '
        'sebagai energi produk — regresi temuan pengujian perangkat', () {
      final extraction = parser.parse(
        'Energi Total 150 kkal\n'
        '*Persen AKG berdasarkan kebutuhan energi 2150 kkal\n',
      );

      expect(extraction.energyKcal.value, 150);
      expect(
        extraction.energyKcal.value,
        isNot(2150),
        reason:
            '2150 adalah angka acuan AKG harian, bukan energi per sajian '
            'produk ini',
      );
    });

    test('HANYA ada catatan AKG, tanpa baris energi produk -> unread, bukan '
        '2150', () {
      final extraction = parser.parse(
        '*Persen AKG berdasarkan kebutuhan energi 2150 kkal\n',
      );

      expect(extraction.energyKcal.confidence, ReadingConfidence.unread);
      expect(extraction.energyKcal.value, isNull);
    });
  });

  group('lemak — tidak tertukar dengan lemak jenuh/trans', () {
    test('"Lemak Total" eksplisit -> confident, bukan angka lemak jenuh', () {
      final extraction = parser.parse(
        'Lemak Total 10 g\n'
        'Lemak Jenuh 4 g\n'
        'Lemak Trans 0 g\n',
      );

      expect(extraction.fat.confidence, ReadingConfidence.confident);
      expect(extraction.fat.value, 10);
    });

    test(
      'hanya ada "Lemak Jenuh" -> unread, bukan dipakai sebagai lemak total',
      () {
        final extraction = parser.parse('Lemak Jenuh 4 g\n');

        expect(extraction.fat.confidence, ReadingConfidence.unread);
        expect(extraction.fat.value, isNull);
      },
    );

    test('"Lemak" longgar tanpa kualifier -> needsCheck', () {
      final extraction = parser.parse('Lemak 8 g\n');

      expect(extraction.fat.confidence, ReadingConfidence.needsCheck);
      expect(extraction.fat.value, 8);
    });
  });

  group('protein dan karbohidrat', () {
    test('"Protein" dengan satuan langsung -> confident', () {
      final extraction = parser.parse('Protein 5 g\n');

      expect(extraction.protein.confidence, ReadingConfidence.confident);
      expect(extraction.protein.value, 5);
    });

    test('angka berkoma Indonesia (2,5 g) terbaca sebagai desimal', () {
      final extraction = parser.parse('Protein 2,5 g\n');

      expect(extraction.protein.value, 2.5);
    });

    test('"Karbohidrat Total" eksplisit -> confident', () {
      final extraction = parser.parse('Karbohidrat Total 18 g\n');

      expect(extraction.carbohydrate.confidence, ReadingConfidence.confident);
      expect(extraction.carbohydrate.value, 18);
    });

    test('tidak ada baris karbohidrat -> unread', () {
      final extraction = parser.parse('Energi Total 150 kkal\n');

      expect(extraction.carbohydrate.confidence, ReadingConfidence.unread);
      expect(extraction.carbohydrate.value, isNull);
    });
  });

  group('basis — tidak pernah confident dari OCR (Design D6)', () {
    test('"per 100 g" terbaca sebagai perHundredGrams, tapi needsCheck', () {
      final extraction = parser.parse('Informasi Nilai Gizi per 100 g\n');

      expect(extraction.basis.kind, ExtractedBasisKind.perHundredGrams);
      expect(extraction.basis.confidence, ReadingConfidence.needsCheck);
    });

    test('"Takaran Saji" terbaca sebagai perServing, tapi needsCheck', () {
      final extraction = parser.parse('Takaran Saji 30 g\n');

      expect(extraction.basis.kind, ExtractedBasisKind.perServing);
      expect(extraction.basis.confidence, ReadingConfidence.needsCheck);
    });

    test('tidak ada penanda basis -> unread, tidak ditebak', () {
      final extraction = parser.parse('Energi Total 150 kkal\n');

      expect(extraction.basis.kind, ExtractedBasisKind.unread);
      expect(extraction.basis.confidence, ReadingConfidence.unread);
    });
  });

  group('ukuran sajian dan jumlah sajian per kemasan', () {
    test('"Takaran Saji 30 g" -> confident', () {
      final extraction = parser.parse('Takaran Saji 30 g\n');

      expect(extraction.servingSize.confidence, ReadingConfidence.confident);
      expect(extraction.servingSize.value, 30);
      expect(extraction.servingSize.unit, 'g');
    });

    test('"2 Sajian per Kemasan" -> confident', () {
      final extraction = parser.parse('2 Sajian per Kemasan\n');

      expect(
        extraction.servingsPerPackage.confidence,
        ReadingConfidence.confident,
      );
      expect(extraction.servingsPerPackage.value, 2);
    });

    test(
      '"Jumlah Sajian per Kemasan: 2" (angka di belakang) -> needsCheck',
      () {
        final extraction = parser.parse('Jumlah Sajian per Kemasan: 2\n');

        expect(
          extraction.servingsPerPackage.confidence,
          ReadingConfidence.needsCheck,
        );
        expect(extraction.servingsPerPackage.value, 2);
      },
    );

    test('"Jumlah Sajian per Kemasan" dan angkanya di baris TERPISAH (tabel '
        'yang terpecah ML Kit) -> needsCheck, bukan unread', () {
      final extraction = parser.parse('Jumlah Sajian per Kemasan\n2\n');

      expect(
        extraction.servingsPerPackage.confidence,
        ReadingConfidence.needsCheck,
      );
      expect(extraction.servingsPerPackage.value, 2);
    });
  });

  group('tabel yang terpecah ML Kit — kata kunci dan angka di baris terpisah '
      '(regresi temuan pengujian perangkat: "energi, protein, karbo, lemak '
      'sering kosong")', () {
    test(
      '"Energi Total" lalu "150 kkal" di baris berikutnya -> needsCheck',
      () {
        final extraction = parser.parse('Energi Total\n150 kkal\n');

        expect(extraction.energyKcal.confidence, ReadingConfidence.needsCheck);
        expect(extraction.energyKcal.value, 150);
      },
    );

    test('"Protein" lalu "2 g" di baris berikutnya -> needsCheck', () {
      final extraction = parser.parse('Protein\n2 g\n');

      expect(extraction.protein.confidence, ReadingConfidence.needsCheck);
      expect(extraction.protein.value, 2);
    });

    test(
      '"Karbohidrat Total" lalu "18 g" di baris berikutnya -> needsCheck',
      () {
        final extraction = parser.parse('Karbohidrat Total\n18 g\n');

        expect(
          extraction.carbohydrate.confidence,
          ReadingConfidence.needsCheck,
        );
        expect(extraction.carbohydrate.value, 18);
      },
    );

    test('"Lemak Total" lalu "5 g" di baris berikutnya -> needsCheck', () {
      final extraction = parser.parse('Lemak Total\n5 g\n');

      expect(extraction.fat.confidence, ReadingConfidence.needsCheck);
      expect(extraction.fat.value, 5);
    });

    test('"Lemak Jenuh" (dikecualikan) sebelum "Lemak Total" — baris '
        'berikutnya milik "Lemak Jenuh" SHALL TIDAK diambil sebagai lemak '
        'total', () {
      final extraction = parser.parse('Lemak Jenuh\n2 g\nLemak Total\n5 g\n');

      expect(extraction.fat.value, 5);
    });

    test(
      'kolom %AKG di baris berikutnya SHALL TIDAK terambil sebagai nilai',
      () {
        final extraction = parser.parse('Protein\n8%\n');

        expect(
          extraction.protein.confidence,
          ReadingConfidence.unread,
          reason:
              '"8%" bukan angka gizi berdiri sendiri yang dikenal '
              '(satuan dibatasi ke g/kkal/kal/ml)',
        );
        expect(extraction.protein.value, isNull);
      },
    );

    test('seluruh baris tabel terpecah sekaligus -> semua terbaca', () {
      final extraction = parser.parse(
        'INFORMASI NILAI GIZI\n'
        'Takaran Saji 30 g\n'
        'Jumlah Sajian per Kemasan\n'
        '2\n'
        'Energi Total\n'
        '150 kkal\n'
        'Protein\n'
        '2 g\n'
        'Karbohidrat Total\n'
        '18 g\n'
        'Lemak Total\n'
        '5 g\n'
        '*Persen AKG berdasarkan kebutuhan energi 2150 kkal\n',
      );

      expect(extraction.servingSize.value, 30);
      expect(extraction.servingsPerPackage.value, 2);
      expect(extraction.energyKcal.value, 150);
      expect(extraction.protein.value, 2);
      expect(extraction.carbohydrate.value, 18);
      expect(extraction.fat.value, 5);
    });
  });

  test('teks kosong -> seluruh nilai unread, tidak ada yang ditebak', () {
    final extraction = parser.parse('');

    expect(extraction.basis.confidence, ReadingConfidence.unread);
    expect(extraction.servingSize.confidence, ReadingConfidence.unread);
    expect(extraction.servingsPerPackage.confidence, ReadingConfidence.unread);
    expect(extraction.energyKcal.confidence, ReadingConfidence.unread);
    expect(extraction.protein.confidence, ReadingConfidence.unread);
    expect(extraction.carbohydrate.confidence, ReadingConfidence.unread);
    expect(extraction.fat.confidence, ReadingConfidence.unread);
  });

  test('label lengkap yang bersih terbaca confident di seluruh nilai', () {
    final extraction = parser.parse(
      'INFORMASI NILAI GIZI\n'
      'Takaran Saji 30 g\n'
      '2 Sajian per Kemasan\n'
      'Energi Total 150 kkal\n'
      'Energi dari Lemak 45 kkal\n'
      'Lemak Total 5 g\n'
      'Lemak Jenuh 2 g\n'
      'Karbohidrat Total 18 g\n'
      'Protein 2 g\n',
    );

    expect(extraction.servingSize.value, 30);
    expect(extraction.servingsPerPackage.value, 2);
    expect(extraction.energyKcal.value, 150);
    expect(extraction.fat.value, 5);
    expect(extraction.carbohydrate.value, 18);
    expect(extraction.protein.value, 2);
    expect(
      extraction.basis.confidence,
      ReadingConfidence.needsCheck,
      reason: 'basis SHALL TIDAK pernah confident dari OCR (Design D6)',
    );
  });
}
