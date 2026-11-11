import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/domain/food/meal_time.dart';

/// Satu komponen dalam draf foto makanan (Design D3/D4, change 011) — satu
/// bahan yang akan menjadi SATU catatan buku harian tersendiri setelah
/// dikonfirmasi, tidak pernah digabung dengan komponen lain (spec, "Satu
/// catatan per komponen").
///
/// [matchedFoodId]/[matchedServingId] `null` berarti belum ada padanan
/// katalog yang memadai (spec, "Komponen tanpa padanan") — komponen SHALL
/// TIDAK menampilkan nilai gizi apa pun sampai pengguna memilih atau
/// membuat makanannya. Nilai gizi itu sendiri SHALL TIDAK disimpan di sini:
/// selalu dibaca ulang dari katalog pada saat mencatat (Design D1), supaya
/// pembaruan katalog sebelum konfirmasi tidak pernah membekukan angka basi.
final class PhotoDraftComponent {
  const PhotoDraftComponent({
    required this.localId,
    required this.foodNameGuess,
    required this.quantity,
    required this.portionNeedsCheck,
    required this.cookingMethodNeedsCheck,
    this.matchedFoodId,
    this.matchedServingId,
    this.matchedFoodName,
    this.quantityUnitLabel,
    this.cookingMethod,
  });

  /// Pengenal stabil DI DALAM draf ini (bukan pengenal buku harian) —
  /// dipakai memetakan koreksi dan penghapusan ke komponen yang benar
  /// sebelum apa pun tersimpan.
  final String localId;

  /// Tebakan nama dari model pengenalan — dipertahankan untuk tampilan
  /// "dikenali sebagai ..." bahkan setelah dipadankan, supaya pengguna
  /// tahu apa yang sebenarnya dikenali dari foto.
  final String foodNameGuess;

  final String? matchedFoodId;
  final String? matchedServingId;

  /// Potret nama makanan padanan, hanya untuk tampilan tanpa membaca ulang
  /// katalog pada setiap frame — TIDAK dipakai sebagai sumber nilai gizi.
  final String? matchedFoodName;

  /// Jumlah takaran padanan (bermakna hanya ketika [matchedServingId]
  /// terisi) — SHALL lebih besar dari nol sebelum dicatat.
  final double quantity;

  /// Label satuan tebakan model (mis. "potong") — murni informasi tampilan
  /// sebelum padanan dipilih.
  final String? quantityUnitLabel;

  /// Metode masak yang ditetapkan atau diusulkan (mis. "digoreng") — `null`
  /// berarti belum ditetapkan atau tidak relevan untuk komponen ini.
  final String? cookingMethod;

  /// Ketidakpastian padanan (Design D4, sumbu 1) — `true` ketika belum ada
  /// padanan katalog yang memadai.
  bool get foodMatchNeedsCheck => matchedFoodId == null;

  /// Ketidakpastian porsi (Design D4, sumbu 2) — porsi dari foto SHALL
  /// selalu dimulai sebagai perkiraan yang perlu dicek (non-goal: "Tidak
  /// ada penghitungan massa dari foto"); layar koreksi menurunkannya begitu
  /// pengguna menegaskan atau mengubah porsinya (task 7.6, sama seperti
  /// `ReadingConfidence.needsUserAttention`, change 010).
  final bool portionNeedsCheck;

  /// Ketidakpastian metode masak (Design D4, sumbu 3).
  final bool cookingMethodNeedsCheck;

  bool get hasAnyUncertainty =>
      foodMatchNeedsCheck || portionNeedsCheck || cookingMethodNeedsCheck;

  PhotoDraftComponent withMatch({
    required String? foodId,
    required String? servingId,
    required String? foodName,
    required double quantity,
  }) => PhotoDraftComponent(
    localId: localId,
    foodNameGuess: foodNameGuess,
    matchedFoodId: foodId,
    matchedServingId: servingId,
    matchedFoodName: foodName,
    quantity: quantity,
    quantityUnitLabel: quantityUnitLabel,
    cookingMethod: cookingMethod,
    portionNeedsCheck: false,
    cookingMethodNeedsCheck: cookingMethodNeedsCheck,
  );

  PhotoDraftComponent withQuantity(double quantity) => PhotoDraftComponent(
    localId: localId,
    foodNameGuess: foodNameGuess,
    matchedFoodId: matchedFoodId,
    matchedServingId: matchedServingId,
    matchedFoodName: matchedFoodName,
    quantity: quantity,
    quantityUnitLabel: quantityUnitLabel,
    cookingMethod: cookingMethod,
    portionNeedsCheck: false,
    cookingMethodNeedsCheck: cookingMethodNeedsCheck,
  );

  PhotoDraftComponent withCookingMethod(String? cookingMethod) =>
      PhotoDraftComponent(
        localId: localId,
        foodNameGuess: foodNameGuess,
        matchedFoodId: matchedFoodId,
        matchedServingId: matchedServingId,
        matchedFoodName: matchedFoodName,
        quantity: quantity,
        quantityUnitLabel: quantityUnitLabel,
        cookingMethod: cookingMethod,
        portionNeedsCheck: portionNeedsCheck,
        cookingMethodNeedsCheck: false,
      );
}

/// Draf foto makanan (Design D6, change 011) — bertahan melewati kegagalan
/// layanan, kehilangan koneksi, dan penutupan aplikasi (task 3.2) sampai
/// pengguna mengonfirmasi atau membatalkan peninjauan.
final class PhotoDraft {
  const PhotoDraft({
    required this.id,
    required this.profileId,
    required this.localDate,
    required this.mealTime,
    required this.components,
    required this.createdAt,
    this.sourceImagePath,
  });

  final String id;
  final String profileId;
  final LocalDate localDate;
  final MealTime mealTime;

  /// `null` ketika pengaturan retensi gambar tidak mengizinkan penyimpanan
  /// (change 010, Design D9) — draf tetap berlaku tanpa foto sumber.
  final String? sourceImagePath;

  final List<PhotoDraftComponent> components;
  final DateTime createdAt;

  PhotoDraft withComponents(List<PhotoDraftComponent> components) => PhotoDraft(
    id: id,
    profileId: profileId,
    localDate: localDate,
    mealTime: mealTime,
    sourceImagePath: sourceImagePath,
    components: components,
    createdAt: createdAt,
  );
}
