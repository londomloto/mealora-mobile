import 'package:mealora/core/ids/id_generator.dart';
import 'package:mealora/domain/food/food.dart';
import 'package:mealora/domain/food/serving_size.dart';
import 'package:mealora/domain/food/serving_unit_matcher.dart';
import 'package:mealora/domain/food_photo_input/food_component_matcher.dart';
import 'package:mealora/domain/food_photo_input/photo_draft.dart';
import 'package:mealora/domain/voice_input/food_sentence_parser.dart';

/// Mengubah hasil penguraian kalimat menjadi komponen draf yang ditinjau di
/// layar peninjauan komponen change 011 (change 012, task 7.1-7.5).
///
/// Aturan:
/// - Setiap makanan dipadankan ke katalog, makanan buatan pengguna, atau
///   produk yang pernah dikonfirmasi lewat [FoodComponentMatcher] yang sama
///   dengan jalur foto (task 7.4). Tanpa padanan, komponen tidak membawa
///   nilai gizi apa pun dan pengguna diminta mencari atau membuatnya
///   (task 7.5).
/// - Jumlah hanya dianggap ditentukan bila jumlah DAN satuan baku disebut,
///   dan satuannya cocok dengan salah satu takaran makanan padanan.
///   Selainnya [PhotoDraftComponent.quantityUndetermined] — tidak pernah
///   menebak, tidak pernah memakai takaran bawaan sebagai jumlah yang
///   disetujui (task 7.1-7.3).
final class VoiceDraftBuilder {
  const VoiceDraftBuilder({required this.matcher, required this.ids});

  final FoodComponentMatcher matcher;
  final IdGenerator ids;

  Future<List<PhotoDraftComponent>> build(ParsedSentence sentence) async {
    final components = <PhotoDraftComponent>[];
    for (final item in sentence.items) {
      final match = await matcher.match(item.foodName);
      components.add(_component(item, match));
    }
    return components;
  }

  PhotoDraftComponent _component(ParsedFoodItem item, Food? match) {
    final serving = match == null ? null : _servingFor(match, item);
    final spoken = item.quantity;
    final determined = serving != null && spoken != null && serving.amount > 0;
    return PhotoDraftComponent(
      localId: ids.next(),
      foodNameGuess: item.foodName,
      matchedFoodId: match?.id,
      matchedServingId: (serving ?? match?.defaultServing)?.id,
      matchedFoodName: match?.name,
      // Pengisi tempat bila belum ditentukan; tidak ditampilkan maupun
      // dicatat (lihat [PhotoDraftComponent.quantityUndetermined]).
      // Jumlah dalam kelipatan takaran: "200 gram" pada takaran 100 g = 2.
      quantity: determined ? spoken / serving.amount : 1,
      quantityUnitLabel: item.unit,
      quantityUndetermined: !determined,
      portionNeedsCheck: !determined || item.needsCheck,
      cookingMethodNeedsCheck: false,
    );
  }

  /// Takaran makanan yang satuannya sama dengan satuan baku yang disebut.
  static ServingSize? _servingFor(Food food, ParsedFoodItem item) {
    if (item.unitStatus != ParsedUnitStatus.standard) return null;
    return ServingUnitMatcher.servingForUnit(food, item.unit);
  }
}
