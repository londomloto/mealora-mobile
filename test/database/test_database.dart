import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/clock/fixed_clock.dart';
import 'package:mealora/core/ids/id_generator.dart';
import 'package:mealora/core/ids/sequential_id_generator.dart';
import 'package:mealora/database/app_database.dart';

/// Waktu tetap yang dipakai seluruh uji basis data.
DateTime get testInstant => DateTime.utc(2026, 11, 8, 2, 30);

/// Zona waktu uji: Asia/Jakarta (UTC+7).
Clock createTestClock() => FixedClock(
  instantUtc: testInstant,
  timeZoneId: 'Asia/Jakarta',
  utcOffset: const Duration(hours: 7),
);

IdGenerator createTestIds() => SequentialIdGenerator();

/// Basis data uji di atas SQLite nyata.
///
/// `NativeDatabase` memakai pustaka SQLite asli, bukan tiruan — sesuai
/// tuntutan change 001 bahwa uji penyimpanan dijalankan terhadap SQLite
/// sungguhan.
AppDatabase createTestDatabase({QueryExecutor? executor}) {
  return AppDatabase(executor ?? NativeDatabase.memory());
}
