import 'package:drift/drift.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/errors/result.dart';
import 'package:mealora/core/ids/id_generator.dart';
import 'package:mealora/data/local/drift_diary_repository.dart';
import 'package:mealora/data/local/user_record_support.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/database/tables/weight_records_table.dart';
import 'package:mealora/domain/weight/weight_record.dart';
import 'package:mealora/domain/weight/weight_repository.dart';
import 'package:mealora/domain/weight/weight_validation.dart';

part 'drift_weight_repository.g.dart';

/// Implementasi `WeightRepository` (change 008) memakai DAO Drift.
///
/// Menyambung ke [DriftDiaryRepository.rebuildProgressFor] secara langsung
/// (bukan lewat domain `ProgramRepository`/`DiaryRepository`), pola yang
/// sama dengan `program_progress_snapshot` (change 004): potret adalah
/// detail lapisan data. Keduanya memanggil titik rebuild yang SAMA supaya
/// penulisan catatan berat tidak menimpa nilai buku harian untuk tanggal
/// yang sama, dan sebaliknya (lihat doc `rebuildProgressFor`).
@DriftAccessor(tables: <Type>[WeightRecords])
class DriftWeightRepository extends DatabaseAccessor<AppDatabase>
    with _$DriftWeightRepositoryMixin
    implements WeightRepository {
  DriftWeightRepository(
    super.db, {
    required Clock clock,
    required IdGenerator ids,
    required DriftDiaryRepository diaryRepository,
  }) : _clock = clock,
       _ids = ids,
       _diaryRepository = diaryRepository;

  final Clock _clock;
  final IdGenerator _ids;
  final DriftDiaryRepository _diaryRepository;

  @override
  Future<WeightRecord?> latest(String profileId) async {
    // Diurutkan menurut tanggal lokal yang dicatat, bukan `recordedAt`
    // (design D1): catatan "terbaru" adalah untuk tanggal paling baru yang
    // punya catatan, bukan yang paling akhir disunting. `recordedAt` hanya
    // memutus seri untuk beberapa catatan pada tanggal lokal yang sama.
    final row =
        await (select(weightRecords)
              ..where(
                (t) =>
                    t.profileId.equals(profileId) &
                    UserRecords.active(t.deletedAt),
              )
              ..orderBy([
                (t) => OrderingTerm.desc(t.localDate),
                (t) => OrderingTerm.desc(t.recordedAt),
              ])
              ..limit(1))
            .getSingleOrNull();
    return row == null ? null : _toDomain(row);
  }

  @override
  Future<List<WeightRecord>> recordsInRange(
    String profileId, {
    required LocalDate from,
    required LocalDate to,
  }) async {
    final rows =
        await (select(weightRecords)
              ..where(
                (t) =>
                    t.profileId.equals(profileId) &
                    t.localDate.isBiggerOrEqualValue(from.iso) &
                    t.localDate.isSmallerOrEqualValue(to.iso) &
                    UserRecords.active(t.deletedAt),
              )
              ..orderBy([
                (t) => OrderingTerm.asc(t.localDate),
                (t) => OrderingTerm.asc(t.recordedAt),
              ]))
            .get();
    return rows.map(_toDomain).toList(growable: false);
  }

  @override
  Future<Result<WeightRecord>> addRecord({
    required String profileId,
    required LocalDate date,
    required double weightKg,
    String? note,
  }) async {
    final validated = _validate(date: date, weightKg: weightKg);
    if (validated is Err<double>) {
      return Err<WeightRecord>(validated.failureOrNull!);
    }

    final now = _clock.nowUtc();
    final id = _ids.next();
    await into(weightRecords).insert(
      WeightRecordsCompanion.insert(
        id: id,
        createdAt: now,
        updatedAt: now,
        profileId: profileId,
        localDate: date.iso,
        recordedAt: now,
        weightKg: weightKg,
        note: Value<String?>(note),
      ),
    );

    final row = await (select(
      weightRecords,
    )..where((t) => t.id.equals(id))).getSingle();
    await _diaryRepository.rebuildProgressFor(profileId, date);
    return Ok<WeightRecord>(_toDomain(row));
  }

  @override
  Future<Result<WeightRecord>> updateRecord({
    required String recordId,
    required LocalDate date,
    required double weightKg,
    String? note,
  }) async {
    final validated = _validate(date: date, weightKg: weightKg);
    if (validated is Err<double>) {
      return Err<WeightRecord>(validated.failureOrNull!);
    }

    final existing = await (select(
      weightRecords,
    )..where((t) => t.id.equals(recordId))).getSingle();
    final now = _clock.nowUtc();

    await (update(weightRecords)..where((t) => t.id.equals(recordId))).write(
      WeightRecordsCompanion(
        localDate: Value<String>(date.iso),
        weightKg: Value<double>(weightKg),
        note: Value<String?>(note),
        updatedAt: Value<DateTime>(now),
        revision: Value<int>(existing.revision + 1),
      ),
    );

    final row = await (select(
      weightRecords,
    )..where((t) => t.id.equals(recordId))).getSingle();
    await _diaryRepository.rebuildProgressFor(existing.profileId, date);
    if (existing.localDate != date.iso) {
      // Tanggal disunting ke hari lain: potret tanggal lama juga harus
      // dibangun ulang supaya tidak terus membawa nilai berat yang sudah
      // tidak berlaku untuk hari itu (design D4).
      await _diaryRepository.rebuildProgressFor(
        existing.profileId,
        LocalDate.parse(existing.localDate),
      );
    }
    return Ok<WeightRecord>(_toDomain(row));
  }

  @override
  Future<void> deleteRecord(String recordId) async {
    final existing = await (select(
      weightRecords,
    )..where((t) => t.id.equals(recordId))).getSingle();
    final now = _clock.nowUtc();

    await (update(weightRecords)..where((t) => t.id.equals(recordId))).write(
      WeightRecordsCompanion(
        deletedAt: Value<DateTime?>(now),
        updatedAt: Value<DateTime>(now),
        revision: Value<int>(existing.revision + 1),
      ),
    );
    await _diaryRepository.rebuildProgressFor(
      existing.profileId,
      LocalDate.parse(existing.localDate),
    );
  }

  Result<double> _validate({
    required LocalDate date,
    required double weightKg,
  }) {
    final validWeight = WeightRecordValidation.weightKg(weightKg);
    if (validWeight is Err<double>) {
      return validWeight;
    }
    final validDate = WeightRecordValidation.recordDate(
      date,
      asOfToday: _clock.today(),
    );
    if (validDate is Err<LocalDate>) {
      return Err<double>(validDate.failureOrNull!);
    }
    return validWeight;
  }

  WeightRecord _toDomain(WeightRecordRow row) => WeightRecord(
    id: row.id,
    profileId: row.profileId,
    localDate: LocalDate.parse(row.localDate),
    recordedAt: row.recordedAt,
    weightKg: row.weightKg,
    note: row.note,
    createdAt: row.createdAt,
  );
}
