import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/domain/nutrition/activity_level.dart';
import 'package:mealora/domain/nutrition/biological_input.dart';
import 'package:mealora/domain/profile/user_profile.dart';
import 'package:mealora/domain/shared/units.dart';

/// `UserProfile` (change 005): kelengkapan profil dan nama panggilan
/// opsional (FRS 2.3.2).
void main() {
  test(
    'profil baru tanpa isian apa pun melaporkan seluruh bidang wajib hilang',
    () {
      const profile = UserProfile(id: 'p-1');
      expect(
        profile.missingRequiredFields,
        containsAll(<String>[
          'birthDate',
          'height',
          'currentWeight',
          'biologicalInput',
          'activityLevel',
        ]),
      );
      expect(profile.isOnboardingComplete, isFalse);
    },
  );

  test('nickname tidak pernah muncul di bidang wajib yang hilang', () {
    const profile = UserProfile(id: 'p-1');
    expect(profile.missingRequiredFields, isNot(contains('nickname')));
  });

  test(
    'profil dengan seluruh bidang wajib terisi tidak melaporkan apa pun hilang',
    () {
      final profile = UserProfile(
        id: 'p-1',
        birthDate: const LocalDate(1997, 5, 20),
        height: Length.cmValue(165, field: 'h').valueOrNull,
        currentWeight: Mass.kgValue(68.4, field: 'w').valueOrNull,
        biologicalInput: BiologicalInput.female,
        activityLevel: ActivityLevel.moderatelyActive,
      );
      expect(profile.missingRequiredFields, isEmpty);
    },
  );

  test('copyWith mengosongkan nickname hanya ketika diminta eksplisit', () {
    const profile = UserProfile(id: 'p-1', nickname: 'Budi');
    final cleared = profile.copyWith(clearNickname: true);
    expect(cleared.nickname, isNull);

    final unchanged = profile.copyWith(activityLevel: ActivityLevel.sedentary);
    expect(unchanged.nickname, 'Budi');
  });

  test('ageYearsAsOf null bila tanggal lahir belum diisi', () {
    const profile = UserProfile(id: 'p-1');
    expect(profile.ageYearsAsOf(const LocalDate(2026, 11, 9)), isNull);
  });

  test('ageYearsAsOf menghitung usia dari tanggal lahir tersimpan', () {
    const profile = UserProfile(id: 'p-1', birthDate: LocalDate(1997, 5, 20));
    expect(profile.ageYearsAsOf(const LocalDate(2026, 11, 9)), 29);
  });
}
