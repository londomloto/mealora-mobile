import 'package:flutter_test/flutter_test.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/data/local/drift_profile_repository.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/domain/nutrition/activity_level.dart';
import 'package:mealora/domain/nutrition/biological_input.dart';
import 'package:mealora/domain/profile/user_profile.dart';
import 'package:mealora/domain/shared/units.dart';

import 'test_database.dart';

/// `DriftProfileRepository` (change 005, task 2.4): satuan kanonis
/// (sentimeter/kilogram), bidang `null` dibedakan dari nilai kosong, dan
/// penanda kelengkapan onboarding tersimpan.
void main() {
  late AppDatabase db;
  late DriftProfileRepository repository;

  setUp(() {
    db = createTestDatabase();
    repository = DriftProfileRepository(db, clock: createTestClock());
  });

  tearDown(() => db.close());

  test('current() mengembalikan null sebelum profil pernah dibuat', () async {
    expect(await repository.current(), isNull);
  });

  test(
    'profil baru yang belum lengkap tersimpan dan terbaca kembali',
    () async {
      const profile = UserProfile(id: 'profile-1', nickname: 'Budi');
      await repository.upsert(profile);

      final reloaded = await repository.current();
      expect(reloaded, isNotNull);
      expect(reloaded!.id, 'profile-1');
      expect(reloaded.nickname, 'Budi');
      expect(reloaded.missingRequiredFields, isNotEmpty);
      expect(reloaded.isOnboardingComplete, isFalse);
    },
  );

  test(
    'profil lengkap menyimpan tinggi (cm) dan berat (kg) sebagai satuan kanonis',
    () async {
      final profile = UserProfile(
        id: 'profile-1',
        birthDate: const LocalDate(1997, 5, 20),
        height: Length.cmValue(165, field: 'h').valueOrNull,
        currentWeight: Mass.kgValue(68.4, field: 'w').valueOrNull,
        biologicalInput: BiologicalInput.female,
        activityLevel: ActivityLevel.moderatelyActive,
        isOnboardingComplete: true,
      );
      await repository.upsert(profile);

      final reloaded = await repository.findById('profile-1');
      expect(reloaded!.height?.cm, 165);
      expect(reloaded.currentWeight?.kg, 68.4);
      expect(reloaded.biologicalInput, BiologicalInput.female);
      expect(reloaded.activityLevel, ActivityLevel.moderatelyActive);
      expect(reloaded.isOnboardingComplete, isTrue);
      expect(reloaded.missingRequiredFields, isEmpty);
    },
  );

  test(
    'upsert memperbarui baris yang sama, bukan menambah baris baru',
    () async {
      await repository.upsert(const UserProfile(id: 'profile-1'));
      await repository.upsert(
        const UserProfile(id: 'profile-1', nickname: 'Siti'),
      );

      final rows = await db.select(db.profiles).get();
      expect(rows, hasLength(1));
      expect(rows.single.nickname, 'Siti');
    },
  );

  test(
    'mengubah berat badan tidak mengubah bidang lain yang sudah tersimpan',
    () async {
      final initial = UserProfile(
        id: 'profile-1',
        height: Length.cmValue(165, field: 'h').valueOrNull,
        currentWeight: Mass.kgValue(68.4, field: 'w').valueOrNull,
        biologicalInput: BiologicalInput.female,
      );
      await repository.upsert(initial);

      final updated = initial.copyWith(
        currentWeight: Mass.kgValue(71, field: 'w').valueOrNull,
      );
      await repository.upsert(updated);

      final reloaded = await repository.current();
      expect(reloaded!.currentWeight?.kg, 71);
      expect(reloaded.height?.cm, 165);
      expect(reloaded.biologicalInput, BiologicalInput.female);
    },
  );
}
