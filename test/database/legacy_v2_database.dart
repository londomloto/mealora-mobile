import 'package:drift/drift.dart';
import 'package:mealora/database/tables/harness_records.dart';
import 'package:mealora/database/tables/programs_table.dart';
import 'package:mealora/database/tables/ui_preferences.dart';
import 'package:mealora/database/tables/user_programs_table.dart'
    show kUserProgramStatuses;
import 'package:mealora/database/tables/user_record_columns.dart';

part 'legacy_v2_database.g.dart';

/// `user_programs` dibekukan persis seperti bentuknya di versi 2 (change
/// 004) — `profileId` adalah teks bebas, BUKAN foreign key.
///
/// Kelas `UserPrograms` yang dipakai `AppDatabase` sudah memuat foreign key
/// ke `profiles` (change 005), dan drift_dev secara otomatis menyertakan
/// tabel tujuan sebuah foreign key ke `allSchemaEntities` meski tidak
/// didaftarkan eksplisit di `tables:` — mereferensikannya di sini akan
/// diam-diam membuat `profiles` ikut tercipta pada fixture v2, membatalkan
/// maksud fixture ini. Salinan beku tersendiri inilah yang menjaga fixture
/// v2 benar-benar tidak punya tabel `profiles`.
@DataClassName('UserProgramV2Row')
class UserProgramsV2 extends Table with UserRecordColumns {
  @override
  String get tableName => 'user_programs';

  TextColumn get profileId => text().withLength(min: 1, max: 64)();

  TextColumn get programId =>
      text().references(Programs, #id, onDelete: KeyAction.restrict)();

  TextColumn get status => text()
      .withLength(min: 1, max: 16)
      // ignore: recursive_getters
      .check(status.isIn(kUserProgramStatuses))();

  DateTimeColumn get startedAt => dateTime().nullable()();
  DateTimeColumn get pausedAt => dateTime().nullable()();
  DateTimeColumn get endedAt => dateTime().nullable()();

  RealColumn get baselineWeightKg => real().nullable()();
  RealColumn get targetWeightKg => real().nullable()();
  TextColumn get targetDate => text().withLength(min: 10, max: 10).nullable()();

  RealColumn get dailyEnergyTargetKcal => real().nullable()();
  RealColumn get proteinTargetG => real().nullable()();
  RealColumn get carbohydrateTargetG => real().nullable()();
  RealColumn get fatTargetG => real().nullable()();
  RealColumn get fiberTargetG => real().nullable()();

  TextColumn get inputSnapshotJson => text()();
  TextColumn get calculatorVersion => text().withLength(min: 1, max: 32)();
  TextColumn get policyVersion => text().withLength(min: 1, max: 32)();

  TextColumn get pauseReason => text().withLength(min: 1, max: 64).nullable()();
  TextColumn get completionReason =>
      text().withLength(min: 1, max: 64).nullable()();

  TextColumn get supersedesUserProgramId => text().nullable()();
  TextColumn get supersededByUserProgramId => text().nullable()();
}

@DataClassName('ProgramEventV2Row')
class ProgramEventsV2 extends Table with AppendOnlyRecordColumns {
  @override
  String get tableName => 'program_events';

  TextColumn get userProgramId =>
      text().references(UserProgramsV2, #id, onDelete: KeyAction.restrict)();

  TextColumn get eventType => text().withLength(min: 1, max: 16)();
  DateTimeColumn get occurredAt => dateTime()();
  TextColumn get fromStatus => text().withLength(min: 1, max: 16).nullable()();
  TextColumn get toStatus => text().withLength(min: 1, max: 16).nullable()();
  TextColumn get reasonCode => text().withLength(min: 1, max: 64).nullable()();
  TextColumn get metadataJson => text().withDefault(const Constant('{}'))();
}

@DataClassName('ProgramProgressV2Row')
class ProgramProgressV2 extends Table with UserRecordColumns {
  @override
  String get tableName => 'program_progress';

  TextColumn get userProgramId =>
      text().references(UserProgramsV2, #id, onDelete: KeyAction.restrict)();

  TextColumn get recordedLocalDate => text().withLength(min: 10, max: 10)();
  DateTimeColumn get recordedAt => dateTime()();

  RealColumn get weightKg => real().nullable()();
  RealColumn get weightChangeKg => real().nullable()();
  RealColumn get targetProgressRatio => real().nullable()();
  RealColumn get consumedEnergyKcal => real().nullable()();
  RealColumn get energyAdherenceRatio => real().nullable()();
  RealColumn get proteinG => real().nullable()();
  RealColumn get carbohydrateG => real().nullable()();
  RealColumn get fatG => real().nullable()();

  IntColumn get loggedMealsCount => integer().withDefault(const Constant(0))();
  BoolColumn get diaryComplete =>
      boolean().withDefault(const Constant(false))();
  IntColumn get activeDayNumber => integer()();
  TextColumn get metricsJson => text().withDefault(const Constant('{}'))();
  TextColumn get calculationVersion => text().withLength(min: 1, max: 32)();
}

/// Skema versi 2 dibekukan (change 004) — dipakai khusus fixture migrasi
/// versi 2 ke 3 (change 005, task 2.6): membuat berkas SQLite sungguhan
/// pada versi 2 tanpa tabel `profiles` dan tanpa foreign key dari
/// `user_programs.profile_id`, lalu dibuka kembali dengan `AppDatabase`
/// (versi 3) sehingga jalur `onUpgrade` dari `from == 2` benar-benar
/// teruji — bukan sekadar `onCreate` langsung pada versi terkini.
@DriftDatabase(
  tables: <Type>[
    HarnessRecords,
    HarnessRecordNotes,
    UiPreferences,
    Programs,
    UserProgramsV2,
    ProgramProgressV2,
    ProgramEventsV2,
  ],
)
class LegacyV2Database extends _$LegacyV2Database {
  LegacyV2Database(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
  );
}
