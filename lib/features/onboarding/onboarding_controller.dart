import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/errors/result.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/domain/nutrition/activity_level.dart';
import 'package:mealora/domain/nutrition/biological_input.dart';
import 'package:mealora/domain/nutrition/energy_equation_policy.dart';
import 'package:mealora/domain/nutrition/nutrition_calculator.dart';
import 'package:mealora/domain/nutrition/nutrition_estimate.dart';
import 'package:mealora/domain/nutrition/physiological_facts.dart';
import 'package:mealora/domain/profile/profile_repository.dart';
import 'package:mealora/domain/profile/profile_validation.dart';
import 'package:mealora/domain/profile/user_profile.dart';
import 'package:mealora/domain/program/commands/activate_program_command.dart';
import 'package:mealora/domain/program/commands/activation_result.dart';
import 'package:mealora/domain/program/nutrition_policy.dart';
import 'package:mealora/domain/program/program_code.dart';
import 'package:mealora/domain/program/program_engine.dart';
import 'package:mealora/domain/program/program_proposal_inputs.dart';
import 'package:mealora/domain/program/program_repository.dart';
import 'package:mealora/domain/program/program_specific_input.dart';
import 'package:mealora/domain/program/program_target_proposal.dart';
import 'package:mealora/domain/shared/program_outcome.dart';
import 'package:mealora/features/onboarding/onboarding_draft.dart';
import 'package:mealora/features/onboarding/onboarding_step.dart';

/// Diinjeksi di `main.dart`/pengujian, mengikuti pola `clockProvider`/
/// `idGeneratorProvider` (core/providers.dart).
final Provider<ProfileRepository> profileRepositoryProvider =
    Provider<ProfileRepository>(
      (ref) => throw UnimplementedError(
        'profileRepositoryProvider harus ditimpa di ProviderScope '
        '(lihat lib/main.dart dan test/).',
      ),
    );

/// Diinjeksi di `main.dart`/pengujian, sama seperti [profileRepositoryProvider].
final Provider<ProgramRepository> programRepositoryProvider =
    Provider<ProgramRepository>(
      (ref) => throw UnimplementedError(
        'programRepositoryProvider harus ditimpa di ProviderScope '
        '(lihat lib/main.dart dan test/).',
      ),
    );

/// Kebijakan gizi aktif — `np-1.0.0`, final untuk Mealora MVP 1 sejak
/// change 002 (D13); task 5.3 mengonstruksinya sebagai `approved`, bukan
/// `draft`, karena tidak ada gerbang persetujuan eksternal untuk MVP 1.
final Provider<NutritionPolicy> nutritionPolicyProvider =
    Provider<NutritionPolicy>(
      (ref) => NutritionPolicy.np100(status: PolicyApprovalStatus.approved),
    );

final Provider<ProgramEngine> programEngineProvider = Provider<ProgramEngine>(
  (ref) => ProgramEngine(ref.watch(nutritionPolicyProvider)),
);

final Provider<ActivateProgramCommand> activateProgramCommandProvider =
    Provider<ActivateProgramCommand>(
      (ref) => ActivateProgramCommand(
        repository: ref.watch(programRepositoryProvider),
        clock: ref.watch(clockProvider),
        idGenerator: ref.watch(idGeneratorProvider),
        engine: ref.watch(programEngineProvider),
      ),
    );

/// Penanda hitung yang dibaca `isOnboardingCompleteProvider` (app/providers,
/// change 005) — dinaikkan setiap kali aktivasi berhasil, memaksa gerbang
/// onboarding membaca ulang `ProfileRepository` alih-alih memakai cache
/// yang dihitung sebelum program aktif.
final StateProvider<int> onboardingRefreshSignalProvider = StateProvider<int>(
  (ref) => 0,
);

final AsyncNotifierProvider<OnboardingController, OnboardingDraft>
onboardingControllerProvider =
    AsyncNotifierProvider<OnboardingController, OnboardingDraft>(
      OnboardingController.new,
    );

/// Wadah state alur onboarding (Design D9, tasks 3.1–3.4): satu per alur,
/// bukan per layar — memuat masukan terkumpul dan langkah saat ini. Setiap
/// langkah yang sah disimpan segera ke `ProfileRepository` (Design D2,
/// task 3.2), sehingga menutup aplikasi di tengah jalan tidak
/// menghilangkan isian.
class OnboardingController extends AsyncNotifier<OnboardingDraft> {
  @override
  Future<OnboardingDraft> build() async {
    final repository = ref.watch(profileRepositoryProvider);
    final existing = await repository.current();
    if (existing == null) {
      return const OnboardingDraft();
    }
    // Profil sudah ada dari sesi onboarding sebelumnya yang belum selesai
    // (Design D2, task 3.5) — melanjutkan dari langkah pertama yang
    // datanya belum lengkap, bukan mengulang dari sambutan.
    return OnboardingDraft(
      currentStep: _resumeStepFor(existing),
      profileId: existing.id,
      nickname: existing.nickname,
      birthDate: existing.birthDate,
      height: existing.height,
      currentWeight: existing.currentWeight,
      biologicalInput: existing.biologicalInput,
      activityLevel: existing.activityLevel,
    );
  }

  OnboardingStep _resumeStepFor(UserProfile profile) {
    final missingCore = <bool>[
      profile.birthDate == null,
      profile.height == null,
      profile.currentWeight == null,
      profile.biologicalInput == null,
    ];
    if (missingCore.any((missing) => missing)) {
      return OnboardingStep.profileBasics;
    }
    if (profile.activityLevel == null) {
      return OnboardingStep.activity;
    }
    return OnboardingStep.programSelect;
  }

  /// Menyimpan langkah "profil awal" (`08`) begitu sah (task 3.2, FRS
  /// 2.3.5) — menolak dan tidak menyimpan apa pun bila ada nilai yang
  /// tidak masuk akal, mengembalikan kegagalan bertipe yang menyebut
  /// bidang bermasalah.
  ///
  /// [today] datang dari `Clock` yang disuntikkan pemanggil (konvensi
  /// change 001) — fungsi ini sendiri tidak membaca jam sistem.
  Future<Result<void>> saveProfileBasics({
    required String nickname,
    required LocalDate birthDate,
    required double heightCm,
    required double currentWeightKg,
    required BiologicalInput biologicalInput,
    required LocalDate today,
  }) async {
    final nicknameResult = ProfileValueRules.nickname(nickname);
    if (nicknameResult.isErr) {
      return Err<void>(nicknameResult.failureOrNull!);
    }
    final birthDateResult = ProfileValueRules.birthDate(
      birthDate,
      asOfToday: today,
    );
    if (birthDateResult.isErr) {
      return Err<void>(birthDateResult.failureOrNull!);
    }
    final heightResult = ProfileValueRules.height(heightCm);
    if (heightResult.isErr) {
      return Err<void>(heightResult.failureOrNull!);
    }
    final weightResult = ProfileValueRules.currentWeight(currentWeightKg);
    if (weightResult.isErr) {
      return Err<void>(weightResult.failureOrNull!);
    }

    final draft = state.valueOrNull ?? const OnboardingDraft();
    final profileId = draft.profileId ?? ref.read(idGeneratorProvider).next();
    final trimmedNickname = nicknameResult.valueOrNull!;

    final updated = draft.copyWith(
      currentStep: OnboardingStep.activity,
      profileId: profileId,
      nickname: trimmedNickname,
      clearNickname: trimmedNickname.isEmpty,
      birthDate: birthDateResult.valueOrNull,
      height: heightResult.valueOrNull,
      currentWeight: weightResult.valueOrNull,
      biologicalInput: biologicalInput,
    );

    await _persist(updated);
    state = AsyncValue<OnboardingDraft>.data(updated);
    return const Ok<void>(null);
  }

  /// Menyimpan langkah "tingkat aktivitas" (`09`) begitu dipilih — tiga
  /// pilihan tertutup (`ActivityLevel`), tidak ada nilai yang bisa tidak
  /// sah di langkah ini.
  Future<void> saveActivityLevel(ActivityLevel level) async {
    final draft = state.valueOrNull ?? const OnboardingDraft();
    final updated = draft.copyWith(
      currentStep: OnboardingStep.programSelect,
      activityLevel: level,
    );
    await _persist(updated);
    state = AsyncValue<OnboardingDraft>.data(updated);
  }

  /// Menandai program yang dipilih di langkah `10` (FRS 3.3.1) —
  /// mengosongkan masukan khusus program sebelumnya, karena program baru
  /// punya masukannya sendiri (berat tujuan untuk Turun Berat/Naik Berat,
  /// fokus kebiasaan untuk Makan Sehat; task 4.10: Pertahankan dan Makan
  /// Sehat tidak pernah menampilkan isian berat tujuan).
  ///
  /// Hanya menandai pilihan — rancangan `10` memakai tombol "Lanjutkan"
  /// terpisah untuk berpindah langkah (lihat `goToStep`), bukan berpindah
  /// seketika saat kartu disentuh.
  ///
  /// Tidak disimpan ke `ProfileRepository` — pratinjau tidak pernah menulis
  /// program (Design D3); masukan ini hanya hidup di [state] sampai
  /// aktivasi.
  void selectProgram(ProgramCode program) {
    final draft = state.valueOrNull ?? const OnboardingDraft();
    state = AsyncValue<OnboardingDraft>.data(
      OnboardingDraft(
        currentStep: draft.currentStep,
        profileId: draft.profileId,
        nickname: draft.nickname,
        birthDate: draft.birthDate,
        height: draft.height,
        currentWeight: draft.currentWeight,
        biologicalInput: draft.biologicalInput,
        activityLevel: draft.activityLevel,
        selectedProgram: program,
        // Pratinjau sebelumnya (bila ada) milik program yang berbeda —
        // tidak dibawa lewat `copyWith` (lihat `OnboardingDraft`).
      ),
    );
  }

  /// Menyimpan fokus kebiasaan Makan Sehat (`11`, FRS 3.3.4).
  void saveHabitFocus(String habitFocus) {
    final draft = state.valueOrNull;
    if (draft == null) {
      return;
    }
    state = AsyncValue<OnboardingDraft>.data(
      draft.copyWith(habitFocus: habitFocus),
    );
  }

  /// Menambah atau menghapus satu fokus kebiasaan. Nilai tetap disimpan pada
  /// kolom string lama sebagai daftar berurutan yang dipisahkan `|`, sehingga
  /// data lama dengan satu fokus tetap kompatibel tanpa migrasi database.
  void toggleHabitFocus(String habitFocus) {
    final draft = state.valueOrNull;
    if (draft == null) {
      return;
    }
    final selected = <String>{
      ...?draft.habitFocus?.split('|').where((value) => value.isNotEmpty),
    };
    if (!selected.add(habitFocus)) {
      selected.remove(habitFocus);
    }
    state = AsyncValue<OnboardingDraft>.data(
      draft.copyWith(
        habitFocus: selected.isEmpty ? null : selected.join('|'),
        clearHabitFocus: selected.isEmpty,
      ),
    );
  }

  /// Menyimpan pengakuan bahwa target dan data makanan adalah perkiraan
  /// (`11`, task 4.8, FRS 3.3.6).
  void setEstimateAcknowledged(bool acknowledged) {
    final draft = state.valueOrNull;
    if (draft == null) {
      return;
    }
    state = AsyncValue<OnboardingDraft>.data(
      draft.copyWith(estimateAcknowledged: acknowledged),
    );
  }

  /// Berpindah dari `11 · Detail program` ke langkah berikutnya: `25` bila
  /// program menuntut berat tujuan, selain itu langsung `review` (task
  /// 4.10).
  ///
  /// Menahan langkah bila pengakuan perkiraan belum diberikan (task 4.8,
  /// FRS 3.3.6, scenario 6.7) — mengembalikan `false` tanpa berpindah.
  bool continueFromProgramDetail() {
    final draft = state.valueOrNull;
    if (draft == null || !draft.estimateAcknowledged) {
      return false;
    }
    goToStep(
      draft.requiresTargetWeight
          ? OnboardingStep.targetWeight
          : OnboardingStep.review,
    );
    return true;
  }

  /// Menyimpan langkah "target berat program" (`25`, FRS 3.3.3/3.3.5) —
  /// menolak nilai berat tujuan yang tidak masuk akal; tanggal tujuan
  /// SHALL TIDAK pernah wajib.
  Result<void> saveTargetWeightDetails({
    required double targetWeightKg,
    LocalDate? targetDate,
  }) {
    final weightResult = ProfileValueRules.targetWeight(targetWeightKg);
    if (weightResult.isErr) {
      return Err<void>(weightResult.failureOrNull!);
    }
    final draft = state.valueOrNull;
    if (draft == null) {
      return const Ok<void>(null);
    }
    state = AsyncValue<OnboardingDraft>.data(
      draft.copyWith(
        currentStep: OnboardingStep.review,
        targetWeight: weightResult.valueOrNull,
        targetDate: targetDate,
        clearTargetDate: targetDate == null,
      ),
    );
    return const Ok<void>(null);
  }

  /// Menghitung pratinjau (`12`, task 5.1/5.2) begitu langkah `review`
  /// dimasuki pertama kali — membekukan masukan yang dipakai
  /// ([OnboardingDraft.previewInputs]) dan hasilnya
  /// ([OnboardingDraft.lastOutcome]). Murni perhitungan: tidak menulis
  /// apa pun (Design D3).
  ///
  /// Tidak menghitung ulang bila pratinjau sudah ada — dipanggil aman dari
  /// `initState` layar tanpa mengulang perhitungan setiap bangun ulang.
  Future<void> prepareReview() async {
    final draft = state.valueOrNull;
    if (draft == null || draft.previewInputs != null) {
      return;
    }
    final profile = await ref.read(profileRepositoryProvider).current();
    if (profile == null || draft.selectedProgram == null) {
      return;
    }
    final inputs = _buildProposalInputs(draft, profile);
    final outcome = _computeOutcome(draft, inputs);
    state = AsyncValue<OnboardingDraft>.data(
      draft.copyWith(previewInputs: inputs, lastOutcome: outcome),
    );
  }

  /// Menyetujui pratinjau (task 5.3) — membaca ulang fakta profil terkini
  /// dan menyerahkan verifikasi staleness ke `ActivateProgramCommand`
  /// (Design D4): lapisan tampilan tidak membandingkan sendiri.
  ///
  /// Bila hasilnya [ActivationInputsChangedSincePreview], pratinjau
  /// dibekukan ulang memakai fakta terkini (Design D5) sehingga layar
  /// "masukan berubah sejak pratinjau" dapat menampilkan pratinjau yang
  /// sudah diperbarui.
  Future<ActivationResult> approve() async {
    final draft = state.valueOrNull;
    if (draft == null ||
        draft.previewInputs == null ||
        draft.profileId == null ||
        draft.selectedProgram == null) {
      throw StateError('approve() dipanggil sebelum pratinjau siap');
    }

    final profile = await ref.read(profileRepositoryProvider).current();
    if (profile == null) {
      throw StateError('profil tidak ditemukan saat menyetujui pratinjau');
    }
    final currentInputs = _buildProposalInputs(draft, profile);

    final result = await ref
        .read(activateProgramCommandProvider)
        .execute(
          profileId: draft.profileId!,
          program: draft.selectedProgram!,
          previewInputs: draft.previewInputs!,
          currentInputs: currentInputs,
          userConfirmed: true,
          programRequiresTargetWeight: draft.requiresTargetWeight,
          programRequiresHabitFocus:
              draft.selectedProgram == ProgramCode.healthyEating,
        );

    switch (result) {
      case ActivationSucceeded():
        // Memaksa `isOnboardingCompleteProvider` (app/providers) membaca
        // ulang penyimpanan, sehingga gerbang peluncuran berpindah ke
        // `AppShell` begitu ruang Hari ini siap menampilkan program aktif
        // (task 5.5).
        ref.read(onboardingRefreshSignalProvider.notifier).state++;
      case ActivationInputsChangedSincePreview():
        final refreshedOutcome = _computeOutcome(draft, currentInputs);
        state = AsyncValue<OnboardingDraft>.data(
          draft.copyWith(
            previewInputs: currentInputs,
            lastOutcome: refreshedOutcome,
          ),
        );
      case ActivationRejectedNotApproved(:final outcome):
        state = AsyncValue<OnboardingDraft>.data(
          draft.copyWith(lastOutcome: outcome),
        );
      case ActivationRequiresConfirmation():
      case ActivationAlreadySatisfied():
      case ActivationConflictExistingRunningProgram():
      case ActivationFailed():
        break;
    }
    return result;
  }

  ProgramProposalInputs _buildProposalInputs(
    OnboardingDraft draft,
    UserProfile profile,
  ) {
    final today = ref.read(clockProvider).today();
    return ProgramProposalInputs(
      ageYears: profile.ageYearsAsOf(today)!,
      biologicalInput: profile.biologicalInput!,
      height: profile.height!,
      currentWeight: profile.currentWeight!,
      activity: profile.activityLevel!,
      specific: ProgramSpecificInput(
        targetWeight: draft.targetWeight,
        targetDate: draft.targetDate,
        habitFocus: draft.habitFocus,
      ),
    );
  }

  ProgramOutcome<ProgramTargetProposal> _computeOutcome(
    OnboardingDraft draft,
    ProgramProposalInputs inputs,
  ) {
    return ref
        .read(programEngineProvider)
        .proposeTarget(
          program: draft.selectedProgram!,
          ageYears: inputs.ageYears,
          biologicalInput: inputs.biologicalInput,
          height: inputs.height,
          currentWeight: inputs.currentWeight,
          estimate: _estimateFrom(inputs),
          screening: inputs.screening,
          specific: inputs.specific,
          asOfDate: ref.read(clockProvider).today(),
          programRequiresTargetWeight: draft.requiresTargetWeight,
          programRequiresHabitFocus:
              draft.selectedProgram == ProgramCode.healthyEating,
        );
  }

  /// Sama seperti `ActivateProgramCommand._estimateFrom` — dipakai di sini
  /// hanya untuk pratinjau (murni perhitungan, Design D3), bukan untuk
  /// menulis apa pun.
  NutritionEstimate _estimateFrom(ProgramProposalInputs inputs) {
    const calculator = NutritionCalculator(EnergyEquationPolicy.np100);
    final outcome = calculator.estimate(
      PhysiologicalFactsInput(
        ageYears: inputs.ageYears,
        biologicalInput: inputs.biologicalInput,
        heightCm: inputs.height.cm,
        weightKg: inputs.currentWeight.kg,
        activity: inputs.activity,
      ),
    );
    return switch (outcome) {
      Approved<NutritionEstimate>(:final value) => value,
      _ => throw StateError(
        'fakta pratinjau tidak valid untuk kalkulator: $outcome',
      ),
    };
  }

  /// Berpindah ke langkah lain tanpa kehilangan isian (task 3.4) — hanya
  /// mengubah [OnboardingDraft.currentStep]; seluruh data yang sudah
  /// tersimpan di [state] tetap ada, baik maju maupun mundur.
  void goToStep(OnboardingStep step) {
    final draft = state.valueOrNull;
    if (draft == null) {
      return;
    }
    state = AsyncValue<OnboardingDraft>.data(draft.copyWith(currentStep: step));
  }

  Future<void> _persist(OnboardingDraft draft) async {
    if (draft.profileId == null) {
      return;
    }
    // Penanda kelengkapan onboarding (Design D2, task 3.3) — satu-satunya
    // sumber yang SHALL dipakai memutuskan apakah perhitungan target boleh
    // dijalankan (lihat `UserProfile.isOnboardingComplete`).
    final isComplete = draft.missingProfileFields.isEmpty;
    await ref
        .read(profileRepositoryProvider)
        .upsert(
          UserProfile(
            id: draft.profileId!,
            nickname: draft.nickname,
            birthDate: draft.birthDate,
            height: draft.height,
            currentWeight: draft.currentWeight,
            biologicalInput: draft.biologicalInput,
            activityLevel: draft.activityLevel,
            isOnboardingComplete: isComplete,
          ),
        );
  }
}
