import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/domain/nutrition/activity_level.dart';
import 'package:mealora/domain/nutrition/biological_input.dart';
import 'package:mealora/domain/profile/profile_validation.dart';
import 'package:mealora/domain/shared/units.dart';

/// Profil lokal pengguna (change 005) — satu per perangkat, dipakai
/// `NutritionCalculator` (domain/nutrition) untuk memperkirakan kebutuhan
/// energi.
///
/// Setiap bidang domain boleh `null` karena profil disimpan bertahap selama
/// onboarding (Design D2, task 3.2): `null` berarti "belum diisi", berbeda
/// dari nilai tidak masuk akal. [isOnboardingComplete] adalah satu-satunya
/// penanda yang SHALL dipakai untuk memutuskan apakah perhitungan target
/// boleh dijalankan (Design D2) — bukan memeriksa [missingRequiredFields]
/// langsung di tempat pemakaian, supaya keduanya tidak diam-diam menyimpang.
final class UserProfile {
  const UserProfile({
    required this.id,
    this.nickname,
    this.birthDate,
    this.height,
    this.currentWeight,
    this.biologicalInput,
    this.activityLevel,
    this.isOnboardingComplete = false,
  });

  final String id;

  /// Opsional (FRS 2.2) — berbeda dari seluruh bidang lain di bawah.
  final String? nickname;

  final LocalDate? birthDate;
  final Length? height;
  final Mass? currentWeight;

  /// Masukan persamaan energi, bukan identitas gender (FRS 2.2,
  /// `BiologicalInput` domain/nutrition).
  final BiologicalInput? biologicalInput;

  final ActivityLevel? activityLevel;

  /// Penanda kelengkapan onboarding (Design D2) — diset benar hanya setelah
  /// seluruh bidang wajib terisi dan pengguna menyelesaikan langkah terakhir
  /// pengumpulan profil. Tidak dihitung ulang dari [missingRequiredFields]
  /// di tempat baca, karena pengguna boleh saja melengkapi lalu mengosongkan
  /// sebagian isian lewat layar ubah profil nanti (change berikutnya) tanpa
  /// otomatis kembali ke onboarding.
  final bool isOnboardingComplete;

  /// Nama bidang wajib (FRS 2.2) yang masih `null`.
  List<String> get missingRequiredFields => <String>[
    if (birthDate == null) 'birthDate',
    if (height == null) 'height',
    if (currentWeight == null) 'currentWeight',
    if (biologicalInput == null) 'biologicalInput',
    if (activityLevel == null) 'activityLevel',
  ];

  /// Usia dalam tahun penuh per [today], atau `null` bila [birthDate] belum
  /// diisi.
  int? ageYearsAsOf(LocalDate today) => birthDate == null
      ? null
      : ProfileValueRules.ageInYears(birthDate!, today);

  UserProfile copyWith({
    String? nickname,
    bool clearNickname = false,
    LocalDate? birthDate,
    Length? height,
    Mass? currentWeight,
    BiologicalInput? biologicalInput,
    ActivityLevel? activityLevel,
    bool? isOnboardingComplete,
  }) {
    return UserProfile(
      id: id,
      nickname: clearNickname ? null : (nickname ?? this.nickname),
      birthDate: birthDate ?? this.birthDate,
      height: height ?? this.height,
      currentWeight: currentWeight ?? this.currentWeight,
      biologicalInput: biologicalInput ?? this.biologicalInput,
      activityLevel: activityLevel ?? this.activityLevel,
      isOnboardingComplete: isOnboardingComplete ?? this.isOnboardingComplete,
    );
  }
}
