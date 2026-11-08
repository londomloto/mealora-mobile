import 'package:mealora/domain/program/onboarding_field.dart';
import 'package:mealora/domain/program/program_code.dart';

/// Definisi satu program di katalog — data acuan, bukan pendaftaran
/// pengguna (program-catalog spec, "Definisi program terpisah dari program
/// pengguna").
final class ProgramDefinition {
  const ProgramDefinition({
    required this.code,
    required this.displayName,
    required this.intent,
    required this.requiresTargetWeight,
    required this.requiredInputs,
    required this.optionalInputs,
    this.isAvailable = true,
  });

  final ProgramCode code;

  /// Nama tampilan berbahasa Indonesia (mis. "Turun Berat"). Data katalog,
  /// bukan hasil pemetaan kode alasan.
  final String displayName;

  /// Maksud program dalam bahasa sehari-hari (mis. "Menurunkan berat badan
  /// dengan target terkawal").
  final String intent;

  final bool requiresTargetWeight;

  final Set<OnboardingField> requiredInputs;
  final Set<OnboardingField> optionalInputs;

  /// Penanda ketersediaan: program yang ditarik ditandai `false`, tidak
  /// dihapus, sehingga riwayat pengguna lama tetap dapat merujuknya.
  final bool isAvailable;

  ProgramDefinition withAvailability(bool isAvailable) => ProgramDefinition(
    code: code,
    displayName: displayName,
    intent: intent,
    requiresTargetWeight: requiresTargetWeight,
    requiredInputs: requiredInputs,
    optionalInputs: optionalInputs,
    isAvailable: isAvailable,
  );
}
