import 'package:mealora/core/ids/id_generator.dart';
import 'package:mealora/domain/food/food.dart';
import 'package:mealora/domain/food/serving_unit_matcher.dart';
import 'package:mealora/domain/food_photo_input/food_component_recognition.dart';
import 'package:mealora/domain/food_photo_input/photo_draft.dart';
import 'package:mealora/domain/image_ai_access/reading_confidence.dart';

/// Mengubah satu komponen hasil pengenalan foto menjadi komponen draf
/// (change 011), dengan satuan dicocokkan ke takaran memakai logika yang
/// sama dengan input suara (change 015, design.md D10):
///
/// - satuan yang cocok dengan takaran → takaran itu, jumlah dalam kelipatan
///   takaran (150 g pada takaran 100 g = 1,5);
/// - satuan tak dikenali → takaran bawaan, jumlah 1, porsi ditandai perlu
///   dicek — angka dengan satuan lain tidak pernah dipakai sebagai kelipatan
///   takaran bawaan;
/// - tanpa satuan → takaran bawaan dengan jumlah yang terbaca.
PhotoDraftComponent buildPhotoDraftComponent({
  required IdGenerator ids,
  required RecognizedComponent recognized,
  required Food? match,
}) {
  final quantity = recognized.quantity;
  final unit = ServingUnitMatcher.canonicalUnit(quantity.unit);
  final value = quantity.value;
  final matched = match == null || unit == null
      ? null
      : ServingUnitMatcher.servingForUnit(match, unit);
  final unitUnmatched = match != null && unit != null && matched == null;

  final serving = matched ?? match?.defaultServing;
  final double draftQuantity;
  if (matched != null && value != null && matched.amount > 0) {
    draftQuantity = value / matched.amount;
  } else if (unitUnmatched) {
    draftQuantity = 1;
  } else {
    draftQuantity = value ?? 1;
  }

  return PhotoDraftComponent(
    localId: ids.next(),
    foodNameGuess: recognized.foodNameGuess,
    matchedFoodId: match?.id,
    matchedServingId: serving?.id,
    matchedFoodName: match?.name,
    quantity: draftQuantity,
    quantityUnitLabel: quantity.unit,
    cookingMethod: recognized.cookingMethod.value,
    portionNeedsCheck: unitUnmatched || quantity.confidence.needsUserAttention,
    cookingMethodNeedsCheck:
        recognized.cookingMethod.confidence == ReadingConfidence.needsCheck,
  );
}
