import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/errors/result.dart';
import 'package:mealora/domain/diary/meal_entry.dart';
import 'package:mealora/domain/food/meal_time.dart';
import 'package:mealora/domain/packaged_food/packaged_food.dart';
import 'package:mealora/domain/packaged_food/packaged_food_nutrition.dart';
import 'package:mealora/domain/packaged_food/packaged_food_quantity.dart';
import 'package:mealora/features/diary/diary_controller.dart';
import 'package:mealora/features/diary/diary_providers.dart';

/// Mencari produk menurut [barcode]: perangkat lebih dulu, baru sumber
/// daring bila tidak ketemu (Design D1, change 009). `null` bila tidak
/// ditemukan di mana pun — hasil daring BELUM tersimpan (spec, "Produk
/// ditinjau sebelum dicatat").
Future<PackagedFood?> lookupPackagedFoodByBarcode(
  WidgetRef ref,
  String barcode,
) {
  return ref.read(packagedFoodRepositoryProvider).findByBarcode(barcode);
}

/// Mengonfirmasi [product] (menyimpannya beserta provenans, task 4.4) lalu
/// mencatatnya ke buku harian lewat jalur yang SAMA dengan makanan lain
/// (task 7.6: `logFoodEntry`, change 007) — tidak ada skema penyimpanan
/// baru untuk butir catatan.
///
/// SHALL TIDAK dipanggil sebelum pengguna mengonfirmasi secara eksplisit
/// (spec, "Pemindaian dibatalkan" — menutup layar tinjau tanpa ini tidak
/// membuat catatan apa pun, task 7.5).
Future<Result<MealEntry>> confirmAndLogPackagedFood(
  WidgetRef ref, {
  required PackagedFood product,
  required MealTime mealTime,
  required PackagedFoodQuantity quantity,
  LocalDate? date,
}) async {
  final confirmed = await ref
      .read(packagedFoodRepositoryProvider)
      .confirm(product);
  final multiplier = packagedFoodQuantityMultiplier(confirmed, quantity);
  return logFoodEntry(
    ref,
    mealTime: mealTime,
    food: confirmed.food,
    serving: confirmed.food.defaultServing,
    quantity: multiplier,
    date: date,
  );
}
