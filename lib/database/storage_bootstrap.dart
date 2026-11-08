import 'package:flutter/foundation.dart';
import 'package:mealora/core/errors/failure.dart';
import 'package:mealora/core/errors/result.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/database/connection/web_fallback.dart';
import 'package:mealora/database/migrations/migration_verification.dart';

/// Membuka penyimpanan lokal dan memverifikasinya sebelum dipakai.
///
/// Mengembalikan kegagalan bertipe — bukan exception — supaya splash dapat
/// menampilkan keadaan kesalahan yang dapat dibaca pengguna alih-alih
/// menggantung (spec `app-shell`: "Splash tidak dapat membuat aplikasi
/// tersangkut").
///
/// [allowWebFallback] hanya berlaku pada build debug di web; lihat
/// `connection/web_fallback_web.dart`.
Future<Result<AppDatabase>> openLocalStorage({
  AppDatabase Function()? databaseFactory,
  bool allowWebFallback = kDebugMode,
}) async {
  final primary = await _open(databaseFactory ?? AppDatabase.new);
  if (primary.isOk || databaseFactory != null || !allowWebFallback) {
    return primary;
  }

  final fallbackExecutor = await openWebFallbackConnection();
  if (fallbackExecutor == null) {
    return primary;
  }

  debugPrint(
    'Mealora: penyimpanan web yang bertahan tidak dapat dibuka '
    '(${primary.failureOrNull?.detail}). Pratinjau debug memakai penyimpanan '
    'in-memory — data tidak akan bertahan.',
  );
  return _open(() => AppDatabase(fallbackExecutor));
}

Future<Result<AppDatabase>> _open(AppDatabase Function() create) async {
  AppDatabase? database;
  try {
    database = create();
    final check = await verifyMigration(
      database,
      expectedSchemaVersion: kSchemaVersion,
    );
    if (!check.isHealthy) {
      await database.close();
      return Err<AppDatabase>(
        Failure(FailureCode.storageMigrationFailed, detail: check.toString()),
      );
    }
    return Ok<AppDatabase>(database);
  } on Object catch (error) {
    await database?.close();
    return Err<AppDatabase>(
      Failure(FailureCode.storageUnavailable, detail: '$error'),
    );
  }
}
