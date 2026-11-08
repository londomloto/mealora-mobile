import 'package:drift/drift.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/errors/failure.dart';
import 'package:mealora/core/errors/result.dart';
import 'package:mealora/core/ids/id_generator.dart';
import 'package:mealora/core/validation/value_rules.dart';
import 'package:mealora/data/local/user_record_support.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/database/tables/harness_records.dart';

part 'harness_record_dao.g.dart';

/// Akses data untuk tabel harness.
///
/// Tabel harness bukan tabel produk; DAO ini ada untuk membuktikan konvensi
/// akses data yang akan dipakai ulang oleh repositori sungguhan: penyaringan
/// penghapusan lunak sebagai baku, penaikan revisi otomatis, validasi nilai
/// sebelum penulisan, dan penulisan ganda di dalam satu transaksi.
@DriftAccessor(tables: [HarnessRecords, HarnessRecordNotes])
class HarnessRecordDao extends DatabaseAccessor<AppDatabase>
    with _$HarnessRecordDaoMixin {
  HarnessRecordDao(super.db, {required Clock clock, required IdGenerator ids})
    : _clock = clock,
      _ids = ids;

  final Clock _clock;
  final IdGenerator _ids;

  /// Pembacaan baku: record terhapus tidak pernah ikut.
  Future<List<HarnessRecord>> listActive() {
    return (select(harnessRecords)
          ..where((t) => UserRecords.active(t.deletedAt))
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
  }

  /// Jalur eksplisit untuk membaca record yang sudah ditandai terhapus.
  Future<List<HarnessRecord>> listDeleted() {
    return (select(harnessRecords)
          ..where((t) => UserRecords.deleted(t.deletedAt))
          ..orderBy([(t) => OrderingTerm.asc(t.id)]))
        .get();
  }

  Future<HarnessRecord?> findActive(String id) {
    return (select(harnessRecords)
          ..where((t) => t.id.equals(id) & UserRecords.active(t.deletedAt)))
        .getSingleOrNull();
  }

  /// Menyimpan satu record harness beserta catatan anaknya, dalam satu
  /// transaksi: berhasil seluruhnya atau tidak sama sekali.
  Future<Result<String>> create({
    required String label,
    required double amount,
    double? nutrientValue,
    List<String> notes = const <String>[],
  }) async {
    final validLabel = ValueRules.requiredText(label, field: 'label');
    if (validLabel case Err<String>(:final failure)) {
      return Err<String>(failure);
    }
    final validAmount = ValueRules.positiveAmount(amount, field: 'amount');
    if (validAmount case Err<double>(:final failure)) {
      return Err<String>(failure);
    }
    final validNutrient = ValueRules.nutrientValue(
      nutrientValue,
      field: 'nutrientValue',
    );
    if (validNutrient case Err<double?>(:final failure)) {
      return Err<String>(failure);
    }
    for (final note in notes) {
      final validNote = ValueRules.requiredText(note, field: 'note');
      if (validNote case Err<String>(:final failure)) {
        return Err<String>(failure);
      }
    }

    final now = _clock.nowUtc();
    final recordId = _ids.next();

    try {
      await transaction(() async {
        await into(harnessRecords).insert(
          HarnessRecordsCompanion.insert(
            id: recordId,
            createdAt: now,
            updatedAt: now,
            label: validLabel.valueOrNull!,
            amount: validAmount.valueOrNull!,
            nutrientValue: Value<double?>(validNutrient.valueOrNull),
            localDate: _clock.localDateOf(now).iso,
            timeZoneId: _clock.timeZoneId(),
          ),
        );
        for (final note in notes) {
          await into(harnessRecordNotes).insert(
            HarnessRecordNotesCompanion.insert(
              id: _ids.next(),
              createdAt: now,
              updatedAt: now,
              recordId: recordId,
              note: note.trim(),
            ),
          );
        }
      });
    } on Object catch (error) {
      return Err<String>(
        Failure(
          FailureCode.invalidValue,
          detail: 'penulisan ditolak penyimpanan: $error',
        ),
      );
    }

    return Ok<String>(recordId);
  }

  /// Memperbarui record: `updated_at` ikut berubah dari [Clock], sementara
  /// `revision` naik satu dan `created_at` dipertahankan oleh pemicu basis
  /// data (lihat `user_record_triggers.dart`).
  Future<Result<void>> updateLabel(String id, String label) async {
    final validLabel = ValueRules.requiredText(label, field: 'label');
    if (validLabel case Err<String>(:final failure)) {
      return Err<void>(failure);
    }

    final affected =
        await (update(harnessRecords)
              ..where((t) => t.id.equals(id) & UserRecords.active(t.deletedAt)))
            .write(
              HarnessRecordsCompanion(
                label: Value<String>(validLabel.valueOrNull!),
                updatedAt: Value<DateTime>(_clock.nowUtc()),
              ),
            );

    if (affected == 0) {
      return const Err<void>(Failure(FailureCode.recordNotFound));
    }
    return const Ok<void>(null);
  }

  /// Penghapusan lunak: barisnya tetap ada, tetapi hilang dari pembacaan
  /// biasa dan perhitungan.
  Future<Result<void>> softDelete(String id) async {
    final now = _clock.nowUtc();
    final affected =
        await (update(harnessRecords)
              ..where((t) => t.id.equals(id) & UserRecords.active(t.deletedAt)))
            .write(
              HarnessRecordsCompanion(
                deletedAt: Value<DateTime>(now),
                updatedAt: Value<DateTime>(now),
              ),
            );

    if (affected == 0) {
      return const Err<void>(Failure(FailureCode.recordNotFound));
    }
    return const Ok<void>(null);
  }

  /// Total nilai gizi yang diketahui pada record aktif. Nilai yang belum
  /// diketahui (`null`) tidak dihitung sebagai nol.
  Future<double?> knownNutrientTotal() async {
    final sum = harnessRecords.nutrientValue.sum();
    final row =
        await (selectOnly(harnessRecords)
              ..addColumns([sum])
              ..where(UserRecords.active(harnessRecords.deletedAt)))
            .getSingle();
    return row.read(sum);
  }
}
