/// Hari pertama dalam satu minggu untuk kalender Riwayat dan ringkasan
/// mingguan Program (rancangan `65 · Bahasa & tampilan`).
enum WeekStart {
  monday,
  sunday;

  static const WeekStart defaultValue = WeekStart.monday;

  String get stableCode => switch (this) {
    WeekStart.monday => 'monday',
    WeekStart.sunday => 'sunday',
  };

  static WeekStart fromStableCode(String code) => WeekStart.values.firstWhere(
    (v) => v.stableCode == code,
    orElse: () => defaultValue,
  );

  /// Nilai `DateTime.weekday` untuk hari pertama minggu ini.
  int get firstWeekday => switch (this) {
    WeekStart.monday => DateTime.monday,
    WeekStart.sunday => DateTime.sunday,
  };

  /// Jarak (0–6) dari awal minggu ke hari dengan [weekday] tersebut.
  int offsetOf(int weekday) => (weekday - firstWeekday) % 7;

  /// Huruf singkat hari, berurutan mulai dari awal minggu.
  List<String> get dayLetters => switch (this) {
    WeekStart.monday => const <String>['S', 'S', 'R', 'K', 'J', 'S', 'M'],
    WeekStart.sunday => const <String>['M', 'S', 'S', 'R', 'K', 'J', 'S'],
  };
}
