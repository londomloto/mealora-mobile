import 'package:mealora/core/ids/id_generator.dart';
import 'package:uuid/uuid.dart';

/// Pembangkit pengenal UUID v7 — terurut menurut waktu sehingga indeks SQLite
/// tetap padat, sekaligus unik antar perangkat (design D4).
///
/// Bila pembangkitan v7 gagal pada suatu platform, kelas ini jatuh ke v4 yang
/// tetap unik global, hanya tidak terurut.
final class UuidIdGenerator implements IdGenerator {
  const UuidIdGenerator([this._uuid = const Uuid()]);

  final Uuid _uuid;

  @override
  String next() {
    try {
      return _uuid.v7();
    } on Object {
      return _uuid.v4();
    }
  }
}
