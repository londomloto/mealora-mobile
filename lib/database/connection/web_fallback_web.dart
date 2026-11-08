import 'package:drift/drift.dart';
import 'package:drift/wasm.dart';
import 'package:sqlite3/wasm.dart';

/// Jalur cadangan khusus pratinjau web debug.
///
/// Sebagian lingkungan browser melarang worker bersama mengambil berkas
/// `sqlite3.wasm`, sehingga penyimpanan web yang bertahan tidak dapat dibuka.
/// Agar iterasi antarmuka tetap bisa berjalan (design D3), modul WASM dimuat
/// di isolate utama dan dipakai dengan berkas in-memory.
///
/// Konsekuensinya data **tidak bertahan** antar muat ulang. Jalur ini hanya
/// aktif pada build debug dan tidak pernah dipakai di Android.
Future<QueryExecutor?> openWebFallbackConnection() async {
  final sqlite3 = await WasmSqlite3.loadFromUrl(
    Uri.base.resolve('sqlite3.wasm'),
  );
  sqlite3.registerVirtualFileSystem(InMemoryFileSystem(), makeDefault: true);
  return WasmDatabase(sqlite3: sqlite3, path: '/mealora.db');
}
