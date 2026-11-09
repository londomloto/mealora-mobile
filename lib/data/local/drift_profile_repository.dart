import 'package:drift/drift.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/data/local/user_record_support.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/database/tables/profiles_table.dart';
import 'package:mealora/domain/nutrition/activity_level.dart';
import 'package:mealora/domain/nutrition/biological_input.dart';
import 'package:mealora/domain/profile/profile_repository.dart';
import 'package:mealora/domain/profile/user_profile.dart';
import 'package:mealora/domain/shared/units.dart';

part 'drift_profile_repository.g.dart';

/// Implementasi `ProfileRepository` (change 005) memakai DAO Drift —
/// mengikuti bentuk `DriftProgramRepository` (change 004): Drift tidak
/// pernah bocor ke lapisan domain (Design D9, change 004).
@DriftAccessor(tables: <Type>[Profiles])
class DriftProfileRepository extends DatabaseAccessor<AppDatabase>
    with _$DriftProfileRepositoryMixin
    implements ProfileRepository {
  DriftProfileRepository(super.db, {required Clock clock}) : _clock = clock;

  final Clock _clock;

  @override
  Future<UserProfile?> current() async {
    final row = await (select(
      profiles,
    )..where((t) => UserRecords.active(t.deletedAt))).getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<UserProfile?> findById(String id) async {
    final row =
        await (select(profiles)
              ..where((t) => t.id.equals(id) & UserRecords.active(t.deletedAt)))
            .getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<void> upsert(UserProfile profile) async {
    final existing = await (select(
      profiles,
    )..where((t) => t.id.equals(profile.id))).getSingleOrNull();
    final now = _clock.nowUtc();

    if (existing == null) {
      await into(
        profiles,
      ).insert(_toCompanion(profile, createdAt: now, updatedAt: now));
      return;
    }
    await (update(profiles)..where((t) => t.id.equals(profile.id))).write(
      _toCompanion(profile, createdAt: existing.createdAt, updatedAt: now),
    );
  }

  UserProfile _toDomain(ProfileRow row) => UserProfile(
    id: row.id,
    nickname: row.nickname,
    birthDate: row.birthDate == null ? null : LocalDate.parse(row.birthDate!),
    height: row.heightCm == null
        ? null
        : Length.cmValue(row.heightCm!, field: 'height').valueOrNull,
    currentWeight: row.currentWeightKg == null
        ? null
        : Mass.kgValue(
            row.currentWeightKg!,
            field: 'currentWeight',
          ).valueOrNull,
    biologicalInput: row.biologicalInput == null
        ? null
        : BiologicalInput.values.byName(row.biologicalInput!),
    activityLevel: row.activityLevel == null
        ? null
        : ActivityLevel.values.byName(row.activityLevel!),
    isOnboardingComplete: row.onboardingComplete,
  );

  ProfilesCompanion _toCompanion(
    UserProfile profile, {
    required DateTime createdAt,
    required DateTime updatedAt,
  }) {
    return ProfilesCompanion.insert(
      id: profile.id,
      createdAt: createdAt,
      updatedAt: updatedAt,
      nickname: Value<String?>(profile.nickname),
      birthDate: Value<String?>(profile.birthDate?.iso),
      heightCm: Value<double?>(profile.height?.cm),
      currentWeightKg: Value<double?>(profile.currentWeight?.kg),
      biologicalInput: Value<String?>(profile.biologicalInput?.name),
      activityLevel: Value<String?>(profile.activityLevel?.name),
      onboardingComplete: Value<bool>(profile.isOnboardingComplete),
    );
  }
}
