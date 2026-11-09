import 'package:mealora/domain/profile/profile_repository.dart';
import 'package:mealora/domain/profile/user_profile.dart';

/// Tiruan `ProfileRepository` dalam memori untuk pengujian — tanpa Drift,
/// tanpa basis data sungguhan. Mengikuti bentuk `InMemoryProgramRepository`
/// (test/unit/domain/program/fakes, change 003/004).
final class InMemoryProfileRepository implements ProfileRepository {
  final Map<String, UserProfile> _profiles = <String, UserProfile>{};

  @override
  Future<UserProfile?> current() async =>
      _profiles.values.isEmpty ? null : _profiles.values.first;

  @override
  Future<UserProfile?> findById(String id) async => _profiles[id];

  @override
  Future<void> upsert(UserProfile profile) async {
    _profiles[profile.id] = profile;
    upsertCallCount++;
  }

  /// Hanya untuk pengujian: jumlah penyimpanan ke [upsert] — membuktikan
  /// penyimpanan bertahap (task 3.2) tanpa bergantung pada isi state.
  int upsertCallCount = 0;
}
