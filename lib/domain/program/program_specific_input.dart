import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/domain/shared/units.dart';

/// Masukan yang berbeda per program (program-catalog spec, "Masukan yang
/// diminta per program").
final class ProgramSpecificInput {
  const ProgramSpecificInput({
    this.targetWeight,
    this.targetDate,
    this.requestedPaceKgPerWeek,
    this.habitFocus,
    this.preferredMaintenanceRange,
  });

  /// Berat tujuan — wajib untuk `weight_loss`/`weight_gain`, selalu kosong
  /// untuk `healthy_eating` (E6, E7, E8).
  final Mass? targetWeight;

  /// Tanggal tujuan — SHALL TIDAK pernah wajib (E6).
  final LocalDate? targetDate;

  /// Laju yang diminta secara langsung (kg/minggu), dipakai bila pengguna
  /// memilih laju alih-alih tanggal. Bila keduanya diisi, [targetDate]
  /// dipakai untuk menurunkan laju yang sebenarnya diminta.
  final double? requestedPaceKgPerWeek;

  /// Fokus kebiasaan yang dipilih — wajib untuk `healthy_eating`.
  final String? habitFocus;

  /// Rentang pemeliharaan yang disukai — opsional untuk `maintenance`.
  final String? preferredMaintenanceRange;
}
