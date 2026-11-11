import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/domain/voice_input/food_sentence_parser.dart';
import 'package:mealora/domain/voice_input/rule_based_food_sentence_parser.dart';

/// Task 5.11 (change 012): pengurai di perangkat diuji dengan himpunan uji
/// evaluasi yang sama dengan model (salinan
/// `mealora-plans/docs/voice-parsing-eval-set.jsonl`).
///
/// M4 (jumlah tidak dikarang) dan M6 (tidak ada komponen dari kalimat di
/// luar cakupan) wajib 100%. Metrik lain dicetak sebagai pembanding.
void main() {
  const parser = RuleBasedFoodSentenceParser();
  final cases = File('test/fixtures/voice-parsing-eval-set.jsonl')
      .readAsLinesSync()
      .where((l) => l.trim().isNotEmpty)
      .map((l) => jsonDecode(l) as Map<String, Object?>)
      .toList(growable: false);

  String norm(String s) => s.toLowerCase().trim();

  test('M4: jumlah yang tidak disebut tidak pernah dikarang', () {
    final violations = <String>[];
    for (final c in cases) {
      final result = parser.parseSentence(c['text']! as String);
      for (final key in (c['items']! as List).cast<Map<String, Object?>>()) {
        if (key['qty'] != null) continue;
        for (final item in result.items) {
          if (norm(item.foodName) == norm(key['name']! as String) &&
              item.quantity != null) {
            violations.add('${c['id']}: ${item.foodName} = ${item.quantity}');
          }
        }
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('M6: kalimat di luar cakupan tidak menghasilkan komponen', () {
    final violations = <String>[];
    for (final c in cases.where((c) => c['cat'] == 'out_of_scope')) {
      final result = parser.parseSentence(c['text']! as String);
      if (result.hasItems) {
        violations.add(
          '${c['id']}: ${result.items.map((i) => i.foodName).join(', ')}',
        );
      }
      expect(result.nonFoodRequests, isNotEmpty, reason: '${c['id']}');
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('M7: bagian bukan makanan pada kalimat bercampur tidak menjadi '
      'komponen', () {
    final violations = <String>[];
    for (final c in cases.where((c) => c['cat'] == 'mixed')) {
      final keyNames = (c['items']! as List)
          .cast<Map<String, Object?>>()
          .map((k) => norm(k['name']! as String))
          .toSet();
      final result = parser.parseSentence(c['text']! as String);
      for (final item in result.items) {
        if (!keyNames.contains(norm(item.foodName))) {
          violations.add('${c['id']}: ${item.foodName}');
        }
      }
    }
    expect(violations, isEmpty, reason: violations.join('\n'));
  });

  test('setiap komponen ditandai perlu diperiksa (task 5.10)', () {
    for (final c in cases) {
      final result = parser.parseSentence(c['text']! as String);
      expect(result.source, ParseSource.onDevice);
      expect(result.items.every((i) => i.needsCheck), isTrue);
    }
  });

  test('pembanding terhadap model: F1 nama, jumlah dan satuan', () {
    var tp = 0;
    var fp = 0;
    var fn = 0;
    var qtyOk = 0;
    var qtyN = 0;
    for (final c in cases.where((c) => c['in_scope'] == true)) {
      final result = parser.parseSentence(c['text']! as String);
      final remaining = [...result.items];
      for (final key in (c['items']! as List).cast<Map<String, Object?>>()) {
        final idx = remaining.indexWhere(
          (i) => norm(i.foodName) == norm(key['name']! as String),
        );
        if (idx < 0) {
          fn++;
          continue;
        }
        tp++;
        final item = remaining.removeAt(idx);
        qtyN++;
        final keyQty = (key['qty'] as num?)?.toDouble();
        if (item.quantity == keyQty) qtyOk++;
      }
      fp += remaining.length;
    }
    final precision = tp / (tp + fp);
    final recall = tp / (tp + fn);
    final f1 = 2 * precision * recall / (precision + recall);
    // Dicatat, tidak menentukan kelulusan (design D14).
    // ignore: avoid_print
    print(
      'on-device parser: F1 ${f1.toStringAsFixed(3)}, '
      'jumlah tepat ${(qtyOk / qtyN).toStringAsFixed(3)} ($tp/$fp/$fn)',
    );
    expect(f1, greaterThan(0));
  });

  test('contoh spec: tiga makanan beserta jumlah dan satuan', () {
    final result = parser.parseSentence(
      'nasi satu piring, ayam bakar satu potong, tempe dua',
    );
    expect(result.items.map((i) => i.foodName), <String>[
      'nasi',
      'ayam bakar',
      'tempe',
    ]);
    expect(result.items.map((i) => i.quantity), <double?>[1, 1, 2]);
    expect(result.items.map((i) => i.unit), <String?>[
      'piring',
      'potong',
      null,
    ]);
  });
}
