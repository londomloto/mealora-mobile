/// Tipe hasil tertutup untuk `NutritionCalculator` dan `ProgramEngine`
/// (change 003, Design D2).
///
/// Tepat lima keadaan: [Approved], [NeedsUserCorrection],
/// [NeedsProfessionalReview], [UnsupportedProfile], dan
/// [MissingValidatedPolicy]. Menambah keadaan baru mengharuskan tiap
/// pemanggil `switch` menanganinya — kompilasi gagal di tempat yang belum
/// menanganinya, bukan pengecualian yang tertangkap entah di mana.
///
/// Setiap keadaan tidak-disetujui membawa `ReasonCode` dari daftar tertutup,
/// bukan kalimat bebas; `details` hanya berisi fakta berupa angka atau
/// tanggal (mis. laju yang diterapkan, tanggal paling awal yang aman) untuk
/// dipakai lapisan presentasi — tidak pernah teks siap tampil.
library;

import 'package:mealora/domain/shared/reason_code.dart';

sealed class ProgramOutcome<T> {
  const ProgramOutcome();
}

/// Hasil disetujui dengan nilai [value].
final class Approved<T> extends ProgramOutcome<T> {
  const Approved(this.value);

  final T value;

  @override
  bool operator ==(Object other) =>
      other is Approved<T> && other.value == value;

  @override
  int get hashCode => Object.hash(Approved<T>, value);

  @override
  String toString() => 'Approved($value)';
}

/// Masukan pengguna belum lengkap atau tidak koheren; pengguna dapat
/// memperbaikinya sendiri.
final class NeedsUserCorrection<T> extends ProgramOutcome<T> {
  const NeedsUserCorrection({
    required this.reasonCode,
    this.missingFields = const <String>[],
    this.details = const <String, Object?>{},
  });

  final ReasonCode reasonCode;

  /// Nama masukan yang kurang, bila [reasonCode] adalah
  /// [ReasonCode.missingRequiredInput].
  final List<String> missingFields;

  /// Fakta pendukung berupa angka/tanggal (bukan kalimat), mis.
  /// `earliestSafeDate`, `appliedCapKgPerWeek`.
  final Map<String, Object?> details;

  @override
  bool operator ==(Object other) =>
      other is NeedsUserCorrection<T> &&
      other.reasonCode == reasonCode &&
      _mapEquals(other.missingFields, missingFields) &&
      _mapEquals(other.details, details);

  @override
  int get hashCode => Object.hash(
    reasonCode,
    Object.hashAll(missingFields),
    Object.hashAllUnordered(
      details.entries.map((e) => Object.hash(e.key, e.value)),
    ),
  );

  @override
  String toString() =>
      'NeedsUserCorrection(${reasonCode.name}, missing: $missingFields, details: $details)';
}

/// Profil tercakup kebijakan tetapi butuh pendampingan tenaga kesehatan
/// sebelum target otomatis diberikan.
final class NeedsProfessionalReview<T> extends ProgramOutcome<T> {
  const NeedsProfessionalReview({
    required this.reasonCode,
    this.details = const <String, Object?>{},
  });

  final ReasonCode reasonCode;
  final Map<String, Object?> details;

  @override
  bool operator ==(Object other) =>
      other is NeedsProfessionalReview<T> &&
      other.reasonCode == reasonCode &&
      _mapEquals(other.details, details);

  @override
  int get hashCode => Object.hash(
    reasonCode,
    Object.hashAllUnordered(
      details.entries.map((e) => Object.hash(e.key, e.value)),
    ),
  );

  @override
  String toString() =>
      'NeedsProfessionalReview(${reasonCode.name}, details: $details)';
}

/// Profil di luar cakupan kebijakan ini sama sekali untuk program yang
/// diminta.
final class UnsupportedProfile<T> extends ProgramOutcome<T> {
  const UnsupportedProfile({required this.reasonCode});

  final ReasonCode reasonCode;

  @override
  bool operator ==(Object other) =>
      other is UnsupportedProfile<T> && other.reasonCode == reasonCode;

  @override
  int get hashCode => reasonCode.hashCode;

  @override
  String toString() => 'UnsupportedProfile(${reasonCode.name})';
}

/// Kebijakan yang berlaku belum disetujui, tidak tersedia, atau tidak
/// mencakup kasus ini — perilaku bawaan gagal tertutup.
final class MissingValidatedPolicy<T> extends ProgramOutcome<T> {
  const MissingValidatedPolicy();

  @override
  bool operator ==(Object other) => other is MissingValidatedPolicy<T>;

  @override
  int get hashCode => (MissingValidatedPolicy<T>).hashCode;

  @override
  String toString() => 'MissingValidatedPolicy()';
}

bool _mapEquals(Object a, Object b) {
  if (a is List && b is List) {
    if (a.length != b.length) {
      return false;
    }
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) {
        return false;
      }
    }
    return true;
  }
  if (a is Map && b is Map) {
    if (a.length != b.length) {
      return false;
    }
    for (final key in a.keys) {
      if (!b.containsKey(key) || b[key] != a[key]) {
        return false;
      }
    }
    return true;
  }
  return a == b;
}
