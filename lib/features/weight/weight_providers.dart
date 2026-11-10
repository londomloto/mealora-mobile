import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/domain/weight/weight_record.dart';
import 'package:mealora/features/onboarding/onboarding_controller.dart'
    show onboardingRefreshSignalProvider;
import 'package:mealora/features/weight/weight_controller.dart';

/// Rentang pengambilan "Catatan terakhir": lebih panjang daripada jendela
/// tren grafik, supaya daftar riwayat tidak ikut terpotong ketika jendela
/// grafik dipersempit (design.md Open Questions, change 008) — mencakup
/// hari ini. `kWeightTrendWindowDays` di `weight_trend_chart.dart` mengambil
/// irisan lebih sempit dari hasil yang sama untuk digambar.
const int kWeightRecentRecordsWindowDays = 28;

/// Catatan berat milik profil ini pada [kWeightRecentRecordsWindowDays] hari
/// terakhir, terlama lebih dulu — dipakai baik untuk tren maupun daftar
/// catatan terakhir (task 2.3), dan untuk `WeightMonitorScreen` (`31`).
final FutureProvider<List<WeightRecord>> recentWeightRecordsProvider =
    FutureProvider<List<WeightRecord>>((ref) async {
      ref.watch(onboardingRefreshSignalProvider);
      ref.watch(weightRefreshSignalProvider);
      final profile = await ref.watch(currentProfileProvider.future);
      if (profile == null) {
        return const <WeightRecord>[];
      }
      final clock = ref.watch(clockProvider);
      final today = clock.today();
      final from = _minusDays(today, kWeightRecentRecordsWindowDays - 1);
      return ref
          .watch(weightRepositoryProvider)
          .recordsInRange(profile.id, from: from, to: today);
    });

/// Catatan terbaru milik profil ini, atau `null` bila belum ada satu pun
/// (design D1 — berat "saat ini" adalah catatan terbaru yang hidup).
final FutureProvider<WeightRecord?> latestWeightRecordProvider =
    FutureProvider<WeightRecord?>((ref) async {
      ref.watch(onboardingRefreshSignalProvider);
      ref.watch(weightRefreshSignalProvider);
      final profile = await ref.watch(currentProfileProvider.future);
      if (profile == null) {
        return null;
      }
      return ref.watch(weightRepositoryProvider).latest(profile.id);
    });

/// Catatan berat pada tepat satu tanggal lokal, atau `null` bila tidak ada
/// (task 5.5, change 008) — dipakai ruang Riwayat menampilkan berat yang
/// tercatat pada tanggal terpilih, bila ada.
final FutureProviderFamily<WeightRecord?, LocalDate>
weightRecordForDateProvider = FutureProvider.family<WeightRecord?, LocalDate>((
  ref,
  date,
) async {
  ref.watch(weightRefreshSignalProvider);
  final profile = await ref.watch(currentProfileProvider.future);
  if (profile == null) {
    return null;
  }
  final records = await ref
      .watch(weightRepositoryProvider)
      .recordsInRange(profile.id, from: date, to: date);
  return records.isEmpty ? null : records.last;
});

LocalDate _minusDays(LocalDate date, int days) {
  var cursor = DateTime(date.year, date.month, date.day);
  cursor = cursor.subtract(Duration(days: days));
  return LocalDate(cursor.year, cursor.month, cursor.day);
}
