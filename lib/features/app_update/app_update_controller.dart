import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mealora/app/providers.dart';
import 'package:mealora/core/providers.dart';
import 'package:mealora/data/local/app_update_preference_store.dart';
import 'package:mealora/data/remote/proxy_app_config_source.dart';
import 'package:mealora/data/remote/vision_proxy_label_provider.dart'
    show VisionProxyConfig;
import 'package:mealora/domain/app_update/app_update.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Sumber konfigurasi versi (change 017, design D3). Ganti override ini saat
/// pindah ke Supabase.
final Provider<AppConfigSource> appConfigSourceProvider =
    Provider<AppConfigSource>(
      (ref) => ProxyAppConfigSource(config: VisionProxyConfig.fromEnvironment),
    );

/// Layanan cek update; null bila platform bukan Android/iOS atau versi
/// terpasang tidak dapat dibaca (fitur diam, fail-open).
final FutureProvider<AppUpdateService?> appUpdateServiceProvider =
    FutureProvider<AppUpdateService?>((ref) async {
      final platform = switch (defaultTargetPlatform) {
        TargetPlatform.android => AppStorePlatform.android,
        TargetPlatform.iOS => AppStorePlatform.ios,
        _ => null,
      };
      if (platform == null) return null;
      final info = await PackageInfo.fromPlatform();
      final installed = AppVersion.tryParse(info.version);
      if (installed == null) return null;
      return AppUpdateService(
        source: ref.watch(appConfigSourceProvider),
        store: AppUpdatePreferenceStore(ref.watch(uiPreferenceDaoProvider)),
        clock: ref.watch(clockProvider),
        installed: installed,
        platform: platform,
      );
    });

/// Status cek update yang dibaca gerbang UI (design D6).
final NotifierProvider<AppUpdateController, AppUpdateStatus>
appUpdateControllerProvider =
    NotifierProvider<AppUpdateController, AppUpdateStatus>(
      AppUpdateController.new,
    );

class AppUpdateController extends Notifier<AppUpdateStatus> {
  bool _checking = false;

  @override
  AppUpdateStatus build() => const AppUpdateNone();

  /// Cek saat app dibuka ([throttled] false) atau saat resume (true, batas
  /// 1 jam). Kegagalan apa pun membiarkan status apa adanya (fail-open).
  Future<void> check({bool throttled = false}) async {
    if (_checking) return;
    _checking = true;
    try {
      final service = await ref.read(appUpdateServiceProvider.future);
      if (service == null) return;
      if (!throttled && state is AppUpdateNone) {
        // Wajib update dari cache berlaku seketika, sebelum jaringan.
        final cached = await service.cachedStatus();
        if (cached is AppUpdateForced) state = cached;
      }
      final next = await service.refresh(throttled: throttled);
      if (next != null) state = next;
    } on Object {
      // Fail-open: cek update tidak boleh mengganggu pemakaian app.
    } finally {
      _checking = false;
    }
  }

  /// "Nanti": versi ini tidak ditawarkan lagi.
  Future<void> dismiss(AppVersion version) async {
    state = const AppUpdateNone();
    try {
      final service = await ref.read(appUpdateServiceProvider.future);
      await service?.dismiss(version);
    } on Object {
      // Gagal menyimpan hanya berarti tawaran bisa muncul lagi.
    }
  }

  /// "Update" pada sheet: tutup tawaran untuk sesi ini tanpa menyimpan
  /// penundaan, sehingga muncul lagi bila update belum terpasang.
  void acknowledge() {
    if (state is AppUpdateOptional) state = const AppUpdateNone();
  }
}
