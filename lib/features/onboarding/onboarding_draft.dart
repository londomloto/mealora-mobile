import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/domain/nutrition/activity_level.dart';
import 'package:mealora/domain/nutrition/biological_input.dart';
import 'package:mealora/domain/program/program_code.dart';
import 'package:mealora/domain/program/program_proposal_inputs.dart';
import 'package:mealora/domain/program/program_target_proposal.dart';
import 'package:mealora/domain/shared/program_outcome.dart';
import 'package:mealora/domain/shared/units.dart';
import 'package:mealora/features/onboarding/onboarding_step.dart';

/// Masukan onboarding yang terkumpul sejauh ini (Design D9) — satu wadah
/// untuk seluruh alur; setiap layar membaca hanya bagian yang relevan
/// baginya.
///
/// Masukan program (langkah `programSelect` dan seterusnya) tidak
/// tersimpan ke repositori seperti bidang profil (Design D3: "Pratinjau
/// tidak pernah menulis program") — ia hidup di sini sampai pengguna
/// menyetujui pratinjau, lalu perintah aktivasi (change 003/004) yang
/// menulisnya sekali, sebagai satu kesatuan.
final class OnboardingDraft {
  const OnboardingDraft({
    this.currentStep = OnboardingStep.welcome,
    this.profileId,
    this.nickname,
    this.birthDate,
    this.height,
    this.currentWeight,
    this.biologicalInput,
    this.activityLevel,
    this.selectedProgram,
    this.targetWeight,
    this.targetDate,
    this.habitFocus,
    this.estimateAcknowledged = false,
    this.previewInputs,
    this.lastOutcome,
  });

  final OnboardingStep currentStep;

  /// `null` sebelum langkah profil pertama kali disahkan — belum ada baris
  /// profil untuk disimpan (task 3.2: penyimpanan dimulai begitu langkah
  /// pertama sah, bukan sebelumnya).
  final String? profileId;

  final String? nickname;
  final LocalDate? birthDate;
  final Length? height;
  final Mass? currentWeight;
  final BiologicalInput? biologicalInput;
  final ActivityLevel? activityLevel;

  /// Program yang dipilih di langkah `10` (FRS 3.3.1).
  final ProgramCode? selectedProgram;

  /// Wajib untuk Turun Berat/Naik Berat, selalu `null` untuk program lain
  /// (FRS 3.3.3).
  final Mass? targetWeight;

  /// SHALL TIDAK pernah wajib (FRS 3.3.5).
  final LocalDate? targetDate;

  /// Wajib untuk Makan Sehat (FRS 3.3.4), `null` untuk program lain.
  final String? habitFocus;

  /// Pengakuan bahwa target dan data makanan adalah perkiraan (task 4.8,
  /// FRS 3.3.6) — wajib benar sebelum pratinjau ditampilkan.
  final bool estimateAcknowledged;

  /// Salinan masukan yang dipakai pratinjau (`12`), dibekukan begitu
  /// pratinjau pertama kali dihitung (Design D4/D9) — dibandingkan ulang
  /// oleh perintah aktivasi terhadap fakta terkini, bukan oleh lapisan
  /// tampilan. Diperbarui hanya ketika aktivasi membatalkan diri karena
  /// masukan berubah (Design D5), sehingga pratinjau berikutnya memakai
  /// nilai terbaru.
  final ProgramProposalInputs? previewInputs;

  /// Hasil `ProgramEngine.proposeTarget` terakhir untuk [previewInputs] —
  /// `Approved` ditampilkan di `12`, selain itu di `26` (task 6.1).
  final ProgramOutcome<ProgramTargetProposal>? lastOutcome;

  /// Bidang profil wajib (FRS 2.2) yang belum terisi — dipakai menahan
  /// kelengkapan onboarding (Design D2, task 3.3). Tidak termasuk langkah
  /// program, yang punya penahanannya sendiri (pengakuan perkiraan, task
  /// 4.8).
  List<String> get missingProfileFields => <String>[
    if (birthDate == null) 'birthDate',
    if (height == null) 'height',
    if (currentWeight == null) 'currentWeight',
    if (biologicalInput == null) 'biologicalInput',
    if (activityLevel == null) 'activityLevel',
  ];

  /// Program ini menuntut berat tujuan (Turun Berat/Naik Berat) — dipakai
  /// memutuskan apakah langkah `targetWeight` (`25`) dilalui (task 4.10).
  bool get requiresTargetWeight =>
      selectedProgram == ProgramCode.weightLoss ||
      selectedProgram == ProgramCode.weightGain;

  OnboardingDraft copyWith({
    OnboardingStep? currentStep,
    String? profileId,
    String? nickname,
    bool clearNickname = false,
    LocalDate? birthDate,
    Length? height,
    Mass? currentWeight,
    BiologicalInput? biologicalInput,
    ActivityLevel? activityLevel,
    ProgramCode? selectedProgram,
    Mass? targetWeight,
    bool clearTargetWeight = false,
    LocalDate? targetDate,
    bool clearTargetDate = false,
    String? habitFocus,
    bool clearHabitFocus = false,
    bool? estimateAcknowledged,
    ProgramProposalInputs? previewInputs,
    ProgramOutcome<ProgramTargetProposal>? lastOutcome,
    bool clearPreview = false,
  }) {
    return OnboardingDraft(
      currentStep: currentStep ?? this.currentStep,
      profileId: profileId ?? this.profileId,
      nickname: clearNickname ? null : (nickname ?? this.nickname),
      birthDate: birthDate ?? this.birthDate,
      height: height ?? this.height,
      currentWeight: currentWeight ?? this.currentWeight,
      biologicalInput: biologicalInput ?? this.biologicalInput,
      activityLevel: activityLevel ?? this.activityLevel,
      selectedProgram: selectedProgram ?? this.selectedProgram,
      targetWeight: clearTargetWeight
          ? null
          : (targetWeight ?? this.targetWeight),
      targetDate: clearTargetDate ? null : (targetDate ?? this.targetDate),
      habitFocus: clearHabitFocus ? null : (habitFocus ?? this.habitFocus),
      estimateAcknowledged: estimateAcknowledged ?? this.estimateAcknowledged,
      previewInputs: clearPreview
          ? null
          : (previewInputs ?? this.previewInputs),
      lastOutcome: clearPreview ? null : (lastOutcome ?? this.lastOutcome),
    );
  }
}
