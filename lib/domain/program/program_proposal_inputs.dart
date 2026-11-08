import 'package:mealora/domain/nutrition/activity_level.dart';
import 'package:mealora/domain/nutrition/biological_input.dart';
import 'package:mealora/domain/program/profile_screening_facts.dart';
import 'package:mealora/domain/program/program_specific_input.dart';
import 'package:mealora/domain/shared/units.dart';

/// Salinan masukan yang dipakai untuk menghitung sebuah proposal (Design
/// D9, D6) — dibandingkan ulang saat aktivasi untuk memastikan profil
/// belum berubah sejak pratinjau (program-lifecycle spec, "Aktivasi
/// memerlukan proposal yang disetujui dan konfirmasi pengguna").
final class ProgramProposalInputs {
  const ProgramProposalInputs({
    required this.ageYears,
    required this.biologicalInput,
    required this.height,
    required this.currentWeight,
    required this.activity,
    this.screening = const ProfileScreeningFacts(),
    this.specific = const ProgramSpecificInput(),
  });

  final int ageYears;
  final BiologicalInput biologicalInput;
  final Length height;
  final Mass currentWeight;
  final ActivityLevel activity;
  final ProfileScreeningFacts screening;
  final ProgramSpecificInput specific;

  /// Kesetaraan yang relevan untuk deteksi "masukan berubah sejak
  /// pratinjau" — membandingkan nilai fisiologis dan masukan khusus
  /// program yang benar-benar memengaruhi perhitungan.
  bool matches(ProgramProposalInputs other) =>
      ageYears == other.ageYears &&
      biologicalInput == other.biologicalInput &&
      height == other.height &&
      currentWeight == other.currentWeight &&
      activity == other.activity &&
      screening.isPregnantOrLactating ==
          other.screening.isPregnantOrLactating &&
      _setEquals(
        screening.declaredConditions,
        other.screening.declaredConditions,
      ) &&
      specific.targetWeight == other.specific.targetWeight &&
      specific.targetDate == other.specific.targetDate &&
      specific.habitFocus == other.specific.habitFocus;
}

bool _setEquals<T>(Set<T> a, Set<T> b) =>
    a.length == b.length && a.every(b.contains);
