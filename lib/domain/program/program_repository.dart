import 'package:mealora/domain/program/program_event.dart';
import 'package:mealora/domain/program/user_program.dart';

/// Kontrak penyimpanan program — diimplementasikan oleh tiruan dalam
/// memori di sini (task 7.9) dan oleh Drift pada change berikutnya.
///
/// Domain tidak mengetahui bagaimana ini diimplementasikan; hanya
/// menyatakan operasi apa yang dibutuhkan, termasuk jaminan atomisitas
/// yang harus dipenuhi implementasi.
abstract interface class ProgramRepository {
  /// Program berstatus `active` atau `paused` milik [profileId], bila ada.
  UserProgram? findRunning(String profileId);

  UserProgram? findById(String id);

  List<ProgramEvent> eventsFor(String userProgramId);

  /// Menyimpan [program] baru atau memperbarui yang sudah ada.
  void upsert(UserProgram program);

  void appendEvent(ProgramEvent event);

  /// Menerapkan pergantian program sebagai satu kesatuan
  /// (program-lifecycle spec, "Pergantian program berlangsung utuh").
  ///
  /// Implementasi SHALL menerapkan seluruh perubahan — program lama,
  /// program baru, dan peristiwa — atau tidak sama sekali. Bila metode ini
  /// melempar, keadaan penyimpanan SHALL kembali seperti sebelum dipanggil.
  void applyProgramChange({
    required UserProgram supersededProgram,
    required UserProgram newProgram,
    required List<ProgramEvent> events,
  });
}
