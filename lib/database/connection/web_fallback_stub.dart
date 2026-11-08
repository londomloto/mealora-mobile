import 'package:drift/drift.dart';

/// Di luar web tidak ada jalur cadangan: Android memakai SQLite native dan
/// kegagalan di sana memang harus dilaporkan sebagai kegagalan.
Future<QueryExecutor?> openWebFallbackConnection() async => null;
