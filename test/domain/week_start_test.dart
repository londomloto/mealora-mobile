import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/domain/preferences/week_start.dart';

void main() {
  test('offset dihitung dari awal minggu yang dipilih', () {
    expect(WeekStart.monday.offsetOf(DateTime.monday), 0);
    expect(WeekStart.monday.offsetOf(DateTime.sunday), 6);
    expect(WeekStart.sunday.offsetOf(DateTime.sunday), 0);
    expect(WeekStart.sunday.offsetOf(DateTime.monday), 1);
    expect(WeekStart.sunday.offsetOf(DateTime.saturday), 6);
  });

  test('kode tersimpan bolak-balik, kode asing jatuh ke bawaan', () {
    for (final v in WeekStart.values) {
      expect(WeekStart.fromStableCode(v.stableCode), v);
    }
    expect(WeekStart.fromStableCode('x'), WeekStart.monday);
  });

  test('huruf hari mulai dari awal minggu', () {
    expect(WeekStart.monday.dayLetters.first, 'S');
    expect(WeekStart.sunday.dayLetters.first, 'M');
  });
}
