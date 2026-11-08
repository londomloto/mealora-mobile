import 'package:drift/drift.dart';

/// Membuat trigger yang menegakkan "satu program berjalan per profil" di
/// tingkat basis data (Design D3, change 004) — lapis kedua di bawah
/// invarian domain dan di bawah transaksi aktivasi/pergantian.
///
/// Dua indeks unik parsial (`program_indexes.dart`) masing-masing mencegah
/// lebih dari satu baris `active`, dan masing-masing mencegah lebih dari
/// satu baris `paused`, per profil — tetapi keduanya **tidak** bersama-sama
/// mencegah satu profil punya satu baris `active` *dan* satu baris `paused`
/// sekaligus. Trigger ini menutup celah itu: trigger dianggap belum ada
/// sampai diuji dengan penulisan langsung yang sengaja melanggar invarian.
Future<void> createProgramInvariantTrigger(DatabaseConnectionUser db) async {
  for (final event in <String>['INSERT', 'UPDATE']) {
    await db.customStatement('''
CREATE TRIGGER IF NOT EXISTS user_programs_single_running_on_$event
BEFORE $event ON user_programs
FOR EACH ROW
WHEN NEW.status IN ('active', 'paused') AND NEW.deleted_at IS NULL
BEGIN
  SELECT RAISE(ABORT, 'satu profil hanya boleh memiliki satu program berjalan')
  WHERE EXISTS (
    SELECT 1 FROM user_programs
    WHERE profile_id = NEW.profile_id
      AND status IN ('active', 'paused')
      AND deleted_at IS NULL
      AND id != NEW.id
  );
END;
''');
  }

  // Keadaan akhir (`completed`, `changed`, `cancelled`) tidak punya
  // perpindahan keluar (program-lifecycle spec, change 003) — ditegakkan di
  // sini supaya penulisan langsung yang melewati domain pun ditolak
  // basis data, bukan hanya kode (task 5.4).
  await db.customStatement('''
CREATE TRIGGER IF NOT EXISTS user_programs_terminal_state_is_final
BEFORE UPDATE ON user_programs
FOR EACH ROW
WHEN OLD.status IN ('completed', 'changed', 'cancelled')
  AND NEW.status != OLD.status
BEGIN
  SELECT RAISE(ABORT, 'keadaan akhir program tidak dapat berpindah lagi');
END;
''');
}
