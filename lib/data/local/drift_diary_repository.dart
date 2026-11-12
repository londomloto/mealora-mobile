import 'package:drift/drift.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/errors/result.dart';
import 'package:mealora/core/ids/id_generator.dart';
import 'package:mealora/core/validation/value_rules.dart';
import 'package:mealora/data/local/drift_program_repository.dart';
import 'package:mealora/data/local/program_progress_snapshot.dart';
import 'package:mealora/data/local/user_record_support.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/database/tables/meal_entries_table.dart';
import 'package:mealora/database/tables/meal_entry_items_table.dart';
import 'package:mealora/database/tables/weight_records_table.dart';
import 'package:mealora/domain/diary/daily_nutrition_total.dart';
import 'package:mealora/domain/diary/diary_repository.dart';
import 'package:mealora/domain/diary/energy_trend.dart' show DiaryDayEnergy;
import 'package:mealora/domain/diary/meal_entry.dart';
import 'package:mealora/domain/food/food.dart';
import 'package:mealora/domain/food/meal_time.dart';
import 'package:mealora/domain/food/nutrition_profile.dart';
import 'package:mealora/domain/food/serving_size.dart';
import 'package:mealora/domain/program/pause_interval.dart';
import 'package:mealora/domain/program/user_program.dart';
import 'package:mealora/domain/shared/units.dart';

part 'drift_diary_repository.g.dart';

/// Implementasi `DiaryRepository` (change 007) memakai DAO Drift.
///
/// Menyambung ke [DriftProgramRepository] secara langsung (bukan lewat
/// `ProgramRepository` domain) untuk memicu pembangunan ulang potret
/// kemajuan (Design D8) — pola yang sama dengan `program_progress_snapshot`
/// (change 004): potret adalah detail lapisan data, bukan konsep domain.
@DriftAccessor(tables: <Type>[MealEntries, MealEntryItems, WeightRecords])
class DriftDiaryRepository extends DatabaseAccessor<AppDatabase>
    with _$DriftDiaryRepositoryMixin
    implements DiaryRepository {
  DriftDiaryRepository(
    super.db, {
    required Clock clock,
    required IdGenerator ids,
    required DriftProgramRepository programRepository,
  }) : _clock = clock,
       _ids = ids,
       _programRepository = programRepository;

  final Clock _clock;
  final IdGenerator _ids;
  final DriftProgramRepository _programRepository;

  @override
  Future<List<MealEntry>> entriesForDate(
    String profileId,
    LocalDate date,
  ) async {
    final query =
        select(mealEntries).join([
            innerJoin(
              mealEntryItems,
              mealEntryItems.mealEntryId.equalsExp(mealEntries.id),
            ),
          ])
          ..where(
            mealEntries.profileId.equals(profileId) &
                mealEntries.localDate.equals(date.iso) &
                UserRecords.active(mealEntries.deletedAt) &
                UserRecords.active(mealEntryItems.deletedAt),
          )
          ..orderBy([OrderingTerm.desc(mealEntries.createdAt)]);

    final rows = await query.get();
    return rows
        .map(
          (row) => _toDomain(
            row.readTable(mealEntries),
            row.readTable(mealEntryItems),
          ),
        )
        .toList(growable: false);
  }

  /// Tanggal lokal (ISO) yang punya setidaknya satu catatan makan pada
  /// rentang `[from, to]` inklusif — dipakai penandaan kalender Riwayat
  /// (`18`, change 008, task 5.2), bukan konsep domain (detail penyimpanan,
  /// Design D9 change 004).
  Future<Set<String>> datesWithEntries(
    String profileId, {
    required LocalDate from,
    required LocalDate to,
  }) async {
    final query = selectOnly(mealEntries, distinct: true)
      ..addColumns([mealEntries.localDate])
      ..where(
        mealEntries.profileId.equals(profileId) &
            mealEntries.localDate.isBiggerOrEqualValue(from.iso) &
            mealEntries.localDate.isSmallerOrEqualValue(to.iso) &
            UserRecords.active(mealEntries.deletedAt),
      );
    final rows = await query.get();
    return rows.map((row) => row.read(mealEntries.localDate)!).toSet();
  }

  /// Energi per tanggal pada rentang `[from, to]` inklusif dalam satu kueri
  /// (change 018, design D1). Tanggal tanpa catatan tidak muncul di hasil;
  /// aturan penjumlahan sama dengan [dailyTotal] (satu energi tidak
  /// diketahui membuat total tanggal itu tidak diketahui).
  Future<Map<String, DiaryDayEnergy>> dailyEnergyInRange(
    String profileId, {
    required LocalDate from,
    required LocalDate to,
  }) async {
    final query =
        select(mealEntries).join([
          innerJoin(
            mealEntryItems,
            mealEntryItems.mealEntryId.equalsExp(mealEntries.id),
          ),
        ])..where(
          mealEntries.profileId.equals(profileId) &
              mealEntries.localDate.isBiggerOrEqualValue(from.iso) &
              mealEntries.localDate.isSmallerOrEqualValue(to.iso) &
              UserRecords.active(mealEntries.deletedAt) &
              UserRecords.active(mealEntryItems.deletedAt),
        );
    final rows = await query.get();
    final byDate = <String, List<NutritionProfile>>{};
    for (final row in rows) {
      final entry = _toDomain(
        row.readTable(mealEntries),
        row.readTable(mealEntryItems),
      );
      byDate
          .putIfAbsent(entry.localDate.iso, () => [])
          .add(entry.totalNutrition);
    }
    return <String, DiaryDayEnergy>{
      for (final MapEntry(:key, :value) in byDate.entries)
        key: switch (NutritionProfile.sumAll(value).energy) {
          final energy? => DiaryDayEnergy.known(energy.kcal),
          null => const DiaryDayEnergy.unknown(),
        },
    };
  }

  /// Tanggal catatan makan pertama yang masih hidup, `null` bila belum ada
  /// — batas awal pemilih rentang energi (change 018, design D6).
  Future<LocalDate?> firstEntryDate(String profileId) async {
    final earliest = mealEntries.localDate.min();
    final query = selectOnly(mealEntries)
      ..addColumns([earliest])
      ..where(
        mealEntries.profileId.equals(profileId) &
            UserRecords.active(mealEntries.deletedAt),
      );
    final value = (await query.getSingle()).read(earliest);
    return value == null ? null : LocalDate.parse(value);
  }

  @override
  Future<DailyNutritionTotal> dailyTotal(
    String profileId,
    LocalDate date,
  ) async {
    final entries = await entriesForDate(profileId, date);
    if (entries.isEmpty) {
      return DailyNutritionTotal.empty;
    }
    final loggedMealTimes = entries.map((e) => e.mealTime).toSet();
    return DailyNutritionTotal(
      nutrition: NutritionProfile.sumAll(entries.map((e) => e.totalNutrition)),
      loggedMealsCount: loggedMealTimes.length,
    );
  }

  @override
  Future<Result<MealEntry>> addEntry({
    required String profileId,
    required LocalDate date,
    required MealTime mealTime,
    required Food food,
    required ServingSize serving,
    required double quantity,
  }) async {
    final validQuantity = ValueRules.positiveAmount(
      quantity,
      field: 'quantity',
    );
    if (validQuantity is Err<double>) {
      return Err<MealEntry>(validQuantity.failureOrNull!);
    }

    final now = _clock.nowUtc();
    final entryId = _ids.next();
    final itemId = _ids.next();

    await transaction(() async {
      await into(mealEntries).insert(
        MealEntriesCompanion.insert(
          id: entryId,
          createdAt: now,
          updatedAt: now,
          profileId: profileId,
          localDate: date.iso,
          mealTime: mealTime.stableCode,
        ),
      );
      await into(mealEntryItems).insert(
        MealEntryItemsCompanion.insert(
          id: itemId,
          createdAt: now,
          updatedAt: now,
          mealEntryId: entryId,
          foodId: food.id,
          servingId: serving.id,
          quantity: quantity,
          foodNameSnapshot: food.name,
          servingLabelSnapshot: serving.label,
          energyKcalSnapshot: Value<double?>(serving.nutrition.energy?.kcal),
          proteinGSnapshot: Value<double?>(serving.nutrition.proteinG),
          carbohydrateGSnapshot: Value<double?>(
            serving.nutrition.carbohydrateG,
          ),
          fatGSnapshot: Value<double?>(serving.nutrition.fatG),
        ),
      );
    });

    await rebuildProgressFor(profileId, date);

    final entryRow = await (select(
      mealEntries,
    )..where((t) => t.id.equals(entryId))).getSingle();
    final itemRow = await (select(
      mealEntryItems,
    )..where((t) => t.id.equals(itemId))).getSingle();
    return Ok<MealEntry>(_toDomain(entryRow, itemRow));
  }

  @override
  Future<Result<List<MealEntry>>> addEntries({
    required String profileId,
    required LocalDate date,
    required MealTime mealTime,
    required List<NewMealEntry> entries,
  }) async {
    for (final entry in entries) {
      final validQuantity = ValueRules.positiveAmount(
        entry.quantity,
        field: 'quantity',
      );
      if (validQuantity is Err<double>) {
        return Err<List<MealEntry>>(validQuantity.failureOrNull!);
      }
    }

    final now = _clock.nowUtc();
    final ids = <(String entryId, String itemId)>[
      for (final _ in entries) (_ids.next(), _ids.next()),
    ];

    await transaction(() async {
      for (var i = 0; i < entries.length; i++) {
        final entry = entries[i];
        final (entryId, itemId) = ids[i];
        await into(mealEntries).insert(
          MealEntriesCompanion.insert(
            id: entryId,
            createdAt: now,
            updatedAt: now,
            profileId: profileId,
            localDate: date.iso,
            mealTime: mealTime.stableCode,
          ),
        );
        await into(mealEntryItems).insert(
          MealEntryItemsCompanion.insert(
            id: itemId,
            createdAt: now,
            updatedAt: now,
            mealEntryId: entryId,
            foodId: entry.food.id,
            servingId: entry.serving.id,
            quantity: entry.quantity,
            foodNameSnapshot: entry.food.name,
            servingLabelSnapshot: entry.serving.label,
            energyKcalSnapshot: Value<double?>(
              entry.serving.nutrition.energy?.kcal,
            ),
            proteinGSnapshot: Value<double?>(entry.serving.nutrition.proteinG),
            carbohydrateGSnapshot: Value<double?>(
              entry.serving.nutrition.carbohydrateG,
            ),
            fatGSnapshot: Value<double?>(entry.serving.nutrition.fatG),
          ),
        );
      }
    });

    await rebuildProgressFor(profileId, date);

    final results = <MealEntry>[];
    for (final (entryId, itemId) in ids) {
      final entryRow = await (select(
        mealEntries,
      )..where((t) => t.id.equals(entryId))).getSingle();
      final itemRow = await (select(
        mealEntryItems,
      )..where((t) => t.id.equals(itemId))).getSingle();
      results.add(_toDomain(entryRow, itemRow));
    }
    return Ok<List<MealEntry>>(results);
  }

  @override
  Future<Result<MealEntry>> updateEntry({
    required String entryId,
    required ServingSize serving,
    required double quantity,
    required MealTime mealTime,
  }) async {
    final validQuantity = ValueRules.positiveAmount(
      quantity,
      field: 'quantity',
    );
    if (validQuantity is Err<double>) {
      return Err<MealEntry>(validQuantity.failureOrNull!);
    }

    final entryRow = await (select(
      mealEntries,
    )..where((t) => t.id.equals(entryId))).getSingle();
    final itemRow = await (select(
      mealEntryItems,
    )..where((t) => t.mealEntryId.equals(entryId))).getSingle();

    final now = _clock.nowUtc();
    final servingChanged = itemRow.servingId != serving.id;

    await transaction(() async {
      await (update(mealEntries)..where((t) => t.id.equals(entryId))).write(
        MealEntriesCompanion(
          mealTime: Value<String>(mealTime.stableCode),
          updatedAt: Value<DateTime>(now),
          revision: Value<int>(entryRow.revision + 1),
        ),
      );
      await (update(
        mealEntryItems,
      )..where((t) => t.id.equals(itemRow.id))).write(
        MealEntryItemsCompanion(
          servingId: Value<String>(serving.id),
          quantity: Value<double>(quantity),
          servingLabelSnapshot: Value<String>(serving.label),
          energyKcalSnapshot: servingChanged
              ? Value<double?>(serving.nutrition.energy?.kcal)
              : const Value<double?>.absent(),
          proteinGSnapshot: servingChanged
              ? Value<double?>(serving.nutrition.proteinG)
              : const Value<double?>.absent(),
          carbohydrateGSnapshot: servingChanged
              ? Value<double?>(serving.nutrition.carbohydrateG)
              : const Value<double?>.absent(),
          fatGSnapshot: servingChanged
              ? Value<double?>(serving.nutrition.fatG)
              : const Value<double?>.absent(),
          updatedAt: Value<DateTime>(now),
          revision: Value<int>(itemRow.revision + 1),
        ),
      );
    });

    await rebuildProgressFor(
      entryRow.profileId,
      LocalDate.parse(entryRow.localDate),
    );

    final updatedEntry = await (select(
      mealEntries,
    )..where((t) => t.id.equals(entryId))).getSingle();
    final updatedItem = await (select(
      mealEntryItems,
    )..where((t) => t.id.equals(itemRow.id))).getSingle();
    return Ok<MealEntry>(_toDomain(updatedEntry, updatedItem));
  }

  @override
  Future<void> deleteEntry(String entryId) async {
    final entryRow = await (select(
      mealEntries,
    )..where((t) => t.id.equals(entryId))).getSingle();
    final now = _clock.nowUtc();

    await transaction(() async {
      await (update(mealEntries)..where((t) => t.id.equals(entryId))).write(
        MealEntriesCompanion(
          deletedAt: Value<DateTime?>(now),
          updatedAt: Value<DateTime>(now),
          revision: Value<int>(entryRow.revision + 1),
        ),
      );
      final itemRows = await (select(
        mealEntryItems,
      )..where((t) => t.mealEntryId.equals(entryId))).get();
      for (final item in itemRows) {
        await (update(
          mealEntryItems,
        )..where((t) => t.id.equals(item.id))).write(
          MealEntryItemsCompanion(
            deletedAt: Value<DateTime?>(now),
            updatedAt: Value<DateTime>(now),
            revision: Value<int>(item.revision + 1),
          ),
        );
      }
    });

    await rebuildProgressFor(
      entryRow.profileId,
      LocalDate.parse(entryRow.localDate),
    );
  }

  MealEntry _toDomain(MealEntryRow entry, MealEntryItemRow item) => MealEntry(
    id: entry.id,
    profileId: entry.profileId,
    localDate: LocalDate.parse(entry.localDate),
    mealTime: MealTime.fromStableCode(entry.mealTime),
    foodId: item.foodId,
    servingId: item.servingId,
    foodNameSnapshot: item.foodNameSnapshot,
    servingLabelSnapshot: item.servingLabelSnapshot,
    quantity: item.quantity,
    nutritionPerServing: NutritionProfile(
      energy: item.energyKcalSnapshot == null
          ? null
          : Energy.kcalValue(
              item.energyKcalSnapshot!,
              field: 'energyKcalSnapshot',
            ).valueOrNull,
      proteinG: item.proteinGSnapshot,
      carbohydrateG: item.carbohydrateGSnapshot,
      fatG: item.fatGSnapshot,
    ),
    createdAt: entry.createdAt,
  );

  /// Memicu pembangunan ulang potret kemajuan program untuk [date] (Design
  /// D8, task 5.3/5.4; design D5 change 008) — idempoten, aman dipanggil
  /// pada setiap perubahan catatan makan ATAU catatan berat untuk tanggal
  /// yang sama (dipanggil juga oleh `DriftWeightRepository`).
  ///
  /// Satu-satunya tempat yang menulis potret kemajuan untuk sebuah tanggal
  /// — membaca ulang buku harian DAN catatan berat setiap kali dipanggil,
  /// bukan hanya bagian milik pemanggil, supaya penulisan oleh satu sisi
  /// tidak menimpa nilai sisi lain untuk tanggal yang sama (`rebuildProgressForDate`
  /// change 004 mengganti seluruh baris, bukan menggabungkan).
  ///
  /// Tidak melakukan apa pun bila tidak ada program yang berjalan — sesuai
  /// spec daily-dashboard: ringkasan hari tetap tampil dari buku harian
  /// langsung, bukan dari potret, ketika tidak ada program.
  Future<void> rebuildProgressFor(String profileId, LocalDate date) async {
    final program = await _programRepository.findRunning(profileId);
    if (program == null) {
      return;
    }

    final total = await dailyTotal(profileId, date);
    final activeDayNumber = _activeDayNumberOn(program, date);
    final energyTarget = program.proposal.energyTarget;
    final consumedEnergyKcal = total.nutrition.energy?.kcal;
    final weightKg = await _weightForDate(profileId, date);
    final startWeightKg = program.inputSnapshot.currentWeight.kg;
    final targetWeightKg = program.inputSnapshot.specific.targetWeight?.kg;
    final weightChangeKg = weightKg == null ? null : weightKg - startWeightKg;
    // Hanya bermakna untuk program dengan berat tujuan (Turun/Naik Berat) —
    // tetap null untuk Pertahankan dan Makan Sehat (tidak ada tujuan untuk
    // dibandingkan), bukan nilai yang dikarang.
    final targetProgressRatio =
        weightKg == null ||
            targetWeightKg == null ||
            targetWeightKg == startWeightKg
        ? null
        : ((weightKg - startWeightKg) / (targetWeightKg - startWeightKg)).clamp(
            0.0,
            1.0,
          );

    await _programRepository.rebuildProgressForDate(
      userProgramId: program.id,
      localDate: date,
      input: ProgramProgressInput(
        recordedAt: _clock.nowUtc(),
        loggedMealsCount: total.loggedMealsCount,
        diaryComplete: total.loggedMealsCount >= MealTime.values.length,
        activeDayNumber: activeDayNumber,
        calculationVersion: program.proposal.calculatorVersion,
        weightKg: weightKg,
        weightChangeKg: weightChangeKg,
        targetProgressRatio: targetProgressRatio,
        consumedEnergyKcal: consumedEnergyKcal,
        energyAdherenceRatio: energyTarget == null || consumedEnergyKcal == null
            ? null
            : consumedEnergyKcal / energyTarget.kcal,
        proteinG: total.nutrition.proteinG,
        carbohydrateG: total.nutrition.carbohydrateG,
        fatG: total.nutrition.fatG,
      ),
    );
  }

  /// Berat yang tercatat untuk [profileId] tepat pada [date], bila ada —
  /// bukan berat terbaru keseluruhan (change 008, spec weight-tracking).
  /// Beberapa catatan pada tanggal yang sama memutus seri lewat
  /// `recordedAt` terbaru, selaras `DriftWeightRepository.latest`.
  Future<double?> _weightForDate(String profileId, LocalDate date) async {
    final row =
        await (select(weightRecords)
              ..where(
                (t) =>
                    t.profileId.equals(profileId) &
                    t.localDate.equals(date.iso) &
                    UserRecords.active(t.deletedAt),
              )
              ..orderBy([(t) => OrderingTerm.desc(t.recordedAt)])
              ..limit(1))
            .getSingleOrNull();
    return row?.weightKg;
  }

  /// Hari aktif ke berapa [date] sejak [program] dimulai: menghitung hari
  /// kalender lokal dari tanggal mulai sampai [date] (inklusif), mengurangi
  /// hari yang berada dalam rentang jeda mana pun (spec daily-dashboard,
  /// "Hari dalam rentang jeda SHALL TIDAK menambah hitungan hari aktif").
  int _activeDayNumberOn(UserProgram program, LocalDate date) {
    final startDate = _clock.localDateOf(program.startedAt);
    if (date.compareTo(startDate) < 0) {
      return 1;
    }
    var activeDays = 0;
    var cursor = startDate;
    while (cursor.compareTo(date) <= 0) {
      if (!_isPaused(program.pauseIntervals, cursor)) {
        activeDays += 1;
      }
      cursor = _nextDay(cursor);
    }
    return activeDays < 1 ? 1 : activeDays;
  }

  bool _isPaused(List<PauseInterval> intervals, LocalDate day) {
    for (final interval in intervals) {
      final start = _clock.localDateOf(interval.startedAt);
      final end = interval.endedAt == null
          ? null
          : _clock.localDateOf(interval.endedAt!);
      if (day.compareTo(start) < 0) {
        continue;
      }
      if (end == null || day.compareTo(end) <= 0) {
        return true;
      }
    }
    return false;
  }

  LocalDate _nextDay(LocalDate date) {
    final next = DateTime(date.year, date.month, date.day + 1);
    return LocalDate(next.year, next.month, next.day);
  }
}
