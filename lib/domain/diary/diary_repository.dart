import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/errors/result.dart';
import 'package:mealora/domain/diary/daily_nutrition_total.dart';
import 'package:mealora/domain/diary/meal_entry.dart';
import 'package:mealora/domain/food/food.dart';
import 'package:mealora/domain/food/meal_time.dart';
import 'package:mealora/domain/food/serving_size.dart';

/// Kontrak buku harian (change 007) — diimplementasikan oleh Drift.
///
/// Implementasi SHALL menulis catatan beserta potretnya sebagai satu
/// kesatuan: seluruhnya tersimpan atau tidak sama sekali (spec food-diary,
/// "Penulisan catatan bersifat utuh").
abstract interface class DiaryRepository {
  /// Seluruh catatan [profileId] pada [date], terbaru lebih dulu di dalam
  /// tiap waktu makan.
  Future<List<MealEntry>> entriesForDate(String profileId, LocalDate date);

  /// Ringkasan gizi [profileId] pada [date] (Design D7 — dihitung, tidak
  /// dibaca dari kolom tersendiri).
  Future<DailyNutritionTotal> dailyTotal(String profileId, LocalDate date);

  /// Menambah satu catatan. Membekukan potret nilai gizi [serving] pada saat
  /// pemanggilan (Design D1) dan memicu pembangunan ulang potret kemajuan
  /// program untuk [date] (Design D8).
  ///
  /// Menolak [quantity] nol atau negatif dengan kesalahan bertipe (spec,
  /// "Jumlah tidak sah") — tidak membuat catatan apa pun pada kegagalan.
  Future<Result<MealEntry>> addEntry({
    required String profileId,
    required LocalDate date,
    required MealTime mealTime,
    required Food food,
    required ServingSize serving,
    required double quantity,
  });

  /// Menambah beberapa catatan sekaligus pada [mealTime]/[date], seluruhnya
  /// dalam SATU transaksi: berhasil semua atau tidak sama sekali (spec
  /// food-photo-input, "Pencatatan menghasilkan catatan per komponen",
  /// change 011) — setiap entri membekukan potretnya sendiri, persis
  /// seperti [addEntry] dipanggil berkali-kali, hanya atomik dan dengan
  /// SATU pembangunan ulang potret kemajuan di akhir (bukan satu per
  /// entri).
  ///
  /// Menolak permintaan ini SELURUHNYA (tidak menulis apa pun) bila SALAH
  /// SATU [entries] punya `quantity` nol atau negatif.
  Future<Result<List<MealEntry>>> addEntries({
    required String profileId,
    required LocalDate date,
    required MealTime mealTime,
    required List<NewMealEntry> entries,
  });

  /// Menyunting takaran, jumlah, dan/atau waktu makan sebuah catatan.
  /// Menghitung ulang dari potret TERSIMPAN pada catatan itu (spec,
  /// "Pengguna menyunting catatannya") — bukan dari katalog saat ini, kecuali
  /// [serving] memilih takaran lain, yang membekukan potret baru untuk
  /// takaran itu pada saat penyuntingan.
  Future<Result<MealEntry>> updateEntry({
    required String entryId,
    required ServingSize serving,
    required double quantity,
    required MealTime mealTime,
  });

  /// Menghapus sebuah catatan (penghapusan lunak, konvensi change 001).
  Future<void> deleteEntry(String entryId);
}
