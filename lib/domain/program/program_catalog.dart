import 'package:mealora/domain/program/onboarding_field.dart';
import 'package:mealora/domain/program/program_code.dart';
import 'package:mealora/domain/program/program_definition.dart';

const _commonInputs = <OnboardingField>{
  OnboardingField.ageOrBirthDate,
  OnboardingField.biologicalInput,
  OnboardingField.height,
  OnboardingField.currentWeight,
  OnboardingField.activityLevel,
  OnboardingField.eligibilityScreening,
};

/// Katalog program Mealora: tepat empat program (program-catalog spec,
/// "Katalog berisi tepat empat program").
///
/// Instance, bukan konstanta statis murni — change 004 memindahkan sumber
/// kebenaran ke tabel basis data; domain di sini diuji agar definisi
/// standarnya ([ProgramCatalog.np1]) dan perilaku penarikan program benar
/// sebelum dipindahkan (Design D10).
final class ProgramCatalog {
  const ProgramCatalog(this.definitions);

  final List<ProgramDefinition> definitions;

  static const np1 = ProgramCatalog(<ProgramDefinition>[
    ProgramDefinition(
      code: ProgramCode.weightLoss,
      displayName: 'Turun Berat',
      intent: 'Menurunkan berat badan dengan target terkawal',
      requiresTargetWeight: true,
      requiredInputs: <OnboardingField>{
        ..._commonInputs,
        OnboardingField.targetWeight,
      },
      optionalInputs: <OnboardingField>{OnboardingField.targetDate},
    ),
    ProgramDefinition(
      code: ProgramCode.weightGain,
      displayName: 'Naik Berat',
      intent: 'Menambah berat badan dengan target terkawal',
      requiresTargetWeight: true,
      requiredInputs: <OnboardingField>{
        ..._commonInputs,
        OnboardingField.targetWeight,
      },
      optionalInputs: <OnboardingField>{OnboardingField.targetDate},
    ),
    ProgramDefinition(
      code: ProgramCode.maintenance,
      displayName: 'Pertahankan',
      intent: 'Menjaga keseimbangan berat dan energi',
      requiresTargetWeight: false,
      requiredInputs: _commonInputs,
      optionalInputs: <OnboardingField>{
        OnboardingField.preferredMaintenanceRange,
      },
    ),
    ProgramDefinition(
      code: ProgramCode.healthyEating,
      displayName: 'Makan Sehat',
      intent: 'Memperbaiki kualitas dan konsistensi makan',
      requiresTargetWeight: false,
      requiredInputs: <OnboardingField>{
        ..._commonInputs,
        OnboardingField.habitFocus,
      },
      optionalInputs: <OnboardingField>{},
    ),
  ]);

  /// Program yang dapat dipilih pengguna baru — program yang ditarik tidak
  /// muncul di sini.
  List<ProgramDefinition> availableForSelection() =>
      definitions.where((d) => d.isAvailable).toList(growable: false);

  /// Definisi program ini, tersedia atau tidak — dipakai untuk menampilkan
  /// riwayat pengguna yang pernah memakai program yang kini sudah ditarik.
  ProgramDefinition definitionFor(ProgramCode code) =>
      definitions.firstWhere((d) => d.code == code);

  /// Katalog baru dengan [code] ditandai tidak tersedia. Definisinya tetap
  /// dapat dibaca lewat [definitionFor].
  ProgramCatalog withdrawn(ProgramCode code) => ProgramCatalog(
    definitions
        .map((d) => d.code == code ? d.withAvailability(false) : d)
        .toList(growable: false),
  );
}
