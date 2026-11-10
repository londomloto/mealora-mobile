import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/data/local/drift_diary_repository.dart';
import 'package:mealora/features/diary/diary_controller.dart';
import 'package:mealora/features/onboarding/onboarding_controller.dart'
    show onboardingRefreshSignalProvider, profileRepositoryProvider;
import 'package:mealora/features/weight/weight_controller.dart';

/// Satu bulan kalender, dipakai sebagai kunci keluarga provider penanda
/// Riwayat (task 5.1/5.2, change 008).
final class HistoryMonth {
  const HistoryMonth(this.year, this.month);

  factory HistoryMonth.of(LocalDate date) =>
      HistoryMonth(date.year, date.month);

  final int year;
  final int month;

  LocalDate get firstDay => LocalDate(year, month, 1);

  LocalDate get lastDay {
    final nextMonthFirstDay = month == 12
        ? DateTime(year + 1, 1, 1)
        : DateTime(year, month + 1, 1);
    final last = nextMonthFirstDay.subtract(const Duration(days: 1));
    return LocalDate(last.year, last.month, last.day);
  }

  HistoryMonth shift(int delta) {
    final total = (year * 12 + (month - 1)) + delta;
    return HistoryMonth(total ~/ 12, total % 12 + 1);
  }

  @override
  bool operator ==(Object other) =>
      other is HistoryMonth && other.year == year && other.month == month;

  @override
  int get hashCode => Object.hash(year, month);
}

/// Tanggal lokal (ISO) dalam satu bulan yang punya catatan makan ATAU
/// catatan berat — dipakai menandai kalender Riwayat tanpa membedakan
/// jenis catatannya (design D7: penanda murni informatif, bukan
/// nilai/peringkat).
final FutureProviderFamily<Set<String>, HistoryMonth>
historyMonthMarkersProvider = FutureProvider.family<Set<String>, HistoryMonth>((
  ref,
  month,
) async {
  ref.watch(onboardingRefreshSignalProvider);
  final profile = await ref.watch(profileRepositoryProvider).current();
  if (profile == null) {
    return const <String>{};
  }

  final diaryRepository = ref.watch(diaryRepositoryProvider);
  final diaryDates = diaryRepository is DriftDiaryRepository
      ? await diaryRepository.datesWithEntries(
          profile.id,
          from: month.firstDay,
          to: month.lastDay,
        )
      : const <String>{};

  final weightRecords = await ref
      .watch(weightRepositoryProvider)
      .recordsInRange(profile.id, from: month.firstDay, to: month.lastDay);

  return <String>{
    ...diaryDates,
    for (final record in weightRecords) record.localDate.iso,
  };
});
