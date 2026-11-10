import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/errors/result.dart';
import 'package:mealora/domain/weight/weight_record.dart';

/// Kontrak catatan berat (change 008) — diimplementasikan oleh Drift.
///
/// `Future`-based (konvensi change 004 Design D11): koneksi Drift aplikasi
/// ini berjalan di isolate latar belakang/web worker.
abstract interface class WeightRepository {
  /// Catatan terbaru milik [profileId] menurut [WeightRecord.recordedAt],
  /// bila ada (design D1 — berat "saat ini" adalah catatan terbaru yang
  /// hidup, bukan kolom tersendiri).
  Future<WeightRecord?> latest(String profileId);

  /// Seluruh catatan [profileId] pada rentang tanggal lokal
  /// `[from, to]` inklusif, terlama lebih dulu — dipakai untuk tren dan
  /// daftar catatan terakhir (task 2.3).
  Future<List<WeightRecord>> recordsInRange(
    String profileId, {
    required LocalDate from,
    required LocalDate to,
  });

  /// Menambah satu catatan. Menolak berat di luar rentang masuk akal dan
  /// tanggal di masa depan dengan kesalahan bertipe (design D9) — tidak
  /// membuat catatan apa pun pada kegagalan. Memicu pembangunan ulang
  /// potret kemajuan program dan pemeriksaan ambang hitung ulang target
  /// untuk [date] (design D5).
  Future<Result<WeightRecord>> addRecord({
    required String profileId,
    required LocalDate date,
    required double weightKg,
    String? note,
  });

  /// Menyunting nilai, tanggal, dan/atau catatan bebas sebuah catatan
  /// (design D4). Memicu ulang pembangunan potret kemajuan dan pemeriksaan
  /// ambang untuk tanggal lama maupun tanggal baru bila berbeda.
  Future<Result<WeightRecord>> updateRecord({
    required String recordId,
    required LocalDate date,
    required double weightKg,
    String? note,
  });

  /// Menghapus sebuah catatan (penghapusan lunak, konvensi change 001).
  /// Memicu ulang pembangunan potret kemajuan dan pemeriksaan ambang untuk
  /// tanggal catatan yang dihapus (design D4/D5).
  Future<void> deleteRecord(String recordId);
}
