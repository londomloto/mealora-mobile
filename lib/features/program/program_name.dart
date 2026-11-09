import 'package:mealora/domain/program/program_code.dart';
import 'package:mealora/l10n/generated/app_localizations.dart';

/// Nama program yang ditampilkan ke pengguna — satu sumber dipakai seluruh
/// layar ruang Program (sebelumnya diduplikasi per layar, sama seperti
/// `features/onboarding/program_detail_screen.dart`).
String programDisplayName(AppText text, ProgramCode code) => switch (code) {
  ProgramCode.healthyEating => text.onboardingProgramHealthyName,
  ProgramCode.weightLoss => text.onboardingProgramWeightLossName,
  ProgramCode.weightGain => text.onboardingProgramWeightGainName,
  ProgramCode.maintenance => text.onboardingProgramMaintenanceName,
};

String programDescription(AppText text, ProgramCode code) => switch (code) {
  ProgramCode.healthyEating => text.onboardingProgramHealthyDescription,
  ProgramCode.weightLoss => text.onboardingProgramWeightLossDescription,
  ProgramCode.weightGain => text.onboardingProgramWeightGainDescription,
  ProgramCode.maintenance => text.onboardingProgramMaintenanceDescription,
};
