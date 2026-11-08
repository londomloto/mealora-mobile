import 'package:drift/drift.dart';
import 'package:mealora/database/tables/user_record_columns.dart';

/// Tabel harness internal.
///
/// Tabel ini **bukan tabel produk**. Keberadaannya semata untuk membuktikan
/// dan menguji konvensi record milik pengguna (pengenal, jejak waktu,
/// penghapusan lunak, revisi, batasan nilai, kunci asing, transaksi) sebelum
/// tabel domain sungguhan masuk di change berikutnya. Kode fitur dilarang
/// memakainya — aturan ini ditegakkan oleh uji arsitektur.
class HarnessRecords extends Table with UserRecordColumns {
  TextColumn get label => text().withLength(min: 1, max: 120)();

  /// Besaran yang harus bernilai positif (mewakili jumlah/berat).
  // ignore: recursive_getters — idiom Drift untuk CHECK yang merujuk kolomnya sendiri.
  RealColumn get amount => real().check(amount.isBiggerThanValue(0))();

  /// Nilai gizi. `null` berarti belum diketahui — dibedakan dari nol.
  RealColumn get nutrientValue =>
      // ignore: recursive_getters
      real().nullable().check(nutrientValue.isBiggerOrEqualValue(0))();

  /// Tanggal lokal (`YYYY-MM-DD`) saat record dicatat, dipakai untuk
  /// pengelompokan harian dan tidak dihitung ulang kemudian.
  TextColumn get localDate => text().withLength(min: 10, max: 10)();

  /// Pengenal zona waktu perangkat saat record dicatat.
  TextColumn get timeZoneId => text().withLength(min: 1, max: 64)();
}

/// Tabel anak dari [HarnessRecords], juga harness-only.
///
/// Ada supaya penegakan kunci asing dan keutuhan transaksi benar-benar
/// teruji, bukan sekadar diasumsikan.
class HarnessRecordNotes extends Table with UserRecordColumns {
  TextColumn get recordId =>
      text().references(HarnessRecords, #id, onDelete: KeyAction.restrict)();

  TextColumn get note => text().withLength(min: 1, max: 280)();
}
