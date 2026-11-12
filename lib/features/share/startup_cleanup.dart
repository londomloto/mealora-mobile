import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/domain/image_ai_access/image_ai_settings.dart';
import 'package:mealora/features/diary/diary_controller.dart';
import 'package:mealora/features/diary/food_photo_draft_storage.dart';
import 'package:mealora/features/onboarding/onboarding_controller.dart';
import 'package:mealora/features/share/share_service.dart';

/// Pembersihan sekali saat start (change 014, task 1.3/3.3, Design D4):
/// PNG kartu sementara selalu dihapus; foto draf yatim dihapus bila retensi
/// "hapus setelah dicatat". Tidak pernah melempar — kegagalan berkas
/// sementara tidak boleh menghalangi aplikasi.
final FutureProvider<void> startupStorageCleanupProvider = FutureProvider<void>(
  (ref) async {
    final startedAt = ref.read(clockProvider).nowUtc();
    await clearShareCards();
    try {
      final retention = await ref.read(imageRetentionPreferenceProvider.future);
      if (retention != ImageRetentionPreference.deleteAfterLogging) return;
      final profile = await ref.read(profileRepositoryProvider).current();
      final draft = profile == null
          ? null
          : await ref.read(photoDraftRepositoryProvider).current(profile.id);
      await deleteOrphanDraftPhotos(
        referencedPaths: <String>{?draft?.sourceImagePath},
        olderThanUtc: startedAt,
      );
    } on Object {
      // Lihat dokumentasi provider.
    }
  },
);
