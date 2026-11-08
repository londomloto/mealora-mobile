import 'package:mealora/core/clock/clock.dart';

/// Satu potret kemajuan program pada satu tanggal lokal (change 004).
///
/// Bukan tipe domain (change 003 tidak mengenal potret kemajuan — buku
/// harian belum ada, design.md Non-Goals) — murni bentuk data yang
/// dikembalikan lapisan akses data, sehingga Drift tetap tidak bocor ke
/// pemanggil (Design D9) tanpa menambah kelas ke `lib/domain/`.
///
/// Seluruh kolom nilai bisa `null` — "belum diketahui", berbeda dari nol
/// (Design D6). [loggedMealsCount] dan [activeDayNumber] selalu terisi.
final class ProgramProgressSnapshot {
  const ProgramProgressSnapshot({
    required this.id,
    required this.userProgramId,
    required this.recordedLocalDate,
    required this.recordedAt,
    required this.loggedMealsCount,
    required this.diaryComplete,
    required this.activeDayNumber,
    required this.calculationVersion,
    this.weightKg,
    this.weightChangeKg,
    this.targetProgressRatio,
    this.consumedEnergyKcal,
    this.energyAdherenceRatio,
    this.proteinG,
    this.carbohydrateG,
    this.fatG,
  });

  final String id;
  final String userProgramId;
  final LocalDate recordedLocalDate;
  final DateTime recordedAt;
  final double? weightKg;
  final double? weightChangeKg;
  final double? targetProgressRatio;
  final double? consumedEnergyKcal;
  final double? energyAdherenceRatio;
  final double? proteinG;
  final double? carbohydrateG;
  final double? fatG;
  final int loggedMealsCount;
  final bool diaryComplete;
  final int activeDayNumber;
  final String calculationVersion;
}

/// Masukan untuk membangun ulang satu potret kemajuan (task 6.1, change
/// 004).
///
/// Murni wadah data — tidak menghitung apa pun ([weightChangeKg],
/// [targetProgressRatio], dan [energyAdherenceRatio] adalah nilai yang
/// SUDAH dihitung pemanggil, bukan diturunkan di sini. Lihat design.md
/// Non-Goals: "Tidak ada perhitungan kemajuan dari catatan makanan" —
/// perhitungan itu adalah tanggung jawab change buku harian berikutnya.
final class ProgramProgressInput {
  const ProgramProgressInput({
    required this.recordedAt,
    required this.loggedMealsCount,
    required this.diaryComplete,
    required this.activeDayNumber,
    required this.calculationVersion,
    this.weightKg,
    this.weightChangeKg,
    this.targetProgressRatio,
    this.consumedEnergyKcal,
    this.energyAdherenceRatio,
    this.proteinG,
    this.carbohydrateG,
    this.fatG,
    this.metricsJson,
  });

  final DateTime recordedAt;
  final double? weightKg;
  final double? weightChangeKg;
  final double? targetProgressRatio;
  final double? consumedEnergyKcal;
  final double? energyAdherenceRatio;
  final double? proteinG;
  final double? carbohydrateG;
  final double? fatG;
  final int loggedMealsCount;
  final bool diaryComplete;
  final int activeDayNumber;
  final String? metricsJson;
  final String calculationVersion;
}
