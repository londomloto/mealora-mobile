import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/theme/color_tokens.dart';
import 'package:mealora/app/theme/typography_tokens.dart';
import 'package:mealora/core/clock/clock.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/domain/food/meal_time.dart';
import 'package:mealora/domain/food_photo_input/food_component_matcher.dart';
import 'package:mealora/domain/food_photo_input/photo_draft.dart';
import 'package:mealora/domain/image_ai_access/label_service_failure.dart';
import 'package:mealora/domain/voice_input/food_sentence_parser.dart';
import 'package:mealora/domain/voice_input/voice_draft_builder.dart';
import 'package:mealora/features/diary/diary_controller.dart'
    show foodRepositoryProvider;
import 'package:mealora/features/diary/food_photo_review_screen.dart';
import 'package:mealora/features/diary/food_search_screen.dart';
import 'package:mealora/features/onboarding/onboarding_controller.dart'
    show profileRepositoryProvider;
import 'package:mealora/l10n/generated/app_localizations.dart';

/// Membuka pencarian katalog — jalur yang selalu bekerja luring (spec
/// voice-food-input, "Jalur mengetik kalimat selalu tersedia").
void openVoiceCatalogSearch(BuildContext context, LocalDate? date) {
  Navigator.of(context).pushReplacement(
    MaterialPageRoute<void>(builder: (_) => FoodSearchScreen(date: date)),
  );
}

/// Pemberitahuan yang ditampilkan di layar setelah penguraian tidak
/// menghasilkan daftar makanan. Teks kalimat SHALL tetap dipertahankan
/// (task 5.6).
final class VoiceParseNotice {
  const VoiceParseNotice({required this.title, required this.body});

  final String title;
  final String body;
}

/// Titik tunggal tempat teks kalimat diserahkan ke penguraian (task 5.1).
///
/// Mengembalikan [VoiceParseNotice] bila tidak ada daftar makanan; `null`
/// bila penguraian berhasil dan peninjauan komponen change 011 sudah
/// dibuka (design D7). Tidak ada catatan yang dibuat di sini; pencatatan
/// terjadi di peninjauan setelah konfirmasi.
Future<VoiceParseNotice?> submitVoiceSentence(
  BuildContext context,
  WidgetRef ref,
  String sentence, {
  LocalDate? date,
}) async {
  final text = AppText.of(context);
  final messenger = ScaffoldMessenger.of(context);
  final outcome = await ref.read(foodSentenceParserProvider).parse(sentence);
  switch (outcome) {
    case FoodSentenceParseUnavailable(:final reason):
      return VoiceParseNotice(
        title: text.voiceParseUnavailableTitle,
        body: switch (reason) {
          LabelServiceFailureReason.offline =>
            text.voiceParseUnavailableOffline,
          LabelServiceFailureReason.timeout =>
            text.voiceParseUnavailableTimeout,
          LabelServiceFailureReason.quotaExceeded =>
            text.voiceParseUnavailableQuota,
          LabelServiceFailureReason.refused =>
            text.voiceParseUnavailableRefused,
        },
      );
    case FoodSentenceParsed(:final sentence)
        when !sentence.hasItems && sentence.nonFoodRequests.isNotEmpty:
      // Batas cakupan (task 6.1): tidak ada yang dijalankan; tunjukkan
      // tempat yang tepat untuk permintaan pertama.
      return VoiceParseNotice(
        title: text.voiceScopeRejectedTitle,
        body: text.voiceScopeRejectedBody(
          _whereFor(text, sentence.nonFoodRequests.first),
        ),
      );
    case FoodSentenceParsed(:final sentence) when !sentence.hasItems:
      return VoiceParseNotice(
        title: text.voiceParseNothingFoundTitle,
        body: text.voiceParseNothingFoundBody,
      );
    case FoodSentenceParsed(:final sentence):
      if (sentence.nonFoodRequests.isNotEmpty) {
        messenger
          ..hideCurrentSnackBar()
          ..showSnackBar(
            SnackBar(
              content: Text(text.voiceParsedIgnoredPartShort),
              behavior: SnackBarBehavior.floating,
            ),
          );
      }
      final profile = await ref.read(profileRepositoryProvider).current();
      if (profile == null || !context.mounted) return null;
      final clock = ref.read(clockProvider);
      final ids = ref.read(idGeneratorProvider);
      final components = await VoiceDraftBuilder(
        matcher: FoodComponentMatcher(ref.read(foodRepositoryProvider)),
        ids: ids,
      ).build(sentence);
      if (!context.mounted) return null;
      // Draf hidup di memori saja (ComponentDraftOrigin.persistsDraft):
      // menutup peninjauan tidak meninggalkan draf maupun catatan (task 7.9).
      final draft = PhotoDraft(
        id: ids.next(),
        profileId: profile.id,
        localDate: date ?? clock.today(),
        mealTime: MealTime.lunch,
        components: components,
        createdAt: clock.nowUtc(),
      );
      await Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => FoodPhotoReviewScreen(
            draft: draft,
            origin: sentence.source == ParseSource.onDevice
                ? ComponentDraftOrigin.voiceOnDevice
                : ComponentDraftOrigin.voice,
          ),
        ),
      );
      return null;
  }
}

String _whereFor(AppText text, String target) => switch (target) {
  'berat_badan' => text.voiceScopeWhereWeight,
  'program' => text.voiceScopeWhereProgram,
  'profil' || 'pengaturan' => text.voiceScopeWhereProfile,
  'buku_harian' => text.voiceScopeWhereDiary,
  'hari_ini' => text.voiceScopeWhereToday,
  _ => text.voiceScopeWhereOther,
};

/// Label komponen yang jumlahnya belum ditentukan (task 7.1/7.3) — satuan
/// yang diucapkan ditampilkan apa adanya, tanpa angka tebakan.
String voiceUndeterminedLabel(AppText text, String? spokenUnit) =>
    spokenUnit == null || spokenUnit.isEmpty
    ? text.voiceQuantityUndetermined
    : text.voiceQuantityUndeterminedWithUnit(spokenUnit);

/// Tautan teks berpanah, gaya `Tanpa internet? Cari di katalog →`.
class VoiceTextLink extends StatelessWidget {
  const VoiceTextLink({required this.label, required this.onTap, super.key});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      link: true,
      label: label,
      excludeSemantics: true,
      child: Center(
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Flexible(
                    child: Text(
                      label,
                      textAlign: TextAlign.center,
                      style: MealoraTypography.bodyEmphasis.copyWith(
                        color: MealoraColors.primaryDeep,
                      ),
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.arrow_forward,
                    size: 16,
                    color: MealoraColors.primaryDeep,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
