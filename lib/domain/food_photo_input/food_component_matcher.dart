import 'package:mealora/domain/food/food.dart';
import 'package:mealora/domain/food/food_repository.dart';

/// Memadankan tebakan nama komponen hasil foto ke katalog makanan,
/// makanan buatan pengguna, atau produk yang pernah dikonfirmasi (spec
/// food-photo-input, "Nilai gizi berasal dari catatan makanan yang dapat
/// ditelusuri") — SATU-SATUNYA titik yang membaca katalog untuk jalur foto,
/// supaya tidak ada kemungkinan model ikut memengaruhi nilai gizi (Design
/// D1, change 011).
///
/// Memakai ulang `FoodRepository.search` apa adanya (Design D3,
/// food-catalog, change 007): kecocokan substring tanpa membedakan huruf
/// besar-kecil, kecocokan di awal nama lebih diutamakan. Mengembalikan
/// hasil teratas, atau `null` bila tidak ada kecocokan sama sekali — bukan
/// kecocokan yang "cukup mirip" yang dapat salah menebak komponen (spec,
/// "Komponen tanpa padanan").
final class FoodComponentMatcher {
  const FoodComponentMatcher(this._repository);

  final FoodRepository _repository;

  Future<Food?> match(String foodNameGuess) async {
    final query = foodNameGuess.trim();
    if (query.isEmpty) {
      return null;
    }
    final results = await _repository.search(query);
    return results.isEmpty ? null : results.first;
  }
}
