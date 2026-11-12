import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/data/local/drift_diary_repository.dart';
import 'package:mealora/domain/diary/energy_trend.dart';
import 'package:mealora/features/diary/diary_controller.dart';
import 'package:mealora/features/onboarding/onboarding_controller.dart'
    show onboardingRefreshSignalProvider, profileRepositoryProvider;
import 'package:mealora/features/program/program_providers.dart';

/// Rentang tanggal `[from, to]` inklusif — kunci keluarga provider tren
/// energi (change 018).
final class EnergyRange {
  const EnergyRange(this.from, this.to);

  /// Tujuh hari terakhir sampai dan termasuk [today] (rentang bawaan layar
  /// pantauan energi).
  factory EnergyRange.lastSevenDays(LocalDate today) =>
      EnergyRange(shiftDate(today, -6), today);

  final LocalDate from;
  final LocalDate to;

  int get dayCount => datesBetween(from, to).length;

  @override
  bool operator ==(Object other) =>
      other is EnergyRange && other.from == from && other.to == to;

  @override
  int get hashCode => Object.hash(from, to);
}

/// Tren energi harian untuk satu rentang. Energi dari buku harian (design
/// D1), target per tanggal dari riwayat program (design D2).
final FutureProviderFamily<EnergyTrend, EnergyRange> energyTrendProvider =
    FutureProvider.family<EnergyTrend, EnergyRange>((ref, range) async {
      ref.watch(diaryRefreshSignalProvider);
      ref.watch(onboardingRefreshSignalProvider);
      final clock = ref.watch(clockProvider);
      final programs = await ref.watch(programHistoryProvider.future);
      final profile = await ref.watch(profileRepositoryProvider).current();
      final repository = ref.watch(diaryRepositoryProvider);

      final diary = profile != null && repository is DriftDiaryRepository
          ? await repository.dailyEnergyInRange(
              profile.id,
              from: range.from,
              to: range.to,
            )
          : const <String, DiaryDayEnergy>{};

      return EnergyTrend.build(
        from: range.from,
        to: range.to,
        today: clock.today(),
        diary: diary,
        targets: EnergyTargetTimeline.fromPrograms(programs, clock: clock),
      );
    });

/// Tanggal catatan makan pertama pengguna — batas awal pemilih rentang.
/// `null` bila belum ada catatan.
final FutureProvider<LocalDate?> firstDiaryDateProvider =
    FutureProvider<LocalDate?>((ref) async {
      ref.watch(diaryRefreshSignalProvider);
      ref.watch(onboardingRefreshSignalProvider);
      final profile = await ref.watch(profileRepositoryProvider).current();
      final repository = ref.watch(diaryRepositoryProvider);
      if (profile == null || repository is! DriftDiaryRepository) {
        return null;
      }
      return repository.firstEntryDate(profile.id);
    });
