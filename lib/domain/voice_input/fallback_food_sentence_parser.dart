import 'package:mealora/domain/voice_input/food_sentence_parser.dart';

/// Merangkai pengurai layanan dan pengurai di perangkat (change 012, design
/// D14, task 5.9) — pola yang sama dengan `FallbackNutritionLabelProvider`
/// change 010.
///
/// Layanan dicoba lebih dulu. Bila tidak tersedia, kalimat diurai di
/// perangkat; bila itu pun tidak menghasilkan satu makanan, alasan kegagalan
/// layanan diteruskan supaya layar menyatakannya dan menawarkan katalog.
final class FallbackFoodSentenceParser implements FoodSentenceParser {
  const FallbackFoodSentenceParser({
    required this.primary,
    required this.fallback,
  });

  final FoodSentenceParser primary;
  final FoodSentenceParser fallback;

  @override
  Future<FoodSentenceParseOutcome> parse(String sentence) async {
    final first = await primary.parse(sentence);
    if (first is FoodSentenceParsed) return first;

    final second = await fallback.parse(sentence);
    if (second is FoodSentenceParsed && second.sentence.hasItems) {
      return second;
    }
    return first;
  }
}
