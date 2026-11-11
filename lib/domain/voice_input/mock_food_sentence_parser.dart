import 'package:mealora/domain/image_ai_access/label_service_failure.dart';
import 'package:mealora/domain/voice_input/food_sentence_parser.dart';

/// Tiruan [FoodSentenceParser] untuk pengujian tanpa jaringan, termasuk
/// mode gagal (change 012, task 5.5).
final class MockFoodSentenceParser implements FoodSentenceParser {
  MockFoodSentenceParser.returning(ParsedSentence sentence)
    : _outcome = FoodSentenceParsed(sentence);

  MockFoodSentenceParser.failing(LabelServiceFailureReason reason)
    : _outcome = FoodSentenceParseUnavailable(reason);

  final FoodSentenceParseOutcome _outcome;

  final List<String> received = <String>[];

  @override
  Future<FoodSentenceParseOutcome> parse(String sentence) async {
    received.add(sentence);
    return _outcome;
  }
}
