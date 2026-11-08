import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

/// Satu titik masuk pembuka koneksi penyimpanan lokal.
///
/// Android memakai SQLite native, target web debug memakai `sqlite3.wasm`
/// beserta worker Drift. Lapisan fitur tidak mengetahui perbedaan ini
/// (design D3).
QueryExecutor openMealoraConnection() {
  return driftDatabase(
    name: 'mealora',
    web: DriftWebOptions(
      // URI mutlak: worker Drift menyelesaikan alamat relatif terhadap
      // skripnya sendiri, sehingga pratinjau web gagal memuat berkas ini bila
      // alamatnya ditulis relatif.
      sqlite3Wasm: Uri.base.resolve('sqlite3.wasm'),
      driftWorker: Uri.base.resolve('drift_worker.js'),
    ),
  );
}
