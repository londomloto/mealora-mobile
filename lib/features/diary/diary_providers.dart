import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/errors/result.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/domain/diary/daily_nutrition_total.dart';
import 'package:mealora/domain/diary/meal_entry.dart'
    show MealEntry, NewMealEntry;
import 'package:mealora/domain/food/food.dart';
import 'package:mealora/domain/food/food_category.dart';
import 'package:mealora/domain/food/food_repository.dart';
import 'package:mealora/domain/food/meal_time.dart';
import 'package:mealora/domain/food/recent_food.dart';
import 'package:mealora/domain/food/serving_size.dart';
import 'package:mealora/domain/food_photo_input/photo_draft.dart';
import 'package:mealora/features/diary/diary_controller.dart';
import 'package:mealora/features/onboarding/onboarding_controller.dart'
    show onboardingRefreshSignalProvider, profileRepositoryProvider;

/// Ringkasan gizi satu tanggal (Design D7 — dihitung, bukan dibaca dari
/// kolom tersendiri). `null` profil (belum onboarding) memberi hari kosong.
final FutureProviderFamily<DailyNutritionTotal, LocalDate>
dailyNutritionTotalProvider =
    FutureProvider.family<DailyNutritionTotal, LocalDate>((ref, date) async {
      ref.watch(diaryRefreshSignalProvider);
      ref.watch(onboardingRefreshSignalProvider);
      final profile = await ref.watch(profileRepositoryProvider).current();
      if (profile == null) {
        return DailyNutritionTotal.empty;
      }
      return ref.watch(diaryRepositoryProvider).dailyTotal(profile.id, date);
    });

/// Catatan satu tanggal, dikelompokkan di sisi pemanggil menurut waktu makan
/// (task 7.1).
final FutureProviderFamily<List<MealEntry>, LocalDate> diaryEntriesProvider =
    FutureProvider.family<List<MealEntry>, LocalDate>((ref, date) async {
      ref.watch(diaryRefreshSignalProvider);
      ref.watch(onboardingRefreshSignalProvider);
      final profile = await ref.watch(profileRepositoryProvider).current();
      if (profile == null) {
        return const <MealEntry>[];
      }
      return ref
          .watch(diaryRepositoryProvider)
          .entriesForDate(profile.id, date);
    });

/// Makanan yang terakhir dicatat profil ini (Design D4) — kosong bagi
/// pengguna baru, tidak diisi contoh (task 6.3).
final FutureProvider<List<RecentFood>> recentFoodsProvider =
    FutureProvider<List<RecentFood>>((ref) async {
      ref.watch(diaryRefreshSignalProvider);
      ref.watch(onboardingRefreshSignalProvider);
      final profile = await ref.watch(profileRepositoryProvider).current();
      if (profile == null) {
        return const <RecentFood>[];
      }
      return ref.watch(foodRepositoryProvider).recentlyLogged(profile.id);
    });

/// Hasil pencarian untuk kueri saat ini (Design D3 — pencocokan substring
/// sederhana). Kueri kosong memberi daftar kosong; bagian "terakhir
/// dicatat" dipakai sebelum pengguna mengetik (task 6.1).
final FutureProviderFamily<List<Food>, String> foodSearchProvider =
    FutureProvider.family<List<Food>, String>((ref, query) {
      return ref.watch(foodRepositoryProvider).search(query);
    });

/// Satu makanan menurut pengenalnya — `null` bila sudah dihapus dari
/// katalog (dipakai layar edit catatan untuk menawarkan pilihan takaran
/// SAAT INI, sementara nilai pada catatan tetap dari potret beku).
final FutureProviderFamily<Food?, String> foodByIdProvider =
    FutureProvider.family<Food?, String>((ref, foodId) {
      return ref.watch(foodRepositoryProvider).findById(foodId);
    });

/// Menambah satu catatan ke buku harian (task 4.1) dan menaikkan sinyal
/// pembaruan pada keberhasilan.
///
/// [date] `null` berarti hari ini — jalur pencatatan biasa (`02`). Ruang
/// Riwayat (`18`, change 008, task 5.6) mengisi tanggal yang sedang
/// ditinjau supaya mencatat makanan dari hari lampau tidak diam-diam
/// tercatat ke hari ini.
Future<Result<MealEntry>> logFoodEntry(
  WidgetRef ref, {
  required MealTime mealTime,
  required Food food,
  required ServingSize serving,
  required double quantity,
  LocalDate? date,
}) async {
  final profile = await ref.read(profileRepositoryProvider).current();
  if (profile == null) {
    throw StateError('logFoodEntry dipanggil sebelum profil siap.');
  }
  final effectiveDate = date ?? ref.read(clockProvider).today();
  final result = await ref
      .read(diaryRepositoryProvider)
      .addEntry(
        profileId: profile.id,
        date: effectiveDate,
        mealTime: mealTime,
        food: food,
        serving: serving,
        quantity: quantity,
      );
  if (result is Ok<MealEntry>) {
    bumpDiaryRefresh(ref);
  }
  return result;
}

/// Menambah beberapa catatan sekaligus (task 7.1, change 011: foto makanan
/// dan — lewat jalur peninjauan yang sama — suara) dalam satu transaksi
/// atomik, dan menaikkan sinyal pembaruan sekali pada keberhasilan.
Future<Result<List<MealEntry>>> logFoodEntries(
  WidgetRef ref, {
  required MealTime mealTime,
  required List<NewMealEntry> entries,
  LocalDate? date,
}) async {
  final profile = await ref.read(profileRepositoryProvider).current();
  if (profile == null) {
    throw StateError('logFoodEntries dipanggil sebelum profil siap.');
  }
  final effectiveDate = date ?? ref.read(clockProvider).today();
  final result = await ref
      .read(diaryRepositoryProvider)
      .addEntries(
        profileId: profile.id,
        date: effectiveDate,
        mealTime: mealTime,
        entries: entries,
      );
  if (result is Ok<List<MealEntry>>) {
    bumpDiaryRefresh(ref);
  }
  return result;
}

/// Menyunting sebuah catatan (task 4.3/4.4) dan menaikkan sinyal pembaruan
/// pada keberhasilan.
Future<Result<MealEntry>> updateFoodEntry(
  WidgetRef ref, {
  required String entryId,
  required ServingSize serving,
  required double quantity,
  required MealTime mealTime,
}) async {
  final result = await ref
      .read(diaryRepositoryProvider)
      .updateEntry(
        entryId: entryId,
        serving: serving,
        quantity: quantity,
        mealTime: mealTime,
      );
  if (result is Ok<MealEntry>) {
    bumpDiaryRefresh(ref);
  }
  return result;
}

/// Menghapus sebuah catatan (task 4.5) dan menaikkan sinyal pembaruan.
Future<void> deleteFoodEntry(WidgetRef ref, String entryId) async {
  await ref.read(diaryRepositoryProvider).deleteEntry(entryId);
  bumpDiaryRefresh(ref);
}

/// Membuat makanan buatan pengguna baru (task 3.4) dan menaikkan sinyal
/// pembaruan supaya langsung muncul di pencarian berikutnya.
Future<Food> createUserFood(
  WidgetRef ref, {
  required String name,
  required ServingSizeInput serving,
}) async {
  final food = await ref
      .read(foodRepositoryProvider)
      .createUserFood(
        name: name,
        category: FoodCategory.other,
        serving: serving,
      );
  bumpDiaryRefresh(ref);
  return food;
}

/// Draf foto makanan belum selesai milik profil aktif, bila ada (change
/// 011, task 3.4) — dipakai `TodayScreen` untuk menawarkan pemulihan draf
/// setelah aplikasi ditutup paksa dan dibuka kembali: penyimpanan draf
/// sudah bertahan melewati itu (Design D6), yang hilang hanya keadaan
/// navigasi di memori, jadi titik masuk ruang utama inilah yang
/// memulihkannya kembali, bukan draf itu sendiri.
final FutureProvider<PhotoDraft?> pendingPhotoDraftProvider =
    FutureProvider<PhotoDraft?>((ref) async {
      ref.watch(photoDraftRefreshSignalProvider);
      ref.watch(onboardingRefreshSignalProvider);
      final profile = await ref.watch(profileRepositoryProvider).current();
      if (profile == null) {
        return null;
      }
      return ref.watch(photoDraftRepositoryProvider).current(profile.id);
    });

/// Menyimpan [draft] dan menaikkan sinyal pembaruan (change 011) — SATU-
/// SATUNYA jalur yang SHALL dipakai layar foto untuk menulis draf, supaya
/// `pendingPhotoDraftProvider` selalu mutakhir.
Future<void> savePhotoDraft(WidgetRef ref, PhotoDraft draft) async {
  await ref.read(photoDraftRepositoryProvider).save(draft);
  bumpPhotoDraftRefresh(ref);
}

/// Membuang draf [draftId] (dicatat atau dibatalkan) dan menaikkan sinyal
/// pembaruan, sama seperti [savePhotoDraft].
Future<void> discardPhotoDraft(WidgetRef ref, String draftId) async {
  await ref.read(photoDraftRepositoryProvider).discard(draftId);
  bumpPhotoDraftRefresh(ref);
}
