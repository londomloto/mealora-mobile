import 'package:mealora/domain/program/program_event.dart';
import 'package:mealora/domain/program/user_program.dart';

/// Kontrak penyimpanan program — diimplementasikan oleh tiruan dalam
/// memori di sini (task 7.9, change 003) dan oleh Drift (change 004).
///
/// Domain tidak mengetahui bagaimana ini diimplementasikan; hanya
/// menyatakan operasi apa yang dibutuhkan, termasuk jaminan atomisitas
/// yang harus dipenuhi implementasi.
///
/// `Future`-based (Design D11, change 004): koneksi Drift aplikasi ini
/// berjalan di isolate latar belakang/web worker, sehingga tidak dapat
/// diakses sinkron. Ini detail tipe Dart pada kontrak internal, bukan
/// perubahan requirement domain.
abstract interface class ProgramRepository {
  /// Program berstatus `active` atau `paused` milik [profileId], bila ada.
  Future<UserProgram?> findRunning(String profileId);

  Future<UserProgram?> findById(String id);

  Future<List<ProgramEvent>> eventsFor(String userProgramId);

  /// Seluruh program yang pernah dijalani [profileId], berurutan menurut
  /// waktu mulai (program-progress spec, "Riwayat program dapat
  /// dijelaskan"; change 004). Membaca nilai tersimpan apa adanya — SHALL
  /// TIDAK menghitung ulang target atau asumsi.
  Future<List<UserProgram>> history(String profileId);

  /// Menyimpan [program] baru atau memperbarui yang sudah ada.
  Future<void> upsert(UserProgram program);

  Future<void> appendEvent(ProgramEvent event);

  /// Menerapkan aktivasi program sebagai satu kesatuan (program-lifecycle
  /// spec, "Aktivasi dan pergantian tersimpan secara utuh"; Design D4,
  /// change 004): program baru, peristiwa aktivasi, dan potret kemajuan
  /// awal ditulis dalam satu transaksi.
  ///
  /// Implementasi SHALL menerapkan seluruh perubahan atau tidak sama
  /// sekali. Bila metode ini melempar, keadaan penyimpanan SHALL kembali
  /// seperti sebelum dipanggil.
  Future<void> applyActivation({
    required UserProgram newProgram,
    required ProgramEvent event,
  });

  /// Menerapkan pergantian program sebagai satu kesatuan
  /// (program-lifecycle spec, "Pergantian program berlangsung utuh").
  ///
  /// Implementasi SHALL menerapkan seluruh perubahan — program lama,
  /// program baru, dan peristiwa — atau tidak sama sekali. Bila metode ini
  /// melempar, keadaan penyimpanan SHALL kembali seperti sebelum dipanggil.
  Future<void> applyProgramChange({
    required UserProgram supersededProgram,
    required UserProgram newProgram,
    required List<ProgramEvent> events,
  });
}
