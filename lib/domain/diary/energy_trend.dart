import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/domain/program/program_state.dart';
import 'package:mealora/domain/program/user_program.dart';

/// Keadaan energi satu tanggal pada tren energi (change 018).
enum DailyEnergyState {
  /// Tidak ada catatan makan sama sekali — bukan 0 kkal.
  notRecorded,

  /// Ada catatan makan, tetapi energi salah satu catatan tidak diketahui.
  unknown,

  /// Ada catatan makan dengan total energi diketahui (boleh sebagian hari).
  recorded,

  /// Tanggal setelah hari ini — tidak ditampilkan sebagai data apa pun.
  future,
}

final class DailyEnergy {
  const DailyEnergy({
    required this.date,
    required this.state,
    this.kcal,
    this.targetKcal,
    this.unknownCount = 0,
  }) : assert(
         (state == DailyEnergyState.recorded) == (kcal != null),
         'kcal hanya diisi untuk tanggal tercatat',
       );

  final LocalDate date;
  final DailyEnergyState state;
  final double? kcal;

  /// Target energi program yang berlaku pada [date]; `null` bila tidak ada.
  final double? targetKcal;

  /// Catatan berenergi kosong pada tanggal tercatat (change 021): [kcal]
  /// lalu hanya batas bawah ("≥").
  final int unknownCount;

  bool get isPartial => unknownCount > 0;
}

/// Masukan energi satu tanggal dari buku harian.
final class DiaryDayEnergy {
  const DiaryDayEnergy.unknown() : kcal = null, unknownCount = 0;
  const DiaryDayEnergy.known(double this.kcal, {this.unknownCount = 0});

  /// `null` berarti tidak ada satu pun catatan yang energinya diketahui.
  final double? kcal;

  /// Catatan berenergi kosong di samping [kcal] (change 021).
  final int unknownCount;
}

/// Tren energi harian untuk rentang `[from, to]` inklusif (spec
/// energy-trend). Rata-rata hanya dari tanggal [DailyEnergyState.recorded].
final class EnergyTrend {
  const EnergyTrend._({
    required this.days,
    required this.averageKcal,
    required this.recordedDays,
    required this.targetKcal,
    required this.targetChanged,
  });

  /// Menyusun tren. [diary] berisi tanggal (ISO) yang punya catatan makan;
  /// tanggal yang tidak ada di [diary] berarti belum dicatat.
  factory EnergyTrend.build({
    required LocalDate from,
    required LocalDate to,
    required LocalDate today,
    required Map<String, DiaryDayEnergy> diary,
    required EnergyTargetTimeline targets,
  }) {
    final days = <DailyEnergy>[];
    for (final date in datesBetween(from, to)) {
      final target = targets.kcalOn(date);
      if (date.compareTo(today) > 0) {
        days.add(DailyEnergy(date: date, state: DailyEnergyState.future));
        continue;
      }
      final entry = diary[date.iso];
      if (entry == null) {
        days.add(
          DailyEnergy(
            date: date,
            state: DailyEnergyState.notRecorded,
            targetKcal: target,
          ),
        );
      } else if (entry.kcal == null) {
        days.add(
          DailyEnergy(
            date: date,
            state: DailyEnergyState.unknown,
            targetKcal: target,
          ),
        );
      } else {
        days.add(
          DailyEnergy(
            date: date,
            state: DailyEnergyState.recorded,
            kcal: entry.kcal,
            targetKcal: target,
            unknownCount: entry.unknownCount,
          ),
        );
      }
    }

    // Rata-rata hanya dari hari yang lengkap: hari parsial (change 021)
    // akan menarik rata-rata turun secara keliru.
    final recorded = days
        .where((d) => d.state == DailyEnergyState.recorded && !d.isPartial)
        .toList(growable: false);
    final average = recorded.isEmpty
        ? null
        : recorded.fold<double>(0, (sum, d) => sum + d.kcal!) / recorded.length;

    final targetValues = days
        .where((d) => d.state != DailyEnergyState.future)
        .map((d) => d.targetKcal)
        .whereType<double>()
        .toSet();

    return EnergyTrend._(
      days: List.unmodifiable(days),
      averageKcal: average,
      recordedDays: recorded.length,
      targetKcal: targetValues.length == 1 ? targetValues.single : null,
      targetChanged: targetValues.length > 1,
    );
  }

  final List<DailyEnergy> days;

  /// `null` bila tidak ada satu pun tanggal tercatat.
  final double? averageKcal;
  final int recordedDays;

  /// Target tunggal yang berlaku di seluruh rentang; `null` bila tidak ada
  /// target sama sekali atau target berubah ([targetChanged]).
  final double? targetKcal;
  final bool targetChanged;

  bool get hasAnyRecord => days.any(
    (d) =>
        d.state == DailyEnergyState.recorded ||
        d.state == DailyEnergyState.unknown,
  );
}

/// Seluruh tanggal kalender `[from, to]` inklusif.
Iterable<LocalDate> datesBetween(LocalDate from, LocalDate to) sync* {
  var current = DateTime(from.year, from.month, from.day);
  final end = DateTime(to.year, to.month, to.day);
  while (!current.isAfter(end)) {
    yield LocalDate(current.year, current.month, current.day);
    current = DateTime(current.year, current.month, current.day + 1);
  }
}

/// Menggeser [date] sebanyak [days] hari kalender.
LocalDate shiftDate(LocalDate date, int days) {
  final shifted = DateTime(date.year, date.month, date.day + days);
  return LocalDate(shifted.year, shifted.month, shifted.day);
}

/// Target energi per tanggal, diturunkan dari riwayat program (design D2,
/// change 018): program yang berjalan pada tanggal itu dan tidak sedang
/// dijeda. Revisi target membuat program baru yang menggantikan yang lama,
/// jadi tanggal mulai program pengganti menjadi tanggal berlakunya target
/// baru. Bila dua program bersinggungan di satu tanggal, yang dimulai paling
/// akhir yang berlaku.
final class EnergyTargetTimeline {
  EnergyTargetTimeline.fromPrograms(
    Iterable<UserProgram> programs, {
    required Clock clock,
  }) : _spans =
           programs
               .where(
                 (p) =>
                     p.state != ProgramState.draft &&
                     p.proposal.energyTarget != null,
               )
               .map((p) => _ProgramSpan.of(p, clock))
               .toList(growable: false)
             ..sort((a, b) => a.start.compareTo(b.start));

  const EnergyTargetTimeline.empty() : _spans = const <_ProgramSpan>[];

  final List<_ProgramSpan> _spans;

  double? kcalOn(LocalDate date) {
    for (final span in _spans.reversed) {
      if (span.covers(date)) {
        return span.kcal;
      }
    }
    return null;
  }
}

final class _ProgramSpan {
  _ProgramSpan({
    required this.start,
    required this.end,
    required this.pauses,
    required this.kcal,
  });

  factory _ProgramSpan.of(UserProgram program, Clock clock) {
    final ended = program.endedAt;
    return _ProgramSpan(
      start: clock.localDateOf(program.startedAt),
      // Program yang sudah berakhir masih berlaku pada tanggal berakhirnya
      // kecuali digantikan program lain yang dimulai di tanggal yang sama.
      end: ended == null ? null : clock.localDateOf(ended),
      pauses: <(LocalDate, LocalDate?)>[
        for (final pause in program.pauseIntervals)
          (
            clock.localDateOf(pause.startedAt),
            pause.endedAt == null ? null : clock.localDateOf(pause.endedAt!),
          ),
      ],
      kcal: program.proposal.energyTarget!.kcal,
    );
  }

  final LocalDate start;
  final LocalDate? end;
  final List<(LocalDate, LocalDate?)> pauses;
  final double kcal;

  bool covers(LocalDate date) {
    if (date.compareTo(start) < 0) {
      return false;
    }
    if (end != null && date.compareTo(end!) > 0) {
      return false;
    }
    for (final (pauseStart, pauseEnd) in pauses) {
      final afterStart = date.compareTo(pauseStart) >= 0;
      final beforeEnd = pauseEnd == null || date.compareTo(pauseEnd) < 0;
      if (afterStart && beforeEnd) {
        return false;
      }
    }
    return true;
  }
}
