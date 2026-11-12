import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/core/errors/result.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/data/local/drift_diary_repository.dart';
import 'package:mealora/data/local/drift_food_repository.dart';
import 'package:mealora/data/local/drift_packaged_food_repository.dart';
import 'package:mealora/data/local/drift_photo_draft_repository.dart';
import 'package:mealora/data/local/drift_profile_repository.dart';
import 'package:mealora/data/local/drift_program_repository.dart';
import 'package:mealora/data/local/drift_weight_repository.dart';
import 'package:mealora/data/local/reminder_settings_repository.dart';
import 'package:mealora/data/local/ui_preference_dao.dart';
import 'package:mealora/data/ocr/ocr_nutrition_label_provider.dart';
import 'package:mealora/data/remote/model_proxy_food_sentence_parser.dart';
import 'package:mealora/data/remote/model_proxy_nutrition_reader.dart';
import 'package:mealora/data/remote/openfoodfacts_product_client.dart';
import 'package:mealora/data/remote/vision_proxy_food_component_provider.dart';
import 'package:mealora/data/remote/vision_proxy_label_provider.dart';
import 'package:mealora/data/speech/device_speech_recognizer.dart';
import 'package:mealora/database/app_database.dart';
import 'package:mealora/database/storage_bootstrap.dart';
import 'package:mealora/domain/image_ai_access/fallback_nutrition_label_provider.dart';
import 'package:mealora/domain/image_ai_access/image_ai_settings.dart';
import 'package:mealora/domain/nutrition_import/nutrition_import.dart';
import 'package:mealora/domain/preferences/week_start.dart';
import 'package:mealora/domain/profile/user_profile.dart';
import 'package:mealora/domain/program/user_program.dart';
import 'package:mealora/domain/voice_input/fallback_food_sentence_parser.dart';
import 'package:mealora/domain/voice_input/rule_based_food_sentence_parser.dart';
import 'package:mealora/features/diary/diary_controller.dart';
import 'package:mealora/features/onboarding/onboarding_controller.dart'
    show
        onboardingRefreshSignalProvider,
        profileRepositoryProvider,
        programRepositoryProvider;
import 'package:mealora/features/shell/destinations.dart';
import 'package:mealora/features/weight/weight_controller.dart';

/// Pabrik basis data.
///
/// Dapat ditimpa dalam pengujian untuk memakai basis data in-memory atau
/// mensimulasikan kegagalan pembukaan penyimpanan.
final Provider<AppDatabase Function()?> databaseFactoryProvider =
    Provider<AppDatabase Function()?>((ref) => null);

/// Pembukaan dan verifikasi penyimpanan lokal.
final FutureProvider<Result<AppDatabase>> storageProvider =
    FutureProvider<Result<AppDatabase>>((ref) async {
      final result = await openLocalStorage(
        databaseFactory: ref.watch(databaseFactoryProvider),
      );
      ref.onDispose(() => result.valueOrNull?.close());
      return result;
    });

/// Penyimpanan lokal yang sudah siap dipakai.
///
/// Hanya dibaca dari pohon widget yang berada di belakang gerbang peluncuran,
/// sehingga penyimpanan dipastikan sudah terbuka dan terverifikasi.
final Provider<AppDatabase> appDatabaseProvider = Provider<AppDatabase>((ref) {
  final database = ref.watch(storageProvider).valueOrNull?.valueOrNull;
  if (database == null) {
    throw StateError(
      'appDatabaseProvider dibaca sebelum penyimpanan lokal siap.',
    );
  }
  return database;
});

final Provider<UiPreferenceDao> uiPreferenceDaoProvider =
    Provider<UiPreferenceDao>(
      (ref) => UiPreferenceDao(
        ref.watch(appDatabaseProvider),
        clock: ref.watch(clockProvider),
      ),
    );

/// Pengaturan pengingat & jam tidur di `UiPreferences` (change 013).
final Provider<ReminderSettingsRepository> reminderSettingsRepositoryProvider =
    Provider<ReminderSettingsRepository>(
      (ref) => ReminderSettingsRepository(ref.watch(uiPreferenceDaoProvider)),
    );

/// Menimpa `profileRepositoryProvider` (features/onboarding, change 005)
/// dengan implementasi Drift sungguhan. Lazy seperti provider lain — baru
/// membaca `appDatabaseProvider` saat benar-benar dipakai, yaitu di
/// belakang gerbang peluncuran tempat penyimpanan sudah siap (lihat
/// `main.dart`, overrides `ProviderScope` akar).
final Override profileRepositoryAppOverride = profileRepositoryProvider
    .overrideWith(
      (ref) => DriftProfileRepository(
        ref.watch(appDatabaseProvider),
        clock: ref.watch(clockProvider),
      ),
    );

/// Menimpa `programRepositoryProvider` (features/onboarding, change 005)
/// dengan implementasi Drift sungguhan — sama seperti
/// [profileRepositoryAppOverride].
final Override programRepositoryAppOverride = programRepositoryProvider
    .overrideWith(
      (ref) => DriftProgramRepository(
        ref.watch(appDatabaseProvider),
        clock: ref.watch(clockProvider),
        ids: ref.watch(idGeneratorProvider),
      ),
    );

/// Menimpa `foodRepositoryProvider` (features/diary, change 007) dengan
/// implementasi Drift sungguhan.
final Override foodRepositoryAppOverride = foodRepositoryProvider.overrideWith(
  (ref) => DriftFoodRepository(
    ref.watch(appDatabaseProvider),
    ids: ref.watch(idGeneratorProvider),
    clock: ref.watch(clockProvider),
  ),
);

/// Menimpa `diaryRepositoryProvider` (features/diary, change 007) dengan
/// implementasi Drift sungguhan — bergantung langsung pada
/// `DriftProgramRepository` untuk memicu pembangunan ulang potret kemajuan
/// (Design D8), dibangun sebagai instance terpisah di atas basis data yang
/// sama (aman: keduanya `DatabaseAccessor` tanpa keadaan di memori).
final Override diaryRepositoryAppOverride = diaryRepositoryProvider
    .overrideWith(
      (ref) => DriftDiaryRepository(
        ref.watch(appDatabaseProvider),
        clock: ref.watch(clockProvider),
        ids: ref.watch(idGeneratorProvider),
        programRepository: DriftProgramRepository(
          ref.watch(appDatabaseProvider),
          clock: ref.watch(clockProvider),
          ids: ref.watch(idGeneratorProvider),
        ),
      ),
    );

/// Menimpa `weightRepositoryProvider` (features/weight, change 008) dengan
/// implementasi Drift sungguhan — bergantung langsung pada
/// `DriftDiaryRepository` untuk memicu pembangunan ulang potret kemajuan
/// bersama (design D5), sama seperti [diaryRepositoryAppOverride].
final Override weightRepositoryAppOverride = weightRepositoryProvider
    .overrideWith(
      (ref) => DriftWeightRepository(
        ref.watch(appDatabaseProvider),
        clock: ref.watch(clockProvider),
        ids: ref.watch(idGeneratorProvider),
        diaryRepository: DriftDiaryRepository(
          ref.watch(appDatabaseProvider),
          clock: ref.watch(clockProvider),
          ids: ref.watch(idGeneratorProvider),
          programRepository: DriftProgramRepository(
            ref.watch(appDatabaseProvider),
            clock: ref.watch(clockProvider),
            ids: ref.watch(idGeneratorProvider),
          ),
        ),
      ),
    );

/// Menimpa `packagedFoodRepositoryProvider` (features/diary, change 009)
/// dengan implementasi Drift sungguhan, memakai `OpenFoodFactsProductClient`
/// di baliknya (Design D2) — pencarian daring opsional, hanya dipanggil
/// ketika barcode tidak ketemu di perangkat.
final Override packagedFoodRepositoryAppOverride =
    packagedFoodRepositoryProvider.overrideWith(
      (ref) => DriftPackagedFoodRepository(
        ref.watch(appDatabaseProvider),
        ids: ref.watch(idGeneratorProvider),
        clock: ref.watch(clockProvider),
        client: OpenFoodFactsProductClient(),
      ),
    );

/// HANYA untuk pengujian manual OCR lokal di perangkat TANPA memanggil
/// penyedia cloud sama sekali — jadi tidak memakai kuota Gemini sedikit pun
/// selama diaktifkan. Dibaca dari
/// `--dart-define=MEALORA_FORCE_LOCAL_OCR=true` dan digabung dengan
/// `kDebugMode` supaya build rilis SELALU memakai
/// [FallbackNutritionLabelProvider] yang sesungguhnya, apa pun nilai define
/// ini — tidak ada jalan bagi flag pengujian untuk ikut ke build yang
/// didistribusikan (bandingkan task 9.4).
///
/// Dipakai dengan: `flutter run --dart-define=MEALORA_FORCE_LOCAL_OCR=true`.
/// Hapus flag ini dari perintah untuk kembali ke jalur cloud → OCR → manual
/// yang sesungguhnya.
const bool _forceLocalOcrForTesting = bool.fromEnvironment(
  'MEALORA_FORCE_LOCAL_OCR',
);

/// Menimpa `nutritionLabelProviderProvider` (core/providers, change 010)
/// dengan [FallbackNutritionLabelProvider]: klien `mealora-model-proxy`
/// sungguhan lebih dulu (alamat proksi dibaca dari `--dart-define` saat
/// build, lihat `VisionProxyConfig`, tidak pernah ditanam di kode), lalu
/// OCR lokal ketika penyedia cloud gagal (Design D11).
final Override nutritionLabelProviderAppOverride =
    nutritionLabelProviderProvider.overrideWithValue(
      kDebugMode && _forceLocalOcrForTesting
          ? OcrNutritionLabelProvider()
          : FallbackNutritionLabelProvider(
              primary: VisionProxyLabelProvider(
                config: VisionProxyConfig.fromEnvironment,
              ),
              fallback: OcrNutritionLabelProvider(),
            ),
    );

/// Menimpa `foodComponentRecognitionProviderProvider` (core/providers,
/// change 011) dengan `VisionProxyFoodComponentProvider` sungguhan — sama
/// dengan [nutritionLabelProviderAppOverride], TIDAK ADA jalur OCR lokal:
/// pengenalan komponen hanya bermakna lewat model penglihatan (Design D1),
/// jadi kegagalan layanan bermuara langsung ke draf + jalur manual (spec,
/// "Jalur tanpa pengenalan selalu tersedia"), bukan ke fallback kedua.
final Override foodComponentRecognitionProviderAppOverride =
    foodComponentRecognitionProviderProvider.overrideWithValue(
      VisionProxyFoodComponentProvider(
        config: VisionProxyConfig.fromEnvironment,
      ),
    );

/// Menimpa `photoDraftRepositoryProvider` (features/diary, change 011)
/// dengan implementasi Drift sungguhan.
final Override photoDraftRepositoryAppOverride = photoDraftRepositoryProvider
    .overrideWith(
      (ref) => DriftPhotoDraftRepository(
        ref.watch(appDatabaseProvider),
        clock: ref.watch(clockProvider),
      ),
    );

/// Profil lokal perangkat ini sudah lengkap (Design D2, change 005) — gerbang
/// antara alur onboarding dan ruang utama. `null`/belum lengkap berarti
/// onboarding, apa pun alasannya (belum pernah diisi, atau ditinggalkan di
/// tengah jalan).
///
/// Mengawasi `onboardingRefreshSignalProvider` supaya aktivasi yang
/// berhasil (task 5.5) memaksa pembacaan ulang, bukan memakai nilai yang
/// pernah dihitung sebelum program aktif.
final FutureProvider<bool> isOnboardingCompleteProvider = FutureProvider<bool>((
  ref,
) async {
  ref.watch(onboardingRefreshSignalProvider);
  final repository = ref.watch(profileRepositoryProvider);
  final profile = await repository.current();
  return profile?.isOnboardingComplete ?? false;
});

/// Profil lokal untuk sapaan dan identitas pada ruang utama.
final FutureProvider<UserProfile?> currentProfileProvider =
    FutureProvider<UserProfile?>((ref) async {
      ref.watch(onboardingRefreshSignalProvider);
      return ref.watch(profileRepositoryProvider).current();
    });

/// Program aktif atau dijeda milik profil ini, atau `null` bila belum ada
/// (task 7.1; keadaan "belum ada program", `36`).
final FutureProvider<UserProgram?> activeProgramProvider =
    FutureProvider<UserProgram?>((ref) async {
      ref.watch(onboardingRefreshSignalProvider);
      final profileRepository = ref.watch(profileRepositoryProvider);
      final profile = await profileRepository.current();
      if (profile == null) {
        return null;
      }
      final programRepository = ref.watch(programRepositoryProvider);
      return programRepository.findRunning(profile.id);
    });

/// Ruang navigasi yang sedang dibuka.
///
/// Dipulihkan dari penyimpanan lokal saat aplikasi dibuka kembali, dan
/// disimpan setiap kali pengguna berpindah ruang.
final AsyncNotifierProvider<SelectedDestination, MealoraDestination>
selectedDestinationProvider =
    AsyncNotifierProvider<SelectedDestination, MealoraDestination>(
      SelectedDestination.new,
    );

class SelectedDestination extends AsyncNotifier<MealoraDestination> {
  @override
  Future<MealoraDestination> build() async {
    final dao = ref.watch(uiPreferenceDaoProvider);
    final stored = await dao.read(UiPreferenceKeys.selectedDestination);
    return MealoraDestination.fromStorageKey(stored) ??
        MealoraDestination.today;
  }

  Future<void> select(MealoraDestination destination) async {
    state = AsyncValue<MealoraDestination>.data(destination);
    await ref
        .read(uiPreferenceDaoProvider)
        .write(UiPreferenceKeys.selectedDestination, destination.storageKey);
  }
}

/// Pengaturan persetujuan unggah gambar (change 010, task 3.5) — bawaan
/// [ImageUploadConsentPreference.askEachTime] sampai pengguna sendiri
/// menetapkan pilihan tetap (Design D3).
final AsyncNotifierProvider<
  ImageUploadConsentSetting,
  ImageUploadConsentPreference
>
imageUploadConsentPreferenceProvider =
    AsyncNotifierProvider<
      ImageUploadConsentSetting,
      ImageUploadConsentPreference
    >(ImageUploadConsentSetting.new);

class ImageUploadConsentSetting
    extends AsyncNotifier<ImageUploadConsentPreference> {
  @override
  Future<ImageUploadConsentPreference> build() async {
    final dao = ref.watch(uiPreferenceDaoProvider);
    final stored = await dao.read(UiPreferenceKeys.imageUploadConsent);
    return stored == null
        ? ImageUploadConsentPreference.defaultValue
        : ImageUploadConsentPreference.fromStableCode(stored);
  }

  Future<void> set(ImageUploadConsentPreference preference) async {
    state = AsyncValue<ImageUploadConsentPreference>.data(preference);
    await ref
        .read(uiPreferenceDaoProvider)
        .write(UiPreferenceKeys.imageUploadConsent, preference.stableCode);
  }
}

/// Pengaturan retensi foto label sumber (change 010, task 3.6) — bawaan
/// [ImageRetentionPreference.deleteAfterLogging] (rancangan `35`).
final AsyncNotifierProvider<ImageRetentionSetting, ImageRetentionPreference>
imageRetentionPreferenceProvider =
    AsyncNotifierProvider<ImageRetentionSetting, ImageRetentionPreference>(
      ImageRetentionSetting.new,
    );

class ImageRetentionSetting extends AsyncNotifier<ImageRetentionPreference> {
  @override
  Future<ImageRetentionPreference> build() async {
    final dao = ref.watch(uiPreferenceDaoProvider);
    final stored = await dao.read(UiPreferenceKeys.imageRetention);
    return stored == null
        ? ImageRetentionPreference.defaultValue
        : ImageRetentionPreference.fromStableCode(stored);
  }

  Future<void> set(ImageRetentionPreference preference) async {
    state = AsyncValue<ImageRetentionPreference>.data(preference);
    await ref
        .read(uiPreferenceDaoProvider)
        .write(UiPreferenceKeys.imageRetention, preference.stableCode);
  }
}

/// Awal minggu untuk kalender Riwayat dan ringkasan mingguan Program
/// (rancangan `65`) — bawaan [WeekStart.monday].
final AsyncNotifierProvider<WeekStartSetting, WeekStart> weekStartProvider =
    AsyncNotifierProvider<WeekStartSetting, WeekStart>(WeekStartSetting.new);

class WeekStartSetting extends AsyncNotifier<WeekStart> {
  @override
  Future<WeekStart> build() async {
    final dao = ref.watch(uiPreferenceDaoProvider);
    final stored = await dao.read(UiPreferenceKeys.weekStart);
    return stored == null
        ? WeekStart.defaultValue
        : WeekStart.fromStableCode(stored);
  }

  Future<void> set(WeekStart weekStart) async {
    state = AsyncValue<WeekStart>.data(weekStart);
    await ref
        .read(uiPreferenceDaoProvider)
        .write(UiPreferenceKeys.weekStart, weekStart.stableCode);
  }
}

/// Menimpa `speechRecognizerProvider` (core/providers, change 012) dengan
/// [DeviceSpeechRecognizer]: pengenalan ucapan di perangkat, tanpa jalur ke
/// layanan luar (Design D2).
final Override speechRecognizerAppOverride = speechRecognizerProvider
    .overrideWithValue(DeviceSpeechRecognizer());

/// Menimpa `foodSentenceParserProvider` (core/providers, change 012):
/// proksi `/parse-food-text` lebih dulu, lalu pengurai aturan di perangkat
/// ketika proksi tidak tersedia (Design D14).
final Override foodSentenceParserAppOverride = foodSentenceParserProvider
    .overrideWithValue(
      FallbackFoodSentenceParser(
        primary: ModelProxyFoodSentenceParser(
          config: VisionProxyConfig.fromEnvironment,
        ),
        fallback: const RuleBasedFoodSentenceParser(),
      ),
    );

/// Klien proksi baca info gizi (change 020, design D2): satu instans untuk
/// jalur teks dan jalur gambar.
final ModelProxyNutritionReader _nutritionReader = ModelProxyNutritionReader(
  config: VisionProxyConfig.fromEnvironment,
);

/// Menimpa `nutritionTextReaderProvider` (core/providers, change 020).
final Override nutritionTextReaderAppOverride = nutritionTextReaderProvider
    .overrideWithValue(_nutritionReader);

/// Menimpa `nutritionReadingPipelineProvider` (core/providers, change 020):
/// AI vision (dengan izin) → OCR ML Kit + teks → OCR + pembaca lokal
/// (design D3).
final Override nutritionReadingPipelineAppOverride =
    nutritionReadingPipelineProvider.overrideWithValue(
      NutritionReadingPipeline(
        imageReader: _nutritionReader,
        textReader: _nutritionReader,
        recognizeText: OcrNutritionLabelProvider.recognizeWithMlKit,
      ),
    );
